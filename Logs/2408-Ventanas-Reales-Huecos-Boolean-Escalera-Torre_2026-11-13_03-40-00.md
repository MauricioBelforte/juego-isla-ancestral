# Log 2408: Ventanas reales (huecos Boolean) y corrección de choques de escalera

**Fecha:** 2026-11-13
**Hora:** 03:40
**Modelo:** ERNIE-5.5-Flash-Preview
**Plataforma:** Kilo Code

## Resumen

El usuario detectó dos problemas: las ventanas eran solo estéticas (no se veían desde el interior) y la escalera de la casa de las torres chocaba con la torre. Se cortaron huecos reales en los muros con Boolean, se reposicionaron las ventanas a planta baja y planta alta, se reubicó la torre este de la Mansión y se liberaron las escaleras de Agricultor/Mercader. Validación final: **68/68 ventanas visibles desde el interior**, **0 choques de escalera**, **0 solapes mueble-estructura**.

## Cambios Realizados

- **Huecos reales:** Boolean DIFFERENCE en los muros exteriores de las cuatro casas; **68 ventanas** con abertura (antes eran marcos pegados al muro).
- **Reposicionamiento:** las dos filas de ventanas estaban ambas en la planta alta; se bajaron a PB (`z=2,2/2,4`) y PA (`z=5,7/6,2`).
- **Visibilidad interior (raycast):** Casona 18/18, Mansión 20/20, Agricultor 14/14, Mercader 12/12.
- **Muebles que tapaban ventanas:** estanterías, espejo y chimenea movidos; tapiz oculto. 0 solapes mueble-estructura.
- **Torre este de la Mansión:** movida de (13, −9) a **(16, 9)**, fuera del interior; 0 solapes escalera-torre.
- **Tabiques E de Agricultor/Mercader:** movidos a x=3,8 y x=3,2; 0 solapes escalera-tabique.
- **AABB final:** 0 mueble-estructura y 0 mueble-mueble en las cuatro casas (postes del invernadero excluidos por ser estructura de soporte).

## Evidencia

| Casa | Ventanas visibles | Choque escalera | Solapes muebles |
|---|---:|---:|---:|
| Casona v2 | 18/18 | 0 | 0 |
| Mansión v2 | 20/20 | 0 (torre) | 0 |
| Agricultor | 14/14 | 0 (tabique) | 0 |
| Mercader | 12/12 | 0 (tabique) | 0 |

## Archivos Modificados

| Archivo | Cambio |
|---|---|
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_v2_guardadas_2026-11-12.blend` | Huecos de ventana, torre este en (16,9), muebles despejados |
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_extra_2026-11-12.blend` | Huecos de ventana, tabiques E movidos, muebles despejados |
| `CAPTURAS/*_2026-11-12.png` | Renders exterior/interior actualizados |
| `DOCUMENTACION/18-Casas/plan-actual/03-Diseno.md` | §10.5 |
| `DOCUMENTACION/18-Casas/plan-actual/04-Codigo.md` | §8.8 |
| `DOCUMENTACION/18-Casas/plan-actual/05-Checklist.md` | §Q + totales 213/204/9 |
| `CHECKLIST-GLOBAL.md` | Fila M18 |

## Pendientes

- Exportar GLB de las cuatro casas con LODs y unir materiales a ≤8.
- Integrar en Godot con `TerrainLocator` y M17; crear las escenas `house_*`.
- QA visual del usuario sobre los renders.

## Notas

- El QA numérico (raycast de ventanas + AABB + choques de escalera) está ejecutado; el modelo no lee imágenes.
- Las casas pequeñas siguen en la escena `Scene` y en `casas_ernie_pequenas_2026-11-12.blend`.