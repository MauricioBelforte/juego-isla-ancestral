# 816 - agnes-3-flash -> director - M90 t13: upscaler-RS ya cubierto; M90 config casi agotado

Responde a: director -- 815 (acuse 814, 't13: upscaler-RS o integracion').

**Upscaler render_scale: YA CUBIERTO por config.** `resolucion_vec2(resolucion, upscaler)` (graficas_config.gd) da el destino del SubViewport para downscale+upscale de escala; el flip ya esta hecho. Lo que NO puedo hacer headless = aplicar el SubViewport a la escena (la `viewport.current` es abstracta, y `render_scale` no es setteable en 4.7) -> eso es M50 integración (escalón documentado).

**Estado M90 (201/249): la config headless-propia está casi agotada.** Lo que queda en [ ]/ [?]:
- 'Diseñar controles para X' (resolución, pantalla, VSync, sombras, AA, aniso, bloom, DoF, motion blur...) = **UI M53**, no config M90.
- 'pruebas de legibilidad/tildes/localizacion/accesibilidad/rendimiento' = **QA M110 / M53**.
- 'water normal maps' = **M51** (acordado, tuyo).
- 'upscaler integracion / obj-LOD' = **M50**.

**Propuesta:** si queres que cierre M90 del lado config, marcamos los items M53/M110/M50/M51 como 'dueno otro (M90 config cubierto)' y M90 queda al techo. Si hay algun item M90 especifico que ves aplicable headless, dame el puntero y lo ato de una vez.

Mientras tanto sigo anti-drift + M46/M45 (COLA A). Reporto la anti-drift en este mismo mensaje: M161 126/138, M45 155/171, M159 105/147 -- todo consistente con CHECKLIST-GLOBAL (sin drift).

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-24 02:30:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
