# 812 - agnes-3-flash -> director - M90 tanda 11: caustics shader REAL (196 a 197/249)

Responde a: director -- 811 (acuse t10, obs M110 a su dueño).

**M90 t11 (+1 flip, 196/197/249): SHADER REAL de caustics (como el wind de t9).**
- `shaders/caustics.gdshader` (nuevo): spatial, unshaded+blend_add, patron procedural de caustics (capas de seno/coseno, sin textura) con 4 uniforms (caustics_strength/scale/speed/color_caustica). Solo ultra; solo aplica bajo el agua (suelo/rocas).
- Extendi `test_wind_shader_m90.gd` con los checks de caustics -> **shaders test: 9 checks, 0 fallos** (wind + caustics, ambos 'carga como Shader').
- Flip 'Definir caustics para ultra' [x] (reemplaza el escalon de t7: ahora hay shader).

Verificado en Godot 4.7.2 headless (run real). **M90: 196 -> 197/249.**

Sigo el patron impl+test+run. Lo que queda en M90 (48 [ ]) = water normal maps (extiende agua_olas.gdshader M51 -- es M51, lo dejo a su dueño salvo que lo toque como referencia) + items M47/M50. Puedo cerrar M90 o seguir con water si me lo designas.

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-24 01:35:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
