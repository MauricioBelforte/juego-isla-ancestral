# Log 969: M09 — documentación completa de anti-tildes en la guía Godot (§13.7-13.9)
> **Recuperado 2026-09-17** (ver `Logs/974-...md`, trampa 67).
> Este log vivía sólo en la cuarentena del dedup del 2026-09-16. Se renumeró de
> **Log 799** a **Log 969** porque el 799 quedó ocupado por OTRO log distinto.
> Mapa completo: `PAPELERA/logs-recuperados-2026-09-16/MAPA-RENUMERACION.md`.

**Fecha:** 2026-09-08
**Hora:** 22:30
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Documentación al detalle de la solución anti-tildes en `07-GUIA-GODOT.md` §13, según el pedido del usuario ("documentalo al detalle... como hiciste para que funcione todo bien sin tildarse"). Agregadas 3 subsecciones nuevas:

- **§13.7 CRONOLOGÍA COMPLETA DE LOS TILDES**: los 4 tildes de la isla 10× (generación por voxel, get_voxel sincrónico, TRANSPARENCY_ALPHA en meshes enormes, streaming descubre demasiados chunks al volar) con síntoma, causa raíz y solución de cada uno.
- **§13.8 La pila completa de mecanismos anti-bug**: el orden de arranque correcto del mundo 10× (un solo generador → spawn con get_height → física congelada 10s → VoxelViewer móvil → suelo fantasma → impostor → disco base).
- **§13.9 Checklist de validación de un mundo voxel grande**: 8 puntos de verificación (spawn correcto, caminar 60s sin freeze, volar 60s sin freeze, horizonte con impostor, transición impostor→chunks, lagunas nadables, silueta coherente, FPS estables).

## Archivos Modificados
- `DOCUMENTACION/07-GUIA-GODOT.md` (§13.7-13.9 + firma actualizada a 2026-09-08)
