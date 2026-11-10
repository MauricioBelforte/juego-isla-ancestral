# Reporte UI/HUD — Glyph Cluster

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (Agent Manager)  
**Fecha:** 2026-11-09  
**Alcance:** `game/isla-ancestral/scripts/ui/`, `scripts/ui/hud/`, escenas UI relacionadas y módulos UI satélite (`scripts/clock/reloj_hud.gd`, `scripts/dialogos/ui/`, `scripts/shops/shop_ui.gd`, `scripts/crafting/crafting_ui.gd`, `scripts/debug/debug_menu*.gd`, `scripts/viajes/travel_ui.gd`).

## Resumen ejecutivo

El framework UI principal (M53) está centralizado en `UIRoot` + `UIManager` + `UILayer`/`UILayerType`, con capas modales registradas dinámicamente y un HUD basado en `CanvasLayer`. La arquitectura es razonable, pero hay **riesgos de input/clicks** por mezcla de patrones (`CanvasLayer` de overlay vs `UILayer` de pila), **posibles conflictos de orden de dibujo** (HUD y UIRoot en `layer = 100`), **duplicación de componentes** (`action_prompt_overlay`/widgets en `hud/` y `widgets/`), y **nodos UI sin integración clara al framework** o con comportamiento inconsistente (ej. prompts HUD sin `mouse_filter` explícito, overlays que no usan `UILayer`, `InteractPrompt` con visibilidad interna no sincronizada al abrir). No se encontraron usos de `MOUSE_FILTER_STOP` en `scripts/ui/` (búsqueda sin resultados), lo que sugiere que el bloqueo de clicks no proviene de stops explícitos sino de estructura/capas/orden.

---

## 1) ¿Cómo se gestionan los nodos UI?

### Núcleo del framework
- **`game/isla-ancestral/scripts/ui/ui_root.gd`** (clase `UIRoot`, `extends CanvasLayer`)
  - `layer = 100` en `_ready()` (línea ~26).
  - Monta capas modales en `_build_layers()` (líneas ~29–105): `DialogLayer`, `PauseLayer`, `MenusLayer`, `ConfirmPopup`, `CraftingUI`, `InventoryLayer`, `ShopUI`, `EquipmentLayer`, `DiaryLayer`, `LoadingLayer`, `CreditsLayer`, `SettingsAudioLayer`.
  - Carga scripts con `load(...)` y hace `add_child(...)` dinámico; no instancia desde `.tscn` para estas capas.
  - Conecta señales de menú/pausa/ajustes a `GameFlowManager`, `ConfirmPopup`, `UIManager` y capas de settings (líneas ~113–220 aprox.).

- **`game/isla-ancestral/scripts/ui/core/ui_manager.gd`** (autoload/orquestador, `extends Node`)
  - Mantiene pila `_stack`, foco `_focus_backup`, HUD `_hud`, modal full actual `_current_modal_full`, guard `_closing` (líneas ~24–40).
  - API: `register_layer/unregister_layer`, `push_layer/pop_layer/close_top`, `register_hud/set_hud_visible`, `open_confirm`, navegación por input (`_unhandled_input`), pausa del mundo (`_actualizar_pausa_mundo`) cuando hay `MODAL_FULL` visible (líneas ~100–520+).
  - Usa constantes de tipo de capa (`LAYER_HUD/MODAL_SIMPLE/MODAL_FULL/POPUP`) y duck-typing (`layer.get("layer_type")`).
  - Busca capas por nombre con `_buscar_capa/_buscar_nodo` (recorrido de árbol/pila).

- **`game/isla-ancestral/scripts/ui/core/ui_layer.gd`** (clase base `UILayer`, `extends Control`)
  - Exporta `layer_type` (default `MODAL_FULL`).
  - Se registra/desregistra en `UIManager` en `_enter_tree/_exit_tree` (líneas ~18–35).
  - Notifica cambios de visibilidad para pausa del mundo (`NOTIFICATION_VISIBILITY_CHANGED` → `_actualizar_pausa_mundo`).
  - `open()/close()` manejan visibilidad, process mode y hooks virtuales `on_layer_opened/on_layer_closed`.
  - `focus_first()` busca primer control enfocable.

- **`game/isla-ancestral/scripts/ui/core/ui_layer_type.gd`**
  - Enum `Type { HUD, MODAL_SIMPLE, MODAL_FULL, POPUP }`.

### HUD
- **`game/isla-ancestral/scripts/ui/hud/hud_screen.gd`** (`extends CanvasLayer`, `class_name HUDScreen`)
  - Referencias `@onready` a widgets (`%StatusBar`, `%ClockWidget`, etc.), timer de refresh 2 Hz, suscripción a `EventBus` (inventario/calendario/economía), registro en `UIManager.register_hud()` (líneas ~24–140).
  - Controla visibilidad del HUD con `set_hud_visible`.

- **`game/isla-ancestral/scenes/ui/hud.tscn`**
  - Nodo raíz `HUDScreen` tipo `CanvasLayer`, **`layer = 100`** (líneas ~14–16).
  - Contenedores/wrappers y widgets con **`mouse_filter = 2` (`MOUSE_FILTER_IGNORE`)** de forma consistente (múltiples nodos; ver sección 2).
  - Incluye `FullMapLayer` (`res://scripts/mapa/full_map_layer.gd`) como `Control` hijo con `mouse_filter = 2`.

### Servicios/overlays UI
- **`notification_service.gd`** y **`tooltip_service.gd`** extienden `CanvasLayer` (servicios visuales); se integran por señales/EventBus o llamadas directas.
- **`subtitulo_overlay.gd`** es `Control` con `mouse_filter = MOUSE_FILTER_IGNORE` en `_ready()` (líneas ~38, ~45).
- Existen capas/overlays de otros dominios montados o usados fuera de `scripts/ui/` pero relacionados (crafting, shop, travel, debug menu, diálogo M21 fallback en `scripts/dialogos/ui/dialogue_ui.gd`).

### Conclusión de gestión
El patrón esperado es: **`UIRoot` (CanvasLayer) monta `UILayer`s (Controls)** y `UIManager` orquesta pila/foco/pausa; el **HUD** es un `CanvasLayer` aparte registrado en `UIManager`. Sin embargo, coexisten componentes fuera de ese patrón (overlays `CanvasLayer`, duplicados hud/widgets, scripts UI satélite), lo que aumenta el riesgo de inconsistencias de input y orden.

---

## 2) ¿Hay problemas de `mouse_filter` que bloqueen clicks?

### Hallazgos positivos (mitigan bloqueo)
- **HUD scene (`scenes/ui/hud.tscn`)**: prácticamente todos los nodos UI del HUD declaran `mouse_filter = 2` (IGNORE), incluyendo contenedores y `FullMapLayer`. Esto es correcto para un HUD no interactivo que no debe comer clicks del mundo.
- **Overlays no interactivos**: `subtitulo_overlay.gd:38,45` y `widgets/action_prompt_overlay.gd:88` usan `MOUSE_FILTER_IGNORE`.
- **Minimap visual**: `widgets/minimap_widget.gd` configura `MOUSE_FILTER_IGNORE` en elementos dibujados (líneas detectadas: 190,199,210,217,263,271,278,285,323,351).
- **Fondos/dimmers de capas modales**: varios usan `MOUSE_FILTER_IGNORE` en el dim (`dialog_layer.gd:126`, `diary_layer.gd:120`, `equipment_layer.gd:44`, `inventory_layer.gd:64`, `pause_layer.gd:37`, `credits_layer.gd:77`). Esto **puede ser intencional** si se quiere que el dim no capture clicks, pero ver riesgos abajo.
- **`UIRoot._agregar_widget_hud`** fuerza `MOUSE_FILTER_IGNORE` para widgets HUD añadidos por código (línea ~109).

### Riesgos / problemas potenciales
1. **Dimmer modal con `MOUSE_FILTER_IGNORE` (riesgo de click-through)**
   - Archivos/líneas: `scripts/ui/layers/dialog_layer.gd:126`, `diary_layer.gd:120`, `equipment_layer.gd:44`, `inventory_layer.gd:64`, `pause_layer.gd:37`, `credits_layer.gd:77`.
   - **Riesgo:** si el contenedor padre de la capa no consume input, los clicks podrían atravesar el fondo hacia controles del mundo/HUD subyacente mientras el modal está abierto. En Godot, un modal fullscreen suele necesitar que el fondo o un `Control` de bloqueo use `MOUSE_FILTER_STOP` (o que el layout/panel capture). Aquí no se observan `MOUSE_FILTER_STOP` en `scripts/ui/**` (búsqueda sin resultados).
   - **Impacto:** clicks “fantasma” en gameplay/cámara/interactuables durante menús/diálogos/inventario, dependiendo del árbol final y de qué nodo recibe el evento.

2. **`InteractPrompt` HUD sin `mouse_filter` explícito**
   - `scripts/ui/hud/interact_prompt.gd`: extiende `Control`, alterna `visible` (`_modificar_visibilidad`) pero **no establece `mouse_filter`**. En `.tscn` su wrapper/nodo tiene `mouse_filter = 2`, pero el script no lo refuerza; si se instancia fuera de la escena, podría quedar con el default (`STOP` en algunos `Control`s según contexto/propiedades) y bloquear clicks en el área central inferior.
   - `scripts/ui/widgets/interact_prompt.gd` (duplicado funcional, ver punto 4) también debe revisarse por consistencia.

3. **Ausencia total de `MOUSE_FILTER_STOP` en `scripts/ui/`**
   - La búsqueda no encontró `MOUSE_FILTER_STOP`. Para UIs modales, esto puede ser válido solo si los paneles/botones capturan eventos y el árbol está diseñado para no dejar “huecos”. Pero combinado con dimmers en `IGNORE`, es una señal de **diseño frágil de bloqueo de input**.

4. **`ui_feedback.gd` crea `AudioStreamPlayer` (no Control)** — no afecta mouse, pero confirma que no hay manejo de input en servicios (OK).

**Conclusión (2):** No hay evidencia directa de `STOP` bloqueando clicks, pero sí hay **patrón de riesgo**: modales con dimmers `IGNORE` y sin `STOP` explícitos pueden permitir click-through o, según composición, comportamientos inesperados. Requiere validación en runtime con `get_debug_output`/prueba interactiva.

---

## 3) ¿Hay `CanvasLayer` con orden incorrecto?

### Hallazgos
- **`scripts/ui/ui_root.gd:26`**: `layer = 100`.
- **`scenes/ui/hud.tscn:15`**: `HUDScreen` (`CanvasLayer`) `layer = 100`.
- **`scripts/ui/hud/action_prompt_overlay.gd:1`** extiende `CanvasLayer` (implementación simple/stub con `Label`s). Si se instancia en escena, su `layer` por defecto sería `1` salvo que se configure; no se observó su uso en `hud.tscn` (la escena usa `widgets/action_prompt_overlay.gd` como `Control`).
- **Servicios CanvasLayer**: `notification_service.gd` y `tooltip_service.gd` extienden `CanvasLayer` sin `layer` explícito visible en el fragmento leído; su orden relativo frente a HUD/UIRoot/modales depende de cuándo/dónde se instancian.

### Problemas potenciales
1. **Colisión de `layer = 100` entre HUD y UIRoot**
   - `HUDScreen` (`scenes/ui/hud.tscn`) y `UIRoot` (`ui_root.gd`) usan el mismo `layer`. En Godot, nodos en el mismo `CanvasLayer.layer` se dibujan según orden del árbol/escena; esto puede hacer que **modales montados en `UIRoot` queden detrás del HUD** o viceversa, dependiendo de quién se añade primero.
   - **Impacto:** menús/pausa/inventario/confirm podrían aparecer bajo elementos HUD, o el HUD podría tapar prompts/feedback; también afecta percepción de bloqueo aunque `mouse_filter` sea correcto.

2. **`action_prompt_overlay` duplicado con tipos distintos**
   - `scripts/ui/hud/action_prompt_overlay.gd` = `extends CanvasLayer` (stub).
   - `scripts/ui/widgets/action_prompt_overlay.gd` = `extends Control` (implementación completa, device-aware) y es el usado en `hud.tscn` (`ActionPromptOverlay` nodo `Control`).
   - **Riesgo de orden/confusión:** si alguien instancia el stub `CanvasLayer` por error, su `layer` default puede dibujarse en un orden inesperado.

3. **Servicios `NotificationService`/`TooltipService` sin `layer` explícito**
   - Al ser `CanvasLayer`, deberían definir `layer` alto (p. ej. > modales) si deben verse sobre popups/menús, o un valor controlado. No se evidenció configuración; puede causar tooltips/notificaciones ocultas tras capas modales o inconsistentes entre escenas.

**Conclusión (3):** Sí hay **conflicto probable de orden** por `layer = 100` compartido entre HUD y UIRoot. Los overlays/servicios CanvasLayer deberían tener política explícita de `layer`.

---

## 4) ¿Hay nodos sin script que deberían tener interacción?

No se revisaron todas las `.tscn` del proyecto, pero con la evidencia disponible:

- **`scenes/ui/hud.tscn`**: los nodos interactivos esperables del HUD están mayormente como contenedores/controls con scripts de widgets (`status_bar`, `clock_widget`, etc.) o scripts específicos (`full_map_layer`). El HUD es principalmente display; su `mouse_filter = 2` sugiere diseño no interactivo (correcto).
- **Capas modales**: `UIRoot` crea instancias por script (`*.gd`) y las añade; no dependen de nodos `.tscn` huérfanos para la lógica principal. Los botones se crean en código (`PauseLayer`, `MenusLayer`, `ConfirmPopup`, `SettingsAudioLayer`).
- **Posibles casos a verificar (no confirmados como bug sin inspección de escena):**
  - `FullMapLayer` en `hud.tscn` apunta a `res://scripts/mapa/full_map_layer.gd` (fuera de `scripts/ui/`): tiene script, pero su interactividad (zoom/pan/click en marcadores) depende de ese script y de su `mouse_filter`/input; en la escena está en `MOUSE_FILTER_IGNORE`, lo que **impediría interacción** si el mapa completo debe recibir clicks.
  - `scenes/debug/debug_menu.tscn`, previews (`preview_paneles_m53.tscn`, `preview_inventario_s5.tscn`) podrían contener `Button`/controles sin conectar señales si fueron armados parcialmente; requiere inspección puntual si se usan en producción.

**Conclusión (4):** No se identificó un nodo “sin script” obvio en el HUD principal revisado. El riesgo más concreto es **`FullMapLayer` con `mouse_filter=IGNORE` en escena** si se espera interacción (clic/arrastre) en el mapa completo.

---

## 5) Sugerencias de mejora (2)

1. **Normalizar política de input/modal y capas de dibujo**
   - Definir una tabla explícita de `CanvasLayer.layer` (ej. HUD=10, UIRoot/modales=20, tooltips=30, notificaciones=40, debug=50) y aplicarla en `ui_root.gd`, `hud.tscn`, `notification_service.gd`, `tooltip_service.gd`, y cualquier overlay `CanvasLayer`.
   - Para modales fullscreen (`MODAL_FULL`/pausa/inventario/diario), usar un **bloqueador de input** consistente: el fondo/dimmer o un `Control` a pantalla completa con `mouse_filter = MOUSE_FILTER_STOP` cuando la capa está visible, y asegurar que los paneles interactivos sigan recibiendo eventos. Revisar `dialog_layer.gd:126`, `diary_layer.gd:120`, `equipment_layer.gd:44`, `inventory_layer.gd:64`, `pause_layer.gd:37`.
   - Eliminar o aislar stubs duplicados (`scripts/ui/hud/action_prompt_overlay.gd`, `scripts/ui/hud/*_widget.gd` vs `widgets/*`) para evitar instanciación accidental.

2. **Hardenizar integración HUD/UIManager y contratos de widgets**
   - Hacer que `InteractPrompt` (y prompts similares) establezcan `mouse_filter = MOUSE_FILTER_IGNORE` en `_ready()`/escena y sincronicen visibilidad real del nodo con el estado interno (evitar `visible` desfasado).
   - Añadir verificación en runtime (debug): al abrir un modal, loguear `layer`, `mouse_filter` efectivo del dimmer/panel y si `UIManager._actualizar_pausa_mundo()` refleja el estado esperado. Usar `get_debug_output`/MCP Godot cuando corresponda antes de dar por cerrado un fix UI.
   - Documentar en `04-Codigo.md`/guía UI qué nodos deben ser interactivos (`FullMapLayer` si aplica) y ajustar `mouse_filter` por modo (IGNORE en HUD pasivo, STOP/PASS en modo mapa abierto).

---

## Archivos clave analizados (referencia)

- `game/isla-ancestral/scripts/ui/ui_root.gd` (montaje capas, `layer=100`, conexiones menú/pausa/ajustes)
- `game/isla-ancestral/scripts/ui/core/ui_manager.gd` (pila, foco, pausa, input, HUD)
- `game/isla-ancestral/scripts/ui/core/ui_layer.gd` (registro, visibilidad, process mode, pausa)
- `game/isla-ancestral/scripts/ui/core/ui_layer_type.gd` (enum)
- `game/isla-ancestral/scripts/ui/hud/hud_screen.gd` (`CanvasLayer`, refresh, EventBus)
- `game/isla-ancestral/scenes/ui/hud.tscn` (`layer=100`, `mouse_filter=2` general, `FullMapLayer`)
- `game/isla-ancestral/scripts/ui/layers/pause_layer.gd:37` (dim `IGNORE`)
- `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd:126` (dim `IGNORE`)
- `game/isla-ancestral/scripts/ui/layers/diary_layer.gd:120` (dim `IGNORE`)
- `game/isla-ancestral/scripts/ui/layers/equipment_layer.gd:44` (dim `IGNORE`)
- `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd:64` (dim `IGNORE`)
- `game/isla-ancestral/scripts/ui/layers/menus_layer.gd` (modal full, botones por código)
- `game/isla-ancestral/scripts/ui/layers/confirm_popup.gd` (`POPUP`)
- `game/isla-ancestral/scripts/ui/layers/settings_audio_layer.gd` (modal full, debounce)
- `game/isla-ancestral/scripts/ui/hud/interact_prompt.gd` (sin `mouse_filter` explícito)
- `game/isla-ancestral/scripts/ui/widgets/action_prompt_overlay.gd` (Control, `IGNORE`, device-aware)
- `game/isla-ancestral/scripts/ui/hud/action_prompt_overlay.gd` (CanvasLayer stub duplicado)
- `game/isla-ancestral/scripts/ui/services/notification_service.gd` (`CanvasLayer`)
- `game/isla-ancestral/scripts/ui/services/tooltip_service.gd` (`CanvasLayer`)
- `game/isla-ancestral/scripts/ui/overlays/subtitulo_overlay.gd` (`IGNORE`)

## Conclusión final

La UI del proyecto tiene una base sólida (UIManager/UILayer/UIRoot, HUD separado, refresh por eventos/timer), pero presenta **deuda de integración** típica de iteraciones multiagente: **orden de `CanvasLayer` potencialmente conflictivo (HUD/UIRoot en layer 100)**, **modales con dimmers `IGNORE` y sin evidencia de `STOP`** (riesgo de click-through/bloqueo inconsistente), **duplicación de overlays/widgets** y **contratos incompletos en nodos HUD** (`InteractPrompt`, política de `FullMapLayer`). Las dos mejoras prioritarias son: (1) unificar `layer` + bloqueo de input modal, y (2) consolidar componentes duplicados y endurecer `mouse_filter`/contratos de interacción. Se recomienda validar en Godot con `get_debug_output` y prueba manual de clicks bajo pausa, inventario, diálogo y mapa.
