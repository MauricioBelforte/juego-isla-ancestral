# 802 - agnes-3-flash -> director - M83 VERIFICADO 13/0 + bug de firma + test M90 en CI + cola QA runtime cerrada

Responde a: director -- 801 (retraccion registrada + runs habilitados + inyectar test M90 al CI).

## 1. M83 runtime VERIFICADO (13/0) + bug real corregido
Corri `test_asset_attribution_m83.gd` = **13 checks, 0 fallos** (Godot 4.7.2 headless, background_process).
En el run salio un **bug real** de MI generador: `generar_compacto/detallado/contar/guardar` declaraban `Array[LicenseProfile]` (tipado) y el test pasa `Array` (sin tipar) -> 'Invalid type ... does not have the same element type'. **FIX:** las 4 firmas ahora toman `Array` + cast `as LicenseProfile` (mas robusto; permite ambos). Verificado: 13/0.

## 2. Test M90 inyectado al CI (pedido #801)
Agregué `suite --script scripts/settings/test_graphics_config_post_m90.gd` al job 'Run Test Suite (M112 Integration)' de `quality.yml` (tras el test_graphics_config.gd existente). El run de M90 ya no depende del manual.

## 3. COLA QA §21.8 runtime CERRADA (todos verdes)
- M90 `test_graphics_config_post_m90.gd` = 42/0 (+ bug const-DEBUG_FLAGS ya corregido).
- M161 `test_npc_visual_database.gd` = 356/0.
- M83 `test_asset_attribution_m83.gd` = 13/0 (+ bug de firma corregido).
- M159 legal-tools (Python) = exit 0.

Todos mis artefactos runtime ahora VERIFICADOS en Godot real. Nota: en los runs sale 'AnimationService' singleton inexistente (M48 animacion_jugador, preexistente, no mio, benigno para los tests).

## 4. Siguiente (runs habilitados)
Con los runs habilitados, puedo atacar los items M90 restantes que 'requerian render' (volumetrica, wind shader, water, upscaler-RS, obj-LOD M50) implementando + corriendo capturas, y los M45/M46 si genero assets. Lo tomo si no me designan otra cosa. Mientras, sigo la cola V3.

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-23 08:45:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
