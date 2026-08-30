# Log 189: M53 UI/UX — Infraestructura core

**Fecha:** 2026-08-28
**Modelo:** MiMo V2.5 (OpenCode)
**Plataforma:** OpenCode

## Resumen
Se implementó la infraestructura core del sistema UI/UX (M53): UIManager autoload con pila de capas, foco y pausa; UILayer clase base; MenuNavigator con wrap-around focus; HUDScreen CanvasLayer con refresh a 2 Hz; TooltipService con pool y delay configurable; NotificationService con toasts de 3 tipos; ThemeUx con paleta pastel cozy. Se registraron 3 autoloads nuevos en project.godot.

## Cambios Realizados

### Archivos creados (7 scripts)
1. `scripts/ui/core/ui_layer_type.gd` — Enum de tipos de capa (HUD, MODAL_SIMPLE, MODAL_FULL, POPUP)
2. `scripts/ui/core/ui_manager.gd` — Autoload UIManager: pila de capas, backup de foco, process_mode por tipo, integración EventBus
3. `scripts/ui/core/ui_layer.gd` — Clase base UILayer: open/close, focus_first, proceso automático
4. `scripts/ui/core/menu_navigator.gd` — Navegación por foco: focus_first/last, wrap-around, tab navigation, tooltip por foco
5. `scripts/ui/hud/hud_screen.gd` — CanvasLayer HUD: widgets placeholders, refresh Timer 2 Hz, conexiones EventBus (inventario, calendario, economía)
6. `scripts/ui/services/tooltip_service.gd` — Autoload: pool de PanelContainers, delay 0.35s, clamp a viewport
7. `scripts/ui/services/notification_service.gd` — Autoload: cola de toasts (máx 3), fade 0.3s, vida 4s, 3 tipos (ITEM, EVENT, QUEST)
8. `scripts/ui/theme/theme_ux.gd` — ThemeUx: paleta pastel, StyleBoxFlat redondeado, 6 tamaños tipográficos, focus ring dorado

### Archivos modificados
1. `project.godot` — 3 autoloads registrados: UIManager, TooltipService, NotificationService
2. `scripts/core/event_bus.gd` — 5 señales nuevas en UIEvents: dialog_finished, layer_requested, confirm_requested, notify, ui_layers_changed, ui_focus_moved
3. `DOCUMENTACION/07-GUIA-GODOT.md` — 2 pitfalls nuevos: §9.38 (Variant inference con :=), §9.39 (no redefinir show() en CanvasLayer)
4. `DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md` — 16/145 ítems marcados como completados
5. `CHECKLIST-GLOBAL.md` — M53 actualizado: 0/145 → 16/145, estado 🟢 → 🔵
6. `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` — M53 agregado a tabla de reservas

### Errores corregidos durante implementación
1. **UILayer type not found** — UIManager (autoload) referenciaba UILayer antes de que estuviera registrado. Solución: usar duck-typing con constantes LAYER_* en vez de `layer is UILayer`
2. **Variant inference** — `bus.get("ui")` retorna Variant, `:=` no puede inferir tipo. Solución: `var ui_events: Variant = bus.get("ui")`
3. **CanvasLayer show() override** — TooltipService definía `show(text, at)` que conflictaba con `CanvasLayer.show()`. Solución: renombrar a `show_tooltip()`
4. **pop_front() Variant** — `_active.pop_front()` retorna Variant. Solución: `var oldest: Dictionary = _active.pop_front()`

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/ui/core/ui_layer_type.gd` (CREADO)
- `game/isla-ancestral/scripts/ui/core/ui_manager.gd` (CREADO)
- `game/isla-ancestral/scripts/ui/core/ui_layer.gd` (CREADO)
- `game/isla-ancestral/scripts/ui/core/menu_navigator.gd` (CREADO)
- `game/isla-ancestral/scripts/ui/hud/hud_screen.gd` (CREADO)
- `game/isla-ancestral/scripts/ui/services/tooltip_service.gd` (CREADO)
- `game/isla-ancestral/scripts/ui/services/notification_service.gd` (CREADO)
- `game/isla-ancestral/scripts/ui/theme/theme_ux.gd` (CREADO)
- `game/isla-ancestral/project.godot` (MODIFICADO)
- `game/isla-ancestral/scripts/core/event_bus.gd` (MODIFICADO)
- `DOCUMENTACION/07-GUIA-GODOT.md` (MODIFICADO)
- `DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md` (MODIFICADO)
- `CHECKLIST-GLOBAL.md` (MODIFICADO)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (MODIFICADO)
