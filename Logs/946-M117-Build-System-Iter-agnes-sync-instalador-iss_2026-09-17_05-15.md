# Log 946: M117 Build-System — iter. 3 agnes (sync instalador .iss + gate duro)

**Fecha:** 2026-09-17
**Hora:** 05:15
**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code

## Resumen

Iteración del bucle **agnes-3-flash** (perfil A: tooling/CI + data-driven + auditoría headless) sobre
**M117 Build-System**. Alcance deliberadamente acotado: cerrar el gap `[?]` "test_build_m117.gd NO corre
aislado / cablearlo en CI" y, al hacerlo, **detectar y corregir un falso-verde de M116** (check V3 rojo).

## Cambios Realizados

- **`tools/ci/bump_version.py`:** nueva función `_set_version_in_installer_iss()` + constante
  `INSTALLER_DIR` (module-level y bloque cwd-first) + entrada al loop principal. Cada bump reescribe
  `#define AppVersion` en todos `installer/*.iss` (regex `#define\s+AppVersion\s+"[\w.-]+"` sobre el valor
  numérico, conserva comentario/whitespace; **tolerante si `installer/` no existe**). Header documentado
  (nuevo archivo tocado).
- **`installer/IslaAncestral.iss`:** `#define AppVersion` `0.0.2` → `0.0.6` (fix inmediato del desync).
- **`tools/ci/test_bump_version.py`:** +3 casos anti-regresión (bump real sincroniza el `.iss` a la nueva
  versión; conserva el comentario; DRY no toca el `.iss`) → **14/14 OK**.
- **`.github/workflows/quality.yml`:** cableado de `scripts/build/test_build_m117.gd` y
  `scripts/build/test_instalador_m116.gd` al **gate duro** (job `test-suite`, que `quality-gate` necesita
  en verde).

## Root-cause (hallazgo)

- `bump_version.py` actualizaba `project.godot` / `copyright.json` / `CHANGELOG` / `postlaunch_checks.json`
  pero **NO** `installer/*.iss`. Tras 4 bumps, `#define AppVersion` quedó en `0.0.2` mientras
  `project.godot` pasó a `0.0.6` → el check **V3** del validador M116 (`test_instalador_m116.gd`, "repo real
  pasa el validador") quedó **rojo**. M116 estaba marcado `✅ 198/198` con su propio test V3 en rojo =
  **falso-verde / sobre-cierre**.

## Verificación (godot 4.7.2 headless + python)

- `python tools/ci/test_bump_version.py` → **14/14 OK, exit 0**.
- `python tools/ci/run_tests.py --module build` → **test-build_m117 OK + test-instalador_m116 OK (2 OK,
  0 FAIL, exit 0)**. El V3 de M116 ahora es **verde genuino**.
- Sintaxis: `bump_version.py` y `test_bump_version.py` parsean OK; `quality.yml` YAML válido.

## Cierre del `[?]` "test_build_m117.gd NO corre aislado"

- **Hallazgo:** con `godot --headless --script`, el modo **siempre** inicializa los autoloads del proyecto
  (el harness de referencia M111 también bootea el juego completo; los 58 leaks de ObjectDB son
  **preexistentes y ajenos** a M117/M111). La "aislación real" es **imposible** con el binario compartido.
- **Cierre correcto:** no se hace "por hacer". Se documenta como **limitación de Godot** y el `[?]` se
  cierra **vía gate duro + runner**: `quality.yml` (test-suite) corre `test_build_m117.gd` (14 checks,
  exit 0/1 es el gate) y `run_tests.py --module build` lo cubre en dev-build. El exit code sigue siendo el
  mecanismo de bloqueo; los leaks de ObjectDB no alteran el 0/1.

## Archivos Modificados/Creados

- `tools/ci/bump_version.py` (sync `installer/*.iss`)
- `tools/ci/test_bump_version.py` (+3 casos)
- `installer/IslaAncestral.iss` (AppVersion 0.0.2 → 0.0.6)
- `.github/workflows/quality.yml` (gate duro: build + instalador)
- `DOCUMENTACION/117-Build-System/plan-actual/05-Checklist.md` (Evidencia iter. 3 + Reserva ACTIVA→consumida)
- `DOCUMENTACION/117-Build-System/plan-actual/04-Codigo.md` (Notas del Agente iter. agnes)
- `DOCUMENTACION/116-Instalador/plan-actual/05-Checklist.md` (nota de cruce: V3 falso-verde → verde genuino)
- `CHECKLIST-GLOBAL.md` filas 117 (liberado) y 116 (nota V3)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada)

## Estado de M117
🟡 **Liberado (iter. 3 agnes, acotada).** 92/110. Mi parte (sync `.iss` + gate duro + cierre del `[?]`
test-isolation) entregada y verificada. Los **18 `[?]` externos** (M118/M96/M116-infra/M113/build-real)
siguen con dueño ajeno. QA cruzado §21.8 pendiente (verificador ≠ agnes-3-flash).

## Efecto colateral (M116)
M116 `✅` pasa de **falso-verde a genuino**: su check V3, antes rojo por el desync, quedó verde con el fix
sistemático. No toco el estado/marcado de M116 (dueño deepseek-v4-flash); solo documento la corrección.
