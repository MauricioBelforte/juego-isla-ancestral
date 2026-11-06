# Hy3 — TANDA LARGA GATE-2 (4nov, 25 tareas)

**Fuente:** agnes-3-flash #482 (4nov 23:01, reintegración fundador)
**Modelo:** Hy3 / WorkBuddy (Tencent Hunyuan)
**Estado:** [→] En progreso

## Bloque 1: Verificar BUG-155 fix en M73 (3)
- [→] G1-01: Correr boot headless → verificar `achievement_service.gd:156` resuelve `colecciones` correctamente (no null)
- [ ] G1-02: Grep `test_coleccionables` o suite de logros → 0 SCRIPT_ERROR
- [ ] G1-03: Verificar que `categoria_completed` se emite (red_probe_event_bus)

## Bloque 2: M129 BUG-070 verificación (2)
- [ ] G2-01: grep `pipeline.*3d|mockup.*merch|render.*merch` en plan-actual M129 → ¿hay artefacto?
- [ ] G2-02: grep `stock_control|StockControl` en scripts/ → ¿existe? Si sí → BUG-070 resuelto → M129 sello 13°

## Bloque 3: M107 reconciliación (3)
- [ ] G3-01: M107 body 182/182 vs GLOBAL 177/182 vs Totales 168/9 → reconciliar conteo real
- [ ] G3-02: Verificar 5 archivos backup (`scripts/backup/*` + `test_backup_ps1.py`) → existen y funcionan
- [ ] G3-03: Si M107 se reconcilia → gate-2 runtime → candidato a sello

## Bloque 4: M59 gate-2 (cuando DeepSeek libere) (2)
- [ ] G4-01: Verificar estado GLOBAL M59. Si 🟡/✅ → gate-2 runtime + BUG-087/088 + BUG-152
- [ ] G4-02: QA debe AFIRMAR LoadResult.OK en request_save() real, no solo camino de error

## Bloque 5: QA-cross módulos ya sellados (5)
- [ ] G5-01: M101 (209/209, sello 10-15): re-verificar 5 [x] contra disco
- [ ] G5-02: M100 (220/220, sello 11°): re-verificar 5 [x] contra disco
- [ ] G5-03: M87 (i18n, 159/3/2): re-verificar 5 [x] contra disco
- [ ] G5-04: M53 (UI-UX, 159/165): re-verificar 5 [x] contra disco
- [ ] G5-05: M34 (Pesca, 145/153, 8 [?]): correr test_fishing + red_probe

## Bloque 6: M64/M17/M37/M43 (condicionales, verificar estado) (4)
- [ ] G6-01: M64 IA NPC (MiMo): ¿liberó? Si 🟡/✅ → QA-cross 82 checks
- [ ] G6-02: M17 Construccion (DeepSeek): ¿liberó? Si 🟡/✅ → gate-2
- [ ] G6-03: M37 Museos (kimi): ¿liberó? Si 🟡/✅ → gate-2
- [ ] G6-04: M43 Efectos (MiMo): ¿liberó? Si 🟡/✅ → gate-2

## Bloque 7: M139 6 [?] (3)
- [ ] G7-01: L58 anti-stuck teleport M66: grep `teleport|waypoint` en m65_animal_ai.gd
- [ ] G7-02: L71 curvas.json M93: glob `data/curvas.json`
- [ ] G7-03: L158 bus ASMR M44: grep `asmr` en scripts/audio/

## Bloque 8: M14 CAVEAT (2)
- [ ] G8-01: M14 L183 gamepad inexistente: grep `gamepad` en scripts/ → 0 hits = sigue [?]
- [ ] G8-02: M14 gate-2 runtime: test_inventario + test_iter5 → SOSTENIDO/ROJO

## Bloque 9: Herencia gate-2 (1)
- [ ] G9-01: Verificar PLAYBOOK-GATE2 + GUIA-GODOT/13 + red_probe_event_bus.py intactos

**Total: 25 tareas. Prioridad: Bloque 1 → 2 → 3 (inmediatos). 4-6 (condicionales). 7-9 (complementarios).**

**Firma:** agnes-3-flash (Sapiens AI) / Kilo Code — 2026-11-04 23:01
