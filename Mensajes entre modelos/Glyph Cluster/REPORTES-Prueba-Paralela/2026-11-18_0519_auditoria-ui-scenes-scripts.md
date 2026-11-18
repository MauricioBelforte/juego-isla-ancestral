# Auditoría de arquitectura UI — `scenes/ui` y `scripts/ui`

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-18 05:19 UTC  
**Alcance:** `game/isla-ancestral/scenes/ui/**`, `game/isla-ancestral/scripts/ui/**`, wiring relevante en `game/isla-ancestral/scripts/main_island.gd` y sistema legado `game/isla-ancestral/scripts/dialogos/ui/dialogue_ui.gd` (por duplicación de diálogo).  
**Método:** inspección estática de `.tscn/.gd` (sin ejecutar Godot, sin modificar código del juego).

> Nota: el workspace no contiene una carpeta raíz `scenes/ui` ni `scripts/ui`; la UI del juego reside en `game/isla-ancestral/scenes/ui/` y `game/isla-ancestral/scripts/ui/`. El script auxiliar `scripts/ui/auditar_ui_m53.py` existe en raíz pero es herramienta de auditoría, no runtime de UI.

## Resumen ejecutivo

- La base M53 (`UIRoot` + `UIManager` + `UILayer`) centraliza capas modales, pero convive con un HUD de escena en el mismo `CanvasLayer.layer` (100), con un sistema de diálogo legado (`DialogueUI`) y con dobles mecanismos de pausa/proceso.
- Se observan riesgos de orden de dibujo entre HUD y framework, inconsistencias de `process_mode`/pausa, y capas que abren/cambian visibilidad sin pasar por la pila del `UIManager`.
- Hay duplicación de componentes homónimos (`action_prompt_overlay` en `hud/` y `widgets/`) y servicios overlay (`NotificationService`, `TooltipService`) sin capa explícita, lo que dificulta razonar el z-order global.

## Hallazgos

### Crítico

1. **Colisión de `CanvasLayer.layer` entre HUD de escena y framework UIRoot (orden de dibujo no determinista funcionalmente).**
   - `game/isla-ancestral/scripts/ui/ui_root.gd:14` — `extends CanvasLayer`
   - `game/isla-ancestral/scripts/ui/ui_root.gd:36` — `layer = 100`
   - `game/isla-ancestral/scenes/ui/hud.tscn:14` — `[node name="HUDScreen" type="CanvasLayer"]`
   - `game/isla-ancestral/scenes/ui/hud.tscn:15` — `layer = 100`
   - `game/isla-ancestral/scripts/main_island.gd:46-50` — registra `$UI` (HUD vivo de escena) en `UIManager.register_hud(...)`
   - `game/isla-ancestral/scripts/main_island.gd:72-78` — monta `UIRoot` como hijo adicional de la escena
   - **Impacto:** HUD y todas las capas modales montadas bajo `UIRoot` comparten la misma capa numérica; el resultado visual entre HUD, diálogos, menús y popups depende del orden de hermanos/árbol y puede invertir prioridad (p.ej. HUD sobre modal o modal bajo elementos HUD).
   - **Accionable:** separar explícitamente bandas de capa (HUD < modales < popups/toasts/tooltips), documentarlas y hacer que `UIRoot`/`HUDScreen` usen valores distintos y estables.

2. **Inconsistencia de `process_mode` entre `UILayer` y `UIManager` bajo pausa global (riesgo de UI congelada o comportamiento divergente).**
   - `game/isla-ancestral/scripts/ui/core/ui_layer.gd:83-93` — `MODAL_SIMPLE` y `MODAL_FULL` se fuerzan a `PROCESS_MODE_WHEN_PAUSED`
   - `game/isla-ancestral/scripts/ui/core/ui_layer.gd:51-57` — `open()` reaplica `_apply_process_mode()` propio
   - `game/isla-ancestral/scripts/ui/core/ui_manager.gd:88-100` — `_actualizar_pausa_mundo()` pausa `get_tree()` cuando hay `MODAL_FULL` visible
   - `game/isla-ancestral/scripts/ui/core/ui_manager.gd:351-368` — `_apply_process_mode(layer)` del manager fuerza todos los tipos a `PROCESS_MODE_ALWAYS`
   - **Impacto:** dos fuentes de verdad compiten por el modo de proceso; dependiendo del orden de llamadas (registro/open/visibilidad), una capa modal puede quedar sin procesar input/foco mientras el árbol está pausado, o procesar cuando no debería.
   - **Accionable:** unificar la política en un solo lugar (preferiblemente `UIManager` + contrato de `UILayer`) y eliminar la doble aplicación; añadir prueba de integración para `MODAL_SIMPLE`/`MODAL_FULL` con `get_tree().paused`.

### Alto

3. **Sistema de diálogo duplicado: `DialogLayer` (M53) vs `DialogueUI` legado (M21) con contratos y contenedores distintos.**
   - `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd:5-15` — capa formal M53 que escucha `DialogueManager` y se integra al framework
   - `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd:32-36` — definida operativamente como `MODAL_SIMPLE` (corrige inversión previa)
   - `game/isla-ancestral/scripts/dialogos/ui/dialogue_ui.gd:5-8,19-20` — UI programática autocontenida `extends CanvasLayer`, `layer = 15`, flujo propio de tipeo/paginado/input
   - `game/isla-ancestral/scripts/dialogos/ui/dialogue_ui.gd:119` — `layer = 15`
   - `game/isla-ancestral/scripts/main_island.gd:116-124` — usa `DialogLayer` vía `UIRoot` si carga; solo monta `DialogueUI` como fallback si `ui_root.gd` falla
   - `game/isla-ancestral/scripts/ui/ui_root.gd:10-11` — declara convivencia/fallback entre ambos enfoques
   - **Impacto:** dos implementaciones con UX, input handling, localización y semántica de pausa distintas; mantenimiento doble y riesgo de regresiones al corregir una sola. El legado opera fuera de la pila M53 (sin `UILayer`, sin registro/foco estándar).
   - **Accionable:** definir un único runtime canónico, deprecar/eliminar fallback progresivamente y migrar tests/herramientas al contrato del sistema elegido.

4. **`DialogLayer` reacciona a señales y se hace visible sin flujo explícito de apertura por pila en todos los caminos.**
   - `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd:41-67` — se suscribe en `_ready()` a `DialogueManager` y `EventBus.ui.dialog_requested/dialog_finished`
   - `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd:132-149,235-243,287-291` — callbacks fijan `visible = true/false` y gestionan reloj/subtítulos directamente
   - `game/isla-ancestral/scripts/ui/core/ui_manager.gd:201-212,481-487` — `register_layer` apila al entrar al árbol; `dialog_requested` del manager intenta `push_layer` si encuentra `DialogLayer`
   - **Impacto:** coexistencia de control por visibilidad directa y por pila puede desincronizar foco, backup/restauración y reglas de "top visible"; difícil garantizar que el diálogo sea siempre la capa modal efectiva.
   - **Accionable:** centralizar apertura/cierre en `UIManager`/`UILayer` (`open/close/push/pop`) y que las señales solo disparen ese flujo.

5. **`ConfirmPopup` (POPUP) no se integra realmente como popup gestionado: se muestra por visibilidad directa, sin backdrop bloqueante.**
   - `game/isla-ancestral/scripts/ui/layers/confirm_popup.gd:20-23` — tipo `POPUP`, `_ready` crea UI y oculta
   - `game/isla-ancestral/scripts/ui/layers/confirm_popup.gd:25-66` — UI centrada sin `ColorRect`/scrim de bloqueo
   - `game/isla-ancestral/scripts/ui/layers/confirm_popup.gd:69-79,81-90` — `configurar/configurar_texto` hacen `visible = true` y `grab_focus()` sin `open()` ni `push_layer`
   - `game/isla-ancestral/scripts/ui/ui_root.gd:77-83` — se instancia y añade, pero no hay conexión equivalente a push/pop para el popup
   - **Impacto:** el popup puede no quedar correctamente representado en la pila/foco/modalidad; clics fuera del panel pueden interactuar con controles subyacentes según layout.
   - **Accionable:** añadir scrim opcional/configurable con `mouse_filter` bloqueante cuando se requiera confirmación modal, y abrir/cerrar vía API unificada del `UIManager`.

6. **Mecanismos de pausa duplicados en inventario (UIManager/UILayer vs lógica propia).**
   - `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd:45` — `layer_type = UILayerType.Type.MODAL_FULL`
   - `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd:357-366` — `toggle()` llama `_freeze_world(true/false)`
   - `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd:374-384` — `_freeze_world()` pausa `GameTime` y notifica `UIManager.set_world_frozen` (si existiera)
   - `game/isla-ancestral/scripts/ui/core/ui_manager.gd:88-100` — el manager ya pausa/reanuda el árbol según modales visibles
   - **Impacto:** múltiples rutas para congelar estado pueden producir estados pegados (mundo pausado tras cerrar, o reanudado prematuramente) y dificultan depurar ownership de la pausa.
   - **Accionable:** definir una única autoridad de pausa (UIManager/GameTime bridge) y que las capas solo declaren intención/modalidad.

### Medio

7. **Servicios overlay sin `layer` explícito (posible solapamiento impredecible con framework/HUD).**
   - `game/isla-ancestral/scripts/ui/services/notification_service.gd:1` — `extends CanvasLayer` (sin `layer = ...`)
   - `game/isla-ancestral/scripts/ui/services/tooltip_service.gd:1` — `extends CanvasLayer` (sin `layer = ...`)
   - `game/isla-ancestral/scripts/ui/ui_root.gd:36` — framework en `layer = 100`
   - **Impacto:** valor por defecto de capa puede dejar toasts/tooltips detrás de modales o detrás de HUD según montaje; comportamiento dependiente del orden de autoload/escena.
   - **Accionable:** asignar capas explícitas (p.ej. tooltip > popup > modal > HUD) y documentar la tabla de capas.

8. **Duplicación/confusión de `ActionPromptOverlay` con mismo nombre conceptual en dos rutas.**
   - `game/isla-ancestral/scripts/ui/widgets/action_prompt_overlay.gd:1-2` — `extends Control`, `class_name ActionPromptOverlay`, implementación rica (dispositivo/remapeo)
   - `game/isla-ancestral/scripts/ui/hud/action_prompt_overlay.gd:1-2` — `extends CanvasLayer`, sin `class_name`, implementación simple por labels
   - `game/isla-ancestral/scenes/ui/hud.tscn:10,113-122` — la escena HUD usa el script de `widgets/`
   - **Impacto:** ambigüedad para futuros cambios/instanciación, riesgo de editar el archivo equivocado y dejar código muerto o divergente.
   - **Accionable:** consolidar en una sola implementación/carpeta canónica y eliminar o renombrar claramente la variante obsoleta.

9. **`mouse_filter = IGNORE` en dimmers de capas modales (bloqueo de interacción dependiente de otros nodos).**
   - `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd:126` — `dim.mouse_filter = Control.MOUSE_FILTER_IGNORE`
   - `game/isla-ancestral/scripts/ui/layers/pause_layer.gd:37` — `dim.mouse_filter = Control.MOUSE_FILTER_IGNORE`
   - `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd:64` — `dim.mouse_filter = Control.MOUSE_FILTER_IGNORE`
   - `game/isla-ancestral/scripts/ui/layers/equipment_layer.gd:44` — `dim.mouse_filter = Control.MOUSE_FILTER_IGNORE`
   - `game/isla-ancestral/scripts/ui/layers/diary_layer.gd:120` — `dim.mouse_filter = Control.MOUSE_FILTER_IGNORE`
   - `game/isla-ancestral/scripts/ui/layers/credits_layer.gd:77` — `_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE`
   - **Impacto:** el oscurecido visual no garantiza bloqueo de input; si no hay otro control capturando eventos, clics/hover pueden atravesar al contenido inferior.
   - **Accionable:** usar `MOUSE_FILTER_STOP` en scrims de modales reales (o un control full-rect dedicado) salvo casos explícitamente no bloqueantes.

10. **HUD de escena marca `FullMapLayer` como no interactivo desde `.tscn`, lo que puede invalidar interacción futura del mapa.**
   - `game/isla-ancestral/scenes/ui/hud.tscn:141-149` — `FullMapLayer` (`Control`) con `mouse_filter = 2` (IGNORE) y script `res://scripts/mapa/full_map_layer.gd`
   - **Impacto:** si el mapa completo requiere clicks/drag/zoom por UI, la escena lo deshabilita por defecto; acopla el comportamiento de input a una constante de escena poco visible.
   - **Accionable:** definir el `mouse_filter` según estado (abierto/cerrado) desde el script del mapa o documentar explícitamente que es display-only.

### Bajo

11. **Uso de `z_index` local en overlay de subtítulos dentro de capa de diálogo.**
   - `game/isla-ancestral/scripts/ui/overlays/subtitulo_overlay.gd:47` — `_panel.z_index = 2`
   - **Impacto:** z-index relativo local; no evidencia conflicto global, pero suma otra dimensión de orden además de árbol/capas.
   - **Accionable:** reservar `z_index` para casos excepcionales y preferir orden de hijos/capas explícitas.

12. **Desajuste documental/codigo en `DialogLayer` (cabecera indica MODAL_FULL, implementación usa MODAL_SIMPLE).**
   - `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd:6` — comentario: "Capa MODAL_FULL registrada en UIManager"
   - `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd:33-36` — asigna `layer_type = UILayerType.Type.MODAL_SIMPLE`
   - **Impacto:** confunde a mantenimiento y auditorías; puede inducir a "corregir" el tipo sin entender la intención real.
   - **Accionable:** actualizar comentario/encabezado para reflejar el contrato vigente y enlazar la decisión de diseño.

### Ruido

13. **Herramienta de auditoría en `scripts/ui/` raíz con corpus distinto al runtime.**
   - `scripts/ui/auditar_ui_m53.py:1-40` — auditor orientado a `game/isla-ancestral/scripts` y métricas M53; no forma parte de la UI ejecutable.
   - **Impacto:** puede inducir a falsos positivos de ubicación/alcance al buscar "UI" a nivel repositorio.
   - **Accionable:** documentar claramente su alcance en README interno de herramientas (sin prioridad funcional).

## Cobertura y límites de esta auditoría

- Revisado en detalle: `ui_root.gd`, `core/ui_manager.gd`, `core/ui_layer.gd`, `core/ui_layer_type.gd`, `hud/hud_screen.gd`, `scenes/ui/hud.tscn`, `layers/dialog_layer.gd`, `layers/pause_layer.gd`, `layers/inventory_layer.gd`, `layers/confirm_popup.gd`, `layers/equipment_layer.gd`, `layers/credits_layer.gd`, `layers/loading_layer.gd`, `layers/diary_layer.gd`, `layers/settings_audio_layer.gd`, `services/notification_service.gd`, `services/tooltip_service.gd`, `widgets/action_prompt_overlay.gd`, `hud/action_prompt_overlay.gd`, `overlays/subtitulo_overlay.gd`, `widgets/interact_prompt.gd`, y wiring en `main_island.gd`.
- No se verificó en runtime: orden visual efectivo, captura de input real, comportamiento con autoloads ausentes/presentes, ni colisiones fuera de los archivos inspeccionados.
- `mouse_filter` aparece ampliamente en widgets/hud; se priorizaron hallazgos con impacto arquitectónico (dimmers/modales, capas interactivas, HUD scene).

## Dos mejoras de diseño concretas

1. **Definir e imponer una "tabla de capas de Canvas" única y versionada para todo el producto.**
   - **Propuesta concreta:** reservar rangos fijos, p.ej. `HUD=10`, `MUNDO_UI/FRAMEWORK=20`, `MODALES=30`, `POPUPS=40`, `TOASTS=50`, `TOOLTIPS/DEBUG_OVERLAY=60`; exponerlos como constantes compartidas (recurso/config/autoload) y prohibir literales ad-hoc (`layer = 100`, `layer = 15`) en escenas/scripts UI.
   - **Aplicación inmediata:** mover `HUDScreen` y `UIRoot` a capas distintas dentro de ese esquema, asignar `layer` explícito a `NotificationService_`/`TooltipService_`, y retirar/aislar `DialogueUI` legado con su `layer = 15` o alinearlo al contrato.
   - **Resultado esperado:** z-order determinista, menos regresiones visuales y base clara para QA visual (V2/V4).

2. **Introducir un contrato único de ciclo de vida y pausa para capas (`UIManager` como autoridad).**
   - **Propuesta concreta:** establecer que toda capa modal/popup visible se abre y cierra exclusivamente vía `UIManager` (`push_layer/open_layer` y `pop_layer/close_layer`), que solo el manager muta `get_tree().paused`/estado de mundo, y que `UILayer` no auto-gestione pausa ni se auto-registre como "abierta" cambiando visibilidad.
   - **Aplicación inmediata:** eliminar `_freeze_world` propio de `InventoryLayer`, hacer que `ConfirmPopup` use `open/close` gestionado, y resolver la contradicción `UILayer._apply_process_mode` vs `UIManager._apply_process_mode` con una sola política (p.ej. UI siempre `PROCESS_MODE_ALWAYS`, mundo pausado por árbol; capas solo declaran `layer_type`).
   - **Resultado esperado:** foco, pila, pausa y restauración coherentes; menor superficie de bugs como modales pegados, input perdido o desincronización entre estado lógico y visual.