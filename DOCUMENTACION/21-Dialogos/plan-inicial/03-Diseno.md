**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 21: Diálogos

## 1. Arquitectura general

Tres capas desacopladas (sección 9 de AGENTS.md):

```
[ Contenido ]   res://_Project/Data/Dialogues/*.json  (grafos, texto, condiciones)
[ Máquina ]     DialogueManager (autoload) + DialogueGraph + DialogueNode + DialogueValidator
[ Presentación ] DialogueUI (escena Canvas) — solo muestra y emite entradas de usuario
[ Disparo ]     DialogueTrigger (sobre NPCs/objetos) — llama al manager
```

```
+----------------+   carga/valida    +-----------------+
|  dialogue_*.json| ---------------> | DialogueGraph    |
+----------------+                   |  (grafo nodos)   |
                                     +--------+--------+
+------------+  start_dialogue(id)            | get_start_node
| DialogueManager| <-------------------+      |
| (autoload)  | --- avanza/elige ----->| DialogueNode (actual)
+-----+------+                          +--------+--------+
      | señales                                | lee/escribe
      v                                        v
+------------+                     +------------------------+
| DialogueUI |                     | WorldStateService (M29 |
| (Canvas)   |   texto/opciones    |  M31, M19, M22, M23)  |
+------------+                     +------------------------+
      ^
      | interact()
+------------+
| DialogueTrigger (NPC M19/M64) |
+------------+
```

## 2. Componentes

### 2.1 DialogueNode (contenedor de datos)

Nodo del grafo con tipos `LINEA`, `OPCIONES`, `EVENTO` y `FIN`:

- `id: String` (único dentro del grafo), `tipo: int`
- `speaker_key: String` (clave del hablante: NPC, deidad, narrador)
- `text_key: String` (clave de localización)
- `placeholders: Dictionary` (valores dinámicos opcionales)
- `conditions: Array[Dictionary]` (reglas para mostrar el nodo)
- `effects: Array[Dictionary]` (cambios: amistad, banderas, misiones)
- `next_id: String` (transición lineal), `goto_id: String` (salto directo)
- `options: Array[DialogueOption]` (hasta 4; vacío si no hay ramas)

### 2.2 DialogueOption

- `text_key: String`, `next_id: String`, `conditions: Array[Dictionary]`
- `blocked_text_key: String` (texto alternativo si falla la condición, tipo candado)
- `effect: Array[Dictionary]` (efecto al elegir)

### 2.3 DialogueGraph

- `dialogue_id: String`, `start_node_id: String`, `nodes: Dictionary`
- `static load_from_json(path: String) -> DialogueGraph`
- `validate() -> Array[ValidationIssue]` (errores y advertencias)
- `get_node_by_id(id: String) -> DialogueNode`
- `get_start_node() -> DialogueNode`

### 2.4 DialogueManager (autoload, capa máquina)

Estado de la conversación actual: grafo activo, nodo actual, entradas de UI, variables de sesión. Desconocen la UI; se comunican por señales.

### 2.5 DialogueUI (escena Canvas, capa presentación)

Caja de diálogo con nombre/retrato del hablante, área de texto con tipografía progresiva, lista de opciones y estados de entrada. Emite señales (`confirm_pressed`, `option_pressed(index)`) que el manager interpreta.

### 2.6 DialogueTrigger

- `dialogue_id: String`, `auto: bool (trigger por proximidad)`, `cooldown: float`
- `interact() -> void` (llamada por interacción del jugador/M19/M64)

### 2.7 DialogueValidator

Chequeos estáticos sobre el grafo cargado (ver checklist C): IDs duplicados, `next`/`goto` inexistentes, nodo huérfano, ciclos, condiciones sintácticamente inválidas, referencias a variables desconocidas, inicio faltante.

## 3. Contratos de API GDScript

```gdscript
# DialogueManager (autoload "DialogueManager" en project.godot)
func start_dialogue(dialogue_id: String, context: Dictionary = {}) -> bool
func stop_dialogue() -> void
func advance() -> void                 # siguiente nodo lineal (o salta línea si tipeando)
func choose_option(index: int) -> void
func is_dialogue_active() -> bool
func get_current_speaker_key() -> String
func get_current_text_key() -> String
func resolve_text(text_key: String, placeholders: Dictionary) -> String

signal dialogue_started(dialogue_id: String)
signal dialogue_ended(dialogue_id: String, last_node_id: String)
signal node_entered(node_id: String)
signal line_complete()
signal option_selected(option_index: int)

# DialogueGraph
static func load_from_json(path: String) -> DialogueGraph
func validate() -> Array                 # Lista de ValidationIssue
func get_start_node() -> DialogueNode
func get_node_by_id(id: String) -> DialogueNode

# DialogueNode
func evaluate_conditions(world_state: Dictionary) -> bool
func apply_effects(event_bus: Node) -> void

# DialogueUI
func show_line(speaker_key: String, text: String) -> void
func show_options(options: Array[Dictionary]) -> void
func set_typing_speed(wpm: int) -> void
func reset() -> void
func set_auto_advance(enabled: bool, seconds: float) -> void

signal confirm_pressed()
signal option_pressed(index: int)
signal typing_finished()

# DialogueTrigger
func interact() -> void
```

## 4. Flujos principales (en texto)

### Flujo A: Inicio y transición lineal

1. Jugador presiona interactuar sobre un NPC → `DialogueTrigger.interact()`.
2. El trigger llama `DialogueManager.start_dialogue(dialogue_id)`.
3. El manager carga el grafo (cacheado), valida si es primera carga, toma `get_start_node()`.
4. Emite `dialogue_started` y `node_entered`; pide a la UI `show_line(hablante, texto)`.
5. La UI tipea el texto; al terminar emite `typing_finished` (flecha visible).
6. El jugador confirma → `DialogueManager.advance()` → si el nodo tiene `next_id`, entra al siguiente; si es `FIN`, emite `dialogue_ended` y limpia.

### Flujo B: Salto rápido (skip)

1. Durante el tipeo, el jugador confirma (`confirm_pressed`).
2. Si el texto no está completo → la UI completa la línea al instante (sin avanzar de nodo).
3. Si el texto ya está completo → `advance()` pasa al siguiente nodo.
4. Doble confirmación sostenida (segunda en nodo siguiente) activa `skip_all` solo si el diálogo lo permite (flag del grafo).

### Flujo C: Opciones ramificadas

1. El nodo actual es de tipo `OPCIONES`.
2. El manager filtra las opciones con `evaluate_conditions(world_state)`.
3. Opciones bloqueadas se muestran con `blocked_text_key` (gris, no seleccionable) o se ocultan según flag `hide_blocked`.
4. La UI muestra la lista; el jugador navega (teclado/gamepad/mouse) y elige.
5. `DialogueManager.choose_option(index)` aplica `effect` del botón y salta a `next_id` de la opción.
6. Emite `option_selected`.

### Flujo D: Eventos de guion (nodo EVENTO)

1. El manager entra a un nodo tipo `EVENTO` (sin texto visible).
2. Ejecuta `effects` (cambiar amistad M19, activar misión M22, bandera de templo M23).
3. Salta a `next_id` o `goto_id` sin intervención del jugador.

### Flujo E: Cierre y limpieza

1. `FIN`, `stop_dialogue()` o cierre por distancia (NPC se aleja, M64).
2. Se emite `dialogue_ended`; el jugador recupera el control; la UI se oculta.

### Flujo F: Validación en carga

1. Al cargar un grafo (primera vez) o vía tool del editor.
2. `DialogueValidator` recorre nodos y arma `ValidationIssue` por cada anomalía.
3. Errores → log `[VAL-DGT]` y fallback amigable; advertencias → log sin bloquear.

## 5. Integraciones

| Módulo | Cómo se integra |
|---|---|
| M19 (amistad) | Niveles de amistad como condiciones (`{amistad_npc} >= 3`); efectos de opciones suben/bajan afinidad; NPC abre ramas nuevas según amistad |
| M22 (historias secundarias) | `effects` activan/actualizan objetivos de misión; respuestas cambian según etapa de la quest |
| M23 (templos y puzzles) | Textos de pistas y revelaciones; condiciones por sellos/secretos desbloqueados |
| M87 (fuentes tipográficas) | `dialogue_ui.tscn` usa las fuentes del sistema de M87 para textos y retratos; sin texto en imágenes |
| M29/M31 (tiempo, estaciones, clima) | Condiciones `{estacion}`, `{hora}`, `{clima}`; diálogos contextuales por franja horaria |
| M64 (IA de NPC) | NPC se detiene y mira al jugador durante la conversación; interrupción de rutina al iniciar diálogo |
| M73 (eventos/festivales) | Diálogos especiales por evento; festivales desbloquean ramas temporales |
| M17 (obras) | Reacciones a construcciones del jugador vía banderas del mundo |

## 6. Reglas de diseño

- La UI jamás consulta el grafo: solo recibe `show_line`/`show_options` y emite entradas.
- El manager jamás referencia nodos del Canvas: se comunica por señales.
- Todo texto de runtime sale de `resolve_text()` (claves + placeholders); nunca strings literales en gameplay.
- Condiciones y efectos usan exclusivamente `WorldStateService` (capa única) para no duplicar estado.
- Un diálogo activo pausa la acción del jugador (M29 respeta pausa del reloj).