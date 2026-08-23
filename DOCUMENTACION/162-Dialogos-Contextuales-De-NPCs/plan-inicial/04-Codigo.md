**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 162: Diálogos Contextuales de NPCs

## 1. Archivos Involucrados

### 1.1 Archivos de Este Módulo
| Archivo | Propósito |
|---------|-----------|
| `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-inicial/01-Requerimientos.md` | Requisitos funcionales |
| `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-inicial/02-Analisis.md` | Análisis de alternativas |
| `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-inicial/03-Diseno.md` | Diseño de diálogos (1406 líneas) |
| `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-inicial/04-Codigo.md` | Este archivo |
| `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-inicial/05-Checklist.md` | Checklist de tareas |

### 1.2 Archivos de Módulos Relacionados (lectura)
| Módulo | Archivo | Razón |
|--------|---------|-------|
| M21 | `plan-actual/01-Requerimientos.md` | Motor de diálogos nodales, JSON, condiciones |
| M22 | `plan-actual/03-Diseno.md` | 7 capítulos, grafo de escenas, eventos |
| M19 | `plan-actual/01-Requerimientos.md` | 23 NPCs, personalidades, rutinas |
| M161 | `plan-actual/01-Requerimientos.md` | Diseño visual de NPCs |
| M20 | `plan-actual/01-Requerimientos.md` | Sistema de amistad (3 niveles) |
| M29 | `plan-actual/01-Requerimientos.md` | Tiempo, estaciones, hora |
| M160 | `plan-actual/01-Requerimientos.md` | 46 ubicaciones, LOC-ISLA-TIPO-NUMERO |

### 1.3 Archivos de Código a Crear (fase de implementación)
| Archivo | Propósito |
|---------|-----------|
| `scripts/dialogues/dialogue_data.gd` | Recursos GDScript para diálogos |
| `scripts/dialogues/dialogue_manager.gd` | Gestor de diálogos contextuales |
| `scripts/dialogues/dialogue_conditions.gd` | Evaluador de condiciones |
| `data/dialogues/` | Archivos JSON por NPC (23 archivos) |
| `scripts/resources/dialogue_resource.gd` | Resource para diálogos |

## 2. Funciones Clave

### 2.1 DialogueManager (gestor principal)
```gdscript
# scripts/dialogues/dialogue_manager.gd
class_name DialogueManager
extends Node

## Obtiene el diálogo apropiado para un NPC dado el contexto actual
func get_dialogue(npc_id: String, tipo: String) -> Dictionary:
    # 1. Obtener capítulo actual de game_progress
    # 2. Obtener nivel de amistad del NPC
    # 3. Obtener estación y hora del mundo
    # 4. Buscar diálogos del NPC para el capítulo
    # 5. Filtrar por condiciones (amistad, estación, hora)
    # 6. Aplicar prioridad si hay múltiples válidos
    # 7. Retornar el diálogo seleccionado

## Verifica si un diálogo cumple todas las condiciones
func check_conditions(dialogue: Dictionary, context: Dictionary) -> bool:
    # Evaluar cada condición del diálogo contra el contexto

## Obtiene todos los diálogos disponibles para un NPC
func get_all_dialogues(npc_id: String) -> Array:
    # Retornar lista completa de diálogos del NPC
```

### 2.2 DialogueConditions (evaluador)
```gdscript
# scripts/dialogues/dialogue_conditions.gd
class_name DialogueConditions
extends RefCounted

## Evalúa condición de capítulo
static func check_chapter(condition: Dictionary, chapter: int) -> bool:
    # Verificar min/max del capítulo

## Evalúa condición de amistad
static func check_friendship(condition: Dictionary, friendship: int) -> bool:
    # Verificar min/max de amistad

## Evalúa condición de estación
static func check_season(condition: Dictionary, season: String) -> bool:
    # Verificar estación requerida

## Evalúa condición de hora
static func check_hour(condition: Dictionary, hour: int) -> bool:
    # Verificar franja horaria (mañana/tarde/noche)

## Evalúa condición de ubicación
static func check_location(condition: Dictionary, location: String) -> bool:
    # Verificar ubicación del jugador
```

### 2.3 DialogueResource (recurso)
```gdscript
# scripts/resources/dialogue_resource.gd
class_name DialogueResource
extends Resource

@export var dialogue_id: String
@export var npc_id: String
@export var tipo: String  # SALUDO, HISTORIA, MISION, AMBIENTE, AMISTAD, ESTACIONAL, HORA
@export var capitulo: int  # 0-7
@export var condiciones: Dictionary
@export var nodes: Array[Dictionary]
@export var prioridad: int  # 0=baja, 1=media, 2=alta
```

## 3. Estructura de Datos JSON

### 3.1 Formato por NPC
```json
{
  "npc_id": "NPC-RIZ-001",
  "npc_name": "Mayor del Pueblo",
  "isla": "RIZ",
  "dialogues": [
    {
      "dialogue_id": "DLG-RIZ-001-CAP0-SALUDO",
      "tipo": "SALUDO",
      "capitulo": 0,
      "condiciones": {
        "game_progress.chapter": {"min": 0, "max": 0},
        "friendship": {"min": 0, "max": 100}
      },
      "prioridad": 1,
      "nodes": [
        {
          "id": "start",
          "text": "¡Bienvenido a Aurora! Soy el mayor de este pueblo.",
          "next": "end"
        }
      ]
    }
  ]
}
```

### 3.2 Variables de Estado (M21)
| Variable | Tipo | Rango | Uso en M162 |
|----------|------|-------|-------------|
| `game_progress.chapter` | int | 0-7 | Capítulo actual de la historia |
| `friendship[npc_id]` | int | 0-100 | Nivel de amistad con el NPC |
| `world.season` | String | PRIMAVERA/VERANO/OTONIO/INVIERNO | Estación actual |
| `world.hour` | int | 0-23 | Hora del día |
| `player.location` | String | LOC-* | Ubicación actual del jugador |
| `quest.completed[quest_id]` | bool | true/false | Misión completada |

## 4. Flujo de Ejecución

```
1. Jugador habla con NPC
   ↓
2. DialogueManager.get_dialogue(npc_id, "SALUDO")
   ↓
3. Obtener contexto actual:
   - chapter = game_progress.chapter
   - friendship = friendship[npc_id]
   - season = world.season
   - hour = world.hour
   - location = player.location
   ↓
4. Cargar diálogos del NPC desde JSON
   ↓
5. Filtrar diálogos por capítulo
   ↓
6. Para cada diálogo restante:
   - Evaluar condiciones (amistad, estación, hora, ubicación)
   - Si todas pasan → candidato válido
   ↓
7. Si hay múltiples candidatos:
   - Seleccionar por prioridad (mayor prioridad gana)
   - Si empate → seleccionar aleatoriamente
   ↓
8. Si no hay candidatos:
   - Usar fallback: diálogo genérico del capítulo
   ↓
9. Retornar nodo de diálogo seleccionado
   ↓
10. M21 muestra el diálogo al jugador
```

## 5. Notas de Implementación

### 5.1 Organización de Archivos JSON
```
data/dialogues/
├── NPC-RIZ-001-mayor.json
├── NPC-RIZ-002-carpintero.json
├── NPC-RIZ-003-vendedora.json
├── NPC-RIZ-004-sabio.json
├── NPC-RIZ-005-pescador.json
├── NPC-RIZ-006-agricultora.json
├── NPC-RIZ-007-nina.json
├── NPC-RIZ-008-animador.json
├── NPC-COR-001-herrero.json
├── NPC-COR-002-pescadora.json
├── NPC-COR-003-comerciante.json
├── NPC-COR-004-guardia.json
├── NPC-COR-005-nina-playa.json
├── NPC-CEN-001-herrero-avanzado.json
├── NPC-CEN-002-minero.json
├── NPC-CEN-003-cocinera.json
├── NPC-CEN-004-bibliotecario.json
├── NPC-CEN-005-guardia-mina.json
├── NPC-AUR-001-encantador.json
├── NPC-AUR-002-sanadora.json
├── NPC-AUR-003-guardia-ancestral.json
├── NPC-AUR-004-artista.json
└── NPC-AUR-005-viajero-misterioso.json
```

### 5.2 Conteo de Diálogos por NPC
| NPC | Capítulos | Tipos por capítulo | Total estimado |
|-----|-----------|-------------------|----------------|
| Mayor RIZ | 8 | 3-4 | ~28 |
| Carpintero RIZ | 8 | 2-3 | ~20 |
| Vendedora RIZ | 8 | 2-3 | ~20 |
| Viejo Sabio RIZ | 8 | 2-3 | ~20 |
| Pescador RIZ | 8 | 2-3 | ~20 |
| Agricultora RIZ | 8 | 2-3 | ~20 |
| Niña RIZ | 8 | 1-2 | ~12 |
| Animador RIZ | 8 | 1-2 | ~12 |
| Herrero COR | 8 | 2-3 | ~20 |
| Pescadora COR | 8 | 2-3 | ~20 |
| Comerciante COR | 8 | 2-3 | ~20 |
| Guardia COR | 8 | 1-2 | ~12 |
| Niña Playa COR | 8 | 1-2 | ~12 |
| Herrero CEN | 8 | 2-3 | ~20 |
| Minero CEN | 8 | 2-3 | ~20 |
| Cocinera CEN | 8 | 2-3 | ~20 |
| Bibliotecario CEN | 8 | 2-3 | ~20 |
| Guardia Mina CEN | 8 | 1-2 | ~12 |
| Encantador AUR | 8 | 2-3 | ~20 |
| Sanadora AUR | 8 | 2-3 | ~20 |
| Guardia Ancestral AUR | 8 | 2-3 | ~20 |
| Artista AUR | 8 | 1-2 | ~12 |
| Viajero Misterioso AUR | 8 | 2-3 | ~20 |
| **TOTAL** | | | **~400** |

### 5.3 Integración con Sistema de Detección (M160)
- Los diálogos pueden referenciar ubicaciones usando IDs de M160
- Ejemplo: `player.location == "LOC-RIZ-PUER-001"` para detectar si el jugador está en el puerto

### 5.4 Extensibilidad
- Agregar un NPC nuevo: crear JSON + agregar entradas en DialogueManager
- Agregar un capítulo nuevo: agregar entradas en cada JSON existente
- Agregar un tipo de diálogo nuevo: agregar caso en DialogueManager.get_dialogue()

## 6. Logs Relacionados
- Ver `Logs/` para registros de creación de este módulo
- Commit de creación: pendiente
