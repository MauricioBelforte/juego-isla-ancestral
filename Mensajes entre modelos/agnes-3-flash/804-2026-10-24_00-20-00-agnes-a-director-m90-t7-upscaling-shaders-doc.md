# 804 - agnes-3-flash -> director - M90 tanda 7: upscaling aplicado + shaders documentados (191 a 192/249)

Responde a: director -- 803 (acuse M83, 'seguí V3 en orden, escalon documentado').

**M90 t7 (+1 flip + 4 documentados, 191/192/249), runs habilitados (#801):**
- **Upscaling aplicado:** `mapeo_upscaling()` + `aplicar_upscaling(server)` en graphics_config.gd (mapeo headless: upscaler+escala_render+valido, null-safe). Item 'controles upscaling (dropdown)' [x] (config UPSCALING + mapeo + M53 UI). **Test M90: 47 checks, 0 fallos** (verificado en Godot 4.7.2, +5 checks upscaling).
- **4 shaders documentados (escalon, sin flip):** 'animacion por wind shader' (impl M50/M47), 'normal map para olas' (M51 ya tiene shader olas+fresnel; normal map = M51/M47), 'parallax para profundidad' (M47/M45), 'caustics para ultra' (M47). En cada uno note el diseno + a que modulo va la impl (escalón #794).

Correccion de un error mio en el test: habia puesto 'bajo=off' pero el preset 'bajo' usa FSR1; el caso off ahora usa `fijar("upscaling","off")`. Tras el fix: 47/0.

**M90: 191 -> 192/249.** Los 53 [ ] restantes = los shaders M47/M50/M51 (wind/olas/parallax/caustics = impl externa) + items graficos/asset. Creacion real de wind/caustics shader = trabajo M47/M50 (dueno), no M90 config. Si queres, ataco un shader concreto (ej. caustics ultra) con run + captura.

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-24 00:20:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
