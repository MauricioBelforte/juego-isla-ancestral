# Log 1481: M37 slice RF2b — construcción voxel 3D de vitrinas + exhibit_slot.tscn

**Fecha:** 2026-10-08
**Hora:** 21:35
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Frente:** M37 RF2b (director msg 112: voxel 3D de vitrinas + exhibit_slot.tscn)

## Cambios
- `scripts/museum/exhibit_slot.gd` + `ExhibitSlot._construir_vitrina_3d()` (RF2b): cada vitrina
  ahora arma su **caso voxel** (BoxMesh + StandardMaterial3D translúcido) + **pieza interior**
  (silueta tenue libre / sólida al ocupar, `_actualizar_apariencia()` en place_item/clear).
  Geometría autocontenida: NO toca M17 (Construccion) ni M156/M167 (terreno).
- `scenes/museo/exhibit_slot.tscn` (nuevo): escena de vitrina genérica y reutilizable.
- `scripts/museum/test_museo_rf2.gd` extendido: verifica la estructura voxel (CasoVitrina BoxMesh +
  PiezaVitrina + place/clear). **0 fallos / EXIT 0.** `test_museo_rf1.gd` sigue 0/0.
- `DOCUMENTACION/37-.../05-Checklist.md`: `[x]` "Construcción voxel de vitrinas [C]" +
  "Escena exhibit_slot.tscn [S]" + **NOTA-AGNES RF2b** (coherencia visual = p/verificar con
  visión/M154 en-editor; registro persistente + reconstrucción posicional = siguiente slice).

## Pendiente (siguiente slice, fuera de este)
- Registro persistente de piezas por exposición + reconstrucción posicional de vitrinas al cargar
  (restore_from_save del CollectionRegistry ya existe; falta reconstruir las vitrinas pobladas + test).
- Coherencia visual exacta del voxel (violation M154 / editor, no verificable headless).

## Archivos
- game/isla-ancestral/scripts/museum/exhibit_slot.gd (mod)
- game/isla-ancestral/scenes/museo/exhibit_slot.tscn (nuevo)
- game/isla-ancestral/scripts/museum/test_museo_rf2.gd (extendido)
- DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md
- Reporte 113. No toqué el GLOBAL (lo actualiza el director).

— agnes-3-flash / Kilo Code
