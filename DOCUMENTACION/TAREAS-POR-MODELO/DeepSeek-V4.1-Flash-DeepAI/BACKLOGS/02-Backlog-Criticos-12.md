# DS-OC 12 Criticos + M17/M129 (post-criticos)

**Fuente:** agnes-3-flash (Cron D 9nov)
**Fecha:** 2026-11-09 09:05
**Estado:** ✅ 12/12 verificados en disco y con evidencia (2026-11-25, Deepseek V4.1 Flash-DeepAI, Log 2447)

## Criticos Nemotron (12 - prioridad)
- [x] VfxDirector: agregar _process/_exit_tree (RAM leak) — `vfx_director.gd:108` llama `actualizar(delta)`
  y `:111` `_exit_tree()` libera emisores; suite `test_vfx_m52_iter6.gd` **76/0**.
- [x] HealthComponent: validar NaN/negativo — `health_component.gd:126/138/151/157` filtran
  `is_finite` y clampean a `[0, max]`; `tests/unit/components/test_health_component.gd` **46/0**.
- [x] Logging: RAM leak — `logger.gd:16` eliminó el `log_buffer` muerto (nadie hacía append);
  `scripts/logging/test_logger.gd` **14/0**.
- [x] Save: pre-validation payload — `save_manager.gd:159` (cierre) y `:253` (guardado) llaman
  `SaveSchema.validar_previo_a_guardar`; `test_prevalidacion_payload_m59.gd` **25/0**.
- [x] DLC: manager — gate de propiedad cerrado por defecto (`dlc_manager.gd:184-187`).
  **Arreglado hoy:** `scripts/dlc/test_dlc_m120.gd` activaba sin registrar propiedad y quedaba en
  rojo (`[FAIL] isla_hielo activo`); ahora cubre el contrato completo: sin propiedad NO activa,
  con propiedad SÍ → **19/0**. Servicios **61/0**, unit `tests/unit/dlc/test_dlc_manager.gd` **50/0**.
- [x] Economía: retiro cero + tope saldo — `economy_manager.gd` (MAX_SALDO + `retirar_monedas`
  rechaza `total <= 0`); suites `test_topos_banda` **11/0**, `test_bug047_sell_only` **6/0**,
  `test_m38_economia_smoke` **7/0**.
- [x] M17 lote 1: circulación + apoyo alternativo — `tests/test_m17_circulacion.gd` **36/0**.
- [x] M129: stock + numeración — `merch_manager.gd` (reserva/venta numerada 1..N por
  SKU, con persistencia M59); `scripts/legal/test_merch_m129.gd` **58/0** re-verificado hoy.
- [x] M129: boot B-17/B-12-06 — `scripts/legal/test_merch_boot_m129.gd` **11/0**.
- [x] M17: tests (`test_m17_construccion_validacion` + `test_m17_suites_integracion`) — **44/0** y
  **17/0** (las 7 suites de `scripts/construccion/` en el circuito central).
- [x] Regresión M21/M162 (Hy3 524) — las **24** suites de `scripts/dialogos/` corridas hoy:
  **0 fallidas**.
- [x] Verificación global (300s headless) — `--headless --fixed-fps 60 --quit-after 18000`
  (18000 frames = 300 s simulados): **exit 0, 0 SCRIPT ERROR**; 8 líneas `ERROR:` de
  RID/renderer son ruido conocido de `--headless` (no hay servidor de render).

## Post-criticos (cuando los 12 cierren)
- [ ] M17: 31 `[ ]` restantes en `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md`
  (UI de modo, HUD, fantasmas, audio, navmesh, cross-module).
- [ ] M129: 54 items (merch/numeracion/boot) — **verificado: el 05-Checklist de M129 tiene 0
  pendientes**; los 54 del backlog eran el conteo previo al cierre v3 del 2026-11-06.

## Nota de método

Los 12 críticos estaban implementados antes de esta sesión (la nota "code changes ya en
worktree" era cierta), pero nadie los había verificado ni marcado. Esta tabla cambia eso: cada
`[x]` cita archivo:línea y una suite con su conteo real, corridos hoy. Único cambio de código de
la tanda: el test de DLC estaba desactualizado respecto de su propio gate.

**Firma:** Deepseek V4.1 Flash-DeepAI (DeepAI) — 2026-11-25 10:35