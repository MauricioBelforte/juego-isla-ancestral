**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

# 03-Diseno.md — Módulo 53: UI/UX

## 1. Arquitectura general

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ AUTOLOADS (orden de registro) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Bootstrap(M07) > EventBus(M07) > ActionLayer(M57) > UIManager(M53)           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                                    â”‚ consume
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ GODOT TREE â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ CanvasLayer "UI_ROOT" (layer 100)                                          â”‚
â”‚ â”œâ”€ HUDScreen               (siempre visible, layer menor, read-only HUD)   â”‚
│ │   ├─ StatusBar · ClockWidget(M30) · SeasonWidget · ResourceCounter        │
│ │   ├─ HotbarWidget(M11) · InteractPrompt(M70) · MinimapWidget(M53/M54)     │
â”‚ â”‚   â””â”€ NotificationService (cola de toasts)                                 â”‚
│ ├─ DialogLayer  (M21: ventana, retrato, opciones, subtítulos M58)           │
â”‚ â”œâ”€ InventoryLayer (grid + hotbar sync + drag & drop)                        â”‚
│ ├─ PauseLayer   (menú pausa + acceso a Ajustes/M89)                         │
│ ├─ MenusLayer   (M89: menú principal, continuar, cargar, ajustes, créditos) │
â”‚ â””â”€ GenericLayers... (confirm popup, amount picker, tutorial tips)           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
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

- `open(initial_focus: Control)`, `close()` â†’ devuelven `void`; transiciones por `Tween` (fade 120 ms).
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
3. UIManager: no hay modal completo â†’ `push_layer(InventoryLayer)`; pausa GameClock (M29) si corresponde; bloquea input del mundo; guarda foco previo.
4. InventoryLayer: `on_layer_opened()` se suscribe a `inventory.changed` (M11); `MenuNavigator.focus_first()` â†’ foco en primera celda.
5. HUD permanece visible con `process_mode` pausado (no repinta).
6. Al pulsar `inventory_toggle`/`close`: pop, restaurar foco, reanudar GameClock, HUD reanuda refresh.

### 3.2 Diálogo con NPC
1. M21 emite `dialog_requested(npc_id, page)` por EventBus (dominio `ui`). La gameplay NO abre la ventana: emite el evento.
2. UIManager detecta capa `DialogLayer` no abierta â†’ la abre (modal sencillo: pausa reloj, el mundo sigue visibles congelado suavemente).
3. El jugador avanza con `confirm` (M57) o click en el botón de pág; opciones con foco; velocidad de texto según M58; subtítulos si M58 activado; pausa de texto habilitada (M58).
4. Al final M21 emite `dialog_finished`; DialogLayer se cierra sola; foco restaurado al jugador.

### 3.3 Pausa
1. `pause` â†’ UIManager abre PauseLayer (modal completo).
2. Opciones: Continuar, Inventario, Diario (M55), Mapa (M54), Ajustes (M89: General/Controles M57/Audio M91/Gráfica M90/Accesibilidad M58), Guardar, Cargar, Salir al menú. Deep-linking entre capas: al cerrar una capa hija, el foco vuelve a PauseLayer.
3. `close`/pausa de nuevo â†’ continuar.

### 3.4 Tooltip por contexto
1. Ratón sobre objeto interactuable → M70 pide prompt (HUD); tras 0.35 s el TooltipService muestra texto breve ("Rocas con musgo. ¿Excavar?").
2. Foco se mueve en UI → tooltip del elemento enfocado (ícono décima favorita del item, precio, uso).
3. Tooltip se cierra: al mover el ratón fuera, cambiar foco, o pulsar cualquier acción transversal.

### 3.5 Notificación-toast
1. EventBus `inventory.item_added`, `quest.updated`, `economy.purchase_done` â†’ NotificationService encola toast.
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

## 7. Sección Audio de Ajustes — SettingsAudioLayer (iter. 2026-10-04, encargo canal 10 "Opción A")

> **Modelo:** mimo-v2.6-flash-free · **Plataforma:** opencode · **Fecha:** 2026-10-04
> El M91 dejó el dominio de audio (AudioConfig) completo, pero **no existía ningún
> widget de audio** en Ajustes. Esta sección es el puente UI→M91.

### 7.1 Composición y posicionamiento

```
UIRoot (montaje)
├─ ...capas existentes (pausa, menús, créditos, ...)
â””â”€ SettingsAudioLayer (MODAL_FULL)   â† montado el ÃšLTIMO: se dibuja encima
     ├─ Título  SETTINGS.AUDIO_TITULO
     â”œâ”€ Fila slider Master/Music/SFX: [HSlider 0-100] [Label %] [CheckButton mute]
     â”œâ”€ Separador + SETTINGS.OPCIONES
     ├─ Rango dinámico (OptionButton: quiet/medio/dinámico)
     ├─ Compresión (CheckButton) · Dispositivo de salida (OptionButton)
     â”œâ”€ LblFallo (feedback, oculto por defecto)
     └─ BtnVolver  ·  TimerCommit (0.25 s, one-shot)
```

### 7.2 Deep-links de `ajustes_pedido` (routing)

Dos emisores, una sola capa; ambos caminos llaman `UIRoot._abrir_ajustes(origen)` â†’
`SettingsAudioLayer.open()` si no está visible:

| Emisor | Situación anterior | Situación nueva |
|--------|--------------------|-----------------|
| `MenusLayer.ajustes_pedido` (M89) | `ui_manager.push_layer(pause_layer)` — **no-op**: la capa ya registrada sigue en la pila (push_layer con capa en pila = warning) | `_abrir_ajustes("M89")` → open de la sección Audio |
| `PauseLayer.ajustes_pedido` (T-053-066) | Emitía **sin listener** (deep-link colgado) | `_abrir_ajustes("T-053-066")` → open de la sección Audio |

El registro de la pila lo hace la capa sola en `_enter_tree` (`register_layer`
es idempotente), patrón sancionado en `ui_manager.gd`; `open()` no empuja, solo
muestra. Esc/`close_top` â†’ `pop_layer` des-registra; reabrir con `open()`
**re-registra** (heal verificado por test).

### 7.3 Flujo forward (widget â†’ AudioConfig â†’ disco)

| Evento de widget | Handler | Acción | Persistencia |
|---|---|---|---|
| `HSlider.value_changed` | `_on_slider_volumen` | etiqueta % + marca sucio + (re)arranca TimerCommit | **ninguna** (debounce §21.4) |
| `drag_ended(true)` / `TimerCommit.timeout` / `close()` | `commit_*` | `AudioConfig.set_volumen_porcentaje(bus, v)` | `config["audio"][bus]` (DataStore/GestorConfig, M60) |
| `CheckButton.toggled` (mute) | `_on_mute_toggled` | `set_mute(bus, on)` | `config["audio"]["mutes"]` |
| `OptionButton.item_selected` / compresión `toggled` | `aplicar_opcion(clave, valor)` | `set_opcion()`; si devuelve `false` → feedback | `config["audio"]["opciones"]` |

- **Debounce:** un solo `[M60] Config guardada` por commit (no por frame): `value_changed`
  marca pendiente; escriben `drag_ended`, el timer (0.25 s) o el cierre de la capa.
- **Feedback de fallo:** `aplicar_opcion` con valor inválido → devuelve `false`,
  muestra `SETTINGS.AUDIO_FALLA` en `LblFallo` y el widget revierte por la señal
  inversa; un cambio válido posterior oculta el label.

### 7.4 Flujo reverse (AudioConfig â†’ widget, anti-bucle)

`volumen_cambiado` / `mute_cambiado` / `opcion_cambiada` â†’ los handlers inversos
usan **`set_value_no_signal` / `set_pressed_no_signal` / `select()`**. Emitir
`value_changed` desde el reverse cerraría el bucle: AudioConfig emite siempre
(sin guard de igualdad) y `set_value` sí emite en el árbol (medido en 4.7.2).

### 7.5 Decisiones y restricciones respetadas

- Sin tocar `scripts/interacciones/`, `mapa/`, `construccion/`, `saving/` (lectura) ni widgets DeepSeek.
- i18n: 14 claves `SETTINGS.*` nuevas agregadas a `locales/es.po` y `en.po` (LF).
- Deprecación de los volúmenes de `game_settings.gd` (dueño M07) documentada en su `plan-actual/04-Codigo.md`.

## Umbral de re-render del UI (S62b — G-5.3-Flash-Agente, 2026-10-23; apilado CRON F #3)

**Criterio numerico de CUANDO el UI re-renderiza (anti-lag M58/M61):**
- RE-RENDER DISPARADO SOLO POR: cambio de chunk/POI del jugador (evento del
  streaming M63), cambio de ratio de recurso (inventario M14), cambio de
  perfil M58 (aplicar_perfil), o cambio de seleccion herramienta M13.
- PROHIBIDO re-render por frame: sin polling de estado en _process de UI
  (solo senal/evento); el binding que pregunta cada frame es deuda
  documentada.
- UMBRAL numerico: el re-render de un panel completo debe completar
  <= 8 ms (medible con el QA NFR overhead M58 S45/S48); el delta entre
  cambio de perfil y el frame pintado <= 2 frames.
- COMO se mide: profiler Godot pestaña UI raiz (la duración del callback de
  la señal) + el QA NFR overhead como patrón de instrumentacion.


## Specs UI/UX (Beam 508)

### Cambio de resolución con capas abiertas (M90)
- Spec: cambio de resolución M90 con capas abiertas: sin cortes ni controles fuera de pantalla. Coherente con M90 (configuración) y M53 (UI).

### Pausa durante transición de escena (M63) sin capas colgadas
- Spec: pausa durante transición de escena (M63) sin capas colgadas. Coherente con M63 (streaming) y M53 (UI).

## Coherencia de UI MEDIDA — auditor, feedback de 120 ms y canal unico (2026-10-25, DeepSeek-V4.1-Flash, Log 2179)

Esta seccion reemplaza la discusion cualitativa de L138/L144/L159/L221 por un
**modelo medido**: cada cifra de abajo sale de correr los artefactos contra el
corpus real del proyecto (1215 `.gd`), no de leer a ojo.

### 8.1 Artefactos

| Artefacto | Ruta | Que hace |
|---|---|---|
| Auditor estatico | `scripts/ui/auditar_ui_m53.py` | Mide los 4 items. `--json`, `--check` (informe, exit 1 si hay violacion), `--selftest` (gate, exit 0/1), **exit 3 = auditor CIEGO** |
| Suite del auditor | embebida (`--selftest`) | 14 checks herméticos sobre corpus sintético (limpio y sucio) |
| Modelo de feedback | `game/isla-ancestral/scripts/ui/feedback_accion_m53.gd` | Tabla de amplitudes + pasos del Tween como datos + aplicador |
| Suite del modelo | `game/isla-ancestral/scripts/ui/test_feedback_accion_m53.gd` | 6 bloques A-F, 64 checks, piso 64 MEDIDO |

Protocolo de gate ratificado en M50 y reusado aca: **`--selftest` es el gate
duro de CI**; `--check` es informe (hoy sale 1 a proposito, por la deuda que
declara). Un gate que sale rojo por diseño no sirve como gate.

### 8.2 L138 — Feedback visual de colocacion, cosecha y compra (120 ms)

Formula (fuente unica: `feedback_accion_m53.gd`):

- **Duracion por paso: 120 ms exactos** (`DURACION_S = 0.12`), dos fases en
  paralelo por propiedad (ida y vuelta) => **240 ms de gesto total**.
- Propiedades: `scale` (pico de amplitud) y `modulate` (flash de tinte), ambas
  vuelven a neutro (`Vector2.ONE` / `Color.WHITE`).
- Tinte desde la paleta del tema (`ThemeUx.COLOR_*`), nunca un literal: si la
  paleta cambia, el feedback cambia con ella (esto es L159 aplicado a L138).

| Accion | Escala pico | Alfa del flash | Tinte | Curva |
|---|---|---|---|---|
| colocacion | 1.10 | 0.55 | `COLOR_HIGHLIGHT_GOLD` | TRANS_QUAD / EASE_OUT |
| cosecha | 1.14 | 0.50 | `COLOR_SPEAKER_NPC` | TRANS_BACK / EASE_OUT |
| compra | 1.08 | 0.60 | `COLOR_ACCENT_OCRE` | TRANS_SINE / EASE_OUT |

**Medido en disco (2026-10-25):** `colocacion` 18 archivos de superficie / **0
tweens**; `cosecha` 6 archivos / **4 tweens, 3 de ellos de 0.12** (el cuarto es
0.05 en `crop_tile_visual.gd`); `compra` 9 archivos / **0 tweens**. O sea: hoy
solo cosecha tiene feedback animado, y ni siquiera completo.

**Estado honesto del item:** el modelo + aplicador + suite existen y estan
verificados; **NO estan cableados** (0 consumidores fuera de su test). El
cableado corresponde a M17 (colocacion), M16/farm (cosecha) y M95/shops
(compra). Por eso L138 se propone como `[→]`, no como `[x]`.

### 8.3 L144 — No redundancia: nunca sonido + visual + toast

**Regla medida:** una accion puede tener audio (M44/FeedbackDirector) o toast
(NotificationService) o feedback visual, pero **no los tres a la vez** para el
mismo evento. El auditor cuenta, por funcion del codigo de producto, cuantos
canales distintos toca (`audio`, `toast`, `visual`, `haptico`).

**Medido:** 0 funciones con triple canal y 0 con audio+toast. La regla se
cumple hoy, pero **por vacuidad**: los servicios estan separados y el canal de
SFX de hover/click esta desconectado.

**Hallazgo (defecto de verificacion, corregido):** el unico test que cubria el
item, `test_m53_no_redundancia.gd`, tenia esta asercion:

    _check(uf == null, "UIFeedback no esta montado ... no hay redundancia posible")

Era un **PASS que solo se cumplia mientras el canal de audio siguiera roto**:
consagraba el defecto. Se reemplazo por una **deuda declarada** (`print`, sin
assert) y la no-redundancia pasa a verificarse sobre el codigo de producto en
el bloque C del auditor. La suite sigue verde: 7 checks / 0 fallos / EXIT 0.

### 8.4 L159 — Coherencia visual entre capas (un solo lenguaje)

Dos metricas distintas, porque son dos deudas distintas:

1. **Duplicacion de token** (deuda estructural): un literal `Color(...)` con el
   MISMO valor que un token del tema (distancia RGB <= 0.05). No se ve mal,
   pero rompe la fuente unica: si el tema cambia, la copia no.
   **Medido: 27 literales** en codigo de producto.
2. **Fuera de paleta** (criterio de diseño): literal a distancia > 0.05 del
   token mas cercano. **Medido: 271**. No es automaticamente un defecto: los
   colores semanticos (marcadores de minimapa, rarezas, estados) viven fuera de
   una paleta de 11 tokens a proposito. El auditor los publica, el diseño decide.

Contexto: 95 archivos usan literales de color y solo 16 usan tokens del tema.
Otros 146 literales caen en archivos no-producto (tests, diag, demo, snapshots
con fecha), que se cuentan aparte y **no se descartan en silencio**.

### 8.5 L221 — Canvas merge por capa

**Medido:** 20 raices `CanvasLayer` (18 de producto), **14 sin `layer`
explicito** (quedan en el default 1, compartiendo plano), y solo 3 indices en
uso: -1, 15 y 100.

**Hallazgo:** `pantalla_carga.gd:36` declara `layer = 100  # por encima de todo`
y `ui_root.gd:36` declara `layer = 100` sin comentario. **Misma capa**, y el
comentario afirma lo contrario. El orden de dibujado entre ambas queda librado
al orden del arbol, no al diseño. Es la colision que detecta el bloque A.

Consolidar capas (merge de canvas) sigue siendo una optimizacion que necesita
medicion con Profiler (M61) antes/despues: el auditor mide la ESTRUCTURA
(cuantas raices, cuantos indices, cuantas colisiones), no draw calls.

### 8.6 Segundo falso verde encontrado (L182): asercion con premisa vencida

`test_m53_extremos.gd` (que sostiene el `[x]` de L182 "test con combinaciones
extremas") exigia:

    _check(absf(fc.r - 0.10) < 0.01 and absf(fc.g - 0.05) < 0.01,
           "alto contraste: font_color Label oscurecido (0.10, 0.05, ...)")

Ese `0.10/0.05` era correcto con la paleta CLARA anterior a D102. Desde el tema
noche (D102, 2026-10-18) **oscurecer el texto baja el contraste**, asi que
`ensure_contrast()` pone casi blanco (0.97, 0.96, 0.93). Medido: la suite estaba
en **8 checks / 1 fallo** (determinista, 2 corridas), o sea el `[x]` de L182 ya
no se sostenia.

Corregido: la asercion ahora verifica el **contrato** (ratio WCAG >= 4.5 contra
el panel y texto mas claro que el panel), no un color hardcodeado. Medido tras el
fix: **9 checks / 0 fallos / EXIT 0**. Nota: verifica el contrato, no el
mecanismo — un `ensure_contrast()` no-op que ya cumpliera el ratio tambien
pasaria, y eso es correcto: lo que se garantiza es el resultado.

### 8.7 Reglas verificables (para que no se degrade)

1. Toda accion con feedback visual usa `FeedbackAccionM53` y por lo tanto 120 ms.
2. Un tinte nuevo se declara como token en `ThemeUx`, no como literal en el
   llamador.
3. Una raiz `CanvasLayer` nueva declara `layer` explicito y no reusa un indice
   ya tomado.
4. Un test NUNCA pasa afirmando que un canal/feature NO existe: la ausencia se
   declara como deuda, no como logro.
5. Un test no fija colores literales: verifica ratios y relaciones.
6. La capa de carga es la MAXIMA de las capas de producto (regla E del
   auditor): una carga por debajo de un modal queda tapada.

### 8.8 Tanda 1 de L159: 9 literales que duplicaban un token (2026-10-25, Log 2181)

GO del director (msg 395, punto 4): reemplazo **mecanico** SOLO de los literales que
duplican un token de `ThemeUx`, en orden de tanda por modulo. Los **271** literales
fuera de paleta NO se tocan: cambiarlos es una decision de diseno, no un reemplazo.

Alcance de esta tanda: los archivos de UI del propio modulo (`scripts/ui/layers/` y
`scripts/ui/widgets/`). **9 sitios en 6 archivos**.

| Archivo | Antes | Despues |
|---|---|---|
| `ui/layers/loading_layer.gd` L79 | `Color(0.14, 0.16, 0.24)` | `Color(ThemeUx.COLOR_BG_ARENA, 1.0)` |
| `ui/layers/menus_layer.gd` L28 | `Color(0.14, 0.16, 0.24)` | `Color(ThemeUx.COLOR_BG_ARENA, 1.0)` |
| `ui/layers/settings_audio_layer.gd` L87 | `Color(0.14, 0.16, 0.24, 0.98)` | `Color(ThemeUx.COLOR_BG_ARENA, 0.98)` |
| `ui/widgets/action_prompt_overlay.gd` L12 | `Color(0.14, 0.16, 0.24, 0.85)` | `Color(ThemeUx.COLOR_BG_ARENA, 0.85)` |
| `ui/widgets/hotbar_widget.gd` L14 | `Color(0.92, 0.76, 0.40, 0.9)` | `Color(ThemeUx.COLOR_HIGHLIGHT_GOLD, 0.9)` |
| `ui/widgets/hotbar_widget.gd` L15 | `Color(0.14, 0.16, 0.24, 0.92)` | `Color(ThemeUx.COLOR_BG_ARENA, 0.92)` |
| `ui/widgets/hotbar_widget.gd` L82 y L123 | `Color(0.87, 0.66, 0.33, 0.55)` | `Color(ThemeUx.COLOR_ACCENT_OCRE, 0.55)` |
| `ui/widgets/interact_prompt.gd` L11 | `Color(0.14, 0.16, 0.24, 0.88)` | `Color(ThemeUx.COLOR_BG_ARENA, 0.88)` |

**Tecnica: el alpha se pasa EXPLICITO.** `COLOR_BG_ARENA` vale
`Color(0.14, 0.16, 0.24, 0.94)`, mientras los literales del llamador tenian alphas
distintos (1.0, 0.92, 0.98, 0.88, 0.85). Escribir el token a secas habria cambiado
la transparencia de todos esos paneles. Con `Color(token, a)` el RGB sale del token
y el alpha queda igual: **los 9 sitios rinden el mismo color que antes**.

Detalle verificado antes de usar la forma en `const`: `Color(ThemeUx.COLOR_X, a)` es
**expresion constante valida** en GDScript (probado con `--check-only` sobre una
sonda desechable antes de tocar los 3 archivos que la usan en `const`). Si no lo
fuera, esos 3 habrian necesitado cambiar `const` por `var`, lo que rompe el
contrato de solo-lectura del estilo.

Medido con `scripts/ui/auditar_ui_m53.py` (antes -> despues):

| Metrica | Antes | Despues |
|---|---|---|
| `literales_duplican_token` | 27 | **18** |
| `archivos_con_token` | 16 | 21 |
| `archivos_con_literal` | 95 | 92 |
| `literales_fuera_paleta` | 271 | 271 (sin tocar, por alcance) |
| `violaciones_duras` | 30 | **20** |

Los **18 restantes** son de archivos de OTROS modulos y van en tandas aparte (el
director pidio no hacerlo de corrido). Medido por archivo:

| Archivo | Sitios | Modulo funcional |
|---|---|---|
| `player/player.gd` | 5 | M11 |
| `clock/w_reloj.gd` | 3 | reloj (M29/M53) |
| `fasttravel/fast_travel_effect.gd` | 2 | fast-travel |
| `crafting/crafting_ui.gd` | 1 | crafting |
| `dialogos/ui/dialogue_ui.gd` | 1 | M21 (NO TOCAR) |
| `main_island.gd` | 1 | core |
| `mapa/map_canvas.gd` | 1 | M54 |
| `shops/shop_ui.gd` | 1 | shops |
| `stream/pantalla_carga.gd` | 1 | M63 (NO TOCAR) |
| `world/block_catalog.gd` | 1 | world |
| `ui/widgets/minimap_widget.gd` | 1 | M54/M53 (dueno en disputa) |

`minimap_widget.gd` queda fuera a proposito: su literal (`0.15, 0.18, 0.22`) NO es
igual al token (`0.14, 0.16, 0.24`), esta a distancia 0.03. Reemplazarlo es una
decision de diseno (unificar el fondo del minimapa), no un reemplazo mecanico, y el
archivo lo reclama M54. Se pide GO explicito antes de tocarlo.

### 8.9 Orden de capa: `pantalla_carga` 120 sobre `ui_root` 100 (decision del director, msg 395 punto 3)

Antes de esta tanda habia **dos** raices `CanvasLayer` en `layer = 100`:
`scripts/ui/ui_root.gd` (montada por `main_island.gd`) y `scripts/stream/pantalla_carga.gd`
(autoload `PantallaCarga`). Dos capas en el mismo indice dejan el orden visual a cargo
del orden del arbol de escena, que es exactamente lo que no se puede garantizar.

Decision aplicada (director, msg 395): `pantalla_carga` sube a **120**, `ui_root` queda
en **100**. La pantalla de carga va por encima de todo, incluido un modal abierto
durante una transicion.

Medido con el auditor: `layers=[-1, 15, 100, 120]`, `colisiones=0` (antes 1: `100` con
dos archivos).

**La decision quedo codificada como regla** (bloque E del auditor), para que no se
degrade: si `pantalla_carga.gd` declara un `layer` que NO es el maximo de las capas de
producto, es violacion dura. Se probo EN ROJO de forma **diferencial** (el repo tiene
20 violaciones ajenas a E, asi que comparar contra `exit 0` seria un criterio
equivocado): inyectando `layer = 50` las violaciones pasan de 20 a **21** (+1 exacta),
la linea nombra `pantalla_carga.gd` y `ui_root.gd`, y al restaurar los bytes el
`sha256` vuelve al original y la linea desaparece.

⚠️ Primera sonda descartada: inyecte `layer = 100` esperando la regla E y lo que
disparo fue la **colision de L221** (nada quedaba por encima). El `exit 1` era correcto
por casualidad, no por la regla nueva. Para probar E hay que bajar la capa DEBAJO de
otra, no igualarla.

**Lo que esta decision NO hace:** el merge de canvas de L221 (consolidar capas para
bajar draw calls) sigue pendiente. Ordenar dos capas no es fusionarlas.

**Verificacion visual pendiente (M154):** el cambio de orden es estatico y medible,
pero el efecto en pantalla (que la barra de carga tape el HUD y no al reves) es
visual. Se declara como pendiente de M154, no como verificado.

### 8.10 Tanda 2 de L159: 5 literales mas, y un punto ciego del propio auditor (2026-10-25, Log 2183)

Segunda tanda del GO scopeado del director (msg 395, punto 4: reemplazo mecanico
solo por `ThemeUx.COLOR_*`, tanda por modulo). Tanda 1 cerro 9 sitios en archivos
propios de M53 (§8.8). Esta tanda toma los tres modulos libres propuestos en el
reporte 397 y **deja afuera, a proposito**, todo archivo con dueno en la lista
NO TOCAR (`dialogos/ui/dialogue_ui.gd` es M21) y `ui/widgets/minimap_widget.gd`
(su literal no es igual al token: ver §8.8).

| Archivo | Linea | Antes | Despues | Token | Dist. |
|---|---|---|---|---|---|
| `clock/w_reloj.gd` | 117 | `Color(0.95, 0.93, 0.86)` | `ThemeUxRef.COLOR_TEXT_DARK` | `COLOR_TEXT_DARK` | 0.017 |
| `clock/w_reloj.gd` | 124 | `Color(0.95, 0.93, 0.86)` | `ThemeUxRef.COLOR_TEXT_DARK` | `COLOR_TEXT_DARK` | 0.017 |
| `clock/w_reloj.gd` | 141 | `Color(0.95, 0.93, 0.86)` | `ThemeUxRef.COLOR_TEXT_DARK` | `COLOR_TEXT_DARK` | 0.017 |
| `shops/shop_ui.gd` | 59 | `Color(0.96, 0.92, 0.86, 0.98)` | `Color(ThemeUx.COLOR_TEXT_DARK, 0.98)` | `COLOR_TEXT_DARK` | 0.022 |
| `crafting/crafting_ui.gd` | 58 | `Color(0.96, 0.92, 0.86, 0.98)` | `Color(ThemeUx.COLOR_TEXT_DARK, 0.98)` | `COLOR_TEXT_DARK` | 0.022 |

**El alpha se pasa explicito donde el literal lo tenia** (0.98 en los dos paneles),
porque `COLOR_TEXT_DARK` vale alpha 1.0: el token pelado habria cambiado la
transparencia de los dos paneles. En los tres sitios del reloj el literal era
opaco y el token tambien, asi que ahi va el token directo.

**Por que `ThemeUxRef` y no `ThemeUx` en el reloj.** `w_reloj.gd` no usaba ningun
simbolo del tema y **es precargado por suites `--script` headless**
(`caso_reloj_tests.gd` L18, `test_reloj_localizacion.gd` L54). En ese modo los
`class_name` globales no resuelven (E-30, GUIA-GODOT/06), asi que se agrego
`const ThemeUxRef := preload("res://scripts/ui/theme/theme_ux.gd")` — el mismo
patron que ya usa `scripts/ui/feedback_accion_m53.gd`. Los otros dos archivos ya
referenciaban `ThemeUx` de forma global y no se toco su estilo.

**Punto ciego del auditor, encontrado al medir (no al revisar).** Despues de la
tanda, `archivos_con_token` subio 21 -> 23 cuando habia **tres** archivos nuevos
con token. Causa: el conteo usaba `ThemeUx\.COLOR_[A-Z0-9_]+`, que no matchea la
forma con alias (`ThemeUxRef.COLOR_...`) porque en `ThemeUxRef.` el caracter que
sigue a `ThemeUx` es `R`, no un punto. El efecto era un **subconteo preexistente**
de 1 archivo (`feedback_accion_m53.gd`, que ya usaba el alias). Corregido a
`(?:ThemeUx|ThemeUxRef)\.COLOR_[A-Z0-9_]+` y **cubierto con fixture**: el corpus
sintetico limpio gano `reloj_alias.gd` (token por preload con alias) y un check
que exige `archivos_con_token == 2` en ese corpus.

**Prueba EN ROJO del check nuevo** (`sonda_alias.py`, descartable): se inyecta el
regex viejo -> `19 checks, 1 fallo(s)`, la linea dice *«cuenta el token por
class_name Y por preload con alias (medido=1)»* y el `EXIT` es **1**; al restaurar
los bytes el `sha256` vuelve a `e4e659c3f2c865766412237acaea376870c40a892b4f03b80c1a679d85e59711`
y el control final sale `19/0 EXIT 0`. Piso de checks **18 -> 19 MEDIDO** (no
estimado), `--selftest` **19/0 x3**.

**Medido antes -> despues** (auditor sobre 1216 `.gd`):

| Metrica | Antes | Despues |
|---|---|---|
| `literales_duplican_token` | 18 | **13** |
| `archivos_con_token` | 21 | **25** (+3 de la tanda, +1 que el subconteo ocultaba) |
| `archivos_con_literal` | 92 | 92 |
| `literales_fuera_paleta` | 280 | 280 (fuera de alcance a proposito) |
| `violaciones_duras` | 20 | **15** |

Las 15 duras = los 13 literales restantes (otros modulos) + las 2 de L138
(`colocacion` y `compra` sin feedback). El delta es exactamente **-5**, que es el
tamano de la tanda.

**Los 13 que quedan, por archivo y modulo:**

| Archivo | Sitios | Modulo / nota |
|---|---|---|
| `player/player.gd` | 5 | M11 — el bloque mas grande, sin tanda pedida |
| `fasttravel/fast_travel_effect.gd` | 2 | M68 |
| `dialogos/ui/dialogue_ui.gd` | 1 | M21 — **NO TOCAR** |
| `main_island.gd` | 1 | escena raiz |
| `mapa/map_canvas.gd` | 1 | M54 |
| `stream/pantalla_carga.gd` | 1 | M63 — **NO TOCAR** |
| `world/block_catalog.gd` | 1 | M08 |
| `ui/widgets/minimap_widget.gd` | 1 | M54 — literal **no** igual al token (dist 0.03) |

**Regresion ejecutada con binario real** (no leida): `--check-only` de los 3
archivos tocados **EXIT 0 / 0 errores**; `test_reloj_localizacion` **6/0 EXIT 0**;
`qa_m16_ui_cerrada` y `qa_m16_panel_mejora` **RESULTADO=OK EXIT 0**; las 6 suites
de M53 verdes (capas 14/0, no_redundancia 7/0, extremos 9/0, lista_larga 7/0,
feedback 64/0, wcag 17/0 = **118 checks, 0 fallos**), `SCRIPT ERROR` **0**.

**Rojo ajeno que aparece en la regresion y NO es mio:** `caso_reloj_tests` sale
**29 checks / 1 fallo EXIT 1**, y el fallo es el scan `C56/E89/E90`
(«0 lecturas de reloj-SO en gameplay»). Los 6 archivos que lo disparan son
`scripts/rendimiento/memoria/sesion_m62_*.gd` y `test_m62_chunks_presupuesto.gd`,
que usan `Time.get_datetime_string_from_system` y **estan en HEAD desde
`2dfed83` (2026-10-19)**, mientras que el scan se toco por ultima vez el
2026-10-16. La whitelist tiene `res://scripts/performance/` pero los archivos
viven en `res://scripts/rendimiento/`. No es efecto de esta tanda (los 3 archivos
tocados tienen **0** ocurrencias de las APIs del scan) y **no se toco**: agregar
la entrada a la whitelist es decision de M30, y cambiar los timestamps es de M62.
Queda reportado al director.
### 8.11 Tanda 3 de L159: 7 literales mas, y 3 que NO se unifican por semantica (2026-10-25, Log 2184)

**Decision del director (msg 400):** se mantiene `DIST_TOKEN_IGUAL = 0.05`, **no**
byte-exacta. El objetivo de tokenizar es consolidar literales sueltos a un token NAMED
(consistencia de diseno), no preservar un literal que nadie definio intencionalmente.
Los 5 sitios de la tanda 2 no se revierten (0.017/0.022, dentro de tolerancia). Regla
para los 13 restantes: la misma 0.05, y se deja en NO TOCAR solo lo que difiera >0.05
o sea decision de diseno / dueno.

**Reparto de los 13 medidos:** 3 quedan afuera por **dueno** (no por distancia) y 10 se
evaluaron por semantica. De esos 10, **7 se unifican** y **3 no**, con causa medida.

| Archivo | Linea | Antes | Despues | Token | Dist. |
|---|---|---|---|---|---|
| `player/player.gd` | 1020 | `Color(0.85, 0.65, 0.30, 0.45)` | `Color(ThemeUx.COLOR_ACCENT_OCRE, 0.45)` | `COLOR_ACCENT_OCRE` | 0.037 |
| `player/player.gd` | 1036 | `Color(0.95, 0.93, 0.86)` | `ThemeUx.COLOR_TEXT_DARK` | `COLOR_TEXT_DARK` | 0.017 |
| `player/player.gd` | 1060 | `Color(0.14, 0.16, 0.24, 0.92)` | `Color(ThemeUx.COLOR_BG_ARENA, 0.92)` | `COLOR_BG_ARENA` | 0.000 |
| `player/player.gd` | 1062 | `Color(0.85, 0.65, 0.30, 0.35)` | `Color(ThemeUx.COLOR_ACCENT_OCRE, 0.35)` | `COLOR_ACCENT_OCRE` | 0.037 |
| `player/player.gd` | 1070 | `Color(0.95, 0.93, 0.86)` | `ThemeUx.COLOR_TEXT_DARK` | `COLOR_TEXT_DARK` | 0.017 |
| `fasttravel/fast_travel_effect.gd` | 16 | `Color(0.10, 0.12, 0.20, 1.0)` | `Color(ThemeUx.COLOR_PRESSED, 1.0)` | `COLOR_PRESSED` | 0.041 |
| `fasttravel/fast_travel_effect.gd` | 18 | `Color(0.92, 0.76, 0.40, 1.0)` | `Color(ThemeUx.COLOR_HIGHLIGHT_GOLD, 1.0)` | `COLOR_HIGHLIGHT_GOLD` | 0.000 |

**El alpha se pasa explicito** donde el literal tenia alpha propio (0.45 / 0.92 / 0.35),
porque `COLOR_ACCENT_OCRE` y `COLOR_BG_ARENA` traen el suyo (1.0 y 0.94). En los sitios
opacos va el token pelado. Los dos `const` de `fast_travel_effect.gd` compilan con
`ThemeUx.COLOR_*` dentro de un inicializador constante (`--check-only` EXIT 0).

**Los 3 que NO se unifican, con causa medida (no por comodidad):**

| Archivo | Linea | Literal | Token que sugiere la distancia | Por que no |
|---|---|---|---|---|
| `main_island.gd` | 245 | `Color(0.96, 0.94, 0.88)` | `COLOR_TEXT_DARK` (0.041) | Es `mat.albedo_color`: **albedo de material 3D** (arena blanca, paleta Maldivas). Atar la arena del terreno al color del **texto** de UI hace que un cambio tipografico repinte el mundo |
| `world/block_catalog.gd` | 78 | `Color(0.96, 0.94, 0.88)` | `COLOR_TEXT_DARK` (0.041) | Es el color del **bloque de arena** (`BlockType.SAND`). Mismo razonamiento: dominio mundo, no UI |
| `mapa/map_canvas.gd` | 45 | `Color(0.12, 0.15, 0.18, 1.0)` | `COLOR_PRESSED` (0.042) | Es un **fondo**; `COLOR_PRESSED` es el estado presionado de un boton. Ademas `COLOR_BG_ARENA` (la semantica correcta) queda **fuera** de tolerancia por canal (0.06 > 0.05), asi que la unica opcion dentro de la regla seria la semanticamente equivocada |

**Hallazgo de la herramienta (limitacion declarada del auditor).** La sugerencia de
`detalle_duplican` es **vecino mas cercano por distancia**, y la distancia no conoce el
dominio: para los 3 casos de arriba propone un token de UI para un color de mundo o para
un fondo. El auditor sirve para **encontrar candidatos**, no para decidir la unificacion;
la decision es semantica y se mide leyendo el sitio. Es la familia de la trampa 92
(detector laxo): un numero alto de candidatos no es senal de buena deteccion.

**Propuesta al director (no aplicada):** un token propio de mundo
`COLOR_ARENA_SAND = Color(0.96, 0.94, 0.88)` que cubra `main_island` L245 y
`block_catalog` L78; y decidir aparte el fondo de `map_canvas` (es de M54, con HOLD
vigente sobre el minimapa).

**Medido antes -> despues** (auditor sobre 1216 `.gd`):

| Metrica | Antes | Despues |
|---|---|---|
| `literales_duplican_token` | 13 | **6** |
| `violaciones_duras` | 15 | **8** |
| `archivos_con_token` | 25 | **26** |
| `archivos_con_literal` | 92 | 92 |
| `literales_fuera_paleta` | 280 | 280 (intactos) |

Delta exacto **-7** = tamano de la tanda. Los 6 que quedan: 3 por dueno
(`dialogue_ui` M21, `pantalla_carga` M63, `minimap_widget` HOLD M54) y los 3 de la tabla
de excepciones semanticas.

**E-30, esta vez medido en sentido contrario.** `player.gd` no usaba ningun simbolo del
tema y se toco con `ThemeUx` **global**, sin alias por preload. No fue una suposicion:
`test_player_m11.gd` hace `load("res://scripts/player/player.gd")` y asevera que el
script carga (A1), y la suite sale **30/0 EXIT 0** con el token global; ademas
`qa_fast_travel_fx.gd` ya cargaba `fast_travel_effect.gd` (que usa `ThemeUx` desde antes)
y seguia verde. La precaucion del alias (§8.10) aplica al caso medido alli, no como regla
general: se mide por archivo, con la suite que lo carga.

**Regresion con binario real:** `--check-only` de los 2 archivos **EXIT 0 / 0 errores**.
`test_player_m11` 30/0 (baseline 30/0), `test_player_cableado_m11` 71/0,
`qa_fast_travel_fx` 45 OK con **diff normalizado sin cambios de comportamiento** (solo
timestamp de sesion y conteo del spawner de M36, ambos volatiles; los 2 `ERROR` de
singleton/subtitle son **preexistentes**, identicos en el baseline). Las 6 suites de M53
x3 = **118 checks, 0 fallos, 0 SCRIPT ERROR en 18 corridas**; `--selftest` del auditor
**19/0 x3** (piso 19).

**Fe de erratas.** El titulo de §8.10 citaba *"Log 2182"*. El 2182 es de **M33
Agricultura** (Step-5); el log de la tanda 2 es el **2183**. Corregido el numero, sin
tocar el resto del contenido.



## Specs UI/UX (Beam 699)

### Probar navegacion completa de cada pantalla 30 minutos por metodo de input
- Spec: probar navegacion completa de cada pantalla 30 minutos por metodo de input. Coherente with M53 (UI/UX) and M114 (hardware).

### Mover objetos con gamepad (agarrar/soltar con confirm y direccion)
- Spec: mover objetos con gamepad (agarrar/soltar con confirm y direccion). Coherente with M53 (UI/UX) and M56 (interfaz).

### Test de rendimiento del minimapa con el mundo voxel cargado
- Spec: test de rendimiento del minimapa con el mundo voxel cargado. Coherente with M53 (UI/UX) and M61 (rendimiento).

### Integracion con el mapa completo M54 (acceso desde el minimapa)
- Spec: integracion con el mapa completo M54 (acceso desde el minimapa). Coherente with M53 (UI/UX) and M54 (mapa).

### Feedback visual de colocacion, cosecha y compra (Tween 120 ms)
- Spec: feedback visual de colocacion, cosecha y compra (Tween 120 ms). Coherente with M53 (UI/UX) and M48 (animacion).


## Specs UI/UX (Beam 707)

### Vibracion haptica leve opcional en gamepad (M57, ajustable en M58)
- Spec: vibracion haptica leve opcional en gamepad (M57, ajustable en M58). Coherente with M53 (UI/UX) and M57 (interfaz).

### Verificar coherencia visual entre todas las capas (un solo lenguaje)
- Spec: verificar coherencia visual entre todas las capas (un solo lenguaje). Coherente with M53 (UI/UX) and M128 (identidad).

### Revisar textos con locales largos (aleman) sin cortes (M87)
- Spec: revisar textos con locales largos (aleman) sin cortes (M87). Coherente with M53 (UI/UX) and M87 (fuentes).

### Integrar tamano, opacidad y fondo de subtitulos
- Spec: integrar tamano, opacidad y fondo de subtitulos. Coherente with M53 (UI/UX) and M58 (accesibilidad).

### Remapeo de M57 re-lee las etiquetas de prompts automaticamente
- Spec: remapeo de M57 re-lee las etiquetas de prompts automaticamente. Coherente with M53 (UI/UX) and M57 (interfaz).

## Specs UI/UX (Beam 708)

### Font subsetting por idioma (M88) para evitar desperdicio de memoria
- Spec: Font subsetting por idioma (M88) para evitar desperdicio de memoria. theme_ux._try_load_font (theme_ux.gd:193-208) carga las TTF completas con load_dynamic_font sin subsetting — las 3 fuentes (Nunito Regular/Bold, FredokaOne) cargan glifos completos. El subsetting por idioma requiere definir ranges Unicode por locale. M88 ya tiene el subsetter (tools/font_subsetter.py + scripts/fonts/auditar_glifos.gd, con la medicion de 79 codepoints requeridos y 78 cubiertos: falta U+2192). Lo que falta es CONECTARLO al pipeline de carga de theme_ux._try_load_font. Coherente with M53 (UI/UX) and M88 (fuentes).
