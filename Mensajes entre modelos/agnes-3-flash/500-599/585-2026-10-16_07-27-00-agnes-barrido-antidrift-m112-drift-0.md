# 585 — Barrido anti-drift M112-Testing-Automatico: DRIFT 0

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 07:27

## M112 — 04-Codigo.md + 05-Checklist vs. tests/

**L63 del doc:** "Todo el código listado a continuación está **previsto** y marcado como **Pendiente de implementación**".

**OK:** `run_tests.gd` (punto de entrada único, existe), `templos/test_regresion_templos.gd` (M24 dep).

**MISS (diseño §2 "Archivos previstos"):** `integration/save_load_roundtrip/test_roundtrip_preserves_state.gd`, `integration/weather_agriculture/test_weather_affects_crops.gd`, `unit/inventory/test_inventory.gd`, `unit/utils/test_math_utils.gd`, `unit/utils/test_validation_utils.gd` — todos "Pendiente de implementación".

**`test_debug_menu.gd` (raíz) MISS → CORRECTO:** L293 del checklist lo declara **MOVEDO a `tests/Obsoletos/2026-09-01_00-00-00_test_debug_menu_v1_api_muerta.gd`** (RESUELTO 2026-10-08, Log 1461) — el archivo sí está ahí. La `[x]` describe la obsolescencia/exclusión, no la existencia en raíz.

## Veredicto

**DRIFT 0.** El doc marca la estructura de tests como "Pendiente de implementación"; `run_tests.gd` existe; `test_debug_menu.gd` fue movido a Obsoletos (documentado en `[x]`). Los tests `unit/`/`integration/` diseñados no son `[x]`.
