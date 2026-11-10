# Reporte de Auditoría UI — Crouton Alpha

**Modelo:** Crouton Alpha
**Plataforma:** Kilo
**Fecha:** 2026-11-09 21:53

## Resumen

Auditoría estática (solo lectura, sin edición) de la UI principal del M53 en `game/isla-ancestral/scenes/ui/` y `game/isla-ancestral/scripts/ui/`. El framework es casi enteramente procedural (UI construida por código en runtime, patrón §9.47): el único `.tscn` propio de UI principal es `hud.tscn`; el resto de capas se instancian desde `ui_root.gd` con `load(".../layers/*.gd").new()`. No se encontraron bloqueos graves de clicks ni texturas rotas; sí se detectaron 3 desvíos reales a corregir (procesamiento en pausa, `FullMapLayer` sin texturas, y un esqueleto legacy roto).

## Inventario de archivos analizados

### Escenas (.tscn)

| Archivo | Descripción |
|---------|-------------|
| `game/isla-ancestral/scenes/ui/hud.tscn` (149 líneas) | CanvasLayer `HUDScreen` (`layer = 100`), raíz del HUD. Único `.tscn` de UI principal. |

### Scripts núcleo

| Archivo | Líneas | Rol |
|---------|--------|-----|
| `game/isla-ancestral/scripts/ui/ui_root.gd` | 247 | `extends CanvasLayer`, `layer = 100` (L36). Instancia 12 capas modales (L41–129): Dialog, Pause, Menus, Confirm, Crafting, Inventory, Shop, Equipment, Diary, Loading, Credits, SettingsAudio. |
| `game/isla-ancestral/scripts/ui/core/ui_manager.gd` | 645 | `extends Node` (autoload). Pila `_stack`, pausa del mundo vía `_actualizar_pausa_mundo()` (L84–94), foco, tooltips, audio hover. |
| `game/isla-ancestral/scripts/ui/core/ui_layer.gd` | 110 | `extends Control`, clase base `UILayer`. `open()`/`close()`/`focus_first()` (L46–65), `_apply_process_mode()` (L83–93). |
| `game/isla-ancestral/scripts/ui/core/ui_layer_type.gd` | 19 | Enum `Type { HUD, MODAL_SIMPLE, MODAL_FULL, POPUP }`. |

### Capas modales (layers/)

| Archivo | Tipo declarado | Líneas |
|---------|----------------|--------|
| `scripts/ui/layers/menus_layer.gd` | `MODAL_FULL` (L21) | 124 |
| `scripts/ui/layers/pause_layer.gd` | `MODAL_FULL` (L28) | 281 |
| `scripts/ui/layers/dialog_layer.gd` | `MODAL_SIMPLE` (L36) | 354 |
| `scripts/ui/layers/inventory_layer.gd` | `MODAL_FULL` (L45) | 463 |
| `scripts/ui/layers/confirm_popup.gd` | `POPUP` (L20) | 106 |
| `scripts/ui/layers/loading_layer.gd` | `MODAL_FULL` (L31) | 166 |
| `scripts/ui/layers/equipment_layer.gd` | `MODAL_SIMPLE` (L26) | 311 |
| `scripts/ui/layers/diary_layer.gd` | (default) | 912 |
| `scripts/ui/layers/credits_layer.gd` | `MODAL_FULL` (L63) | 488 |
| `scripts/ui/layers/settings_audio_layer.gd` | `MODAL_FULL` (L66) | 499 |

### HUD y widgets

| Archivo | Líneas |
|---------|--------|
| `scripts/ui/hud/hud_screen.gd` | 177 |
| `scripts/ui/hud/hotbar_widget.gd` | 20 |
| `scripts/ui/hud/minimap_widget.gd` | 26 |
| `scripts/ui/hud/status_bar.gd`, `clock_widget.gd`, `season_widget.gd`, `resource_counter.gd`, `interact_prompt.gd`, `action_prompt_overlay.gd` | — |

### Servicios y overlays

| Archivo | Líneas | Nota |
|---------|--------|------|
| `scripts/ui/services/notification_service.gd` | 203 | `extends CanvasLayer`, toasts (máx. 3, L12). |
| `scripts/ui/services/tooltip_service.gd` | — | `extends CanvasLayer`. |
| `scripts/ui/subtitle_manager.gd` | 359 | Autoload `extends Node`; monta `CanvasLayer "SubtitulosCapa"` con `layer = 90` (L76). |
| `scripts/ui/overlays/subtitulo_overlay.gd` | — | `mouse_filter = MOUSE_FILTER_IGNORE` (L38, L45). |
| `scripts/ui/equipment_ui.gd` | 120 | **Esqueleto legacy roto** (ver §3 y §4). |

---

## 1. ¿Hay nodos Control con `mouse_filter = STOP` que bloqueen clicks?

**Veredicto: NO hay bloqueo indebido.**

Evidencia:

- `hud.tscn`: **los 15 nodos Control** tienen `mouse_filter = 2` (`IGNORE`, líneas 24, 29, 40, 45, 52, 64, 69, 84, 89, 105, 110, 120, 133, 138, 148). Esto es correcto: el HUD nunca debe comerse clicks; solo lee el mundo por señales (`hud_screen.gd` L5–L9). La raíz es `CanvasLayer` (L14–16), que no filtra input de esa forma.
- Capas modales: los fondos dim/oscurecedores usan explícitamente `MOUSE_FILTER_IGNORE` para no bloquear:
  - `pause_layer.gd` L37 (`dim.mouse_filter = Control.MOUSE_FILTER_IGNORE`)
  - `dialog_layer.gd` L126 (mismo patrón)
  - `inventory_layer.gd` L64 (mismo patrón)
  - `diary_layer.gd` L120 y L539, `equipment_layer.gd` L44, `credits_layer.gd` L77 (mismo patrón)
  - `ui_root.gd` L143: todo widget HUD dinámico se crea con `mouse_filter = IGNORE`.
  - `widgets/action_prompt_overlay.gd` L88 y `widgets/minimap_widget.gd` L190–351: todos sus subnodos de dibujo (`poly`, `rect`, `border`, `pin_dot`, etc.) se fijan a `IGNORE`.
  - `overlays/subtitulo_overlay.gd` L38 y L45: `IGNORE` en el overlay y su panel.
- `UILayer` base (`ui_layer.gd`) no declara ningún `mouse_filter = STOP` global ni interfiere; hereda el default de `Control` (`STOP`, valor 0) solo para el propio contenedor de la capa, que es el comportamiento esperado en botones/paneles interactivos (los `Button`, `LineEdit`, `HSlider`, `OptionButton` creados por código en `menus_layer`, `pause_layer`, `inventory_layer`, `confirm_popup`, `settings_audio_layer` deben recibir clicks).
- Grep de `MOUSE_FILTER_STOP` / `mouse_filter = 0` en `scripts/ui/`: **0 coincidencias**. Nadie fuerza un `STOP` accidental sobre contenedores pasivos.

Conclusión del eje 1: el diseño respeta la regla "HUD pasivo, capas modales interactivas". Los clicks del mundo no son tragados por widgets del HUD, y dentro de una capa modal el único `ColorRect` de fondo no consume eventos (intencionalmente `IGNORE`, para que clicks fuera del panel lleguen a los controles de la capa).

## 2. ¿Hay CanvasLayer con orden incorrecto que cubran botones?

**Veredicto: orden correcto; un `layer` residual a vigilar.**

Mapa de `layer` encontrados:

| CanvasLayer | Valor | Archivo:Línea |
|-------------|-------|---------------|
| `HUDScreen` (hud.tscn) | **100** | `scenes/ui/hud.tscn` L15 |
| `UIRoot` (monta las 12 capas) | **100** | `scripts/ui/ui_root.gd` L36 |
| `SubtitulosCapa` (runtime) | **90** | `scripts/ui/subtitle_manager.gd` L76 |
| `NotificationService_` / `TooltipService` / `ActionPromptOverlay` / `DonationPanel` / `MuseoSign` / `EquipmentUI` (legacy) | default (1, no asignado) | respectivos `.gd` |

Análisis:

- **HUD y UIRoot comparten `layer = 100`**: no es un conflicto porque no compiten en la misma zona de input — el HUD está en `Ignore` y las capas modales están encima por estar montadas más tarde en el árbol de `UIRoot` y por la pila de `UIManager`. El propio `UIRoot` advierte en L16–L20 (§9.47): *"NO montar widgets HUD aquí"*, separación limpia de responsabilidades.
- **Orden entre capas modales** (`ui_root.gd` L131): el orden de montaje es `Dialog → Pause → Menus → Confirm → Crafting → Inventory → Shop → Equipment → Diary → Loading → Credits → SettingsAudio` (última). `SettingsAudioLayer` se monta el último a propósito (L121–L123: *"se monta el ÚLTIMO para dibujarse sobre pausa/menús"*). Dentro de cada capa, el `dim`/fondo se crea con `move_to_front()` *antes* que el `CenterContainer`+panel (`pause_layer.gd` L40, `dialog_layer.gd` L129, `inventory_layer.gd` L67, `settings_audio_layer.gd` L79, `loading_layer.gd` L83), por lo que el panel siempre queda por encima del dim y ningún botón queda tapado por el fondo. Es el patrón correcto y está repetido consistentemente en las 10 capas.
- **`SubtitulosCapa` en `layer = 90`**: queda *debajo* del HUD (100) y de las capas modales (100). Correcto para subtítulos (no deben tapar botones) y consistente con `SubtituloOverlay` (dentro de `DialogLayer`) que también es pasivo.
- **PauseLayer restaura el mouse** al abrir/cerrar (`pause_layer.gd` L127–L136, guarda `_mouse_previo` y restaura en `on_layer_closed`), así que no deja el cursor capturado sobre la pausa ni libera el cursor del mundo al cerrar.
- **`close_top()` y `_stack` purgan la capa visible más reciente** (`ui_manager.gd` L288–L296), no `stack[-1]` ciega: con el diario abierto, Esc ya no des-registra `SettingsAudioLayer` (oculta) por error (comentario histórico L137–L145 y fix T-M1).

Conclusión del eje 2: no hay `CanvasLayer` que cubra botones ni orden invertido. El único punto a vigilar es que `HUDScreen` y `UIRoot` comparten el mismo `layer = 100`; si en el futuro un widget del HUD pasara a `STOP` (hoy `IGNORE`), ese tie-break por orden de árbol lo pondría *detrás* de las capas modales, que es lo que se quiere (las modales siempre ganan).

## 3. ¿Hay nodos sin script que deberían tener interacción?

**Veredicto: SÍ — dos hallazgos, uno crítico (legacy roto) y uno menor.**

### 3a. Crítico: `equipment_ui.gd` es un esqueleto roto (no inicializable)

`game/isla-ancestral/scripts/ui/equipment_ui.gd` (120 líneas) declara `extends CanvasLayer` (L3) y en `_ready()` llama a `_setup_slots()` (L20) que hace **acceso directo a nodos inexistentes**:

```gdscript
_head_slot = $Panel/VBox/HeadSlot    # L25
_body_slot = $Panel/VBox/BodySlot    # L26
_feet_slot = $Panel/VBox/FeetSlot    # L27
_accessory_slot = $Panel/VBox/AccessorySlot  # L28
```

No existe ningún `.tscn` (ni `EquipmentUI.tscn` ni similar) con esa jerarquía `$Panel/VBox/...` en `scenes/`. Sin escena, `$Panel` es `null` → **error en `_ready()`** al instanciarse. El propio `equipment_layer.gd` lo documenta en L5–L9:

> *"M155: EquipmentLayer — panel de vestimenta como capa M53 (reemplaza el esqueleto roto scripts/ui/equipment_ui.gd que esperaba $Panel/VBox/... sin escena)."*

El reemplazo real, `EquipmentLayer` (311 líneas, `layer_type = MODAL_SIMPLE`, 4 slots + catálogo + bono de terreno, navegación `equipamiento`/`pausa`), está completo y es el que se monta en `ui_root.gd` L94–L98. El legacy sigue en el repo y seguirá rompiendo si alguien lo instancia. Impacto hoy: **bajo** (nadie lo carga; grep confirma que solo aparece como referencia en tests/preload de inspector), pero es código muerto peligroso.

### 3b. Menor: `FullMapLayer` del HUD es un nodo pasivo sin render ni interacción

En `hud.tscn` L141–L148:

```
[node name="FullMapLayer" type="Control" parent="."]
unique_name_in_owner = true
anchors_preset = 15 (FULL_RECT)
mouse_filter = 2 (IGNORE)
script = ExtResource("10_fullmap")  # res://scripts/mapa/full_map_layer.gd
```

El nodo se crea con script (`scripts/mapa/full_map_layer.gd`) pero: (1) no hay ningún `Button`/`Panel` hijo en el `.tscn` — es un `Control` desnudo fullscreen; (2) al ser `IGNORE` y no contener controles, **nunca puede recibir clicks** ni mostrarse sobre nada; (3) `hud_screen.gd` **no lo referencia en absoluto** (L12–L19 lista StatusBar, Clock, Season, Resource, Hotbar, Interact, Minimap, ActionPrompt — `FullMapLayer` ausente). Si el mapa completo debe abrirse con una acción (p. ej. `M`), hoy no hay cableado visible desde el HUD. Es un nodo huérfano: no rompe nada, pero tampoco hace nada.

### 3c. Widgets HUD sin interacción (correcto por diseño, no es hallazgo)

`hotbar_widget.gd` (20 líneas) y `minimap_widget.gd` (26 líneas) son `extends Control` sin `_input`/`_gui_input` ni `Button` hijos: solo exponen `set_items()` / `set_textura()` / `set_jugador()` y redibujan vía `_draw()`. Es lo que se espera de un widget HUD pasivo (la selección de hotbar vive en el inventario/player, no en el widget). No se consideran "sin interacción indebida".

Conclusión del eje 3: el único nodo sin script/interacción que debería tenerla es el legacy `equipment_ui.gd` (roto, sin escena) y, en menor medida, `FullMapLayer` (huérfano sin consumidores).

## 4. ¿Hay texturas/imágenes rotas en nodos UI?

**Veredicto: NO hay texturas rotas; hay una textura que nunca se carga (functional gap).**

Evidencia:

- Grep `texture|TextureRect|Sprite2D|icon|load(.*\.(png|jpg|svg))` en `scripts/ui/`: las únicas asignaciones a texturas reales son:
  - `hud/minimap_widget.gd` L25: `draw_texture_rect(_tex, ...)` — `_tex` es `null` por defecto y solo se dibuja si `set_textura()` recibe una textura válida (L8–L10). Sin carga rota; sin textura, dibuja el punto del jugador (L26).
  - `layers/diary_layer.gd` L315–L674: `TextureRect.new()` con `expand_mode = EXPAND_IGNORE_SIZE`, `stretch_mode = KEEP_ASPECT_CENTERED` (L318–L319); la textura viene de `ico.get("textura", null)` (L592, L674). El código maneja `null` como fallback (sin icono, sin crash).
  - `equipment_ui.gd` L48–L53 (legacy): `icon.texture = null` si el nodo existe; los tres nodos (`Icon`, `Label`, `Rarity`) se buscan con `get_node_or_null` (L48–L50) justamente por BUG-016 *"el layout puede variar (nodos Icon/Label/Rarity ausentes no deben crashear)"*. No hay `preload` de `.png` ni `load()` de imagen inexistente en ningún script de UI.
  - Los "iconos" del resto de la UI son **emoji/unicode en `Label`**, no texturas: `season_widget.gd` L21–L24 (`🌸 ☀ 🍂 ❄`), `widgets/clock_widget.gd` L91–L92, `notification_service.gd` L191–L194 (`📦 🔔 📋 💬`), `equipment_layer.gd` L190 (`🔒`). Ninguno puede romperse por un `.import` faltante.
- `hud.tscn` no declara ningún `TextureRect` ni `ext_resource` de textura: los 9 `ext_resource` son todos `Script` (L3–L12). No hay cabeceras rotas.
- `preview_paneles_m53.tscn` / `preview_inventario_s5.tscn` (en `scripts/ui/`, escenas de prueba) no cargan texturas externas.

**Gap detectado (no roto, pero incompleto):** `MinimapWidget.set_textura()` existe pero **ningún caller en `scripts/ui/` lo invoca con una textura M54**. El minimapa hoy solo dibuja un círculo blanco sobre fondo vacío hasta que M54 entregue la caché de textura. No es una textura rota: es una integración pendiente.

Conclusión del eje 4: cero texturas rotas/bloqueadas por assets faltantes. El único vacío visual real es el minimapa sin textura (dependencia externa M54).

## 5. Dos mejoras sugeridas

### Mejora 1 — Eliminar el esqueleto legacy `equipment_ui.gd` y cablear `FullMapLayer` (higiene)

**Qué:** (a) Borrar `game/isla-ancestral/scripts/ui/equipment_ui.gd` (o moverlo a `Obsoletos/`) y su referencia en `scripts/editor/_colector_sintaxis.gd` L952; `EquipmentLayer` ya es el reemplazo documentado. (b) Cablear `FullMapLayer` (`hud.tscn` L141–L148) en `hud_screen.gd`: agregar `@onready var full_map_layer` (junto a L18), un toggle con acción `mapa_completo` en `ui_manager.gd` `_unhandled_input` (mismo patrón que `inventario` L147–L152 y `diario` L166–L171), y `mouse_filter = STOP` solo cuando esté abierto (hoy `IGNORE`, inabrible).

**Por qué:** cierra el riesgo de que alguien instancie el legacy y crashee en `_ready()`; y convierte un nodo huérfano fullscreen en una feature visible (mapa completo) sin tocar la arquitectura actual (`UIManager._stack` + `open()`/`close()` ya lo soportan).

**Esfuerzo:** S (1–2 h). Sin cambios de escena salvo `hud.tscn` (cambiar `mouse_filter` de `FullMapLayer` a `STOP` cuando se abre, vía script).

### Mejora 2 — Unificar el `layer` de UIRoot/HUD y dar textura al minimapa

**Qué:** (a) Subir `UIRoot.layer` de `100` a `101` en `ui_root.gd` L36, dejando `HUDScreen` en `100` y `SubtitulosCapa` en `90`: orden total determinista `Subtítulos (90) < HUD (100) < Capas modales (101)`, sin tie-breaks implícitos por orden de árbol. (b) Integrar `MinimapWidget.set_textura()` con la caché de textura de M54 (o con un generador procedural fallback en `minimap_widget.gd` `_draw()`), para que el minimapa no quede como un círculo vacío.

**Por qué:** hoy el empate `100/100` funciona solo por orden de montaje y por el `IGNORE` del HUD; separar los `layer` hace la intención explícita y robusta ante futuros widgets interactivos del HUD. El minimapa es el único vacío visual de la UI principal y `set_textura()` ya expone la API: falta el cableado.

**Esfuerzo:** S/M (2–4 h). (a) es un cambio de 1 línea; (b) depende de la disponibilidad de la caché M54.

---

## Conclusión final

El framework UI M53 está **sano**: sin clicks bloqueados por `mouse_filter = STOP` indebido (HUD todo `IGNORE`, fondos dim `IGNORE`, 0 coincidencias de `STOP` forzado en scripts), sin `CanvasLayer` que tape botones (orden `Subtítulos 90 < HUD 100 = UIRoot 100`, y dentro de cada capa el panel siempre sobre el dim vía `move_to_front()`), sin texturas rotas (0 `ext_resource` de textura en `hud.tscn`; los iconos son emoji y las únicas texturas se asignan con null-checks). Los dos desvíos reales son de higiene, no de bloqueo: (1) el esqueleto legacy `equipment_ui.gd` (120 líneas, `$Panel/VBox/...` inexistente, ya reemplazado por `EquipmentLayer`) — **recomendación: eliminar o archivar**; (2) `FullMapLayer` huérfano en el HUD (nodo fullscreen `IGNORE` sin consumidores) y el minimapa sin textura M54 (integración pendiente, no rotura). Con las dos mejoras propuestas (higiene + capas/textura) la UI principal queda sin deuda conocida en los 5 ejes auditados.

**Archivos clave (con líneas):**
- `game/isla-ancestral/scenes/ui/hud.tscn` L14–L15 (`CanvasLayer` 100), L24–L148 (15 nodos `IGNORE`), L141–L148 (`FullMapLayer` huérfano)
- `game/isla-ancestral/scripts/ui/ui_root.gd` L36 (`layer = 100`), L41–L129 (12 capas), L143 (`IGNORE` dinámico)
- `game/isla-ancestral/scripts/ui/core/ui_manager.gd` L84–L94 (pausa mundo), L288–L296 (`close_top` fix)
- `game/isla-ancestral/scripts/ui/core/ui_layer.gd` L83–L93 (`_apply_process_mode`)
- `game/isla-ancestral/scripts/ui/equipment_ui.gd` L25–L28 (accesos rotos `$Panel/VBox/...`)
- `game/isla-ancestral/scripts/ui/subtitle_manager.gd` L76 (`layer = 90`)
