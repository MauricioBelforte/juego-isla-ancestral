# Log 555: Auditoría de aliasing ISaveProviders (BUG-013 cerrado)

**Fecha:** 2026-09-02
**Hora:** 22:20
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Auditoría transversal del patrón de aliasing detectado en M19 (Log 553, BUG-013): herramienta ejecutable + análisis estático de 40+ ISaveProviders. Resultado: el único caso real era M19 (ya corregido); los 34 patrones estáticos restantes son falsos positivos (int/float/String se copian por valor). 11-BUGS.md actualizado con BUG-013 [x] Resuelto.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/saving/auditar_aliasing.gd` *(nuevo)* | Auditoría DINÁMICA reutilizable: para cada autoload con get_save_data/restore_save_data → snapshot → restore vacío → ¿el snapshot quedó vacío? (aliasing). Reporta OK/ALIASING por archivo |
| `Logs/reservas/auditar_estatico.py` *(temporal, borrada)* | Auditoría ESTÁTICA: regex sobre todos los get_save_data() buscando serialización directa de vars sin .duplicate() — 34 patrones |
| `DOCUMENTACION/11-BUGS.md` | BUG-013 registrado como [x] Resuelto con causa/solución/auditoría transversal |

## Resultados de la auditoría

### Dinámica (runtime, providers con estado en boot)
- **OK (8):** time_calendar, economy_manager, coleccionables_manager, hotbar_state, inventario_iter5, crafting_service, audio_config_service, event_manager
- **ALIASING (0):** ninguno

### Estática (34 patrones → verificación de tipos)
- Todos los patrones son `int`/`float`/`String` (weather _dia_actual:int, friendship _mes:int, story _final_elegido:String, game_clock _hora:int, travel _transcurrido:float, etc.)
- En Godot los tipos primitivos se copian **por valor** → sin aliasing
- **Alias real solo con Dictionary/Array** → el único caso era M19 (corregido Log 553)

## Tests
- `auditar_aliasing.gd`: ejecutado, reporta 8 OK / 0 ALIASING, exit 0
- Los tests de M19 (test_memoria_agenda) siguen 0 fallos tras el fix del Log 553

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/saving/auditar_aliasing.gd` *(nuevo — herramienta permanente)*
- `DOCUMENTACION/11-BUGS.md` *(BUG-013 [x] Resuelto)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 555)*
- `Logs/reservas/555-glm-5.3-flash-M59-Auditoria-Aliasing.txt` *(creado y borrado)*

## Notas técnicas
- La herramienta `auditar_aliasing.gd` es reutilizable en CI (M118) o tras cualquier nuevo ISaveProvider: detecta el problema SIN conocer el código.
- Regla para providers futuros: **deep-copy SIEMPRE en get_save_data() si serializas Dictionary/Array** (candidato a 07-GUIA §8).
- Los providers con estado vacío en boot no son auditables dinámicamente sin simular actividad — el análisis estático complementa (con verificación manual de tipos para descartar falsos positivos).
