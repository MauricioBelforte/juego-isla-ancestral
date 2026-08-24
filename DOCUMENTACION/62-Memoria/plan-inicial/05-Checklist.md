**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 62: Memoria

## A. Problema y objetivos

- [ ] Definir el problema: memoria creciente por chunks, señales, texturas y audio sin descarga en mundo voxel cozy [S]
- [ ] Registrar dependencias: M61 (rendimiento), M08 (voxel), M63 (streaming); relaciones M41-M44, M12, M90, M103, M110 [S]
- [ ] Definir el objetivo: RAM predecible y estable, sin leaks y sin picos de frame en hardware medio/bajo [S]
- [ ] Definir el alcance: monitoreo, presupuestos, pooling, prevención de leaks y políticas de descarga [S]
- [ ] Fijar la prioridad del módulo: Alta (la memoria condiciona a todos los demás sistemas) [S]

## B. RF1 — Monitoreo y diagnóstico

- [ ] Autoload MemoryMonitor como único dueño del estado global de memoria [M]
- [ ] Muestreo periódico: cada 5 s en calma y cada 1 s con movimiento de cámara [M]
- [ ] Lectura de `OS.get_static_memory_usage()` para memoria del motor [S]
- [ ] Lectura de `OS.get_static_memory_peak_usage()` para el pico máximo [S]
- [ ] Lectura de `Performance.PERFORMANCE_OBJECT_COUNT` para conteo de objetos vivos [S]
- [ ] Lectura de `Performance.PERFORMANCE_ORPHAN_NODE_COUNT` para nodos huérfanos [S]
- [ ] Lectura de `Performance.PERFORMANCE_MEMORY_STATIC` para memoria estática [S]
- [ ] Contadores propios por sistema del juego (voxel, audio, texturas, escenas, pools) [C]
- [ ] Costo de muestreo < 0.1 ms de media (no viola frame budgets de M61) [M]
- [ ] Getters puros para el resto de módulos: consumo, presupuesto, semáforo, drift [S]
- [ ] Detección de drift: comparación contra baseline estabilizada a los 5 minutos [M]
- [ ] Registro del pico de memoria por sesión y por punto de interés (spawn, teleport, escena) [M]
- [ ] Alarma ante pico > 200 MB en un solo frame (registro y análisis) [M]
- [ ] Exportar reportes al log rotado (M103) sin afectar el gameplay [S]
- [ ] Estado de memoria accesible para el panel del Debug Menu (M110) [M]

## C. RF2 — Presupuestos por sistema

- [ ] Tabla de presupuestos en `budgets.tres` con topes por sistema [S]
- [ ] Presupuesto voxel: 800 MB en preset Alta (buffers, meshes, colliders, pool) [M]
- [ ] Presupuesto texturas/atlas: 400 MB en preset Alta [S]
- [ ] Presupuesto audio (M41-M44): 250 MB en preset Alta [S]
- [ ] Presupuesto escenas/NPCs/objetos: 350 MB en preset Alta [S]
- [ ] Presupuesto pooling global: 200 MB en preset Alta [S]
- [ ] Presupuesto UI y fuentes: 100 MB en preset Alta [S]
- [ ] Presupuesto shaders/materiales: 100 MB en preset Alta [M]
- [ ] Reserva del sistema: 300 MB para cerrar el total de 2.5 GB (Alta) [S]
- [ ] Presets por calidad M90: Baja 1.5 GB, Media 2.0 GB, Alta 2.5 GB [M]
- [ ] Verificación periódica: `verificar()` devuelve los sistemas sobre su tope [M]
- [ ] Enforcement suave al 90%: medidas de descarga automáticas ordenadas [M]
- [ ] Enforcement duro al 95%: descarga forzada de recursos de menor prioridad sin excepción [M]
- [ ] La suma de topes por preset es fija: ningún sistema crece sin bajar otro (check en tests) [M]

## D. RF3 — Pooling global

- [ ] Servicio GlobalPool autoload con piscinas tipadas por familia [M]
- [ ] Familia `audio_voz`: voces del pool de M43 reutilizadas sin instanciar de nuevo [S]
- [ ] Familia `particula`: efectos de clima, herramientas y esporas de luz (M11/M32) [M]
- [ ] Familia `mesh_chunk`: meshes de chunks voxel reutilizados sin allocs por frame [C]
- [ ] Familia `objeto_recogible`: objetos lanzados o dropeados (M15) [M]
- [ ] Familia `texto_efimero`: textos flotantes y notificaciones UI (M53) [S]
- [ ] Familia `npc_temporal`: NPCs de visita o eventos con reinicio de estado limpio [C]
- [ ] API única: `obtener()`, `devolver()`, `precalentar()`, `limite()`, `tamanio()` [M]
- [ ] Precalentamiento al arrancar y en pantalla de carga (M63), nunca en mitad de gameplay [M]
- [ ] Límite por familia configurable en `pool_config.tres` [S]
- [ ] Fallback honesto: si el pool está lleno se usa `queue_free()` en vez de crecer sin tope [S]
- [ ] Ítems devueltos: invisibles, quietos, sin señales activas y sin referencias externas [M]
- [ ] Contadores por familia expuestos al MemoryMonitor [S]
- [ ] Test de integridad: un ítem devuelto al pool no retiene referencias externas [C]

## E. RF4 — Prevención de leaks

- [ ] Auditoría de señales: todo `connect()` se desconecta explícitamente al liberar el nodo [M]
- [ ] Regla: prohibido conectar señales a lambdas que capturen nodos externos sin limpieza [M]
- [ ] Patrón de desconexión central en `_exit_tree()` documentado para todos los módulos [S]
- [ ] Timers cancelados en `_exit_tree()` de cada nodo que los posea [S]
- [ ] Tweens cancelados en `_exit_tree()` (evita callables repetitivos que retienen) [S]
- [ ] Prohibido crear Node sin padre que quede huérfano; chequeo con contador de orphans [S]
- [ ] Policy de recursos compartidos: `duplicate(false)` y caché con un solo dueño (D6) [M]
- [ ] Texturas de región se liberan al salir de la misma (con M63 y M09) [M]
- [ ] Los datos de partida (M29) no retienen referencias a nodos del mundo [M]
- [ ] Partículas y audio se detienen y devuelven al pool al desactivar la fuente [M]
- [ ] Los callables con bound parameters se desconectan en `_exit_tree` (anti-leak de lambdas) [M]
- [ ] Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares) [C]
- [ ] Sesión de referencia: 30 min de juego sin drift > 5% sobre la línea base [C]
- [ ] Test de leaks con teleport ×10 y conteo de objetos antes/después (debe ser igual) [C]

## F. RN — Requisitos no funcionales

- [ ] RN1: presupuesto de RAM objetivo ≤ 2.5 GB en PCs de gama media (preset Alta) [M]
- [ ] RN1: preset Baja ≤ 1.5 GB para gama baja con 4 GB de RAM [M]
- [ ] RN2: sin picos de frame: deltas < 50 ms durante descargas o liberaciones [M]
- [ ] RN2: cero hitching perceptible por refcount en liberaciones masivas [C]
- [ ] RN3: memoria estable: sesión de 30 min con drift < 5% sobre baseline [C]
- [ ] RN4: topes configurables desde `budgets.tres` sin recompilar [S]
- [ ] RN5: implementación 100% Godot 4.x + GDScript, sin C# ni plugins externos [S]
- [ ] RN6: ninguna operación de memoria bloquea el hilo principal [M]
- [ ] RN9: la gestión de memoria es transparente para la partida (determinismo intacto) [S]

## G. Diseño de arquitectura

- [ ] MemoryMonitor autoload como único dueño del estado global de memoria [S]
- [ ] BudgetRegistry: presupuestos por sistema con verificación por tick [M]
- [ ] GlobalPool desacoplado del gameplay (servicio puro) [M]
- [ ] UnloadPolicy: orden de descarga por distancia > edad > peso [C]
- [ ] Separación de responsabilidades: los managers reportan, no tocan memoria ajena [S]
- [ ] Flujo muestreo → semáforo → política de acción (warning/crítico/emergencia) [M]
- [ ] Flujo de arranque: precalentar pools primero, después cargar mundo (M63) [M]
- [ ] Flujo de cambio de escena: drenar pools, cancelar timers/tweens, descargar recursos [C]
- [ ] Flujo de salida de chunks: LRU → anunciar handshake → liberar escalonado → pool [C]
- [ ] Degradación graceful al 90%: LOD de lejanos, pools mínimos, evicción de atlas [M]
- [ ] Descarga dura al 95%: atlas fuera de pantalla y bancos de biomas viajeros [M]
- [ ] Toda decisión de descarga queda registrada en log (M103) para análisis [S]

## H. Integración con M08 (mundo voxel)

- [ ] Buffers de VoxelTools por chunk se liberan al descargar (sin acumulación) [C]
- [ ] Meshes de chunks van al pool `mesh_chunk` y se reutilizan sin nuevos allocs [C]
- [ ] Colliders estáticos de chunks descargados se liberan junto con la mesh [M]
- [ ] Sin duplicación de meshes entre M63 (streaming) y el 62 (descarga) [M]
- [ ] Generación de mallas en hilos (M08): resultados por cola sin copias extra [C]
- [ ] Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM [M]
- [ ] Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos [M]
- [ ] Teleport extremo ×10 y vuelta al spawn deja la memoria en el mismo nivel (test) [C]
- [ ] El pool de chunks se ajusta al presupuesto voxel declarado (800 MB Alta) [M]

## I. Integración con M41-M44 (audio)

- [ ] Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región [M]
- [ ] Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa [C]
- [ ] Voces del pool M43 con tope duro: si se llena, se corta la voz más antigua (nunca crece) [S]
- [ ] Streams `.ogg` liberados de caché cuando ningún reproductor los usa [M]
- [ ] Los buses (M91) no retienen streams detenidos [S]
- [ ] Cambio de bioma: descarga del banco anterior diferida 1 frame (no corta transiciones) [M]
- [ ] Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio [C]

## J. Integración con M61 y M63

- [ ] Leer los presupuestos definitivos de M61 antes de fijar los topes duros del 62 [S]
- [ ] Los topes de RAM del 62 respetan los frame budgets del 61 (deltas < 50 ms) [M]
- [ ] La cola de streaming (M63) informa cargas/descargas al MemoryMonitor [M]
- [ ] LRU compartido: el 63 decide qué cargar, el 62 decide qué liberar (handshake) [C]
- [ ] Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueño) [M]
- [ ] La pantalla de carga (M63) precarga pools sin duplicarlos al terminar [M]
- [ ] El 62 nunca descarga un recurso que esté en la cola de carga del 63 (evento cancel) [C]
- [ ] Teleport (M69/M28): drift-check obligatorio tras cada viaje largo [M]
- [ ] NO tocar la carpeta 61 (en curso por otro agente): solo consumir sus entregables [S]

## K. Edge cases

- [ ] Textura gigante (4K simple sin mips): detector la identifica y degrada calidad automáticamente [M]
- [ ] Atlas lleno: política de evicción por orden de uso con log del evento [C]
- [ ] Chunk sin descargar tras cambio rápido de región: el monitor lo detecta y fuerza liberación [M]
- [ ] Chunk liberado mientras el jugador lo edita (M08): regeneración segura sin doble free [C]
- [ ] Audio acumulado por bug: cientos de voces creadas: tope duro del pool + log inmediato [M]
- [ ] Banco de audio pedido mientras se descarga: reproducción diferida o silenciada graceful [M]
- [ ] Escena cambiada dos veces antes de terminar la transición: cola evita doble descarga [C]
- [ ] Cambio de escena con streaming activo: cancelación limpia sin recursos colgados [C]
- [ ] Cercanía de OOM del sistema: degradación máxima (LOD bajo, pools mínimos) sin crash [C]
- [ ] Preset Baja en isla pequeña (M27): carga priorizada y descarga agresiva de viajeros [M]
- [ ] Partículas infinitas por bug: límite de vida y devolución al pool garantizadas [S]
- [ ] Tween sin fin en UI: auto-detención en `_exit_tree` [S]
- [ ] Nieve/niebla (M32) que crea nodos por frame: detector de nodos por frame con alerta [M]
- [ ] Minimapa (M11) regenerando textura cada frame: reutilización de imagen destino sin alloc [C]
- [ ] Memoria al límite durante tormenta máxima: degrada con aviso y el juego sigue jugable [M]

## L. Optimización y mediciones

- [ ] Baseline menú principal: objetivo < 600 MB [S]
- [ ] Baseline spawn de Aurora: objetivo < 1.600 MB [S]
- [ ] Baseline horizonte terrestre oteado: objetivo < 2.200 MB [S]
- [ ] Baseline subterráneo del templo (M26): objetivo < 2.000 MB [S]
- [ ] Baseline tormenta máxima (M32) + banco de audio completo: ≤ 2.500 MB (Alta) [S]
- [ ] Profiling: identificar top de allocs por frame en hot paths [M]
- [ ] Cero allocs deliberados en `_process`/`_physics_process` del gameplay [C]
- [ ] Uso de arrays tipados y `Packed*Array` donde el tamaño es fijo [M]
- [ ] Evitar `duplicate()`, `instantiate()` y `load()` síncrono en gameplay [M]
- [ ] Pico de liberación por refcount < 3 ms al descargar una región completa [C]

## M. Documentación

- [ ] Documentar la arquitectura en plan-actual/03-Diseno.md [S]
- [ ] Documentar la API pública con XML docs GDScript (`##`) en todos los scripts [S]
- [ ] Registrar los edge cases y sus soluciones en plan-actual/04-Codigo.md [S]
- [ ] Tabla de presupuestos documentada con su justificación por sistema [S]
- [ ] Notas del Agente firmadas con modelo, plataforma y fecha en 04-Codigo.md [S]

## N. Testings

- [ ] Test unitario del BudgetRegistry: suma de topes == total del preset, sin negativos [M]
- [ ] Test unitario del GlobalPool: obtener, devolver, precalentar y límite de pool [M]
- [ ] Test unitario del UnloadPolicy: elección correcta del recurso a liberar (LRU/distancia) [C]
- [ ] Test Play Mode: drift-check de 30 min sin teleport con drift ≤ 5% [C]
- [ ] Test Play Mode: teleport extremo ×10 con memoria estable y sin picos [C]
- [ ] Test Play Mode: cambio de bioma de audio sin crecimiento de memoria [M]
- [ ] Test Play Mode: excavar y regenerar 500 bloques sin leaks de buffers voxel [C]
- [ ] Test Play Mode: máximo de chunks cargados sin superar el presupuesto voxel [M]
- [ ] Test Play Mode: textura gigante forzada degrada sin crash [M]
- [ ] Test de semáforos: forzar 90% y verificar descargas automáticas y registro en log [C]
- [ ] Test de nodos huérfanos: conteo de orphans en reposo con valor estable [M]
- [ ] Test en preset Baja con 4 GB de RAM: sesión completa sin OOM y jugable [C]