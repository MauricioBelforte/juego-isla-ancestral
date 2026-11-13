# Log 2407: Casas extra, ventanas, chimeneas visibles y detalle exterior/interior

**Fecha:** 2026-11-12
**Hora:** 23:45
**Modelo:** ERNIE-5.5-Flash-Preview
**Plataforma:** Kilo Code

## Resumen

El usuario pidió casas más detalladas, habitables y con exteriores más reales; además detectó que las casas anteriores no tenían ventanas y que las chimeneas quedaban ocultas. Se crearon dos casas extra (Agricultor y Mercader), se agregaron **640 ventanas** a las cuatro casas, se subieron las chimeneas por encima de la cumbrera y se sumó detalle exterior e interior. Validación final: **0 solapes, 0 objetos sobre el hueco de escalera, 0 mueble-mueble**.

## Cambios Realizados

- **Casa del Agricultor (18×13, 2 plantas, 3,6 m):** cocina/comedor, vestíbulo, granero, despensa, almacén de herramientas, cuarto de ordeño, dormitorio principal, dormitorio infantil, taller, almacén de semillas y lavadero. Exterior con silo, pacas, carretilla, cerca, pozo, farol, sendero y jardineras.
- **Casa del Mercader (16×12, 2 plantas, 3,8 m):** tienda con mostrador, estanterías, balanza y caja fuerte; almacén, trastienda/oficina, cocina, baño; dormitorio principal, invitados, estudio/contabilidad, sala de estar y vestidor. Exterior con toldo, cartel, escaparate, barriles y cajas.
- **Ventanas:** 640 objetos (marco, vidrio, traviesa, postigos, jardinera y flores) en muros traseros y laterales de las cuatro casas.
- **Chimeneas:** subidas a 3,4–3,6 m y acercadas a la cumbrera; topes por encima del techo (Casona 11,38 vs 10,20; Mansión 12,43 vs 11,45; Agricultor 11,38 vs 10,20; Mercader 12,02 vs 10,85).
- **Detalle exterior:** vigas de esquina, zócalo perimetral, aleros, sendero, cerca, farol, pozo, jardineras.
- **Detalle interior:** zócalos, vigas de techo, marcos de puertas, cuadros y vajilla.
- **Validación:** AABB + hueco de escalera; 0 solapes en las cuatro casas.

## Métricas finales

| Casa | Piezas | Tris | Materiales |
|---|---:|---:|---:|
| Casona v2 | 807 | 18.708 | 18 |
| Mansión v2 | 1.091 | 27.502 | 17 |
| Agricultor | 546 | 12.330 | 17 |
| Mercader | 592 | 12.708 | 18 |

## Archivos Modificados/Creados

| Archivo | Acción |
|---|---|
| `tools/mcp/blender-mcp/18-Casas/build_casas_extra.py` | Creado — Agricultor y Mercader |
| `tools/mcp/blender-mcp/18-Casas/add_exterior_detail.py` | Creado — ventanas, chimeneas, vigas, zócalos, aleros, sendero, cerca, pozo, farol |
| `tools/mcp/blender-mcp/18-Casas/add_interior_detail.py` | Creado — zócalos interiores, vigas, marcos, cuadros, vajilla |
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_extra_2026-11-12.blend` | Creado — escena `Casas_Extra` + v2 + pequeñas |
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_v2_guardadas_2026-11-12.blend` | Actualizado — v2 con detalle |
| `CAPTURAS/*_2026-11-12.png` | 6 renders exterior/interior |
| `DOCUMENTACION/18-Casas/plan-actual/03-Diseno.md` | Modificado — §10 |
| `DOCUMENTACION/18-Casas/plan-actual/04-Codigo.md` | Modificado — §8.7 |
| `DOCUMENTACION/18-Casas/plan-actual/05-Checklist.md` | Modificado — §P + totales 200/193/7 |
| `DOCUMENTACION/45-Arte-3D/plan-actual/01-Requerimientos.md` | Modificado — casas extra y detalle |
| `CHECKLIST-GLOBAL.md` | Modificado — fila M18 |

## Pendientes

- Exportar GLB de Agricultor y Mercader con LODs ≤6.000 tris y unir materiales a ≤8.
- Integrar en Godot con `TerrainLocator` y M17; crear `house_agricultor.tscn` / `house_mercader.tscn`.
- QA visual del usuario sobre los renders.

## Notas

- Las casas pequeñas siguen en la escena `Scene` y en `casas_ernie_pequenas_2026-11-12.blend`.
- El modelo no lee imágenes; el QA numérico (AABB + hueco de escalera + topes de chimenea) sí se ejecutó.