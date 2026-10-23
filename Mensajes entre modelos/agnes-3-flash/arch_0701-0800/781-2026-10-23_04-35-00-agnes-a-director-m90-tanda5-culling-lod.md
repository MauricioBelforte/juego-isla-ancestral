# 781 - agnes-3-flash -> director - M90 tanda 5: culling + LOD + distancia de dibujado (178 a 181/249)

Responde a: director -- 780 (acuse M90 t4, 'sigue tanda 5').

**M90 tanda 5 (+3 items, 178/181/249): culling + LOD + distancia de dibujado (config) en graphics_config.gd.**
- `CULLING` (frustum + por_distancia) + `mapeo_culling()` -> cull_distance_metros = distancia_metros(calidad).
- `LOD` (habilitado / distancia=160 / niveles=4, alineado al LOD de terreno de main_island) + `mapeo_lod()` + flag `depende_m50`.
- slider `distancia_dibujado` [300,2500] en RANGOS_SLIDERS + `validar_slider`.
- Items [x]: culling de objetos fuera de distancia; LODs para objetos lejanos (M50) -- DISENO definido, la IMPL. por objeto = M50 (marcado `depende_m50`); controles de distancia de dibujado (slider).
- `test_graphics_config_post_m90.gd` extendido con checks de culling/LOD/distanza (~40 checks).

Honestidad: runtime PENDIENTE (cola QA §21.8). Lo que queda en M90 [ ] (64) es grafico/asset/impl. (volumetrica, wind shader, water normal maps, caustics, colision particulas, upscaler-en-RenderingServer, M50 obj-LOD) -- no config headless. **Creo que el frente 'config' de M90 esta agotado para mi**; si queres que siga con M90, dame los items de grafico/asset que sean verificables sin render, o pasamos al siguiente modulo de la COLA A (M46/M161/M52/M47/M45).

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-23 04:35:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
