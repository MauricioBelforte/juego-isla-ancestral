# Log 1452: T-M112 extra — fix autorizado del CI testing.yml (M118): eliminado el `|| true` que hacía que el paso nunca fallara

**Fecha:** 2026-10-08
**Hora:** 01:58
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Encargo del director (msg 59, 2026-10-08): acepta T-M112/BUG-120 y **autoriza**
corregir `.github/workflows/testing.yml` (hallazgo #5 de los `[?]` delegados):
invocación en el modo ya probado del `run_tests.gd` v2c y **eliminación del
`|| true`**. Solo ese archivo; sin commit ni push; informe con el texto del paso
antes/después.

## Defectos corregidos (job `test`, paso "Run tests")

**Antes:**
```yaml
godot --headless -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --path res://tests --verbose 2>&1 || true
```
1. `--path res://tests` **no es un flag de GdUnit4** (lo consumía Godot como
   directorio de proyecto) y **no había `-a`**: el parser no escaneaba suites →
   mismo modo de fallo silencioso que BUG-120 (0 tests).
2. `|| true` forzaba exit 0 siempre → **el paso y el `quality-gate` pasaban
   aunque todo fallara** (falso-verde a escala de CI).

**Después:**
```yaml
godot --headless -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/foto \
  -a res://tests/unit/inventario \
  -a res://tests/unit/ui \
  -a res://tests/unit/debug \
  --ignoreHeadlessMode 2>&1
```
- Misma invocación verificada del `run_tests.gd` v2c: `-a <dirs>` +
  `--ignoreHeadlessMode` (sin ese flag GdUnit sale con 103); sin `--` ni
  `--path`.
- Sin `|| true`: si una suite falla, el paso falla → `quality-gate` (que ya
  compara `needs.test.result`) deja el CI **rojo a la vista**.
- Comentario YAML en el archivo documentando defectos, invocación y alcance.

## Alcance y límites

- Este job es **solo GdUnit4** por diseño (su nombre ya lo decía): 4 dirs, 21
  test cases. Las 22 suites `extends SceneTree` **no pertenecen a GdUnit4** y
  las cubre `run_tests.gd` en local (documentado en el propio YAML y en
  11-BUGS → BUG-120). No es "excluir suites para arreglar el CI".
- **NO tocados** (mismo archivo, fuera de la autorización): los `|| true` de
  los pasos `Check formatting` y `Run static analysis` del job `lint` →
  reportados al director en el msg 60 para instrucción.
- `quality.yml` intocado (restricción). Otros workflows intocados.

## Evidencia

- **YAML válido** tras el cambio (`yaml.safe_load` OK, 3 jobs).
- **Paso nuevo ejecutado localmente con la invocación exacta** (Godot 4.7.2,
  cwd `game/isla-ancestral`):
```
Overall Summary: 21 test cases | 0 errors | 0 failures
Executed test suites: (4/4)
Executed test cases : (21/21)
EXIT 0
```
- No se ejecutó GH Actions (no corresponde acá): la evidencia es el texto del
  paso + la misma invocación corriendo 21/21 en local.
- En CI, este paso queda **verde legítimo** con las suites GdUnit4 como están
  hoy; las 3 suites rotas (SceneTree) no forman parte de este job.

## Archivos modificados/creados

- `.github/workflows/testing.yml` (paso `Run tests` reescrito + documentación)
- `DOCUMENTACION/11-BUGS.md` → BUG-120: hallazgo #5 marcado RESUELTO (archivo
  M con contenido de otros agentes → no se indexó)
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/04-Codigo.md` (fila de la
  tabla de artefactos actualizada)
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md`
  (`[?]` → `[x]` de testing.yml; totales T-M112 → 13 [x] / 4 [?])
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md`
- `Mensajes entre modelos/mimo-v2.6-flash-free/60-…` (informe de cierre)
- `Logs/NUMEROS_DISPONIBLES.txt` (reserva 1452)

## Reglas

Sin commit ni push (staging selectivo del director). `quality.yml`,
otros workflows, `interaction_manager`, `service_registry`, `bootstrap`,
`main_island` y CHECKLIST-GLOBAL no tocados.
