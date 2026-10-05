**Modelo:** DeepSeek-V4.1-Flash (último modificador)
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-05 (iter. 7 — T-D9, Log 1325)

# 05-Checklist.md — Módulo 62: Memoria

## Reserva actual

- Estado: 🟢 En curso — iter. 6 (Log 1196) por DeepSeek-V4.1-Flash
- Agente: DeepSeek-V4.1-Flash (WorkBuddy)
- Fase: Base de producción (soporte M61 Rendimiento)
- Dificultad: 3
- Visión: V0
- Entrada: M61 🟡 (núcleo OK, presupuestos base)
- Salida: 5 defectos reales corregidos (denominador del semáforo, enforcement, muestreo por frame, drift/baseline a 5 min, pico por punto de interés) + `PoolFactory` + `LeakGuard` + `TextureMemory` + dataset regenerado por `generar_budgets.gd` + 4 suites con guardián probado por inyección (232 checks) + gate de CI en `quality.yml`
  - **iter. 4:** presupuesto de liberación por refcount **medido** (pico < 3 ms, delta de lote < 50 ms) + nodos huérfanos estables en reposo + **auditor estático de arquitectura de servicios** (`scripts/auditar_arquitectura_m62.py`, con selftest probado en rojo) + 2 gates nuevos de CI. 2 bugs nuevos (BUG-068/BUG-069).
  - **iter. 5 (Log 1187):** **handshake con M63** (el 62 nunca descarga lo que el 63 está cargando) + cola de transición de escena + región rápida → fuerza liberación + banco de audio diferido + atlas LRU con log + determinismo (RN9). Suite nueva `test_memoria_m62_iter5.gd` (**60 checks**, guardián probado con **5 sondas en rojo**, exit real verificado) + gate de CI. **9 ítems** de §K/§J/§F pasan a `[x]`. Total M62 = **307 checks**.
  - **iter. 6 (Log 1196):** **pureza de los datos de partida** (item L98): los 39 proveedores `ISaveProvider` registrados devuelven solo datos (0 Nodos) y el payload COMPLETO de `collect()` tambien. Suite `test_m62_pureza_save.gd` (58 checks) con escaner recursivo probado EN ROJO. Complemento estatico: **regla C** en `auditar_arquitectura_m62.py` (56 scripts con `get_save_data`, 0 hallazgos).
  - **iter. 7 (Log 1325, T-D9):** **test de leaks con teleport x10** (items **L105** y **L143**). Suite nueva `test_m62_leaks_teleport.gd` (**21 checks**, guardián de 3 capas probado EN ROJO con 2 inyecciones). Mide que la cola de descarga (`UnloadPolicy`) **no retiene** los `Resource` de los chunks que el teleport deja atras: 10 ciclos, 0 retenidos, `objetos_vivos` delta **0**. **PENDIENTE de cablear a `quality.yml`** (no lo toqué: es de s2/director). Total M62 = **387 checks**.
- Archivos: `game/isla-ancestral/scripts/rendimiento/memoria/` + `data/rendimiento/budgets.json` + `scripts/auditar_arquitectura_m62.py`
- Fecha cierre: (pendiente — al cerrar con `--estado`)

### Historial de reservas
- **iter. 1** (núcleo): deepseek-v4-flash / Kilo Code — 2026-09-01 19:50 (Log 390), liberado 🟡
- **iter. 2** (enforcement + pool): glm-5.3-flash / Kilo Code — 2026-09-01/03 (Log 604), liberado 🟡
- **iter. 3**: DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-19 (Log 1094)
- **iter. 4**: DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-20 (Log 1112)
- **iter. 5**: DeepSeek-V4.1-Flash / WorkBuddy — 2026-10-02 (Log 1187) — módulo **reservado de vuelta** al autor (commit `6d8d02b`)
- **iter. 6**: DeepSeek-V4.1-Flash / WorkBuddy — 2026-10-02 (Log 1196) — pureza de los datos de partida (L98) + regla C del auditor

## A. Problema y objetivos

- [x] Definir el problema: memoria creciente por chunks, señales, texturas y audio sin descarga en mundo voxel cozy [S] — **iter. 6 (Log 1196):** documentado en `01-Requerimientos.md` §1 Problema (L12-14).
- [x] Registrar dependencias: M61 (rendimiento), M08 (voxel), M63 (streaming); relaciones M41-M44, M12, M90, M103, M110 [S] — **iter. 6 (Log 1196):** `01-Requerimientos.md` §ID del Modulo (L9) lista las 3 dependencias y las 6 relaciones.
- [x] Definir el objetivo: RAM predecible y estable, sin leaks y sin picos de frame en hardware medio/bajo [S] — **iter. 6 (Log 1196):** `01-Requerimientos.md` §2 Objetivo (L16-18).
- [x] Implementar alcance núcleo: MemoryMonitor + BudgetRegistry + GlobalPool + UnloadPolicy [S]
- [x] Fijar la prioridad del módulo: Alta (la memoria condiciona a todos los demás sistemas) [S]

## B. RF1 — Monitoreo y diagnóstico

- [x] MemoryMonitor autoload: memoria_actual/pico/objetos/huérfanos/drift/semaforo + señales [M]
- [x] Muestreo periódico: cada 5 s en calma y cada 1 s con movimiento de cámara [M] — Log 1094: `intervalo_muestreo()` 5 s en calma / 1 s con movimiento + `avisar_movimiento_camara()` con vigencia de 2 s. Bloque D de `test_memoria_m62_iter3.gd`
- [x] Lectura de `OS.get_static_memory_usage()` para memoria del motor [S]
- [x] Lectura de `OS.get_static_memory_peak_usage()` para el pico máximo [S]
- [x] Lectura de `Performance.PERFORMANCE_OBJECT_COUNT` para conteo de objetos vivos [S] — Log 1094: constante CORREGIDA — en Godot 4 es `Performance.OBJECT_COUNT` (el nombre del ítem no existe). `objetos_vivos()` la lee
- [x] Lectura de `Performance.PERFORMANCE_ORPHAN_NODE_COUNT` para nodos huérfanos [S] — Log 1094: constante CORREGIDA — en Godot 4 es `Performance.OBJECT_ORPHAN_NODE_COUNT`. `nodos_huerfanos()` la lee
- [x] Lectura de `Performance.PERFORMANCE_MEMORY_STATIC` para memoria estática [S]
- [x] Contadores propios por sistema del juego (voxel, audio, texturas, escenas, pools) [C]
- [x] Costo de muestreo < 0.1 ms de media (no viola frame budgets de M61) [M]
- [x] Getters puros: consumo_de, presupuesto_de, drift_porciento, semaforo [S]
- [x] Detección de drift: comparación contra baseline estabilizada a los 5 minutos [M] — Log 1094: `drift_check()` + baseline a los 300 s (`TIEMPO_BASELINE_S`); sin baseline devuelve false a propósito. Bloque E
- [x] Registro del pico de memoria por sesión y por punto de interés (spawn, teleport, escena) [M] — Log 1094: `marcar_punto_de_interes()` / `pico_de_poi()` (spawn/teleport/escena). Bloque F
- [x] Alarma ante pico > 200 MB en un solo frame (registro y análisis) [M] — Log 1094: `_alarma_pico()` devuelve bool y cuenta en `alarmas_pico()`. La anotación previa decía «testeado» pero el test era `_check(true, "…sin crash")`, infalsificable; ahora se asertan el umbral estricto (>200) y el contador
- [x] Exportar reportes al log rotado (M103) sin afectar el gameplay [S] — Log 1094: `_log_m62()` + `exportar_reporte()`. OJO: la anotación previa («integrado en iter. 1») era FALSA — `grep -rn "GameLogger\|logger" scripts/rendimiento/` no devolvía nada y el ítem estuvo 18 días marcado sin código que lo respaldara
- [x] Estado de memoria accesible para el panel del Debug Menu (M110) [M] — MemoryMonitor autoload con APIs de estadísticas (iter. 1, deepseek); panel visual con dueño M110

## C. RF2 — Presupuestos por sistema

- [x] Tabla de presupuestos data-driven (budgets.json: 3 presets Baja/Media/Alta, 8 sistemas) [S]
- [x] Presupuesto voxel: 800 MB en preset Alta (buffers, meshes, colliders, pool) [M]
- [x] Presupuesto texturas/atlas: 400 MB en preset Alta [S] — Log 1094: `budgets.json` regenerado y validado — alta texturas=400 (el dataset divergía: tenía 384)
- [x] Presupuesto audio (M41-M44): 250 MB en preset Alta [S] — Log 1094: alta audio=250, validado por `generar_budgets.gd`
- [x] Presupuesto escenas/NPCs/objetos: 350 MB en preset Alta [S] — Log 1094: alta escenas=350, validado por `generar_budgets.gd`
- [x] Presupuesto pooling global: 200 MB en preset Alta [S]
- [x] Presupuesto UI y fuentes: 100 MB en preset Alta [S] — Log 1094: alta ui=100, validado por `generar_budgets.gd`
- [x] Presupuesto shaders/materiales: 100 MB en preset Alta [M] — Log 1094: alta shaders=100, validado por `generar_budgets.gd`
- [x] Reserva del sistema: 300 MB para cerrar el total de 2.5 GB (Alta) [S]
- [x] Presets por calidad M90: Baja 1.5 GB, Media 2.0 GB, Alta 2.5 GB [M] — Log 1094: los 3 presets existen en `budgets.json` con las sumas exactas 1500/2000/2500 y `set_preset()` probado. El consumo desde M90 es de M90
- [x] Verificación periódica: `verificar()` devuelve los sistemas sobre su tope [M] — BudgetRegistry.verificar() devuelve sistemas sobre su tope (testeado)
- [x] Enforcement suave al 90%: medidas de descarga automáticas ordenadas [M] — Log 1094: `_enforcement(actual, nivel)` se dispara desde `nivel_para()` (misma fuente de verdad que el semáforo) y usa el tope POR PRESET (`max_por_frame_para`, §5.4). Antes comparaba la memoria real del OS contra el consumo REPORTADO: con 0 sistemas reportando el total daba 0 y NUNCA corría
- [x] Enforcement duro al 95%: descarga forzada de recursos de menor prioridad sin excepción [M] — Log 1094: es el nivel 3 (no el 2: la anotación previa confundía los niveles) y re-aplica siempre, sin el gate de idempotencia. Probado con aserciones reales, no con «sin crash»
- [x] La suma de topes por preset es fija: ningún sistema crece sin bajar otro (check en tests) [M] — Log 1094: `generar_budgets.gd` aborta la escritura si la suma no es exactamente la declarada (1500/2000/2500). Antes los 8 sistemas de los 3 presets divergían del diseño §2 (1664/2112/2560)

## D. RF3 — Pooling global

- [x] GlobalPool: obtener/devolver/precalentar/límites/liberar_todo por familia [M]
- [x] Familia `audio_voz`: voces del pool de M43 reutilizadas sin instanciar de nuevo [S]
- [x] Familia `particula`: efectos de clima, herramientas y esporas de luz (M11/M32) [M] — Log 1094: definida en `PoolFactory.FAMILIAS` (64/8) y probada
- [x] Familia `mesh_chunk`: meshes de chunks voxel reutilizados sin allocs por frame [C]
- [x] Familia `objeto_recogible`: objetos lanzados o dropeados (M15) [M] — Log 1094: definida en `PoolFactory.FAMILIAS` (64/0) y probada
- [x] Familia `texto_efimero`: textos flotantes y notificaciones UI (M53) [S] — Log 1094: definida (32/4) y en `PRECALENTAMIENTO_ARRANQUE`
- [x] Familia `npc_temporal`: NPCs de visita o eventos con reinicio de estado limpio [C] — Log 1094: definida (16/0) y probada
- [x] API única: `obtener()`, `devolver()`, `precalentar()`, `limite()`, `tamanio()` [M] — iter. 2 (Log 604): las 5 ya existían de iter. 1 (deepseek) y ahora con estados completos: obtener ACTIVA (proceso on/visible), devolver ESTACIONA (proceso off/invisible/sin señales); testeado round-trip
- [x] Precalentamiento al arrancar y en pantalla de carga (M63), nunca en mitad de gameplay [M] — Log 1094: `precalentar()` devuelve cuántos creó y la ventana se cierra con `marcar_gameplay_iniciado()`; en gameplay devuelve 0 y avisa (probado)
- [x] Límite por familia configurable (set_limite, base 256 por defecto) [S]
- [x] Fallback honesto: si el pool está lleno se usa `queue_free()` en vez de crecer sin tope [S] — iter. 2: devolver() con pool lleno hace queue_free y retorna false; testeado (pool NO crece más allá del límite)
- [x] Ítems devueltos: invisibles, quietos, sin señales activas y sin referencias externas [M] — Log 1094: `esta_limpio()` VERIFICA las 4 condiciones del diseño §4 en vez de confiar en que se cumplieron
- [x] Contadores: tamanio, limite, familias expuestos [S]
- [x] Test de integridad: un ítem devuelto al pool no retiene referencias externas [C]

## E. RF4 — Prevención de leaks

- [x] Auditoría de señales: todo `connect()` se desconecta explícitamente al liberar el nodo [M] — iter. 2: _auditar_senales() en devolver() desconecta conexiones ENTRANTES (get_incoming_connections) del nodo estacionado; testeado (receptor sin conexiones tras devolver)
- [x] Regla: prohibido conectar señales a lambdas que capturen nodos externos sin limpieza [M] — Log 1094: `LeakGuard.tiene_bound()` detecta los callables con `.bind()` y `limpiar()` los desconecta (probado)
- [x] Patrón de desconexión central en `_exit_tree()` documentado para todos los módulos [S] — Log 1094: `LeakGuard` centraliza `conectar()` y limpia solo en `_exit_tree()` (probado)
- [x] Timers cancelados en `_exit_tree()` de cada nodo que los posea [S] — Log 1094: `registrar_timer()` + `limpiar()`; probado que el timer deja de correr
- [x] Tweens cancelados en `_exit_tree()` (evita callables repetitivos que retienen) [S] — Log 1094: `registrar_tween()` + `limpiar()`; probado que el tween muere
- [x] Prohibido crear Node sin padre que quede huérfano; chequeo con contador de orphans [S] — Log 1094: holder anti-huérfano en `GlobalPool` + `LeakGuard.contar_huerfanos()`; probado que el ítem estacionado cuelga del holder
- [x] Policy de recursos compartidos: `duplicate(false)` y caché con un solo dueño (D6) [M] — Log 1094: `LeakGuard.recursos_duplicados()` agrupa por `resource_path`+`instance_id` y detecta la doble carga (probado)
- [ ] Texturas de región se liberan al salir de la misma (con M63 y M09) [M]
- [x] Los datos de partida (M29) no retienen referencias a nodos del mundo [M] — **iter. 6 (Log 1196): MEDIDO.** `test_m62_pureza_save.gd` (58 checks, 0 fallos): los 39 proveedores registrados y el payload completo de `collect()` dan 0 Objects; escaner recursivo probado EN ROJO (bloque D). Complemento estatico: regla C del auditor (56 scripts con `get_save_data`, 0 hallazgos).
- [x] Partículas y audio se detienen y devuelven al pool al desactivar la fuente [M]
- [x] Los callables con bound parameters se desconectan en `_exit_tree` (anti-leak de lambdas) [M] — Log 1094: `LeakGuard.conectar()` guarda el Callable EXACTO (incluido el `.bind()`), así el disconnect funciona; probado
- [ ] Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares) [C] — **iter. 4 (Log 1112): SIGUE ABIERTO, y ahora hay evidencia de por qué.** El auditor nuevo mide **2 componentes fuertemente conexas** (7 nodos: `CollectionRegistry, Fishing, GameTime, Inventario, SaveManager, TimeCalendar, Weather`; y 2 nodos: `ThemeService, UIManager`) más 9 referencias a un autoload declarado después. Escalado como **BUG-069**; el gate los tiene en lista de permitidos para que ningún ciclo NUEVO pase
- [ ] Sesión de referencia: 30 min de juego sin drift > 5% sobre la línea base [C]
- [x] Test de leaks con teleport ×10 y conteo de objetos antes/después (debe ser igual) [C] — **iter. 7 (Log 1325, T-D9): MEDIDO.** `test_m62_leaks_teleport.gd` (21 checks, 0 fallos, ×3 idénticas): 10 ciclos de teleport dejan 240 `Resource` como candidatos a descarga; tras `ejecutar_descarga()` **0 retenidos** (verificado con `WeakRef`) y `objetos_vivos` **delta 0** (base 3618 = fin 3618). Guardián de 3 capas probado EN ROJO con 2 inyecciones. **Alcance:** mide la contratación de M62 (que su cola de descarga no retenga recursos), no el teleport con mundo real — eso sigue siendo Play Mode (L213).

## F. RN — Requisitos no funcionales

- [ ] RN1: presupuesto de RAM objetivo ≤ 2.5 GB en PCs de gama media (preset Alta) [M]
- [ ] RN1: preset Baja ≤ 1.5 GB para gama baja con 4 GB de RAM [M]
- [x] RN2: sin picos de frame: deltas < 50 ms durante descargas o liberaciones [M] — **iter. 4 (Log 1112): MEDIDO.** El lote completo de liberación por refcount queda en **2,1–5,8 ms** (ligero 8 MB) y **3,9–5,8 ms** (pesado 64 MB), muy por debajo del límite de 50 ms. Ver `test_m62_liberacion.gd`
- [ ] RN2: cero hitching perceptible por refcount en liberaciones masivas [C]
- [ ] RN3: memoria estable: sesión de 30 min con drift < 5% sobre baseline [C]
- [x] RN4: topes configurables desde `budgets.tres` sin recompilar [S]
- [x] RN5: implementación 100% Godot 4.x + GDScript, sin C# ni plugins externos [S]
- [x] RN6: ninguna operación de memoria bloquea el hilo principal [M] — **iter. 4 (Log 1112): MEDIDO** para el caso de liberación por refcount: el pico de UNA operación es 0,279–0,492 ms (ligero) y 0,414–0,448 ms (pesado), por debajo de un frame a 60 FPS (16,67 ms). Alcance: mide liberación de `RefCounted`, no toda operación de memoria del motor
- [x] RN9: la gestión de memoria es transparente para la partida (determinismo intacto) [S] — **iter. 5 (Log 1187): MEDIDO.** Bloque G de `test_memoria_m62_iter5.gd`: dos monitores con la MISMA entrada dan el mismo nivel (`nivel_para()` en 8 valores) y el **mismo orden** de descarga con los mismos MB liberados. La decisión es función pura de la entrada

## G. Diseño de arquitectura

- [x] MemoryMonitor autoload registrado en ServiceRegistry [S]
- [x] BudgetRegistry: presupuestos, reportar_consumo, verificar (sistemas sobre tope) [M]
- [x] GlobalPool: servicio puro, desacoplado del gameplay [M]
- [x] UnloadPolicy: orden distancia > edad > peso, descarga escalonada (max 3/frame) [C]
- [x] Separación de responsabilidades: los managers reportan, no tocan memoria ajena [S]
- [x] Flujo muestreo → semáforo → política de acción (warning/crítico/emergencia) [M] — Log 1094: `muestrear_ahora()` → `nivel_para()` → semáforo + `_enforcement()`, con una sola fuente de verdad; probado en los bloques B y C
- [x] Flujo de arranque: precalentar pools primero, después cargar mundo (M63) [M]
- [x] Flujo de cambio de escena: drenar pools, cancelar timers/tweens, descargar recursos [C]
- [x] Flujo de salida de chunks: LRU → anunciar handshake → liberar escalonado → pool [C]
- [x] Degradación graceful al 90%: LOD de lejanos, pools mínimos, evicción de atlas [M]
- [ ] Descarga dura al 95%: atlas fuera de pantalla y bancos de biomas viajeros [M]
- [x] Toda decisión de descarga queda registrada en log (M103) para análisis [S] — Log 1094: `_log_m62()` escribe en `/root/GameLogger` (categoría SYSTEM) y `resumen_ultimo_lote()` describe el lote

## H. Integración con M08 (mundo voxel)

- [ ] Buffers de VoxelTools por chunk se liberan al descargar (sin acumulación) [C]
- [x] Meshes de chunks van al pool `mesh_chunk` y se reutilizan sin nuevos allocs [C]
- [ ] Colliders estáticos de chunks descargados se liberan junto con la mesh [M]
- [ ] Sin duplicación de meshes entre M63 (streaming) y el 62 (descarga) [M]
- [ ] Generación de mallas en hilos (M08): resultados por cola sin copias extra [C]
- [ ] Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM [M]
- [ ] Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos [M]
- [x] Teleport extremo ×10 y vuelta al spawn deja la memoria en el mismo nivel (test) [C] — **iter. 7 (Log 1325, T-D9): MEDIDO** por la misma suite: 10 ciclos con `marcar_punto_de_interes("teleport_extremo")`, la cola queda VACÍA tras cada descarga y el conteo de objetos NO crece. **Alcance headless:** el "nivel de memoria" medido es el conteo de objetos + la retención de recursos; el RSS del mundo real (M08/M63) no es medible acá.
- [x] El pool de chunks se ajusta al presupuesto voxel declarado (800 MB Alta) [M]

## I. Integración con M41-M44 (audio)

- [ ] Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región [M]
- [ ] Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa [C]
- [x] Voces del pool M43 con tope duro: si se llena, se corta la voz más antigua (nunca crece) [S]
- [ ] Streams `.ogg` liberados de caché cuando ningún reproductor los usa [M]
- [ ] Los buses (M91) no retienen streams detenidos [S]
- [ ] Cambio de bioma: descarga del banco anterior diferida 1 frame (no corta transiciones) [M]
- [ ] Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio [C]

## J. Integración con M61 y M63

- [ ] Leer los presupuestos definitivos de M61 antes de fijar los topes duros del 62 [S]
- [x] Los topes de RAM del 62 respetan los frame budgets del 61 (deltas < 50 ms) [M]
- [x] La cola de streaming (M63) informa cargas/descargas al MemoryMonitor [M]
- [x] LRU compartido: el 63 decide qué cargar, el 62 decide qué liberar (handshake) [C] — **iter. 5 (Log 1187).** `MemoryMonitor.avisar_carga_iniciada()/avisar_carga_terminada()/esta_en_carga()`; el filtro `_puede_descargar()` se pasa a `UnloadPolicy.ejecutar_descarga(..., filtro)`. Bloque A de `test_memoria_m62_iter5.gd`
- [ ] Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueño) [M]
- [x] La pantalla de carga (M63) precarga pools sin duplicarlos al terminar [M]
- [x] El 62 nunca descarga un recurso que esté en la cola de carga del 63 (evento cancel) [C] — **iter. 5 (Log 1187).** El candidato vetado por el filtro **no sale de la cola** y se cuenta en `descartes_por_carga()`; probado tanto por la vía directa (bloque A) como por el enforcement nivel 3 (bloque B)
- [ ] Teleport (M69/M28): drift-check obligatorio tras cada viaje largo [M]
- [x] NO tocar la carpeta 61 (en curso por otro agente): solo consumir sus entregables [S] — **iter. 5 (Log 1187): cumplido y verificado.** `git status` de la iter. muestra cambios SOLO en `scripts/rendimiento/memoria/` (nunca en `scripts/rendimiento/` fuera de `memoria/`). M61 no se tocó; su presupuesto definitivo sigue pendiente (ver L154)

## K. Edge cases

- [x] Textura gigante (4K simple sin mips): detector la identifica y degrada calidad automáticamente [M] — Log 1094: `TextureMemory.requiere_degradacion()` + `degradar()` (resize + mips); probado
- [x] Atlas lleno: política de evicción por orden de uso con log del evento [C] — **iter. 5 (Log 1187).** `MemoryMonitor.evictar_atlas(entradas, tope)`: evicta por uso más ANTIGUO, respeta el tope y **registra el evento** vía `_log_m62()`. Bloque F de `test_memoria_m62_iter5.gd`
- [x] Chunk sin descargar tras cambio rápido de región: el monitor lo detecta y fuerza liberación [M] — **iter. 5 (Log 1187).** `avisar_cambio_region(region)`: si hay candidatos pendientes, **fuerza** la liberación (`liberaciones_forzadas()`); avisar la MISMA región no cuenta como cambio. Bloque D de `test_memoria_m62_iter5.gd`
- [x] Chunk liberado mientras el jugador lo edita (M08): regeneración segura sin doble free [C]
- [x] Audio acumulado por bug: cientos de voces creadas: tope duro del pool + log inmediato [M]
- [x] Banco de audio pedido mientras se descarga: reproducción diferida o silenciada graceful [M] — **iter. 5 (Log 1187).** `iniciar_descarga_audio()` / `pedir_banco_audio(banco)`: si hay descarga en curso, el banco se **difiere** (`bancos_audio_diferidos()`) y se reproduce al terminar; otro banco no se ve afectado. Bloque E de `test_memoria_m62_iter5.gd`
- [x] Escena cambiada dos veces antes de terminar la transición: cola evita doble descarga [C] — **iter. 5 (Log 1187).** `iniciar_transicion_escena()` devuelve `false` y **encola** el 2.º cambio (`doble_descarga_evitada()`); `terminar_transicion_escena()` encadena el encolado. Bloque C de `test_memoria_m62_iter5.gd`
- [x] Cambio de escena con streaming activo: cancelación limpia sin recursos colgados [C] — **iter. 5 (Log 1187).** `cancelar_transicion_escena()` reporta los candidatos pendientes, **drena** la cola (nada colgado), corta la transición y cuenta la cancelación. Bloque C de `test_memoria_m62_iter5.gd`
- [x] Cercanía de OOM del sistema: degradación máxima (LOD bajo, pools mínimos) sin crash [C]
- [ ] Preset Baja en isla pequeña (M27): carga priorizada y descarga agresiva de viajeros [M]
- [x] Partículas infinitas por bug: límite de vida y devolución al pool garantizadas [S]
- [x] Tween sin fin en UI: auto-detención en `_exit_tree` [S] — Log 1094: `LeakGuard.registrar_tween()` + limpieza automática en `_exit_tree()`
- [x] Nieve/niebla (M32) que crea nodos por frame: detector de nodos por frame con alerta [M] — Log 1094: `DetectorNodosPorFrame` mide la DERIVADA (nodos/frame) y `alerta()` describe el crecimiento
- [x] Minimapa (M11) regenerando textura cada frame: reutilización de imagen destino sin alloc [C]
- [ ] Memoria al límite durante tormenta máxima: degrada con aviso y el juego sigue jugable [M]

## L. Optimización y mediciones

- [ ] Baseline menú principal: objetivo < 600 MB [S]
- [ ] Baseline spawn de Aurora: objetivo < 1.600 MB [S]
- [ ] Baseline horizonte terrestre oteado: objetivo < 2.200 MB [S]
- [ ] Baseline subterráneo del templo (M26): objetivo < 2.000 MB [S]
- [ ] Baseline tormenta máxima (M32) + banco de audio completo: ≤ 2.500 MB (Alta) [S]
- [x] Profiling: identificar top de allocs por frame en hot paths [M]
- [x] Cero allocs deliberados en `_process`/`_physics_process` del gameplay [C] — Log 1094: el muestreo por frame con `_muestras.append()`+`pop_front` (un alloc deliberado por frame, justo lo prohibido) se reemplazó por muestreo por TIEMPO y ventana circular `PackedFloat32Array`
- [x] Uso de arrays tipados y `Packed*Array` donde el tamaño es fijo [M] — Log 1094: ventana de 600 muestras en `PackedFloat32Array` pre-dimensionado (0 allocs por frame)
- [x] Evitar `duplicate()`, `instantiate()` y `load()` síncrono en gameplay [M] — **iter. 4 (Log 1112): MEDIDO y con gate.** Auditor estático nuevo `scripts/auditar_arquitectura_m62.py` (reglas B1/B2/B3): **0 hallazgos** en 800 archivos `.gd` y **79 callbacks por frame** (`_process`, `_physics_process`, `_input`, `_unhandled_input`, `_unhandled_key_input`, `_integrate_forces`). El auditor lleva **guarda de ceguera** (si resuelve 0 autoloads, o el grafo queda con 0 aristas, o encuentra 0 callbacks por frame, sale 3 en vez de 0) y `--selftest` probado EN ROJO: su primera corrida cazó 4 defectos del propio auditor (entre ellos que `x.instantiate()` y `d.duplicate()` eran indetectables por un lookbehind mal puesto). Gate `architecture-guard` en `quality.yml`
- [x] Pico de liberación por refcount < 3 ms al descargar una región completa [C] — **iter. 4 (Log 1112): MEDIDO.** `test_m62_liberacion.gd` (15 checks, 0 fallos, x5 idénticas): pico por objeto **0,279–0,492 ms** en la variante ligera (2048 × 4 KB) y **0,414–0,448 ms** en la pesada (256 × 256 KB), contra el límite declarado de 3 ms. Medición con rondas intercaladas y mínimo por variante (trampa 78)

## M. Documentación

- [x] Documentar la arquitectura en plan-actual/03-Diseno.md [S] — 03-Diseno.md §2-§6 es la fuente contra la que se implementó iter. 3 (tabla §2, umbrales §3, familias §4, escalonamiento §5.4, baseline §6.4)
- [x] Documentar la API pública con XML docs GDScript (`##`) en todos los scripts [S]
- [x] Registrar los edge cases y sus soluciones en plan-actual/04-Codigo.md [S] — Log 1094: §5 de las Notas del Agente (iter. 3) en 04-Codigo.md
- [x] Tabla de presupuestos documentada con su justificación por sistema [S]
- [x] Notas del Agente firmadas con modelo, plataforma y fecha en 04-Codigo.md [S] — Log 1094: sección «Iteración 3» firmada DeepSeek-V4.1-Flash / WorkBuddy / 2026-09-19

## N. Testings

- [x] Test BudgetRegistry: carga, verificación, topes, total_consumo (test_memoria_m62.gd) [M]
- [x] Test GlobalPool: obtener/devolver/precalentar/límite/liberar_todo (test_memoria_m62.gd) [M]
- [x] Test UnloadPolicy: LRU/distancia, descarga escalonada (test_memoria_m62.gd) [C]
- [ ] Test Play Mode: drift-check de 30 min sin teleport con drift ≤ 5% [C]
- [ ] Test Play Mode: teleport extremo ×10 con memoria estable y sin picos [C]
- [ ] Test Play Mode: cambio de bioma de audio sin crecimiento de memoria [M]
- [ ] Test Play Mode: excavar y regenerar 500 bloques sin leaks de buffers voxel [C]
- [ ] Test Play Mode: máximo de chunks cargados sin superar el presupuesto voxel [M]
- [ ] Test Play Mode: textura gigante forzada degrada sin crash [M]
- [x] Test de semáforos: forzar 90% y verificar descargas automáticas y registro en log [C] — Log 1094: bloques B y C de `test_memoria_m62_iter3.gd` (1599/1600/1799/1800/1899/1900/2000 MB) + bloque C de `test_enforcement_m62.gd`
- [x] Test de nodos huérfanos: conteo de orphans en reposo con valor estable [M] — **iter. 4 (Log 1112): MEDIDO.** Bloque D de `test_m62_liberacion.gd`: base=0, 5 muestras consecutivas sin deriva, crear 128 nodos sin padre los cuenta (0 → 128) y liberarlos devuelve el conteo a 0 (sin leak). Lee `Performance.OBJECT_ORPHAN_NODE_COUNT`
- [ ] Test en preset Baja con 4 GB de RAM: sesión completa sin OOM y jugable [C]

## Notas del Agente (iter. 2 GlobalPool — Log 604, glm-5.3-flash/Kilo Code)

### Lo que hice
- **API única completa con estados**: obtener() ahora ACTIVA el nodo (proceso on + visible); devolver() lo ESTACIONA (proceso off + invisible) — round-trip testeado.
- **RN Auditoría de señales**: devolver() desconecta las conexiones ENTRANTES del nodo (get_incoming_connections) — un ítem estacionado no retiene callbacks a objetos liberados antes. Testeado.
- **Fallback honesto**: pool lleno → queue_free() del objeto + return false (sin crecer sin tope). Testeado.
- **drenar_familia()**: drenaje parcial por familia para cambio de escena (además de liberar_todo existente). Testeado.
- Test `test_pool_iter2.gd` (14 checks) — **0 fallos**; regresión test_memoria_m62 26/0.

### Hallazgo de tests
- liberar_todo() al final de un test puede devolver >3 si los pools de checks anteriores siguen poblados — el check debe ser >= (los pools viven en la MISMA instancia durante todo el SceneTree).

### Pendientes con dueño
- Contadores propios por sistema voxel/audio/texturas (requiere instrumentar M08/M43/M47)
- Test de leaks teleport ×10 (requiere mundo real M08/M09)
- Presupuestos por preset M90 (800 MB voxel / 200 MB pool en Alta)

## Notas del Agente (iter. 4 — Log 1112, DeepSeek-V4.1-Flash / WorkBuddy)

### Lo que hice
- **Auditor estático nuevo** `scripts/auditar_arquitectura_m62.py` (fuera de `res://`: es herramienta de
  repo, junto a `verificar_binarios.py`). Dos grupos de reglas que hasta ahora no tenían ninguna puerta:
  - **Grupo A — grafo de servicios** (111 autoloads, 213 referencias explícitas):
    A1 componentes fuertemente conexas (Tarjan) · A2 referencias a un autoload declarado después,
    alcanzables desde `_ready()` · A3 el mismo script registrado como dos autoloads.
  - **Grupo B — carga síncrona** en callbacks por frame (`load()`, `instantiate()`, `duplicate()`).
- **Suite nueva** `test_m62_liberacion.gd` (15 checks): presupuesto de liberación por refcount
  (L191 + RN2 + RN6) y nodos huérfanos en reposo.
- **2 gates de CI nuevos**: `test_m62_liberacion.gd` dentro de `test-suite`, y el job
  `architecture-guard` (con selftest + auditor) registrado en `summary`.

### Lo que la medición me corrigió (3 veces)
1. **A2 no es un bug de runtime.** La hipótesis era «`get_node_or_null("/root/X")` desde `_ready()`
   devuelve null si X se declara después → rama saltada en silencio». **Medido con un banco de
   pruebas propio (2 autoloads, Godot 4.7.2 headless): falso.** En `_ready()` Godot ya instanció
   TODOS los autoloads, así que la búsqueda acierta. Lo único que falla es `_init()`, y falla con
   un `ERROR` fuerte y **para cualquier destino**, no por el orden. Se dejó escrito en el auditor y
   en BUG-069 para que nadie «arregle» un crash que no existe.
2. **Mi propio auditor tenía 4 defectos.** El `--selftest` los cazó en rojo: `x.instantiate()` y
   `d.duplicate()` eran **indetectables** (lookbehind que prohibía el punto delante, y esas dos son
   siempre llamadas a método); y dos aserciones del selftest estaban mal escritas (esperaban que
   `_ready` fuera un callback por frame, y ponían `preload` y `instantiate` en la misma línea).
3. **Una aserción de la suite era una suposición.** «2048 objetos chicos cuestan más en total que
   256 grandes» → medido: **al revés** (2346 µs vs 4270 µs). Y comparar los **picos** por objeto
   resultó inestable (corrida 3: 492 µs > 448 µs). La comparación estable es el **total**.

### Hallazgos escalados
- **BUG-068** — `hardware` y `HardwareManager` son el **mismo script** en dos autoloads → 2
  instancias (medido: `instance_id` distintos, `==` falso), 2 parseos del JSON y 2 registros en
  ServiceRegistry. Los dos nombres están **sin usar** (0 referencias). Fix de 1 línea.
- **BUG-069** — 2 componentes cíclicas + 9 referencias fuera de orden. Deuda arquitectónica, **sin
  fallo de runtime medido**.

### Trampas nuevas que deja esta iteración
- **Un auditor ciego y un auditor limpio dicen lo mismo.** El detector de ciclos reportó «0 ciclos»
  DOS veces siendo ciego: la primera porque resolvía mal las rutas de los autoloads (los 111
  quedaban «sin archivo») y la segunda porque no encontraba callbacks por frame. De ahí la guarda
  de ceguera con exit 3, y el fixture explícito de «grafo con 0 aristas».
- **Un detector laxo inventa ciclos.** Contar la mera aparición del identificador dio 13 ciclos, uno
  de ellos `HardwareManager -> hardware`: y resulta que **ambos nombres apuntan al mismo archivo**.
  Solo cuentan las referencias explícitas (`get_node`/`get_node_or_null("/root/X")`) y hay que
  excluir las aristas entre autoloads del mismo archivo.
- **El selftest hay que probarlo antes de confiar en él.** El de este auditor pasó de 4 fallos a 0
  corrigiendo el auditor Y las aserciones; sin esa primera corrida en rojo, el gate habría entrado a
  CI sin detectar `instantiate()` ni `duplicate()`.

## Notas del Agente (iter. 6 — Log 1196, DeepSeek-V4.1-Flash / WorkBuddy)

### Lo que hice
- **Item L98 CERRADO y MEDIDO.** Suite nueva `test_m62_pureza_save.gd` (58 checks, 0 fallos, EXIT 0):
  recorre de forma RECURSIVA el payload de los 39 proveedores `ISaveProvider` registrados como
  autoload (y el payload COMPLETO de `SaveManager.snapshot.collect()`) y exige 0 referencias a
  Objetos/Nodos. Medicion: 39 proveedores, 46 claves de payload, 0 objetos.
- **Escaner probado EN ROJO** (bloque D, in-suite): un `SaveSnapshot` aislado con un proveedor que
  devuelve `{"nodo": Node.new()}` -> el escaner detecta 1 objeto y nombra la ruta exacta; un
  proveedor puro -> 0. Ademas sonda EXTERNA: registrar un proveedor impuro en el SaveManager REAL
  -> 3 fallos, EXIT 1 (control sin mutar: EXIT 0).
- **Complemento estatico: regla C** en `scripts/auditar_arquitectura_m62.py` — `get_save_data()` no
  debe devolver `self` desnudo. Cubre los 56 scripts con `get_save_data()` (mas que los 39 autoload:
  tambien los que NO se registran). Selftest del auditor EXTENDIDO (fixture `save.gd` que devuelve
  `self` + control negativo `self.metodo()` + fixture de ceguera del grupo C): 0 fallos, EXIT 0.
- **Items §A (L30-L32) cerrados** con evidencia: `01-Requerimientos.md` §ID del Modulo (L9), §1
  Problema (L12-14) y §2 Objetivo (L16-18) ya contenian problema, dependencias y objetivo.

### Lo que la medicion me enseno
- **39 != 56.** El runtime solo ve los proveedores registrados como autoload; el analisis estatico ve
  los 56 scripts que definen `get_save_data()`. Ninguna vista por si sola cubre el item: van las DOS.
- **Un "0 objetos" necesita su sonda roja.** Sin el bloque D, un escaner roto (que no recorriera nada)
  daria el mismo "0 objetos" que un payload limpio (trampa 61: un detector que da 100% esta roto).

### Hallazgo AJENO (no tocado)
- El auditor reporta `A2|SubtitleManager->DataStore` como hallazgo NUEVO. **NO es mio**:
  `subtitle_manager.gd` esta SIN TRACKEAR y `SubtitleManager` solo existe en el `project.godot` del
  WORKTREE (M91/subtitulos). En HEAD no existe -> el gate commiteado queda verde. El dueno de M91
  debe decidir (allowlist A2 o reordenar). **No toque `PERMITIDOS`.**

### NO sella §21.8
- El autor no puede auto-verificarse (trampa 46/119). La re-verificacion de M62 queda para un NO-autor.

## QA cruzado §21.8 — Hy3 (Log 1223, 2026-10-03)

Re-verificación del delta iter.5+6 (el autor no puede auto-verificarse, trampa 46/119). Verificador hy3/WorkBuddy ≠ autor (DeepSeek-V4.1-Flash) ⇒ legítimo §21.8.

- **Binario real (godot 4.7.2):** 7 suites M62 VIVAS y AFIRMATIVAS = **365 checks / 0 fallos / EXIT 0**:
  - `test_memoria_m62.gd` 27/0, `test_memoria_m62_iter3.gd` 133/0, `test_memoria_m62_iter5.gd` 60/0, `test_pool_iter2.gd` 25/0, `test_m62_pureza_save.gd` 58/0, `test_enforcement_m62.gd` 47/0, `test_m62_liberacion.gd` 15/0.
- **Anti-falso-verde:** las 7 suites llevan guardián 3 capas (piso MEDIDO + nombra bloques no ejecutados); **reproducido en ROJO por inyección** (1 `_check` false → EXIT 1, 1 fallo). Una suite muerta ya no da '0 fallos'.
- **DoD:** checklist 111[x]/39[ ]/0[?]; 0[?] sin documentar. Pureza de save AFIRMA LoadResult.OK en el camino real (lección BUG-087/088).
- **Veredicto:** ✅ **Verificado por Hy3/WorkBuddy (Log 1223, §21.8).** Confirma el sello iter.4 (Log 856/1128) y cierra la QA pendiente del delta.
- **Hallazgo AJENO (no tocado):** `A2|SubtitleManager->DataStore` (dueño M91).
- Detalle: `Logs/1223-m62-qa21.8-iter56_2026-10-03.md`.

## Delta iter. 7 — T-D9 (Log 1325, 2026-10-05)

> El autor **NO sella §21.8** (trampa 46/119): este bloque es el **reporte del delta**, no una
> verificación. La re-verificación del delta queda para un NO-autor.

- **Suite nueva:** `test_m62_leaks_teleport.gd` — **21 checks, 0 fallos, EXIT 0, ×3 idénticas.**
- **Items que pasan a `[x]`:** **L105** (test de leaks con teleport ×10 + conteo de objetos antes/después)
  y **L143** (teleport extremo ×10 deja la memoria en el mismo nivel).
- **Medición:** 10 ciclos × 24 chunks = 240 `Resource`; **0 retenidos** tras `ejecutar_descarga()`
  (verificado con `WeakRef`); `objetos_vivos` base=3618 fin=3618 (**delta 0**).
- **Guardián EN ROJO (2 inyecciones):** omitir los bloques C/D → el resumen **nombra** los bloques y baja
  del piso (21→15), EXIT 1; error de runtime en B → el resumen diferido **igual corre**, nombra B, EXIT 1.
- **Regresión:** las 7 suites previas siguen verdes (**366 checks**) + la nueva = **387 checks / 0 fallos**.
  `auditar_arquitectura_m62.py`: **0 hallazgos nuevos**. `generar_budgets.gd -- --check`: 20/0.
- **DoD medido tras el delta:** checklist **113[x] / 37[ ] / 0[?]** (150 items).
- **Alcance headless:** mide la contratación de M62 (que su cola no retenga recursos). El teleport con
  mundo real (M08/M63) sigue siendo Play Mode — **L213 no se cierra con esto**.
- **PENDIENTE:** cablear la suite a `quality.yml` (no lo toqué — es de s2/director).
