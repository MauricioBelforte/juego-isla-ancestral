# Log 1469: Frente B BUG-122 — job lint de testing.yml hecho honesto: parseo con colector reemplaza al check colgado y el paso de analisis estatico se retira con evidencia

**Fecha:** 2026-10-08
**Hora:** 05:20
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Frente B del msg 70 (director): resolver BUG-122 (los 2 pasos del job `lint`
de `.github/workflows/testing.yml`). Criterio del director: "el job lint debe
ser honesto: o funciona o no existe". Se aplicó eso, tocando **solo
testing.yml** (archivo sin restricción): el paso de formato colgado se
reemplazó por un gate de parseo que SÍ corre, y el paso de análisis estático
se retiró con evidencia (adaptarlo exige tocar `code_quality_check.gd`, de
M111, restringido por el propio msg 70 → pendiente de coordinación).

## Diagnóstico (medido en local, Godot 4.7.2)

1. **Paso `Check formatting`** — `godot --headless --check-only 2>&1`:
   SIN `--script` el flag no hace nada: Godot arranca el juego completo y
   **colgaba hasta `timeout-minutes: 10` en cada push/PR** (medido 02:23,
   Log 1453: >45 s y seguía corriendo).
2. **Paso `Run static analysis (CodeQualityCheck)`** —
   `godot --headless --script res://scripts/editor/code_quality_check.gd`:
   **FALLA SIEMPRE** con 2 ERROR estructurales (`Class 'EditorScript' can
   only be instantiated by editor` + `doesn't inherit from SceneTree or
   MainLoop`). El análisis estático **nunca se ejecutó en CI**.
3. **¿Se puede adaptar sin tocar el archivo de M111? — NO (sonda A):**
   wrapper temporal `extends SceneTree` que hace `load()` + `.new()` sobre
   `code_quality_check.gd` en headless:
   - `load()` → OK (el recurso carga).
   - `.new()` → **NULL** con `Class 'EditorScript' can only be instantiated
     by editor` + `Can't inherit from a virtual class`.
   Conclusión: cualquier adaptación real exige modificar
   `scripts/editor/code_quality_check.gd` (archivo de M111, restricción
   "avisame antes" del msg 70 §4).
4. **¿Hay linter/formatter gratis en headless? — NO (sonda C):**
   `--help` no expone flags de lint; `--check-only --script` sobre un script
   con variable sin usar **no imprime ninguna advertencia del linter
   nativo** configurado en `project.godot` (`linter/enable=true`); no hay
   gdtoolkit/gdformat instalado ni config `.gdformat`. Un check de formato
   real exigiría instalar gdtoolkit y medir el volumen de violaciones
   (decisión M118).

## Decisión (opciones ofrecidas por el director en el msg 70)

- **Paso 1 → REEMPLAZADO** por la receta de parseo ya probada en
  `quality.yml` (BUG-051/BUG-091): generador del colector
  (`tools/quality/gen_colector_sintaxis.py`), `--import` (cache de
  class_names) y conteo de `SCRIPT ERROR` como gate duro. Es exactamente la
  opción sugerida por el director ("`--check-only --script <checker>`").
  El paso se renombró a `Check GDScript parse (gate duro)`: dice lo que hace
  (parseo, no estilo) y el comentario YAML explica que formato real queda
  pendiente M118.
- **Paso 2 → RETIRADO con evidencia** (la otra opción ofrecida), con
  comentario YAML que documenta la sonda A y que la reintegración depende de
  coordinación director ↔ M111.

## Cambios realizados (solo `.github/workflows/testing.yml`)

1. Bloque de comentario del job reescrito: histórico BUG-122 + estado nuevo
   medido.
2. Paso `Check formatting` → `Setup Python` + `Generate syntax collector` +
   `Import project resources` + `Check GDScript parse (gate duro)` (sin
   `|| true` operativos; el conteo usa `grep -c ... || :` y el gate es el
   `exit 1` explícito sobre el conteo).
3. Paso `Run static analysis (CodeQualityCheck)` eliminado con su justificación.
4. Nombre del **job** (`GDScript Lint & Format`) y del workflow intactos
   (posible dependencia de branch protection — reportado al director).

## Evidencia

| Verificación | Resultado |
|---|---|
| Receta del paso nuevo en local (generar + import + check) | colector **971 preloads**, **0 SCRIPT ERROR**, **EXIT 0**, segundos |
| `yaml.safe_load(testing.yml)` | OK |
| `\|\| true` operativos en testing.yml | **0** (los 3 que quedan son comentarios históricos) |
| Runner completo DESPUÉS | **25 descubiertas / 0 excluidas / 19 OK / 718 tests / 3 fallos preexistentes** (idéntico al baseline del frente A) |
| Gate `scripts/templos/test_regresion_templos.gd` DESPUÉS | **76 checks, 0 fallos** (idéntico al baseline) |

Caveza honesta: los cambios son **solo YAML** — no se tocó ningún `.gd` del
juego (sondas A y C borradas; el colector regenerado localmente se restauró
a su versión commiteada). La regresión se corrió igual, por estándar del
director.

## Pendientes reportados al director (msg 71)

1. **M111:** adaptar `code_quality_check.gd` para headless (propuesta:
   extraer la lógica a una clase instanciable + runner SceneTree, manteniendo
   el EditorScript como envoltura de editor) → requiere su coordinación.
2. **quality.yml (restringido):** el job `code-quality-script` corre el
   MISMO comando roto con `|| true` (nunca falla) y sube un artefacto que no
   se genera → mismo bug enmascarado en el otro workflow.
3. Nombre del job `GDScript Lint & Format` conservado por branch protection
   (confirmar si renombrarlo a algo honesto rompe checks requeridos).

## Archivos modificados/creados

- `.github/workflows/testing.yml` (job `lint` reescrito)
- `DOCUMENTACION/11-BUGS.md` (BUG-122 → resuelto; **NO commiteado**, saneo
  del director)
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/04-Codigo.md` (fila
  testing.yml actualizada)
- `Logs/NUMEROS_DISPONIBLES.txt` (reserva 1469)
- `Mensajes entre modelos/mimo-v2.6-flash-free/71-…` (informe)
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md`

## Reglas

Commits locales selectivos autorizados (msgs 63/65/70), **sin push**.
`quality.yml` y `code_quality_check.gd` **intocados** (msg 70 §4).
`11-BUGS.md` y `ESTADO-PARALELO.md` NO se commitean.
