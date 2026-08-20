**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 113: Pruebas de Stress (110 ítems)

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
- [x] Definir métrica: física < 5 ms [M]
- [x] Definir verificación de pathfinding para manadas [M]
- [x] Definir reproducción o intrépida de comportamiento [S]
- [x] Definir limpieza de pool tras escenario [M]

## 5. Mucha vegetación (4º)

- [x] Definir escenario con 50 000 instancias vegetales [C]
- [x] Definir métrica: culling correcto y memoria < umbral [M]
- [x] Definir verificación de viento/anima sin degradación [M]
- [x] Definir prueba con cámara rápida (sobrevuelo) [S]
- [x] Definir verificación del render (batches/draw calls) [M]

## 6. Muchos objetos (5º)

- [x] Definir escenario con 10 000 objetos en el mundo [C]
- [x] Definir métrica: pooling sin GC spikes [M]
- [x] Definir verificación de interacción (recoger) [S]
- [x] Definir prueba de colisiones densas [M]
- [x] Definir verificación de física estabilizada [S]

## 7. Mundo muy grande (6º)

- [x] Definir escenario con seed máxima de M10 [C]
- [x] Definir métrica: streaming < 30 s [M]
- [x] Definir métrica: memoria < 4 GB (target mínimo) [M]
- [x] Definir verificación de generación LOD/culling [S]
- [x] Definir teleport a bordes del mundo [M]
- [x] Definir verificación de transición de chunks [S]

## 8. Inventario enorme (7º)

- [x] Definir escenario con 5 000 items en inventario [C]
- [x] Definir métrica: UI < 16 ms al abrir/ordenar [M]
- [x] Definir verificación de búsqueda/filtros [S]
- [x] Definir persistencia del inventario enorme (M14/M59) [M]
- [x] Definir ordenamiento + drag&drop con 5 000 items [M]

## 9. Muchas construcciones (8º)

- [x] Definir escenario con 500 estructuras (M17/18) [C]
- [x] Definir métrica: edición estable (FPS ≥ 30) [M]
- [x] Definir verificación de guardado de construcciones densas [M]
- [x] Definir prueba de demolición masiva [S]
- [x] Definir verificación de interacción del jugador en zona densa [S]

## 10. Sesión de muchas horas (9º)

- [x] Definir escenario de sesión larga 8-24 h (automatizado) [C]
- [x] Definir métrica: memoria estable ±5% en 8 h [M]
- [x] Definir métrica: FPS no decae > 10% [M]
- [x] Definir telemetría de GC/leaks durante la sesión [M]
- [x] Definir guardado automático durante la sesión [S]
- [x] Definir ejecución semanal del escenario [S]

## 11. Viajes repetidos (10º)

- [x] Definir escenario con 500 viajes entre islas [C]
- [x] Definir métrica: transición < 5 s cada viaje [M]
- [x] Definir verificación de streaming tras viajes [M]
- [x] Definir verificación de cooldown/recursos del viaje [S]
- [x] Definir prueba de guardado en medio de viajes [S]

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
- [x] Definir prueba de guardado concurrente (auto-save + manual) [M]

## 14. Cargas repetidas (13º)

- [x] Definir escenario de carga repetida (100 ciclos) [C]
- [x] Definir métrica: carga < 30 s [M]
- [x] Definir verificación de 0 corrupción al cargar [M]
- [x] Definir prueba de carga tras guardado parcial [S]
- [x] Definir prueba de carga en equipment/UI activa [S]

## 15. Clima cambiante (14º)

- [x] Definir escenario con 200 transiciones de clima [C]
- [x] Definir métrica: frame < 16 ms con FX activos [M]
- [x] Definir verificación de audio/partículas transicionando [M]
- [x] Definir prueba de clima durante guardado [S]
- [x] Definir prueba de clima con niebla extremo [S]

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
- [x] Definir prueba con niebla densa + lluvia [S]
- [x] Definir prueba de partículas en cuevas [S]

## 18. Muchas luces (17º)

- [x] Definir escenario con 300 luces dinámicas [C]
- [x] Definir métrica: batching ok, < 20 ms [M]
- [x] Definir verificación de horocasting y sombras [M]
- [x] Definir prueba de luces en interiores densos [S]
- [x] Definir prueba de transición día/noche con muchas luces [M]

## 19. Mucha agua (18º)

- [x] Definir escenario con mar completo + ríos [C]
- [x] Definir métrica: reflexiones < 12 ms [M]
- [x] Definir verificación de físicas en agua densa [M]
- [x] Definir prueba de navegación (M28) con agua [S]
- [x] Definir prueba de transiciones de nivel de agua [S]

## 20. Muchas cuevas (19º)

- [x] Definir escenario con 50 cuevas simultáneas [C]
- [x] Definir métrica: culling y colisiones correctas [M]
- [x] Definir verificación de iluminación en cavidades [M]
- [x] Definir prueba de tesoros/puzzles en cuevas [S]
- [x] Definir prueba de entrada/salida con streaming [S]

## 21. Muchos chunks activos (20º)

- [x] Definir escenario con 49 chunks activos [C]
- [x] Definir métrica: meshing < 16 ms [M]
- [x] Definir métrica: memoria estable con chunks densos [M]
- [x] Definir verificación de regeneración/re-meshing [M]
- [x] Definir prueba de bordes de chunks con cambio [S]
- [x] Definir prueba con edición masiva en frontera [S]

## 22. Reportes y gates

- [x] Definir reporte JSON con p50/p95 por escenario [M]
- [x] Definir gráfica opcional en artifact del CI [S]
- [x] Definir comparación con baseline en cada corrida [M]
- [x] Definir gate `stress-save` en PR (rápido) [M]
- [x] Definir gate `stress-full` nocturno [M]
- [x] Definir gate `stress-long` semanal [M]
- [x] Definir gate pre-Beta/pre-RC (M141/M142) [M]
- [x] Definir integración de hallazgos con M61/M62 [S]
- [x] Definir feed de límites desde M96 [S]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]

## Totales

**Total de ítems:** 127
**Ítems resueltos por documentación:** 127 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)