**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 53: UI/UX

## 1. Arquitectura general

```
┌─────────────────────── AUTOLOADS (orden de registro) ───────────────────────┐
│ Bootstrap(M07) > EventBus(M07) > ActionLayer(M57) > UIManager(M53)           │
└───────────────────────────────────┬──────────────────────────────────────────┘
                                    │ consume
┌──────────────── GODOT TREE ───────▼─────────────────────────────────────────┐
│ CanvasLayer "UI_ROOT" (layer 100)                                          │
│ ├─ HUDScreen               (siempre visible, layer menor, read-only HUD)   │
│ │   ├─ StatusBar · ClockWidget(M30) · SeasonWidget · ResourceCounter        │
│ │   ├─ HotbarWidget(M11) · InteractPrompt(M70) · MinimapWidget(M53/M54)     │
│ │   └─ NotificationService (cola de toasts)                                 │
│ ├─ DialogLayer  (M21: ventana, retrato, opciones, subtítulos M58)           │
│ ├─ InventoryLayer (grid + hotbar sync + drag & drop)                        │
│ ├─ PauseLayer   (menú pausa + acceso a Ajustes/M89)                         │
│ ├─ MenusLayer   (M89: menú principal, continuar, cargar, ajustes, créditos) │
│ └─ GenericLayers... (confirm popup, amount picker, tutorial tips)           │
└─────────────────────────────────────────────────────────────────────────────┘
```
Capas: **HUD** (no modal, sigue al mundo) · **Modal Sencillo** (diálogo: pausa parcial) · **Modal Completo** (inventario/pausa: pausa total, bloquea input del mundo) · **Popup** (confirmar, notificación, tooltip: no competidor de foco).

## 2. Componentes principales

### 2.1 UIManager (autoload, `res://ui/core/ui_manager.gd`)
Orquesta la pila de capas, el foco, la pausa y la distribución de acciones transversales de M57.

- Pila de capas: `push_layer(layer)`, `pop_layer(layer)`, `top()`, `close_top()`.
- Reglas: solo una capa Modal Completo a la vez; las demás se encolan; al cerrar se restaura el foco al elemento guardado o al primero de la capa visible.
- Suscribe acciones de M57: `inventory_toggle`, `pause`, `close`, `confirm`, `cancel`, `tab_next/tab_prev`, `menu_open`.
- `process_mode` por capa: modal completo congela el mundo (pausa M29); HUD usa `PROCESS_MODE_ALWAYS` con refresh bajo demanda.
- Emite eventos `ui_layers_changed`, `ui_focus_moved`.

### 2.2 UILayer (base `res://ui/core/ui_layer.gd`)
Clase base de toda pantalla modal. Contrato:

- `open(initial_focus: Control)`, `close()` → devuelven `void`; transiciones por `Tween` (fade 120 ms).
- `on_layer_opened()` / `on_layer_closed()` virtuales (suscribirse/desuscribirse de eventos).
- Registra en UIManager al entrar al árbol; exige `process_mode` coherente con su tipo.
- Herencia: `DialogLayer`, `InventoryLayer`, `PauseLayer`, `MenusLayer`, `SettingsLayer` (M89 lo especializa), etc.

### 2.3 HUDScreen (`res://ui/hud/hud_screen.gd`)
- Widgets suscritos a EventBus (dominio `ui` y dominios de datos) — jamás actúa sobre gameplay.
- Refresh por señal y `Timer` de baja frecuencia (2 Hz) para reloj/estación; sin refresh por frame.
- Ocultable con una sola acción (para M56 Fotografía / captura de pantalla): `set_hud_visible(false)`.

### 2.4 ThemeUx (`res://ui/theme/theme_ux.gd` + `theme_ux.tres`)
- `Theme` de Godot construido en runtime desde `theme_ux.tres` + fuentes de M88 (Nunito cuerpo / Fredoka One titulares; jerarquía H1 32, H2 24, H3 20, BODY 16, SMALL 12, MICRO 10).
- StyleBoxFlat redondeado (radius 12-16), paleta pastel (fondo arena, acento ocre, texto marrón oscuro, highlight dorado suave); hover/disabled/pressed con variantes de color suaves.
- API: `apply(scale_ratio)`, `reload_after_font_change()`, `ensure_contrast()` (contraste AA según M58), `reduce_motion_active`.
- Notas de accesibilidad: estados distinguibles por forma + color (borde/relleno), no solo color.

### 2.5 MenuNavigator (`res://ui/core/menu_navigator.gd`)
- Wrapping circular de foco (`focus_neighbor` explícitos configurados en editor + `_gui_input` de atajos).
- `focus_first()`, `focus_last()`, `move_focus(direction)` (direccional 4D con gamepad), `wrap_manager` con ciclo continuo entre extremos de grid.
- Tooltip por foco: al enfocar un elemento, muestra su tooltip (accesible por teclado, RF6).

### 2.6 Widgets de datos
- `ClockWidget`: hora del GameClock M29/M30 (formato cozy "Otoño 3, 14:30").
- `MinimapWidget`: textura generada de navegación (M54 provee mapa/POIs), jugador centrado, rotación fija (decisión: fija, menos cinetosis, M58), ocultable.
- `TooltipService`: pool único, retardo 0.35 s, clamp de posición a viewport, cierre al mover foco/ratón.
- `NotificationService`: cola de toasts (máx 3 visibles), tipo (obtención/evento/misión) con icono + SFX del bus UI (M91); clicable para abrir detalle (M55).
- `ActionPromptOverlay`: lee el Action Layer de M57 y muestra el prompt correcto por dispositivo ("E para interactuar", "A" en gamepad, icono Xbox/PS según M57).

## 3. Flujos principales (texto)

### 3.1 Abrir inventario
1. Jugador pulsa acción `inventory_toggle` (M57). El jugador la tiene asignada (tecla I / gamepad back).
2. ActionLayer notifica pulsaciones de acciones a UIManager (suscrito).
3. UIManager: no hay modal completo → `push_layer(InventoryLayer)`; pausa GameClock (M29) si corresponde; bloquea input del mundo; guarda foco previo.
4. InventoryLayer: `on_layer_opened()` se suscribe a `inventory.changed` (M11); `MenuNavigator.focus_first()` → foco en primera celda.
5. HUD permanece visible con `process_mode` pausado (no repinta).
6. Al pulsar `inventory_toggle`/`close`: pop, restaurar foco, reanudar GameClock, HUD reanuda refresh.

### 3.2 Diálogo con NPC
1. M21 emite `dialog_requested(npc_id, page)` por EventBus (dominio `ui`). La gameplay NO abre la ventana: emite el evento.
2. UIManager detecta capa `DialogLayer` no abierta → la abre (modal sencillo: pausa reloj, el mundo sigue visibles congelado suavemente).
3. El jugador avanza con `confirm` (M57) o click en el botón de pág; opciones con foco; velocidad de texto según M58; subtítulos si M58 activado; pausa de texto habilitada (M58).
4. Al final M21 emite `dialog_finished`; DialogLayer se cierra sola; foco restaurado al jugador.

### 3.3 Pausa
1. `pause` → UIManager abre PauseLayer (modal completo).
2. Opciones: Continuar, Inventario, Diario (M55), Mapa (M54), Ajustes (M89: General/Controles M57/Audio M91/Gráfica M90/Accesibilidad M58), Guardar, Cargar, Salir al menú. Deep-linking entre capas: al cerrar una capa hija, el foco vuelve a PauseLayer.
3. `close`/pausa de nuevo → continuar.

### 3.4 Tooltip por contexto
1. Ratón sobre objeto interactuable → M70 pide prompt (HUD); tras 0.35 s el TooltipService muestra texto breve ("Rocas con musgo. ¿Excavar?").
2. Foco se mueve en UI → tooltip del elemento enfocado (ícono décima favorita del item, precio, uso).
3. Tooltip se cierra: al mover el ratón fuera, cambiar foco, o pulsar cualquier acción transversal.

### 3.5 Notificación-toast
1. EventBus `inventory.item_added`, `quest.updated`, `economy.purchase_done` → NotificationService encola toast.
2. Aparece arriba-derecha bajo el minimapa (lugar fijo, no molesta al centro), fade 0.3 s, vida 4 s, máx 3 simultáneos; se desplazan hacia arriba.
3. Feedback de sonido del bus UI (M91) asociado al tipo de toast.

### 3.6 Cambio de resolución (M90)
1. M90 aplica resolución → emite `graphics.resolution_changed`.
2. ThemeUx.`reload_after_font_change()` y `apply(scale_ratio)`; UIManager revisa que las capas abiertas respeten anchors (guardas de debug) y recoloca tooltips/popups visibles.
3. MinimapWidget regenera su textura si el ratio cambió. Sin cortes en 16:9/16:10 (QA automatizado con lista de resoluciones).

### 3.7 Foco perdido (edge case)
1. Cerrar capa A sobre la que se abrió B encima: al hacer pop de B, UIManager restaura el foco guardado de A (guardado al push de B).
2. Si al restaurar el control ya no existe (vendido/eliminado), `focus_first()` de la capa visible actual; assert de debug loguea el caso (DOM-UI).
3. Al perder la ventana (alt-tab), Godot gestiona foco; al volver, `focus_first()` de la capa visible; sin estados colgados.

## 4. Contratos API (GDScript, firmas)

```gdscript
## UIManager (autoload)
class_name UIManager
signal ui_layers_changed
signal ui_focus_moved(node: Control)

func push_layer(layer: UILayer) -> void
func pop_layer(layer: UILayer) -> void
func close_top() -> void
func top() -> UILayer
func is_modal_open() -> bool
func open_confirm(title: StringName, message: String, on_ok: Callable, on_cancel: Callable = Callable()) -> void
func set_hud_visible(visible: bool) -> void
func request_focus_restore(preferred: Control) -> void

## UILayer (base)
class_name UILayer
extends Control

var layer_type: Type = Type.MODAL

func open(initial_focus: Control = null) -> void
func close() -> void
func on_layer_opened() -> void
func on_layer_closed() -> void
func focus_first() -> Control

## HUDScreen
class_name HUDScreen
extends CanvasLayer

func set_hud_visible(visible: bool) -> void
func force_refresh() -> void
func bind_status(source: Callable) -> void

## MinimapWidget
class_name MinimapWidget
extends Control

func set_map_source(source: MinimapProvider) -> void   # M54
func set_visible_hint(show_pois: bool) -> void
func update_player(position_2d: Vector2, heading: float) -> void

## TooltipService
class_name TooltipService
extends CanvasLayer

func show(text: String, at: Control, anchor: Rect2i = Rect2i()) -> void
func hide_tooltip() -> void
func set_delay(ms: int) -> void       # M58

## NotificationService
class_name NotificationService
extends CanvasLayer

func push(toast: ToastData) -> void
func set_queue_limit(n: int) -> void
func clear_all() -> void

## ActionPromptOverlay
class_name ActionPromptOverlay
extends Control

func set_action(action_name: StringName) -> void       # se resuelve por M57
func refresh_for_device(device: String) -> void        # "keyboard" | "xbox" | "playstation" | "generic"

## DialogsLayerFacade (M21 firma de contrato)
extends UILayer
func set_story(story: DialogStory) -> void
func set_speed(ratio: float) -> void                   # M58
func pause_text() -> void
```

## 5. Integración con otros módulos

| Módulo | Integración |
|---|---|
| M57 Interfaz de Control | Única fuente de acciones; Action Layer notifica a UIManager; prompts dinámicos por dispositivo; remapeo → la UI re-lee etiquetas; navegación direccional gamepad via foco nativo |
| M58 Accesibilidad | Parámetros runtime: `ui_scale` (0.8-1.5 aplicado por ThemeUx), `text_scale`, `high_contrast`, `daltonism_mode` (formas + texturas junto al color), `reduce_motion` (desactiva Tweens/parpadeos), `subtitle_size`, `visual_sound_indicators`, `flash_free`. Todos aplicados en vivo sin reiniciar |
| M88 Fuentes Tipográficas | ThemeUx usa Nunito (cuerpo) y Fredoka One (títulos) con la jerarquía H1..MICRO y line-heights definidos; subsetting para locales; recarga al cambiar idioma M87 |
| M89 Diseño de Menús | Consume UILayer + MenuNavigator; define la lista de pantallas y su orden (menú principal, continuar, carga, ajustes, créditos); pausa con deep-linking |
| M90 Configuración Gráfica | En eventos de cambio de resolución/escalado, ThemeUx se re-aplica; guardas de layout en QA multi-resolución |
| M91 Configuración de Audio | Bus UI dedicado para todos los SFX de interfaz; sliders del menú operan sobre buses reales (M91) |
| M21 Diálogos | `dialog_requested`/`dialog_finished` por EventBus; DialogLayer es la presentación de M21, sin lógica de historia |
| M54/M55/M56 | Consumen HUDScreen/Modal framework: minimapa (M54), diario (M55), modo fotografía oculta HUD (M56) |
| M30 Reloj / M29 Calendario | ClockWidget/SeasonWidget con la capa de presentación cozy; pausa respetada |
| M11 Jugador | HotbarWidget y ResourceCounter leen estado por señales de dominio, jamás por polling directo de nodos |
| M61 Rendimiento | Presupuesto UI ≤ 8% frame; minimapa con textura caché; labels con caché de texto; capas pausadas sin repintar |

## 6. Reglas anti-acoplamiento (verificables)

1. Ningún script de `scripts/gameplay/`, `scripts/world/` o `scripts/ai/` importa `res://ui/` (verificación estática en M01/M07).
2. La gameplay emite eventos `ui.*` en EventBus; la UI nunca es llamada con retorno obligatorio.
3. UIManager autoload es el único punto de contacto hacia capas; las capas no se referencian entre sí (se comunican por eventos).
4. Los widgets del HUD no mutan estado de gameplay; solo leen.
5. Toda cadena visible pasa por tr_local (M87), nunca hardcodeada.