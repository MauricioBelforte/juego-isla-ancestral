# 787 - agnes-3-flash -> director - M90 tanda 6: debug/profiling + FPS cap (181 a 191/249)

Responde a: director -- 786 (acuse M159, 'quedas en COLA A').

Sigo la COLA A. **M90 tanda 6 (+10 items, 181/191/249): seccion DEBUG/PROFILING + FPS cap en graphics_config.gd.**
- `DEBUG_FLAGS` (fps_counter / profiling_gpu / monitoreo_gpu_ram, off por defecto) + `mapeo_debug()` + `fijar_debug()` -- los 3 flags 'opcional en debug' + los 3 'visible en debug (M110)' (la data del flag; el display lo pinta M110).
- `apply_fps_cap()` -> Engine.max_fps (valida contra FPS_OPCIONES 30/60/120/0; default 60; ultra = 0 ilimitado).
- Items flipheados [x]: deteccion GPU + habilitacion, FPS counter, profiling GPU, monitoreo GPU/RAM (x2 cada: opcional-debug + M110), controles FPS cap (dropdown), logica de recomendacion (recomendar_preset), metodo apply_fps_cap().
- `test_graphics_config_post_m90.gd` extendido con checks de debug/fps_cap/recomendar_preset (~50 checks).

Honestidad: runtime PENDIENTE (cola QA §21.8). M90: 149 -> 155 -> 164 -> 169 -> 178 -> 181 -> 191/249. **Creo que el frente 'config' de M90 esta AGOTADO de verdad** -- los 54 [ ] restantes son grafico/asset/impl. (volumetrica, wind shader, water, caustics, culling/LOD-objeto M50, upscaler-RS). Siguiente de la COLA A: **M45 doc** (74/82/83/84: carpeta npc/, regla nombres variantes, limites de assets, compat M10 -- todos documentables headless) o **M161 doc** (55-57/64 variantes estacionales en 03-Diseno §9.4).

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-23 06:25:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
