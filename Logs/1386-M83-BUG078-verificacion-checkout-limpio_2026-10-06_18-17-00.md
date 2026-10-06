# Log 1386 - M83 (CI) - BUG-078: verificacion del job `godot-lint` en checkout limpio

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Modulo:** M83 (CI) - BUG-078 (en el mismo pase: cierre formal de la cola M59 BUG-108..115)
**Fecha:** 2026-10-06 18:17
**Pedido por:** Atria-Dawn-Preview (director), canal 56 (2026-10-06 17:19)

## 1. Encargo (canal 56, seccion 4)

BUG-078 = "el CI ejecuta 8 scripts que NO estan versionados". Encargo:
1. Diagnostico: son tests que faltan, o rutas erroneas en `quality.yml`?
2. Segun el diagnostico: crearlos / des-cablearlos, o corregir rutas. NO tocar
   `quality.yml` sin coordinar con s2 (es suyo, BUG-091 modo A).
3. Verificacion: checkout limpio y correr el job `godot-lint` ahi -> tiene que salir VERDE.
4. Reportar la decision por cada uno de los 7 (los que el director creia ajenos).

## 2. Diagnostico (medido contra HEAD, no contra el worktree)

Los 8 scripts de BUG-078 **ya estan versionados** en `HEAD`. Medido con
`git cat-file -e HEAD:<ruta>` + `git log --oneline -1 -- <ruta>` (no con `ls`: el
archivo esta en el disco del autor aunque no este en el repo - trampa 98):

| script | en HEAD | commit que lo versiono |
|---|---|---|
| game/isla-ancestral/scripts/player/test_player_m11.gd | SI | 5ce3aa9 (2026-09-20) |
| game/isla-ancestral/scripts/ia_npc/test_ia_npc_m64_iterN.gd | SI | 454d0ae (2026-09-29) |
| game/isla-ancestral/scripts/ia_npc/test_navegacion_m64.gd | SI | 454d0ae (2026-09-29) |
| game/isla-ancestral/scripts/ia_npc/test_social_m64.gd | SI | 454d0ae (2026-09-29) |
| game/isla-ancestral/scripts/ia_npc/test_rendimiento_m64.gd | SI | 454d0ae (2026-09-29) |
| game/isla-ancestral/scripts/ia_npc/test_persistencia_m64.gd | SI | 454d0ae (2026-09-29) |
| game/isla-ancestral/scripts/build/test_instalador_m116.gd | SI | bcec7f5 (2026-10-04) |
| game/isla-ancestral/scripts/build/test_build_m117.gd | SI | bcec7f5 (2026-10-04) |

`scripts/validar_workflows.py` tiene `DEUDA_CONOCIDA = {}` (VACIA) -> corre con EXIT 0 y sin
avisos: "6 workflow(s) validos: YAML parseable, jobs con runs-on, needs coherentes y toda cita
`--script` versionada". Selftest 6/6 (incluye el fixture "BUG-078: `--script` cita un archivo NO
versionado -> 1 problema" y su control negativo). La premisa del director ("los 7 ajenos siguen en
DEUDA_CONOCIDA") estaba **desactualizada**: la fila del registro es del 2026-09-20 y nadie la
actualizo cuando los archivos se versionaron.

**Respuesta a la pregunta 1:** ninguna de las dos opciones. Eran **tests reales que faltaban** y
**ya fueron creados y versionados** (M64 el 09-29 por su dueno; M116/M117 el 10-04). No habia rutas
erroneas. **No se toco `quality.yml`** (no hizo falta; y es de s2).

## 3. Verificacion: job `godot-lint` en checkout limpio (definicion de done)

**Metodo.** Checkout limpio de `HEAD` SIN usar `git worktree` (trampa 102: hay un worktree ajeno
`.kilo/worktrees/phase-judge` que no se debe tocar; `git worktree list` igual antes y despues):

```
git archive HEAD game/isla-ancestral tools/quality | tar -x -C <temp-fuera-del-repo>
```

2727/2727 archivos extraidos = exactamente el arbol trackeado de `HEAD` (lo que produce
`actions/checkout`), sin `.godot/`. Godot local: 4.7.2-stable (win64 console).

**Replica de los 3 pasos del job (quality.yml, job `godot-lint`):**

| paso | comando | resultado |
|---|---|---|
| 1 Generate syntax collector | `python tools/quality/gen_colector_sintaxis.py --proyecto game/isla-ancestral` | EXIT 0 - **932 preloads, 0 excluidos** |
| 2 Import project resources | `godot --headless --path game/isla-ancestral --import` | EXIT 0 - **0 SCRIPT ERROR / Parse Error / ERROR** |
| 3 Check for Godot parser errors (gate MODO A) | `godot --headless --check-only --script res://scripts/editor/_colector_sintaxis.gd` + `grep -c "SCRIPT ERROR"` | **raw_exit=0, SCRIPT ERROR=0 -> JOB EXIT 0 = VERDE** |

**Guard probado EN ROJO (trampa 91/101 - un 0 de un detector ciego y de uno limpio son iguales).**
Inyectado un parse error deliberado al final de `scripts/saving/validate_save.gd`
(`func __sonda_roja_bug078(:`), regenerado el colector y re-corrida la misma linea del gate:

```
raw_exit=1  SCRIPT_ERROR=3  JOB EXIT = 1
SCRIPT ERROR: Parse Error: Could not preload resource script "res://scripts/saving/validate_save.gd".
   at: GDScript::reload (res://scripts/editor/_colector_sintaxis.gd:651)
```

El detector **nombra el archivo** inyectado y la linea del colector. Restaurado el archivo desde
`HEAD` (`git archive HEAD <ruta> | tar -x`) y re-corrido -> **raw_exit=0, SCRIPT ERROR=0,
JOB EXIT=0**. Las tres direcciones medidas: verde -> rojo -> verde. El 0 del checkout limpio **no es
un detector ciego**.

**Conclusion: el defecto tecnico de BUG-078 esta RESUELTO y el job `godot-lint` sale VERDE en
`HEAD`.**

## 4. Cierre formal de la cola M59 (mismo pase)

Commit local `ad5dd29` (`DOCUMENTACION/11-BUGS.md`, 1 archivo, +555 lineas, LF puro sin BOM,
verificado por bytes): 8 filas BUG-108..115 con Estado `[x]` + Log + commit + fecha; 8 secciones de
detalle con el bloque `Resolucion` completo; nota de reclasificacion de BUG-111 (falso positivo +
BUG-111-bis real, medido 47 -> 0); nota de cierre en la seccion 8.3. El commit incluye el bloque de
auditoria L-03 que ya estaba sin commitear en el worktree (se dice en el mensaje del commit).

| Bug | Estado | Log | Commit |
|---|---|---|---|
| BUG-108 | Resuelto | 1378 | da6c974 |
| BUG-109 | Resuelto | 1380 | 4e61ca0 |
| BUG-110 | Resuelto | 1381 | 0bfa62b |
| BUG-111 | Reclasificado (falso positivo + BUG-111-bis resuelto) | 1377 | a089174 |
| BUG-112 | Resuelto | 1382 | 3ad8630 |
| BUG-113 | Resuelto | 1382 | 3ad8630 |
| BUG-114 | Resuelto | 1382 | 3ad8630 |
| BUG-115 | Documentado - deuda sin fix (NO es un fix) | 1382 | 3ad8630 |

## 5. Push autorizado (canal 56 seccion 2) - NO-OP, no ejecutado por mi

Medido ANTES de empujar: `git rev-parse HEAD` == `git rev-parse origin/main` == `7b409c5`;
`git ls-remote origin main` = `7b409c5`; `git rev-list origin/main..HEAD` = vacio;
`git merge-base --is-ancestor 3ad8630 origin/main` = true (idem 2c15f0d). Mis 2 commits ya viajaron
en el push del director `7b409c5` (2026-10-06 17:46:59, autor Mauricio Belforte). Un `git push`
habria dicho "Everything up-to-date". **No se reclama ese push** (trampa E/28).

Huella 4.3 del ejecutor real: rango `e9bdfda..7b409c5`, 2026-10-06 17:46:59, ejecutante
Mauricio Belforte / atria (director), tipo principal.

## 6. Hallazgos colaterales del pool de logs

- **BOM en `Logs/NUMEROS_DISPONIBLES.txt`** (trampa 77): el primer numero (1386) era INVISIBLE al
  asignador (`b'\xef\xbb\xbf1386\r'.strip().isdigit()` = False) -> `--estado` reportaba
  "1615 libres (primero=1386)" pero el 1386 no se podia consumir ni detectar. **Reparado por bytes**
  (quitados los 3 bytes del BOM; 9693 -> 9690 B, primera linea pasa a `b'1386\r'`), recien entonces
  reservado el 1386. Auto-curacion 28.
- **COLISION 1290 (AJENA)**: `1290-m112-export-presets-deuda-obsoleta_2026-10-04_20-43.md` vs
  `1290-th2-bloque1-reverify-21.8_2026-10-04.md`. **Reportada, NO tocada** (renumerar un log ajeno es
  destructivo; decision de su dueno).

## 7. Pendiente / decision del director

La fila de BUG-078 en `11-BUGS.md` sigue `[ ] Parcial ... los 7 ajenos en DEUDA_CONOCIDA` ->
**miente sobre el estado real** y mantiene a M151 bloqueada (el `control_final_gate.gd` cuenta
criticos ABIERTOS EN EL REGISTRO, no corre el CI). Se dejo una fila propuesta lista para pegar en el
canal 57. **No se edito esa fila**: el director pidio "reportar ... para que se actualice", y el
cierre que autorizo eran las 8 filas de BUG-108..115.

## 8. Limites

- No se toco `CHECKLIST-GLOBAL.md`, `quality.yml`, `interaction_manager.gd`,
  `service_registry.gd` ni `bootstrap.gd`.
- El checkout temporal se creo y se borro fuera del repo; los worktrees existentes quedaron
  intactos (verificado con `git worktree list`).
- Sin push.

**Firma:**
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-06 18:17
