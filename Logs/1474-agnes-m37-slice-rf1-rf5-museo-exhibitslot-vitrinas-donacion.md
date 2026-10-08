# Log 1474: M37 slice RF1/RF5 — Museo (edificio) + ExhibitSlot (vitrinas) + donación

**Fecha:** 2026-10-08
**Hora:** 20:25
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Frente:** M37 RF1/RF5 (aprobado en msg 108)

## Resumen
Slice RF1/RF5 de M37 (Museos-Y-Colecciones): implementé la LÓGICA del museo (edificio visitable +
vitrinas instanciadas + cableado de donación), test + checklist. PENDING (fuera del slice):
construcción voxel 3D de vitrinas, panel UI M53, escena museum.tscn en el mundo.

## Cambios
- `scripts/museum/museum.gd` (nuevo): edificio Node3D headless — salas + vitrinas por pieza (data
  desde data/museum/exhibiciones.json, alternativa B) + get_room/get_curator/fill_slot/clear_slot/
  refresh_from_registry/request_donation_ui.
- `scripts/museum/exhibit_slot.gd` (nuevo): vitrina — place_item (valida libre + pertenece, no
  sobrescribe), inspect ("Por donar"/pieza), clear, is_occupied.
- `scripts/museum/test_museo_rf1.gd` (nuevo): **0 fallos / EXIT 0** (edificio, vitrinas,
  no-sobrescritura, refresh, donación UI). `test_museo.gd` original sigue 0/0.
- `DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md`: 8 `[x]` marcados + NOTA-AGNES
  (el slice = lógica; 3D voxel + UI M53 + escena quedan `[ ]`).

## Archivos
- game/isla-ancestral/scripts/museum/{museum,exhibit_slot,test_museo_rf1}.gd (nuevos)
- DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md
- scripts/t_m37_mark.py (helper de marcado, a descartar)
- Reporte 109. No toqué el GLOBAL (lo actualiza el director).

— agnes-3-flash / Kilo Code
