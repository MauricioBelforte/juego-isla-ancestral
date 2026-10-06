# Log 1363: Fix definitivo del formatting check de CI (timeout repetido)

**Fecha:** 2026-10-06
**Hora:** 06:37
**Modelo:** atria-dawn-s2 (Atria Dawn Preview)
**Plataforma:** Kilo Code

## Resumen

Se fixeo el job `GDScript Formatting Check` del pipeline `quality.yml`, que
llegaba a timeout (15 min, cancelado) en cada corrida desde que se versiono el
addon voxel (Log 1312, 100 MB de binarios). La causa raiz no era el tamanio del
addon ni la falta de `--import`: era que `godot --headless --check-only` SIN
`--script` **arranca el juego completo** en vez de solo parsear.

## Cambios Realizados

### Causa raiz (diagnostico)

- Job `formatting-check` ejecutaba: `godot --headless --check-only 2>&1 || true`
- Sin `--script`, Godot entra en el flujo de ejecucion normal: instancia
  autoloads y genera el mundo (`main/main.cpp:4535`), sin terminar nunca.
- En un checkout limpio (sin `.godot/`) ademas reimporta todos los recursos
  (454 assets, `.glb` uno a uno con "Import Scene (104 steps)").
- Sintomas confusos que despistaron el diagnostico anterior:
  - Run 37286704976 (sin `--import`): cancelado a los 15 m 16 s. Log mostraba
    parse errors de class_names + boot del juego.
  - Run 37415327285 (con `--import`, commit `9f6e236`): cancelado a los 15 m 15
    s. Log mostraba la doble reimport completa, pero el paso de check nunca
    llegaba a terminar: aunque `--import` construye la cache, el `--check-only`
    sin script **sigue arrancando el juego**.
- **Prueba clave:** el job `godot-lint` del mismo run ejecuta el MISMO
  `--import` (454 steps) y termina en **34 s**. La unica diferencia es que el
  lint apunta `--check-only --script res://scripts/editor/_colector_sintaxis.gd`.
  El reimport NO es el problema; es el `--check-only` pelado.

### Solucion (commit `cd32547`)

Se aplica el mismo patron que usa `godot-lint`:

1. `python tools/quality/gen_colector_sintaxis.py --proyecto game/isla-ancestral`
   (regenera el colector; ya tenia el flag, solo no se usaba en este job).
2. `godot --headless --path game/isla-ancestral --import` (cache de class_names).
3. `godot --headless --check-only --script res://scripts/editor/_colector_sintaxis.gd`
   desde `game/isla-ancestral/`.

Godot parsea los **925 scripts** del proyecto en una sola pasada (cada
`preload` fuerza el parseo en compilacion) y termina en segundos.

Ademas, el paso era un **no-op** (`|| true` que descartaba el exit code): nunca
validaba nada ni podia fallar. Ahora cuenta los `SCRIPT ERROR` y hace `exit 1`
si hay alguno. El job por fin sirve para algo.

### Verificacion

- Local: `godot --headless --check-only --script` sobre el colector regenerado
  (925 preloads, 4 excluidos) => **exit 0 en 11.2 s**.
- CI: job `godot-lint` (mismo flujo) => **success en 34 s** en el run
  37415327285. El `formatting-check` con el fix deberia estar en ese orden.
- YAML validado con `yaml.safe_load`: 6 steps, `needs` de `summary` intacto
  (12 jobs).

## Archivos Modificados/Creados

- `.github/workflows/quality.yml` — job `formatting-check`: anadidos pasos
  `Setup Python`, `Generate syntax collector`; el paso de check ahora usa
  `--script` + conteo de SCRIPT ERROR + `exit 1`. Comentario explicativo de la
  causa raiz.
- `game/isla-ancestral/scripts/editor/_colector_sintaxis.gd` — regenerado
  (925 preloads; diff de renumeracion por scripts nuevos agregados por otros
  agentes entre generaciones).

## Notas

- Huella de push (AGENTS.md seccion 4.3): `9f6e236..cd32547 main -> main`,
  2026-10-06 06:35Z, atria-dawn-s2. Push principal (fix formatting check).
  Commit anterior `9f6e236` tambien mio (mismo frente).
- NO se commiteo `CHECKLIST-GLOBAL.md` que otro agente tenia staged en el
  working tree (commiteo solo mis 2 archivos con pathspec explicito).
- Pendiente de confirmar en CI: el run nuevo deberia dejar el formatting check
  en verde y en segundos. Si vuelve a fallar, el siguiente frente es revisar si
  el reimport del addon voxel en CI es el cuello de botella real.
