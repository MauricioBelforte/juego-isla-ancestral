**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 63: Cargas y Streaming

## 1. Resolución de los 15 puntos del plan maestro

| # | Punto | Resolución |
|---|---|---|
| 1 | Pantalla de carga | Escena `LoadingScreen.tscn` con arte cozy (nubes, islas dibujadas), barra de progreso REAL calculada sobre operaciones encoladas, consejos del mundo y Skip deshabilitado (UX sección 8 AGENTS) |
| 2 | Cargas asíncronas | `ResourceLoader.load_threaded_request(path, type, use_sub_threads)` para: escenas, bancos de audio, texturas grandes; cola con prioridad |
| 3 | Chunks cercanos | El voxel (M08) prioriza chunks por distancia radial; radio streaming base R=3, máx 5 en movimiento rápido; señal por chunk listo |
| 4 | Chunks lejanos | LRU con tope de chunks en memoria; descarga diferida (2 frames después de salir del radio) para evitar parpadeo |
| 5 | NPCs necesarios | Nodos NPC solo dentro de radio de actividad (se instancian al entrar, se pausan al salir — M63-RF4) |
| 6 | Audio | Bancos por región: los de la zona se precargan en el hilo de streaming; sin `load()` en tiempo de juego |
| 7 | Texturas | Atlas por bioma + mips; carga por LOD: mip base al entrar, mip alto al acercar (streaming de mipmaps) |
| 8 | Shaders | Compilación en PRECALIENTE (menú principal): shaders del mundo y de efectos compilados antes del spawn; caché de variantes |
| 9 | Precalentar | En el menú: `precalentar_mundo()` (chunks iniciales + shaders + bancos) → el viaje al mundo es casi instantáneo |
| 10 | Evitar congelamientos | Ninguna carga en el hilo main: reglas verificables (deltas < 50 ms; profiler M113) |
| 11 | Progreso real | El total = suma ponderada de ítems encolados; cada ítem reporta avance (loaded/count) → barra nunca fija ni falsa |
| 12 | Streaming del océano | Océano como mesh semáforo por región (LOD 0 base lejano + mallas costa cerca): solo se actualiza el horizonte (anillo) |
| 13 | Streaming subterráneo | Subterráneo = regiones grandes con LOD profundo; el jugador que profundiza carga por pisos (0-2), descarga techo al salir |
| 14 | Streaming de islas | Islas flotantes (M09/M27): cada isla = chunk StreamableBox; descargar al salir 10 m del borde; subir/bajar sin huecos (encadenado de LOD) |
| 15 | Probar movimientos rápidos | Test de QA: teleport de punta a punta del mapa en 10 s sin hitching ni chunks vacíos visibles |

## 2. Decisiones clave

1. **Progreso real por encolado ponderado**: cada operación es una unidad con peso (chunk=1, banco=3, shader=5); la barra refleja la suma de pesos completados / total — honesto y smooth.
2. **Precalentamiento en menú principal**: el 90% de la carga visible se adelanta; la pantalla de carga del mundo queda corta (~1-3 s).
3. **LRU con tope duro** en chunks (M08): memoria predecible y sin fugas; descarga diferida 2 frames (anti-parpadeo).
4. **Streaming por región** (océano/islas/subterráneo): los mundos con estructura propia no se comportan como voxel plano — cada uno con su LOD y cola.
5. **Cero cargas síncronas en runtime** (regla M61): todo `load`/`preload` ocurre en arranque o en hilos.

## 3. Alternativas descartadas

- **Barra de progreso falsa (fake timers):** engañosa y rompe la sección 8 (progreso real); descartado (pesos por operación).
- **Streaming "todo instanciado de una vez" para islas pequeñas:** el mapa tiene decenas de islas (M27); memoria inaceptable; descartado (StreamableBox por isla).
- **Cambiar LOD de chunks con operaciones síncronas de mesh:** provoca hitching notable (congelamiento); descartado (generación en hilos + cola).
- **Consejos de carga elegidos con `randi()` (no deterministas):** rompe la reproducibilidad de QA y el "misma partida → misma experiencia"; descartado (rotación determinista por semilla de partida M29, `ConsejosCarga.indice_inicial`). *(iter. 6, Log 1193)*
- **Fundido con `Tween` acoplado al árbol de escena:** no se puede ejercitar en headless sin montar el árbol; descartado (máquina de estados PURA `FundidoCarga` separada de la animación del nodo, testeable headless). *(iter. 6, Log 1193)*

## 4. Dependencias y bloqueos (L150)

- **M08 (voxel/chunks)** — *bloqueante de la parte no-headless*: el poblado REAL de chunks (radio R=3, máx 5 en movimiento rápido), los buffers de VoxelTools y la generación de mallas en hilos son de M08. El 63 aporta la DECISIÓN (cola, LRU, `registrar_chunk()`); la instanciación es del 08. **No bloquea** la lógica headless (ya implementada y medida).
- **M61 (rendimiento/pool)** — *solo consumir, NO tocar* (en curso por otro agente, regla §21.4): el 63 consume sus presupuestos y suelta la referencia de malla (`unreference()`); el pool de meshes reutilizado es suyo.
- **M28/M69 (viaje/teleport)** — el 63 aporta `toca_precargar_destino()` (60% de la ruta) y `corona_oceano()`/`piso_subterraneo()`; el enganche real del vuelo es de esos módulos → `[?]`.
- **M29 (partida/save)** — el 63 lee la semilla de partida vía el autoload `GameTime` (`get_semilla_partida()`) y persiste su estado en su propia sección "stream" (ISaveProvider M59), sin acoplarse al save del mundo.
- **M53/M46/M47/M90/M112/M113/M114** — arte cozy, LoadingScreen reutilizable, mips por LOD, presets Deck, profiler y recorrido: dueños externos → `[?]`.

## 5. API estable (L148)

Superficie pública del módulo, congelada para los consumidores (M08/M12/M28/M69/M29/M62):

**`StreamManager` (autoload)**
- Cola: `encolar(op_id, tipo, prioridad, callable, ruta_recurso="") -> bool`, `cola_size()`, `pausar_cargas()`, `reanudar_cargas()`, `cargas_pausadas()`.
- Progreso: `progreso() -> float`, `pesos_encolados() -> float`; señales `progreso_cambiado`, `operacion_completada`, `chunk_listo`, `banco_listo`, `shader_listo`.
- LRU: `registrar_chunk(chunk_id, distancia, recurso=null)`, `chunk_activo()`, `chunks_activos()`, `marcar_envejecidos(r_max)`, `liberar_envejecidos() -> int`, `aplicar_tope() -> int`, `set_max_chunks(n)`.
- Handshake M62 (§5.3): `avisar_carga_iniciada(recurso)`, `avisar_carga_terminada(recurso)`, `recursos_en_carga_63()`, `esta_en_carga_63(recurso)`, `avisos_m62()`.
- Anti doble carga: `esta_cargando_ruta(ruta)`, `rutas_en_carga()`.
- Precalentamiento: `precalentar_mundo(opciones={}) -> int`, `operaciones_restantes()`, `precalentado()`.
- Región: `corona_oceano(dist)`, `piso_subterraneo(prof)`, `dentro_streamable_box(pos, centro)`, `toca_precargar_destino(progreso_ruta)`, `piso_liberable(piso, destino_listo)`.
- Persistencia (M59): `get_section_name() == "stream"`, `get_save_data()`, `restore_save_data(data)`.

**`ProgressCalculator` (`class_name`, estático)** — `calcular_peso_total(cola)`, `progreso(completados, total)`, `peso_de_tipo(tipo, weights={})`.

**`ConsejosCarga` (`class_name`, estático)** — `parsear(texto)`, `cargar(ruta=RUTA_DEFAULT)`, `indice_inicial(semilla, n)`, `consejo(tips, semilla, tick)`; const `INTERVALO_ROTACION`, `RUTA_DEFAULT`.

**`FundidoCarga` (`class_name`)** — `iniciar(duracion=DURACION_DEFAULT)`, `avanzar(delta)`, `alpha()`, `progreso()`, `terminado()`, `estado()`; estático `acotar_duracion(d)`; enum `Estado`; const `DURACION_MAX = 2.0`, `DURACION_DEFAULT`.

**`PantallaCarga` (autoload)** — `mostrar()`, `ocultar()`, `fundir(duracion)`, `fundiendo()`, `alpha_actual()`, `configurar_seed(semilla)`, `consejo_actual()`; señal `pantalla_oculta`.

> Regla de estabilidad: **cambios aditivos** (nuevos métodos/constantes) no rompen consumidores; renombrar o cambiar la firma de los anteriores exige coordinar con los dueños listados en §4.