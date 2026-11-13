# Log 2405: Casas v2 — corrección de mesa en pared y alfombra sobre escalera

**Fecha:** 2026-11-12
**Hora:** 23:20
**Modelo:** ERNIE-5.5-Flash-Preview
**Plataforma:** Kilo Code

## Resumen

El usuario reportó dos fallas concretas: una mesa atravesaba la pared y la alfombra de la cama tapaba la subida de la escalera. Se analizaron las ubicaciones con AABB y con chequeo explícito del hueco de escalera, y se corrigieron hasta **0 solapes, 0 objetos sobre el hueco y 0 mueble-mueble**.

## Cambios Realizados

- **Casona — comedor:** el tabique E1/E2 se movió de x=3,5 a x=2,8; el comedor pasó a 7,2 m de ancho. La mesa de 3,6 m ya no atraviesa la pared; la alfombra se redujo a 3,8 m.
- **Casona — dormitorio infantil:** la cama, el escritorio, la silla y la alfombra se sacaron del hueco de escalera (x 7,0..9,2); cama a x=5,8, escritorio a y=0,5, alfombra a x=5,2.
- **Casona — detalles:** consolas, espejo del vestíbulo, estanterías y biblioteca caracol corridos para dejar ≥0,10 m con muros y tabiques; plantas movidas.
- **Mansión — biblioteca:** la segunda mesa de lectura se movió de x=11,5 a (8,0; 1,5); el billar de x=9,0 a (7,5; −1,5).
- **Mansión — dormitorio de invitados:** cama y alfombra movidas de x=9,5 a x=7,5; escritorio a y=0,0; silla a y=−0,9; fuera del hueco x 10,0..12,5.
- **Mansión — detalles:** estanterías de la biblioteca, carta estelar, estante del observatorio, estante de cocina, mesa de recepción, consola y planta movidos para clearance.

## Validación final

| Casa | Muebles | Solapes mueble-estructura | Objetos sobre el hueco | Solapes mueble-mueble |
|---|---:|---:|---:|---:|
| Casona v2 | 496 | **0** | **0** | **0** |
| Mansión v2 | 708 | **0** | **0** | **0** |

> Tolerancias: 0,02 m para estructura sólida (muros, tabiques, escaleras, torres, techo de invernadero); 0,0 m para mueble-mueble; el hueco de escalera se chequea en coordenadas mundiales (Casona x −6,0..−3,8; Mansión x 26,0..28,5; ambas a la altura de planta alta).

## Archivos Modificados/Actualizados

| Archivo | Acción |
|---|---|
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_grandes_v2_2026-11-12.blend` | Actualizado — posiciones finales |
| `tools/mcp/blender-mcp/18-Casas/CAPTURAS/*_v2_*_2026-11-12.png` | Regenerados — 5 renders |
| `DOCUMENTACION/18-Casas/plan-actual/03-Diseno.md` | Modificado — §9.6 |
| `DOCUMENTACION/18-Casas/plan-actual/04-Codigo.md` | Modificado — §8.6 |
| `DOCUMENTACION/18-Casas/plan-actual/05-Checklist.md` | Modificado — nota v2 |
| `CHECKLIST-GLOBAL.md` | Modificado — fila M18 |

## Pendientes

- Exportar GLB exterior/interior con LODs y unir materiales a ≤8.
- Integrar en Godot con `TerrainLocator`; crear `house_casona_gremio_v2.tscn` / `house_mansion_museo_v2.tscn`.
- QA visual del usuario sobre los renders.

## Notas

- Las casas pequeñas siguen en la escena `Scene` y en `casas_ernie_pequenas_2026-11-12.blend`.
- El modelo no lee imágenes; el QA numérico (AABB + hueco de escalera) sí se ejecutó.