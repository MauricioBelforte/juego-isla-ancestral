# Auditoría de arquitecturas de UI — Glyph Cluster

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo (Vercel AI Gateway)  
**Fecha:** 2026-11-13  
**Alcance:** `game/isla-ancestral/scenes/ui/` y `game/isla-ancestral/scripts/ui/`  
**Tipo:** Análisis estático (sin modificaciones al código del juego)

## Resumen ejecutivo

- **Estado de escenas UI:** solo existe una escena en `scenes/ui/` (`hud.tscn`); el resto de capas se construyen por código desde `ui_root.gd`.
- **Hallazgos críticos/altos:** duplicación real de `ActionPromptOverlay` (HUD y widgets) con `class_name` en colisión, y doble ruta de apertura/gestión de diálogo (DialogLayer M53 + fallback M21 + `push_layer` sobre capa ya registrada).
- **`mouse_filter = STOP`:** no se hallaron asignaciones explícitas a `STOP/0` en el alcance auditado; la mayoría de nodos no interactivos usan `MOUSE_FILTER_IGNORE` (2), lo cual es correcto en HUD/overlays.
- **Señales:** hay guardas `is_connected` en varios puntos, pero también conexiones sin guarda y patrones de suscripción duplicables en runtime (`DialogueManager`/EventBus y reconexiones en `PauseLayer`).

---

## 1) `mouse_filter = STOP` que bloqueen interacción con el mouse

### Evidencia revisada
- `game/isla-ancestral/scenes/ui/hud.tscn:24,29,40,45,52,64,69,84,89,105,110,120,133,138,148` — todos los contenedores/widgets del HUD declaran `mouse_filter = 2` (`MOUSE_FILTER_IGNORE`).
- `game/isla-ancestral/scripts/ui/ui_root.gd:143` — `_agregar_widget_hud()` fuerza `widget.mouse_filter = Control.MOUSE_FILTER_IGNORE` para widgets `Control` instanciados por código.
- Fondos/overlays decorativos usan `MOUSE_FILTER_IGNORE`:  
  - `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd:126`  
  - `game/isla-ancestral/scripts/ui/layers/pause_layer.gd:37`  
  - `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd:64`  
  - `game/isla-ancestral/scripts/ui/layers/equipment_layer.gd:44`  
  - `game/isla-ancestral/scripts/ui/layers/diary_layer.gd:120`  
  - `game/isla-ancestral/scripts/ui/layers/credits_layer.gd:77`  
  - `game/isla-ancestral/scripts/ui/overlays/subtitulo_overlay.gd:38,45`  
  - `game/isla-ancestral/scripts/ui/widgets/action_prompt_overlay.gd:88` (widgets)  
  - `game/isla-ancestral/scripts/ui/widgets/minimap_widget.gd:190,199,210,217,263,271,278,285,323,351`
- Búsqueda dirigida en alcance UI (`scenes/ui`, `scripts/ui`): **sin coincidencias** para `MOUSE_FILTER_STOP` ni `mouse_filter = 0`.

### Hallazgos

| ID | Severidad | Hallazgo | Evidencia (archivo:línea) | Impacto |
|---|---|---|---|---|
| UI-MF-01 | **Informativa** | No se detectaron bloqueos explícitos por `mouse_filter = STOP` en la UI auditada. El patrón dominante es `IGNORE` en HUD, fondos y overlays. | `scenes/ui/hud.tscn:24,29,40,45,52,64,69,84,89,105,110,120,133,138,148`; `scripts/ui/ui_root.gd:143`; `scripts/ui/layers/dialog_layer.gd:126`; `scripts/ui/layers/pause_layer.gd:37`; `scripts/ui/layers/inventory_layer.gd:64`; `scripts/ui/layers/equipment_layer.gd:44` | Riesgo actual bajo de bloqueo de clic por `STOP` explícito en estas rutas. |
| UI-MF-02 | **Baja** | Varios `Control` raíz de capas modales no fijan `mouse_filter` explícitamente; dependen del valor por defecto del engine/escena. Hoy no bloquea por diseño, pero es una superficie frágil ante refactors o instanciación en escenas distintas. | `scripts/ui/layers/dialog_layer.gd:63` (`set_anchors_preset(FULL_RECT)` sin `mouse_filter`); `scripts/ui/layers/pause_layer.gd:30-34`; `scripts/ui/layers/menus_layer.gd:23-27`; `scripts/ui/layers/inventory_layer.gd:57-61`; `scripts/ui/layers/equipment_layer.gd:37-41`; `scripts/ui/layers/credits_layer.gd:68-73`; `scripts/ui/layers/settings_audio_layer.gd:68-72` | Posible regresión futura: un cambio a `STOP` en nodos contenedores full-screen puede absorber input del mouse fuera de botones. |

---

## 2) Capas de diálogo duplicadas

### Evidencia revisada
- **Capa formal M53:** `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd:14` (`class_name DialogLayer`, `extends UILayer`), montada por `ui_root.gd:41-45` y registrada en `UIManager` vía `UILayer._enter_tree` (`scripts/ui/core/ui_layer.gd:23-28`).
- **Fallback M21 documentado en código:** `dialog_layer.gd:10-12` indica coexistencia con `dialogue_ui.gd` (fallback M21). Existe implementación: `game/isla-ancestral/scripts/dialogos/dialogue_ui.gd:1` (`extends CanvasLayer`, `class_name DialogueUI`).
- **Dos fuentes de eventos para la misma presentación:** `DialogLayer` se suscribe a `DialogueManager` (`node_entered/dialogue_ended/option_selected`, `dialog_layer.gd:41-49`) y también a `EventBus.ui.dialog_requested/dialog_finished` (`dialog_layer.gd:50-58`).
- **Apertura adicional por `UIManager`:** `ui_manager.gd:480-486` empuja `DialogLayer` al recibir `EventBus.ui.dialog_requested` (`push_layer(layer)`), mientras la propia capa ya se auto-gestiona con `visible = true` en callbacks (`dialog_layer.gd:255-268,280-291,322-330`).
- **Estado de pila inconsistente para diálogos:** `UIManager._actualizar_pausa_mundo()` solo considera `MODAL_FULL` visibles (`ui_manager.gd:84-94`), pero `DialogLayer` es `MODAL_SIMPLE` (`dialog_layer.gd:35-39`) y además maneja pausa de reloj internamente (`dialog_layer.gd:243-251,349-353`).

### Hallazgos

| ID | Severidad | Hallazgo | Evidencia (archivo:línea) | Impacto |
|---|---|---|---|---|
| UI-DLG-01 | **Alta** | Coexisten al menos dos implementaciones de UI de diálogo: capa formal M53 (`DialogLayer`) y fallback M21 (`DialogueUI` CanvasLayer). La arquitectura declara fallback, pero no hay un único punto de verdad para renderizado/flujo visual del diálogo. | `scripts/ui/layers/dialog_layer.gd:10-14,41-58`; `scripts/ui/ui_root.gd:41-45`; `scripts/dialogos/dialogue_ui.gd:1-5`; `scripts/ui/core/ui_manager.gd:480-486` | Riesgo de divergencia UX/comportamiento (tema, subtítulos, input, pausa) y de doble presentación si M21 también instancia UI en runtime. |
| UI-DLG-02 | **Media** | `DialogLayer` escucha tanto señales directas de `DialogueManager` como eventos del `EventBus`, y además `UIManager` intenta abrir la capa por `dialog_requested`. Esto crea rutas paralelas de activación y visibilidad. | `scripts/ui/layers/dialog_layer.gd:41-58,255-260,280-291,322-330`; `scripts/ui/core/ui_manager.gd:52-54,480-486` | Estado difícil de razonar, riesgo de transiciones redundantes, y acoplamiento innecesario entre orquestador y capa. |
| UI-DLG-03 | **Media** | Apertura de diálogo vía `UIManager.push_layer` choca con el modelo de capas "montadas y registradas al entrar al árbol": `push_layer` retorna si la capa ya está en `_stack` (no la abre), y la visibilidad/pila queda parcialmente desincronizada. | `scripts/ui/core/ui_manager.gd:222-248`; `scripts/ui/core/ui_layer.gd:23-28,46-64`; `scripts/ui/layers/dialog_layer.gd:280-291` | Puede dejar `DialogLayer` visible sin ser la capa "gestionada" por `push_layer`, romper supuestos de foco/cierre y degradar el comportamiento modal. |

---

## 3) Orden incorrecto de `CanvasLayer`

### Evidencia revisada
- **HUD scene:** `scenes/ui/hud.tscn:14-16` → `HUDScreen` es `CanvasLayer` con `layer = 100`.
- **UIRoot (capas modales):** `scripts/ui/ui_root.gd:13,36` → `UIRoot extends CanvasLayer` y fija `layer = 100` en `_ready`.
- **HUDScreen en árbol de escenas principal:** montado como hijo `UI` (`scenes/main_island.tscn:170` referencia `res://scenes/ui/hud.tscn`).
- **Overlays/servicios globales como CanvasLayer:**  
  - `scripts/ui/services/notification_service.gd:1` (`extends CanvasLayer`, sin `layer` explícito)  
  - `scripts/ui/services/tooltip_service.gd:1` (`extends CanvasLayer`, sin `layer` explícito)  
  - `scripts/ui/hud/action_prompt_overlay.gd:1` (`extends CanvasLayer`, sin `layer` explícito; además ver duplicación en §4)
- **FullMapLayer** se instancia dentro del HUD (`hud.tscn:141-149`, script `scripts/mapa/full_map_layer.gd`) y hereda el contexto de capa del HUD (mismo `CanvasLayer` padre).

### Hallazgos

| ID | Severidad | Hallazgo | Evidencia (archivo:línea) | Impacto |
|---|---|---|---|---|
| UI-LYR-01 | **Alta** | `UIRoot` (contenedor de capas modales M53) y `HUDScreen` (`scenes/ui/hud.tscn`) comparten `layer = 100`. El orden de dibujo entre HUD y modales queda dependiente del orden en el árbol de escena en lugar de una jerarquía explícita de capas. | `scripts/ui/ui_root.gd:13,36`; `scenes/ui/hud.tscn:14-16`; `scenes/main_island.tscn:170` | Riesgo de HUD por encima de modales o inconsistencias visuales entre escenas (diálogos/pausa/inventario tapados por HUD o viceversa). |
| UI-LYR-02 | **Media** | Servicios/overlays `CanvasLayer` (`NotificationService`, `TooltipService`, `ActionPromptOverlay` de `hud/`) no establecen `layer` explícito; su z-order relativo frente a HUD/UIRoot depende de defaults y orden de montaje/autoload. | `scripts/ui/services/notification_service.gd:1-35`; `scripts/ui/services/tooltip_service.gd:1-35`; `scripts/ui/hud/action_prompt_overlay.gd:1-24` | Tooltips/notificaciones/prompts pueden quedar detrás de modales o delante del HUD de forma no determinista según escena/carga. |
| UI-LYR-03 | **Baja** | `FullMapLayer` vive dentro del mismo `CanvasLayer` del HUD (`hud.tscn:141-149`), no en una capa modal dedicada con prioridad propia. | `scenes/ui/hud.tscn:14-16,141-149` | Complica garantizar que el mapa completo se renderice siempre sobre HUD pero bajo/según política respecto a modales del framework. |

---

## 4) Señales de UI sin conexión o con doble conexión

### Evidencia revisada
- **Conexiones con guarda (`is_connected`) presentes:**  
  - `ui_manager.gd:207-208` (`PauseLayer.continuar_pedido`), `575-576` (`locale_changed`)  
  - `dialog_layer.gd:44-49,55-58` (DialogueManager/EventBus)  
  - `pause_layer.gd:154-157,202-205` (SaveManager)  
  - `menus_layer.gd:114-115` (`control_changed`)  
  - `settings_audio_layer.gd:478-483` (desconexión defensiva)  
  - `hud_screen.gd:117,125,132` (guard temprano parcial)  
  - `overlays/subtitulo_overlay.gd:93-94`
- **Conexiones sin guarda (potencial doble conexión si el nodo persiste/reusa):**  
  - `ui_manager.gd:52,54,58,62,64,66,70,537`  
  - `hud_screen.gd:119-121,127-128,134` (tras guard por grupo, pero no por callback individual)  
  - `equipment_layer.gd:32-33,130`  
  - `inventory_layer.gd:52,54,56`  
  - `services/tooltip_service.gd:114`  
  - `services/notification_service.gd:42`  
  - `theme/theme_service.gd:23,27`
- **UIManager conecta señales propias internas al mismo callback:** `ui_manager.gd:64,66` (`ui_focus_moved` → tooltip y hover sound). Si `_ready` se ejecutara más de una vez en la vida del autoload/instancia, duplicaría efectos (hoy singleton reduce riesgo, pero el patrón no es idempotente).

### Hallazgos

| ID | Severidad | Hallazgo | Evidencia (archivo:línea) | Impacto |
|---|---|---|---|---|
| UI-SIG-01 | **Crítica** | Duplicación de `ActionPromptOverlay` con el mismo `class_name` en dos rutas distintas (`scripts/ui/widgets/action_prompt_overlay.gd` y `scripts/ui/hud/action_prompt_overlay.gd`). `hud.tscn` instancia el script de `widgets/` y además declara `extends CanvasLayer`, incompatible con un script que extiende `Control` (`widgets`). | `scripts/ui/widgets/action_prompt_overlay.gd:1` (`extends Control`, `class_name ActionPromptOverlay`); `scripts/ui/hud/action_prompt_overlay.gd:1,3` (`extends CanvasLayer`, `class_name ActionPromptOverlay`); `scenes/ui/hud.tscn:10,113-121` (`ext_resource` a `widgets/...` en nodo `ActionPromptOverlay`) | Colisión de `class_name` global, comportamiento ambiguo de carga/script, y alto riesgo de errores en editor/runtime o de que la escena HUD no refleje la implementación esperada. |
| UI-SIG-02 | **Alta** | `UIManager._on_dialog_requested` usa `push_layer` sobre `DialogLayer`, pero `push_layer` aborta si la capa ya está en `_stack` (capas montadas se registran en `_enter_tree`). El evento no garantiza apertura efectiva y puede dejar el flujo en estado inconsistente. | `scripts/ui/core/ui_manager.gd:222-226,480-486`; `scripts/ui/core/ui_layer.gd:23-28`; `scripts/ui/ui_root.gd:41-45` | Diálogo solicitado por evento puede no mostrarse o no integrarse correctamente a la pila/foco/modalidad según timing. |
| UI-SIG-03 | **Media** | Conexiones sin guarda en autoloads/servicios y capas persistentes (`UIManager`, `HUDScreen`, `EquipmentLayer`, `InventoryLayer`, `TooltipService`, `NotificationService`, `ThemeService`). Varias dependen de que `_ready` ocurra una sola vez. | `scripts/ui/core/ui_manager.gd:52,54,58,62,64,66,70,537`; `scripts/ui/hud/hud_screen.gd:119-121,127-128,134`; `scripts/ui/layers/equipment_layer.gd:32-33,130`; `scripts/ui/layers/inventory_layer.gd:52,54,56`; `scripts/ui/services/tooltip_service.gd:114`; `scripts/ui/services/notification_service.gd:42` | Doble suscripción potencial tras reinstanciación/reload, callbacks duplicados, refrescos dobles o fugas de señales en escenarios no-singleton/test. |
| UI-SIG-04 | **Media** | `DialogLayer` mantiene dos contratos de entrada (DialogueManager directo + EventBus) y modifica visibilidad/pausa en ambos caminos sin mediación única. No se observó desconexión simétrica en cierre/desmontaje. | `scripts/ui/layers/dialog_layer.gd:41-58,243-251,255-260,280-291,322-330,349-353` | Riesgo de estados duplicados (pausa/reloj/visibilidad) y dificultad para garantizar una sola fuente de verdad del ciclo de diálogo. |
| UI-SIG-05 | **Baja** | `PauseLayer` reconecta `save_completed/save_failed` al abrir confirmación de guardado y también al abrir la capa; las guardas evitan duplicado inmediato, pero la estrategia de conexión está distribuida en múltiples puntos (`_conectar_guardar_dirty`, `_ejecutar_guardado_manual`). | `scripts/ui/layers/pause_layer.gd:142-159,201-207` | Mantenibilidad baja y riesgo de regresión si se elimina alguna guarda en futuros cambios. |

---

## Priorización recomendada

1. **Crítica/Alta (corregir primero):** UI-SIG-01, UI-SIG-02, UI-DLG-01, UI-LYR-01.  
2. **Media:** UI-DLG-02, UI-DLG-03, UI-SIG-03, UI-SIG-04, UI-LYR-02.  
3. **Baja/Informativa:** UI-SIG-05, UI-LYR-03, UI-MF-02, UI-MF-01.

---

## 2 mejoras de diseño concretas (con código)

### Mejora 1 — Unificar apertura/cierre de `DialogLayer` a través de `UIManager` (una sola ruta)

**Problema que ataca:** UI-DLG-02, UI-DLG-03, UI-SIG-02.  
**Objetivo:** evitar que `DialogLayer`, `DialogueManager` y `UIManager` compitan por visibilidad/pila; hacer idempotente la apertura por evento.

```gdscript
# game/isla-ancestral/scripts/ui/core/ui_manager.gd
# Nueva API explícita para capas ya registradas (montadas por UIRoot).
func open_registered_layer(layer_name: String) -> Node:
	var layer := _buscar_capa(layer_name)
	if layer == null:
		return null
	# Garantiza registro en stack aunque algún flujo la haya des-registrado.
	if not (layer in _stack):
		register_layer(layer)
	if layer.has_method("open"):
		layer.open()
	# Sincroniza modal_full aunque se abra por open() directo.
	if _is_modal_full(layer):
		_current_modal_full = layer
	_actualizar_pausa_mundo()
	_log("capa abierta (registered): %s" % layer.name)
	return layer

func close_registered_layer(layer_name: String) -> void:
	var layer := _buscar_capa(layer_name)
	if layer and layer.visible and layer.has_method("close"):
		layer.close()
	_actualizar_pausa_mundo()

func _on_dialog_requested(_npc_id: String, _dialog_data: Dictionary) -> void:
	if open_registered_layer("DialogLayer") == null:
		_log("dialog_requested recibido (sin DialogLayer montado; M21 usa su fallback)")
```

```gdscript
# game/isla-ancestral/scripts/ui/layers/dialog_layer.gd
# La capa pasa a ser "vista" pura: reacciona a DialogueManager,
# delega visibilidad al orquestador y evita tocar UIManager/EventBus por duplicado.

func _on_node_entered(_node_id: String, speaker_key: String, texto: String, tipo: int, options: Array) -> void:
	var ui_mgr := get_node_or_null("/root/UIManager")
	if ui_mgr and ui_mgr.has_method("open_registered_layer"):
		ui_mgr.open_registered_layer("DialogLayer")
	else:
		visible = true
	_pausar_reloj(true)
	# ... render del nodo (speaker, opciones, typing, subtítulos) ...

func _on_dialogue_ended(_id: String, _ultimo: String) -> void:
	var ui_mgr := get_node_or_null("/root/UIManager")
	if ui_mgr and ui_mgr.has_method("close_registered_layer"):
		ui_mgr.close_registered_layer("DialogLayer")
	else:
		visible = false
	_limpiar_opciones()
	_ocultar_subtitulo()
	_pausar_reloj(false)
```

**Beneficio:** un único camino de apertura/cierre (UIManager), menos acoplamiento de `DialogLayer` al bus, y comportamiento consistente de pila/foco/pausa.

### Mejora 2 — Contrato explícito de capas visuales (`CanvasLayer` policy) y eliminación de colisión `ActionPromptOverlay`

**Problema que ataca:** UI-LYR-01, UI-LYR-02, UI-SIG-01.  
**Objetivo:** orden determinista de renderizado y una sola implementación canónica del overlay de prompts.

```gdscript
# game/isla-ancestral/scripts/ui/core/ui_layer_policy.gd (nuevo, autoload/const helper)
class_name UILayerPolicy

const HUD := 100
const WORLD_UI := 110      # etiquetas world-space si aplica
const MODALS := 200        # UIRoot / Dialog / Pause / Inventory / etc.
const TOAST := 300         # NotificationService
const TOOLTIP := 400       # TooltipService
const SYSTEM_OVERLAY := 500 # loading/debug overlays críticos
```

```gdscript
# game/isla-ancestral/scripts/ui/ui_root.gd
func _ready() -> void:
	layer = UILayerPolicy.MODALS
	_build_layers()
```

```gdscript
# game/isla-ancestral/scripts/ui/hud/hud_screen.gd
func _ready() -> void:
	layer = UILayerPolicy.HUD
	# ... resto sin cambios ...
```

```gdscript
# game/isla-ancestral/scripts/ui/services/notification_service.gd
func _ready() -> void:
	layer = UILayerPolicy.TOAST
	_conectar_event_bus()
```

```gdscript
# game/isla-ancestral/scripts/ui/services/tooltip_service.gd
func _ready() -> void:
	layer = UILayerPolicy.TOOLTIP
	# ... timer, conexiones ...
```

```ini
# game/isla-ancestral/scenes/ui/hud.tscn (ajuste de recurso canónico)
# 1) Mantener UNA sola implementación: scripts/ui/widgets/action_prompt_overlay.gd (Control).
# 2) Eliminar/renombrar scripts/ui/hud/action_prompt_overlay.gd o quitarle class_name
#    para evitar colisión global. Si se requiere versión CanvasLayer, usar otro class_name
#    (p.ej. HudActionPromptOverlay) y no compartir identidad con el widget.
# 3) HUDScreen.layer debe ser UILayerPolicy.HUD (100) y UIRoot UILayerPolicy.MODALS (200).
```

**Beneficio:** jerarquía visual determinista (HUD < modales < toasts < tooltips), elimina ambigüedad de `class_name` y reduce errores de montaje/escena por scripts incompatibles.

---

## Notas de alcance y limitaciones

- Auditoría limitada a rutas solicitadas (`scenes/ui/`, `scripts/ui/`) con verificaciones puntuales de dependencias directas (`scripts/dialogos/dialogue_ui.gd`, referencia de `hud.tscn` en escena principal) para confirmar hallazgos de duplicación/orden.
- No se ejecutó Godot ni se validó en runtime; los hallazgos se basan en análisis estático de `.gd`/`.tscn` y búsquedas de patrones.
- Existen dos implementaciones homónimas de `ActionPromptOverlay` en el repositorio (`scripts/ui/widgets/` y `scripts/ui/hud/`); el reporte las trata como señal arquitectónica de duplicación/colisión, no como variantes intencionales verificadas.
