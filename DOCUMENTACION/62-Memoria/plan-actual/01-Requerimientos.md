**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 62: Memoria

## ID del Módulo
- **Código:** M62 (plan maestro: sección 61 — Memoria)
- **Carpeta:** `DOCUMENTACION/62-Memoria/`
- **Dependencias:** M61 (rendimiento — EN CURSO por otro agente; NO tocar `DOCUMENTACION/61-*`), M08 (mundo voxel), M63 (cargas y streaming). Relaciones: M41-M44 (audio), M90 (configuración gráfica), M12 (cámara), M103 (logging), M110 (debug menu)
- **Delegable desde:** hoy (documentación completa; implementación tras los presupuestos definitivos de M61 y el voxel de M08)

## 1. Problema

El juego vive en un mundo voxel (isla Aurora, M08) con música y bancos de audio por bioma (M41-M44), streaming de chunks (M63) y hardware objetivo medio/bajo. Sin gestión de memoria, el proyecto sufre: picos de RAM por chunks acumulados, leaks por señales y callables que retienen nodos, texturas sin descargar, bancos de audio precargados para siempre y liberaciones masivas que congelan frames (refcount en GDScript). El resultado sería OOM en gama baja y hitching en gama media.

## 2. Objetivo

Memoria predecible y estable: un presupuesto de RAM por sistema, pools reutilizables, políticas de descarga automáticas y monitoreo continuo — sin leaks, sin picos de frame y sin tocar el hilo principal. El jugador nunca percibe degradación injustificada.

## 3. Alcance

### Dentro del módulo
- Monitoreo de memoria (motor + juego) y semáforos de alerta.
- Presupuestos de RAM por sistema, configurables por preset de calidad (M90).
- Pooling global de instancias (audio, partículas, meshes, objetos, NPCs temporales).
- Prevención de leaks: señales, callables, timers, tweens, recursos huérfanos.
- Políticas de descarga (LRU, prioridad, edad) para chunks voxel (M08), texturas y audio.
- Reportes al log (M103), al Debug Menu (M110) y mediciones de verificación.
- Documentación y testings del módulo.

### Fuera del módulo
- Frame budgets y rendimiento general de render/GPU (M61, otro agente).
- Cola de carga y orden de streaming (M63): el 62 solo decide qué liberar y cuánto cabe.
- Optimización de assets en origen (compresión de texturas): se consume la decisión de M90/M61.
- IA, gameplay, red: consumen el servicio, no lo implementan.

## 4. Restricciones

- Motor Godot 4.x, lenguaje GDScript únicamente (sin C#, sin plugins nativos de memoria).
- Hardware objetivo: gama media/baja (4-8 GB de RAM del sistema; el juego debe correr en 2 GB de presupuesto).
- NO modificar la carpeta `DOCUMENTACION/61-*` (módulo en curso por otro agente).
- Ninguna operación de memoria puede bloquear el hilo principal.
- El juego es single-player local: no hay red, no hay cachés de red.
- Principio del proyecto: optimización obligatoria; no se aceptan sistemas que "funcionan pero mal".

## 5. Requisitos Funcionales (RF)

| # | Requisito | Detalle |
|---|---|---|
| RF1 | MemoryMonitor | Servicio único que muestrea memoria del motor y del juego, objetos vivos, picos y drift; con getters puros para el resto de módulos |
| RF2 | Presupuestos por sistema | Tabla de topes de RAM por familia (voxel, texturas, audio, escenas, pools, UI, shaders, reserva); verificación periódica y configuración por preset M90 |
| RF3 | Pooling global | Piscinas tipadas por familia (audio, partículas, meshes de chunk, objetos, NPCs temporales, textos UI) con API obtener/devolver/precalentar, límites y contadores |
| RF4 | Prevención de leaks | Auditoría de señales/callables, cancelación de timers/tweens en `_exit_tree`, política de ResourceCache, rechazo de nodos huérfanos |
| RF5 | Descarga de chunks | LRU + pool de meshes: liberar buffers voxel y colliders de chunks lejanos sin duplicar con M63 |
| RF6 | Gestión de texturas | Atlas + mips, descarga de texturas fuera de región, evicción de atlas por uso |
| RF7 | Gestión de audio | Bancos por bioma (M42) con carga/descarga en región; pistas largas en streaming; tope de voces del pool (M43) |
| RF8 | Anti-picos | Cero allocs deliberados en hot paths (`_process`/`_physics_process`), liberaciones diferidas 1 frame, descargas escalonadas |
| RF9 | Reportes | Semáforos (warning/crítico/emergencia), eventos por EventBus (M07), registro en log (M103) y panel en Debug Menu (M110) |
| RF10 | Configuración | Topes editables en `budgets.tres` sin recompilar; presets Baja/Media/Alta definidos |

## 6. Requisitos No Funcionales (RN)

- **RN1 — Presupuesto de RAM objetivo:** ≤ 2.5 GB en PCs de gama media (preset Alta); ≤ 2.0 GB preset Media; ≤ 1.5 GB preset Baja (gama baja).
- **RN2 — Sin picos de frame:** deltas < 50 ms durante descargas o liberaciones de chunks; cero hitching perceptible por refcount.
- **RN3 — Cero leaks:** sesión de 30 minutos de juego continuo sin drift > 5% sobre la línea base estabilizada.
- **RN4 — Topes configurables:** todos los presupuestos por sistema son datos (.tres) y verificables sin recompilar.
- **RN5 — Stack:** 100% Godot 4.x + GDScript; sin C#, sin plugins externos de memoria.
- **RN6 — Hilo principal:** ninguna operación (carga, descarga, medición) bloquea el hilo principal.
- **RN7 — Degradación graceful:** al cruzar umbrales se degrada (bajar LOD de lejanos, reducir pools, evicción de atlas) antes que crashear; el juego sigue jugable y cozy.
- **RN8 — Coherencia con M63:** el 62 nunca descarga algo que la cola de streaming esté cargando (handshake por evento).
- **RN9 — Determinismo:** la memoria es transparente para la partida: misma semilla = mismo mundo, sin que el estado de memoria altere gameplay.
- **RN10 — Mediciones verificables:** baseline por punto de interés (menú < 600 MB, spawn < 1.6 GB, horizonte < 2.2 GB) ejecutable en tests.

## 7. Criterios de Aceptación

1. MemoryMonitor, presupuestos por sistema, pooling global y políticas de descarga especificados en diseño.
2. Tabla de presupuestos por preset (Baja/Media/Alta) cerrada y justificada (suma ≤ 2.5 GB).
3. RF1-RF10 resueltos con firma de funciones GDScript y archivos previstos.
4. Reglas anti-leak y anti-pico verificables en tests (RN2, RN3, RN10).
5. Integraciones con M08/M41-44/M61/M63 documentadas sin tocar la carpeta 61.
6. Delegable para implementación.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M061** — Rendimiento | Gestión de memoria |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M061** — Rendimiento | Depende de este módulo |

