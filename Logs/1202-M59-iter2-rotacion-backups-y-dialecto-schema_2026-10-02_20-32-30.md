# Log 1202 - M59 Guardado, iteracion 2: rotacion de backups y dialecto schema<->proveedores

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Modulo:** M59-Guardado (dueno actual; relevo 21.4.7)
**Fecha:** 2026-10-02 20:32
**Estado:** Parcial entregado y medido. NO sella 21.8 (autor != verificador).
**Tipo:** bugfix critico + robustez + suite nueva + hallazgo de deuda

---

## 1. Encargo y contexto

Continuacion del backlog de M59 (autonomia total dentro del modulo). Reglas vigentes:
no tocar M61, `scripts/interacciones/` (kimi), `scripts/mapa/` (agnes),
`scripts/audio/` (mimo); commits con pathspec encadenado; no sellar 21.8; no tocar
`CHECKLIST-GLOBAL.md` (tarea de pipes del coordinador en vuelo).

Punto de partida: iteracion 1 (Log 1197, commits `15010f7`+`ddc6d3f`) habia corregido
que NINGUN save valido se podia cargar. Las 2 suites heredadas estaban verdes
(`validate_save.gd` 16/0, `test_slots_m59.gd` 22/0).

Primer paso de la iteracion 2: MEDIR el ecosistema real de proveedores en vez de
asumirlo. Probe temporal -> **39 proveedores** autoload; secciones del schema SIN
proveedor = `world, quests, events, photos`; `collect()` = 46 claves top-level;
seccion VACIA tras `collect()` = `player` (0 claves en headless).

## 2. HALLAZGO CRITICO (BUG #4) - `request_save()` no dejaba ningun save cargable

**Sintoma medido (probe):** tras `SaveManager.request_save(2, ...)` el slot quedaba asi:

```
slot_2.save      existe=false     <-- NO HAY SAVE
slot_2_r1.bak    existe=true len=4369
save_exists(2) = false
load_slot(2)   = 1  (NOT_FOUND)
slot_metadata(2) = {}
```

**Causa raiz:** en `SaveManager._process_queue()` el orden era
`write_atomic()` -> `rotate()`. `write_atomic()` renombra `.tmp -> .save`, lo que
REEMPLAZA el save anterior (Godot usa MoveFileEx con MOVEFILE_REPLACE_EXISTING);
despues `rotate()` movia ESE save recien escrito a `slot_N_r1.bak`. Neto: el slot
quedaba SIN `.save` y solo con `.bak`... que `load()` ni miraba (devolvia NOT_FOUND
antes de intentar el backup). Es decir: **el camino normal de guardado (auto-save por
dia/mision/evento, timer, UI M53) nunca producia un save cargable.**

**Por que nadie lo vio:** las 2 suites heredadas llamaban a `SaveWriter.write_atomic()`
DIRECTO, nunca a `SaveManager.request_save()`. `validate_save.gd` incluso codifica el
orden CORRECTO a mano en `_test_backup_recovery()` (`write_atomic` -> `rotate` ->
`write_atomic`), enmascarando que produccion hacia lo contrario. Es la trampa 119 otra
vez: suite verde, camino real roto, por OMISION de cobertura (no por asercion laxa).

## 3. Fixes aplicados

### FIX 1 (critico) - `save_manager.gd`: rotar ANTES de escribir
`SaveBackup.rotate(slot)` pasa a ejecutarse antes de `SaveWriter.write_atomic()`.
Asi el save anterior se preserva en `.bak` y el nuevo queda en `.save`.

### FIX 2 - `save_loader.gd`: recuperar el backup cuando falta el `.save`
Con el orden nuevo, si el proceso muere (o la escritura falla) entre la rotacion y el
rename, queda `.bak` sin `.save`. Antes -> NOT_FOUND (progreso inalcanzable aunque
estuviera en disco). Ahora: si hay backup, se recupera (`RECOVERED`).

### FIX 3 - `save_loader.gd`: el camino de backup es tan estricto como el principal
`_try_recover()` restauraba el payload SIN normalizar ni validar, asi que un backup de
version FUTURA se cargaba como RECOVERED, degradando un save mas nuevo (contra la regla
dura "nunca degradar un save"). Ahora normaliza `schema_version`, valida estructura y
rechaza FUTURE_VERSION.

### FIX 4 - `save_manager.gd`: `slot_metadata()` lee el dia REAL
El proveedor de tiempo (M29) emite `{dia, mes, anio, hora, minuto, ...}`, pero el schema
declara `{day, season, hour, minute}`. Como `collect()` REEMPLAZA la seccion entera,
`time.day` NO EXISTE en disco -> `slot_metadata().day` salia **SIEMPRE 0** (la UI de
slots habria mostrado "dia 0" para cualquier partida). Ahora lee `dia` y cae a `day`.

### FIX 5 - `save_manager.gd`: el manager sella `meta.last_saved`
Ningun proveedor emite la seccion `meta`, asi que `collect()` dejaba el default y
`meta.last_saved` quedaba SIEMPRE "" (el backend de "hora/fecha del ultimo guardado por
slot" no tenia dato). Ahora lo sella el manager, que es quien escribe. Nuevo helper
`_payload_para_slot(slot)` usado por la cola y por el guardado de cierre.

## 4. Suite nueva: `scripts/saving/test_rotate_m59.gd` (28 checks, 7 bloques)

Cubre el CAMINO REAL y la rotacion. Guardia anti-falso-verde de 3 capas identica a
`test_slots_m59.gd`: `_fin(clave)` por bloque, `CHECKS_MINIMOS = 28` MEDIDO en verde,
`_summary()` en `call_deferred` separado que decide el exit code.

- b1 `request_save()` deja un `.save` cargable (regresion del bug critico) + no deja `.tmp` + sin save previo no crea `.bak`.
- b2 la rotacion preserva el save ANTERIOR en `.bak` (por CONTENIDO, no por tamano).
- b3 guardado interrumpido: sin `.save` pero con `.bak` -> RECOVERED con el payload intacto.
- b4 backup de version FUTURA -> FUTURE_VERSION, no RECOVERED; el `.bak` no se degrada en disco.
- b5 control: slot vacio sin backup -> NOT_FOUND.
- b6 `slot_metadata` sobre `request_save`: `day` == el dia del proveedor (tolerante a la reconciliacion futura del dialecto) + `last_saved` sellado.
- b7 kill durante la ESCRITURA: `.tmp` huerfano + `.save` anterior -> carga OK; `cleanup_orphan_tmp()` lo borra.

## 5. Sondas en ROJO (6/6)

Cada fix se probo inyectando su reversion en el archivo REAL, corriendo la suite y
exigiendo fallo; despues se restauro. El CONTROL (sin mutar) debe dar EXIT 0.

| Sonda | Resultado |
|---|---|
| FIX1 rotate-antes-de-write | exit=1, 8 fallos (27 checks, 6 bloques) |
| FIX2 fallback-de-backup-sin-save | exit=1, 3 fallos |
| FIX3 backup-futuro-no-se-carga | exit=1, 1 fallo (dio RECOVERED=3) |
| FIX4 slot_metadata-lee-dia | exit=1, 1 fallo (dio 0) |
| FIX5 manager-sella-last_saved | exit=1, 1 fallo (dio '') |
| GUARDIA piso CHECKS_MINIMOS | exit=1, **0 fallos** (23 checks < 28) -> el piso delata una suite recortada sin `[FALLO]` explicito |
| CONTROL sin mutar | exit=0, 28 checks, 0 fallos |

## 6. Mediciones (3 rondas, 0 SCRIPT ERROR)

| Suite | Checks | Fallos | EXIT |
|---|---|---|---|
| `validate_save.gd` | 16 | 0 | 0 |
| `test_slots_m59.gd` | 22 | 0 | 0 |
| `test_rotate_m59.gd` | 28 | 0 | 0 |

Total 66 checks, 0 fallos, 9 corridas, 0 SCRIPT ERROR. Estado en disco tras 3 saves
consecutivos por `request_save`: `.save` (nuevo) + `_r1.bak` (anterior) + `_r2.bak`
(antepenultimo) -> rotacion correcta, `load_slot` = OK en cada paso.

## 7. HALLAZGO DE DEUDA: el schema y los proveedores hablan dialectos distintos

`SaveSchema.default_payload()` documenta que el schema es "la unica fuente de verdad" y
que las secciones quedan "con estructuras vacias pero presentes, para que el schema sea
estable y forward-compatible". La realidad MEDIDA es que `collect()` hace
`payload[seccion] = data` y cada proveedor escribe su propio dialecto:

| seccion | schema declara | el proveedor persiste | claves del schema perdidas |
|---|---|---|---|
| `time` | day, season, hour, minute | dia, mes, anio, hora, minuto, acumulador, eventos_visitados, semilla_partida | **las 4** |
| `inventory` | items, equipment, hotbar | "0","1","2","3","4","5" (indices de slot) | las 3 |
| `economy` | coins, shops | saldo, precios, historial, reputacion | las 2 |
| `player` | name, position, spawn_position, zone | `{}` en headless (real con nodo Player) | las 4 |
| `world` | seed, islands, poi, explored, fog, modified_blocks | identico (SIN proveedor -> queda el default) | 0 |
| `photos` | ids | identico (SIN proveedor -> queda el default) | 0 |

Consecuencia: `SaveSchema.validate()` solo comprueba que las secciones sean Dictionary
(y `time.day`, que no existe) -> la validacion es practicamente vacua contra los saves
reales. **NO lo arreglo yo**: cambiar el dialecto de `time`/`inventory`/`economy` es de
los duenos de M29/M14/M38. Queda REPORTADO al coordinador como deuda de integracion.
M59 mitiga lo suyo: `slot_metadata()` lee el dialecto real (FIX 4) y sella su propia
seccion `meta` (FIX 5).

## 8. Verificacion de una afirmacion del checklist (honestidad)

El item I ("Guardar posicion del jugador, zona y punto de spawn") esta `[x]` con la nota
"guarda/restaura posicion y spawn_position (probado)". MEDIDO con un nodo Player
inyectado (Node3D llamado "Player"):

- `get_save_data()` con Player en (10,5,-3) -> `{name:"", position:[10,5,-3], spawn_position:[10,5,-3], zone:""}`.
- `spawn_position == position` -> **true**: no es un punto de spawn, es una copia de la posicion actual.
- `restore_save_data()` restaura `position` CORRECTAMENTE (10,5,-3). **NO restaura** `spawn_position`, `zone` ni `name`.
- El nodo Player NO expone `spawn_position`, `zone` ni `nombre_jugador` (verificado con `"x" in p`).

Conclusion: "guarda/restaura posicion" es CIERTO y medido; "restaura spawn_position" es
FALSO (se escribe pero no se restaura, y no hay consumidor). La nota del checklist se
corrige para decir la verdad; la marca se mantiene `[x]` porque el texto del item pide
GUARDAR (los 4 campos se escriben) y el sistema de zonas (M09/M54) no existe todavia.

## 9. Efecto colateral: el item T "ciclo jugar -> auto-save -> apagar -> cargar -> continuar" era falso

Ese item estaba `[x]` con el bug critico vivo: el ciclo NO podia funcionar porque el
auto-save no dejaba `.save`. Con FIX 1 el ciclo es real (medido en b1/b2/b6). Se anota
en el checklist para que quede la traza.

## 10. Lo que NO hice (honestidad obligatoria)

- **No** toque M61 (background thread), ni `interacciones/`, `mapa/`, `audio/`.
- **No** reconcilie el dialecto schema<->proveedores (M14/M29/M38) - solo lo reporte.
- **No** implemente el merge de defaults al cargar (item H "campos nuevos/faltantes"):
  hoy `validate()` rechaza una seccion ausente; falta decidir si se rellena con
  `default_payload()`. Queda para iter. 3.
- **No** hice un SIGKILL real: los estados de "apagado" se SIMULAN reproduciendo el
  estado en disco que deja el corte (`.tmp` huerfano / `.save` ausente + `.bak`).
- **No** selle 21.8 (autor != verificador).
- **No** toque `CHECKLIST-GLOBAL.md` ni el pool (tarea del coordinador).

## 11. Archivos tocados

- `game/isla-ancestral/scripts/saving/save_manager.gd` (FIX 1, 4, 5 + helper `_payload_para_slot`)
- `game/isla-ancestral/scripts/saving/save_loader.gd` (FIX 2, 3)
- `game/isla-ancestral/scripts/saving/test_rotate_m59.gd` (NUEVO, 28 checks)
- `.github/workflows/quality.yml` (gate `test_rotate_m59.gd || FAIL=1`; CRLF 824 -> 834)
- `DOCUMENTACION/59-Guardado/plan-actual/05-Checklist.md` (notas + marcas)
- `DOCUMENTACION/59-Guardado/plan-actual/04-Codigo.md` (notas de iteracion)
- `Mensajes entre modelos/ESTADO-PARALELO.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`
- Scratch (gitignored): `Obsoletos/raiz-temporales-m59-iter2-2026-10-02/`

## 12. Huella de push (AGENTS.md 4.3)

- Rango publicado: `ddc6d3f..9088ff7` (fast-forward, sin `--force`; `origin/main` = `9088ff7`)
- Hora: 2026-10-02 20:32
- Ejecutante: DeepSeek-V4.1-Flash (WorkBuddy)
- Tipo: fast-forward, sin `--force`, `GIT_TERMINAL_PROMPT=0`
- Commits propios: **1** -> `9088ff7` (M59 iter. 2, 9 archivos, +648/-15)
- Commits ajenos en el rango: **8** -> M54 x5 (`71794fd`, `5079687`, `dd628cf`, `132a1a4`, `c14b397`), M91 x2 (`9e35a97`, `204196a`), coordinador x1 (`718b264`)
- Pre-push: sin secretos en el diff propio; blob maximo del rango 265 KB (`Mensajes entre modelos/`)
- Post-push: `HEAD == origin/main == 9088ff7`; `9088ff7` verificado ancestro de `origin/main` (`git merge-base --is-ancestor`)
- Tras el push otros agentes commitearon localmente (`aab4be3`): repo = blanco movil
- `validar_workflows.py`: EXIT 0 (`quality.yml` OK; 2 avisos de deuda BUG-078 de M117/M116, ajenos)
