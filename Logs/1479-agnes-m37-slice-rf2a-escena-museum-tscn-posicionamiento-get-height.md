# Log 1479: M37 slice RF2a — escena museum.tscn + posicionamiento en el mundo (get_height+1)

**Fecha:** 2026-10-08
**Hora:** 21:05
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Frente:** M37 RF2a (director msg 110: escena + posicionamiento; RF2b = voxel 3D pendiente)

## Resumen
Implementé la parte (a) del slice RF2 de M37: la escena del museo + su posicionamiento en el
mundo con anti-flotamiento (regla de AGENTS.md: TerrainLocator.get_height + 1, nunca IslandGenerator).
RF2b (construcción voxel 3D de las vitrinas + mostrador/cartel UI M53) queda PENDING.

## Cambios
- `scenes/museo/museum.tscn` (nuevo): edificio Museum (Node3D + museum.gd); salas + vitrinas se
  instancian en runtime desde data/museum/exhibiciones.json (alternativa B).
- `museum.gd` + `placiar_en_mundo(pos=MUSEO_POS)` + const MUSEO_POS=(3900,3830): posiciona el
  edificio con TerrainLocator.posicionar_sobre_terreno (anti-float get_height+1); fallback a y-base
  si el terrain no está listo (headless).
- `museum_placer.gd` (nuevo): `crear_en_mundo(padre)` instancia la escena + la posiciona.
- `test_museo_rf2.gd` (nuevo): **0 fallos / EXIT 0** (escena carga, estructura salas+curador+vitrinas,
  posicionamiento XZ a MUSEO_POS; el snapping del terreno se verifica en-editor). `test_museo_rf1.gd`
  sigue 0/0.
- `DOCUMENTACION/37-.../05-Checklist.md`: marcado `[x]` "El museo es accesible desde el inicio
  (sin bloqueos)" + **NOTA-AGNES RF2a** (alcance: escena + posicionamiento; voxel 3D + mostrador +
  cartel (UI M53) + exhibit_slot.tscn + registro persistente + reconstrucción = PENDING, sin
  sobremarcar).

## Reglas de isolación de islas
El posicionamiento SOLO LEE `TerrainLocator.get_height` (read-only del terreno); NO modifiqué el
generador de la isla ni M163/M167. MUSEO_POS es ajustable (decime si querés otro punto del pueblo).

## Archivos
- scenes/museo/museum.tscn (nuevo)
- scripts/museum/{museum,museum_placer,test_museo_rf2}.gd (museum.gd modificado + placer/test nuevos)
- DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md
- Reporte 111. No toqué el GLOBAL (lo actualiza el director).

— agnes-3-flash / Kilo Code
