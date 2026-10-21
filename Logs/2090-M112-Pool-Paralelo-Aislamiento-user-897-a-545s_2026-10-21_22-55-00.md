# Log 2090: M112 — pool paralelo + aislamiento de user://: 897.0 s -> 545.3 s (presupuesto 600 s, CUMPLE)

**Fecha:** 2026-10-21
**Hora:** 22:55
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Resumen

Cierre de **P1** (M112, PRORIDAD 1 del director, plan aprobado en su msg 015). Los 2 items de tiempo
("suite <= 10 min") quedan CERRADOS con medicion propia: el tiempo total de suite bajo de
**897.0 s (14.95 min)** a **545.3 s (9.09 min)**. **M112: 219/225 -> 221/225.**

## Que se hizo (fix de test, sin tocar codigo del juego)

1. **Pool paralelo** en `tests/run_tests.gd`: 6 workers sobre las 41 suites SceneTree que **no** escriben
   `user://` ni lanzan `OS.execute` (deteccion estatica por fuente, `_es_segura_para_pool()`); el resto serial.
2. **Aislamiento de `user://` por worker** (APPDATA en Windows / XDG_DATA_HOME en Linux): sin esto las suites
   se pisan el estado guardado y el resultado **flapea** (1-2 timeouts alternando entre corridas).
3. Timeout de 300 s en el pool (con 6 workers la CPU se comparte) y contador para los archivos de redirect
   (unicos con ejecucion concurrente). El cronometro previo y el contrato de salida quedan intactos.

## Mediciones (mismo hardware, runner instrumentado)

| Corrida | Tiempo total | Suites OK | Tests | Fallos |
|---|---|---|---|---|
| SERIAL (Log 2086) | **897.0 s (14.95 min)** | 45/47 | 2441 | `test_crafting_inventory.gd` (3 checks) + `test_iconos_m159.gd` (TIMEOUT 180 s) |
| POOL sin aislamiento | 422-426 s | 46/47 | 2411-2462 | 1-2 TIMEOUT, **flapping** |
| **POOL + aislamiento** | **545.3 s (9.09 min) — CUMPLE 600 s** | 46/47 | 2462 | `test_iconos_m159.gd` (TIMEOUT 300 s, **preexistente**) |

**La cobertura NO baja**: el pool no saltea ninguna suite; los tests ejecutados suben de 2441 a 2462. El runner
conserva su contrato (mismas lineas `RESULTADO:` / `[EVIDENCIA]`, mismos codigos de salida) y el CI no se toca.

## Hallazgos

1. **El rojo de `integration/test_crafting_inventory.gd` (3 checks de M16/M14) era un ARTEFACTO del `user://`
   compartido** entre suites del runner, no un bug de crafting: con aislamiento por worker la suite **pasa**.
2. **El unico rojo restante es `tests/test_iconos_m159.gd` (TIMEOUT)**, que **ya colgaba en la corrida serial**
   (preexistente, riel M159, ya derivado a agnes). No se revierte nada (protocolo del director, msg 010).
3. **BUG-141 re-anotado por el director** contra el riel voxel (M07/M08/M167): la causa real es el deinit del
   GDExtension de Voxel Tools, no el hilo de guardado de `data_store`. El fix de test lo **solapa** en vez de
   eliminarlo.

## Archivos Modificados/Creados

**Modificado:**
- `game/isla-ancestral/tests/run_tests.gd` (pool de 6 workers, aislamiento de `user://` por hijo, timeout de
  pool a 300 s, contador de temporales; cronometro y contrato de salida intactos)
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md` (2 items de tiempo -> [x]; Totales 221/225; firma)
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/04-Codigo.md` (seccion 5: pool + tabla de mediciones)
- `CHECKLIST-GLOBAL.md` (fila 112), `DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOG-MASTER.md`
- `Mensajes entre modelos/ESTADO-PARALELO.md`
- `Logs/NUMEROS_DISPONIBLES.txt` (2090 consumido)

**Creado:**
- `Logs/2090-M112-Pool-Paralelo-Aislamiento-user-897-a-545s_2026-10-21_22-55-00.md` (este log)
- `Mensajes entre modelos/MiniMax-M3.1-Flash/016-2026-10-21_22-55-00-minimax-a-glm-5-3-director-p1-cerrado.md`

**Sin push ni commits.**
