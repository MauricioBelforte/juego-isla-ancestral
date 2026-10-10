# 14 - E-11 barrido stale — MITAD 1 de 2 (BUG-103, BUG-076, BUG-078, BUG-094)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 20:05:03
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 13-2026-10-09_18-56-23-atria-a-stepfun-step-5-preview-correccion-e11-bug104-resuelto-nuevo-encargo-barrido-stale.md

## Resumen de la mitad 1

| Bug | Veredicto | Estado real |
|---|---|---|
| BUG-103 | **VIVO** 🔴 | los 3 logs siguen sin decodificar (medido hoy) |
| BUG-076 | **RESUELTO** ✅ | los 2 jobs infalsables ya no existen / tienen gate duro |
| BUG-078 | **RESUELTO** ✅ | los 8 scripts existen y están versionados (medido) |
| BUG-094 | **RESUELTO** ✅ | las 3 APIs muertas ya no se llaman (convertidas a headless) |

**+ HALLAZGO CRÍTICO NUEVO:** `quality.yml` tiene **YAML inválido en L239** (col 11) → GitHub rechaza el archivo COMPLETO y **se apaga el CI entero**. Causa: una línea comentada sin indentar (L236, ajena a mí). Lo reporté y **no lo toqué**.

## BUG-103 — VIVO (medido hoy, 2026-10-09)

**Veredicto: STALE NO — el bug sigue VIVO tal como está registrado.**

Comando: `python scripts/verificar_cjk.py` — salida (fragmento):

```
ARCHIVOS ILEGIBLES (texto que no es UTF-8 valido):
  Logs/353-M53-UI-UX-InventoryLayer_2026-08-30_20-25-00.md no es UTF-8 valido (byte 31, razon: invalid start byte)
  Logs/354-M16-M38-Coste-AO-Crafting_2026-08-30_20-35-00.md no es UTF-8 valido (byte 19, razon: invalid start byte)
  Logs/358-sincronizacion-doc-vs-codigo-m07-m15-m29-m30-m38-m39-m66_2026-08-30.md no es UTF-8 valido (byte 23, razon: invalid continuation byte)
VEREDICTO: FALLA — 287 CJK + 3 ilegibles + 4 BOM.
```

Los **mismos 3 archivos** y los **mismos offsets** (31, 19, 23) que registró el reporte original (SB-07, Log 1296). El bug está correctamente abierto; no se ha hecho la transcodificación cp1252 → UTF-8. **No toqué nada** (el director los marcó como históricos; el fix requiere su aprobación explícita, que sigue pendiente).

Nota para el director: el mismo gate también reporta **287 caracteres CJK** en archivos vivos (`npc_watchdog.gd`, `state_machine.gd`, `crear_gaviota_lowpoly.py`, `legal/evidencia/autoria-repo…txt`) — **no es BUG-103** (esa es otra familia: AGENTS.md §28 prohíbe CJK), pero conviene que conste.

## BUG-076 — RESUELTO ✅ (quedó marcado `[ ] Abierto` pero está cerrado en disco)

Evidencia en `.github/workflows/quality.yml`:

1. **Job `code-quality-script` — ELIMINADO.** L72-92 documentan la resolución: *"BUG-122 (gemelo en quality.yml) RESUELTO (2026-10-08, DeepSeek-V4.1-Flash)… El job `code-quality-script` era un FALSO VERDE estructural… Decisión: RETIRAR el job + sacarlo del `needs` del summary"*. Ya no existe el job en el archivo (grep de `code-quality-script:` → sin match de definición de job).
2. **Job `formatting-check` — GATE DURO real.** L60-70:

```
FAIL=0
LINT_LOG=$(mktemp)
godot --headless --check-only --script res://scripts/editor/_colector_sintaxis.gd 2>&1 | tee "$LINT_LOG" || true
PARSE_ERRORS=$(grep -c "SCRIPT ERROR" "$LINT_LOG" || true)
...
if [ "$PARSE_ERRORS" -gt 0 ]; then
  echo "GATE DURO BUG-091: $PARSE_ERRORS SCRIPT ERROR en scripts del proyecto"
  FAIL=1
fi
echo "Godot headless lint completed (FAIL=$FAIL)"
exit $FAIL
```

El `|| true` de L62 es **legítimo** (patrón `tee` + conteo + `exit $FAIL` documentado). El segundo job infalsable del bug (`formatting-check`, L107 original) fue reconvertido el 2026-10-06 (L96-101: `--check-only` sin `--script` causaba timeout; con `--script` termina en segundos).

**Los dos `|| true` que el bug denunciaba ya no existen como defecto.** Mi propia entrega E-09 (los 9 tests) es coherente con este mismo frente ya avanzado por s2/DeepSeek.

## BUG-078 — RESUELTO ✅ (registrado "Parcialmente resuelto", hoy está completo)

Los 8 scripts citados por el job `godot-lint` — verificados con `Test-Path` + `git ls-files --error-unmatch` (la medición que el propio bug pide, porque `ls` miente):

| script | disco | git |
|---|---|---|
| `scripts/player/test_player_m11.gd` | ✅ | ✅ versionado |
| `scripts/ia_npc/test_navegacion_m64.gd` | ✅ | ✅ versionado |
| `scripts/ia_npc/test_social_m64.gd` | ✅ | ✅ versionado |
| `scripts/ia_npc/test_rendimiento_m64.gd` | ✅ | ✅ versionado |
| `scripts/ia_npc/test_persistencia_m64.gd` | ✅ | ✅ versionado |
| `scripts/ia_npc/test_ia_npc_m64_iterN.gd` | ✅ | ✅ versionado |
| `scripts/build/test_instalador_m116.gd` | ✅ | ✅ versionado |
| `scripts/build/test_build_m117.gd` | ✅ | ✅ versionado |

**Los 8 existen y están versionados.** El `DEUDA_CONOCIDA` de `validar_workflows.py` ya no es necesario para ellos.

## BUG-094 — RESUELTO ✅ (registrado `[ ] Abierto`, hoy cerrado)

`git grep` sobre `game/isla-ancestral/tests/` de las 3 APIs muertas:

- **0 llamadas reales.** Los únicos matches son (a) comentarios documentales en 10 archivos convertidos (`is_instance_of inexistente -> el real es is_instanceof`), y (b) usos dentro del propio addon `addons/gdUnit4/` (donde `is_instance_of` es el builtin del motor,correcto ahí).
- Los 3 sitios originales quedaron convertidos al estándar headless del proyecto con aserciones nativas:
  - `tests/unit/interfaces/test_i_saveable.gd:148` → `_check("data .is_instance_of(Dictionary)", (data) is Dictionary)`
  - `tests/unit/player/test_equipment_manager.gd:427` → `_check("unlocked .has_not_contains(...)", not (... in ...))`
  - `tests/unit/editor/test_recipe_schema.gd:133` → `_check("...has_any_item(...)", (...) in (...))`

Mismo mecanismo que BUG-093 (familia 1ª) y mismo desenlace: convertidas y en verde.

## HALLAZGO CRÍTICO NUEVO (no es del barrido — lo entrego porque rompe TODO el CI)

**`python scripts/validar_workflows.py` → `❌ quality.yml — YAML INVALIDO en linea 239, col 11: expected <block end>, but found '<scalar>'`.**

Causa exacta: **L236 de `.github/workflows/quality.yml`** — la línea que atria-dawn comentó para BUG-104 quedó en **columna 0** ("# ELIMINADO por atria-dawn 2026-10-09…") en medio de un bloque `run:` indentado. Un comentario sin indentar dentro de una lista YAML rompe el documento completo. Los otros 5 workflows validan OK; solo quality.yml.

**Impacto:** GitHub rechaza el archivo entero → el CI completo del repo queda apagado, no solo un job. **NO LO TOQUÉ** (es de atria-dawn, del día de hoy y zona de otro agente) — lo reporto para que el director lo derive/arregle. El fix es de 1 carácter (indentar la L236 al mismo nivel que L237).

## Estado del barrido

Mitad 1 entregada (4/4 con evidencia). Mitad 2 pendiente: **BUG-052, BUG-074, BUG-034, BUG-065** — la entrego a continuación. READ-ONLY sobre `11-BUGS.md` y `CHECKLIST-GLOBAL.md` respetado: **0 ediciones**, sin commits, sin tocar `quality.yml`.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 20:05:03
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 13-2026-10-09_18-56-23-atria-a-stepfun-step-5-preview-correccion-e11-bug104-resuelto-nuevo-encargo-barrido-stale.md
