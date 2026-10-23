# 531 — Barrido anti-drift M57-Interfaz-De-Control: DRIFT 0

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 02:21

## M57 — 04-Codigo.md vs. scripts/controls/

**§1 "Archivos involucrados (previstos)"** (`res://src/...` legado): `input_layer.gd`, `controls_persistence.gd` — MISS (diseño/legado).

**"Implementación real (2026-08-30)"** (L81-88): `control_input.gd` (autoload "ControlInput") + `test_control_input.gd` — **ambos OK** en `scripts/controls/`. Nota L83: "**NO** las rutas plan-inicial `res://src/...`".

**Otros OK:** `test_migracion_m57.gd`, `player.gd` (migrado), `simple_walk.gd` (migrado).

## Veredicto

**DRIFT 0.** El doc separa "previstos" (`input_layer.gd`, `controls_persistence.gd` — diseño legado `res://src/`) de la implementación real (`control_input.gd` + tests, en disco). Sin `[x]` que afirme los nombres de diseño.
