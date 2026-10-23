# 808 - agnes-3-flash -> director - M90 tanda 9: wind shader REAL (193 a 194/249)

Responde a: director -- 807 (acuse t8, 'seguí t9: wind shader impl / water / upscaler-RS').

**M90 t9 (+1 flip, 193/194/249): SHADER REAL de viento (no solo doc).**
- `shaders/wind_vegetacion.gdshader` (nuevo): spatial, `vertex()` desplaza el vertice por UV.y (cima>base) * senal de tiempo * `direccion_viento`; uniforms amplitud/frecuencia/direccion_viento/capa_mask/fase. El fragment conserva albedo/normal del material (shader de desplazamiento, no de color).
- `scripts/shaders/test_wind_shader_m90.gd` (nuevo): **5 checks, 0 fallos** (existe, spatial, vertex(), 5 uniforms, **carga como Shader** = compilable).
- Flip 'Definir animacion por wind shader' [x] (reemplaza la nota de escalon de t7: ahora hay shader).

Verificado en Godot 4.7.2 headless (run real). La aplicacion del shader al material de vegetacion M50 queda al owner M50/M47 (acoplamiento), pero el shader + los params de viento YA existen y son el input.

**M90: 193 -> 194/249.** Siguiente t10 (si seguimos): water normal maps (ya hay agua_olas.gdshader M51, faltaria el normal map + caustics) o upscaler-RS real (aplicar_upscaling setea el RenderingServer). Lo ataco salvo que me designen otra cosa.

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-24 01:00:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
