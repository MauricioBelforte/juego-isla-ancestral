# Log 2051: Tanda 80 - Item 125 (baseline horizonte con renderer real)

**Fecha:** 2026-10-20
**Hora:** 05:24
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** OpenCode

## Resumen

Se cerro el item 125 del BACKLOG (L191 de M62): "Baseline horizonte terrestre oteado: objetivo < 2.200 MB".

**No habia que implementar gameplay:** se midio con renderer real, se corrigio un bug del arnes de test
(la camara resolvia `_target` un frame despues y el scroll solo cambia `_distance`; la posicion converge
en `_physics_process`) y se agrego la lectura de VRAM.

Ademas se leyo el mensaje **170** del director: acepta 121 y 124, preserva las tandas 75-76 y ordena
seguir 125+. Plegado en el informe **171**.

## Bug del arnes encontrado y corregido

- `follow_camera._ready()` hace `await get_tree().process_frame` antes de resolver `_target`; el arnes
  aplicaba el escenario en el mismo frame del monitor y la camara quedaba en el origen (1136 m del
  Player). **Fix:** `_retardo_aplicar = 1.0` antes de aplicar.
- El scroll modifica `_distance`, pero `global_position` converge en `_physics_process`; medir en el
  mismo frame daba 12.09 -> 12.09. **Fix:** forzar modo EXPLORE y simular 2 s de `_physics_process`
  (20 x 0.1) antes de medir.
- **Solo test:** `sesion_m62_baselines.gd`. No se toco codigo de produccion.

## Mediciones

**Corrida 1 - arnes, sin `--headless`:**
`M62_ESCENARIO=horizonte`, `M62_ASENTAR_S=20`, `--rendering-driver opengl3`.
- **151.7 MB static**, 7384 objetos, **0 huerfanos**, **9 checks / 0 fallos / EXIT 0**.
- Camara a **20.00 m** del Player (tope `max_distance=20`).
- Log: `out/tanda80/horizonte_render.log`, sha256 `a714c30ed8db4b22864dace8085cb0034fe26bf9cb404bf2510b37e584fd522a`.

**Corrida 2 - probe de VRAM con zoom al tope:**
- **static 148.0 MB + VRAM 44.4 MB = 192.4 MB**; texturas 12.2 MB; buffers 32.2 MB; 7293 objetos.
- Log: `out/tanda80/probe_vram_horizonte.log`, sha256 `398910cc88453e4b2de7751b7adb2a0c8c6db89edee598a46c04924e2972be49`.

**Regresion spawn (arnes corregido):**
- **144.1 MB static**, 7/0, 0 huerfanos.
- Log: `out/tanda80/spawn_render_patch.log`, sha256 `e896ff9e9ddacdf721ce00865fe10ec308969338fc39a5766edc156b959c2c3b`.

## Resultado

**192.4 MB << 2200 MB = 8.7% del objetivo.** Cierra L191.

## Alcance

- Boot automatizado con renderer real y 20 s de asentamiento; no es una sesion manual.
- Sin banco de audio completo (0 assets en el repo).
- VRAM medida con `RENDER_VIDEO_MEM_USED`; el static es el del monitor de produccion.

## Cambios Realizados

- `sesion_m62_baselines.gd`: espera de camara + fisica tras scroll + mensaje de alcance dinamico.
- `05-Checklist.md` M62: L191 `[x]`; Totales **139/10/1**; seccion Tanda 80.
- `04-Codigo.md` M62: seccion Tanda 80.
- `07-Resultados-Testings.md` M62: seccion 31.
- BACKLOG: item 125 `[x]` y duplicado 20 `[x]`.
- Log 2051; informe 171; cron fila 74; tracker 171.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/rendimiento/memoria/sesion_m62_baselines.gd`
- `DOCUMENTACION/62-Memoria/plan-actual/04-Codigo.md`
- `DOCUMENTACION/62-Memoria/plan-actual/05-Checklist.md`
- `DOCUMENTACION/62-Memoria/plan-actual/07-Resultados-Testings.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md`
- `out/tanda80/horizonte_render.log`
- `out/tanda80/probe_vram_horizonte.log`
- `out/tanda80/spawn_render_patch.log`
- `out/tanda80/probe_vram_horizonte.gd`

**Firma:** DeepSeek-V4.1-Flash / OpenCode - Tanda 80 - 2026-10-20 05:24
