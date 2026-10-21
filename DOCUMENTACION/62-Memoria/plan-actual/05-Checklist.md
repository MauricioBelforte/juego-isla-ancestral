**Modelo:** DeepSeek-V4.1-Flash — DS-V4.1-Flash-Opencode (último modificador)
**Plataforma:** OpenCode
**Fecha:** 2026-10-18 (Tanda 60 — L132 por medición; Log 1998)

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
- [x] Texturas de región se liberan al salir de la misma (con M63 y M09) [M] — **Tanda 59 (2026-10-18, DS-Opencode, Log 1997): MEDIDO.** Suite `test_m62_texturas_region.gd` (**33 checks, 0 fallos**, ×3 idénticas + guardián de 3 capas probado EN ROJO con 2 inyecciones; out/tanda59): con los autoloads REALES (StreamManager + MemoryMonitor) — registro M63→M62 → veto por carga → `avisar_cambio_region` fuerza la liberación → cola M62 drenada → **0/3 sobreviven (WeakRef)** + `objetos_vivos` delta 0 + atlas LRU evictado con señal. Prelación: sonda `probe_unreference.gd` (out/tanda59/probe1.log). **Alcance:** mide el mecanismo extremo a extremo; el llamador de gameplay (M09/M27 avisando la salida) sigue siendo deuda de cableado de esos dueños (auditoría arriba).
- [x] Los datos de partida (M29) no retienen referencias a nodos del mundo [M] — **iter. 6 (Log 1196): MEDIDO.** `test_m62_pureza_save.gd` (58 checks, 0 fallos): los 39 proveedores registrados y el payload completo de `collect()` dan 0 Objects; escaner recursivo probado EN ROJO (bloque D). Complemento estatico: regla C del auditor (56 scripts con `get_save_data`, 0 hallazgos).
- [x] Partículas y audio se detienen y devuelven al pool al desactivar la fuente [M]
- [x] Los callables con bound parameters se desconectan en `_exit_tree` (anti-leak de lambdas) [M] — Log 1094: `LeakGuard.conectar()` guarda el Callable EXACTO (incluido el `.bind()`), así el disconnect funciona; probado
- [ ] Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares) [C] — **iter. 4 (Log 1112): SIGUE ABIERTO, y ahora hay evidencia de por qué.** El auditor nuevo mide **2 componentes fuertemente conexas** (7 nodos: `CollectionRegistry, Fishing, GameTime, Inventario, SaveManager, TimeCalendar, Weather`; y 2 nodos: `ThemeService, UIManager`) más 9 referencias a un autoload declarado después. Escalado como **BUG-069**; el gate los tiene en lista de permitidos para que ningún ciclo NUEVO pase
- [ ] Sesión de referencia: 30 min de juego sin drift > 5% sobre la línea base [C]
- [x] Test de leaks con teleport ×10 y conteo de objetos antes/después (debe ser igual) [C] — **iter. 7 (Log 1325, T-D9): MEDIDO.** `test_m62_leaks_teleport.gd` (21 checks, 0 fallos, ×3 idénticas): 10 ciclos de teleport dejan 240 `Resource` como candidatos a descarga; tras `ejecutar_descarga()` **0 retenidos** (verificado con `WeakRef`) y `objetos_vivos` **delta 0** (base 3618 = fin 3618). Guardián de 3 capas probado EN ROJO con 2 inyecciones. **Alcance:** mide la contratación de M62 (que su cola de descarga no retenga recursos), no el teleport con mundo real — eso sigue siendo Play Mode (L213).

## F. RN — Requisitos no funcionales

- [x] RN1: presupuesto de RAM objetivo ≤ 2.5 GB en PCs de gama media (preset Alta) [M] — iter. 7 (2026-10-17, Tanda 6, DS-Opencode): suite test_memoria_m62_iter3.gd: "set_preset('alta') -> total 2500" MB (≤ 2.5 GB); rc=0, 133 checks 0 fallos (out/m62-tanda6).
- [x] RN1: preset Baja ≤ 1.5 GB para gama baja con 4 GB de RAM [M] — iter. 7 (2026-10-17, Tanda 6, DS-Opencode): suite test_memoria_m62_iter3.gd: "set_preset('baja') -> total 1500" MB (≤ 1.5 GB); rc=0, 133 checks 0 fallos (out/m62-tanda6).
- [x] RN2: sin picos de frame: deltas < 50 ms durante descargas o liberaciones [M] — **iter. 4 (Log 1112): MEDIDO.** El lote completo de liberación por refcount queda en **2,1–5,8 ms** (ligero 8 MB) y **3,9–5,8 ms** (pesado 64 MB), muy por debajo del límite de 50 ms. Ver `test_m62_liberacion.gd`
- [x] RN2: cero hitching perceptible por refcount en liberaciones masivas [C] — iter. 7 (2026-10-17, Tanda 6, DS-Opencode): suite test_m62_liberacion.gd: "RN2: el lote completo no produce un delta >= 50.00 ms (ligera/pesada)" + "RN6: ninguna liberacion individual bloquea el hilo principal mas de un frame" + pico < 3.50 ms; rc=0, 15 checks 0 fallos.
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
- [x] Descarga dura al 95%: atlas fuera de pantalla y bancos de biomas viajeros [M] — **Tanda 60 (2026-10-18, DS-Opencode, Log 1998): MEDIDO.** Suite `test_m62_duro95.gd` (**39 checks, 0 fallos**, ×4 idénticas + guardián de 3 capas EN ROJO; out/tanda60) sobre el autoload REAL `MemoryMonitor`: umbrales 80/90/95 **derivados del presupuesto vivo** (topes del preset + registros runtime: hoy 2000+32 de `ia_npc` → 2032 MB), nivel 1 no ejecuta → nivel 2 drena el tope del preset media (12) e idempotente → nivel 3 **re-aplica sin excepción**; **bancos viajeros**: orden distancia desc [60,50,40,…], el vetado por el handshake M63 sigue en cola y se drena al terminar la carga (168+100 MB); **atlas**: `evictar_atlas` LRU — fuera de pantalla primero (nunca por tamaño: 90 MB en pantalla intacto), señal `atlas` 60 MB, `hasta_mb=0` no-op, `max_entradas` manda, entradas sin mutar; **audio viajero**: pedido en descarga = `diferido`, tras terminar = `reproducir`. **Alcance:** el mecanismo del 62 queda pinneado; los FEEDS de producción siguen como deuda de sus dueños (tabla de atlas M09/M63; registro de bancos al viajar M42 — ítem 112).
- [x] Toda decisión de descarga queda registrada en log (M103) para análisis [S] — Log 1094: `_log_m62()` escribe en `/root/GameLogger` (categoría SYSTEM) y `resumen_ultimo_lote()` describe el lote

## H. Integración con M08 (mundo voxel)

- [x] Buffers de VoxelTools por chunk se liberan al descargar (sin acumulación) [C]
- [x] Meshes de chunks van al pool `mesh_chunk` y se reutilizan sin nuevos allocs [C]
- [x] Colliders estáticos de chunks descargados se liberan junto con la mesh [M]
- [x] Sin duplicación de meshes entre M63 (streaming) y el 62 (descarga) [M]
- [x] Generación de mallas en hilos (M08): resultados por cola sin copias extra [C]
- [x] Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM [M]
- [x] Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos [M]
- [x] Teleport extremo ×10 y vuelta al spawn deja la memoria en el mismo nivel (test) [C] — **iter. 7 (Log 1325, T-D9): MEDIDO** por la misma suite: 10 ciclos con `marcar_punto_de_interes("teleport_extremo")`, la cola queda VACÍA tras cada descarga y el conteo de objetos NO crece. **Alcance headless:** el "nivel de memoria" medido es el conteo de objetos + la retención de recursos; el RSS del mundo real (M08/M63) no es medible acá.
- [x] El pool de chunks se ajusta al presupuesto voxel declarado (800 MB Alta) [M]

## I. Integración con M41-M44 (audio)

- [x] Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región [M]
- [x] Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa [C]
- [x] Voces del pool M43 con tope duro: si se llena, se corta la voz más antigua (nunca crece) [S]
- [x] Streams `.ogg` liberados de caché cuando ningún reproductor los usa [M]
- [x] Los buses (M91) no retienen streams detenidos [S]
- [x] Cambio de bioma: descarga del banco anterior diferida 1 frame (no corta transiciones) [M]
- [x] Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio [C] — [x] 2026-10-20 (Tanda 72, DS-Opencode): MEDIDO con `sesion_m62_clima_30min.gd` extendido con banco sintético AudioStreamWAV de 3 MB — 30 min de reloj de pared, 359 muestras, 10 cambios efectivos, 4 climas, 10 bancos creados, 1 vivo (el ACTUAL), PENDIENTE=null, control positivo +3 MB, drift +0.1%, buses 7→7, reproductores 9→9, 0 huérfanos, 0 teleport, 0 SCRIPT ERROR (1 ERROR de engine AnimationService conocido), EXIT 0; sonda roja `M62_AUDIO_FUGA=1` retiene 7 bancos (+21 MB) y falla el gate; stand-in declarado: no mide assets reales ni M42 (0 llamadores, deuda de M42); out/tanda72; Log 2039.

## J. Integración con M61 y M63

- [x] Leer los presupuestos definitivos de M61 antes de fijar los topes duros del 62 [S] — [x] 2026-10-20 (Tanda 73, DS-Opencode): LEÍDO `data/performance/budgets.json` v2 (16,7 ms total, tolerancia 10%, 7 categorías 16,5 ms; límites 500 partículas / 400 draw calls / 1000 objetos; 12 normas: 60/30 FPS, 1080p, presets 100/150/220 m, LOD 3, 20 NPCs) y contrastado con `data/rendimiento/budgets.json` v2 (Baja/Media/Alta 1500/2000/2500 MB; 8 sistemas; descarga 8/12/16 por frame). Gates: `validate_budget.gd` 0 fallos + `generar_budgets.gd -- --check` 20 checks/0 fallos (`out/tanda73`). Sin conflicto; deuda M61 VRAM/instancias/draw calls declarada; sin cambio de código. Log 2041.
- [x] Los topes de RAM del 62 respetan los frame budgets del 61 (deltas < 50 ms) [M]
- [x] La cola de streaming (M63) informa cargas/descargas al MemoryMonitor [M]
- [x] LRU compartido: el 63 decide qué cargar, el 62 decide qué liberar (handshake) [C] — **iter. 5 (Log 1187).** `MemoryMonitor.avisar_carga_iniciada()/avisar_carga_terminada()/esta_en_carga()`; el filtro `_puede_descargar()` se pasa a `UnloadPolicy.ejecutar_descarga(..., filtro)`. Bloque A de `test_memoria_m62_iter5.gd`
- [x] Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueño) [M] — [x] 2026-10-20 (Tanda 74, DS-Opencode): `StreamManager.encolar()` RECHAZA la 2.ª carga de una ruta ya en vuelo ANTES de `load_threaded_request` (guard central; `_encolar_precarga` ya lo hacía). Suite nueva `test_m62_doble_carga_m63.gd` **20 checks**: 1.ª carga = 1 ruta/1 op; 2.ª rechazada (la cola no crece); 1 callback; ruta cerrada; `ResourceLoader` entrega la MISMA instancia; LeakGuard 0 duplicados; control positivo `CACHE_MODE_IGNORE`. **ROJO 4 fallos → VERDE 0/20**; regresión M63 7/51/42 + M62 hilos 33, **0 fallos**. Sin cambio de M62; cambio acotado a M63 `stream_manager.gd`. Log 2042.
- [x] La pantalla de carga (M63) precarga pools sin duplicarlos al terminar [M]
- [x] El 62 nunca descarga un recurso que esté en la cola de carga del 63 (evento cancel) [C] — **iter. 5 (Log 1187).** El candidato vetado por el filtro **no sale de la cola** y se cuenta en `descartes_por_carga()`; probado tanto por la vía directa (bloque A) como por el enforcement nivel 3 (bloque B)
- [x] Teleport (M69/M28): drift-check obligatorio tras cada viaje largo [M] — [x] 2026-10-20 (Tanda 75, DS-Opencode): **flip de herencia verificado**, no reimplementado. El cableado ya existía: `TravelService._atracar()` llama `_verificar_drift_post_viaje(ruta)` DESPUÉS de aterrizar y ANTES de `travel_arrived`; umbral `UMBRAL_VIAJE_LARGO_S=45.0` derivado de las 2 rutas más largas de `rutas.json` (20/30/45/60). Autor del código: DeepSeek-V4.1-Flash (Log 2021); punto de llamada en M28. Gate `test_m62_drift_post_viaje.gd`: **12 checks, 0 fallos, EXIT 0** (A corto no chequea; B largo OK; C drift forzado 100% → 1 fallo; D sin monitor → NO MEDIBLE, nunca verde; señal de llegada intacta). Regresión `test_viajes.gd`: **0 fallos, EXIT 0**. Evidencia `out/tanda75/`; Log 2044.
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
- [x] Preset Baja en isla pequeña (M27): carga priorizada y descarga agresiva de viajeros [M] — [x] 2026-10-20 (Tanda 76, DS-Opencode): **flip de herencia verificado**, no reimplementado. Autor: DeepSeek-V4.1-Flash (Log 2021). `IslandTravelGuard` ya tiene `TOPE_ISLAS_POR_PRESET` (baja=1 / media=alta=2), `max_islas_en_memoria()`, `debe_precargar()` limitado por preset y `descarga_agresiva_viajeros()` (descarga TODA viajera cacheada que no sea actual ni principal, de la más vieja a la más nueva, sin tocar `descubierta`/`visitada`). Gate `test_m62_preset_baja_m27.gd`: **13 checks, 0 fallos, EXIT 0** (tope baja/media/desconocido; no descarga actual ni principal; progreso preservado; no queda viajera; prioridad por cercanía; presupuesto explícito 2). Regresiones M27: `test_islas_m27.gd` **171/0** y `test_islas_m27_iter2.gd` **238/0**, EXIT 0. Evidencia `out/tanda76/`; Log 2045. **DEUDA DECLARADA (M27):** no hay llamador de producción que instancie `IslandTravelGuard`, inyecte `preset` ni invoque `descarga_agresiva_viajeros()` en un viaje real; el mecanismo M62 queda medido y el feed runtime es del dueño de M27 (mismo criterio que L132).
- [x] Partículas infinitas por bug: límite de vida y devolución al pool garantizadas [S]
- [x] Tween sin fin en UI: auto-detención en `_exit_tree` [S] — Log 1094: `LeakGuard.registrar_tween()` + limpieza automática en `_exit_tree()`
- [x] Nieve/niebla (M32) que crea nodos por frame: detector de nodos por frame con alerta [M] — Log 1094: `DetectorNodosPorFrame` mide la DERIVADA (nodos/frame) y `alerta()` describe el crecimiento
- [x] Minimapa (M11) regenerando textura cada frame: reutilización de imagen destino sin alloc [C]
- [x] Memoria al límite durante tormenta máxima: degrada con aviso y el juego sigue jugable [M] — [x] 2026-10-20 (Tanda 77, DS-Opencode): **flip de herencia verificado**, no reimplementado. Autor: DeepSeek-V4.1-Flash (Log 2033, item 17). `sesion_m62_limite.gd` lleva la escena REAL `main_island.tscn` a 85/92/97% del presupuesto forzando el DENOMINADOR (no la memoria) en contexto de TORMENTA real de M32 alcanzada en 3 días: semáforo 1→2→3 con `semaforo_cambiado` 3 veces, enforcement hasta nivel 3, sin crash, Player movible, restauración exacta a 2032 MB y vuelta a 0. **14 checks, 0 fallos, EXIT 0** (`out/tanda77/limite_tormenta.log`). Regresión M32: `test_clima.gd` 29/0. **Alcance:** headless no prueba 60 fps (mide escena/Player vivos, no jugabilidad por frames) y no hay assets de audio en el repo; se cierra con esa deuda declarada. Log 2046.

## L. Optimización y mediciones

- [?] Baseline menú principal: objetivo < 600 MB [S] — **[?] 2026-10-20 (Tanda 78, DS-Opencode): NO MEDIBLE, no hay escena de menú.** `project.godot` arranca en `res://scenes/main_island.tscn`; los 4 candidatos (`scenes/main_menu.tscn`, `ui/main_menu.tscn`, `ui/menu.tscn`, `menu.tscn`) no existen; el único `*menu*.tscn` es `scenes/debug/debug_menu.tscn` (no es el menú principal). Medir `main_island.tscn` y llamarlo “menú” sería un falso verde. Evidencia del bloqueo: Log 2033 (item 18) + glob actual. Se deja `[?]` para que el dueño del menú lo cierre cuando la escena exista; no se inventa un número. Log 2047.
- [x] Baseline spawn de Aurora: objetivo < 1.600 MB [S] — **[x] 2026-10-20 (Tanda 79, DS-Opencode): medido con RENDERER REAL (OpenGL 3.3, AMD Radeon, ventana 640x360), no headless.** `sesion_m62_baselines.gd` spawn: **149.7 MB static, 7307 objetos, 0 huérfanos, 7/0 EXIT 0**. Probe de VRAM sobre la misma escena: **static 145.6 + VRAM 44.3 = 189.9 MB** (tex 12.2, buf 32.1), 7288 objetos. Total estimado **189.9 MB << 1600 MB** (11.9% del objetivo). Alcance: boot automatizado con renderer real y 12–15 s de asentamiento, no una sesión manual; no hay banco de audio completo. Evidencia: `out/tanda79/spawn_render.log` sha256 `b9938516…`, `out/tanda79/probe_vram.log` sha256 `7ed5c3f5…`. Log 2048.
- [x] Baseline horizonte terrestre oteado: objetivo < 2.200 MB [S] — **[x] 2026-10-20 (Tanda 80, DS-Opencode): medido con RENDERER REAL (OpenGL 3.3, AMD Radeon), no headless.** `sesion_m62_baselines.gd` horizonte: **151.7 MB static, 7384 objetos, 0 huérfanos, 9/0 EXIT 0**; cámara a **20.00 m** del Player (tope de oteo). Probe de VRAM: **static 148.0 + VRAM 44.4 = 192.4 MB** (tex 12.2, buf 32.2), 7293 objetos. Total **192.4 MB << 2200 MB** (8.7% del objetivo). Se corrigió el arnés (cámara resuelve `_target` un frame después; el scroll solo cambia `_distance` y la posición converge en `_physics_process`), sin tocar código de producción. Evidencia: `out/tanda80/horizonte_render.log` sha256 `a714c30e…`, `out/tanda80/probe_vram_horizonte.log` sha256 `398910cc…`; regresión spawn `spawn_render_patch.log` 7/0. Log 2051.
- [?] Baseline subterráneo del templo (M26): objetivo < 2.000 MB [S] — **[?] 2026-10-20 (Tanda 81, DS-Opencode): NO MEDIBLE, no existe templo/API de acceso.** No hay ninguna escena `*templo*` ni `*subterr*` en `scenes/` (solo scripts de puzzles en `scripts/templos/` y referencias de zonas en combate/minería). El arnés solo puede bajar al Player 40 m en el spawn (Y 6.0 → -34.0); con renderer real reporta **1 VoxelTerrain y 0 bloques actualizados**, así que el subterráneo no se ejercita: **155.9 MB static / 7354 objetos / 0 huérfanos / 8 checks, 1 fallo (sin API de producción), EXIT 3 (detector ciego)**. Ese número NO es un baseline del templo y no se usa. Se deja `[?]` hasta que exista la escena/entrada de producción. Evidencia: `out/tanda81/subterraneo_render.log` sha256 `f1ea9c77…`. Log 2052.
- [?] Baseline tormenta máxima (M32) + banco de audio completo: ≤ 2.500 MB (Alta) [S] — **[?] 2026-10-20 (Tanda 82, DS-Opencode): memoria MEDIDA, banco completo NO medible.** Renderer real OpenGL 3.3, TORMENTA determinística tras 3 días: **157.9 MB static / 7412 objetos / 0 huérfanos / 8 checks 0 fallos / EXIT 0**, 7 buses y 9 reproductores; banco `AudioStreamWAV` sintético de 3 MB (151.9 → 157.9 MB). Probe: **static 152.0 + VRAM 44.7 = 196.7 MB** (7.9% del objetivo de 2500 MB), 7322 objetos. Pero **0 assets de audio** en el repo y `AmbientDirector.set_estado_clima()` (M42) sigue con 0 llamadores: el “banco completo” no existe; el sintético es un stand-in y no prueba assets ni decoder. Queda `[?]` hasta que exista el banco real (M42/assets), no se marca un verde que no se midió. Evidencia: `out/tanda82/tormenta_audio3_render.log` sha256 `dd47de0f…`, `out/tanda82/probe_vram_tormenta.log` sha256 `70f7f327…`. Log 2053.
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
- [x] Test Play Mode: drift-check de 30 min sin teleport con drift ≤ 5% [C] — **[x] 2026-10-20 (Tanda 83, DS-Opencode): cubierto por la corrida real de 30 min de T72/L155.** `sesion_m62_clima_30min.gd` sobre `main_island.tscn`: **359 muestras** (mínimo 300), baseline 178.2 MB, **drift final +0.1% (máx 0.1%)**, `drift_check()=true`, **0 viajes/teleports**, 0 huérfanos, 10 cambios de clima, **EXIT 0**. La corrida incluye clima cambiante (estrés adicional), así que cubre el caso sin teleport. **Alcance:** el arnés es `SceneTree --script` (no el Play Mode del editor), sin input de jugador; se declara la diferencia y no se inventa una sesión manual. Evidencia: `out/tanda72/sesion_audio_30min.log` y `.csv` (sha256 del log en el Log 2039). Log 2054.
- [x] Test Play Mode: teleport extremo ×10 con memoria estable y sin picos [C] — iter. 7 (2026-10-17, Tanda 6, DS-Opencode): suite test_m62_leaks_teleport.gd: "los 10 ciclos de teleport se ejecutaron completos" + "objetos_vivos() NO crece tras 10 teleports (fin <= base; medido delta=0)" + cola vacia tras cada descarga; rc=0, 21 checks 0 fallos.
- [x] Test Play Mode: cambio de bioma de audio sin crecimiento de memoria [M] — **[x] 2026-10-20 (Tanda 84, DS-Opencode): suite directa + 30 min de T72.** `test_m62_audio_bioma.gd` (headless, autoload real): **45 checks, 0 fallos, EXIT 0**; entrar/salir de bioma encola y descarga el banco, 3 ciclos de viaje, **0 bancos sobrevivientes (WeakRef)**, `objetos_vivos()` **4477 → 4477 (delta 0)**, cola vacía y lote de drenaje único. La corrida de 30 min de T72 con 10 bancos sintéticos mantiene la memoria plana (178.2 → 178.4 MB, drift +0.1%, 1 banco vivo). **Alcance:** el arnés es `SceneTree --script`, no el Play Mode del editor; la suite mide retención/objetos y T72 aporta la memoria de 30 min. Evidencia: `out/tanda84/audio_bioma.log` sha256 `E54AB45D…`. Log 2055.
- [x] Test Play Mode: excavar y regenerar 500 bloques sin leaks de buffers voxel [C] — **[x] 2026-10-20 (Tanda 85, DS-Opencode): 500 ops reales sobre VoxelBuffer.** `sesion_m62_voxel_500.gd`: **9 checks, 0 fallos, EXIT 0**; 500 posiciones sólidas, **500/500 excavadas leídas como AIRE**, **500/500 regeneradas** con el ID original; **5 buffers creados, 0 vivos**; memoria 137.3 → 137.3 MB (delta +0.0%); objetos +5; 0 huérfanos. **Sonda roja:** `M62_RETENER_BUFFERS=1` retuvo 5 buffers y el gate falló (`[FALLO] 0 buffers...`, EXIT 1), así que el test detecta la fuga. **Alcance:** el VoxelTerrain headless reporta 0 bloques actualizados, por lo que se ejercita el VoxelBuffer real (mismo tipo/API que farm_service) y no el terreno renderizado; no es el Play Mode del editor. Evidencia: `out/tanda85/voxel_500.log` sha256 `A9C2…` y `voxel_500_rojo.log`. Log 2056.
- [ ] Test Play Mode: máximo de chunks cargados sin superar el presupuesto voxel [M]
- [x] Test Play Mode: textura gigante forzada degrada sin crash [M] — iter. 7 (2026-10-17, Tanda 6, DS-Opencode): suite test_memoria_m62_iter3.gd: "con umbral 64 sí es gigante" + "requiere_degradacion() true" + "la politica se aplico" + "la textura degradada mide la mitad / y ahora tiene mips / ocupa menos"; rc=0, 133 checks 0 fallos.
- [x] Test de semáforos: forzar 90% y verificar descargas automáticas y registro en log [C] — Log 1094: bloques B y C de `test_memoria_m62_iter3.gd` (1599/1600/1799/1800/1899/1900/2000 MB) + bloque C de `test_enforcement_m62.gd`
- [x] Test de nodos huérfanos: conteo de orphans en reposo con valor estable [M] — **iter. 4 (Log 1112): MEDIDO.** Bloque D de `test_m62_liberacion.gd`: base=0, 5 muestras consecutivas sin deriva, crear 128 nodos sin padre los cuenta (0 → 128) y liberarlos devuelve el conteo a 0 (sin leak). Lee `Performance.OBJECT_ORPHAN_NODE_COUNT`
- [ ] Test en preset Baja con 4 GB de RAM: sesión completa sin OOM y jugable [C]


**Totales:** 150 items - Completados: 142 - Pendientes: 5 - No resueltos: 3.

## Notas del Agente — auditoría Patrón D de los 37 `[ ]` (2026-10-15, step-5-kilocode / Kilo Code)

**Resultado: 0 flips. Los 37 se mantienen.** Auditoría pedida por el director (msg 407).

**Lo que sí existe y está verificable en disco** (para que el próximo no vuelva a
buscarlo):

- El servicio existe y es sustancial: `scripts/rendimiento/memoria/memory_monitor.gd`,
  **568 líneas**, con ~70 funciones públicas. Cubre semáforo de memoria, presupuestos
  por sistema, baseline y drift (`baseline_mb`, `drift_porciento`, `drift_check`),
  cola de descarga con veto por carga en curso, evicción de atlas
  (`evictar_atlas`), cambio de región (`avisar_cambio_region`), bancos de audio
  (`pedir_banco_audio`, `bancos_audio_diferidos`) y puntos de interés.
- La suite de tests es grande: **~373 `_check()` en 8 archivos** —
  `test_memoria_m62_iter3.gd` (135), `test_memoria_m62_iter5.gd` (61),
  `test_enforcement_m62.gd` (49), `test_memoria_m62.gd` (29), `test_pool_iter2.gd`
  (28), `test_m62_leaks_teleport.gd` (22), `test_m62_pureza_save.gd` (21),
  `test_m62_liberacion.gd` (17).

**Por qué ningún `[ ]` se promueve**, con el detalle por naturaleza:

1. **11 ítems miden una sesión real** (30 min de juego, drift < 5%, baselines de
   600/1600/2200/2000/2500 MB, tormenta máxima). No hay forma de verificarlos sin
   ejecutar el juego; ningún número de esos está medido en disco.
2. **14 ítems dependen de otro módulo** y nombran el dueño entre paréntesis (M63,
   M42, M41, M32, M09, M12, M69, M28, M27, M26, M08, M91). Verifiqué los
   consumidores reales de las APIs clave de M62 y **solo una está integrada**: el
   handshake de carga con `scripts/stream/stream_manager.gd`, que llama
   `avisar_carga_iniciada/terminada` (L158-175) y `registrar_candidato_descarga`
   (L308-309). El resto —`evictar_atlas`, `avisar_cambio_region`,
   `pedir_banco_audio`, `drift_check`, `estabilizar_baseline`, `doble_descarga_evitada`,
   `iniciar_descarga_audio`— **no tiene ningún consumidor fuera de los tests**: el
   mecanismo está construido y probado aisladamente, pero nada en el juego lo llama,
   así que el comportamiento que describen los ítems no ocurre.
3. **16 ítems son mecanismo propio** pero igualmente describen comportamiento
   (buffers de VoxelTools por chunk, colliders de chunks descargados, diffs del
   jugador sin historial infinito). La capacidad existe en `memory_monitor.gd` y los
   tests la ejercen, pero no hay evidencia de que el chunking o el sistema de
   edición la invoque.

**Conclusión operativa:** M62 está **construido y bien testeado, pero integrado solo
por el camino de streaming**. Los 37 `[ ]` no son deuda de implementación del módulo
sino de **cableado**: falta que M63, M09, M42, M41 y el sistema de chunks llamen a
las APIs que ya existen. Ese es el trabajo real que queda, y es de los dueños de
esos módulos, no de M62.

**Salvedad honesta:** no ejecuté ningún test (Godot no disponible en este entorno).
El conteo de `_check()` es lectura de fuente, no resultado de corrida.

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

## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 8)
M62: Sustentado, 0 degradaciones. Evidencia: test_memoria_m62_iter5.gd 60/0 = scripts/rendimiento/memoria/; verificado contra disco.

## Notas del Agente — Tanda 59 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-18, Log 1997)

**Estado:** L100 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_texturas_region.gd`
(33 checks, 0 fallos, ×3 idénticas) que ejercita el contrato extremo a extremo con los DOS
autoloads reales — exactamente el hueco que la auditoría de cableado (2026-10-15, arriba)
declaró irresoluble sin Play Mode. Guardián de 3 capas probado EN ROJO con 2 inyecciones
(piso y aborto real de B; out/tanda59/suite_rojo_piso.log + suite_rojo_aborto.log).
Prelación empírica: la sonda `probe_unreference.gd` verificó SEGURA la semántica de
`unreference()` sin `reference()` previo (`stream_manager.gd` L350) — nunca antes
ejercitada porque las suites viejas registran chunks sin recurso.

**Alcance declarado:** el llamador de gameplay (M09/M27 avisando la salida de región) NO
existe aún y NO es parte de este cierre; queda como deuda de cableado de esos módulos.
Mismo criterio de alcance que L106/L101.

**No toqué:** `quality.yml` (gate de CI — es de s2/director); el colector de sintaxis
(autogenerado por `tools/quality/gen_colector_sintaxis.py`, se regenera en CI).

**Totales tras el cierre:** 119 / 31 / 0 (150 items).

## Notas del Agente — Tanda 60 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-18, Log 1998)

**Estado:** L132 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_duro95.gd`
(39 checks, 0 fallos, ×4 corridas idénticas) sobre el autoload REAL `MemoryMonitor`, con el
disparo DURO del diseño §3 ejercitado de punta a punta: umbrales → nivel 3 → viajeros +
atlas fuera de pantalla + audio diferido.

**Hallazgo (registrado para inspectores):** los umbrales 80/90/95 de esta suite se DERIVAN del
presupuesto VIVO (`presupuesto_total_mb()`), no de un hardcode: el autoload suma al preset del
JSON los sistemas registrados en runtime (`npc_manager.gd` registra `ia_npc` = 32 MB → total
2000+32 = 2032 MB en el arranque de hoy). La iteración queda capturada en
`out/tanda60/suite_run1.log` (4 fallos con el pin hardcodeado 2000) → derivación con `ceil`
(robusta a futuros registros runtime). Las suites viejas que instancian su propio registro local
(p. ej. `test_enforcement_m62.gd`) no se ven afectadas: no usan el autoload.

**Guardán de 3 capas:** probado EN ROJO (piso artificial 999 → `[FALL]` del piso + exit 1;
`out/tanda60/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `9f2cb1e4…`).

**Alcance declarado:** este cierre pina el CONTRATO del 62 (si el recurso está registrado, el
duro lo descarga; el atlas LRU evicta lo fuera de pantalla; el banco viajero en descarga se
difiere). Los FEEDS de producción no existen aún y son deuda de sus dueños: tabla de atlas
(M09/M63) y registro de bancos al viajar (M42 — ya trackeado como ítem 112 del backlog).

**Totales tras el cierre:** 120 / 30 / 0 (150 items).

## Notas del Agente — Tanda 61 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-18, Log 2001)

**Estado:** L137 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_voxel_buffers.gd`
(19 checks, 0 fallos, ×3 idénticas) con los DOS autoloads reales. El hiato que la auditoría de
cableado (2026-10-15, arriba) declaró irresoluble sin Play Mode queda pinnado por contrato.

**Cambio de producción (ensanche):** las firmas de M62 tipadas `Resource` pasaron a `RefCounted`
(`unload_policy.marcar_candidato`; `memory_monitor.esta_en_carga/_puede_descargar/
registrar_candidato_descarga`) para admitir el payload real de M08 (VoxelBuffer es RefCounted,
sonda out/tanda61/probe{1,2}.log). Retrocompatible (Resource extiende RefCounted); M63 intacto.
Regresión: 10 suites M62 + generar_budgets --check verdes (out/tanda61/reg_*.log).

**Guardián de 3 capas:** probado EN ROJO (piso artificial 999 → `[FALL]` + exit 1;
`out/tanda61/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `c9632f6e…`; sha actual tras el P.D.: `03b2c6ef…`).

**Alcance declarado:** el cableado de producción es deuda de M08: quien creará los VoxelBuffer
por chunk y los registrará vía `registrar_candidato_descarga()` es el futuro `ChunkMemory` de
M08 (junto con L134-139). El VoxelTerrain real gestiona sus buffers internos en C++ y no los
expone por chunk en GDScript. Mismo criterio de alcance que L100/L132.

**No toqué:** `quality.yml` (gate de CI — es de s2/director); el colector de sintaxis
(autogenerado).

**Totales tras el cierre:** 121 / 29 / 0 (150 items).



**P.D. (corrección de referencias de Log, misma sesión):** los headers de `unload_policy.gd`, `memory_monitor.gd` y `test_m62_voxel_buffers.gd` citaban «Log 1999» — que es el log real de Step-5-WorkBuddy (barrido de pools). El log correcto de esta tanda es **Log 2001**. El fix es de comentarios (sin cambio de código): la suite se re-corrió tras el fix → 19/0 (out/tanda61/suite_run4_postfix.log) y su sha256 pasó de `c9632f6e…` (guardián/cierre) a `03b2c6ef…` (actual). Es el único delta.

## Notas del Agente — Tanda 62 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-18, Log 2004)

**Estado:** L139 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_colliders_chunk.gd`
(21 checks, 0 fallos, ×3 idénticas) con los DOS autoloads reales. Cierra el ítem de colliders
estáticos de chunks ("se liberan junto con la mesh").

**Sin cambio de producción:** la sonda (out/tanda62/probe1.log) midió que el collider real de un
chunk voxel (`ConcavePolygonShape3D` de `Mesh.create_trimesh_shape()`) YA es Resource + RefCounted
y viaja por la cola M62 tras el ensanche T61 — no hizo falta tocar producción. La suite pina
el contrato: par {mesh + collider} encolado → 0/24 sobrevivientes; 5 ciclos × 10 pares → 0/100;
mesh vía M63 + collider directo mueren en el MISMO evento de descarga (0/2); nodo
StaticBody3D+CollisionShape3D sin huérfanos tras free().

**Guardián de 3 capas:** probado EN ROJO (piso artificial 999 → `[FALL]` + exit 1;
`out/tanda62/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `90baf14e…`).

**Alcance declarado:** el cableado de producción sigue siendo deuda de M08: `chunk_memory.gd`
(04-Codigo: escucha `chunk_saliendo` de M63, libera buffers/colliders, reutiliza meshes del pool)
es quien creará el collider por chunk y lo registrará. El VoxelTerrain real gestiona sus
colliders internos en C++ y no los expone por chunk en GDScript. Mismo criterio que L137 (T61).

**No toqué:** `quality.yml` (gate de CI — es de s2/director); el colector de sintaxis
(autogenerado).

**Totales tras el cierre:** 122 / 28 / 0 (150 items).

## Notas del Agente — Tanda 63 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-18, Log 2006)

**Estado:** L140 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_sin_duplicacion.gd`
(33 checks, 0 fallos, ×3 idénticas) con los DOS autoloads reales. Cierra el ítem "Sin
duplicación de meshes entre M63 (streaming) y el 62 (descarga)" (origen RF5 de 01-Requerimientos L54).

**Sin cambio de producción:** el contrato ya estaba vigente — `registrar_chunk` del 63 ofrece
UNA vez por chunk (gate `es_nuevo`), el re-registro por frame no re-ofrece, el drenaje del 62 cuenta
MB pero NO libera (drop del dueño vía `liberar_envejecidos`), y el veto de handshake es opt-in
(filtro `_puede_descargar` que producción siempre pasa). Hallazgo de la ronda: el drenaje directo
SIN filtro no veta — la suite D usa el filtro de producción; documentado en su cabecera.

**Guardián de 3 capas:** probado EN ROJO (piso artificial 999 → `[FALL]` + exit 1;
`out/tanda63/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `60df8436…`).

**Alcance declarado:** el cableado de producción sigue siendo deuda de M08: `chunk_memory.gd`
(generación de mallas en hilos, L141) es quien creará y registrará por chunk. Mismo criterio
que L137 (T61) y L139 (T62).

**No toqué:** `quality.yml` (gate de CI — es de s2/director); el colector de sintaxis
(autogenerado).

**Totales tras el cierre:** 123 / 27 / 0 (150 items).

## Notas del Agente — Tanda 64 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-19, Log 2007)

**Estado:** L141 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_hilos_cola_mallas.gd`
(33 checks, 0 fallos, ×3 corridas idénticas runs 8/9/10) con los DOS autoloads reales. Cierra el ítem
"Generación de mallas en hilos (M08): resultados por cola sin copias extra".

**Sin cambio de producción:** el camino real ya cumple — `encolar` con ruta usa `load_threaded_request`/
`load_threaded_get` y entrega la MISMA instancia del cache (identidad verificada); `_encolar_precarga`
rechaza la segunda llamada mientras hay ruta en vuelo (anti-doble, guard L158).

**Hallazgo del engine (7 corridas de iteración lo aislaron):** con la descarga del 62 activa
(`ejecutar_descarga` + `marcar_envejecidos` + `liberar_envejecidos` JUNTOS), el engine RECLAMA la
instancia descargada y la siguiente carga entrega una instancia NUEVA limpia; la reclamación precede
siempre a la entrega: JAMÁS dos vivas a la vez. Documentado como E-32 en
`GUIA-GODOT/06-registro-errores.md` (con traza de refcounts de las micro-sondas).

**Guardián de 3 capas:** probado EN ROJO (piso artificial 999 → `[FALL]` + exit 1;
`out/tanda64/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `4666e207…`).

**Alcance declarado:** el cableado de producción de M08 (`chunk_memory.gd` generando mallas en
hilos por chunk) sigue siendo deuda de ese dueño; esta suite pina el contrato de la cola/loader
del 62/63 (identidad sin copias + anti-doble + reclamación limpia). Mismo criterio que L137/139/140.

**No toqué:** `quality.yml` (gate de CI — es de s2/director); el colector de sintaxis
(autogenerado).

**Totales tras el cierre:** 124 / 26 / 0 (150 items).

## Notas del Agente — Tanda 65 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-19, Log 2010)

**Estado:** L142 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_diffs_ediciones.gd`
(24 checks, 0 fallos, ×3 corridas idénticas runs 3/4/5) con los DOS autoloads reales. Cierra el ítem
"Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM".

**Sin cambio de producción:** el camino real de edición (`tool_controller.gd`) escribe con
`do_point` (1 escritura por acción; `do_sphere`/`do_box` ausentes; 0/8 patrones de historial/op-log
en la fuente). Nada acumula por diseño; la tanda pina ese contrato con mediciones.

**Hallazgo de herramienta (sondas T65):** `VoxelToolBuffer` NO es instanciable desde GDScript en
este build (can_instantiate=false; constructor no bindeado; sin `set_buffer`; `ClassDB.instantiate`
nulo). Documentado en `GUIA-GODOT/02-voxel-tools.md` §20. Para tests sin terreno real:
`VoxelBuffer.set_voxel` directo.

**Evidencia (out/tanda65):** runs 1-2 de iteración hallaron 2 defectos de harness (typing `Resource`
de `registrar_chunk`; WeakRefs contadas en el balance global) → corregidos; runs 3/4/5 idénticas
(24/24, exit 0; logs normalizados idénticos). Guardián de 3 capas EN ROJO (piso 999 → `[FALL]` +
exit 1; suite restaurada byte-idéntica sha256 `0689b07d…`). Regresión: 11 suites + budgets verdes.

**Alcance declarado:** el cableado de producción de M08 (`chunk_memory.gd`) sigue siendo deuda de
ese dueño; esta suite pina el contrato del camino real (edición por acción sin historial) + la
liberación por las colas del 62/63. Mismo criterio que L137/139/140/141.

**No toqué:** `quality.yml` (gate de CI — es de s2/director); el colector de sintaxis
(autogenerado).

**Totales tras el cierre:** 125 / 25 / 0 (150 items).

## Notas del Agente — Tanda 66 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-19, Log 2012)

**Estado:** L143 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_anillo_borde.gd`
(24 checks, 0 fallos, ×3 corridas idénticas 3/4/5) con los DOS autoloads reales. Cierra el ítem
"Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos".

**Contrato medido (mecanismo §4 del 63, sin cambio de producción):** borde = distancia > r_max+1.0
ESTRICTO (la frontera exacta r_max+1.0 queda dentro); una sola marca NO libera (gracia de 2 frames);
dos marcas liberan EXACTAMENTE el borde; el contador se resetea si el chunk vuelve al rango;
`liberar_envejecidos` es idempotente y suma a `descargas_total`.

**Invariante del ítem medida (borde ANTES que nuevos):** con anillo A (5 interior + 4 borde) y la
secuencia canónica — 62 drena su cola (9) → move r100→60 (marcar×2 + liberar: 4 del borde) → el
borde queda 0/4 vivos mientras el interior sobrevive 5/5 → RECIÉN ENTONCES se registran los 4
nuevos (9 activos, ninguno de los ids viejos del borde activo, balance ≤ base+9). Vía mixta 63→62
con Resource: candidato auto, el 62 drena, el 63 cierra su libro y el payload muere (0/1 vivos).
Ciclo completo de 2 movimientos (r200→r100): cada movimiento descarga SU borde (2+2, incluido el
chunk recién cargado que quedó fuera) y termina en 3 activos = 3 vivos (balance ≤ base+3).

**Evidencia (out/tanda66):** corrida 1 de iteración halló un defecto de harness (los WeakRef wrappers
cuentan en `objetos_vivos`: B +22 = 9 chunks + 13 wrappers; D +1; E +10 = 3 + 7) → corregido con
`clear()` antes del balance; corrida 2 verde; corridas 3/4/5 idénticas (24/24, exit 0; logs
normalizados idénticos). Guardián de 3 capas EN ROJO (piso 999 → `[FALL]` + exit 1; suite
restaurada byte-idéntica sha256 `19200978…`). Regresión: 13 suites + budgets verdes.

**Alcance declarado:** el caller de producción del movimiento del anillo (M12 zoom → M63 aplicar
r_max) todavía no está cableado en el repo; esta suite pina el mecanismo de descarga del borde
del 62/63 y la secuencia canónica que lo cumple. El cableado M12/M63 sigue siendo deuda de esos
módulos. Mismo criterio que L137/139/140/141/142.

**No toqué:** `quality.yml` (gate de CI — es de s2/director); `stream_manager.gd` (M63,
read-only); `memory_monitor.gd`; el colector de sintaxis (autogenerado).

**Totales tras el cierre:** 126 / 24 / 0 (150 items).

## Notas del Agente — Tanda 67 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-19, Log 2013)

**Estado:** L149 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_audio_bioma.gd`
(45 checks, 0 fallos, ×3 corridas idénticas 3/4/5) con el autoload real MemoryMonitor. Cierra el ítem
"Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región".

**Contrato medido (mecanismo del 62, sin cambio de producción):**
- ENTRAR al bioma: `pedir_banco_audio` devuelve "reproducir" (el banco entra reproducible; sin
  descargas declaradas ni diferidos).
- SALIR de la región: el banco del bioma viejo se encola como candidato y el cambio de región
  FUERZA su descarga (`avisar_cambio_region` == true); prueba fuerte con WeakRef: el banco NO
  sobrevive (queda sin retención tras el drenaje).
- Banco EN CARGA: el cambio de región lo VETA (`descartes_por_carga` +1, queda en cola, no se
  pierde); terminada la carga, el siguiente cambio lo descarga. La salida de región no corta el
  banco que suena.
- CICLO ×3 (viajes): sin acumulación — la cola vuelve a 0 en cada frontera, las forzadas se
  cuentan (+3), los viajeros mueren (WeakRef 0) y `objetos_vivos` no crece (delta 0).
- ORDEN: drenaje por lejanía (5,3,1 estricto) y peso del banco en el lote (`resumen_ultimo_lote`
  empieza por el banco más lejano); UNA liberación forzada por cambio aunque haya 3 bancos.

**Evidencia (out/tanda67):** corrida 1 de iteración halló defectos de harness (snapshot `_camb_a`
pre-A y refs locales retenidas en los WeakRef: banco_selva/banco_costa/array de viajes) →
corregidos; corridas 3/4/5 idénticas (45/45, exit 0; logs normalizados de 399 líneas idénticos).
Guardián de 3 capas EN ROJO (piso 999 → `[FALL]` + exit 1; suite restaurada byte-idéntica sha256
`e24b72b0…`). Regresión: 14 suites + budgets verdes.

**Alcance declarado:** el cableado de producción M42 (avisar entrar/salir de bioma desde
`set_bioma`/`ambiente_cambiado` y encolar el banco que sale) todavía no existe en el repo — es
deuda de M42 (07 §12). Esta suite pina el mecanismo del 62 y el ciclo canónico que lo cumple.
Mismo criterio que los cierres previos (L137/139/140/141/142/143).

**No toqué:** `quality.yml`; `ambient_director.gd` (M42, read-only); `memory_monitor.gd`;
`stream_manager.gd` (M63, read-only); el colector de sintaxis (autogenerado).

**Totales tras el cierre:** 127 / 23 / 0 (150 items).

## Notas del Agente — Tanda 68 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-20, Log 2027)

**Estado:** L150 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_pistas_streaming.gd`
(57 checks, 0 fallos, ×3 corridas idénticas 2/3/4) con el autoload real MemoryMonitor. Cierra el ítem
"Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa".

**Contrato medido (mecanismo del 62, sin cambio de producción):**
- STREAMING de una pista larga: mientras está EN descarga (`iniciar_descarga_audio`), pedirla devuelve
  "diferido" (no se reproduce a medias); pedirla N veces durante la descarga NO duplica el registro
  (idempotente por nombre). `terminar_descarga_audio` la vuelve "reproducir" (stream listo).
- NO EN RAM COMPLETA: la pista de 60 MB se encola como candidata y el cambio de región la descarga
  (`avisar_cambio_region` == true); WeakRef 0 vivos y el lote reporta su peso SIN retener el recurso
  (`_ultimo_lote` es solo {peso,distancia,edad}).
- M41 + M44 SIMULTÁNEOS: música y ASMR en streaming a la vez; terminar una la vuelve reproducible
  SIN afectar a la otra; ambas se descargan en el mismo lote al salir de la región (60 MB primero).
- CICLO ×3 de regiones: sin acumulación — cola 0 en cada frontera, forzadas +3, pistas mueren
  (WeakRef 0), el registro de diferidos suma los 3 nombres (strings, no recursos) y `objetos_vivos`
  no crece (delta 0).
- ORDEN: drenaje por lejanía (9,5,2 estricto) y pesos en el lote; UNA liberación forzada por cambio
  aunque haya 3 pistas.

**Evidencia (out/tanda68):** corrida 1 de MEDICIÓN dio verde a la primera (57/57) sin iteración de
harness; corridas 2/3/4 idénticas (exit 0; logs normalizados de 410 líneas idénticos). Guardián de
3 capas EN ROJO (piso 999 → `[FALL]` + exit 1; suite restaurada byte-idéntica sha256 `43a73a43…`).
Regresión: 15 suites + budgets verdes.

**Alcance declarado:** M41 (MusicDirector) y M44 (FeedbackDirector) son HOY directores de LÓGICA
(matriz de temas / recetas de feedback): no tienen AudioStreamPlayer ni llaman al handshake de audio
del 62 (`iniciar_descarga_audio`/`pedir_banco_audio`) — verificado por grep (solo el monitor y las
suites lo usan). Ese cableado es deuda de M41/M44 (07 §12). Esta suite pina el mecanismo del 62 y el
ciclo canónico que lo cumple. Mismo criterio que los cierres previos (L137/139/140/141/142/143/149).

**No toqué:** `quality.yml`; `music_director.gd` / `feedback_director.gd` (M41/M44, read-only);
`ambient_director.gd` (M42, read-only); `memory_monitor.gd`; `stream_manager.gd` (M63, read-only);
el colector de sintaxis (autogenerado).

**Totales tras el cierre:** 128 / 22 / 0 (150 items).

## Notas del Agente — Tanda 69 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-20, Log 2029)

**Estado:** L152 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_ogg_cache.gd`
(46 checks, 0 fallos, ×3 corridas idénticas 3/4/5) con el autoload real MemoryMonitor. Cierra el ítem
"Streams `.ogg` liberados de caché cuando ningún reproductor los usa".

**Contrato medido (mecanismo del 62, sin cambio de producción):**
- CON reproductor: un stream asignado a un AudioStreamPlayer no se descarga al cambiar de región
  (`avisar_cambio_region` lo saltea por estar en uso) y muere recién al soltar la última referencia
  del reproductor y drenar la cola (WeakRef 0).
- SIN reproductor: `marcar_candidato` RETIENE el stream mientras está encolado (correcto: no se libera
  antes del drenaje); `ejecutar_descarga` lo libera (WeakRef 0) y el lote reporta solo {peso,dist,edad}.
- CICLO ×3 usar/soltar/drenar: 3 streams muertos, cola 0 en cada frontera, forzadas +3, sin acumulación.
- LOTE MIXTO: el stream con reproductor sobrevive al drenaje y el libre muere (discriminación por uso).
- PoolFactory `audio_voz`: el player nace estacionado SIN stream; reciclar/free libera el stream (el pool
  no retiene media).

**Evidencia (out/tanda69):** corrida 1 (v1) y corrida 2 fueron construcción del harness (defectos
detectados y corregidos: asertos de muerte antes del drenaje, `objetos_vivos` con ruido del engine y
`weakref` inferido como Variant). Corridas 3/4/5 del archivo final: 46 checks, 0 fallos, exit 0,
logs normalizados idénticos de 399 líneas. Guardián de 3 capas EN ROJO (piso 999 → `[FALL]` + exit 1;
suite restaurada byte-idéntica sha256 `526bb017…`). Regresión: 16 suites + budgets verdes.

**Alcance declarado:** el repo no tiene assets de audio (0 `.ogg/.wav/.mp3` en game/isla-ancestral),
así que no se puede construir un `AudioStreamOggVorbis` real; se usa `AudioStreamWAV` como stand-in
DECLARADO (misma semántica RefCounted y misma propiedad `stream` del reproductor). Se mide la
LIBERACIÓN cuando ningún reproductor usa el stream, no el decoder ogg (criterio T65). Mismo criterio
que los cierres previos (L137/139/140/141/142/143/149/150).

**No toqué:** `quality.yml`; `music_director.gd` / `feedback_director.gd` (M41/M44, read-only);
`ambient_director.gd` (M42, read-only); `memory_monitor.gd`; `pool_factory.gd`; `unload_policy.gd`;
`stream_manager.gd` (M63, read-only); el colector de sintaxis (autogenerado).

**Totales tras el cierre:** 129 / 21 / 0 (150 items).

## Notas del Agente — Tanda 70 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-20, Log 2031)

**Estado:** L153 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_buses_m91.gd`
(40 checks, 0 fallos, ×3 corridas idénticas 5/6/7) con el AudioServer REAL y la topología de buses
M91 del proyecto. Cierra el ítem "Los buses (M91) no retienen streams detenidos".

**Contrato medido (mecanismo del engine + topología M91, sin cambio de producción):**
- TOPOLOGÍA M91: los 7 buses existen (Master, Music, SFX, Ambient, Voice, UI, Cinematic), bus_count
  == 7 y los 6 no-Master siguen enrutados a Master.
- STREAM DETENIDO: reproducir un AudioStream real en Music, stop() + stream = null → el bus no
  retiene el stream (WeakRef muere tras el frame del playback), bus_count sigue en 7 y los efectos
  del bus no cambian.
- CICLO ×3 en Music/SFX/Ambient: 3 streams muertos, bus_count constante y los buses siguen existiendo.
- BUS CON EFECTOS: con el compressor montado en Master, el stream detenido igual muere y el efecto
  sigue montado (el efecto no guarda el stream).
- PLAYER LIBERADO REPRODUCIENDO: free() del reproductor libera el stream, bus_count sigue en 7 y el
  árbol no queda con reproductores colgados (conteo local, no OBJECT_COUNT global).

**Evidencia (out/tanda70):** corridas 1-4 fueron construcción del harness (defectos detectados y
corregidos: argumentos invertidos en un check, el AudioServer libera el playback en el frame
siguiente → espera acotada por WeakRef, y OBJECT_COUNT global derivaba entre corridas → se
sustituyó por un criterio local del árbol). Corridas 5/6/7 del archivo final: 40 checks, 0 fallos,
exit 0, 57 líneas de test normalizadas idénticas (se filtra el ruido no determinista del arranque
del mundo: spawner M36, impostores M09). Guardián de 3 capas EN ROJO (piso 999 → `[FALL]` + exit 1;
suite restaurada byte-idéntica sha256 `dad6998a…`). Regresión: 17 suites + budgets verdes.

**Alcance declarado:** el repo no tiene assets de audio (0 `.ogg/.wav/.mp3` en game/isla-ancestral);
se usa AudioStreamWAV generado en memoria como stand-in DECLARADO (AudioStream REAL del engine,
misma semántica RefCounted). Se mide la retención del stream por parte del bus, no el decoder.
Mismo criterio que los cierres previos (L137/139/140/141/142/143/149/150/152).

**No toqué:** `quality.yml`; `music_director.gd` / `feedback_director.gd` (M41/M44, read-only);
`ambient_director.gd` (M42, read-only); `memory_monitor.gd`; `pool_factory.gd`; `unload_policy.gd`;
`stream_manager.gd` (M63, read-only); el colector de sintaxis (autogenerado).

**Totales tras el cierre:** 130 / 20 / 0 (150 items).

## Notas del Agente — Tanda 71 (DS-V4.1-Flash-Opencode, OpenCode, 2026-10-20, Log 2035)

**Estado:** L154 cerrado por MEDICIÓN (no por argumento): suite nueva `test_m62_bioma_audio_diferido.gd`
(47 checks, 0 fallos, ×3 corridas idénticas 1/2/3) con el autoload REAL `MemoryMonitor`.

**Cambio de producción (`memory_monitor.gd`, M62):**
- `avisar_cambio_bioma_audio(banco_nuevo: RefCounted) -> bool`: mismo banco = `false` (no-op); si había
  un pendiente, lo suelta YA (dos cambios en el mismo frame no acumulan); el anterior pasa a PENDIENTE y
  el nuevo a ACTUAL; devuelve `true`.
- `_procesar_liberacion_audio()`: el primer `_process` tras el cambio marca el paso; el siguiente suelta
  el pendiente. El banco anterior sobrevive un frame completo de transición.
- Getters: `audio_banco_actual()`, `audio_banco_pendiente()`, `audio_liberaciones_diferidas()`,
  `audio_ultimo_liberado()`.

**Contrato medido:**
- Cambio a→b: el anterior queda PENDIENTE y VIVO en el frame del cambio; no se cuenta liberación; con
  el frame de margen muere (WeakRef) y se cuenta 1; el ACTUAL es b.
- Mismo banco: no-op, sin pendiente ni liberación espuria.
- Dos cambios en el mismo frame: el intermedio se suelta YA (2 liberaciones), el segundo queda PENDIENTE
  y muere con el margen (3); el ACTUAL es el tercero.
- RefCounted puro: el mecanismo no exige `Resource`; mismo ciclo sin acumulación (4 y 5 liberaciones).

**Evidencia (out/tanda71):** corrida de calibración inicial con piso 46 (47 checks); se elevó el piso a
47 y se repitieron 3 corridas del archivo final: 47 checks, 0 fallos, exit 0, 58 líneas de test
normalizadas idénticas (se filtra el ruido no determinista del arranque del mundo). Guardián de 3 capas
EN ROJO: piso 999 → `[FALL] solo 47 checks ejecutados (mínimo medido en verde: 999)` + exit 1; suite
restaurada byte-idéntica sha256 `fbe56577…`. Regresión: 18 suites + budgets verdes.

**Alcance y deuda:** M42 (`ambient_director.gd`) sigue read-only; el cableado real
`set_bioma() -> avisar_cambio_bioma_audio()` queda como deuda declarada de M42 (§12 del 07). Sin assets
de audio se usan bancos `Resource`/`RefCounted` sintéticos: se mide el contrato del mecanismo, no el
decoder. No se tocaron `quality.yml`, M41/M44, `stream_manager.gd` (M63), `pool_factory.gd` ni
`unload_policy.gd`.

**Totales tras el cierre:** 131 / 19 / 0 (150 items).

## Tanda 72 — L155 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2039)

**Prueba de 30 min con clima cambiante y banco de audio sintético.** Se extendió
`sesion_m62_clima_30min.gd` con `M62_AUDIO_BANCO_MB`: en cada `clima_cambio` crea un
`AudioStreamWAV` real de 3 MB (stand-in declarado: el repo no tiene assets), lo entrega a
`MemoryMonitor.avisar_cambio_bioma_audio()` (mecanismo L154) y verifica por `WeakRef` que el
banco anterior muere. No toca producción.

- **Corrida real:** 2026-10-20 02:32:16 → 03:02:16 (30 min), 359 muestras, 299 con baseline
  (178.2 MB), drift final +0.1% (máx 0.1%), `drift_check()=true`, 10 cambios de clima /
  10 eventos / 4 climas, 10 bancos creados, **1 vivo (ACTUAL)**, **PENDIENTE=null**, control
  positivo +3 MB, buses 7→7, reproductores 9→9, 0 huérfanos, 0 viajes, **0 SCRIPT ERROR**,
  EXIT 0. Evidencia: `out/tanda72/sesion_audio_30min.log` y `.csv`.
- **Sonda roja:** `M62_AUDIO_FUGA=1` retuvo 7 bancos (+21 MB) y el gate falló con
  `[FALLO] audio sintetico: 7 bancos vivos` + `PENDIENTE sin liberar` (EXIT 1). Evidencia:
  `out/tanda72/guardian_audio_rojo.log`.
- **Alcance:** mide el mecanismo M62 con un `AudioStreamWAV` sintético, no assets reales ni el
  decoder; M42 sigue con 0 llamadores (`set_estado_clima`), deuda declarada de M42. El
  `ERROR: Failed to retrieve non-existent singleton 'AnimationService'` es ruido preexistente
  del boot headless, ajeno a M62.
- **Reproducir:** `M62_AUDIO_BANCO_MB=3 <godot_console> --headless --path game/isla-ancestral
  --script res://scripts/rendimiento/memoria/sesion_m62_clima_30min.gd` (sin
  `M62_BASELINE_FORZAR`; el run real usa 1800 s).

**Totales tras el cierre:** 132 / 18 / 0 (150 items).

## Tanda 73 — L159 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2041)

**Lectura y contraste de los presupuestos M61 antes de fijar los topes duros de M62.**

- **M61 leído:** `data/performance/budgets.json` version 2 — 16,7 ms totales, tolerancia CI 10%,
  7 categorías que suman 16,5 ms; límites 500 partículas/cámara, 400 draw calls, 1000 objetos de
  mundo; 12 normas (60/30 FPS, 1080p, presets 100/150/220 m, LOD 3, 20 NPCs, remesh 2 ms, carga
  fría 30 s/caliente 10 s, sin HDD).
- **M62 contrastado:** `data/rendimiento/budgets.json` version 2 — Baja 1500 MB / Media 2000 MB /
  Alta 2500 MB, suma exacta de 8 sistemas; descarga por frame 8/12/16 (default 3).
- **Gates:** `validate_budget.gd` → `[M61] limites: 3`, `[M61] normas: 12`, **0 fallos**, rc=0;
  `generar_budgets.gd -- --check` → **20 checks, 0 fallos**, `BUDGETS OK`, rc=0. Evidencia:
  `out/tanda73/m61_validate_budget.log` y `out/tanda73/m62_generar_budgets_check.log`.
- **Veredicto:** sin conflicto; M61 gobierna tiempo/cantidad y M62 RAM. La deuda de M61
  (VRAM por escena, instancias por chunk, draw calls) queda declarada y no invalida los topes RAM.
  Sin cambio de código de producción.
- **Detalle:** `02-Analisis.md` sección 5.

**Totales tras el cierre:** 133 / 17 / 0 (150 items).

## Tanda 74 — L163 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2042)

**Cierre por medición de la frontera ResourceCache + cola M63.**

- **Bug medido (ROJO):** `StreamManager.encolar()` aceptaba una 2.ª operación con la MISMA
  `ruta_recurso` aunque la 1.ª siguiera en vuelo: `ok2=true`, cola 0→2 y dos callbacks
  (`doble_1`, `doble_2`). `_encolar_precarga()` sí filtraba, pero la API pública no.
  Evidencia: `out/tanda74/red.log` — 20 checks, **4 fallos**, EXIT 1.
- **Fix (M63, acotado):** guard al inicio de `encolar()`:
  `if ruta_recurso != "" and esta_cargando_ruta(ruta_recurso): return false`
  (con warning), ANTES de `ResourceLoader.load_threaded_request`. Una sola ruta = una sola
  operación = un solo dueño de la carga. `stream_manager.gd` sha256 `8e4188595e01…`.
- **Suite nueva:** `test_m62_doble_carga_m63.gd` (20 checks; piso 18). Prueba 1.ª carga,
  rechazo de la 2.ª, `_encolar_precarga` 0, un solo callback, ruta cerrada, M62 sin cargas,
  MISMA instancia del `ResourceLoader`, 0 duplicados en LeakGuard y control positivo
  `CACHE_MODE_IGNORE`.
- **Verde:** 20/20, 0 fallos, EXIT 0 — `out/tanda74/green.log` (sha256 `fcfcaf71…`).
- **Regresión:** `test_rf2_threaded` 7/0, `test_stream_m63_iter5` 51/0, `test_stream_m63_iter6`
  42/0, `test_m62_hilos_cola_mallas` 33/0 = **133 checks, 0 fallos** (`out/tanda74/*.log`).
- **Alcance:** no se tocó `quality.yml`; el llamador real de chunks sigue en M08/M63. Esta suite
  mide el contrato de la cola y la caché, no el streaming C++ de `VoxelTerrain`.

**Totales tras el cierre:** 134 / 16 / 0 (150 items).

## Tanda 75 — L166 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2044)

**Flip de herencia verificado: el item ya estaba implementado por DeepSeek-V4.1-Flash (Log 2021).**

- **Código existente (M28):** `TravelService._atracar()` llama `_verificar_drift_post_viaje(ruta)`
  después de aterrizar y antes de `travel_arrived`; resuelve `MemoryMonitor` por `ServiceRegistry`
  (contrato `memoria`), no por parseo. Umbral `UMBRAL_VIAJE_LARGO_S = 45.0` (rutas 45 s y 60 s).
- **Fail-closed:** sin monitor o sin `drift_check`/`drift_porciento`, suma `drift_no_medibles` y
  avisa; un viaje largo NO se reporta verde sin medición.
- **Gate:** `test_m62_drift_post_viaje.gd` — **12 checks, 0 fallos, EXIT 0**:
  A corto (20 s) no chequea; B largo (60 s) chequea 1 y 0 fallos; C baseline inyectada a la mitad
  (drift 100%) → 1 fallo; D sin monitor → 1 no medible y el contador de checks no sube; 4 llegadas
  emitidas; umbral 45 s. Evidencia `out/tanda75/drift_post_viaje.log` (sha256 `025a6ea6…`).
- **Regresión M28:** `test_viajes.gd` → **0 fallos, EXIT 0** (`out/tanda75/test_viajes.log`,
  sha256 `bfec4aa0…`).
- **Alcance:** M69 no ejecuta el teleport (solo emite `viaje_solicitado`; el caller M28/M59 lo hace).
  La medición cubre el punto de llamada real de M28; el viaje rápido M69 queda como contrato de
  señal, no como teleport medido. El umbral 45 s queda confirmado por las rutas reales.

**Totales tras el cierre:** 135 / 15 / 0 (150 items).

## Tanda 76 — L180 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2045)

**Flip de herencia verificado: el mecanismo ya estaba implementado por DeepSeek-V4.1-Flash (Log 2021).**

- **Tope por preset:** `TOPE_ISLAS_POR_PRESET = {"baja": 1, "media": 2, "alta": 2}` inyectado por
  `IslandTravelGuard.configurar(vista, {"preset": ...})`; preset desconocido cae a `media` (no a 0).
- **Carga priorizada:** `debe_precargar()` usa por defecto `min(MAX_OPS_POR_FRAME,
  max_islas_en_memoria())` y ordena candidatas por distancia; un presupuesto explícito sigue mandando.
- **Descarga agresiva:** `descarga_agresiva_viajeros(isla_actual, ops)` descarga todas las islas
  cacheadas que no sean la actual ni la principal, de la más vieja a la más nueva, hasta el tope del
  preset, sin esperar presión de memoria. No toca `descubierta`/`visitada` y devuelve
  `estado_preservado`.
- **Gate:** `test_m62_preset_baja_m27.gd` — **13 checks, 0 fallos, EXIT 0**:
  A tope baja=1 / media=2 / desconocido=media; B descarga 1 de 3 y deja actual+principal, progreso
  preservado; C media con 2 cargadas no descarga; D precarga por cercanía (1 en baja; 2 explícitas en
  orden). Evidencia `out/tanda76/preset_baja_m27.log` (sha256 `8d105bfd…`).
- **Regresiones M27:** `test_islas_m27.gd` **171/0** (`f0c6e682…`) y `test_islas_m27_iter2.gd`
  **238/0** (`3f33bd22…`), EXIT 0.
- **Deuda declarada:** `IslandTravelGuard` no se instancia en producción; nadie inyecta el preset ni
  llama `descarga_agresiva_viajeros()` en un viaje real. El mecanismo queda pinneado; el cableado
  runtime es del dueño de M27. Se cierra con el mismo criterio que L132 (mecanismo M62 cerrado, feeds
  de producción como deuda de su módulo).

**Totales tras el cierre:** 136 / 14 / 0 (150 items).

## Tanda 77 — L185 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2046)

**Flip de herencia verificado: el arnés ya estaba implementado por DeepSeek-V4.1-Flash (Log 2033).**

- **Contexto real:** TORMENTA de M32 alcanzada tras 3 días con `GameTime.avanzar_hasta(23,59)` +
  `(0,0)`; `get_clima() == 3` verificado. Escena real `main_island.tscn` con `MemoryMonitor` de
  producción.
- **Inyección honesta:** se fuerza el DENOMINADOR (presupuesto) para que la memoria real caiga en
  85/92/97%; la memoria no se toca. Presupuesto real del preset `media`: 2032 MB.
- **Secuencia observada:** niveles **1 → 2 → 3** con `semaforo_cambiado` 3 veces; enforcement suave
  en 2 y duro en 3 (`_ultimo_enforcement = 3`); sin crash; monitor válido y **Player movible**;
  restauración exacta a 2032 MB y semáforo **0**.
- **Gate:** `sesion_m62_limite.gd` — **14 checks, 0 fallos, EXIT 0** (`out/tanda77/limite_tormenta.log`,
  sha256 `0563a543…`). **Regresión M32:** `test_clima.gd` **29/0** (`out/tanda77/test_clima.log`,
  sha256 `641eee03…`).
- **Alcance declarado:** en `--script` el árbol no itera a 60 Hz (8 physics frames en 10 s), así que
  “sigue jugable” se mide como escena/Player vivos, no como fps. No hay assets de audio en el repo:
  la mitad “banco de audio completo” del ítem 127 sigue fuera de alcance. No es una sesión de juego.

**Totales tras el cierre:** 137 / 13 / 0 (150 items).

## Tanda 78 — L189 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2047)

**Resultado: `[?]` NO MEDIBLE — no se cierra en falso.**

- **Item:** “Baseline menú principal: objetivo < 600 MB [S]”.
- **Bloqueo medido:** `project.godot` tiene `run/main_scene="res://scenes/main_island.tscn"`; no hay
  escena de menú principal. Los 4 candidatos de Log 2033 (`scenes/main_menu.tscn`,
  `ui/main_menu.tscn`, `ui/menu.tscn`, `menu.tscn`) siguen sin existir; el único `*menu*.tscn` es
  `scenes/debug/debug_menu.tscn`.
- **Por qué no se mide `main_island.tscn`:** daría un número de la isla, no del menú; reportarlo como
  baseline del menú sería el falso verde que el proyecto ya tiene documentado. La escena ni siquiera
  es un menú.
- **Estado:** `[?]` con explicación; el dueño del menú (M04/UI) puede cerrarlo cuando exista la escena.
  No se toca `project.godot` ni se crea un menú postizo para “aprobar” el ítem.

**Totales tras el cierre:** 137 / 12 / 1 (150 items).

## Tanda 79 — L190 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2048)

**Resultado: `[x]` — baseline de spawn medido con renderer real.**

- **Item:** “Baseline spawn de Aurora: objetivo < 1.600 MB [S]”.
- **Corrida 1 (arnés de producción, no headless):** `sesion_m62_baselines.gd` con
  `M62_ESCENARIO=spawn`, `M62_ASENTAR_S=15`, `--rendering-driver opengl3`: **149.7 MB static**,
  7307 objetos, 0 huérfanos, **7 checks / 0 fallos / EXIT 0**. El log confirma
  `OpenGL API 3.3.0 Core Profile ... AMD Radeon(TM) Graphics`.
- **Corrida 2 (VRAM):** probe sobre `main_island.tscn` en el mismo renderer, 12 s después de
  instanciar: **static 145.6 MB + VRAM 44.3 MB = 189.9 MB** (texturas 12.2, buffers 32.1);
  7288 objetos. **189.9 MB es el 11.9% del objetivo de 1600 MB.**
- **Por qué cierra:** el objetivo es un techo de 1600 MB y el total estimado queda 8.4x por debajo;
  no hay OOM, no hay huérfanos y la escena es la real (`main_island.tscn`), con el spawn de Aurora.
- **Alcance declarado:** boot automatizado con renderer real y 12–15 s de asentamiento; **no** es una
  sesión manual de juego ni incluye banco de audio completo. La VRAM se lee con
  `Performance.RENDER_VIDEO_MEM_USED`, no con una fórmula paralela.
- **Evidencia:** `out/tanda79/spawn_render.log` (sha256 `b9938516…`) y
  `out/tanda79/probe_vram.log` (sha256 `7ed5c3f5…`).

**Totales tras el cierre:** 138 / 11 / 1 (150 items).

## Tanda 80 — L191 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2051)

**Resultado: `[x]` — baseline de horizonte oteado con renderer real.**

- **Item:** “Baseline horizonte terrestre oteado: objetivo < 2.200 MB [S]”.
- **Arnés, sin `--headless`:** `sesion_m62_baselines.gd`, `M62_ESCENARIO=horizonte`,
  `M62_ASENTAR_S=20`, `--rendering-driver opengl3`: **151.7 MB static**, 7384 objetos, 0 huérfanos,
  **9 checks / 0 fallos / EXIT 0**. Cámara a **20.00 m** del Player (tope de oteo).
- **VRAM:** probe con zoom al tope: **static 148.0 MB + VRAM 44.4 MB = 192.4 MB** (texturas 12.2,
  buffers 32.2), 7293 objetos. **8.7% del objetivo de 2200 MB.**
- **Fix de arnés (solo test):** la cámara resuelve `_target` un `process_frame` después de `_ready`;
  el escenario se aplicaba en el mismo frame. Se espera 1 s antes de aplicar, se fuerza modo EXPLORE y
  se simulan 2 s de `_physics_process` después del scroll (el scroll solo cambia `_distance`; la
  posición converge en física). **No se tocó código de producción.**
- **Regresión:** spawn con el arnés corregido: **144.1 MB static, 7/0 EXIT 0** (124 sigue válido).
- **Evidencia:** `out/tanda80/horizonte_render.log` (sha256 `a714c30e…`),
  `out/tanda80/probe_vram_horizonte.log` (sha256 `398910cc…`),
  `out/tanda80/spawn_render_patch.log` (sha256 `e896ff9e…`).

## Tanda 81 — L192 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2052)

**Resultado: `[?]` — NO MEDIBLE: no existe el templo ni una API de acceso al subterráneo.**

- **Item:** “Baseline subterráneo del templo (M26): objetivo < 2.000 MB [S]”.
- **Búsqueda:** 0 escenas `*templo*`, `*subterr*`, `*cueva*` en `scenes/`; solo scripts de puzzles en
  `scripts/templos/` y referencias de zona (`templo`) en combate/minería. No hay escena de templo que
  cargar ni punto de teleport de producción.
- **Corrida con renderer real:** el arnés baja al Player 40 m en el spawn (Y 6.0 → -34.0); con
  **1 VoxelTerrain y 0 bloques actualizados** el subterráneo no se ejercita: **155.9 MB static,
  7354 objetos, 0 huérfanos, 8 checks / 1 fallo (el escenario no se aplicó por API de producción),
  EXIT 3 (detector ciego)**. Ese número **no** es un baseline del templo y no se usa.
- **Evidencia:** `out/tanda81/subterraneo_render.log` (sha256 `f1ea9c77…`).
- **Cierre:** queda `[?]` hasta que exista la escena/entrada de producción del templo.

**Totales tras Tandas 80-81:** 139 / 9 / 2 (150 items).

## Tanda 82 — L193 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2053)

**Resultado: `[?]` — memoria de tormenta medida; “banco de audio completo” no existe.**

- **Item:** “Baseline tormenta máxima (M32) + banco de audio completo: ≤ 2.500 MB (Alta)”.
- **Tormenta real, renderer OpenGL 3.3:** clima 3 tras 3 días; **157.9 MB static, 7412 objetos,
  0 huérfanos, 8/0 EXIT 0**; 7 buses de audio y 9 reproductores.
- **Banco sintético:** `AudioStreamWAV` de 3 MB (stand-in de T72): memoria 151.9 → **157.9 MB**.
- **VRAM:** probe con tormenta y banco de 3 MB: **static 152.0 + VRAM 44.7 = 196.7 MB**
  (7.9% de 2500 MB), 7322 objetos.
- **Por qué `[?]`:** 0 assets de audio en el repo; `AmbientDirector.set_estado_clima()` (M42) tiene
  0 llamadores, así que el clima no llega al banco de audio real. El sintético mide el mecanismo y el
  techo, **no** el banco completo ni el decoder. Se reabre cuando existan assets/M42.
- **Evidencia:** `out/tanda82/tormenta_audio3_render.log` (sha256 `dd47de0f…`),
  `out/tanda82/probe_vram_tormenta.log` (sha256 `70f7f327…`).

**Totales tras Tanda 82:** 139 / 8 / 3 (150 items).

## Tanda 83 — L213 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2054)

**Resultado: `[x]` por herencia medida de T72 — 30 min sin teleport, drift +0.1%.**

- **Item:** “Test Play Mode: drift-check de 30 min sin teleport con drift ≤ 5% [C]”.
- **Corrida real (T72/L155):** 2026-10-20 02:32:16 → 03:02:16; `main_island.tscn`; **359 muestras**,
  baseline 178.2 MB, **drift +0.1% (máx 0.1%)**, `drift_check()=true`, **0 viajes/teleports**,
  0 huérfanos, 10 cambios de clima, 10 bancos sintéticos (1 vivo), **EXIT 0**.
- **Evidencia:** `out/tanda72/sesion_audio_30min.log` (231 KB) y `.csv` (12.6 KB).
- **Alcance:** es un arnés `SceneTree --script`, no el Play Mode del editor, y no hay input de jugador.
  La corrida es de reloj de pared (30 min reales) y agrega clima cambiante; el caso “sin teleport” está
  cubierto (0 viajes). No se re-ejecutan 30 min para no duplicar una corrida ya válida.

**Totales tras Tanda 83:** 140 / 7 / 3 (150 items).

## Tanda 84 — L215 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2055)

**Resultado: `[x]` — cambio de bioma de audio sin crecimiento.**

- **Suite directa:** `test_m62_audio_bioma.gd` con el autoload real `MemoryMonitor`: **45 checks, 0 fallos,
  EXIT 0**. Entrar/salir de bioma pide y descarga el banco; el cambio de región fuerza la descarga; el
  banco EN CARGA se veta y no se pierde; 3 ciclos de viaje sin acumulación; **0 bancos sobrevivientes
  (WeakRef)**; `objetos_vivos()` **4477 → 4477 (delta 0)**; cola vacía y drenaje final en un lote.
- **Corrida de 30 min (T72):** 10 bancos sintéticos creados, **1 vivo**, memoria 178.2 → 178.4 MB,
  drift +0.1%, EXIT 0. Aporta la estabilidad de memoria que la suite corta no mide en MB.
- **Evidencia:** `out/tanda84/audio_bioma.log` (sha256 `E54AB45D52A3B095FD8E3C27F7CB578FED2EF21BC7AAE5CCA658BE6DAE3598A5`).
- **Alcance:** `SceneTree --script`, no editor Play Mode; no hay assets reales (bancos `Resource` sintéticos).
  M42 sigue con 0 llamadores de `set_estado_clima`; el cableado de producción es deuda de M42.

**Totales tras Tanda 84:** 141 / 6 / 3 (150 items).

## Tanda 85 — L216 (2026-10-20, DS-V4.1-Flash-Opencode / OpenCode, Log 2056)

**Resultado: `[x]` — 500 excavaciones + 500 regeneraciones sin buffers retenidos.**

- **Corrida verde:** `sesion_m62_voxel_500.gd` sobre `main_island.tscn` (headless, autoload real):
  **9 checks, 0 fallos, EXIT 0**; 500 posiciones sólidas; **500/500 excavadas leídas como AIRE**;
  **500/500 regeneradas** con el ID original; **5 buffers creados, 0 vivos**; memoria **137.3 → 137.3 MB
  (delta +0.0%)**; objetos **7408 → 7413 (+5)**; **0 huérfanos**.
- **Sonda roja:** `M62_RETENER_BUFFERS=1` → 5 buffers vivos y `[FALLO] 0 buffers temporales retenidos`,
  **EXIT 1**. El gate no es decorativo: detecta la fuga deliberada.
- **Evidencia:** `out/tanda85/voxel_500.log` y `out/tanda85/voxel_500_rojo.log`.
- **Alcance:** el VoxelTerrain headless reporta 0 bloques actualizados; el arnés ejercita `VoxelBuffer` real
  (mismo tipo/API que `farm_service.gd`), no el terreno renderizado ni el Play Mode del editor.

**Totales tras Tanda 85:** 142 / 5 / 3 (150 items).
