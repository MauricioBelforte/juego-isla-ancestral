# Log 1275: CI job UTF-8 arreglado (mojibake en backlog Hy3) + M62 diagnosticado (report-only)

**Fecha:** 2026-10-04
**Hora:** 06:31
**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code

## Resumen

Tercer job de los 5 rojos del encargo del director (canal 10): **UTF-8 sin BOM (AGENTS seccion 28)**. Diagnosticado y arreglado. Ademas se diagnostico el cuarto job, **Architecture Guard (M62)**, que resulta ser codigo de otro agente y se deja como reporte (regla del director: no arreglar modulos ajenos).

## Cambios Realizados

### Job 3/5: UTF-8 sin BOM (AGENTS seccion 28) - ARREGLADO

El job seguia en rojo en el run `37190114175` (commit `4b9b2bb`) aunque el BOM de `NUMEROS_DISPONIBLES.txt` ya se habia removido en `e564605`. El step que falla es `python3 scripts/diagnosticar_mojibake.py` (exit 1).

Diagnostico:
- El `--selftest` pasa (28/28 casos), asi que el detector esta sano.
- Ejecutado localmente: 1 archivo SUCIO.
- Aislado con el propio patron del detector: `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md` **L913**.
- El hallazgo NO es la cita intencional de la regla de L12 (esa la excluye `PAT_LINEA_DOC`, "caracteres rotos"): es un **signo de seccion doble-codificado real** (U+00C2 seguido de U+00A7) en la linea
  `- git add con pathspec; git diff --cached --name-only antes de cada commit; trabajo ajeno staged -> git reset -- <path>. Push con huella 4.3 si cerras iteracion.`
  Es la doble codificacion clasica de cp1252 (una A-circunfleja huerfana antes del signo de seccion legitimo de "seccion 4.3"). Una sola ocurrencia en todo el archivo.

Fix (minimo, sin tocar contenido semantico):
- Respaldado en `Obsoletos/encoding-backup-2026-10-04_08-58_Hy3-BACKLOG-MASTER.md` (AGENTS.md seccion 5).
- Reemplazado el unico par mojibake por el signo de seccion correcto con Python puro, reescrito en UTF-8 sin BOM.
- Verificado: `python scripts/diagnosticar_mojibake.py` entrega **SUCIO 0, IRREVERSIBLE 0** ("LIMPIO: no queda mojibake reparable").

Nota: el backlog de Hy3 es de otro agente, pero la regla de codificacion es de higiene del repositorio y el fix es de un byte de ancho; no cambia ninguna tarea ni estado. Se informa en el canal de Hy3 por cortesia y en mi canal para el director.

### Job 4/5: Architecture Guard (M62) - DIAGNOSTICADO, report-only

El job falla con exactamente 1 hallazgo nuevo:

```
-- Hallazgos NUEVOS (no permitidos): 1
     A2|SubtitleManager->DataStore
```

Regla A2 (orden de autoloads): un autoload alcanza con `get_node_or_null("/root/X")` desde su `_ready()` a otro autoload declarado **despues** de el. Hallazgo REAL, no falso positivo:

- `game/isla-ancestral/scripts/ui/subtitle_manager.gd:286` y `:306` llaman a `get_node_or_null("/root/DataStore")`.
- Ambas son alcanzables desde `_ready()`: `subtitle_manager.gd:65` -> `_cargar_config()` (L67) -> L286.
- En `project.godot`, `SubtitleManager` se declara **antes** que `DataStore` (DataStore esta detras de SceneManager/PantallaCarga).
- Es violacion de la regla de capas del diseno, no de runtime (en `_ready()` todos los autoloads ya existen; medido en Godot 4.7.2 por el propio auditor).
- La API usada (`cargar_config()`/`guardar_config()`) SI existe en `data_store.gd` (L404/L411), asi que no hay stale code: es solo el orden de declaracion.

Introducido en el commit `80819e1` ("Se implemento el autoload de subtitulos del modulo 91 (lote 3)", 2026-10-02 20:07, **mimo-v2.6-flash-free**, Log 198). M91 esta asignado a mimo-v2.6-flash-free. **Por la regla del director no se arregla**: se reporta con archivo + lineas.

El camino correcto para el dueno de M91 es mover la declaracion de `DataStore` antes de `SubtitleManager` en `project.godot` (o diferir la carga fuera de `_ready()`).

### Estado de los 5 jobs (run `37190114175`, commit `4b9b2bb`)

| Job | Estado | Nota |
|---|---|---|
| UTF-8 sin BOM (AGENTS 28) | OK arreglado | este log (mojibake en Hy3 backlog L913) |
| Legal Tooling Tests (M127) | OK arreglado | confirmado **success** en el run; falso positivo shallow clone (Log 1274) |
| GDScript Linter | no tocar | esperado: el gate BUG-091 es duro por diseno (director) |
| Architecture Guard (M62) | report-only | A2 `SubtitleManager->DataStore`, codigo de mimo-v2.6-flash-free |
| Run Test Suite (M112) | pendiente | manana |

## Archivos Modificados/Creados

- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md` (L913: signo de seccion doble-codificado -> correcto)
- `Obsoletos/encoding-backup-2026-10-04_08-58_Hy3-BACKLOG-MASTER.md` (respaldo)
- `Logs/1275-ci-job-utf8-mojibake-m62-report_2026-10-04_06-31.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1275 consumido; nueva cabeza 1276)

## Huella de push (AGENTS.md seccion 4.3)

Push principal: `4b9b2bb..30a3a02` (main -> main), 2026-10-04, atria-dawn-s2 / Kilo Code. Commit `30a3a02` "Se arreglo el job UTF-8 de CI (mojibake en backlog de Hy3)". Sin catch-ups.
