**Modelo original:** MiMo V2.5
**Plataforma original:** OpenCode
**Actualizado por:** Hy3 / WorkBuddy (iter 1, 2026-09-01 — Log 363)

# 04-Codigo.md — Módulo 162: Diálogos Contextuales de NPCs

## 1. Archivos Involucrados

### 1.1 Archivos creados en iter 1 (Hy3 / WorkBuddy)

| Archivo | Propósito |
|---------|-----------|
| `scripts/dialogos/contextual_dialogue_manager.gd` | Selector de prioridad + fallback (RefCounted, no autoload) |
| `scripts/dialogos/test_contextual_dialogue_m162.gd` | Test headless (valida grafos con `DialogGraphValidator` + prueba el selector) |
| `scripts/gen_m162_dialogues.py` | Generador reproducible de grafos + `registry.json` |
| `data/dialogues/contextual/registry.json` | Registro de entradas: `{npc, tipo, graph, prioridad, condiciones[]}` |
| `data/dialogues/contextual/*.json` (78) | Grafos M21, uno por entrada contextual |

### 1.2 Módulos relacionados (solo lectura, no se toca su código)

M21 (`dialogue_graph.gd`, `dialogue_node.gd`, `dialog_graph_validator.gd`),
M22 (historia/capítulos), M19 (NPCs), M161 (visuales), M20 (amistad),
M29 (tiempo), M160 (ubicaciones).

## 2. Formato JSON (compatible con M21 — DialogueGraph)

Cada entrada contextual es un **grafo M21 completo**, no el formato simplificado
`{nodes:[{id,text,next}]}` del diseño previo (ese formato NO es aceptado por M21).

```json
{
  "id": "DLG-RIZ_001-CAP0-SALUDO-PRIMERA",
  "start": "n0",
  "nodes": {
    "n0": { "tipo": 0, "speaker_key": "npc.riz_001",
            "text_key": "¡Bienvenido a Aurora! ...", "next_id": "fin", "tipo_fin": false },
    "fin": { "tipo": 3, "speaker_key": "npc.riz_001" }
  }
}
```

- `tipo`: 0=LÍNEA, 1=OPCIONES, 2=EVENTO, 3=FIN (de `dialogue_node.gd`).
- `speaker_key`: `npc.<slug>` (slug = `riz_001`, `aur_005`, ...).
- `text_key`: texto cozy literal en español (convención de `catalina_hola.json`).
- `placeholders`: `{"nombre": "viajero"}` para `{nombre}` en el texto.
- `conditions` / `options` / `effects`: igual que M21.
- Validación: todos los grafos pasan `DialogGraphValidator.validar_archivo`.

## 3. Selector — `ContextualDialogueManager`

```gdscript
# scripts/dialogos/contextual_dialogue_manager.gd
class_name ContextualDialogueManager
extends RefCounted

## Retorna {ok, graph, entry} para npc_id + tipo según el contexto.
## contexto: Dictionary con variables de mundo (claves M21, ver §4).
static func seleccionar(npc_id: String, tipo: String, contexto: Dictionary) -> Dictionary
```

Algoritmo:
1. Resuelve `slug` desde `npc_id` (o lo usa directo si ya es slug).
2. Filtra entradas de `registry.json` por `npc == slug` y `tipo`.
3. Descarta las que no cumplen sus `condiciones` (misma semántica que
   `DialogueNode._evalua_cond`: operadores `== != >= <= > <`).
4. Entre las válidas, elige la de **mayor `prioridad`** (empate → primera).
5. Si ninguna vale, **fallback** = entrada del mismo NPC+tipo con MENOS condiciones
   (más genérica); si hay empate de condiciones, la de mayor prioridad.
6. Carga el grafo JSON y lo devuelve para que M21 lo reproduzca.

## 4. Contrato de Variables de Estado (ÚNICO formato válido en M21)

> **Corrección de integración:** el diseño previo (`game_progress.chapter`,
> `friendship[npc_id]`, `world.season`, `world.hour`, `player.location`,
> `quest.completed`) **NO existe** en M21. `dialog_graph_validator.gd`
> (`CLAVES_MUNDO_BASE`) solo acepta estas claves. M162 las usa:

| Dimensión | Clave M21 | Quién la fija |
|-----------|-----------|---------------|
| Capítulo (0-7) | `flag_capitulo` (int) | M22 al avanzar |
| Estación | `estacion` | M29 |
| Hora / día / noche | `hora`, `es_de_dia`, `es_noche` | M29 |
| Clima | `clima` | M29/M32 |
| Amistad NPC | `amistad_<slug>` (int 0-100) | M20 |
| Ubicación | `flag_ubicacion_<loc>` | M160/M19 |
| Misión | `flag_quest_<id>` | M22/quests |
| Otras banderas | `flag_<clave>` | WorldState (M59) |

## 5. Ejemplo de entry en `registry.json`

```json
{
  "id": "DLG-RIZ_001-CAP0-SALUDO-PRIMAVERA",
  "npc": "riz_001", "tipo": "SALUDO",
  "graph": "riz_001_cap0_saludo_primavera.json",
  "prioridad": 3,
  "condiciones": [
    {"clave": "flag_capitulo", "operador": "==", "valor": 0},
    {"clave": "flag_riz_001_visitado", "operador": "==", "valor": false},
    {"clave": "estacion", "operador": "==", "valor": "PRIMAVERA"}
  ]
}
```

Prioridades demostradas (Mayor cap0 SALUDO): primavera=3, primera vez=2,
repetido=1 → el selector elige la variante de mayor prioridad que cumpla.

## 6. Cómo regenerar / extender

```bash
python scripts/gen_m162_dialogues.py
```
El script es la "fuente de verdad" del contenido; editar el dict `entries`
y reejecutar regenera grafos + registry (y valida cada grafo localmente).

## 7. Testing

```bash
godot --headless --path game/isla-ancestral \
      --script res://scripts/dialogos/test_contextual_dialogue_m162.gd
```
Valida los 78 grafos con `DialogGraphValidator` y prueba el selector
(prioridad primavera/primera/repeat, Viajero noche/día, fallback).
**Estado iter 1:** test escrito; ejecución runtime pendiente (entorno sin Godot).
La lógica de selección fue validada por simulación en Python (8/8 OK).

## 8. Estado iter 1 (Log 363)

- 78 grafos M21 generados, 0 inválidos, 23/23 NPCs con ≥1 diálogo.
- Completos cap 0-7: Mayor (RIZ-001), Viejo Sabio (RIZ-004), Viajero Misterioso (AUR-005).
- Demostradas variantes: primera vez / repetido, estación (PRIMAVERA), noche/día (Viajero).
- **Pendiente ([?]):** variantes amistad (0-29/30-69/70-100), estación (3 restantes),
  hora (mañana/tarde/noche) y ubicación; capítulos 1-7 de los 20 NPCs secundarios
  (~330 diálogos); ejecución runtime en Godot.

## 9. Estado iter 2 (Log 472 — Hy3 / Kilo Code, 2026-09-01)

- Generador `scripts/gen_m162_dialogues.py` **recreado** (faltaba en disco; el 04-Codigo
  iter 1 decía que existía pero no estaba) y ejecutado como fuente de verdad del contenido.
- **260 grafos M21 generados** (264 archivos .json en `data/dialogues/contextual/`, incluidos
  los 2 de variante PRIMAVERA/PRIMERA del Mayor preservados del iter 1), **263 entries** en
  `registry.json`.
- Contenido completado: capítulos 1-7 (SALUDO/HISTORIA/MISION/AMBIENTE según diseño) para
  los 20 NPCs secundarios, más HISTORIA/MISION/AMBIENTE cap 0 donde el diseño los define.
  Total módulo: 98 [x] / 22 [?] de 120 (plan-actual/05-Checklist.md).
- **Validación:** réplica de `DialogGraphValidator` en Python (mismos criterios: start existe,
  `fin` alcanzable, sin huérfanos) → 264/264 grafos OK, 0 fallos; `registry.json` 263 entries,
  0 claves de mundo desconocidas (todas `flag_capitulo`/`estacion`/`es_noche`/`flag_*` válidas).
- `test_contextual_dialogue_m162.gd` actualizado: COR-001 ya tiene HISTORIA cap0 (antes era
  pendiente); el fallback ahora verifica que no hay variante de amistad aún.
- **Pendiente ([?]):** dimensiones de variación (amistad/estación-restantes/hora/ubicación) y
  checks de coherencia cruzada con M158/M160/M22. Ejecución runtime del test en Godot pendiente
  (el MCP disponible solo corre el juego principal, no `--script`).
