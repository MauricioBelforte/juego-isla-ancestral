# Reporte UI/HUD/Overlays/Menús — Glyph Cluster

- **Fecha:** 2026-11-08
- **Modelo:** Glyph Cluster
- **Plataforma:** Kilo Code
- **Alcance analizado:** `game/isla-ancestral/scripts/ui/` y `game/isla-ancestral/scenes/ui/`
- **Método:** revisión estática de scripts `.gd` y escenas `.tscn` (sin ejecución en runtime).

## 1) Cómo se estructuran las escenas UI

### Arquitectura general
- **Punto de montaje/modal framework:** `scripts/ui/ui_root.gd`
  - `UIRoot` extiende `CanvasLayer` y fija `layer = 100` (`ui_root.gd:14,36`).
  - Monta por código las capas modales/overlays del framework M53: `DialogLayer`, `PauseLayer`, `MenusLayer`, `ConfirmPopup`, `CraftingUI`, `InventoryLayer`, `ShopUI`, `EquipmentLayer`, `DiaryLayer`, `LoadingLayer`, `CreditsLayer`, `SettingsAudioLayer` (`ui_root.gd:39-129`).
  - **Decisión explícita:** no monta widgets HUD aquí; los widgets HUD viven en la escena HUD y/o en otras instancias (`ui_root.gd:16-20`).
- **Orquestador central:** `scripts/ui/core/ui_manager.gd` (autoload esperado `/root/UIManager`)
  - Mantiene pila `_stack` de capas registradas, referencia al HUD (`_hud`), modal full actual (`_current_modal_full`), backup de foco y guard de cierre rápido (`ui_manager.gd:27-36`).
  - Registra capas vía `register_layer` / `unregister_layer` (llamadas desde `UILayer`, `ui_layer.gd:23-40`; `ui_manager.gd:197-219`).
  - Maneja foco, navegación por InputMap, pausa del mundo cuando hay `MODAL_FULL` visible, toggles globales (inventario, equipamiento, HUD, diario), apertura de pausa con `Esc`, tooltips por foco y re-traducción i18n (`ui_manager.gd:38-94,116-192,314-349,571-589`).
- **Clase base de capas:** `scripts/ui/core/ui_layer.gd`
  - `UILayer extends Control` con `@export var layer_type: UILayerType.Type` (default `MODAL_FULL`) (`ui_layer.gd:2,15`).
  - Se auto-registra/des-registra en `UIManager` al entrar/salir del árbol (`ui_layer.gd:23-40`).
  - `open()/close()` controlan visibilidad y hooks `on_layer_opened/on_layer_closed`; notifica visibilidad para pausa del mundo (`ui_layer.gd:30-61`).
- **Tipos de capa:** `scripts/ui/core/ui_layer_type.gd`
  - Enum `HUD`, `MODAL_SIMPLE`, `MODAL_FULL`, `POPUP` (`ui_layer_type.gd:10-19`).

### Escena HUD
- `scenes/ui/hud.tscn` define un `CanvasLayer` raíz `HUDScreen` (`layer = 100`, script `hud_screen.gd`) con contenedores de layout (`TopLeft`, `TopRight`, `TopCenter`, `BottomCenter`, `CenterBottom`, `BottomRight`) y widgets: `StatusBar`, `ClockWidget`, `SeasonWidget`, `ResourceCounter`, `HotbarWidget`, `InteractPrompt`, `ActionPromptOverlay`, `MinimapWidget`, `FullMapLayer` (`hud.tscn:1-149`).
- `scripts/ui/hud/hud_screen.gd` registra el HUD en `UIManager`, refresca widgets a baja frecuencia (timer 0.5s) y reacciona a `EventBus` (inventario, calendario, economía) (`hud_screen.gd:31-177`).

### Capas modales (ejemplos revisados)
- `PauseLayer` y `MenusLayer`: `MODAL_FULL`, construyen UI por código, gestionan foco y señales (`pause_layer.gd:27-141`; `menus_layer.gd:20-124`).
- `DialogLayer`: **`MODAL_SIMPLE`** (pausa reloj/mundo visible según diseño), integra `DialogueManager` y `EventBus`, incluye typing effect y subtítulos (`dialog_layer.gd:32-354`).
- `InventoryLayer`: **`MODAL_FULL`** (pausa total/bloqueo mundo), toggle por acción, drag/swap, filtros, descarte con confirmación (`inventory_layer.gd:41-463`).
- `LoadingLayer`: `MODAL_FULL`, progreso suavizado y tips (`loading_layer.gd:30-166`).
- `ConfirmPopup`: `POPUP`, superpuesto con OK/Cancelar (`confirm_popup.gd:19-106`).

## 2) Problemas de `mouse_filter` que puedan bloquear clicks

### Hallazgos
- **HUD (escena):** todos los contenedores y widgets visibles del HUD están en `mouse_filter = 2` (`MOUSE_FILTER_IGNORE`) en `scenes/ui/hud.tscn` (líneas 24,29,40,45,52,64,69,84,89,105,110,120,133,138,148). Esto es correcto para un HUD informativo: **no debería bloquear clicks** del mundo/capas interactivas.
- **Fondos decorativos/dimmers en capas:** varios fondos usan `MOUSE_FILTER_IGNORE` (ej. `dialog_layer.gd:126`, `pause_layer.gd:37`, `inventory_layer.gd:64`, `equipment_layer.gd:44`, `diary_layer.gd:120`, `credits_layer.gd:77`, `subtitulo_overlay.gd:38,45`). Esto permite que el input pase; en capas modales, el bloqueo real depende más de que la capa esté visible, reciba input y/o del manejo de pausa/foco que de un dimmer “stop”.
- **Widgets/overlays no interactivos:** `interact_prompt` se oculta/muestra pero no define `mouse_filter` explícito en código; su nodo en escena HUD sí es `IGNORE` (`hud.tscn:110`). `action_prompt_overlay.gd:88` y minimapa (`widgets/minimap_widget.gd`) usan `IGNORE` para elementos gráficos, lo cual evita bloquear clicks.
- **UIRoot helper:** `_agregar_widget_hud` fuerza `MOUSE_FILTER_IGNORE` si el widget es `Control` (`ui_root.gd:136-144`) — coherente con HUD no interactivo.

### Riesgos/observaciones
- **Riesgo de clicks “atravesando” un modal si el modal depende solo del dimmer:** en `DialogLayer`, `PauseLayer`, `InventoryLayer`, `EquipmentLayer` el `ColorRect` de fondo está en `IGNORE` (`dialog_layer.gd:126`, `pause_layer.gd:37`, `inventory_layer.gd:64`, `equipment_layer.gd:44`). Si algún control raíz del modal no consume input, clics podrían llegar a elementos debajo (según árbol/visibilidad). No se observa en esta revisión un `mouse_filter = STOP` explícito en el `PanelContainer`/raíz de esas capas; conviene verificar en runtime.
- **`ConfirmPopup` (POPUP):** no crea dimmer; su panel se centra (`confirm_popup.gd:26-66`). Al ser popup, puede ser aceptable, pero sin un backdrop que consuma clicks, el usuario podría interactuar con UI subyacente si el flujo no lo previene.

**Conclusión (mouse_filter):** no se detectan bloqueos evidentes del HUD (está en `IGNORE`). El patrón dominante es seguro para HUD, pero hay **posible permeabilidad de clicks en modales/popups** por falta de un backdrop/raíz con `MOUSE_FILTER_STOP` explícito; requiere validación en runtime.

## 3) Nodos `CanvasLayer` con orden incorrecto que cubran botones

### Hallazgos
- `UIRoot` (`CanvasLayer`) usa `layer = 100` (`ui_root.gd:36`).
- `HUDScreen` (`CanvasLayer`) usa `layer = 100` (`hud.tscn:15`).
- `LoadingLayer` es una capa lógica `UILayer` (Control) montada como hija de `UIRoot` (`ui_root.gd:108-112`) y su `layer_type` es `MODAL_FULL` (`loading_layer.gd:31`); al ser hija del mismo `CanvasLayer` (UIRoot, layer 100), su orden visual depende del orden de hijos, no de un `CanvasLayer.layer` propio.
- Servicios como `NotificationService` y `TooltipService` extienden `CanvasLayer` (`notification_service.gd:1-2`, `tooltip_service.gd:1-2`) pero su `layer` no se establece en los archivos leídos; si se instancian como autoloads o nodos con layer por defecto, podrían quedar debajo/encima según configuración de escena/proyecto.

### Riesgos/observaciones
- **Conflicto potencial HUD vs UIRoot (mismo layer 100):** si `HUDScreen` y `UIRoot` coexisten en la misma escena/árbol con `layer = 100`, el orden de dibujo entre ambos `CanvasLayer` puede depender del orden en el árbol. Esto puede causar que un modal montado en `UIRoot` quede **debajo** de elementos HUD o viceversa. El HUD usa `mouse_filter=IGNORE` (mitiga bloqueo de input), pero visualmente puede tapar o ser tapado inesperadamente.
- **`FullMapLayer` dentro del HUD** (`hud.tscn:141-149`, `mouse_filter=2`) es un `Control` a pantalla completa dentro del `CanvasLayer` HUD; si se hace visible/interactivo en el futuro sin ajustar filtros/orden, podría interferir con UI modal.
- **`SettingsAudioLayer` se monta al final** en `UIRoot` para dibujarse sobre pausa/menús (`ui_root.gd:121-129`) — buena práctica de orden dentro del mismo padre.

**Conclusión (orden de capas):** no hay evidencia directa de botones cubiertos en el código estático, pero **`UIRoot` y `HUDScreen` comparten `layer = 100`**, lo que es un riesgo de z-order/solapamiento entre HUD y framework modal según composición de la escena principal.

## 4) Elementos UI que no se actualizan correctamente

### Hallazgos/posibles problemas
- **Inconsistencia de `process_mode` entre `UILayer` y `UIManager`:**
  - `UILayer._apply_process_mode()` asigna `WHEN_PAUSED` a `MODAL_SIMPLE`/`MODAL_FULL` y `ALWAYS` a HUD/POPUP (`ui_layer.gd:82-92`).
  - `UIManager._apply_process_mode()` asigna `ALWAYS` a todos los tipos (`ui_manager.gd:426-441`) y además pausa/reanuda el mundo con `get_tree().paused` según visibilidad de `MODAL_FULL` (`ui_manager.gd:79-94,330-349`).
  - La nota en `ui_layer.gd:30-34` y el diseño de `ui_manager.gd:440-441` sugieren que el modelo actual es “UI siempre procesa, mundo se pausa por árbol”. Si `UILayer.open()` reaplica `WHEN_PAUSED` (`ui_layer.gd:48-49,82-92`) en un momento donde el árbol no está pausado como se espera, o si hay carreras, podrían aparecer capas que no responden a input o no se refrescan. **Es un riesgo de coherencia de estado.**
- **`HUDScreen` refresca reloj/estación por timer solo cuando visible** (`hud_screen.gd:37-44,58-62,163-166`), pero el timer corre a 2 Hz; cambios event-driven también existen (`_on_day_started/_on_season_changed`). Correcto en general; si el HUD se oculta/muestra rápido, el estado intermedio depende de `force_refresh()` al mostrar.
- **`MenusLayer` no usa el patrón `UiI18n.meta_texto`/metadatos i18n en sus labels/botones** (`menus_layer.gd:43-72,67-72` usa `_t()` directo al crear). `UIManager` retraduce nodos con metadatos `text_key/tooltip_text_key` vía `UiI18n.retraducir()` al cambiar locale (`ui_manager.gd:571-589`; `ui_i18n.gd:59-84`). Por tanto, **el menú principal puede no re-traducirse en caliente** al cambiar idioma, a diferencia de `PauseLayer`/`EquipmentLayer`/otros que sí usan `UiI18n.meta_texto`.
- **`InteractPrompt` establece texto inicial con `UiI18n.meta_texto` (`interact_prompt.gd:94`)**, pero cuando muestra prompts dinámicos usa `show_prompt(message)` y sobrescribe `_label.text` (`interact_prompt.gd:32-41`). Si el sistema espera re-traducción automática del mensaje contextual, habría que re-aplicar clave o traducir en el caller.
- **`NotificationService` posiciona toasts usando `node.size` tras añadir (`notification_service.gd:133,178-185`)**; en el mismo frame el tamaño puede no estar actualizado, causando solapamientos o posiciones incorrectas hasta el siguiente reposicionado/fade. Riesgo menor de actualización visual.
- **`TooltipService` también posiciona con `get_minimum_size()`/`size` (`tooltip_service.gd:158-166`)**; puede requerir ajuste diferido en algunos casos de layout.

## 5) Dos mejoras sugeridas

1. **Unificar la política de `process_mode` y añadir “backdrop bloqueante” en modales**
   - **Problema:** doble fuente de verdad (`UILayer` vs `UIManager`) para `process_mode` y dimmers con `MOUSE_FILTER_IGNORE` en capas modales.
   - **Acción:** definir una sola política (p. ej. UI `PROCESS_MODE_ALWAYS` + pausa del mundo por `UIManager`, coherente con `ui_manager.gd:440-441` y `ui_layer.gd:30-34`) y eliminar/asignar explícitamente la lógica contradictoria en `UILayer._apply_process_mode()` (`ui_layer.gd:82-92`). Añadir en modales/popups críticos un `Control`/`ColorRect` a pantalla completa con `mouse_filter = MOUSE_FILTER_STOP` (o asegurar que el root consume clicks) para evitar interacción con UI subyacente.
   - **Impacto:** menos bugs de input congelado/click-through y comportamiento consistente al pausar.

2. **Estandarizar i18n reactivo y orden de `CanvasLayer` del HUD**
   - **Problema:** `MenusLayer` construye textos con `_t()` sin metadatos `text_key` (`menus_layer.gd:44,61-72`), por lo que puede no actualizarse con `locale_changed` vía `UIManager/UiI18n`. Además, `HUDScreen` y `UIRoot` comparten `layer = 100` (`hud.tscn:15`, `ui_root.gd:36`), con riesgo de solapamiento según el árbol.
   - **Acción:** migrar labels/botones del menú a `UiI18n.meta_texto`/metadatos (patrón ya usado en `PauseLayer`, `EquipmentLayer`, `InteractPrompt`) y conectar actualización dinámica donde haga falta. Separar explícitamente los `CanvasLayer.layer` (ej. HUD < overlays/modales, o documentar el orden de instanciación) para garantizar que menús/pausa/loading no queden visualmente detrás del HUD.
   - **Impacto:** cambio de idioma consistente en todas las capas y jerarquía visual predecible.

## Conclusión final
La UI está organizada con un **framework claro** (`UIRoot` + `UIManager` + `UILayer` + `UILayerType`) y una escena HUD separada con widgets mayormente no interactivos (`mouse_filter=IGNORE`). No se observan bloqueos obvios de clicks causados por el HUD. Los riesgos principales detectados en revisión estática son: **(1)** posible permeabilidad de clicks en modales/popups por dimmers/raíces sin `STOP` explícito, **(2)** **colisión de orden** al compartir `CanvasLayer.layer = 100` entre HUD y UIRoot, **(3)** **inconsistencia de `process_mode`** entre `UILayer` y `UIManager`, y **(4)** **re-traducción incompleta** en `MenusLayer` por no usar metadatos i18n. Las dos mejoras priorizadas son unificar input/pausa + backdrop bloqueante, y estandarizar i18n reactivo junto con una jerarquía de `CanvasLayer` explícita. Se recomienda validar estos puntos en runtime con `Esc`/diálogo/inventario/menú, cambio de idioma y clicks sobre modales.
