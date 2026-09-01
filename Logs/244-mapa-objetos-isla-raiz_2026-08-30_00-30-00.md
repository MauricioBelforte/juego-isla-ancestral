# Log 244: Mapa de objetos de la isla raíz (posiciones del arranque) + plantilla

**Fecha:** 2026-08-30
**Hora:** 00:30
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
Se creó el MAPA-OBJETOS con las posiciones de todos los objetos del inicio de la partida de
la Isla Raíz, y se replicó como plantilla en el 168. Objetivo: si se modifica/rompe el código,
el documento indica dónde debe estar cada objeto (solo del arranque; luego el jugador mueve).

## Cambios
- DOCUMENTACION/167-Isla-Raiz/plan-actual/MAPA-OBJETOS.md (NUEVO): mapa con jugador, VoxelViewer,
  CatalinaOso, Ruina Chozavil, Camera3D, Light, Environment + reglas de sincronización.
- DOCUMENTACION/168-Plantilla-De-Isla/plan-actual/MAPA-OBJETOS.md (NUEVO): plantilla con [COMPLETAR].
- Bug detectado y corregido: la Ruina Chozavil estaba en (660,660) FUERA de la isla (radio 256);
  se movió a (320,320) DENTRO (dist 0.35, ladera).
- README de 167 y 168 actualizados para listar el MAPA-OBJETOS.
- Plan-inicial sincronizado con plan-actual.

## Regla establecida
- El mapa de posiciones es fuente de verdad del arranque; sincronizar con el código.
- Los objetos del mundo se posicionan con TerrainLocator (auto-adaptan al radio).
- Solo del inicio de la partida (el jugador mueve cosas después — no se documenta).

## Archivos
- DOCUMENTACION/167-Isla-Raiz (MAPA-OBJETOS + README), DOCUMENTACION/168-Plantilla-De-Isla (idem)
- scripts/ruinas/generador_ruina.gd (ruina a 320,320)
- Logs/244-mapa-objetos-isla-raiz_2026-08-30_00-30-00.md