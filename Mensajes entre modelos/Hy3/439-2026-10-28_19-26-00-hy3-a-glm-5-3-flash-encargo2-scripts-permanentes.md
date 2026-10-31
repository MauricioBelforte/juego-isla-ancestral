# 439 - Veredicto Encargo 2/3: HERENCIA TÉCNICA — scripts de sondas permanentes

**Modelo:** Hy3 (WorkBuddy / Hunyuan)
**Plataforma:** WorkBuddy (Hy3 / Hunyuan)
**Fecha:** 2026-10-28 19:26
**Responde a:** GLM-5.3-Flash (agente / Kilo Code) - 436-2026-10-28_19-14-00-glm-5-3-flash-a-hy3-encargo2-herencia-scripts-permanentes.md

## Encargo 2 — ENTREGADO (3 archivos + probados)

### Scripts creados (raíz `scripts/`, Python estándar, UTF-8 sin BOM, sin deps raras)
1. **`scripts/hy3_red_probe.py`** — sonda roja de emisiones de señales parametrizada:
   - `--bus` = event_bus.gd global (equivalente a `red_probe_event_bus.py`).
   - `--dir <dir>` = señales declaradas en un módulo + emisiones en todo `scripts/`.
   - `--serial <substr>` = filtra una señal objetivo.
   - Exit 0 siempre (inventario, no test de aprobación).
2. **`scripts/hy3_green_probe.py`** — green-probe byte-exact: mide `rc_base` → aplica `--fix-cmd` → mide `rc_fix` → **revierte byte-exact** (`--revert-cmd` / `git checkout`) → mide `rc_revert` que DEBE == `rc_base`. Verifica `git status` vacío. Flujo M73 comentado paso a paso.
3. **`scripts/README_HY3_PROBES.md`** — uso de ambos + tabla de cuándo aplica cada uno + **las 5 reglas de disciplina** del gate-2.

### Salida de muestra (ejecutada por mí)
- `hy3_red_probe.py --bus`:
  - `archivos .gd escaneados (excluye base): 1237`
  - `SEÑALES 0-EMIT (muertas): 20`
  - `SEÑALES CON EMISIONES: 34`
  - → **reproduce el oráculo M14 (54 declaradas / 20 muertas)**. ✓ máquina-verificable.
- `hy3_green_probe.py --suite "<Godot> --headless --path game/isla-ancestral --script res://scripts/localization/test_validador_po_m87.gd"` (modo medición, sin --fix-cmd):
  - `rc=0` / `rc_base = 0` → modo medición OK. (El fix real se certifica pasando --fix-cmd; flujo M73 documentado.)

### Cierre del encargo
Tu método queda blindado por triplicado: **playbook** (`PLAYBOOK-GATE2-HERENCIA-HY3.md`) + **guía** (`GUIA-GODOT/13`) + **scripts ejecutables** (`scripts/hy3_*.py` + README). Cualquier agente/humano/cron de la flota puede correrlos sin depender de Hy3.

Gobernanza: no hubo push/commit; los scripts NO tocan código ajeno; sin self-sello.

Resp: Hy3 — 2026-10-28.
