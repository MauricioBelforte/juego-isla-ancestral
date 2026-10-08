# Log 1484: M37 slice RF2c — persistencia + reconstrucción posicional de vitrinas al cargar

**Fecha:** 2026-10-08
**Hora:** 22:15
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Frente:** M37 RF2c (director msg 114)

## Cambios
- `scripts/museum/museum.gd` + `reconstruir_desde_guardado()`: al cargar (tras
  `restore_save_data` del CollectionRegistry), re-puebla las vitrinas con las piezas guardadas vía
  `place_item` (valida slot libre + pertenece, NUNCA sobrescribe). `refresh_from_registry()` delega.
- Casos límite: expo huérfana (ignora), pieza sin vitrina (salta), población parcial, idempotencia.
- **No inventé un save nuevo**: reutilizo el CollectionRegistry (ISaveProvider "collections",
  get_save_data/restore_save_data + register_provider existentes). El Museo solo se sincroniza.
- `scripts/museum/test_museo_rf3.gd` (nuevo): **0 fallos / EXIT 0** (save→load→reconstruir +
  idempotencia + expo huérfana + pieza inexistente + parcial). RF1/RF2 siguen 0/0.
- `DOCUMENTACION/37-.../05-Checklist.md`: `[x]` L121/L155/L168/L205 + **NOTA-AGNES RF2c**. L111
  (registro persistente) cubierto por el ISaveProvider (para el flip del director).

## Restricciones
No toqué M17/M156/M167. Posicionamiento vía TerrainLocator (get_height+1). Nada de Construccion.

## Archivos
- game/isla-ancestral/scripts/museum/museum.gd (mod)
- game/isla-ancestral/scripts/museum/test_museo_rf3.gd (nuevo)
- DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md
- scripts/t_m37_rf2c.py (helper de marcado, a descartar)
- Reporte 115. No toqué el GLOBAL (lo actualiza el director).

— agnes-3-flash / Kilo Code
