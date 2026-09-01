**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 53: UI/UX

## 1. Ubicación de archivos

> ⚠️ **Nota de paths (2026-08-30):** Los scripts reales están en `res://scripts/ui/`, no en `res://ui/` como se documentó originalmente.

```
res://scripts/ui/
├── ui_root.gd                  # UIRoot (class_name): punto de montaje de capas modales M53
├── core/
│   ├── ui_manager.gd           # Autoload UIManager (pila de capas, foco, pausa)
│   ├── ui_layer.gd             # Clase base UILayer
│   ├── ui_layer_type.gd        # enum Type { HUD, MODAL_SIMPLE, MODAL_FULL, POPUP }
│   └── menu_navigator.gd       # Navegación por foco con wrap-around
├── hud/
│   ├── hud_screen.gd           # HUDScreen (CanvasLayer, widgets agregados)
│   ├── status_bar.gd           # Vitales/energía del jugador (M11)
│   ├── clock_widget.gd         # Reloj y estación (M29/M30)
│   ├── season_widget.gd
│   ├── resource_counter.gd     # Contadores de recursos (M38)
│   ├── hotbar_widget.gd        # Hotbar sincronizada (M11)
│   ├── interact_prompt.gd      # Prompt contextual de interacción (M70)
│   └── action_prompt_overlay.gd # Prompts dinámicos por dispositivo (M57)
├── layers/
│   ├── dialog_layer.gd         # Presentación de diálogos (M21)
│   ├── inventory_layer.gd      # Inventario: grid, drag&drop, hotbar (M11)
│   ├── pause_layer.gd          # Pausa con deep-linking (M89)
│   ├── menus_layer.gd          # Menú principal/continuar/cargar (M89)
│   └── confirm_popup.gd        # Popup genérico confirmar/cancelar
├── services/
│   ├── tooltip_service.gd      # Autoload TooltipService
│   └── notification_service.gd # Autoload NotificationService (toasts)
└── theme/
    ├── theme_service.gd        # Autoload ThemeService (tema cozy global, escala, fuentes)
    └── theme_ux.gd             # Construye Theme en runtime desde recursos
│   ├── theme_ux.tres               # Colores, StyleBoxFlat, constantes base
│   ├── style_factory.gd            # Helpers de StyleBoxFlat (radius, hover, focus)
│   └── aanim_config.gd             # Curvas y duraciones de transiciones (reduce_motion)
├── i18n/                           # Strings y traducciones (M87)
│   └── ui_es.po · ui_en.po ...
└── glyphs/                         # Iconos vectoriales (SVG) del HUD y botones (M46)
    ├── icon_coin.svg · icon_seed.svg ...
```

## 2. Autoloads registrados (project.godot)

```
[autoload]
UIManager="*res://scripts/ui/core/ui_manager.gd"
ThemeService="*res://scripts/ui/theme/theme_service.gd"
TooltipService="*res://scripts/ui/services/tooltip_service.gd"
NotificationService="*res://scripts/ui/services/notification_service.gd"
```
Orden de carga: después de Bootstrap, EventBus y ActionLayer (M57). ThemeService construye el tema cozy global en `_ready()` y lo aplica al root del SceneTree. UIManager gestiona la pila de capas.

## 3. Firmas clave

```gdscript
## ui_manager.gd
# Pila de capas con política de pausa y foco
static var INSTANCE: UIManager                 # referencia de autoload
var _stack: Array[UILayer]                     # capas abiertas
var _focus_backup: Dictionary                  # layer -> Control con foco previo

func _ready() -> void:
    EventBus.subscribe(EventBus.Domain.UI, "layers_requested", _on_layers_event)

func push_layer(layer: UILayer) -> void: ...
func pop_layer(layer: UILayer) -> void: ...
func close_top() -> void: ...
func top() -> UILayer: ...
func is_modal_open() -> bool: ...
func open_confirm(title: StringName, message: String, on_ok: Callable, on_cancel: Callable) -> void: ...
func set_hud_visible(visible: bool) -> void: ...
func request_focus_restore(preferred: Control) -> void:
    # guarda el foco de preferred antes de que una capa lo quite
func _on_action(action: StringName, pressed: bool) -> void:
    # suscrito a ActionLayer (M57): inventory_toggle, pause, close, confirm, cancel, tab_next/prev
func assert_stack_integrity() -> void:
    # debug: ninguna capa invisible puede bloquear input (DOM-UI)

## ui_layer.gd
class_name UILayer
extends Control

var layer_type: UILayerType.Type = UILayerType.Type.MODAL_FULL

func _enter_tree() -> void:
    UIManager.register_layer(self)
func _exit_tree() -> void:
    UIManager.unregister_layer(self)

func open(initial_focus: Control = null) -> void:
    visible = true
    set_process_mode_from_type()
    on_layer_opened()
    MenuNavigator.focus_first(initial_focus)
func close() -> void:
    on_layer_closed()
    visible = false
func on_layer_opened() -> void:  # override: suscripciones a EventBus
func on_layer_closed() -> void:  # override: desuscripciones

## hud_screen.gd
class_name HUDScreen
extends CanvasLayer

func set_hud_visible(visible: bool) -> void:
    if not visible: _timers.stop_all()
func force_refresh() -> void:
    clock_widget.refresh(); season_widget.refresh(); resource_counter.refresh()
func bind_status(source: Callable) -> void:
    status_bar.pull = source          # lectura por Callable, sin tocar gameplay

## minimap_widget.gd
class_name MinimapWidget
extends Control

var _texture: ImageTexture            # caché generada por M54 (no se re-renderiza por frame)
func set_map_source(source: MinimapProvider) -> void:
    _source = source; _rebake()
func _rebake() -> void: ...
func update_player(position_2d: Vector2, heading: float) -> void:
    # mueve el ícono sobre la textura; sin regeneración de textura

## tooltip_service.gd
class_name TooltipService
extends CanvasLayer

func show(text: String, at: Control, anchor: Rect2i = Rect2i()) -> void:
    _cancel_delayed()
    _delayed_show(text, at, anchor)     # retardo default 350 ms (M58 ajustable)
func hide_tooltip() -> void: ...
func _clamp_to_viewport(node: Control) -> void:
    # nunca sale de pantalla (margen 8 px)

## notification_service.gd
class_name NotificationService
extends CanvasLayer

func push(toast: ToastData) -> void:
    if _active.size() >= _max_active (3): _dequeue_oldest()
    _active.append(toast); _spawn_node(toast)
func _spawn_node(toast: ToastData) -> void:
    # icono + texto + SFX bus UI (M91); Tween fade 0.3 s; vida 4 s
func clear_all() -> void: ...

## theme_ux.gd
class_name ThemeUx

const BASE_SIZE := Vector2i(1920, 1080)
var base: Theme                       # construido desde theme_ux.tres + fuentes M88
func build() -> Theme:                # aplica font size scale (M58 ui_scale/text_scale)
func apply(scale_ratio: float) -> void
func reload_after_font_change() -> void   # M87/M88 recarga de locales
func ensure_contrast(min_ratio: float) -> void   # M58: alto contraste AA
func reduce_motion_active() -> bool   # desactiva tweens/parpadeos

## styles factory
func panel_rounded(radius: int, color: Color, border: int = 0) -> StyleBoxFlat
func button_cozy(normal: Color, hover: Color, pressed: Color, focus: Color) -> StyleBoxFlat
func focus_box() -> StyleBoxFlat        # anillo dorado con radius; visible con teclado/gamepad

## menu_navigator.gd
class_name MenuNavigator

static func focus_first(layer: UILayer, preferred: Control = null) -> Control
static func focus_last(layer: UILayer) -> Control
static func wrap_focus(layer: UILayer, direction: Vector2i) -> void
    # wrapping circular sobre la grid (focus_neighbor x4 configurados en editor)
static func move_tab(next: bool) -> void   # tab_next/tab_prev de M57
static func show_tooltip_for_focused() -> void
```

## 4. Eventos consumidos (EventBus, dominio `ui`)

| Evento | Emisor | Acción en UI |
|---|---|---|
| `ui.hud_request` | UIManager/otros | refresh puntual de widgets |
| `ui.dialog_requested` | M21 | abrir DialogLayer |
| `ui.dialog_finished` | M21 | cerrar DialogLayer |
| `ui.layer_requested(layer_id)` | M54/M55/M56/M89 | push de capa específica |
| `ui.confirm_requested` | servicios de dominio | open_confirm |
| `ui.notify(ToastData)` | servicios (M11/M21/M38) | cola de toasts |
| `graphics.resolution_changed` | M90 | ThemeUx.apply + guardas de layout |
| `accessibility.settings_changed` | M58 | re-aplicar escala/contraste/movimiento |
| `input.device_changed` | M57 | refresh de ActionPromptOverlay |

## 5. Logs relevantes (convención `DOM-UI`)

- `[DOM-UI] capa abierta: {id} (tipo={tipo}, pila={n})` — push/close de capas.
- `[DOM-UI] foco restaurado a: {node} en {layer}` — política de foco tras pop.
- `[DOM-UI] integridad de pila OK` / `[DOM-UI] INCONSISTENCIA: capa invisible en pila {id}` — assert de debug.
- `[DOM-UI] tooltip fuera de viewport, reposicionado a {pos}` — clamp defensivo.
- `[DOM-UI] tema reaplicado (escala={s}, contraste={c}, motion={m})` — tras M58/M90.
- `[DOM-UI] toast descartado por cola llena ({n})` — política de cola.
- Mensajes de debug en `Logs/aplicacion.log` (fuera de `Assets/`/`res://`, ver AGENTS 18).

## 6. Dependencias de código (imports permitidos)

- `res://ui/**` importa: `res://core/**` (EventBus, tr_local, Logger/ErrorHandler), `res://data/**` (ToastData, recursos), `res://gameplay_domain/services/**` SOLO si el dominio ya expuso interfaz vía Callable/Resource (sin nodos), M57 `action_layer.gd` (estado de acciones), M88 recursos de fuentes (`theme_fonts.tres`).
- **Prohibido**: importar nodos de gameplay (jugador, NPCs, mundo) o clases de IA desde `res://ui/**`. Verificación estática en CI (M07/M01).