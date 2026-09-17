**Modelo:** agnes-3-flash (Sapiens AI) (último modificador)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-15 (reserva iter. agnes + StressComparator/baseline)
**Historial:** documentación completa por Deepseek V4 Flash (OpenCode, 2026-08-20); iter. 1 núcleo por deepseek-v4-flash (Kilo Code, 2026-09-01); iter. agnes por agnes-3-flash (Kilo Code, 2026-09-15)

# 05-Checklist.md — Módulo 113: Pruebas de Stress (110 ítems)

## Reserva actual

- Estado: 🔵 En curso (iter. agnes — StressComparator + baseline)
- Agente: agnes-3-flash (Sapiens AI) / Kilo Code
- Log reservado: 919 (`Logs/reservas/919-agnes-3-flash-M113.txt`)
- Fase: QA y operación (soporte de M112 Testing)
- Dificultad: 3
- Visión: V0
- Entrada: M112 ✅ (testing automático), M61 🟡 (rendimiento — las métricas que piden baseline real quedan `[?]` con dueño M61)
- Salida: `StressComparator` + baseline versionado `perf_base.json` (umbral ±5% configurable) cableado en `stress_runner.gd` (marcador de `regresion` + exit 1) + test headless `test_stress_m113_comparador.gd` + reconciliación del sobre-cierre del `Totales`
- Archivos: `game/isla-ancestral/scripts/stress/` (+ `stress_comparator.gd`, `test_stress_m113_comparador.gd`)
- Fecha: 2026-09-15 23:05:00

## Convención
- `[x]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Framework de stress (RF1-RF3)

- [x] Definir StressRunner headless con batch mode [C]
- [x] Definir clase base StressScenario (Setup/Execute/Teardown) [M]
- [x] Definir medición p50/p95/max por métrica [M]
- [x] Definir reporte JSON de cada corrida [M]
- [x] Definir baseline versionado perf_base.json [M]
- [x] Definir comparación automática ±5% [M]
- [x] Definir seeds fijas por escenario (M10) [S]
- [x] Definir corre en hardware fijo (label CI) [S]
- [x] Definir exclusión del framework del build de jugador [M]
- [x] Definir integración con Debug Menu (M110) para spawn/teleport [M]
- [x] Definir status por escenario en el reporte [S]

## 2. Miles de bloques modificados (1º)

- [x] Definir escenario de edición de 100 000 bloques [C]
- [x] Definir métrica: FPS ≥ 30 p95 durante edición [M]
- [x] Definir métrica: edit operations/s ≥ 60 [M]
- [x] Definir verificación de integridad de chunks tras edición [M]
- [x] Definir undo masivo en el escenario [S]
- [x] Definir guardado del mundo denso tras el escenario [M]

## 3. Muchos NPC (2º)

- [x] Definir escenario con 60 NPC activos [C]
- [x] Definir métrica: AI frame < 4 ms [M]
- [x] Definir verificación de rutinas y diálogos sin pérdida de estado [M]
- [x] Definir interacción simultánea (hablar con varios) [S]
- [x] Definir verificación de economía/tiendas con NPCs [M]
- [x] Definir reset del escenario sin corrupción [S]

## 4. Muchos animales (3º)

- [x] Definir escenario con 200 animales (fauna) [C]
- [ ] Definir métrica: física < 5 ms [M]
- [x] Definir verificación de pathfinding para manadas [M]
- [x] Definir reproducción o intrépida de comportamiento [S]
- [x] Definir limpieza de pool tras escenario [M]

## 5. Mucha vegetación (4º)

- [x] Definir escenario con 50 000 instancias vegetales [C]
- [ ] Definir métrica: culling correcto y memoria < umbral [M]
- [x] Definir verificación de viento/anima sin degradación [M]
- [ ] Definir prueba con cámara rápida (sobrevuelo) [S]
- [x] Definir verificación del render (batches/draw calls) [M]

## 6. Muchos objetos (5º)

- [x] Definir escenario con 10 000 objetos en el mundo [C]
- [ ] Definir métrica: pooling sin GC spikes [M]
- [x] Definir verificación de interacción (recoger) [S]
- [ ] Definir prueba de colisiones densas [M]
- [x] Definir verificación de física estabilizada [S]

## 7. Mundo muy grande (6º)

- [x] Definir escenario con seed máxima de M10 [C]
- [ ] Definir métrica: streaming < 30 s [M]
- [ ] Definir métrica: memoria < 4 GB (target mínimo) [M]
- [x] Definir verificación de generación LOD/culling [S]
- [x] Definir teleport a bordes del mundo [M]
- [x] Definir verificación de transición de chunks [S]

## 8. Inventario enorme (7º)

- [x] Definir escenario con 5 000 items en inventario [C]
- [ ] Definir métrica: UI < 16 ms al abrir/ordenar [M]
- [x] Definir verificación de búsqueda/filtros [S]
- [x] Definir persistencia del inventario enorme (M14/M59) [M]
- [ ] Definir ordenamiento + drag&drop con 5 000 items [M]

## 9. Muchas construcciones (8º)

- [x] Definir escenario con 500 estructuras (M17/18) [C]
- [x] Definir métrica: edición estable (FPS ≥ 30) [M]
- [x] Definir verificación de guardado de construcciones densas [M]
- [x] Definir prueba de demolición masiva [S]
- [x] Definir verificación de interacción del jugador en zona densa [S]

## 10. Sesión de muchas horas (9º)

- [x] Definir escenario de sesión larga 8-24 h (automatizado) [C]
- [ ] Definir métrica: memoria estable ±5% en 8 h [M]
- [x] Definir métrica: FPS no decae > 10% [M]
- [ ] Definir telemetría de GC/leaks durante la sesión [M]
- [ ] Definir guardado automático durante la sesión [S]
- [x] Definir ejecución semanal del escenario [S]

## 11. Viajes repetidos (10º)

- [x] Definir escenario con 500 viajes entre islas [C]
- [x] Definir métrica: transición < 5 s cada viaje [M]
- [x] Definir verificación de streaming tras viajes [M]
- [x] Definir verificación de cooldown/recursos del viaje [S]
- [ ] Definir prueba de guardado en medio de viajes [S]

## 12. Entradas y salidas repetidas (11º)

- [x] Definir escenario con 1 000 entradas/salidas (casas/ruinas/cuevas) [C]
- [x] Definir métrica: sin leak de memoria por ciclo [M]
- [x] Definir verificación de ambiente interior/exterior [S]
- [x] Definir prueba de entrada con undo/fallo [S]
- [x] Definir verificación de referencias de objetos internos [M]

## 13. Guardados repetidos (12º)

- [x] Definir escenario de guardado continuo (100 ciclos) [C]
- [x] Definir métrica: tiempo de guardado < 5 s [M]
- [x] Definir verificación de integridad tras cada guardado [M]
- [x] Definir prueba de guardado durante cambios de worldgen [S]
- [ ] Definir prueba de guardado concurrente (auto-save + manual) [M]

## 14. Cargas repetidas (13º)

- [x] Definir escenario de carga repetida (100 ciclos) [C]
- [x] Definir métrica: carga < 30 s [M]
- [x] Definir verificación de 0 corrupción al cargar [M]
- [x] Definir prueba de carga tras guardado parcial [S]
- [ ] Definir prueba de carga en equipment/UI activa [S]

## 15. Clima cambiante (14º)

- [x] Definir escenario con 200 transiciones de clima [C]
- [x] Definir métrica: frame < 16 ms con FX activos [M]
- [x] Definir verificación de audio/partículas transicionando [M]
- [ ] Definir prueba de clima durante guardado [S]
- [ ] Definir prueba de clima con niebla extremo [S]

## 16. Estaciones cambiantes (15º)

- [x] Definir escenario con 100 ciclos de estaciones [C]
- [x] Definir verificación de terreno/vegetación por estación (M50) [M]
- [x] Definir verificación de eventos por estación [M]
- [x] Definir prueba de cambios durante construcción [S]
- [x] Definir prueba de guardado entre estaciones [S]

## 17. Multitud de partículas (16º)

- [x] Definir escenario con 5 000 partículas activas [C]
- [x] Definir métrica: frame < 8 ms adicional [M]
- [x] Definir verificación de pooling de partículas (M52) [M]
- [ ] Definir prueba con niebla densa + lluvia [S]
- [ ] Definir prueba de partículas en cuevas [S]

## 18. Muchas luces (17º)

- [x] Definir escenario con 300 luces dinámicas [C]
- [ ] Definir métrica: batching ok, < 20 ms [M]
- [x] Definir verificación de horocasting y sombras [M]
- [ ] Definir prueba de luces en interiores densos [S]
- [x] Definir prueba de transición día/noche con muchas luces [M]

## 19. Mucha agua (18º)

- [x] Definir escenario con mar completo + ríos [C]
- [ ] Definir métrica: reflexiones < 12 ms [M]
- [x] Definir verificación de físicas en agua densa [M]
- [x] Definir prueba de navegación (M28) con agua [S]
- [x] Definir prueba de transiciones de nivel de agua [S]

## 20. Muchas cuevas (19º)

- [x] Definir escenario con 50 cuevas simultáneas [C]
- [ ] Definir métrica: culling y colisiones correctas [M]
- [x] Definir verificación de iluminación en cavidades [M]
- [ ] Definir prueba de tesoros/puzzles en cuevas [S]
- [ ] Definir prueba de entrada/salida con streaming [S]

## 21. Muchos chunks activos (20º)

- [x] Definir escenario con 49 chunks activos [C]
- [ ] Definir métrica: meshing < 16 ms [M]
- [ ] Definir métrica: memoria estable con chunks densos [M]
- [x] Definir verificación de regeneración/re-meshing [M]
- [ ] Definir prueba de bordes de chunks con cambio [S]
- [x] Definir prueba con edición masiva en frontera [S]

## 22. Reportes y gates

- [x] Definir reporte JSON con p50/p95 por escenario [M]
- [x] Definir gráfica opcional en artifact del CI [S]
- [x] Definir comparación con baseline en cada corrida [M]
- [x] Definir gate `stress-save` en PR (rápido) [M]
- [x] Definir gate `stress-full` nocturno [M]
- [x] Definir gate `stress-long` semanal [M]
- [ ] Definir gate pre-Beta/pre-RC (M141/M142) [M]
- [x] Definir integración de hallazgos con M61/M62 [S]
- [ ] Definir feed de límites desde M96 [S]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]

## Totales (reconciliado por agnes-3-flash, iter. agnes, Log 919, 2026-09-15)

**Corrección del sobre-cierre:** la cifra anterior decía "127/127 (0 pendientes, 0 dudas)" — **falso**.
Conteo real de este archivo antes de la iteración: **101 `[x]` · 30 `[ ]` · 1 `[?]`** (total 132).

**Estado tras iter. agnes (Log 919):**
- `[x]` framework: `stress_runner.gd` + `stress_scenario.gd` + 4 escenarios + `StressComparator` (baseline ±5%) + `test_stress_m113_comparador.gd` (19/0).
- Los 30 `[ ]` son "definir métrica/prueba" de los 19 escenarios → la mayoría **pide baseline real de rendimiento
  (dueño M61 🟡)** o módulos reales aún ausentes (M19/M50/M65…). **No se marcan `[x]` sin implementación.**
- El 1 `[?]` (Iter.3 "comparar con objetivo de referencia / umbral por escenario") → **cerrado `[x]`** por
  `StressComparator` (mecanismo ±5% por escenario); los VALORES objetivo quedan con M61/M19/M50/M65.
- Gate pre-Beta/pre-RC (M141/M142) y feed M96 → siguen `[ ]` con dueño externo.
## Iteración 3 — Verificación visual del reporte (2026-09-02, deepseek-v4-flash-vision-exp)

- [x] Análisis del reporte real `user://stress_report.json` (4 escenarios, 4323 ms, exit 0): lecturas coherentes, integridad 1.0 en los 3 flujos de datos reales (SaveLoad 100 ciclos ok, Inventory conteos exactos, Equipment slots vacíos)
- [x] Gráficos de rendimiento generados (visualización): duración por escenario (barras) y operaciones por segundo por flujo (barras)
- [x] Interpretación QA del reporte (nota de lectura): BlockEdit 595k ops/s es una simulación RAM (no comparable con la API real); Inventory ADD ~50k ops/s (7x más lento que remove 360k — coste de señales/stacking) y Equipment equip ~50k ops/s — números realistas y sanos para el estado actual
- [x] Memoria estable: +104 KB estáticos entre inicio/fin de la corrida de referencia (sin acarreo)
- [x] Comparar con objetivo de referencia (umbral definido por escenario) — **mecanismo cerrado por agnes-3-flash (iter. agnes, Log 919):** `StressComparator.comparar()` con umbral ±5% configurable + baseline `perf_base.json`. Los VALORES objetivo por escenario quedan con M61/M19/M50/M65 cuando estén en producción.

## Notas del Agente (iter. agnes)

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-15
**Estado:** Parcial — iteración agnes liberada (mecanismo de baseline/gate entregado y verificado headless); los 30 `[ ]` de "definir métrica/prueba" siguen con dueño M61/módulos reales.

### Lo que hice
- Entregué el gap que el diseño marcó `[x]` pero el runner no implementaba: **`StressComparator`** (`scripts/stress/stress_comparator.gd`) + **baseline versionado `perf_base.json`** + **comparación ±5% configurable** cableada en `stress_runner.gd` (marcador de `regresion` + exit 1) + modo `--update-baseline` + **test headless `test_stress_m113_comparador.gd` (19 checks, 0 fallos)**.
- Cerré el `[?]` de Iter.3 ("umbral por escenario") con el mecanismo del comparador.
- **Corregí el sobre-cierre del `Totales`** (decía 127/127 "0 pendientes"; el real era 101 `[x]` / 30 `[ ]` / 1 `[?]`).

### Lo que NO hice (honestidad obligatoria)
- **No sembré un `perf_base.json` versionado en el repo:** al probarlo, una siembra desde dev-headless marcó **5 regresiones falsas** (p95 de timing oscila >5% entre corridas en hardware variable). El diseño §1 exige "corre en hardware fijo (label CI)"; **el valor del baseline es de M61/CI sobre hardware fijo**, no un artefacto de laptop. Dejé el mecanismo listo y el repo sin un baseline ruidoso.
- Los 30 `[ ]` "definir métrica/prueba" y el gate pre-Beta/RC (M141/M142) y feed M96 **siguen pendientes** con dueño.

### Recomendaciones para el próximo agente
- M61 (🟡) debe generar el `perf_base.json` **en CI con hardware fijo** vía `--update-baseline` y versionarlo; ahí el gate ±5% deja de ser frágil.
- Considerar **mediana de N corridas** o umbral por métrica (más flojo en timing, estricto en integridad) si el ±5% único sigue siendo frágil.
- Los 17 escenarios restantes (NPC/fauna/vegetación/mundo grande/…) siguen esperando a M19/M65/M08/M50.

