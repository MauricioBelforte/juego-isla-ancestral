# Log 2053: Tanda 82 - Item 127 (tormenta + audio: memoria medida, banco completo NO MEDIBLE)

**Fecha:** 2026-10-21
**Hora:** 01:03
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** OpenCode

## Resumen

Se trabajo el item 127 del BACKLOG (L193 de M62): "Baseline tormenta maxima (M32) + banco de audio
completo: <= 2.500 MB (Alta)".

**Resultado: `[?]`.** La memoria de la tormenta se midio con renderer real y esta muy por debajo del
objetivo (196.7 MB = 7.9%), pero el "banco de audio completo" **no existe**: 0 assets de audio en el
repo y `AmbientDirector.set_estado_clima()` (M42) sigue con 0 llamadores. Se uso un banco sintetico
de 3 MB como stand-in (mismo criterio de T72), que mide el mecanismo y el techo, no el asset real ni
el decoder. No se marca `[x]` un banco que no se midio.

## Medicion

**Tormenta real + banco sintetico, renderer OpenGL 3.3 (sin `--headless`):**
- `M62_ESCENARIO=tormenta`, `M62_ASENTAR_S=20`, `M62_AUDIO_BANCO_MB=3`.
- Clima 3 (Tormenta) tras 3 dias.
- **157.9 MB static, 7412 objetos, 0 huerfanos, 8 checks / 0 fallos / EXIT 0.**
- 7 buses de audio, 9 reproductores; banco 151.9 -> 157.9 MB.
- Log: `out/tanda82/tormenta_audio3_render.log`, sha256 `dd47de0f406c343dcefd7c51d598d77da1aa51f8434a06e71baec0e23608de92`.

**VRAM con tormenta + banco 3 MB:**
- **static 152.0 + VRAM 44.7 = 196.7 MB**; tex 12.2; buf 32.5; 7322 objetos.
- **7.9% del objetivo de 2500 MB.**
- Log: `out/tanda82/probe_vram_tormenta.log`, sha256 `70f7f327315cc6464155c804b582cf3365da77793b7a27420a5e290cbc308130`.

## Cambio de arnes (solo test)

- `sesion_m62_baselines.gd`: nueva variable `M62_AUDIO_BANCO_MB` (default 0 = off). Si es > 0, crea un
  `AudioStreamWAV` sintetico del tamano pedido y lo retiene durante la medicion; reporta el delta.
- `scripts/rendimiento/memoria/probe_vram_tormenta.gd`: probe nuevo (test) que llega a TORMENTA con
  `GameTime.avanzar_hasta`, crea el banco de 3 MB y lee VRAM. No es produccion.

## Bloqueo declarado

- **0 assets de audio** en el repo.
- **M42 `AmbientDirector.set_estado_clima()` tiene 0 llamadores de produccion**, asi que el clima de
  M32 no selecciona el banco de audio real.
- El sintetico no prueba assets ni decoder. El item se reabre cuando exista el banco real.

## T-19 del mensaje 174

El director aviso que el 173 seguia como plantilla vacia. **Falso positivo:** el 173 tiene **2323
bytes** y cuerpo completo desde 05:38. No se reenvia; se responde en el 175 con el resumen y el
tamano/mtime como evidencia.

## Cambios Realizados

- `sesion_m62_baselines.gd`: opcion de banco sintetico (test).
- `probe_vram_tormenta.gd`: probe nuevo (test).
- `05-Checklist.md` M62: L193 `[?]`; Totales **139/8/3**; seccion Tanda 82.
- `04-Codigo.md` M62: seccion Tanda 82.
- `07-Resultados-Testings.md` M62: seccion 33.
- BACKLOG: 127 `[?]` y duplicado 22.
- Log 2053; informe 175; cron fila 76; tracker 175.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/rendimiento/memoria/sesion_m62_baselines.gd`
- `game/isla-ancestral/scripts/rendimiento/memoria/probe_vram_tormenta.gd`
- `DOCUMENTACION/62-Memoria/plan-actual/04-Codigo.md`
- `DOCUMENTACION/62-Memoria/plan-actual/05-Checklist.md`
- `DOCUMENTACION/62-Memoria/plan-actual/07-Resultados-Testings.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md`
- `out/tanda82/tormenta_audio3_render.log`
- `out/tanda82/probe_vram_tormenta.log`

**Firma:** DeepSeek-V4.1-Flash / OpenCode - Tanda 82 - 2026-10-21 01:03
