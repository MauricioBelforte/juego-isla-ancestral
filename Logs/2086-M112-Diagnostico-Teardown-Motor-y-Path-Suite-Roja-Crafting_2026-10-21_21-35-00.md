# Log 2086: M112 — diagnostico del costo real de la suite + path exacto de la suite roja de crafting

**Fecha:** 2026-10-21
**Hora:** 21:35
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Resumen

Vuelta con 3 encargos del director (msg 8, 10, 11): P1 (fix headless de M112), P2 (QA de M90), P3 (frente
M17). En esta vuelta: (a) **P1 avanzado con el diagnostico real del cuello de botella** (el fix "topes 30
frames" aprobado NO recupera el tiempo: el costo esta en la salida final del motor, por el hilo de guardado
que incluye el mundo voxel en binario); (b) **respondido el pedido de path de la suite roja de crafting** con
evidencia dura (el archivo EXISTE y esta trackeado; el glob en 0 hits del otro agente fue un falso 0).

## Cambios Realizados

### 1. Diagnostico del costo de la suite (P1) — sondas propias, ya borradas

| Sonda | Resultado |
|---|---|
| boot + `quit()` SIN escena | **2.8 s** |
| boot + `main_island.tscn` + `quit()` | **101.9 s** |
| cronometro interno del script: escena montada / `remove_child` / `free()` / `quit()` | 1.3 s / 1.3 s / 1.32 s / 1.32 s -> el 100% del costo es DESPUES de `quit()` |
| `streaming_enabled` | la property NO existe (props: `stream`, `process_thread_group`, `run_stream_in_editor`) |
| `VoxelViewer.view_distance = 32` | 96.9 s (sin efecto) |
| quitar `VoxelTerrain` + `VoxelViewer` | 66.7 s (sin efecto) |
| `SaveManager.current_slot = 0` + `_blocked = true` | 62.2 s (sin efecto; el slot ya venia en -1) |

**Cadena real:** al montar la escena se dispara un guardado asincrono cuyo payload incluye el **mundo voxel en
binario** (`DataStore._guardar_voxel_binario`, `scripts/datos/data_store.gd` L589) y el hilo tarda ~60 s; al salir
`DataStore` hace `_hilo_guardado.wait_to_finish()` (L100-104) -> la salida del proceso espera. **Bug de
producto:** cerrar el juego con el mundo voxel cargado tarda ~1 minuto.

**Fix propuesto (NO aplicado, falta corrida de validacion):** (1) que el guardado asincrono no incluya el mundo
voxel en procesos de test (o un flag `--no-save` que `DataStore` respete) -> ~60 s x 5 suites; (2) paralelizar
las 4 carpetas GdUnit4 (~300 s), ganancia INDEPENDIENTE de esta causa. Con 1+2: 897 s -> ~300 s.

**Consecuencia del plan aprobado:** "topes 30 frames" NO recupera el tiempo de esas suites (el cuello no son las
esperas). Se reporta medido en vez de aplicar un cambio que no mueve la aguja. Se aplicara el protocolo del
director (msg 10): si alImplementar (1) o (2) alguna suite queda ROJA, NO se revierte el cambio: se documenta
como HALLAZGO con suite + check + condicion incumplida y se deriva al dueno.

### 2. Path exacto de la suite roja de crafting (pedido del director msg 11)

- **Ruta EXACTA:** `game/isla-ancestral/tests/integration/test_crafting_inventory.gd` (5948 bytes).
- **SI esta trackeado en git:** commit `35f7cc5` ("Se actualizaron 5 archivos del cubo M16-Crafting
  (lote 2 de commits)"). El "0 hits" del glob del otro agente fue un **falso 0** (probablemente sin `**`
  para la subcarpeta `integration/`).
- **Lineas exactas de mi run de 897 s:** `[SUITE SceneTree] res://tests/integration/test_crafting_inventory.gd`
  -> `[FAIL] rc=1`; y la **segunda** suite roja del run: `res://tests/test_iconos_m159.gd` ->
  `[FAIL] TIMEOUT — suite colgada >180s` (M159, riel de otro agente).
- **Reproducible ahora (rc=1), los 3 checks que fallan:**
  1. `[FAIL] segundo craft exitoso`
  2. `[FAIL] pico_cobre total = 2 n=1`
  3. `[FAIL] pico_cobre total = 4 n=3`
  (los demas 18 checks del suite pasan; `=== Resumen M16+M14: 21 checks, 3 fallos ===`)

### 3. Autoincidencia reportada (por honestidad)

Al limpiar mis sondas temporales use un glob `_sonda*.gd` que **tambien borro `tests/_sonda_bug119.gd`, que
NO era mio y si esta trackeado** (commit `da4ca3f`). **Restaurado de inmediato con `git restore`** y
verificado (existe, `git status` limpio). Lo reporto en vez de dejarlo pasar.

## Archivos Modificados/Creados

**Modificado:**
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md` (diagnostico en los 2 items de tiempo)
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/04-Codigo.md` (seccion 4: diagnostico de la causa)
- `CHECKLIST-GLOBAL.md` (fila 112: nota del diagnostico)
- `DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOG-MASTER.md` (M112: nota del diagnostico)
- `Logs/NUMEROS_DISPONIBLES.txt` (2086 consumido)

**Creado:**
- `Logs/2086-M112-Diagnostico-Teardown-Motor-y-Path-Suite-Roja-Crafting_2026-10-21_21-35-00.md` (este log)
- `Mensajes entre modelos/MiniMax-M3.1-Flash/012-2026-10-21_21-35-00-minimax-a-glm-5-3-director-p1-diagnostico-y-path-crafting.md`

**Restaurado (por error mio):** `game/isla-ancestral/tests/_sonda_bug119.gd` (borrado por un glob mio, restaurado
con `git restore` en el mismo minuto).

## Lo que NO se hizo

- P1 **no esta cerrado**: no se aplico todavia el fix (falta implementarlo y correr la validacion completa).
- P2 (QA de M90) y P3 (frente M17) **no se tocaron en esta vuelta**:Prioridad 1 era el diagnostico, que es lo que
  condiciona el fix correcto.
