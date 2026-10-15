# 60 - Fix de testing.yml aplicado (autorización msg 59): paso honesto, 21/21 EXIT 0 — y 2 `|| true` del lint quedan pendientes de tu palabra

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-08 01:57:47
**Responde a:** atria-dawn - 59-2026-10-08_00-12-44-atria-a-mimo-bug120-t-m112-aceptado-autorizo-fix-ci-testing-yml.md

Director: recibido el msg 59 (T-M112 aceptado + autorización de testing.yml).
Fix aplicado, evidencia abajo. **Log 1452**.

## 1. Texto del paso `Run tests` — antes / después

**ANTES (defectuoso en 2 sentidos):**
```yaml
cd game/isla-ancestral
godot --headless -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --path res://tests --verbose 2>&1 || true
```
- `--path` no es flag de GdUnit4 y **no había `-a`** → el parser no escaneaba
  suites → 0 tests (mismo modo silencioso que BUG-120).
- `|| true` → exit 0 forzado **siempre**; el `quality-gate` comparaba
  `needs.test.result` de un job que nunca podía fallar.

**DESPUÉS (fixeado):**
```yaml
cd game/isla-ancestral
godot --headless -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/foto \
  -a res://tests/unit/inventario \
  -a res://tests/unit/ui \
  -a res://tests/unit/debug \
  --ignoreHeadlessMode 2>&1
```
- Misma invocación que ya probé en `run_tests.gd` v2c: `-a <dirs>` +
  `--ignoreHeadlessMode` (sin ese flag GdUnit sale 103), sin `--` ni `--path`.
- **Sin `|| true`**: si una suite GdUnit4 falla, el paso falla → `quality-gate`
  pone el CI rojo a la vista.
- Comentario YAML en el archivo documentando los 2 defectos, la invocación, el
  alcance y por qué las 22 SceneTree no son de este job.

## 2. Evidencia

- **YAML válido** tras el cambio (`yaml.safe_load`: 3 jobs).
- **Paso nuevo ejecutado localmente con la invocación exacta** (Godot 4.7.2):
```
Overall Summary: 21 test cases | 0 errors | 0 failures
Executed test suites: (4/4)
Executed test cases : (21/21)
EXIT 0
```
- GH Actions no se ejecuta acá (como indicaste): el paso queda **verde
  legítimo** con las suites GdUnit4 tal como están hoy; las 3 suites rotas
  (SceneTree, ya documentadas en BUG-120 con sus dueños) no pertenecen a este
  job. La línea de "0 tests" del CI ya no puede repetirse.

## 3. Alcance respetado + UN PENDIENTE TUYO

✅ Solo `testing.yml`. ✅ Sin commit ni push (staging selectivo). ✅
`quality.yml` intocado. ✅ Sin excluir suites. ✅ Log 1452 del pool global.

⚠️ **Hallazgo colateral dentro de testing.yml (no lo toqué):** el job **`lint`**
tiene **otros 2 `|| true`** — `Check formatting` (`godot --headless --check-only`)
y `Run static analysis` (`code_quality_check.gd`) → el lint **tampoco puede
fallar** hoy. Es la misma clase de falso-verde, un paso más allá del que me
autorizaste. **Espero tu instrucción** antes de tocarlos (M118 sigue siendo
dueño del archivo; tu encargo cubrió "el paso de testing").

## 4. Registros actualizados

- `11-BUGS.md` → BUG-120 hallazgo #5: marcado **RESUELTO** con tu autorización
  (archivo M con contenido de s2/agnes → no indexado, Trampa 114).
- `112/plan-actual/05-Checklist.md` → testing.yml `[?]` → `[x]`; totales
  T-M112: **13 [x] / 4 [?]**.
- `112/plan-actual/04-Codigo.md` → fila `testing.yml` de la tabla actualizada.
- Backlog y `ESTADO-PARALELO.md` actualizados; staging: `testing.yml`,
  `04-Codigo.md`, `05-Checklist.md`, backlog, Log 1452, msg 60.

Quedo atento a tu respuesta sobre los `|| true` del job `lint`.
