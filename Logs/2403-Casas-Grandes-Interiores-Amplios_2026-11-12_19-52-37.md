# Log 2403: Casas grandes con interiores amplios y objetos nuevos

**Fecha:** 2026-11-12
**Hora:** 19:52
**Modelo:** ERNIE-5.5-Flash-Preview
**Plataforma:** Kilo Code

## Resumen

Se modelaron en Blender dos casas grandes con interiores sofisticados y espacios amplios, se crearon 21 objetos nuevos y se actualizaron los planes vigentes de M18, M45 y M47. Las casas pequeñas anteriores (`TALLER_MAREA` y `REFUGIO_PESCADOR`) se conservaron en la escena `Scene` y en el `.blend` de respaldo.

## Cambios Realizados

- **Casona del Gremio:** 16×12 m, 2 plantas, techo 3,4 m; 6 ambientes por planta; 608 piezas; 12.608 tris; 16 materiales.
- **Mansión del Museo:** 22×16 m, 2 plantas + 2 torres, techo 3,8 m; 6 ambientes por planta; 845 piezas; 19.866 tris; 15 materiales.
- **Reglas de espacio:** habitación mínima 4×4 m, techos 3,4–3,8 m, circulación ≥1,2 m, pasillos ≥1,5 m.
- **Objetos nuevos:** biblioteca caracol, mesa alquimista, tapiz ancestral, globo terráqueo, reloj de pie, vitrina de conchas, bañera de cobre, fuente interior, araña, cama con dosel, telar, acuario empotrado, estufa cerámica, vitrina de museo, piano de cola, arpa, esfera armilar, armadura, mesa de billar, hamaca y candelabro de pie.
- **Renders:** 5 imágenes en `tools/mcp/blender-mcp/18-Casas/CAPTURAS/` (general, casona exterior/interior, mansión exterior/interior).
- **Documentación actualizada:** `DOCUMENTACION/18-Casas/plan-actual/01-Requerimientos.md` §7, `02-Analisis.md` §7, `03-Diseno.md` §8, `04-Codigo.md` §8, `05-Checklist.md` §O; `DOCUMENTACION/45-Arte-3D/plan-actual/01-Requerimientos.md`; `DOCUMENTACION/47-Texturas-Y-Materiales/plan-actual/artbook_specs_m47.md` §X; `CHECKLIST-GLOBAL.md`.

## Archivos Modificados/Creados

| Archivo | Acción |
|---|---|
| `tools/mcp/blender-mcp/18-Casas/build_casas_grandes.py` | Creado — script generador |
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_grandes_2026-11-12.blend` | Creado — escena `Casas_Grandes` + `Scene` |
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_pequenas_2026-11-12.blend` | Creado — respaldo de las casas pequeñas |
| `tools/mcp/blender-mcp/18-Casas/CAPTURAS/*.png` | 5 renders |
| `DOCUMENTACION/18-Casas/plan-actual/01-Requerimientos.md` | Modificado — §7 |
| `DOCUMENTACION/18-Casas/plan-actual/02-Analisis.md` | Modificado — §7 |
| `DOCUMENTACION/18-Casas/plan-actual/03-Diseno.md` | Modificado — §8 |
| `DOCUMENTACION/18-Casas/plan-actual/04-Codigo.md` | Modificado — §8 |
| `DOCUMENTACION/18-Casas/plan-actual/05-Checklist.md` | Modificado — §O + totales 180/175/5 |
| `DOCUMENTACION/45-Arte-3D/plan-actual/01-Requerimientos.md` | Modificado — presupuesto casas grandes |
| `DOCUMENTACION/47-Texturas-Y-Materiales/plan-actual/artbook_specs_m47.md` | Modificado — §X materiales |
| `CHECKLIST-GLOBAL.md` | Modificado — fila M18 |

## Evidencia

- Casona: bbox 17,7×13,1×9,7 m; 608 piezas; 12.608 tris; 16 materiales; sin piezas bajo el suelo.
- Mansión: bbox 23,9×18,6×11,7 m; 845 piezas; 19.866 tris; 15 materiales; sin piezas bajo el suelo.
- Separación entre casas: Casona x ∈ [-18,8, -1,1]; Mansión x ∈ [1,0, 24,9] (sin solape).
- Renders con luminancia media 0,49–0,54 y 0 % de píxeles negros.
- Script ejecutado en 2,6 s; escena guardada y renderizada.

## Pendientes

- Exportar GLB exterior/interior con LODs y unir materiales a ≤8.
- Integrar en Godot con `TerrainLocator` y M17; crear `house_casona_gremio.tscn` y `house_mansion_museo.tscn`.
- Registrar los 21 objetos en M18/M159 y `HouseDecor`.
- QA visual con el usuario (6 azimuts por casa).

## Notas

- Las casas pequeñas no se eliminaron: viven en la escena `Scene` del `.blend` y en el respaldo `casas_ernie_pequenas_2026-11-12.blend`.
- El modelo no puede inspeccionar imágenes; la revisión estética final queda del lado del usuario. El QA numérico (bounds, apoyos, tris, materiales) sí se ejecutó.