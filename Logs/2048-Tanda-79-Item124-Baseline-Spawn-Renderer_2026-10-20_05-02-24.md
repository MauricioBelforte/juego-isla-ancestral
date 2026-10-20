# Log 2048: Tanda 79 - Item 124 (baseline spawn con renderer real)

**Fecha:** 2026-10-20
**Hora:** 05:02
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** OpenCode

## Resumen

Se cerro el item 124 del BACKLOG (L190 de M62): "Baseline spawn de Aurora: objetivo < 1.600 MB".
**No habia que implementar codigo:** se midio el spawn real con **renderer real** (OpenGL 3.3,
AMD Radeon, ventana 640x360), no headless, y se agrego una lectura de VRAM.

Ademas se leyo el mensaje **168** del director: **rectifica** el aviso T-19 anterior y confirma que
el 165 estaba completo (1949 B, mtime 04:35:42). No hay accion pendiente por ese lado.

## Mediciones

**Corrida 1 - arnes de produccion, sin `--headless`:**
`sesion_m62_baselines.gd`, `M62_ESCENARIO=spawn`, `M62_ASENTAR_S=15`,
`--rendering-driver opengl3 --audio-driver Dummy --resolution 640x360`.
- **149.7 MB static**, pico 149.7 MB, 7307 objetos, **0 huerfanos**, 7 checks / 0 fallos / **EXIT 0**.
- Log: `out/tanda79/spawn_render.log`, sha256 `b993851600389d9e9514a6c77514af2decaf93444053bd755a46eb0059ebe903`.
- El log confirma `OpenGL API 3.3.0 Core Profile Context ... AMD Radeon(TM) Graphics`.

**Corrida 2 - probe de VRAM sobre la misma escena:**
`out/tanda79/probe_vram.gd` (one-off) instancia `main_island.tscn`, espera 12 s y lee
`Performance.MEMORY_STATIC`, `RENDER_VIDEO_MEM_USED`, `RENDER_TEXTURE_MEM_USED`,
`RENDER_BUFFER_MEM_USED`.
- **static 145.6 MB + VRAM 44.3 MB = 189.9 MB**; texturas 12.2 MB; buffers 32.1 MB; 7288 objetos.
- Log: `out/tanda79/probe_vram.log`, sha256 `7ed5c3f539c08c738d0a33a7c046de499caa22219895095c15490ddcac938b82`.

## Resultado

**189.9 MB << 1600 MB = 11.9% del objetivo.** Cierra L190.

## Alcance / Deuda declarada

- Boot automatizado con renderer real y 12-15 s de asentamiento; **no** es una sesion manual de juego.
- No hay banco de audio completo en el repo, asi que el objetivo de 1600 MB no incluye audio pesado.
- La VRAM se lee del renderer (`RENDER_VIDEO_MEM_USED`), no de una estimacion externa.

## Cambios Realizados

- `05-Checklist.md` M62: L190 `[x]`; Totales **138/11/1**; seccion Tanda 79.
- `04-Codigo.md` M62: seccion Tanda 79 (sin codigo nuevo).
- `07-Resultados-Testings.md` M62: seccion 30.
- BACKLOG: item 124 `[x]` y duplicado 19 `[x]`.
- Log 2048; informe 169; cron fila 73; tracker 169.

## Archivos Modificados/Creados

- `DOCUMENTACION/62-Memoria/plan-actual/04-Codigo.md`
- `DOCUMENTACION/62-Memoria/plan-actual/05-Checklist.md`
- `DOCUMENTACION/62-Memoria/plan-actual/07-Resultados-Testings.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md`
- `out/tanda79/spawn_render.log`
- `out/tanda79/probe_vram.log`
- `out/tanda79/probe_vram.gd`

**Firma:** DeepSeek-V4.1-Flash / OpenCode - Tanda 79 - 2026-10-20 05:02
