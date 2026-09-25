**Generado por:** atria-dawn (Kilo Code) — coordinacion Log 1091/1092
**Fecha:** 2026-09-20

# BACKLOG AUTONOMO — DeepSeek-V4.1-Flash

> **Tareas extraidas de los `05-Checklist.md` reales** (no inventadas). Cada una es
> verificable contra el codigo. **Trabajalas en orden**; al completar una, marca `[x]`
> en los **3 registros**: este backlog, el `05-Checklist.md` del modulo (marcas **Y**
> linea `**Totales:**`) y la fila de `CHECKLIST-GLOBAL.md`.
>
> **Rol asignado:** Diseno + implementacion de infraestructura (fundador del proyecto, iter.1 M103)
>
> **Recordatorios del protocolo:**
> - Reserva log: `python scripts/reservar_log.py --reservar --agente DeepSeek-V4.1-Flash --modulo <X>`
> - Push a git: **NEGATIVO** (instruccion del usuario)
> - Anti-falso-verde (leccion 28): exit code **Y** 0 SCRIPT ERROR en stderr
> - Codificacion UTF-8 obligatoria
> - Binario Godot 4.7.2: `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
>   `--headless --path game/isla-ancestral --quit --script res://...`

---

## 103-Logging (12 pendientes)

- [?] **T-001 103:** RF18: crash reporting integración [S] -- [?] — integración con M122 (Crash Reporting) NO implementada: el módulo consumidor no existe todavía. Dise...
- [?] **T-002 103:** Definir buffer de escritura (performance) [S] -- [?] — iter. 1 (2026-09-15): el buffer de escritura se RETIRÓ por ser código muerto; la escritura e...
- [?] **T-003 103:** Definir flush periódico (cada 100 líneas o 1s) [S] -- [?] — no hay flush periódico (100 líneas / 1 s): desde el fix del 2026-09-02 se hace flush po...
- [?] **T-004 103:** Definir generación de bug_{timestamp}.log para issues [S] -- [?] — no existe definición de bug_{timestamp}.log: solo export_{timestamp}.log (LogExp...
- [?] **T-005 103:** Definir búsqueda de texto [S] -- [?] — no hay API de búsqueda de texto en logger.gd; depende de la consola in-game (M53/M110).
- [?] **T-006 103:** Definir scroll en consola in-game [S] -- [?] — sin consola in-game propia; depende de M110 (Debug Menu).
- [?] **T-007 103:** Definir coloreado por nivel (INFO=blanco, ERROR=rojo) [S] -- [?] — iter. 1: se retiró la nota previa que afirmaba «colores definidos en logging_con...
- [?] **T-008 103:** Definir timestamp relativo (hace X segundos) [S] -- [?] — solo timestamps absolutos; el relativo exigiría calcular un delta por línea.
- [?] **T-009 103:** Definir impacto máximo en frame budget (< 0.5%%) [S] -- [?] — impacto en frame budget NO medido; corresponde a M61 (Rendimiento). El diseño (§10 Re...
- [?] **T-010 103:** Criterios de aceptación cumplidos [M] -- [?] — de los 5 criterios de aceptación de 01-Requerimientos.md §4, el nº4 (integración con M102 para adjun...
- [?] **T-011 103:** Implementar buffer + flush periódico (cada 100 líneas) para performance [M] -- [?] — igual que el ítem G de diseño: el buffer de 100 líneas se reti...
- [?] **T-012 103:** Regresión completa: 6 tests de economía/tiendas/tiempo con 0 fallos tras el autoload (Godot 4.7.2) [S] -- [?] — verificado 2026-09-15: 5 de 6 pasan...

## 62-Memoria (91 pendientes)

- [ ] **T-013 62:** Definir el problema: memoria creciente por chunks, señales, texturas y audio sin descarga en mundo voxel cozy
- [ ] **T-014 62:** Registrar dependencias: M61 (rendimiento), M08 (voxel), M63 (streaming); relaciones M41-M44, M12, M90, M103, M110
- [ ] **T-015 62:** Definir el objetivo: RAM predecible y estable, sin leaks y sin picos de frame en hardware medio/bajo
- [ ] **T-016 62:** Muestreo periódico: cada 5 s en calma y cada 1 s con movimiento de cámara
- [ ] **T-017 62:** Lectura de `Performance.PERFORMANCE_OBJECT_COUNT` para conteo de objetos vivos
- [ ] **T-018 62:** Lectura de `Performance.PERFORMANCE_ORPHAN_NODE_COUNT` para nodos huérfanos
- [ ] **T-019 62:** Detección de drift: comparación contra baseline estabilizada a los 5 minutos
- [ ] **T-020 62:** Registro del pico de memoria por sesión y por punto de interés (spawn, teleport, escena)
- [ ] **T-021 62:** Presupuesto texturas/atlas: 400 MB en preset Alta
- [ ] **T-022 62:** Presupuesto audio (M41-M44): 250 MB en preset Alta
- [ ] **T-023 62:** Presupuesto escenas/NPCs/objetos: 350 MB en preset Alta
- [ ] **T-024 62:** Presupuesto UI y fuentes: 100 MB en preset Alta
- [ ] **T-025 62:** Presupuesto shaders/materiales: 100 MB en preset Alta
- [ ] **T-026 62:** Presets por calidad M90: Baja 1.5 GB, Media 2.0 GB, Alta 2.5 GB
- [ ] **T-027 62:** Familia `particula`: efectos de clima, herramientas y esporas de luz (M11/M32)
- [ ] **T-028 62:** Familia `objeto_recogible`: objetos lanzados o dropeados (M15)
- [ ] **T-029 62:** Familia `texto_efimero`: textos flotantes y notificaciones UI (M53)
- [ ] **T-030 62:** Familia `npc_temporal`: NPCs de visita o eventos con reinicio de estado limpio
- [ ] **T-031 62:** Precalentamiento al arrancar y en pantalla de carga (M63), nunca en mitad de gameplay
- [ ] **T-032 62:** Ítems devueltos: invisibles, quietos, sin señales activas y sin referencias externas
- [ ] **T-033 62:** Regla: prohibido conectar señales a lambdas que capturen nodos externos sin limpieza
- [ ] **T-034 62:** Patrón de desconexión central en `_exit_tree()` documentado para todos los módulos
- [ ] **T-035 62:** Timers cancelados en `_exit_tree()` de cada nodo que los posea
- [ ] **T-036 62:** Tweens cancelados en `_exit_tree()` (evita callables repetitivos que retienen)
- [ ] **T-037 62:** Prohibido crear Node sin padre que quede huérfano; chequeo con contador de orphans
- [ ] **T-038 62:** Policy de recursos compartidos: `duplicate(false)` y caché con un solo dueño (D6)
- [ ] **T-039 62:** Texturas de región se liberan al salir de la misma (con M63 y M09)
- [ ] **T-040 62:** Los datos de partida (M29) no retienen referencias a nodos del mundo
- [ ] **T-041 62:** Los callables con bound parameters se desconectan en `_exit_tree` (anti-leak de lambdas)
- [ ] **T-042 62:** Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares)
- [ ] **T-043 62:** Sesión de referencia: 30 min de juego sin drift > 5% sobre la línea base
- [ ] **T-044 62:** Test de leaks con teleport ×10 y conteo de objetos antes/después (debe ser igual)
- [ ] **T-045 62:** RN1: presupuesto de RAM objetivo ≤ 2.5 GB en PCs de gama media (preset Alta)
- [ ] **T-046 62:** RN1: preset Baja ≤ 1.5 GB para gama baja con 4 GB de RAM
- [ ] **T-047 62:** RN2: sin picos de frame: deltas < 50 ms durante descargas o liberaciones
- [ ] **T-048 62:** RN2: cero hitching perceptible por refcount en liberaciones masivas
- [ ] **T-049 62:** RN3: memoria estable: sesión de 30 min con drift < 5% sobre baseline
- [ ] **T-050 62:** RN6: ninguna operación de memoria bloquea el hilo principal
- [ ] **T-051 62:** RN9: la gestión de memoria es transparente para la partida (determinismo intacto)
- [ ] **T-052 62:** Flujo muestreo → semáforo → política de acción (warning/crítico/emergencia)
- [ ] **T-053 62:** Descarga dura al 95%: atlas fuera de pantalla y bancos de biomas viajeros
- [ ] **T-054 62:** Toda decisión de descarga queda registrada en log (M103) para análisis
- [ ] **T-055 62:** Buffers de VoxelTools por chunk se liberan al descargar (sin acumulación)
- [ ] **T-056 62:** Colliders estáticos de chunks descargados se liberan junto con la mesh
- [ ] **T-057 62:** Sin duplicación de meshes entre M63 (streaming) y el 62 (descarga)
- [ ] **T-058 62:** Generación de mallas en hilos (M08): resultados por cola sin copias extra
- [ ] **T-059 62:** Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM
- [ ] **T-060 62:** Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos
- [ ] **T-061 62:** Teleport extremo ×10 y vuelta al spawn deja la memoria en el mismo nivel (test)
- [ ] **T-062 62:** Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región
- [ ] **T-063 62:** Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa
- [ ] **T-064 62:** Streams `.ogg` liberados de caché cuando ningún reproductor los usa
- [ ] **T-065 62:** Los buses (M91) no retienen streams detenidos
- [ ] **T-066 62:** Cambio de bioma: descarga del banco anterior diferida 1 frame (no corta transiciones)
- [ ] **T-067 62:** Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio
- [ ] **T-068 62:** Leer los presupuestos definitivos de M61 antes de fijar los topes duros del 62
- [ ] **T-069 62:** LRU compartido: el 63 decide qué cargar, el 62 decide qué liberar (handshake)
- [ ] **T-070 62:** Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueño)
- [ ] **T-071 62:** El 62 nunca descarga un recurso que esté en la cola de carga del 63 (evento cancel)
- [ ] **T-072 62:** Teleport (M69/M28): drift-check obligatorio tras cada viaje largo
- [ ] **T-073 62:** NO tocar la carpeta 61 (en curso por otro agente): solo consumir sus entregables
- [ ] **T-074 62:** Textura gigante (4K simple sin mips): detector la identifica y degrada calidad automáticamente
- [ ] **T-075 62:** Atlas lleno: política de evicción por orden de uso con log del evento
- [ ] **T-076 62:** Chunk sin descargar tras cambio rápido de región: el monitor lo detecta y fuerza liberación
- [ ] **T-077 62:** Banco de audio pedido mientras se descarga: reproducción diferida o silenciada graceful
- [ ] **T-078 62:** Escena cambiada dos veces antes de terminar la transición: cola evita doble descarga
- [ ] **T-079 62:** Cambio de escena con streaming activo: cancelación limpia sin recursos colgados
- [ ] **T-080 62:** Preset Baja en isla pequeña (M27): carga priorizada y descarga agresiva de viajeros
- [ ] **T-081 62:** Tween sin fin en UI: auto-detención en `_exit_tree`
- [ ] **T-082 62:** Nieve/niebla (M32) que crea nodos por frame: detector de nodos por frame con alerta
- [ ] **T-083 62:** Memoria al límite durante tormenta máxima: degrada con aviso y el juego sigue jugable
- [ ] **T-084 62:** Baseline menú principal: objetivo < 600 MB
- [ ] **T-085 62:** Baseline spawn de Aurora: objetivo < 1.600 MB
- [ ] **T-086 62:** Baseline horizonte terrestre oteado: objetivo < 2.200 MB
- [ ] **T-087 62:** Baseline subterráneo del templo (M26): objetivo < 2.000 MB
- [ ] **T-088 62:** Baseline tormenta máxima (M32) + banco de audio completo: ≤ 2.500 MB (Alta)
- [ ] **T-089 62:** Uso de arrays tipados y `Packed*Array` donde el tamaño es fijo
- [ ] **T-090 62:** Evitar `duplicate()`, `instantiate()` y `load()` síncrono en gameplay
- [ ] **T-091 62:** Pico de liberación por refcount < 3 ms al descargar una región completa
- [ ] **T-092 62:** Documentar la arquitectura en plan-actual/03-Diseno.md
- [ ] **T-093 62:** Registrar los edge cases y sus soluciones en plan-actual/04-Codigo.md
- [ ] **T-094 62:** Notas del Agente firmadas con modelo, plataforma y fecha en 04-Codigo.md
- [ ] **T-095 62:** Test Play Mode: drift-check de 30 min sin teleport con drift ≤ 5%
- [ ] **T-096 62:** Test Play Mode: teleport extremo ×10 con memoria estable y sin picos
- [ ] **T-097 62:** Test Play Mode: cambio de bioma de audio sin crecimiento de memoria
- [ ] **T-098 62:** Test Play Mode: excavar y regenerar 500 bloques sin leaks de buffers voxel
- [ ] **T-099 62:** Test Play Mode: máximo de chunks cargados sin superar el presupuesto voxel
- [ ] **T-100 62:** Test Play Mode: textura gigante forzada degrada sin crash
- [ ] **T-101 62:** Test de semáforos: forzar 90% y verificar descargas automáticas y registro en log
- [ ] **T-102 62:** Test de nodos huérfanos: conteo de orphans en reposo con valor estable
- [ ] **T-103 62:** Test en preset Baja con 4 GB de RAM: sesión completa sin OOM y jugable

---

## Meta

103 tareas pendientes en total. Trabaja en lotes de 5;
cada lote = 1 log + sync de los 3 registros.

**Si una tarea te supera (scope, contexto, vision):** dejala `[?]` con
dueno y explicacion. **Mejor un `[?]` honesto que un `[x]` falso** (DoD §21.6).
