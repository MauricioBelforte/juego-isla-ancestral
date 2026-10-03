# Log 1205 - M59 Guardado, iteracion 3: defaults al cargar, contrato del proveedor player y un SCRIPT ERROR ajeno (luego corregido: no era bug)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Modulo:** M59-Guardado (dueno actual; relevo 21.4.7)
**Fecha:** 2026-10-02 21:05
**Estado:** Parcial entregado y medido. NO sella 21.8 (autor != verificador).
**Tipo:** feature (item H) + contrato de proveedor + deuda tecnica contenida + hallazgo AJENO (corregido despues: era un estado transitorio, no un bug)

---

## 1. Contexto

Continuacion de M59 (iter. 1 = Log 1197; iter. 2 = Log 1202). El usuario pidio
explicitamente "corregir los problemas" que la iteracion 2 dejo REPORTADOS en vez de
arreglados: el merge de defaults al cargar (item H), el contrato incompleto del
PlayerSaveProvider y la deuda del dialecto schema<->proveedores.

## 2. FIX 6 - item H: "Manejar campos nuevos (defaults) y faltantes (sin crash)"

**Antes:** un save al que le faltaba una seccion fallaba `SaveSchema.validate()` con
"Falta seccion: X" -> `SaveLoader.load()` devolvia CORRUPTED (o RECOVERED desde un backup)
y **no se podia cargar**. El item H estaba marcado `[x]` pero solo era cierto en el
sentido debil de "no crashea".

**Ahora:** `SaveSchema.completar(payload)` rellena con los defaults del schema toda
SECCION de nivel superior que falte, y `SaveLoader.load()` (y `_try_recover()`) lo llaman
ANTES de `validate()`.

**LO QUE NO HACE, A PROPOSITO (y por que):** `completar()` NO toca el INTERIOR de las
secciones. Medido antes de implementarlo: de los proveedores con `restore_save_data`,
**15 iteran las claves de su seccion**. En particular
`inventario_service.restore_save_data()` hace `for id in data: var c := int(id)` y trata
la clave como INDICE DE CONTENEDOR: inyectar la clave del schema `items` (un Array) haria
`int("items") == 0` y **BORRARIA el contenido del contenedor 0**. Un "merge de defaults"
ingenuo dentro de las secciones habria sido una perdida de datos silenciosa. El interior de
una seccion es responsabilidad de su proveedor.

Prueba (bloque 8 de `test_rotate_m59.gd`): un save SIN `photos` ni `collections` ->
control `validate()` reporta 2 errores; `load_slot()` devuelve **OK**; el payload cargado
tiene las 2 secciones con sus defaults (`photos.ids == []`) y el dato REAL (`time.day = 55`)
NO se sobrescribe.

## 3. FIX 7/8/9 - PlayerSaveProvider: contrato COMPLETO

Medido en iter. 2 (Log 1202): se GUARDABA `spawn_position` pero `restore_save_data()` solo
restauraba `position`; y `spawn_position` era siempre una copia de la posicion actual.

- **FIX 7**: `restore_save_data()` ahora restaura `spawn_position` y `zone` **si el nodo las
  expone** (duck-typing con `prop in nodo`). Si no las expone, no escribe nada.
- **FIX 8/9**: `get_save_data()` las LEE del nodo si existen (antes `spawn_position` era
  siempre `position` y `zone` siempre `""`).
- **NUNCA se asigna `name`**: en un `Node`, `name` es `Node.name`; asignarlo RENOMBRARIA el
  nodo y romperia el `find_child("Player")` del proximo guardado. Verificado en el test
  (el nodo sigue llamandose "Player" tras restaurar un payload con `name: "X"`).

El Player actual NO expone `spawn_position`/`zone`, asi que el contrato queda documentado:
hoy `spawn_position` es un punto de REANUDACION, no un spawn real. El dia que el Player
gane esas propiedades, el save las leera/restaurara sin tocar M59.

## 4. FIX 4-bis - el dialecto schema<->proveedores, contenido en UN solo lugar

La traduccion del dialecto (`dia` del proveedor M29 vs `day` del schema) estaba inline en
`SaveManager.slot_metadata()`. Ahora vive en `SaveSchema.dia_de(payload)`, documentado como
la UNICA traduccion; si los duenos de M14/M29/M38 reconcilian las claves, se cambia solo ahi.
(La deuda de fondo sigue REPORTADA: `time`, `inventory` y `economy` no hablan el dialecto del
schema y `collect()` reemplaza la seccion entera.)

## 5. Suite

`test_rotate_m59.gd`: **43 checks, 9 bloques** (era 28/7). Bloques nuevos:
- **b8**: item H (save con secciones faltantes) + control negativo (`validate()` SI las detecta).
- **b9**: contrato del PlayerSaveProvider con nodo inyectado, incluyendo un nodo con
  `spawn_position`/`zone` creado con un `GDScript` en runtime para probar el duck-typing sin
  depender de un script ajeno.

Piso `CHECKS_MINIMOS = 43` MEDIDO en verde.

## 6. Sondas en ROJO (10/10)

| Sonda | Resultado |
|---|---|
| FIX1 rotate-antes-de-write | exit=1, 8 fallos |
| FIX2 fallback-de-backup-sin-save | exit=1, 3 fallos |
| FIX3 backup-futuro-no-se-carga | exit=1, 1 fallo |
| FIX4 slot_metadata-lee-dia | exit=1, 1 fallo |
| FIX5 manager-sella-last_saved | exit=1, 1 fallo |
| FIX6 completar-defaults-al-cargar | exit=1, **4 fallos** (load_slot dio 2 = CORRUPTED) |
| FIX7 player-restaura-spawn-y-zone | exit=1, 2 fallos |
| FIX8 player-lee-spawn-del-nodo | exit=1, 1 fallo |
| FIX9 player-lee-zone-del-nodo | exit=1, 1 fallo |
| GUARDIA piso CHECKS_MINIMOS | exit=1, **0 fallos** (34 checks < 43; "PISO NO CUMPLIDO") |
| CONTROL sin mutar | exit=0, 43 checks, 0 fallos |

## 7. Mediciones

| Suite | Checks | Fallos | EXIT |
|---|---|---|---|
| `validate_save.gd` | 16 | 0 | 0 |
| `test_slots_m59.gd` | 22 | 0 | 0 |
| `test_rotate_m59.gd` | 43 | 0 | 0 |

Total **81 checks, 0 fallos, EXIT 0 x3**.

## 8. HALLAZGO AJENO: SCRIPT ERROR transitorio en `minimap_widget.gd` (CORREGIDO: no era bug)

Durante la iter. 3 aparecio **1 SCRIPT ERROR** en las TRES suites, que en iter. 2 no estaba:

```
SCRIPT ERROR: Parse Error: Function "_ready" has the same name as a previously declared function.
   at: res://scripts/ui/widgets/minimap_widget.gd
```

**En el momento lo atribui a una regresion publicada de M54 (commit `46c1f79`). ESO ERA FALSO.**
Medido de nuevo al retomar la tarea (Log 1209):

- `git log --all` da **18 commits** que tocan `minimap_widget.gd`. En TODOS,
  `git show <commit>:<ruta> | grep -c '^func _ready'` da **1**. **Ningun commit tuvo 2.**
- En HEAD el archivo **compila** (`--check-only` sin Parse Error) y las 3 suites de M59
  corren con **0 SCRIPT ERROR**.

Conclusion: el Parse Error correspondia a un **estado TRANSITORIO del worktree** (M54 estaba
editando el archivo en ese momento; agnes guardaba estados intermedios y los corregia). No era
codigo publicado ni habia nada roto que arreglar. El "fix de 2 lineas" que propuse era inutil:
no hay ningun `_ready()` espurio.

**Leccion (trampa nueva, seccion AI del skill):** una medicion tomada mientras otro agente edita un
archivo compartido NO es estable. **Antes de atribuir un fallo a un commit, hay que medir el
CONTENIDO DEL COMMIT** (`git show <commit>:<ruta>`), no solo el worktree. El error era real; la
ATRIBUCION ("regresion publicada") era falsa. **BUG-089** (registrado por el coordinador a
partir de este reporte) quedo **anulado** (ver `DOCUMENTACION/11-BUGS.md`).

## 9. Lo que NO hice (honestidad obligatoria)

- **No** toque `minimap_widget.gd` (M54/agnes) ni M61, `interacciones/`, `mapa/`, `audio/`.
- **No** reconcilie el dialecto de fondo (M14/M29/M38): solo lo contengo y lo reporto.
- **No** selle 21.8 (autor != verificador).
- **No** toque `CHECKLIST-GLOBAL.md` ni el pool (tarea del coordinador).

## 10. Archivos tocados

- `game/isla-ancestral/scripts/saving/save_schema.gd` (`completar()` + `dia_de()`)
- `game/isla-ancestral/scripts/saving/save_loader.gd` (llama `completar()` en los 2 caminos)
- `game/isla-ancestral/scripts/saving/save_manager.gd` (`slot_metadata` usa `SaveSchema.dia_de`)
- `game/isla-ancestral/scripts/saving/player_save_provider.gd` (contrato completo)
- `game/isla-ancestral/scripts/saving/test_rotate_m59.gd` (28 -> 43 checks, bloques 8-9)
- `DOCUMENTACION/59-Guardado/plan-actual/05-Checklist.md`
- `DOCUMENTACION/59-Guardado/plan-actual/04-Codigo.md`
- `Mensajes entre modelos/ESTADO-PARALELO.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`
- Scratch (gitignored): `Obsoletos/raiz-temporales-m59-iter2-2026-10-02/`

## 11. Huella de push (AGENTS.md 4.3)

- Rango publicado: `9067d1f..c14e396` (`main`)
- Hora: 2026-10-02 21:09 (-0300)
- Ejecutante: DeepSeek-V4.1-Flash (WorkBuddy)
- Tipo: fast-forward, sin `--force`, `GIT_TERMINAL_PROMPT=0`
- Commits propios: 1 -> `c14e396` (M59 iter. 3)
- Commits ajenos en el rango: 7
  - `d24c195` bloqueo de M59-Guardado y reconstruccion de su fila a 11 columnas (coordinador)
  - `14803a3` registro de BUG-088 (coordinador)
  - `b4354e2` registro de BUG-087 (coordinador)
  - `9645883` M54: +3 [x] (leyenda filtros, escala zoom, daltonismo) (agnes)
  - `f9cc745` M54: minimap ocultable (agnes)
  - `b2856cd` M54: +4 [x] (ocultable, M88 fuentes, explorer desacoplado, estados) (agnes)
  - `6b9fc46` M91 lote 6: contraste de Especificacion RF1-RF15 (mimo)
- Verificacion post-push: `HEAD == origin/main == c14e396`; `git merge-base --is-ancestor c14e396 origin/main` = SI
