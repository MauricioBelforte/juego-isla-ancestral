# Reporte: Entradas de usuario (input) — Glyph Cluster

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code / Agent Manager (VS Code)  
**Fecha:** 2026-11-08  
**Alcance:** game/isla-ancestral/scripts/ (.gd) — búsqueda de manejo de input/teclado/mouse/gamepad (Input, InputEvent, _input, _unhandled_input, InputMap, is_action*).  
**Nota:** No existe scripts/input/ ni scripts/teclado/; el manejo principal está en scripts/controls/, scripts/player/, scripts/camera/follow_camera.gd, scripts/interacciones/, scripts/ui/core/ui_manager.gd y handlers distribuidos.

## Archivos relevantes analizados

| Archivo | Rol en entradas |
|---|---|
| game/isla-ancestral/project.godot (autoloads + [input]) | Registro de ControlInput como autoload; mapa de acciones/bindings. |
| game/isla-ancestral/scripts/controls/control_input.gd | Capa central M57: consulta Input/InputMap, detección de dispositivo, remapeo, persistencia. |
| game/isla-ancestral/scripts/controls/prompt_db.gd | Resolución de prompts por acción/dispositivo (usa InputMap/ControlInput). |
| game/isla-ancestral/scripts/player/player.gd | Movimiento, salto, toggles, edición voxel, hotbar, UI legacy; mezcla Input directo y ControlInput. |
| game/isla-ancestral/scripts/player/player_core_m11.gd | Sprint: lee InputMap/Input (LShift o acción correr) con duck-typing sobre player.gd. |
| game/isla-ancestral/scripts/follow_camera.gd | Cámara canónica: _unhandled_input para mouse motion/scroll y rotación/zoom. |
| game/isla-ancestral/scripts/interacciones/interaction_manager.gd | Autoload interacciones: selección de objetivo y despacho por presionar_interact() (no lee input directo). |
| game/isla-ancestral/scripts/ui/core/ui_manager.gd | _unhandled_input: pausa, inventario, equipamiento, HUD, diario, favorito, navegación. |
| game/isla-ancestral/scripts/npc/villager_manager.gd | _unhandled_input para interacción con aldeanos (ruta paralela a M70). |
| game/isla-ancestral/scripts/crafting/crafting_station.gd, scripts/foto/photo_service.gd, scripts/shops/shop_ui.gd, scripts/mapa/full_map_layer.gd, scripts/debug/debug_menu.gd | Handlers de acciones puntuales (_unhandled_input/_input). |

## 1) ¿Cómo se gestionan las entradas de usuario?

### Arquitectura declarada (M57) vs. uso real
- **InputMap + autoload central:** project.godot define acciones en [input] (mover_*, interactuar, inventario, pausa, colocar, avorito, saltar, hotbar_*, camara_*, ocultar_hud, 	omar_foto, etc.) y registra ControlInput="*res://scripts/controls/control_input.gd" (autoloads, ~líneas 19–120 y sección [input] del archivo).  
  Referencia: game/isla-ancestral/project.godot.
- **Capa ControlInput (M57):** expone wrappers sobre Input/InputMap (ccion_presionada, ccion_justa, eje, ector_movimiento, ejes_camara), detecta dispositivo activo en _unhandled_input (teclado/ratón/gamepad) y emite dispositivo_cambiado; además remapea, detecta conflictos, sugiere atajos libres y persiste config JSON atómica.  
  Referencia: game/isla-ancestral/scripts/controls/control_input.gd:13-15,62-123,168-176,219-240,278-308,337-346.

### Consumo mixto (acción-map + polling directo)
- **Movimiento/cámara con acciones/parcial:** ControlInput.vector_movimiento() usa Input.get_vector("mover_oeste","mover_este","mover_norte","mover_sur") (control_input.gd:76-81). ollow_camera.gd usa _unhandled_input para InputEventMouseMotion/wheel y aplica sensibilidad/inversión desde GameSettings (ollow_camera.gd:81-102).
- **Jugador (player.gd) combina patrones:** usa _accion_justa_m57() con fallback a Input.is_action_just_pressed (player.gd:53-57), pero el **movimiento principal**, salto, descenso, teleports dev y fallback de mano leen teclas directas con Input.is_key_pressed(KEY_W/A/S/D/SPACE/C/V/N/T/E/Q) en _physics_process/helpers (player.gd:303-345,409-456,468-485). Hotbar 1–6 usa InputEventKey por keycode en _unhandled_input (player.gd:145-155).
- **UIManager consume acciones:** maneja pausa, inventario, equipamiento, ocultar_hud, diario, avorito, mover_* vía event.is_action_pressed(...) en _unhandled_input (ui/core/ui_manager.gd:117-187).
- **Interacciones distribuidas:** crafting_station.gd abre UI con event.is_action_pressed("interactuar") por proximidad (crafting_station.gd:51-56); photo_service.gd escucha posar/	omar_foto (oto/photo_service.gd:235-242); shop_ui.gd y crafting_ui.gd cierran con pausa. interaction_manager.gd (autoload M70) **no lee input**: expone presionar_interact() y selecciona objetivos por evaluación periódica (interacciones/interaction_manager.gd:82-96,133-159); no se observó un handler global que llame presionar_interact() desde acción interactuar en los archivos inspeccionados (hay rutas paralelas como illager_manager.gd).

## 2) ¿Hay validación de inputs antes de usarlos?

**Sí, en la capa central y en algunos consumidores; parcial/inconsistente en gameplay directo.**
- **ControlInput valida/normaliza:** deadzone en ejes/vector (_aplicar_deadzone, _aplicar_deadzone_vector, deadzone_palanca_izq/der/gatillo: control_input.gd:37-40,70-102), sensibilidad/inversión de cámara (control_input.gd:84-92), detección de conflictos y equivalencia de eventos antes de remapear (control_input.gd:168-195), carga JSON con chequeo de tipo/defaults y solo agrega eventos si la acción existe (control_input.gd:296-346), persistencia atómica con backup (control_input.gd:278-294), vibración clampeada (control_input.gd:267-274).
- **PromptDB defensivo:** verifica InputMap.has_action y modo; fallback seguro a teclado cuando no hay ControlInput (controls/prompt_db.gd:73-102).
- **follow_camera:** bloquea input en modos DIALOG/CUTSCENE, clampea pitch, limita zoom a min/max, y usa MOUSE_MODE_CAPTURED para rotación (ollow_camera.gd:81-102,154-161).
- **player.gd:** valida existencia de nodos (get_node_or_null, null-checks para terreno/cámara/tool controller/inventario), evita toggle ESC cuando hay capa UI visible (_ui_capa_visible, player.gd:294-314), y normaliza input_dir (player.gd:422-425). **Pero** no pasa por ControlInput para WASD/salto/acciones dev; confía en polling directo sin capa común de remapeo/deadzone/gamepad.
- **UIManager/debug handlers:** comprueban acciones con event.is_action_pressed y consumen/gestionan estado de UI; debug_menu usa _input para consumir Escape/F1 y también mantiene _unhandled_input para F12 legacy (debug_menu.gd:456-474,583+ según búsqueda).

## 3) ¿Hay problemas de inputs fantasma o duplicados?

**Riesgos observados (potenciales/estructurales), no todos confirmados en runtime sin pruebas:**
- **Rutas paralelas para “interactuar”:** InteractionManager.presionar_interact() existe (M70, interaction_manager.gd:133-159), VillagerManager._unhandled_input interactúa con aldeanos por distancia/proximidad (illager_manager.gd:341-376), y CraftingStation._unhandled_input abre panel con interactuar (crafting_station.gd:51-56). Sin un árbitro único, la misma pulsación puede disparar comportamientos distintos según orden de escena/árbol (fantasma funcional o doble intención).
- **Colisión de bindings en el mapa:** en project.godot la acción interactuar usa KEY_E (physical 69) y equipamiento **también** usa KEY_E ([input] acciones interactuar y equipamiento). Esto puede producir activaciones no deseadas/ambigüedad de intención (misma tecla, acciones distintas) según qué sistema escuche primero.
- **Mezcla de capas para movimiento/juego:** el jugador ignora el InputMap/ControlInput para WASD/salto/hotbar parcial (player.gd:145-155,330-345,413-420), mientras ControlInput expone ector_movimiento() y acciones (control_input.gd:62-81). Resultado: remapeos persistidos por M57 pueden **no afectar** al movimiento real del jugador (input “fantasma” desde la perspectiva del usuario: cambió controles y no pasa nada).
- **Polling en _physics_process sin edge control en varios casos:** salto/acciones dev usan is_key_pressed cada frame físico (con guards parciales como _t_prev para T: player.gd:348-355, cooldown mano: player.gd:320-328, debounce ESC: player.gd:303-314). Mantener teclas puede repetir efectos donde no hay cooldown/estado (riesgo de repetición según contexto).
- **Duplicidad de handlers/debug:** DebugMenu declara intención de usar _input para Escape/F1 pero conserva _unhandled_input para F12 (debug_menu.gd:456,583 referencia en comentario/búsqueda). Esto es deliberado para legacy, pero aumenta superficie de eventos; tests llaman _input/_unhandled_input directamente (aceptable en headless).
- **Cámara deprecated aún presente:** camera_rig.gd está marcado DEPRECATED/código muerto y no debería instanciarse, pero existe con lógica de input/shake/fade; si se reintroduce accidentalmente, duplicaría responsabilidades con ollow_camera.gd (camera_rig.gd:1-6).

## 4) ¿Hay bindings de teclado configurados correctamente?

**Parcialmente.** El mapa base existe y cubre gameplay/cámara/UI, pero hay incoherencias y cobertura incompleta.
- **Correcto/esperable:** WASD (mover_*) con teclado + ejes de gamepad; saltar con espacio + botón joy; hotbar_1-9; zoom cámara por wheel; rotación cámara por stick derecho; pausa en Escape; acciones como inventario(B), colocar(Q), diario(J), avorito(F), ocultar_hud(H), 	omar_foto(P). Referencia: project.godot [input].
- **Problema:** interactuar y equipamiento comparten KEY_E (physical 69) en project.godot — conflicto de intención. ControlInput.hay_conflicto() compara eventos entre **ACCIONES_CATALOGO** (control_input.gd:29-34,177-184), y ese catálogo **no incluye equipamiento** (ni ocultar_hud, 	omar_foto, camara_zoom_*, camara_rotar_*, diario, hotbar_* completos según catálogo vs. mapa), por lo que el conflicto real del mapa puede no ser detectado por la API de M57.
- **Acciones usadas pero no verificadas en mapa completo:** photo_service.gd escucha posar (oto/photo_service.gd:236) — no se observó binding posar en el bloque [input] revisado; si falta, el atajo no funcionará por acción-map. player_core_m11.gd contempla acción correr si existe, con fallback a LShift (player_core_m11.gd:54-56,109-114); no se vio correr en [input].
- **Cobertura gamepad incompleta:** varias acciones clave (p.ej. interactuar, inventario, pausa según mapa visible) no muestran binding de joypad en [input], aunque ControlInput/PromptDB soportan prompts y remapeo genérico; UX gamepad puede depender de defaults no declarados o remapeo manual.

## 5) Sugerencias de mejora (2)

1. **Unificar la ruta de entrada de gameplay en ControlInput + InputMap (eliminar polling directo donde sea gameplay).**  
   - Migrar player.gd a consumir ControlInput/acciones (ector_movimiento, ccion_presionada/justa para salto/hotbar/fallback mano/interacciones dev) en vez de Input.is_key_pressed(KEY_*) (player.gd:145-155,303-345,409-420).  
   - Definir/agregar acciones faltantes (correr, posar si aplica) en project.godot y ampliar ACCIONES_CATALOGO/lógica de conflicto de ControlInput para cubrir acciones reales del mapa (incluyendo equipamiento o resolver el solapamiento con interactuar).  
   - **Beneficio:** remapeo M57 efectivo, menos inputs fantasma por bypass, detección real de conflictos, mejor soporte teclado/ratón/gamepad.

2. **Crear un despachador único de “interacción contextual” con arbitraje/prioridad.**  
   - Centralizar el flujo: un solo punto (p.ej. UIManager o un InteractionDispatcher) escucha interactuar (is_action_just_pressed), consulta estado UI/diálogo/cinemática y llama **una** ruta: InteractionManager.presionar_interact() (M70) o, si se mantiene legado, una cola priorizada; evitar que VillagerManager, CraftingStation, etc. reaccionen independientemente al mismo evento.  
   - Resolver el conflicto interactuar vs equipamiento en la misma tecla (separar bindings o usar modificador/contexto).  
   - **Beneficio:** elimina dobles disparos, orden determinista, y hace testable el contrato de input→acción.

## Conclusión final

El proyecto tiene una base sólida para input moderno en Godot 4: **InputMap en project.godot** y un autoload **ControlInput (M57)** con detección de dispositivo, deadzones, remapeo, conflictos y persistencia. Sin embargo, la gestión real está **fragmentada**: sistemas de UI/cámara usan acciones y _unhandled_input, mientras que el **núcleo del jugador** depende en gran medida de **polling directo por KEY_*** y hay **rutas paralelas de interacción** (InteractionManager M70 vs. handlers distribuidos como VillagerManager/CraftingStation).

Esto genera riesgos concretos: **remapeos que no aplican al movimiento**, **posibles activaciones ambiguas/duplicadas** (notablemente interactuar/equipamiento compartiendo E y ACCIONES_CATALOGO incompleto frente al mapa), y **difícil garantía de ausencia de inputs fantasma** sin un árbitro único. La validación existe pero es desigual: fuerte en ControlInput/cámara, limitada en gameplay directo. Prioridad recomendada: **unificar consumo en ControlInput + acción-map** y **consolidar la interacción contextual** bajo un único dispatcher.
