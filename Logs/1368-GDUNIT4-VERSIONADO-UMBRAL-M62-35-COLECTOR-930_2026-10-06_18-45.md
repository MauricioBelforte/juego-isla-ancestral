# Log 1368: gdUnit4 versionado + umbral M62 3.50 + colector sin exclusiones

**Fecha:** 2026-10-06
**Hora:** 18:45
**Modelo:** atria-dawn-s2 (Atria Dawn Preview)
**Plataforma:** Kilo Code

## Resumen

Ejecute las 2 decisiones del fundador (canal 60) que cierran los 4 fallos
restantes de la suite M112 y dejan `quality.yml` a un paso del primer CI verde
del proyecto.

## Cambios Realizados

### 1. gdUnit4 versionado (commit `a0260b8`)

Decision del fundador: el framework de testing debe vivir en git (CI
irreproducible + test M83 cuenta `mit=1` cuando hay 2 addons MIT).

**Verificaciones previas (condiciones del fundador):**
- **Licencia: MIT** (Copyright (c) 2023 Mike Schulze) — cumple el test M83
  (`mit=2`).
- **Path estandar:** `addons/gdUnit4` (convencion Godot).
- **Tamano:** 516 archivos / 1.11 MB — trivial.
- **`bin/` contiene solo scripts .gd** (GdUnitCmdTool, GdUnitCopyLog), no
  binarios — nada que excluir del versionado.
- **`*.uid` siguen ignorados** por el `.gitignore` global; Godot los regenera.

Excepcion agregada al `.gitignore` raiz junto a la de `zylann.voxel`:
`!game/isla-ancestral/addons/gdUnit4/`. Commit aislado, un solo proposito.

### 2. Colector de sintaxis sin exclusiones gdUnit4 (commit `81ff2b8`)

Con gdUnit4 en git, la exclusion por contenido (`_usa_gdunit`) del generador
quedo obsoleta: Godot ya resuelve `extends GdUnitTestSuite`. Se elimino la
funcion y su logica del bucle `_recolectar`.

- Antes: 926 preloads + **4 excluidos** (tests gdUnit4).
- Ahora: **930 preloads, 0 excluidos** — todos los `.gd` del proyecto se
  validan.
- Verificado: `godot --headless --check-only --script` => **exit 0**.

### 3. Umbral L191 de M62: 3.00 -> 3.50 ms (commit `1719f9e`)

Decision del fundador con condicion de medir el baseline local primero.

**Baseline local (5 corridas, binario real, misma maquina):**

| Corrida | pico_pesado (ms) |
|---|---|
| 1 | 0.373 |
| 2 | 0.916 |
| 3 | 0.349 |
| 4 | 0.380 |
| 5 | 0.377 |

**vs CI run 37415327285: pico = 3.040 ms.** El runner mide **3x-8x mas lento**
que local (contenedor compartido, sin affinity de CPU). Margen real en la
maquina del desarrollador: **~9x por debajo del umbral nuevo**.

Documentado en el propio test (comentario de 7 lineas): explica por que 3.50, el
baseline medido, y la orden de volver a 3.00 si CI baja de 2 ms. No es la trampa
81 (umbral inflado sin justificacion) — hay medicion y punto de retorno.

Verificado: 15 checks, **0 fallos**.

## Verificacion

- Colector 930 scripts: exit 0.
- M62 liberacion: 15 checks, 0 fallos (5 corridas + 1 post-cambio).
- `.gitignore`: `git check-ignore` negativo sobre gdUnit4.

## Archivos Modificados/Creados

- `.gitignore` — excepcion `!game/isla-ancestral/addons/gdUnit4/` + comentario.
- `game/isla-ancestral/addons/gdUnit4/` — 270 archivos versionados (516 totales
  menos los `.uid` ignorados): src/, bin/, LICENSE, plugin.cfg, plugin.gd,
  runtest.cmd/sh.
- `tools/quality/gen_colector_sintaxis.py` — eliminada `_usa_gdunit` y su logica.
- `game/isla-ancestral/scripts/editor/_colector_sintaxis.gd` — regenerado (930).
- `game/isla-ancestral/scripts/rendimiento/memoria/test_m62_liberacion.gd` —
  `LIMITE_PICO_MS` 3.0 -> 3.5 + comentario con el baseline.

## Notas

- Huellas de push: se hacen tras este log (commit log incluido).
- Resta confirmar en CI que M83 (3 fallos) y M62 (1 fallo) queden en 0 con estos
  commits -> M112 en 0 fallos -> desbloquear DeepSeek (canal 60 punto 6).
- No se commiteo `CHECKLIST-GLOBAL.md` (staged por otro agente) en ningun
  commit; todos usaron pathspec explicito.
- El director pidio T-OM04 solo en `--dry-run` (no aplicar): pendiente.
