# Log 2052: Tanda 81 - Item 126 (subterraneo del templo NO MEDIBLE) + recuperacion de docs

**Fecha:** 2026-10-20
**Hora:** 05:37
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** OpenCode

## Resumen

Se trabajo el item 126 del BACKLOG (L192 de M62): "Baseline subterraneo del templo (M26): objetivo < 2.000 MB".

**Resultado: `[?]` NO MEDIBLE.** No existe ninguna escena de templo ni API de acceso al subterraneo:
0 escenas `*templo*`, `*subterr*`, `*cueva*` en `scenes/`; solo scripts de puzzles en `scripts/templos/`
y referencias de zona en combate/mineria. El arnes solo puede bajar al Player 40 m en el spawn y el
VoxelTerrain reporta **0 bloques actualizados**, asi que el subterraneo no se ejercita. No se inventa
un baseline con `main_island.tscn`.

## Medicion

- Comando: `sesion_m62_baselines.gd`, `M62_ESCENARIO=subterraneo`, `M62_ASENTAR_S=20`,
  `--rendering-driver opengl3`, sin `--headless`.
- **155.9 MB static, 7354 objetos, 0 huerfanos, 8 checks / 1 fallo, EXIT 3 (detector ciego).**
- Evidencia: Player Y **6.0 -> -34.0**; **VoxelTerrain 1**, **bloques actualizados 0**.
- El fallo es "el escenario se aplico por API de produccion": no hay API de produccion a la que
  llamar; el arnes solo teletransporta en el spawn.
- Log: `out/tanda81/subterraneo_render.log`, sha256 `f1ea9c77d6faa6907934be27c148bf0aa9e2f5fc16f889f7accf349c579967bb`.
- **Ese numero NO es un baseline del templo y no se usa.**

## Fix de arnes

El mensaje de NO MEDIBLE decia "0 bloques generados en headless" incluso con renderer real. Ahora dice
"0 bloques actualizados: el subterraneo no se ejercita". Solo test.

## Incidente de integridad (importante para el director)

Durante el cierre de la Tanda 80, un script de reemplazo abrio los 4 archivos de documentacion en modo
`w` **antes** de leerlos, y los dejo en 0 bytes:

- `DOCUMENTACION/62-Memoria/plan-actual/05-Checklist.md`
- `DOCUMENTACION/62-Memoria/plan-actual/04-Codigo.md`
- `DOCUMENTACION/62-Memoria/plan-actual/07-Resultados-Testings.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md`

El commit **3b43f64** ("Se preservaron...") los commiteo como blobs vacios (e69de29). Se recuperaron
desde **75253f3** (ultima version con contenido: 88 KB / 47 KB / 68 KB / 128 KB) y se re-aplicaron
123/124/125/126. **El arbol de trabajo esta sano, pero HEAD sigue con los 4 vacios hasta el proximo
commit del director.** No se perdieron datos: 123/124 ya estaban en 75253f3 y 125/126 se re-escribieron
con la evidencia de `out/tanda80` y `out/tanda81`.

## Cambios Realizados

- `sesion_m62_baselines.gd`: mensaje de NO MEDIBLE corregido (solo test).
- `05-Checklist.md` M62: L191 `[x]`, L192 `[?]`; Totales **139/9/2**; secciones Tanda 80/81.
- `04-Codigo.md` M62: secciones Tanda 80/81.
- `07-Resultados-Testings.md` M62: secciones 31/32.
- BACKLOG: 125 `[x]`, 126 `[?]`, duplicados 20/21.
- Log 2052; informe 173; cron fila 75; tracker 173.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/rendimiento/memoria/sesion_m62_baselines.gd`
- `DOCUMENTACION/62-Memoria/plan-actual/04-Codigo.md`
- `DOCUMENTACION/62-Memoria/plan-actual/05-Checklist.md`
- `DOCUMENTACION/62-Memoria/plan-actual/07-Resultados-Testings.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md`
- `out/tanda81/subterraneo_render.log`

**Firma:** DeepSeek-V4.1-Flash / OpenCode - Tanda 81 - 2026-10-20 05:37
