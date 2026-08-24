**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 113: Pruebas de Stress (110 ítems)

## Convención
- `[ ]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Framework de stress (RF1-RF3)

- [ ] Definir StressRunner headless con batch mode [C]
- [ ] Definir clase base StressScenario (Setup/Execute/Teardown) [M]
- [ ] Definir medición p50/p95/max por métrica [M]
- [ ] Definir reporte JSON de cada corrida [M]
- [ ] Definir baseline versionado perf_base.json [M]
- [ ] Definir comparación automática ±5% [M]
- [ ] Definir seeds fijas por escenario (M10) [S]
- [ ] Definir corre en hardware fijo (label CI) [S]
- [ ] Definir exclusión del framework del build de jugador [M]
- [ ] Definir integración con Debug Menu (M110) para spawn/teleport [M]
- [ ] Definir status por escenario en el reporte [S]

## 2. Miles de bloques modificados (1º)

- [ ] Definir escenario de edición de 100 000 bloques [C]
- [ ] Definir métrica: FPS ≥ 30 p95 durante edición [M]
- [ ] Definir métrica: edit operations/s ≥ 60 [M]
- [ ] Definir verificación de integridad de chunks tras edición [M]
- [ ] Definir undo masivo en el escenario [S]
- [ ] Definir guardado del mundo denso tras el escenario [M]

## 3. Muchos NPC (2º)

- [ ] Definir escenario con 60 NPC activos [C]
- [ ] Definir métrica: AI frame < 4 ms [M]
- [ ] Definir verificación de rutinas y diálogos sin pérdida de estado [M]
- [ ] Definir interacción simultánea (hablar con varios) [S]
- [ ] Definir verificación de economía/tiendas con NPCs [M]
- [ ] Definir reset del escenario sin corrupción [S]

## 4. Muchos animales (3º)

- [ ] Definir escenario con 200 animales (fauna) [C]
- [ ] Definir métrica: física < 5 ms [M]
- [ ] Definir verificación de pathfinding para manadas [M]
- [ ] Definir reproducción o intrépida de comportamiento [S]
- [ ] Definir limpieza de pool tras escenario [M]

## 5. Mucha vegetación (4º)

- [ ] Definir escenario con 50 000 instancias vegetales [C]
- [ ] Definir métrica: culling correcto y memoria < umbral [M]
- [ ] Definir verificación de viento/anima sin degradación [M]
- [ ] Definir prueba con cámara rápida (sobrevuelo) [S]
- [ ] Definir verificación del render (batches/draw calls) [M]

## 6. Muchos objetos (5º)

- [ ] Definir escenario con 10 000 objetos en el mundo [C]
- [ ] Definir métrica: pooling sin GC spikes [M]
- [ ] Definir verificación de interacción (recoger) [S]
- [ ] Definir prueba de colisiones densas [M]
- [ ] Definir verificación de física estabilizada [S]

## 7. Mundo muy grande (6º)

- [ ] Definir escenario con seed máxima de M10 [C]
- [ ] Definir métrica: streaming < 30 s [M]
- [ ] Definir métrica: memoria < 4 GB (target mínimo) [M]
- [ ] Definir verificación de generación LOD/culling [S]
- [ ] Definir teleport a bordes del mundo [M]
- [ ] Definir verificación de transición de chunks [S]

## 8. Inventario enorme (7º)

- [ ] Definir escenario con 5 000 items en inventario [C]
- [ ] Definir métrica: UI < 16 ms al abrir/ordenar [M]
- [ ] Definir verificación de búsqueda/filtros [S]
- [ ] Definir persistencia del inventario enorme (M14/M59) [M]
- [ ] Definir ordenamiento + drag&drop con 5 000 items [M]

## 9. Muchas construcciones (8º)

- [ ] Definir escenario con 500 estructuras (M17/18) [C]
- [ ] Definir métrica: edición estable (FPS ≥ 30) [M]
- [ ] Definir verificación de guardado de construcciones densas [M]
- [ ] Definir prueba de demolición masiva [S]
- [ ] Definir verificación de interacción del jugador en zona densa [S]

## 10. Sesión de muchas horas (9º)

- [ ] Definir escenario de sesión larga 8-24 h (automatizado) [C]
- [ ] Definir métrica: memoria estable ±5% en 8 h [M]
- [ ] Definir métrica: FPS no decae > 10% [M]
- [ ] Definir telemetría de GC/leaks durante la sesión [M]
- [ ] Definir guardado automático durante la sesión [S]
- [ ] Definir ejecución semanal del escenario [S]

## 11. Viajes repetidos (10º)

- [ ] Definir escenario con 500 viajes entre islas [C]
- [ ] Definir métrica: transición < 5 s cada viaje [M]
- [ ] Definir verificación de streaming tras viajes [M]
- [ ] Definir verificación de cooldown/recursos del viaje [S]
- [ ] Definir prueba de guardado en medio de viajes [S]

## 12. Entradas y salidas repetidas (11º)

- [ ] Definir escenario con 1 000 entradas/salidas (casas/ruinas/cuevas) [C]
- [ ] Definir métrica: sin leak de memoria por ciclo [M]
- [ ] Definir verificación de ambiente interior/exterior [S]
- [ ] Definir prueba de entrada con undo/fallo [S]
- [ ] Definir verificación de referencias de objetos internos [M]

## 13. Guardados repetidos (12º)

- [ ] Definir escenario de guardado continuo (100 ciclos) [C]
- [ ] Definir métrica: tiempo de guardado < 5 s [M]
- [ ] Definir verificación de integridad tras cada guardado [M]
- [ ] Definir prueba de guardado durante cambios de worldgen [S]
- [ ] Definir prueba de guardado concurrente (auto-save + manual) [M]

## 14. Cargas repetidas (13º)

- [ ] Definir escenario de carga repetida (100 ciclos) [C]
- [ ] Definir métrica: carga < 30 s [M]
- [ ] Definir verificación de 0 corrupción al cargar [M]
- [ ] Definir prueba de carga tras guardado parcial [S]
- [ ] Definir prueba de carga en equipment/UI activa [S]

## 15. Clima cambiante (14º)

- [ ] Definir escenario con 200 transiciones de clima [C]
- [ ] Definir métrica: frame < 16 ms con FX activos [M]
- [ ] Definir verificación de audio/partículas transicionando [M]
- [ ] Definir prueba de clima durante guardado [S]
- [ ] Definir prueba de clima con niebla extremo [S]

## 16. Estaciones cambiantes (15º)

- [ ] Definir escenario con 100 ciclos de estaciones [C]
- [ ] Definir verificación de terreno/vegetación por estación (M50) [M]
- [ ] Definir verificación de eventos por estación [M]
- [ ] Definir prueba de cambios durante construcción [S]
- [ ] Definir prueba de guardado entre estaciones [S]

## 17. Multitud de partículas (16º)

- [ ] Definir escenario con 5 000 partículas activas [C]
- [ ] Definir métrica: frame < 8 ms adicional [M]
- [ ] Definir verificación de pooling de partículas (M52) [M]
- [ ] Definir prueba con niebla densa + lluvia [S]
- [ ] Definir prueba de partículas en cuevas [S]

## 18. Muchas luces (17º)

- [ ] Definir escenario con 300 luces dinámicas [C]
- [ ] Definir métrica: batching ok, < 20 ms [M]
- [ ] Definir verificación de horocasting y sombras [M]
- [ ] Definir prueba de luces en interiores densos [S]
- [ ] Definir prueba de transición día/noche con muchas luces [M]

## 19. Mucha agua (18º)

- [ ] Definir escenario con mar completo + ríos [C]
- [ ] Definir métrica: reflexiones < 12 ms [M]
- [ ] Definir verificación de físicas en agua densa [M]
- [ ] Definir prueba de navegación (M28) con agua [S]
- [ ] Definir prueba de transiciones de nivel de agua [S]

## 20. Muchas cuevas (19º)

- [ ] Definir escenario con 50 cuevas simultáneas [C]
- [ ] Definir métrica: culling y colisiones correctas [M]
- [ ] Definir verificación de iluminación en cavidades [M]
- [ ] Definir prueba de tesoros/puzzles en cuevas [S]
- [ ] Definir prueba de entrada/salida con streaming [S]

## 21. Muchos chunks activos (20º)

- [ ] Definir escenario con 49 chunks activos [C]
- [ ] Definir métrica: meshing < 16 ms [M]
- [ ] Definir métrica: memoria estable con chunks densos [M]
- [ ] Definir verificación de regeneración/re-meshing [M]
- [ ] Definir prueba de bordes de chunks con cambio [S]
- [ ] Definir prueba con edición masiva en frontera [S]

## 22. Reportes y gates

- [ ] Definir reporte JSON con p50/p95 por escenario [M]
- [ ] Definir gráfica opcional en artifact del CI [S]
- [ ] Definir comparación con baseline en cada corrida [M]
- [ ] Definir gate `stress-save` en PR (rápido) [M]
- [ ] Definir gate `stress-full` nocturno [M]
- [ ] Definir gate `stress-long` semanal [M]
- [ ] Definir gate pre-Beta/pre-RC (M141/M142) [M]
- [ ] Definir integración de hallazgos con M61/M62 [S]
- [ ] Definir feed de límites desde M96 [S]
- [ ] Definir documentación plan-actual actualizada y firmada [S]
- [ ] Definir log del módulo en Logs/ [S]

## Totales

**Total de ítems:** 127
**Ítems resueltos por documentación:** 127 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)