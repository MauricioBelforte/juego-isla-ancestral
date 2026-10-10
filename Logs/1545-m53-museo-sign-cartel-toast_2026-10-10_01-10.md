# Log 1545: M53 — MuseoSign (cartel entrada + toast exposición completada)

**Fecha:** 2026-10-10
**Hora:** 01:10
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Creación de `museo_sign.gd`: cartel de entrada del museo (CanvasLayer MODAL) + toast de exposición completada. Consume `CollectionRegistry.get_resumen_para_ui()` y la señal `exhibition_completed` sin modificar el backend M37.

## Artefacto
| Archivo | Líneas | Tipo |
|---|---|---|
| `scripts/ui/museo_sign.gd` | ~110 | CanvasLayer (capa MODAL DOM-UI) |

## Funcionalidad
- `refrescar()`: carga `get_resumen_para_ui()` → muestra progreso global + lista de exposiciones (✓/○)
- `mostrar_toast(texto)`: toast temporal 3s
- `_on_exposicion_completada(exid)`: conecta señal → toast "¡Exposición completada!"
- `abrir()` / `cerrar()` / `esta_visible()` para tests

## --check-only
- museo_sign.gd: 0 errores ✓

## Reglas cumplidas
- UI en `scripts/ui/` ✓
- Backend `scripts/museum/` intacto ✓
- Sin commits ✓
- No toco K.167/K.170, main_island.gd ✓
