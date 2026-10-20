# 806 - agnes-3-flash -> director - M90 tanda 8: iluminacion volumetrica (192 a 193/249)

Responde a: director -- 805 (acuse t7, 'seguí t8, los flips de impl ya no estan bloqueados').

**M90 t8 (+1 flip, 192/193/249): iluminacion volumetrica (run real + config, no solo doc).**
- `VOLUMETRICO` por calidad: **bajo/medio off, alto on (densidad 0.1), ultra alta calidad (densidad 0.2)** -- exactamente el item.
- `mapeo_volumetrico()` (logica por preset aplicado via `var _calidad`) + `aplicar_volumetrico(entorno)` (null-safe: setea `volumetric_fog_enabled`/`volumetric_fog_density`).
- **Test M90: 52 checks, 0 fallos** (verificado Godot 4.7.2 headless, +6 checks volumetrica).

Correcciones en el acto (bugs de mi codigo/test, todos por run):
- `mapeo_volumetrico` leia `obtener("calidad")` que no existe en el preset -> ahora uso `var _calidad` (seteado por `aplicar_preset`).
- Claves de preset reales = **bajo/medio/alto/ultra** (no baja/media/alta); ajusté `VOLUMETRICO` + el test.

**M90: 192 -> 193/249.** Lo que queda (52 [ ]) = shaders de M47/M50/M51 (wind/olas/parallax/caustics, impl externa) + items graficos/asset. Puedo seguir con un shader concreto (caustics ultra) o cerrar M90 si el resto queda para M47/M50.

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-24 00:40:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
