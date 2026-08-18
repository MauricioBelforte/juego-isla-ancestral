**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 62: Memoria

## A. Problema y objetivos

- [x] Definir el problema: memoria creciente por chunks, señales, texturas y audio sin descarga en mundo voxel cozy [S]
- [x] Registrar dependencias: M61 (rendimiento), M08 (voxel), M63 (streaming); relaciones M41-M44, M12, M90, M103, M110 [S]
- [x] Definir el objetivo: RAM predecible y estable, sin leaks y sin picos de frame en hardware medio/bajo [S]
- [x] Definir el alcance: monitoreo, presupuestos, pooling, prevención de leaks y políticas de descarga [S]
- [x] Fijar la prioridad del módulo: Alta (la memoria condiciona a todos los demás sistemas) [S]

## B. RF1 — Monitoreo y diagnóstico

- [x] Autoload MemoryMonitor como único dueño del estado global de memoria [M]
- [x] Muestreo periódico: cada 5 s en calma y cada 1 s con movimiento de cámara [M]
- [x] Lectura de `OS.get_static_memory_usage()` para memoria del motor [S]
- [x] Lectura de `OS.get_static_memory_peak_usage()` para el pico máximo [S]
- [x] Lectura de `Performance.PERFORMANCE_OBJECT_COUNT` para conteo de objetos vivos [S]
- [x] Lectura de `Performance.PERFORMANCE_ORPHAN_NODE_COUNT` para nodos huérfanos [S]
- [x] Lectura de `Performance.PERFORMANCE_MEMORY_STATIC` para memoria estática [S]
- [x] Contadores propios por sistema del juego (voxel, audio, texturas, escenas, pools) [C]
- [x] Costo de muestreo < 0.1 ms de media (no viola frame budgets de M61) [M]
- [x] Getters puros para el resto de módulos: consumo, presupuesto, semáforo, drift [S]
- [x] Detección de drift: comparación contra baseline estabilizada a los 5 minutos [M]
- [x] Registro del pico de memoria por sesión y por punto de interés (spawn, teleport, escena) [M]
- [x] Alarma ante pico > 200 MB en un solo frame (registro y análisis) [M]
- [x] Exportar reportes al log rotado (M103) sin afectar el gameplay [S]
- [x] Estado de memoria accesible para el panel del Debug Menu (M110) [M]

## C. RF2 — Presupuestos por sistema

- [x] Tabla de presupuestos en `budgets.tres` con topes por sistema [S]
- [x] Presupuesto voxel: 800 MB en preset Alta (buffers, meshes, colliders, pool) [M]
- [x] Presupuesto texturas/atlas: 400 MB en preset Alta [S]
- [x] Presupuesto audio (M41-M44): 250 MB en preset Alta [S]
- [x] Presupuesto escenas/NPCs/objetos: 350 MB en preset Alta [S]
- [x] Presupuesto pooling global: 200 MB en preset Alta [S]
- [x] Presupuesto UI y fuentes: 100 MB en preset Alta [S]
- [x] Presupuesto shaders/materiales: 100 MB en preset Alta [M]
- [x] Reserva del sistema: 300 MB para cerrar el total de 2.5 GB (Alta) [S]
- [x] Presets por calidad M90: Baja 1.5 GB, Media 2.0 GB, Alta 2.5 GB [M]
- [x] Verificación periódica: `verificar()` devuelve los sistemas sobre su tope [M]
- [x] Enforcement suave al 90%: medidas de descarga automáticas ordenadas [M]
- [x] Enforcement duro al 95%: descarga forzada de recursos de menor prioridad sin excepción [M]
- [x] La suma de topes por preset es fija: ningún sistema crece sin bajar otro (check en tests) [M]

## D. RF3 — Pooling global

- [x] Servicio GlobalPool autoload con piscinas tipadas por familia [M]
- [x] Familia `audio_voz`: voces del pool de M43 reutilizadas sin instanciar de nuevo [S]
- [x] Familia `particula`: efectos de clima, herramientas y esporas de luz (M11/M32) [M]
- [x] Familia `mesh_chunk`: meshes de chunks voxel reutilizados sin allocs por frame [C]
- [x] Familia `objeto_recogible`: objetos lanzados o dropeados (M15) [M]
- [x] Familia `texto_efimero`: textos flotantes y notificaciones UI (M53) [S]
- [x] Familia `npc_temporal`: NPCs de visita o eventos con reinicio de estado limpio [C]
- [x] API única: `obtener()`, `devolver()`, `precalentar()`, `limite()`, `tamanio()` [M]
- [x] Precalentamiento al arrancar y en pantalla de carga (M63), nunca en mitad de gameplay [M]
- [x] Límite por familia configurable en `pool_config.tres` [S]
- [x] Fallback honesto: si el pool está lleno se usa `queue_free()` en vez de crecer sin tope [S]
- [x] Ítems devueltos: invisibles, quietos, sin señales activas y sin referencias externas [M]
- [x] Contadores por familia expuestos al MemoryMonitor [S]
- [x] Test de integridad: un ítem devuelto al pool no retiene referencias externas [C]

## E. RF4 — Prevención de leaks

- [x] Auditoría de señales: todo `connect()` se desconecta explícitamente al liberar el nodo [M]
- [x] Regla: prohibido conectar señales a lambdas que capturen nodos externos sin limpieza [M]
- [x] Patrón de desconexión central en `_exit_tree()` documentado para todos los módulos [S]
- [x] Timers cancelados en `_exit_tree()` de cada nodo que los posea [S]
- [x] Tweens cancelados en `_exit_tree()` (evita callables repetitivos que retienen) [S]
- [x] Prohibido crear Node sin padre que quede huérfano; chequeo con contador de orphans [S]
- [x] Policy de recursos compartidos: `duplicate(false)` y caché con un solo dueño (D6) [M]
- [x] Texturas de región se liberan al salir de la misma (con M63 y M09) [M]
- [x] Los datos de partida (M29) no retienen referencias a nodos del mundo [M]
- [x] Partículas y audio se detienen y devuelven al pool al desactivar la fuente [M]
- [x] Los callables con bound parameters se desconectan en `_exit_tree` (anti-leak de lambdas) [M]
- [x] Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares) [C]
- [x] Sesión de referencia: 30 min de juego sin drift > 5% sobre la línea base [C]
- [x] Test de leaks con teleport ×10 y conteo de objetos antes/después (debe ser igual) [C]

## F. RN — Requisitos no funcionales

- [x] RN1: presupuesto de RAM objetivo ≤ 2.5 GB en PCs de gama media (preset Alta) [M]
- [x] RN1: preset Baja ≤ 1.5 GB para gama baja con 4 GB de RAM [M]
- [x] RN2: sin picos de frame: deltas < 50 ms durante descargas o liberaciones [M]
- [x] RN2: cero hitching perceptible por refcount en liberaciones masivas [C]
- [x] RN3: memoria estable: sesión de 30 min con drift < 5% sobre baseline [C]
- [x] RN4: topes configurables desde `budgets.tres` sin recompilar [S]
- [x] RN5: implementación 100% Godot 4.x + GDScript, sin C# ni plugins externos [S]
- [x] RN6: ninguna operación de memoria bloquea el hilo principal [M]
- [x] RN9: la gestión de memoria es transparente para la partida (determinismo intacto) [S]

## G. Diseño de arquitectura

- [x] MemoryMonitor autoload como único dueño del estado global de memoria [S]
- [x] BudgetRegistry: presupuestos por sistema con verificación por tick [M]
- [x] GlobalPool desacoplado del gameplay (servicio puro) [M]
- [x] UnloadPolicy: orden de descarga por distancia > edad > peso [C]
- [x] Separación de responsabilidades: los managers reportan, no tocan memoria ajena [S]
- [x] Flujo muestreo → semáforo → política de acción (warning/crítico/emergencia) [M]
- [x] Flujo de arranque: precalentar pools primero, después cargar mundo (M63) [M]
- [x] Flujo de cambio de escena: drenar pools, cancelar timers/tweens, descargar recursos [C]
- [x] Flujo de salida de chunks: LRU → anunciar handshake → liberar escalonado → pool [C]
- [x] Degradación graceful al 90%: LOD de lejanos, pools mínimos, evicción de atlas [M]
- [x] Descarga dura al 95%: atlas fuera de pantalla y bancos de biomas viajeros [M]
- [x] Toda decisión de descarga queda registrada en log (M103) para análisis [S]

## H. Integración con M08 (mundo voxel)

- [x] Buffers de VoxelTools por chunk se liberan al descargar (sin acumulación) [C]
- [x] Meshes de chunks van al pool `mesh_chunk` y se reutilizan sin nuevos allocs [C]
- [x] Colliders estáticos de chunks descargados se liberan junto con la mesh [M]
- [x] Sin duplicación de meshes entre M63 (streaming) y el 62 (descarga) [M]
- [x] Generación de mallas en hilos (M08): resultados por cola sin copias extra [C]
- [x] Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM [M]
- [x] Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos [M]
- [x] Teleport extremo ×10 y vuelta al spawn deja la memoria en el mismo nivel (test) [C]
- [x] El pool de chunks se ajusta al presupuesto voxel declarado (800 MB Alta) [M]

## I. Integración con M41-M44 (audio)

- [x] Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región [M]
- [x] Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa [C]
- [x] Voces del pool M43 con tope duro: si se llena, se corta la voz más antigua (nunca crece) [S]
- [x] Streams `.ogg` liberados de caché cuando ningún reproductor los usa [M]
- [x] Los buses (M91) no retienen streams detenidos [S]
- [x] Cambio de bioma: descarga del banco anterior diferida 1 frame (no corta transiciones) [M]
- [x] Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio [C]

## J. Integración con M61 y M63

- [x] Leer los presupuestos definitivos de M61 antes de fijar los topes duros del 62 [S]
- [x] Los topes de RAM del 62 respetan los frame budgets del 61 (deltas < 50 ms) [M]
- [x] La cola de streaming (M63) informa cargas/descargas al MemoryMonitor [M]
- [x] LRU compartido: el 63 decide qué cargar, el 62 decide qué liberar (handshake) [C]
- [x] Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueño) [M]
- [x] La pantalla de carga (M63) precarga pools sin duplicarlos al terminar [M]
- [x] El 62 nunca descarga un recurso que esté en la cola de carga del 63 (evento cancel) [C]
- [x] Teleport (M69/M28): drift-check obligatorio tras cada viaje largo [M]
- [x] NO tocar la carpeta 61 (en curso por otro agente): solo consumir sus entregables [S]

## K. Edge cases

- [x] Textura gigante (4K simple sin mips): detector la identifica y degrada calidad automáticamente [M]
- [x] Atlas lleno: política de evicción por orden de uso con log del evento [C]
- [x] Chunk sin descargar tras cambio rápido de región: el monitor lo detecta y fuerza liberación [M]
- [x] Chunk liberado mientras el jugador lo edita (M08): regeneración segura sin doble free [C]
- [x] Audio acumulado por bug: cientos de voces creadas: tope duro del pool + log inmediato [M]
- [x] Banco de audio pedido mientras se descarga: reproducción diferida o silenciada graceful [M]
- [x] Escena cambiada dos veces antes de terminar la transición: cola evita doble descarga [C]
- [x] Cambio de escena con streaming activo: cancelación limpia sin recursos colgados [C]
- [x] Cercanía de OOM del sistema: degradación máxima (LOD bajo, pools mínimos) sin crash [C]
- [x] Preset Baja en isla pequeña (M27): carga priorizada y descarga agresiva de viajeros [M]
- [x] Partículas infinitas por bug: límite de vida y devolución al pool garantizadas [S]
- [x] Tween sin fin en UI: auto-detención en `_exit_tree` [S]
- [x] Nieve/niebla (M32) que crea nodos por frame: detector de nodos por frame con alerta [M]
- [x] Minimapa (M11) regenerando textura cada frame: reutilización de imagen destino sin alloc [C]
- [x] Memoria al límite durante tormenta máxima: degrada con aviso y el juego sigue jugable [M]

## L. Optimización y mediciones

- [x] Baseline menú principal: objetivo < 600 MB [S]
- [x] Baseline spawn de Aurora: objetivo < 1.600 MB [S]
- [x] Baseline horizonte terrestre oteado: objetivo < 2.200 MB [S]
- [x] Baseline subterráneo del templo (M26): objetivo < 2.000 MB [S]
- [x] Baseline tormenta máxima (M32) + banco de audio completo: ≤ 2.500 MB (Alta) [S]
- [x] Profiling: identificar top de allocs por frame en hot paths [M]
- [x] Cero allocs deliberados en `_process`/`_physics_process` del gameplay [C]
- [x] Uso de arrays tipados y `Packed*Array` donde el tamaño es fijo [M]
- [x] Evitar `duplicate()`, `instantiate()` y `load()` síncrono en gameplay [M]
- [x] Pico de liberación por refcount < 3 ms al descargar una región completa [C]

## M. Documentación

- [x] Documentar la arquitectura en plan-actual/03-Diseno.md [S]
- [x] Documentar la API pública con XML docs GDScript (`##`) en todos los scripts [S]
- [x] Registrar los edge cases y sus soluciones en plan-actual/04-Codigo.md [S]
- [x] Tabla de presupuestos documentada con su justificación por sistema [S]
- [x] Notas del Agente firmadas con modelo, plataforma y fecha en 04-Codigo.md [S]

## N. Testings

- [x] Test unitario del BudgetRegistry: suma de topes == total del preset, sin negativos [M]
- [x] Test unitario del GlobalPool: obtener, devolver, precalentar y límite de pool [M]
- [x] Test unitario del UnloadPolicy: elección correcta del recurso a liberar (LRU/distancia) [C]
- [x] Test Play Mode: drift-check de 30 min sin teleport con drift ≤ 5% [C]
- [x] Test Play Mode: teleport extremo ×10 con memoria estable y sin picos [C]
- [x] Test Play Mode: cambio de bioma de audio sin crecimiento de memoria [M]
- [x] Test Play Mode: excavar y regenerar 500 bloques sin leaks de buffers voxel [C]
- [x] Test Play Mode: máximo de chunks cargados sin superar el presupuesto voxel [M]
- [x] Test Play Mode: textura gigante forzada degrada sin crash [M]
- [x] Test de semáforos: forzar 90% y verificar descargas automáticas y registro en log [C]
- [x] Test de nodos huérfanos: conteo de orphans en reposo con valor estable [M]
- [x] Test en preset Baja con 4 GB de RAM: sesión completa sin OOM y jugable [C]