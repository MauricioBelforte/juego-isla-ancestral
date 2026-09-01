# Log 250: M53 UI/UX — Widgets del HUD implementados

**Fecha:** 2026-08-29
**Hora:** 23:34
**Modelo:** DeepSeek V4 Flash
**Plataforma:** OpenCode

## Resumen
Implementación de los 7 widgets del HUD del módulo M53 (UI/UX). Cada widget es un Control que lee datos de autoloads de forma defensiva (sin acoplar a gameplay). Se integraron en `main_island.tscn` bajo un CanvasLayer en capa 100. Verificación con Godot MCP: 0 errores, compila y ejecuta limpio.

## Widgets Creados

### 1. StatusBar (`status_bar.gd`)
- 3 barras de progreso: vida (rojo), stamina (verde), energía (azul)
- Lee datos por Callable o `set_values()` directo
- Estilo cozy: barras redondeadas (radius 6), colores suaves

### 2. ClockWidget (`clock_widget.gd`)
- Muestra hora del juego en formato "14:30"
- Lee de `TimeCalendar.get_hora()` / `get_minuto()`
- Icono de estación junto a la hora

### 3. SeasonWidget (`season_widget.gd`)
- Muestra estación actual con icono emoji y nombre
- Lee de `TimeCalendar.get_estacion()`
- Mapeo: 0=Primavera🌸, 1=Verano☀, 2=Otoño🍂, 3=Invierno❄

### 4. ResourceCounter (`resource_counter.gd`)
- Muestra monedas del jugador con icono 🪙
- Lee de `EconomyManager.saldo`
- Actualización defensiva (si no existe autoload, muestra 0)

### 5. HotbarWidget (`hotbar_widget.gd`)
- 8 slots horizontales con highlight dorado en el seleccionado
- Lee de `Inventario.get_hotbar_item()`
- Conecta `hotbar_selected` del EventBus para sincronizar selección

### 6. InteractPrompt (`interact_prompt.gd`)
- Panel centrado abajo: "[F] Hablar"
- Fade in/out suave (0.15s)
- `show_prompt(message)` / `hide_prompt()`

### 7. ActionPromptOverlay (`action_prompt_overlay.gd`)
- Prompts dinámicos por dispositivo (keyboard, Xbox, PlayStation)
- `show_prompt(action, position)` / `hide_all()`
- Detección automática de gamepad conectado

## Escena Integrada
- `main_island.tscn`: HUDScreen (CanvasLayer 100) con layout:
  - TopLeft: StatusBar (vitales)
  - TopRight: ClockWidget + SeasonWidget (reloj/estación)
  - TopCenter: ResourceCounter (monedas)
  - BottomCenter: HotbarWidget (slots)
  - CenterBottom: InteractPrompt (indicador F)
  - Fullscreen: ActionPromptOverlay (prompts dispositivos)

## Errores Corregidos Durante Implementación
1. `action_prompt_overlay.gd:89`: `Array[int] > int` inválido → usar `.size()`
2. `status_bar.gd:82`: ProgressBar duplicado en padres → simplificar `_create_bar()`
3. `action_prompt_overlay.gd:15`: variable `_prompts` sin usar → eliminada
4. `action_prompt_overlay.gd:54`: parámetro `position` sombreado → renombrado a `at_position`
5. `season_widget.gd:66`: parámetro `name` sombreado → renombrado a `display_name`

## Archivos Creados/Modificados
### Creados
- `scripts/ui/widgets/status_bar.gd`
- `scripts/ui/widgets/clock_widget.gd`
- `scripts/ui/widgets/season_widget.gd`
- `scripts/ui/widgets/resource_counter.gd`
- `scripts/ui/widgets/hotbar_widget.gd`
- `scripts/ui/widgets/interact_prompt.gd`
- `scripts/ui/widgets/action_prompt_overlay.gd`
- `scenes/ui/hud.tscn` (escena standalone, no usada aún)

### Modificados
- `scenes/main_island.tscn`: agregados ext_resources y nodos HUD
- `DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md`: 8 ítems marcados [x]

## Checklist M53 Actualizado
- **Antes:** 16/145
- **Después:** 24/145 (+8 widgets)
