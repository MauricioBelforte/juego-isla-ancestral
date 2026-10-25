**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

# 03-Diseno.md â€” MÃ³dulo 53: UI/UX

## 1. Arquitectura general

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ AUTOLOADS (orden de registro) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Bootstrap(M07) > EventBus(M07) > ActionLayer(M57) > UIManager(M53)           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                                    â”‚ consume
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ GODOT TREE â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ CanvasLayer "UI_ROOT" (layer 100)                                          â”‚
â”‚ â”œâ”€ HUDScreen               (siempre visible, layer menor, read-only HUD)   â”‚
â”‚ â”‚   â”œâ”€ StatusBar Â· ClockWidget(M30) Â· SeasonWidget Â· ResourceCounter        â”‚
â”‚ â”‚   â”œâ”€ HotbarWidget(M11) Â· InteractPrompt(M70) Â· MinimapWidget(M53/M54)     â”‚
â”‚ â”‚   â””â”€ NotificationService (cola de toasts)                                 â”‚
â”‚ â”œâ”€ DialogLayer  (M21: ventana, retrato, opciones, subtÃ­tulos M58)           â”‚
â”‚ â”œâ”€ InventoryLayer (grid + hotbar sync + drag & drop)                        â”‚
â”‚ â”œâ”€ PauseLayer   (menÃº pausa + acceso a Ajustes/M89)                         â”‚
â”‚ â”œâ”€ MenusLayer   (M89: menÃº principal, continuar, cargar, ajustes, crÃ©ditos) â”‚
â”‚ â””â”€ GenericLayers... (confirm popup, amount picker, tutorial tips)           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```
Capas: **HUD** (no modal, sigue al mundo) Â· **Modal Sencillo** (diÃ¡logo: pausa parcial) Â· **Modal Completo** (inventario/pausa: pausa total, bloquea input del mundo) Â· **Popup** (confirmar, notificaciÃ³n, tooltip: no competidor de foco).

## 2. Componentes principales

### 2.1 UIManager (autoload, `res://ui/core/ui_manager.gd`)
Orquesta la pila de capas, el foco, la pausa y la distribuciÃ³n de acciones transversales de M57.

- Pila de capas: `push_layer(layer)`, `pop_layer(layer)`, `top()`, `close_top()`.
- Reglas: solo una capa Modal Completo a la vez; las demÃ¡s se encolan; al cerrar se restaura el foco al elemento guardado o al primero de la capa visible.
- Suscribe acciones de M57: `inventory_toggle`, `pause`, `close`, `confirm`, `cancel`, `tab_next/tab_prev`, `menu_open`.
- `process_mode` por capa: modal completo congela el mundo (pausa M29); HUD usa `PROCESS_MODE_ALWAYS` con refresh bajo demanda.
- Emite eventos `ui_layers_changed`, `ui_focus_moved`.

### 2.2 UILayer (base `res://ui/core/ui_layer.gd`)
Clase base de toda pantalla modal. Contrato:

- `open(initial_focus: Control)`, `close()` â†’ devuelven `void`; transiciones por `Tween` (fade 120 ms).
- `on_layer_opened()` / `on_layer_closed()` virtuales (suscribirse/desuscribirse de eventos).
- Registra en UIManager al entrar al Ã¡rbol; exige `process_mode` coherente con su tipo.
- Herencia: `DialogLayer`, `InventoryLayer`, `PauseLayer`, `MenusLayer`, `SettingsLayer` (M89 lo especializa), etc.

### 2.3 HUDScreen (`res://ui/hud/hud_screen.gd`)
- Widgets suscritos a EventBus (dominio `ui` y dominios de datos) â€” jamÃ¡s actÃºa sobre gameplay.
- Refresh por seÃ±al y `Timer` de baja frecuencia (2 Hz) para reloj/estaciÃ³n; sin refresh por frame.
- Ocultable con una sola acciÃ³n (para M56 FotografÃ­a / captura de pantalla): `set_hud_visible(false)`.

### 2.4 ThemeUx (`res://ui/theme/theme_ux.gd` + `theme_ux.tres`)
- `Theme` de Godot construido en runtime desde `theme_ux.tres` + fuentes de M88 (Nunito cuerpo / Fredoka One titulares; jerarquÃ­a H1 32, H2 24, H3 20, BODY 16, SMALL 12, MICRO 10).
- StyleBoxFlat redondeado (radius 12-16), paleta pastel (fondo arena, acento ocre, texto marrÃ³n oscuro, highlight dorado suave); hover/disabled/pressed con variantes de color suaves.
- API: `apply(scale_ratio)`, `reload_after_font_change()`, `ensure_contrast()` (contraste AA segÃºn M58), `reduce_motion_active`.
- Notas de accesibilidad: estados distinguibles por forma + color (borde/relleno), no solo color.

### 2.5 MenuNavigator (`res://ui/core/menu_navigator.gd`)
- Wrapping circular de foco (`focus_neighbor` explÃ­citos configurados en editor + `_gui_input` de atajos).
- `focus_first()`, `focus_last()`, `move_focus(direction)` (direccional 4D con gamepad), `wrap_manager` con ciclo continuo entre extremos de grid.
- Tooltip por foco: al enfocar un elemento, muestra su tooltip (accesible por teclado, RF6).

### 2.6 Widgets de datos
- `ClockWidget`: hora del GameClock M29/M30 (formato cozy "OtoÃ±o 3, 14:30").
- `MinimapWidget`: textura generada de navegaciÃ³n (M54 provee mapa/POIs), jugador centrado, rotaciÃ³n fija (decisiÃ³n: fija, menos cinetosis, M58), ocultable.
- `TooltipService`: pool Ãºnico, retardo 0.35 s, clamp de posiciÃ³n a viewport, cierre al mover foco/ratÃ³n.
- `NotificationService`: cola de toasts (mÃ¡x 3 visibles), tipo (obtenciÃ³n/evento/misiÃ³n) con icono + SFX del bus UI (M91); clicable para abrir detalle (M55).
- `ActionPromptOverlay`: lee el Action Layer de M57 y muestra el prompt correcto por dispositivo ("E para interactuar", "A" en gamepad, icono Xbox/PS segÃºn M57).

## 3. Flujos principales (texto)

### 3.1 Abrir inventario
1. Jugador pulsa acciÃ³n `inventory_toggle` (M57). El jugador la tiene asignada (tecla I / gamepad back).
2. ActionLayer notifica pulsaciones de acciones a UIManager (suscrito).
3. UIManager: no hay modal completo â†’ `push_layer(InventoryLayer)`; pausa GameClock (M29) si corresponde; bloquea input del mundo; guarda foco previo.
4. InventoryLayer: `on_layer_opened()` se suscribe a `inventory.changed` (M11); `MenuNavigator.focus_first()` â†’ foco en primera celda.
5. HUD permanece visible con `process_mode` pausado (no repinta).
6. Al pulsar `inventory_toggle`/`close`: pop, restaurar foco, reanudar GameClock, HUD reanuda refresh.

### 3.2 DiÃ¡logo con NPC
1. M21 emite `dialog_requested(npc_id, page)` por EventBus (dominio `ui`). La gameplay NO abre la ventana: emite el evento.
2. UIManager detecta capa `DialogLayer` no abierta â†’ la abre (modal sencillo: pausa reloj, el mundo sigue visibles congelado suavemente).
3. El jugador avanza con `confirm` (M57) o click en el botÃ³n de pÃ¡g; opciones con foco; velocidad de texto segÃºn M58; subtÃ­tulos si M58 activado; pausa de texto habilitada (M58).
4. Al final M21 emite `dialog_finished`; DialogLayer se cierra sola; foco restaurado al jugador.

### 3.3 Pausa
1. `pause` â†’ UIManager abre PauseLayer (modal completo).
2. Opciones: Continuar, Inventario, Diario (M55), Mapa (M54), Ajustes (M89: General/Controles M57/Audio M91/GrÃ¡fica M90/Accesibilidad M58), Guardar, Cargar, Salir al menÃº. Deep-linking entre capas: al cerrar una capa hija, el foco vuelve a PauseLayer.
3. `close`/pausa de nuevo â†’ continuar.

### 3.4 Tooltip por contexto
1. RatÃ³n sobre objeto interactuable â†’ M70 pide prompt (HUD); tras 0.35 s el TooltipService muestra texto breve ("Rocas con musgo. Â¿Excavar?").
2. Foco se mueve en UI â†’ tooltip del elemento enfocado (Ã­cono dÃ©cima favorita del item, precio, uso).
3. Tooltip se cierra: al mover el ratÃ³n fuera, cambiar foco, o pulsar cualquier acciÃ³n transversal.

### 3.5 NotificaciÃ³n-toast
1. EventBus `inventory.item_added`, `quest.updated`, `economy.purchase_done` â†’ NotificationService encola toast.
2. Aparece arriba-derecha bajo el minimapa (lugar fijo, no molesta al centro), fade 0.3 s, vida 4 s, mÃ¡x 3 simultÃ¡neos; se desplazan hacia arriba.
3. Feedback de sonido del bus UI (M91) asociado al tipo de toast.

### 3.6 Cambio de resoluciÃ³n (M90)
1. M90 aplica resoluciÃ³n â†’ emite `graphics.resolution_changed`.
2. ThemeUx.`reload_after_font_change()` y `apply(scale_ratio)`; UIManager revisa que las capas abiertas respeten anchors (guardas de debug) y recoloca tooltips/popups visibles.
3. MinimapWidget regenera su textura si el ratio cambiÃ³. Sin cortes en 16:9/16:10 (QA automatizado con lista de resoluciones).

### 3.7 Foco perdido (edge case)
1. Cerrar capa A sobre la que se abriÃ³ B encima: al hacer pop de B, UIManager restaura el foco guardado de A (guardado al push de B).
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

## 5. IntegraciÃ³n con otros mÃ³dulos

| MÃ³dulo | IntegraciÃ³n |
|---|---|
| M57 Interfaz de Control | Ãšnica fuente de acciones; Action Layer notifica a UIManager; prompts dinÃ¡micos por dispositivo; remapeo â†’ la UI re-lee etiquetas; navegaciÃ³n direccional gamepad via foco nativo |
| M58 Accesibilidad | ParÃ¡metros runtime: `ui_scale` (0.8-1.5 aplicado por ThemeUx), `text_scale`, `high_contrast`, `daltonism_mode` (formas + texturas junto al color), `reduce_motion` (desactiva Tweens/parpadeos), `subtitle_size`, `visual_sound_indicators`, `flash_free`. Todos aplicados en vivo sin reiniciar |
| M88 Fuentes TipogrÃ¡ficas | ThemeUx usa Nunito (cuerpo) y Fredoka One (tÃ­tulos) con la jerarquÃ­a H1..MICRO y line-heights definidos; subsetting para locales; recarga al cambiar idioma M87 |
| M89 DiseÃ±o de MenÃºs | Consume UILayer + MenuNavigator; define la lista de pantallas y su orden (menÃº principal, continuar, carga, ajustes, crÃ©ditos); pausa con deep-linking |
| M90 ConfiguraciÃ³n GrÃ¡fica | En eventos de cambio de resoluciÃ³n/escalado, ThemeUx se re-aplica; guardas de layout en QA multi-resoluciÃ³n |
| M91 ConfiguraciÃ³n de Audio | Bus UI dedicado para todos los SFX de interfaz; sliders del menÃº operan sobre buses reales (M91) |
| M21 DiÃ¡logos | `dialog_requested`/`dialog_finished` por EventBus; DialogLayer es la presentaciÃ³n de M21, sin lÃ³gica de historia |
| M54/M55/M56 | Consumen HUDScreen/Modal framework: minimapa (M54), diario (M55), modo fotografÃ­a oculta HUD (M56) |
| M30 Reloj / M29 Calendario | ClockWidget/SeasonWidget con la capa de presentaciÃ³n cozy; pausa respetada |
| M11 Jugador | HotbarWidget y ResourceCounter leen estado por seÃ±ales de dominio, jamÃ¡s por polling directo de nodos |
| M61 Rendimiento | Presupuesto UI â‰¤ 8% frame; minimapa con textura cachÃ©; labels con cachÃ© de texto; capas pausadas sin repintar |

## 6. Reglas anti-acoplamiento (verificables)

1. NingÃºn script de `scripts/gameplay/`, `scripts/world/` o `scripts/ai/` importa `res://ui/` (verificaciÃ³n estÃ¡tica en M01/M07).
2. La gameplay emite eventos `ui.*` en EventBus; la UI nunca es llamada con retorno obligatorio.
3. UIManager autoload es el Ãºnico punto de contacto hacia capas; las capas no se referencian entre sÃ­ (se comunican por eventos).
4. Los widgets del HUD no mutan estado de gameplay; solo leen.
5. Toda cadena visible pasa por tr_local (M87), nunca hardcodeada.

## 7. SecciÃ³n Audio de Ajustes â€” SettingsAudioLayer (iter. 2026-10-04, encargo canal 10 "OpciÃ³n A")

> **Modelo:** mimo-v2.6-flash-free Â· **Plataforma:** opencode Â· **Fecha:** 2026-10-04
> El M91 dejÃ³ el dominio de audio (AudioConfig) completo, pero **no existÃ­a ningÃºn
> widget de audio** en Ajustes. Esta secciÃ³n es el puente UIâ†’M91.

### 7.1 ComposiciÃ³n y posicionamiento

```
UIRoot (montaje)
â”œâ”€ ...capas existentes (pausa, menÃºs, crÃ©ditos, ...)
â””â”€ SettingsAudioLayer (MODAL_FULL)   â† montado el ÃšLTIMO: se dibuja encima
     â”œâ”€ TÃ­tulo  SETTINGS.AUDIO_TITULO
     â”œâ”€ Fila slider Master/Music/SFX: [HSlider 0-100] [Label %] [CheckButton mute]
     â”œâ”€ Separador + SETTINGS.OPCIONES
     â”œâ”€ Rango dinÃ¡mico (OptionButton: quiet/medio/dinÃ¡mico)
     â”œâ”€ CompresiÃ³n (CheckButton) Â· Dispositivo de salida (OptionButton)
     â”œâ”€ LblFallo (feedback, oculto por defecto)
     â””â”€ BtnVolver  Â·  TimerCommit (0.25 s, one-shot)
```

### 7.2 Deep-links de `ajustes_pedido` (routing)

Dos emisores, una sola capa; ambos caminos llaman `UIRoot._abrir_ajustes(origen)` â†’
`SettingsAudioLayer.open()` si no estÃ¡ visible:

| Emisor | SituaciÃ³n anterior | SituaciÃ³n nueva |
|--------|--------------------|-----------------|
| `MenusLayer.ajustes_pedido` (M89) | `ui_manager.push_layer(pause_layer)` â€” **no-op**: la capa ya registrada sigue en la pila (push_layer con capa en pila = warning) | `_abrir_ajustes("M89")` â†’ open de la secciÃ³n Audio |
| `PauseLayer.ajustes_pedido` (T-053-066) | EmitÃ­a **sin listener** (deep-link colgado) | `_abrir_ajustes("T-053-066")` â†’ open de la secciÃ³n Audio |

El registro de la pila lo hace la capa sola en `_enter_tree` (`register_layer`
es idempotente), patrÃ³n sancionado en `ui_manager.gd`; `open()` no empuja, solo
muestra. Esc/`close_top` â†’ `pop_layer` des-registra; reabrir con `open()`
**re-registra** (heal verificado por test).

### 7.3 Flujo forward (widget â†’ AudioConfig â†’ disco)

| Evento de widget | Handler | AcciÃ³n | Persistencia |
|---|---|---|---|
| `HSlider.value_changed` | `_on_slider_volumen` | etiqueta % + marca sucio + (re)arranca TimerCommit | **ninguna** (debounce Â§21.4) |
| `drag_ended(true)` / `TimerCommit.timeout` / `close()` | `commit_*` | `AudioConfig.set_volumen_porcentaje(bus, v)` | `config["audio"][bus]` (DataStore/GestorConfig, M60) |
| `CheckButton.toggled` (mute) | `_on_mute_toggled` | `set_mute(bus, on)` | `config["audio"]["mutes"]` |
| `OptionButton.item_selected` / compresiÃ³n `toggled` | `aplicar_opcion(clave, valor)` | `set_opcion()`; si devuelve `false` â†’ feedback | `config["audio"]["opciones"]` |

- **Debounce:** un solo `[M60] Config guardada` por commit (no por frame): `value_changed`
  marca pendiente; escriben `drag_ended`, el timer (0.25 s) o el cierre de la capa.
- **Feedback de fallo:** `aplicar_opcion` con valor invÃ¡lido â†’ devuelve `false`,
  muestra `SETTINGS.AUDIO_FALLA` en `LblFallo` y el widget revierte por la seÃ±al
  inversa; un cambio vÃ¡lido posterior oculta el label.

### 7.4 Flujo reverse (AudioConfig â†’ widget, anti-bucle)

`volumen_cambiado` / `mute_cambiado` / `opcion_cambiada` â†’ los handlers inversos
usan **`set_value_no_signal` / `set_pressed_no_signal` / `select()`**. Emitir
`value_changed` desde el reverse cerrarÃ­a el bucle: AudioConfig emite siempre
(sin guard de igualdad) y `set_value` sÃ­ emite en el Ã¡rbol (medido en 4.7.2).

### 7.5 Decisiones y restricciones respetadas

- Sin tocar `scripts/interacciones/`, `mapa/`, `construccion/`, `saving/` (lectura) ni widgets DeepSeek.
- i18n: 14 claves `SETTINGS.*` nuevas agregadas a `locales/es.po` y `en.po` (LF).
- DeprecaciÃ³n de los volÃºmenes de `game_settings.gd` (dueÃ±o M07) documentada en su `plan-actual/04-Codigo.md`.

## Umbral de re-render del UI (S62b â€” G-5.3-Flash-Agente, 2026-10-23; apilado CRON F #3)

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
- COMO se mide: profiler Godot pestaÃ±a UI raiz (la duraciÃ³n del callback de
  la seÃ±al) + el QA NFR overhead como patrÃ³n de instrumentacion.


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
