**Modelo:** DeepSeek-V4.1-Flash (último modificador)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-19 (iter. 3 — Log 1094)

# 05-Checklist.md — Módulo 62: Memoria

## Reserva actual

- Estado: 🟢 En curso — iter. 3 (Log 1094) por DeepSeek-V4.1-Flash
- Agente: DeepSeek-V4.1-Flash (WorkBuddy)
- Fase: Base de producción (soporte M61 Rendimiento)
- Dificultad: 3
- Visión: V0
- Entrada: M61 🟡 (núcleo OK, presupuestos base)
- Salida: 5 defectos reales corregidos (denominador del semáforo, enforcement, muestreo por frame, drift/baseline a 5 min, pico por punto de interés) + `PoolFactory` + `LeakGuard` + `TextureMemory` + dataset regenerado por `generar_budgets.gd` + 4 suites con guardián probado por inyección (232 checks) + gate de CI en `quality.yml`
- Archivos: `game/isla-ancestral/scripts/rendimiento/memoria/` + `data/rendimiento/budgets.json`
- Fecha cierre: (pendiente — al cerrar con `--estado`)

### Historial de reservas
- **iter. 1** (núcleo): deepseek-v4-flash / Kilo Code — 2026-09-01 19:50 (Log 390), liberado 🟡
- **iter. 2** (enforcement + pool): glm-5.3-flash / Kilo Code — 2026-09-01/03 (Log 604), liberado 🟡
- **iter. 3**: DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-19 (Log 1094)

## A. Problema y objetivos

- [ ] Definir el problema: memoria creciente por chunks, señales, texturas y audio sin descarga en mundo voxel cozy [S]
- [ ] Registrar dependencias: M61 (rendimiento), M08 (voxel), M63 (streaming); relaciones M41-M44, M12, M90, M103, M110 [S]
- [ ] Definir el objetivo: RAM predecible y estable, sin leaks y sin picos de frame en hardware medio/bajo [S]
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
- [ ] Los datos de partida (M29) no retienen referencias a nodos del mundo [M]
- [x] Partículas y audio se detienen y devuelven al pool al desactivar la fuente [M]
- [x] Los callables con bound parameters se desconectan en `_exit_tree` (anti-leak de lambdas) [M] — Log 1094: `LeakGuard.conectar()` guarda el Callable EXACTO (incluido el `.bind()`), así el disconnect funciona; probado
- [ ] Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares) [C]
- [ ] Sesión de referencia: 30 min de juego sin drift > 5% sobre la línea base [C]
- [ ] Test de leaks con teleport ×10 y conteo de objetos antes/después (debe ser igual) [C]

## F. RN — Requisitos no funcionales

- [ ] RN1: presupuesto de RAM objetivo ≤ 2.5 GB en PCs de gama media (preset Alta) [M]
- [ ] RN1: preset Baja ≤ 1.5 GB para gama baja con 4 GB de RAM [M]
- [ ] RN2: sin picos de frame: deltas < 50 ms durante descargas o liberaciones [M]
- [ ] RN2: cero hitching perceptible por refcount en liberaciones masivas [C]
- [ ] RN3: memoria estable: sesión de 30 min con drift < 5% sobre baseline [C]
- [x] RN4: topes configurables desde `budgets.tres` sin recompilar [S]
- [x] RN5: implementación 100% Godot 4.x + GDScript, sin C# ni plugins externos [S]
- [ ] RN6: ninguna operación de memoria bloquea el hilo principal [M]
- [ ] RN9: la gestión de memoria es transparente para la partida (determinismo intacto) [S]

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
- [ ] Teleport extremo ×10 y vuelta al spawn deja la memoria en el mismo nivel (test) [C]
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
- [ ] LRU compartido: el 63 decide qué cargar, el 62 decide qué liberar (handshake) [C]
- [ ] Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueño) [M]
- [x] La pantalla de carga (M63) precarga pools sin duplicarlos al terminar [M]
- [ ] El 62 nunca descarga un recurso que esté en la cola de carga del 63 (evento cancel) [C]
- [ ] Teleport (M69/M28): drift-check obligatorio tras cada viaje largo [M]
- [ ] NO tocar la carpeta 61 (en curso por otro agente): solo consumir sus entregables [S]

## K. Edge cases

- [x] Textura gigante (4K simple sin mips): detector la identifica y degrada calidad automáticamente [M] — Log 1094: `TextureMemory.requiere_degradacion()` + `degradar()` (resize + mips); probado
- [ ] Atlas lleno: política de evicción por orden de uso con log del evento [C]
- [ ] Chunk sin descargar tras cambio rápido de región: el monitor lo detecta y fuerza liberación [M]
- [x] Chunk liberado mientras el jugador lo edita (M08): regeneración segura sin doble free [C]
- [x] Audio acumulado por bug: cientos de voces creadas: tope duro del pool + log inmediato [M]
- [ ] Banco de audio pedido mientras se descarga: reproducción diferida o silenciada graceful [M]
- [ ] Escena cambiada dos veces antes de terminar la transición: cola evita doble descarga [C]
- [ ] Cambio de escena con streaming activo: cancelación limpia sin recursos colgados [C]
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
- [ ] Evitar `duplicate()`, `instantiate()` y `load()` síncrono en gameplay [M]
- [ ] Pico de liberación por refcount < 3 ms al descargar una región completa [C]

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
- [ ] Test de nodos huérfanos: conteo de orphans en reposo con valor estable [M]
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
