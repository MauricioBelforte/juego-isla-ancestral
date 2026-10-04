# 14 — CI: job 3/5 UTF-8 arreglado, job 4/5 M62 diagnosticado (report-only)

**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04 06:42:00
**Responde a:** `10-2026-10-04_06-52-00-ci-rojo-cinco-jobs.md`

## Resumen del encargo

Avance sobre los 5 jobs rojos. Cierre del turno por directiva del usuario ("manana seguimos"). Quedan 1 job pendiente (M112) + 1 report-only (M62).

## Job 3/5 — UTF-8 sin BOM: ARREGLADO

El job seguia rojo en el run `37190114175` aunque el BOM de `NUMEROS_DISPONIBLES.txt` ya estaba removido. El step que falla es `python3 scripts/diagnosticar_mojibake.py` (exit 1).

**Diagnostico:** el `--selftest` pasa 28/28 (detector sano). La corrida real marca 1 archivo SUCIO:

- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md` **L913**
- No es la cita intencional de la regla de L12 (esa la excluye `PAT_LINEA_DOC`). Es un **signo de seccion doble-codificado real** (U+00C2 + U+00A7) en una linea de tus propias lecciones de git:
  `- git add con pathspec; ... Push con huella §4.3 si cerras iteracion.`
- Doble codificacion clasica de cp1252. 1 sola ocurrencia en el archivo.

**Fix:** respaldo en `Obsoletos/encoding-backup-2026-10-04_08-58`, reemplazo del par por el signo correcto, reescritura UTF-8 sin BOM. Verificado: `diagnosticar_mojibake.py` = **SUCIO 0 / IRREVERSIBLE 0**, `verificar_bom.py` = exit 0.

El backlog es de Hy3 (otro agente), pero la regla de codificacion es higiene del repo y el fix es de 1 byte, sin cambio semantico. Lo aviso en su canal por cortesia.

Commits: `30a3a02` (fix) + `f0a934b` (huella push). Log 1275.

## Job 4/5 — Architecture Guard (M62): DIAGNOSTICADO, report-only

Falla con exactamente 1 hallazgo nuevo:

```
A2|SubtitleManager->DataStore
```

**Es un hallazgo REAL, no falso positivo.** Regla A2 (orden de autoloads):

- `game/isla-ancestral/scripts/ui/subtitle_manager.gd:286` y `:306` llaman a `get_node_or_null("/root/DataStore")`.
- Alcanzables desde `_ready()`: L65 -> `_cargar_config()` (L67) -> L286.
- En `project.godot`, `SubtitleManager` se declara **antes** que `DataStore`.
- Violacion de la regla de capas (no de runtime: en `_ready()` todos los autoloads existen, medido en Godot 4.7.2).
- La API usada (`cargar_config`/`guardar_config`) SI existe en `data_store.gd` L404/L411. No hay stale code.

**Introducido por** `80819e1` (2026-10-02, "modulo 91 lote 3", **mimo-v2.6-flash-free**, Log 198). M91 esta asignado a ese modelo.

**Por la regla del director (no arreglar modulos ajenos) no lo toco.** Reporto para que se lo pases a mimo-v2.6-flash-free:

- Archivo: `game/isla-ancestral/scripts/ui/subtitle_manager.gd` lineas 286, 306
- Tambien: `game/isla-ancestral/project.godot` (orden de la seccion `[autoload]`)
- Fix sugerido: mover la declaracion de `DataStore` antes de `SubtitleManager` en `project.godot`, o diferir la carga fuera de `_ready()`.

## Estado de los 5 jobs (run `37190114175`, commit `4b9b2bb`)

| Job | Estado | Nota |
|---|---|---|
| UTF-8 sin BOM | OK arreglado | Log 1275, commits `30a3a02`+`f0a934b` |
| Legal Tooling (M127) | OK arreglado | confirmado **success** en el run; Log 1274 |
| GDScript Linter | no tocar | esperado: gate BUG-091 duro por diseno |
| Architecture Guard (M62) | report-only | A2 real, codigo de mimo-v2.6-flash-free |
| Run Test Suite (M112) | pendiente | manana |

## Pendiente manana

1. **Run Test Suite (M112)** — job `111400340017` del run `37190114175`, step "Run validation tests", ~2 min.
2. **Evaluar la trampa del `--script`** (tu canal 11): mi gate modo A usa `--check-only --script`, que no carga autoloads. Puede sumar falsos SCRIPT ERROR. Pendiente ver si necesita ajuste.
3. Si queres que arregle el A2 de M62, confirma y lo hago (es un cambio de 1 linea en `project.godot`, pero es modulo de mimo).

## Huella de push

`4b9b2bb..30a3a02` y `30a3a02..f0a934b` (main -> main), 2026-10-04, atria-dawn-s2 / Kilo Code.
