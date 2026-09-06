# Log 644: M50 Vegetación — verificación V2 (GLBs presentes, 45 instancias pobladas)

**Fecha:** 2026-09-04
**Hora:** 07:10
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Verificación V2 de M50 Vegetación con visión: los 15 GLBs de vegetación EXISTEN en `assets/3d/media/50-Vegetacion_*.glb` (palmera, arbustos, helechos, árboles frutales, hierba, hongo, lianas, raíces), el catálogo JSON mapea 6 biomas con densidades, y el boot confirma **45 instancias pobladas, 0 omitidas**. La vegetación está en el mundo; la captura del spawn no las mostraba porque están distribuidas por radio 256 desde el centro (el spawn está en 320,320 — fuera del radio denso).

## Verificación de cadena completa
1. `vegetacion_config.json`: 6 biomas (playa/pradera/bosque/montaña/ribera/humedal) con tipos y densidades ✓
2. `vegetation_manager.gd`: tipos_para_bioma() + densidad() + posiciones() con PRNG seed 42 ✓
3. `vegetation_spawner.gd`: espera 2 frames (terreno listo), snap con TerrainLocator, BUG-022 (no plantar sobre agua h<3) ✓
4. GLBs: 15 archivos en assets/3d/media/ ✓
5. Boot: "[M50] Vegetación poblada: 45 instancias, 0 omitidas" ✓

## Pendiente de verificación V2 (con el usuario)
- Visibilidad en gameplay: moverse hacia el centro (256, 256) donde está la mayor densidad
- Escala de los GLBs (si son demasiado pequeños para verse a distancia)
- Distancia de render (VoxelViewer view_distance 128 vs radio 256)

## Archivos Modificados/Creados
- Sin cambios de código (verificación)
- `Logs/ULTIMO_NUMERO.txt` *(→ 644)*
- `Logs/reservas/644-...txt` *(creada y borrada)*

## Recomendación
La siguiente iteración de M50 debería enfocarse en: (1) verificar escala de GLBs in-game, (2) aumentar densidad cerca del spawn, (3) LOD para distancia.
