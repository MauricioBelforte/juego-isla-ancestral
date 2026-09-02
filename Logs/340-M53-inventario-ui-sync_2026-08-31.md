# Log 340: M53 UI/UX — InventoryLayer drag-drop, HotbarWidget sync, TooltipService M88

**Fecha:** 2026-08-31
**Hora:** 14:30
**Modelo:** MiMo V2.5 (OpenCode)
**Plataforma:** OpenCode

## Resumen

Iteración 5 del M53 UI/UX. Se implementaron 3 funcionalidades de UI que desbloquean ítems del M14 Inventario: drag & drop por swap de dos clicks en InventoryLayer, sincronización bidireccional del HotbarWidget con nombres reales de ítems, y estilo M88 cozy en TooltipService (título + cuerpo). Freeze world al abrir inventario.

## Cambios Realizados

### InventoryLayer (`inventory_layer.gd`)
- **Drag & drop por dos clicks:** primer click selecciona origen (resaltado visual), segundo click intercambia con destino. Toggle favorito si se hace click en el mismo slot.
- **Swap de slots:** `_swap_slots(a, b)` usa `InventarioService.swap_slots()` si existe, fallback manual con copia temporal de item_id/cantidad/favorito.
- **Freeze world:** `_freeze_world(frozen)` pausa GameTime y notifica a UIManager al abrir/cerrar inventario.
- **Cancel drag:** al cerrar capa o soltar en slot libre, se cancela el estado de selección.

### HotbarWidget (`hotbar_widget.gd`)
- **Refresh bidireccional:** ahora lee slots del inventario directamente (contenedor bolsillo) con fallback a `get_hotbar_item()`.
- **Nombres reales:** `_friendly_item_id()` convierte "madera_roble" → "Madera roble".
- **Notificación de selección:** `select_slot()` llama a `InventarioService.select_hotbar_slot()` si existe.
- **Tooltips por slot:** cada panel de la hotbar muestra tooltip con nombre y cantidad.

### TooltipService (`tooltip_service.gd`)
- **Estilo M88 cozy:** pool de tooltips con VBoxContainer (título + cuerpo).
- **Título:** font_size 14, color ocre (0.85, 0.72, 0.35).
- **Cuerpo:** font_size 12, color claro (0.92, 0.88, 0.82), autowrap.
- **Formato:** texto con "|" separa título y cuerpo (ej: "Madera roble|Se usa para construir").
- **Panel:** fondo cálido oscuro, bordes redondeados 10px, margen 10px.

### Checklist M53
- E.84 Drag & drop con ratón entre celdas y hotbar [x]
- E.87 Hotbar sincronizada con el inventario en ambos sentidos [x]
- E.91 Verificar que abrir inventario congele el mundo [x]
- G.112 Texto breve y amable con jerarquía M88 (título y cuerpo) [x]
- G.113 Verificar que el tooltip nunca bloquea el input del mundo [x]

### Checklist M14
- F.98 Asignación por arrastre desde el inventario y por atajo de tecla [x]
- L.182 Bordes de rareza consistentes en iconos y tooltip [x]

### CHECKLIST-GLOBAL.md
- M14: 81/140 → 83/140
- M53: 61/158 → 66/158

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd` — drag-drop, freeze world
- `game/isla-ancestral/scripts/ui/widgets/hotbar_widget.gd` — sync bidireccional, nombres reales
- `game/isla-ancestral/scripts/ui/services/tooltip_service.gd` — estilo M88 cozy
- `DOCUMENTACION/14-Inventario/plan-actual/05-Checklist.md` — +2 ítems [x]
- `DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md` — +5 ítems [x]
- `CHECKLIST-GLOBAL.md` — progreso actualizado
- `Logs/ULTIMO_NUMERO.txt` — 299 → 300
