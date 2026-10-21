# Log 2059: Tanda 87 - Item 132 (preset Baja 4 GB, NO MEDIBLE)

**Fecha:** 2026-10-21
**Hora:** 01:39
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** OpenCode

## Resumen

Se trabajo el item 132 del BACKLOG (L221 de M62): "Test en preset Baja con 4 GB de RAM: sesion
completa sin OOM y jugable [C]".

**Resultado: `[?]` NO MEDIBLE, con parcial medido.** El preset Baja esta configurado y verificado
(`budgets.json` total **1.500 MB**, 8 sistemas; `test_m62_preset_baja_m27.gd` **13/0**, T76) y la
sesion de 30 min de T72 tiene pico **178.2 MB static (T72) y 44.7 MB VRAM (probe T82, corrida separada)**, 26x por debajo de 4 GB, sin OOM.
Pero **no hay hardware de 4 GB ni simulador de OOM**: correr headless no impone el limite de 4 GB y no
prueba el allocator; ademas "jugable" exige input/Play Mode real, y el arnes `--script` no itera a
60 Hz (medido: 8 physics frames en 10 s). Marcar `[x]` seria un verde falso.

## Evidencia parcial

- `out/tanda72/sesion_audio_30min.log`: 178.2 MB static, drift +0.1%, 0 OOM.
- `out/tanda76/preset_baja_m27.log`: gate de islas en Baja, 13 checks / 0 fallos.
- `game/isla-ancestral/data/rendimiento/budgets.json`: preset Baja = 1.500 MB total.

## Falta para cerrar

- Playtest del usuario en una maquina de 4 GB, **o**
- Job Object de Windows con `ProcessMemoryLimit=4GB` + escena con input/Play Mode real.

## Cambios Realizados

- `05-Checklist.md` M62: L221 `[?]`; Totales **143/3/4**; seccion Tanda 87.
- `04-Codigo.md` M62: seccion Tanda 87.
- `07-Resultados-Testings.md` M62: seccion 38.
- BACKLOG: 132 `[?]` y duplicado 27 `[?]`.
- Log 2059; informe 185; cron fila 81; tracker 187 (incluye acuse 186 y corrección 187).

## Archivos Modificados/Creados

- `DOCUMENTACION/62-Memoria/plan-actual/04-Codigo.md`
- `DOCUMENTACION/62-Memoria/plan-actual/05-Checklist.md`
- `DOCUMENTACION/62-Memoria/plan-actual/07-Resultados-Testings.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md`

**Firma:** DeepSeek-V4.1-Flash / OpenCode - Tanda 87 - 2026-10-21 01:39
