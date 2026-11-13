# Log 2404: Casas grandes v2 — 20×15 y 28×20, 0 solapes

**Fecha:** 2026-11-12
**Hora:** 22:55
**Modelo:** ERNIE-5.5-Flash-Preview
**Plataforma:** Kilo Code

## Resumen

El usuario reportó que las casas grandes seguían apretadas y con objetos superpuestos. Se midió el solape real con AABB en Blender, se rediseñaron ambas casas a **20×15 m** y **28×20 m**, se corrigieron los 7/13 solapes restantes y se verificó **0 solapes mueble-estructura y 0 mueble-mueble**.

## Cambios Realizados

- **Casona del Gremio v2:** 20×15 m, 2 plantas, techo 3,6 m; 300 m²/planta; 568 piezas; 11.896 tris; 16 materiales.
- **Mansión del Museo v2:** 28×20 m, 2 plantas + torres, techo 4,0 m; 560 m²/planta; 826 piezas; 19.874 tris; 15 materiales.
- **Densidad:** 1,89 / 1,48 piezas/m² (frente a 3,17 / 2,40 en v1).
- **Solapes:** v1 tenía 76/100 mueble-estructura y 210/339 mueble-mueble; v2 quedó en **0/0** y **0/0**.
- **Correcciones puntuales:** armarios y vestidores separados de muros; chimeneas corridas; vitrina de museo separada de la torre; armadura separada del tabique; araña bajada del techo; techo del invernadero por debajo de la losa de planta alta; barrera de galería separada de la torre.
- **Archivos v2:** `build_casas_grandes_v2.py`, `casas_ernie_grandes_v2_2026-11-12.blend`, 5 renders `CAPTURAS/*_v2_*`.
- **Documentación actualizada:** M18 `01` RF13, `02` §7.6, `03` §9, `04` §8.6, `05` §O; M45 presupuesto v2; `CHECKLIST-GLOBAL.md`.

## Archivos Modificados/Creados

| Archivo | Acción |
|---|---|
| `tools/mcp/blender-mcp/18-Casas/build_casas_grandes_v2.py` | Creado — generador + validador AABB |
| `tools/mcp/blender-mcp/18-Casas/casas_ernie_grandes_v2_2026-11-12.blend` | Creado — escena v2 + casas pequeñas |
| `tools/mcp/blender-mcp/18-Casas/CAPTURAS/*_v2_*.png` | 5 renders |
| `DOCUMENTACION/18-Casas/plan-actual/01-Requerimientos.md` | Modificado — RF13 |
| `DOCUMENTACION/18-Casas/plan-actual/02-Analisis.md` | Modificado — §7.6 |
| `DOCUMENTACION/18-Casas/plan-actual/03-Diseno.md` | Modificado — §9 |
| `DOCUMENTACION/18-Casas/plan-actual/04-Codigo.md` | Modificado — §8.6 |
| `DOCUMENTACION/18-Casas/plan-actual/05-Checklist.md` | Modificado — §O + nota v2 |
| `DOCUMENTACION/45-Arte-3D/plan-actual/01-Requerimientos.md` | Modificado — presupuesto v2 |
| `CHECKLIST-GLOBAL.md` | Modificado — fila M18 |

## Evidencia

- Casona v2: 568 piezas, 11.896 tris, 16 materiales, bbox 21,1×16,0×10,3 m, 0 solapes.
- Mansión v2: 826 piezas, 19.874 tris, 15 materiales, bbox 30,2×22,8×12,9 m, 0 solapes.
- Validador AABB con tolerancia 0,10 m; exclusiones only intended (chimenea-techo, base/respaldo, tapa/cuerpo de piano, anillos de esfera armilar).
- Renders v2 guardados y escena v2 guardada.

## Pendientes

- Exportar GLB exterior/interior con LODs ≤6.000 tris y unir materiales a ≤8.
- Integrar en Godot con `TerrainLocator` y M17; crear `house_casona_gremio_v2.tscn` / `house_mansion_museo_v2.tscn`.
- Registrar los 21 objetos en M18/M159 y `HouseDecor`.
- QA visual con el usuario.

## Notas

- Las casas pequeñas (`TALLER_MAREA`, `REFUGIO_PESCADOR`) siguen en la escena `Scene` y en `casas_ernie_pequenas_2026-11-12.blend`.
- La escena v1 (`Casas_Grandes`) se eliminó del archivo v2 para no duplicar geometría; queda como histórico en `casas_ernie_grandes_2026-11-12.blend`.
- El modelo no puede inspeccionar imágenes; el QA numérico (AABB, bounds, tris, materiales) sí se ejecutó.