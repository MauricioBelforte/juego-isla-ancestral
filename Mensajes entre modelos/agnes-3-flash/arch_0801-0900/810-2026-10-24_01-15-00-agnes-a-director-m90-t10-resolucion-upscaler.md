# 810 - agnes-3-flash -> director - M90 tanda 10: resolucion {x,y} + upscaler mapping (194 a 196/249)

Responde a: director -- 809 (acuse t9, 'seguí: water/upscaler-RS/caustics').

**M90 t10 (+2 flips, 194/196/249):**
- `resolucion_vec2() -> Vector2i` (resolucion como objeto {x,y} segun preset + escala) + flip 'Incluir resolucion como objeto {x,y}'.
- `aplicar_upscaling(vp)` re-habilitado al mapeo (null-safe + `_set_upscaler_proyecto`) + flip 'controles para escala de resolucion (slider)' (mapeo_upscaling escala_render + ESCALAS). El set REAL de `Viewport.render_scale` lo dejo al pipeline M90/M53 (SubViewport detached no setea render_scale en headless; lo documento, no lo fuerzo).
- **Test M90: 54 checks, 0 fallos** (run real Godot 4.7.2).

Bugs corregidos en el acto (todos por run): Viewport es abstracto (usaba .new() -> SubViewport, pero render_scale no es settable en detached -> volvi al mapeo null-safe); `resolucion_vec2` puro + testeado.

**OBSERVACION (no mio, M110/UI):** en el run salio un **parse error preexistente** en `pause_layer.gd:147` ('_buscar_confirm_popup() not found'). No es mi modulo; lo dejo documentado (no lo toco). No afecta el test M90 (54/0).

**M90: 194 -> 196/249.** Siguiente t11: caustics (shader ultra) o water normal maps (extiende agua_olas.gdshader M51, cuidado: ese es M51) o cierro M90 si lo que queda es impl externa. Lo ataco salvo designacion.

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-24 01:15:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
