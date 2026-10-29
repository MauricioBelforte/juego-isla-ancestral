# HY3 PROBES — Sondas de runtime del GATE-2 (model-agnostic)

Tres herramientas permanentes para que CUALQUIER agente / humano / cron verifique
módulos de *Isla Ancestral* (Godot 4.7.2) sin depender de Hy3. Heredadas del
`PLAYBOOK-GATE2-HERENCIA-HY3.md` + `DOCUMENTACION/GUIA-GODOT/13-sondas-runtime-gate2.md`.

> El gate-2 NO pertenece a ningún agente: pertenece al repositorio. Estos scripts
> son la capa mecánica (máquina-verificable) del método.

## 1. `hy3_red_probe.py` — sonda roja de emisiones de señales

Cuenta emisiones estáticas `.<señal>.emit(` en los `.gd` y reporta señales
0-emit (muertas) vs usadas. **No bootea Godot** (es inventario estático).

```bash
python -X utf8 scripts/hy3_red_probe.py --bus
      # event_bus.gd global (oráculo M14 Hy3 27oct: 54 declaradas / 20 muertas)
python -X utf8 scripts/hy3_red_probe.py --dir game/isla-ancestral/scripts/inventario
      # señales declaradas en el módulo + emisiones en todo scripts/
python -X utf8 scripts/hy3_red_probe.py --bus --serial item_removed
      # solo una señal objetivo
```

Salida: lista de señales 0-emit y de señales con emisiones + conteo. Exit 0 siempre.
Para **0-runtime-captura** real (boot headless) usar
`game/isla-ancestral/scripts/core/probe_runtime_bus_m14.gd`.

## 2. `hy3_green_probe.py` — green-probe byte-exact (certifica un fix)

Confirma que EL FIX (no el azar) pone en verde. Flujo: mide `rc_base` → aplica
`--fix-cmd` → mide `rc_fix` → **revierte byte-exact** (`--revert-cmd` / `git checkout`)
→ mide `rc_revert` que DEBE == `rc_base`.

```bash
python -X utf8 scripts/hy3_green_probe.py \
  --suite "GODOT --headless --path game/isla-ancestral --script res://scripts/X.gd" \
  --fix-cmd "edita X.gd ..." \
  --revert-cmd "git checkout -- game/isla-ancestral/scripts/X.gd" \
  --archivo game/isla-ancestral/scripts/X.gd
```

- Sin `--fix-cmd`: solo mide `rc_base` (modo medición).
- El script **no modifica código**; el `--fix-cmd` lo provee quien aplica el fix.
- Verifica `git status --short` vacío tras revert (byte-exact). Cualquier desvío → exit 1.

## 3. Cómo interpretar la salida

- **RED-PROBE:** "0-emit" = señal declarada pero nunca emitida en disco → posible
  señal muerta / huérfana. Cruza con el runtime (probe M14) antes de concluir.
- **GREEN-PROBE:** `rc_fix==espera_verde` Y `rc_revert==rc_base` = el fix es el
  causante. Si `rc_revert != rc_base`, el revert no fue exacto → ABORTA y rehaz.

## 4. Las 5 reglas de disciplina del gate-2 (sin ellas el método no vale)

1. **RED antes de creer:** inyecta un fallo y exige `EXIT 1` (el "0 fallos" no se hereda).
2. **MEDIR el piso en verde:** `CHECKS_MINIMOS` medido, nunca estimado.
3. **REVERTIR byte-exact y VERIFICAR** (`git status` vacío / `sha256`) tras cada sonda.
4. **NO auto-QA ni self-sello:** verificador ≠ autor; el sello lo pone el director.
5. **NUMERACIÓN honesta:** 1 número = 1 archivo; canal = `max(archivos en disco)+1`.

## 5. Cuándo aplica cada una

| Sonda | Cuándo | Qué certifica |
|-------|--------|---------------|
| `hy3_red_probe.py` | ante un "0 fallos" o censo de señales | señales muertas/huérfanas (estático) |
| `probe_runtime_bus_m14.gd` | para 0-runtime-captura real | emisiones en boot headless |
| `hy3_green_probe.py` | el autor propone un fix | el fix (no el azar) pone en verde |

Firma: Hy3 (verificador §21.8) — por herencia del fundador 27oct / GLM-5.3-Flash 28oct.
