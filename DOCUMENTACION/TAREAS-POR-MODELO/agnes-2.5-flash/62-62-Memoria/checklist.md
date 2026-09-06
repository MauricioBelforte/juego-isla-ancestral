# Tareas módulo 62 62-Memoria

**Estado:** 🟡 Liberado (iter. 2 GlobalPool)

**Items pendientes:** 91

[ ] T-62-001: Definir el problema: memoria creciente por chunks, señales, texturas y audio sin descarga en mundo voxel cozy
[ ] T-62-002: Registrar dependencias: M61 (rendimiento), M08 (voxel), M63 (streaming); relaciones M41-M44, M12, M90, M103, M110
[ ] T-62-003: Definir el objetivo: RAM predecible y estable, sin leaks y sin picos de frame en hardware medio/bajo
[ ] T-62-004: Muestreo periódico: cada 5 s en calma y cada 1 s con movimiento de cámara
[ ] T-62-005: Lectura de `Performance.PERFORMANCE_OBJECT_COUNT` para conteo de objetos vivos
[ ] T-62-006: Lectura de `Performance.PERFORMANCE_ORPHAN_NODE_COUNT` para nodos huérfanos
[ ] T-62-007: Detección de drift: comparación contra baseline estabilizada a los 5 minutos
[ ] T-62-008: Registro del pico de memoria por sesión y por punto de interés (spawn, teleport, escena)
[ ] T-62-009: Presupuesto texturas/atlas: 400 MB en preset Alta
[ ] T-62-010: Presupuesto audio (M41-M44): 250 MB en preset Alta
[ ] T-62-011: Presupuesto escenas/NPCs/objetos: 350 MB en preset Alta
[ ] T-62-012: Presupuesto UI y fuentes: 100 MB en preset Alta
[ ] T-62-013: Presupuesto shaders/materiales: 100 MB en preset Alta
[ ] T-62-014: Presets por calidad M90: Baja 1.5 GB, Media 2.0 GB, Alta 2.5 GB
[ ] T-62-015: Familia `particula`: efectos de clima, herramientas y esporas de luz (M11/M32)
[ ] T-62-016: Familia `objeto_recogible`: objetos lanzados o dropeados (M15)
[ ] T-62-017: Familia `texto_efimero`: textos flotantes y notificaciones UI (M53)
[ ] T-62-018: Familia `npc_temporal`: NPCs de visita o eventos con reinicio de estado limpio
[ ] T-62-019: Precalentamiento al arrancar y en pantalla de carga (M63), nunca en mitad de gameplay
[ ] T-62-020: Ítems devueltos: invisibles, quietos, sin señales activas y sin referencias externas
[ ] T-62-021: Regla: prohibido conectar señales a lambdas que capturen nodos externos sin limpieza
[ ] T-62-022: Patrón de desconexión central en `_exit_tree()` documentado para todos los módulos
[ ] T-62-023: Timers cancelados en `_exit_tree()` de cada nodo que los posea
[ ] T-62-024: Tweens cancelados en `_exit_tree()` (evita callables repetitivos que retienen)
[ ] T-62-025: Prohibido crear Node sin padre que quede huérfano; chequeo con contador de orphans
[ ] T-62-026: Policy de recursos compartidos: `duplicate(false)` y caché con un solo dueño (D6)
[ ] T-62-027: Texturas de región se liberan al salir de la misma (con M63 y M09)
[ ] T-62-028: Los datos de partida (M29) no retienen referencias a nodos del mundo
[ ] T-62-029: Los callables con bound parameters se desconectan en `_exit_tree` (anti-leak de lambdas)
[ ] T-62-030: Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares)
[ ] T-62-031: Sesión de referencia: 30 min de juego sin drift > 5% sobre la línea base
[ ] T-62-032: Test de leaks con teleport ×10 y conteo de objetos antes/después (debe ser igual)
[ ] T-62-033: RN1: presupuesto de RAM objetivo ≤ 2.5 GB en PCs de gama media (preset Alta)
[ ] T-62-034: RN1: preset Baja ≤ 1.5 GB para gama baja con 4 GB de RAM
[ ] T-62-035: RN2: sin picos de frame: deltas < 50 ms durante descargas o liberaciones
[ ] T-62-036: RN2: cero hitching perceptible por refcount en liberaciones masivas
[ ] T-62-037: RN3: memoria estable: sesión de 30 min con drift < 5% sobre baseline
[ ] T-62-038: RN6: ninguna operación de memoria bloquea el hilo principal
[ ] T-62-039: RN9: la gestión de memoria es transparente para la partida (determinismo intacto)
[ ] T-62-040: Flujo muestreo → semáforo → política de acción (warning/crítico/emergencia)
[ ] T-62-041: Descarga dura al 95%: atlas fuera de pantalla y bancos de biomas viajeros
[ ] T-62-042: Toda decisión de descarga queda registrada en log (M103) para análisis
[ ] T-62-043: Buffers de VoxelTools por chunk se liberan al descargar (sin acumulación)
[ ] T-62-044: Colliders estáticos de chunks descargados se liberan junto con la mesh
[ ] T-62-045: Sin duplicación de meshes entre M63 (streaming) y el 62 (descarga)
[ ] T-62-046: Generación de mallas en hilos (M08): resultados por cola sin copias extra
[ ] T-62-047: Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM
[ ] T-62-048: Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos
[ ] T-62-049: Teleport extremo ×10 y vuelta al spawn deja la memoria en el mismo nivel (test)
[ ] T-62-050: Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región
[ ] T-62-051: Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa
[ ] T-62-052: Streams `.ogg` liberados de caché cuando ningún reproductor los usa
[ ] T-62-053: Los buses (M91) no retienen streams detenidos
[ ] T-62-054: Cambio de bioma: descarga del banco anterior diferida 1 frame (no corta transiciones)
[ ] T-62-055: Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio
[ ] T-62-056: Leer los presupuestos definitivos de M61 antes de fijar los topes duros del 62
[ ] T-62-057: LRU compartido: el 63 decide qué cargar, el 62 decide qué liberar (handshake)
[ ] T-62-058: Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueño)
[ ] T-62-059: El 62 nunca descarga un recurso que esté en la cola de carga del 63 (evento cancel)
[ ] T-62-060: Teleport (M69/M28): drift-check obligatorio tras cada viaje largo
[ ] T-62-061: NO tocar la carpeta 61 (en curso por otro agente): solo consumir sus entregables
[ ] T-62-062: Textura gigante (4K simple sin mips): detector la identifica y degrada calidad automáticamente
[ ] T-62-063: Atlas lleno: política de evicción por orden de uso con log del evento
[ ] T-62-064: Chunk sin descargar tras cambio rápido de región: el monitor lo detecta y fuerza liberación
[ ] T-62-065: Banco de audio pedido mientras se descarga: reproducción diferida o silenciada graceful
[ ] T-62-066: Escena cambiada dos veces antes de terminar la transición: cola evita doble descarga
[ ] T-62-067: Cambio de escena con streaming activo: cancelación limpia sin recursos colgados
[ ] T-62-068: Preset Baja en isla pequeña (M27): carga priorizada y descarga agresiva de viajeros
[ ] T-62-069: Tween sin fin en UI: auto-detención en `_exit_tree`
[ ] T-62-070: Nieve/niebla (M32) que crea nodos por frame: detector de nodos por frame con alerta
[ ] T-62-071: Memoria al límite durante tormenta máxima: degrada con aviso y el juego sigue jugable
[ ] T-62-072: Baseline menú principal: objetivo < 600 MB
[ ] T-62-073: Baseline spawn de Aurora: objetivo < 1.600 MB
[ ] T-62-074: Baseline horizonte terrestre oteado: objetivo < 2.200 MB
[ ] T-62-075: Baseline subterráneo del templo (M26): objetivo < 2.000 MB
[ ] T-62-076: Baseline tormenta máxima (M32) + banco de audio completo: ≤ 2.500 MB (Alta)
[ ] T-62-077: Uso de arrays tipados y `Packed*Array` donde el tamaño es fijo
[ ] T-62-078: Evitar `duplicate()`, `instantiate()` y `load()` síncrono en gameplay
[ ] T-62-079: Pico de liberación por refcount < 3 ms al descargar una región completa
[ ] T-62-080: Documentar la arquitectura en plan-actual/03-Diseno.md
[ ] T-62-081: Registrar los edge cases y sus soluciones en plan-actual/04-Codigo.md
[ ] T-62-082: Notas del Agente firmadas con modelo, plataforma y fecha en 04-Codigo.md
[ ] T-62-083: Test Play Mode: drift-check de 30 min sin teleport con drift ≤ 5%
[ ] T-62-084: Test Play Mode: teleport extremo ×10 con memoria estable y sin picos
[ ] T-62-085: Test Play Mode: cambio de bioma de audio sin crecimiento de memoria
[ ] T-62-086: Test Play Mode: excavar y regenerar 500 bloques sin leaks de buffers voxel
[ ] T-62-087: Test Play Mode: máximo de chunks cargados sin superar el presupuesto voxel
[ ] T-62-088: Test Play Mode: textura gigante forzada degrada sin crash
[ ] T-62-089: Test de semáforos: forzar 90% y verificar descargas automáticas y registro en log
[ ] T-62-090: Test de nodos huérfanos: conteo de orphans en reposo con valor estable
[ ] T-62-091: Test en preset Baja con 4 GB de RAM: sesión completa sin OOM y jugable
