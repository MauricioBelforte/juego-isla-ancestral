**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 21: Diálogos

## 1. Rutas propuestas

```
res://_Project/Scripts/Dialogues/
├── dialogue_manager.gd        # Autoload: máquina de conversación
├── dialogue_manager_autoload.gd  # (alias registrado como "DialogueManager")
├── dialogue_graph.gd          # Grafo de nodos: carga y acceso
├── dialogue_node.gd           # Nodo de datos (LINEA/OPCIONES/EVENTO/FIN)
├── dialogue_option.gd         # Opción ramificada
├── dialogue_validator.gd      # Validación estática de grafos
├── dialogue_condition_parser.gd  # Parsing de condiciones declarativas
├── dialogue_trigger.gd        # Componente de disparo sobre NPCs/objetos
├── dialogue_events.gd         # EventBus de señales del sistema
├── world_state_service.gd     # Acceso a variables de estado del mundo (capa única)
└── dialogue_text_resolver.gd  # Placeholders {clave} -> valores

res://_Project/Scenes/UI/
└── dialogue_ui.tscn           # Escena Canvas de conversación
    └── dialogue_ui.gd         # Presentación: tipeo, opciones, entrada

res://_Project/Data/Dialogues/
├── dialogo_ejemplo.json       # Ejemplo funcional (valida el pipeline)
├── npc/{npc_id}.json          # Base de diálogos por NPC (M19)
├── deidades/{deidad_id}.json  # Conversaciones con deidades
├── misiones/{mision_id}.json  # Diálogos de misiones (M22/M23)
└── idiomas/
    ├── es.json                # Diccionario español (default)
    └── en.json                # Ejemplo de localización (M87)
```

## 2. Firmas de funciones clave

### dialogue_manager.gd (autoload)

```gdscript
extends Node

func start_dialogue(dialogue_id: String, context: Dictionary = {}) -> bool
func stop_dialogue() -> void
func advance() -> void
func choose_option(index: int) -> void
func skip_all() -> void
func is_dialogue_active() -> bool
func get_current_node() -> DialogueNode
func resolve_text(text_key: String, placeholders: Dictionary = {}) -> String
func _load_graph(dialogue_id: String) -> DialogueGraph
func _enter_node(node: DialogueNode) -> void
func _handle_input(event: InputEvent) -> void   # confirmar/saltar/opciones
func _on_typing_finished() -> void
func _on_confirm_pressed() -> void
func _on_option_pressed(index: int) -> void
```

### dialogue_graph.gd

```gdscript
class_name DialogueGraph
extends RefCounted

var dialogue_id: String
var start_node_id: String
var nodes: Dictionary = {}            # id -> DialogueNode

static func load_from_json(path: String) -> DialogueGraph
func validate() -> Array[Dictionary]  # [{tipo, mensaje, nodo_id, linea}]
func get_node_by_id(id: String) -> DialogueNode
func get_start_node() -> DialogueNode
func get_speaker_keys() -> Array[String]
```

### dialogue_node.gd

```gdscript
class_name DialogueNode
extends RefCounted

enum Tipo { LINEA, OPCIONES, EVENTO, FIN }

var id: String
var tipo: Tipo = Tipo.LINEA
var speaker_key: String
var text_key: String
var placeholders: Dictionary = {}
var conditions: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var next_id: String
var goto_id: String
var options: Array[DialogueOption] = []
var hide_blocked: bool = false

func evaluate_conditions(world_state: Dictionary) -> bool
func apply_effects(event_bus: Node) -> void
func static from_dict(data: Dictionary) -> DialogueNode
```

### dialogue_validator.gd

```gdscript
class_name DialogueValidator
extends RefCounted

static func validate_graph(graph: DialogueGraph) -> Array[Dictionary]
static func validate_json_text(path: String, raw: String) -> Array[Dictionary]
```

### dialogue_ui.gd

```gdscript
class_name DialogueUI
extends CanvasLayer

func show_line(speaker_key: String, text: String) -> void
func show_options(options: Array[Dictionary]) -> void
func clear_options() -> void
func set_typing_speed(wpm: int) -> void
func set_auto_advance(enabled: bool, seconds: float) -> void
func skip_current_line() -> void
func reset() -> void

signal confirm_pressed
signal option_pressed(index: int)
signal typing_finished
```

### dialogue_trigger.gd

```gdscript
class_name DialogueTrigger
extends Node3D

@export var dialogue_id: String = ""
@export var auto_trigger: bool = false
@export var trigger_distance: float = 2.0
@export var cooldown: float = 1.5

func interact() -> bool
func _on_distance_check() -> void
```

### world_state_service.gd

```gdscript
class_name WorldStateService
extends Node

func get_value(key: String, default: Variant = null) -> Variant
func set_value(key: String, value: Variant) -> void
func get_snapshot(keys: Array[String]) -> Dictionary
```

## 3. Logs relacionados

| Prefijo | Uso |
|---|---|
| `[DOM-DGT]` | Eventos de conversación: inicio, fin, nodo, opción (manager) |
| `[VAL-DGT]` | Resultados de validación: errores y advertencias de grafos |
| `[LOC-DGT]` | Fallos de localización: clave ausente en el diccionario activo |
| `[SYS-DGT]` | Carga/descarga de grafos, cache y recarga en caliente |

Ejemplos:

```
[DOM-DGT] Inicio dialogo 'aldeana_ana_1' (primer encuentro)
[DOM-DGT] Nodo 'ana_intro' -> 'ana_presentacion'
[DOM-DGT] Opcion 2 elegida: 'ana_pedir_consejo' (+1 amistad M19)
[VAL-DGT] ERROR: dialogo_ejemplo.json nodo 'x3': goto 'nodo_fantasma' inexistente
[VAL-DGT] ERROR: dialogo_ejemplo.json nodo 'x1': id duplicado con 'intro'
[LOC-DGT] AVISO: clave 'ana_linea_88' ausente en idioma 'en'
```

## 4. Reglas de implementación

- Los datos JSON no contienen emojis ni texto incrustado en imágenes (M87).
- `resolve_text()` devuelve la clave sin resolver si falta el diccionario (nunca crashea).
- La UI se oculta al no haber conversación activa; deshabilitar input rápido (sección 8 de AGENTS.md: prevenir clicks rápidos).
- Validar siempre `start_dialogue` contra el cache y validar en frío en el editor (`tool`).
- Los `effects` se emiten en orden y una sola vez por entrada a nodo.

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo
**Fecha:** 2026-08-30
**Estado:** Núcleo implementado por Hy3 (Kilo) 2026-08-29; bugfix de reinicio documentado por Deepseek V4 Flash (Kilo) 2026-08-30.

### Implementación real (archivos runtime vigentes — NO los plan-inicial)

El sistema de diálogos M21 está implementado en GDScript real (no coincide con las rutas
`res://_Project/...` del plan-inicial, que quedaron como referencia de diseño):

```
res://scripts/dialogos/
├── dialogue_manager.gd        # Autoload "DialogueManager" (máquina de conversación)
├── dialogue_graph.gd          # Grafo: carga desde JSON + validación estática [VAL-DGT]
├── dialogue_node.gd           # Nodo (LINEA=0 / OPCIONES=1 / EVENTO=2 / FIN=3)
├── dialogue_option.gd         # Opción ramificada con conditions/effects
├── ui/dialogue_ui.gd          # CanvasLayer autocontenido (presentación + input)
├── test_dialogos.gd           # Suite headless (grafo, flujo, opciones, reinicio)
res://data/dialogues/catalina_hola.json  # Grafo de ejemplo (Catalina, M19)
```

Registrado en `project.godot` como autoload `DialogueManager`. La UI se instancia desde
`main_island.gd:_crear_ui_dialogo()` y se conecta a las señales del manager
(`node_entered`, `dialogue_ended`). El disparo de la conversación lo hace
`villager_dialogue_hook.gd` (M19) llamando `DialogueManager.start_dialogue(dialogue_id, ctx)`.

### Lo que hice (2026-08-30)

- **Bugfix "el diálogo solo funciona una vez" (M21):** la UI guardaba `_opciones_activas = options`
  (referencia directa al Array de opciones del nodo del grafo cacheado) y `_limpiar_opciones()`
  llamaba `_opciones_activas.clear()`, vaciando el array **original** en `DialogueManager._grafos_cache`.
  La 2ª vez, `start_dialogue` validaba el grafo con el nodo OPCIONES sin opciones →
  `ERROR: [VAL-DGT] nodo OPCIONES 'pregunta' sin opciones` → no iniciaba.
  - Fix en `scripts/dialogos/ui/dialogue_ui.gd`: `_opciones_activas = options.duplicate()` y
    `_limpiar_opciones()` usa `_opciones_activas = []` (reasignación, no `clear()`).
  - Lección general documentada en `07-GUIA-GODOT.md` §9.46 (Arrays por referencia).
  - Verificado: `test_dialogos.gd` headless 0 fallos; `--check-only` de `dialogue_ui.gd` sin errores.

### Lo que NO hice (honestidad)

- No marqué ítems del checklist como `[x]` de implementación completa: el núcleo ya existía de la
  iteración de Hy3 y el checklist plan-actual aún está mayormente `[ ]` (pendiente de relevar
  contra el código real). Solo marqué los ítems relacionados con este bugfix (ver 05-Checklist.md).
- No ejecuté playtest manual completo con la UI visible (requiere Godot con ventana).

### Intentos fallidos / decisiones

- Primero intenté reproducir el bug con un test headless que instanciaba `DialogueUI` dentro de un
  `SceneTree` (`test_reinicio_ui.gd`), pero **no se reproduce** porque el `_ready()` de la UI no se
  ejecuta en scripts `SceneTree` con lógica en `_init()`. El diagnóstico se hizo por análisis del
  flujo de referencias + el error real del depurador (MCP Godot). Archivo temporal eliminado.

### Recomendaciones para el próximo agente

- Al conectar la UI con cualquier sistema que cache grafos/datos: SIEMPRE `duplicate()` antes de
  guardar una copia mutable (ver 07-GUIA-GODOT §9.46).
- Relevar el checklist plan-actual contra el código real (manager + grafo + UI ya existen).
- Integrar la UI M21 con M53 (UIManager/pila de capas) cuando corresponda; hoy es autocontenida.