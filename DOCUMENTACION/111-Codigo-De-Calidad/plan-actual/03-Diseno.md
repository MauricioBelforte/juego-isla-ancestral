**Modelo:** SWE-1.6
**Plataforma:** Devin

# 03-Diseno.md — Módulo 111: Código de Calidad

## 1. Arquitectura del módulo

```
Código de Calidad (lineamientos y estándares)
├── Guía de Estilo GDScript
│   ├── Convenciones de nomenclatura
│   ├── Límites de tamaño (métodos, clases, archivos)
│   ├── Estructura de archivos
│   └── Plantillas de documentación
├── Patrones de Diseño
│   ├── Interfaces recomendadas
│   ├── EventBus (desacoplamiento)
│   ├── Service Locator (inyección de dependencias)
│   ├── ScriptableObject (datos estáticos)
│   └── State Machine (estados finitos)
├── Procesos
│   ├── Code Review
│   ├── Refactorización
│   └── Registro de Deuda Técnica
└── Herramientas
    ├── GDScript Linter
    ├── Godot Profiler
    └── Memory Inspector
```

## 2. Guía de Estilo GDScript (archivo central)

**Archivo: docs/codigo_de_calidad/guia_estilo_gdscript.md**

**Contenido:**
- Convenciones de nomenclatura (clases, funciones, variables, archivos)
- Límites de tamaño (50 líneas método, 300 líneas clase, 500 líneas archivo)
- Complejidad ciclomática (máx 10 por método)
- Anidamiento máximo (4 niveles)
- Estructura de archivos (organización por módulo)
- Plantillas de documentación (clases, funciones)

## 3. Plantillas de documentación

**Plantilla de clase:**
```gdscript
## [NombreClase]
##
## [Descripción breve de la clase]
##
## Dependencias
## - [Dependencia 1]
## - [Dependencia 2]
##
## Señales
## - [signal1](descripcion)
## - [signal2](descripcion)
##
## Métodos públicos
## - [metodo1](descripcion)
## - [metodo2](descripcion)
##
## Ejemplo de uso
## ```gdscript
## var instancia = NombreClase.new()
## instancia.metodo1()
## ```
class_name NombreClase
extends ClaseBase
```

**Plantilla de función:**
```gdscript
## [nombre_funcion]
##
## [Descripción de la función]
##
## @param [param1]: [descripcion]
## @param [param2]: [descripcion]
## @return: [descripcion del retorno]
func [nombre_funcion]([param1], [param2]) -> [tipo]:
```

## 4. Límites y métricas

**Tabla de límites:**
| Métrica | Límite | Herramienta de verificación |
|---------|--------|--------------------------|
| Líneas por método | 50 | GDScript Editor (contador de líneas) |
| Líneas por clase | 300 | GDScript Editor |
| Líneas por archivo | 500 | Split manual |
| Complejidad ciclomática | 10 | Calcular manualmente |
| Anidamiento máximo | 4 niveles | GDScript Editor (indentación) |
| Parámetros por función | 5 | Extraer a struct/dict si excede |

## 5. Interfaces recomendadas

**Archivo: scripts/interfaces/i_interactable.gd**
```gdscript
## IInteractable
##
## Objeto con el que el jugador puede interactuar.
##
## Métodos requeridos:
## - interact(player: Node3D) -> void
## - get_interaction_prompt() -> String
## - is_interactable() -> bool
class_name IInteractable
extends RefCounted

func interact(player: Node3D) -> void:
    pass

func get_interaction_prompt() -> String:
    return "Interactuar"

func is_interactable() -> bool:
    return true
```

**Archivo: scripts/interfaces/i_damageable.gd**
```gdscript
## IDamageable
##
## Entidad que puede recibir daño.
##
## Métodos requeridos:
## - take_damage(amount: int, source: Node) -> void
## - get_health() -> int
## - is_alive() -> bool
class_name IDamageable
extends RefCounted

func take_damage(amount: int, source: Node) -> void:
    pass

func get_health() -> int:
    return 100

func is_alive() -> bool:
    return true
```

## 6. Proceso de Code Review

**Archivo: docs/codigo_de_calidad/proceso_code_review.md**

**Checklist:**
- [ ] Código sigue convenciones de nomenclatura
- [ ] No hay código duplicado evidente
- [ ] Métodos dentro de límites de tamaño
- [ ] Clases dentro de límites de tamaño
- [ ] Documentación presente en APIs públicas
- [ ] No hay warnings de Godot
- [ ] Tests cubren cambios (M112)
- [ ] No introduce deudas técnicas sin registro
- [ ] No rompe backward compatibility
- [ ] Código es legible y mantenible

**Flujo:**
1. Autor crea Pull Request
2. Reviewer revisa código
3. Autor corrige según feedback
4. Reviewer aprueba (o solicita cambios)
5. Merge a main

## 7. Registro de Deuda Técnica

**Archivo: docs/codigo_de_calidad/deuda_tecnica.md**

**Formato:**
```markdown
| ID | Descripción | Prioridad | Estado | Dueño | Estimación |
|----|-------------|-----------|--------|-------|-----------|
| DT001 | Sistema de inventario monolítico | Alta | Pendiente | M14 | 2 días |
| DT002 | Generación de mundo sin tests | Alta | Pendiente | M10 | 3 días |
```

**Prioridades:**
- Alta: bloquea hito mayor
- Media: impacta performance o mantenibilidad
- Baja: mejoras no críticas

## 8. Script de análisis estático

**Archivo: scripts/tools/code_quality_check.gd**

**Funciones:**
- `check_method_length(file_path: String)` → Array de métodos que exceden 50 líneas
- `check_class_length(file_path: String)` → Array de clases que exceden 300 líneas
- `check_naming_conventions(file_path: String)` → Array de violaciones
- `check_documentation(file_path: String)` → Array de APIs sin documentación

**Uso:**
```gdscript
var checker = CodeQualityCheck.new()
var violations = checker.check_all_files("scripts/")
for violation in violations:
    Logger.warning("Code quality violation: %s" % violation)
```

## 9. Integración con CI/CD (M118)

**Archivo: .github/workflows/code_quality.yml**

**Steps:**
1. Ejecutar GDScript Linter
2. Ejecutar CodeQualityCheck
3. Si hay violaciones críticas → fallar build
4. Si hay warnings → notificar pero no fallar

## 10. Documentación para desarrolladores

**Archivo: docs/codigo_de_calidad/guia_desarrolladores.md**

**Contenido:**
- Cómo seguir la guía de estilo
- Cómo hacer code reviews
- Cómo registrar deuda técnica
- Cómo refactorizar código
- Cuándo optimizar (M61)
- Cómo prevenir memory leaks
- Cómo manejar errores

## 11. Reglas de calidad

### Regla 1: Convenciones obligatorias
- Seguir guía de estilo GDScript en todo código nuevo
- Revisar código existente y actualizar si es práctico
- Documentar desviaciones con justificación

### Regla 2: Límites de tamaño
- Nunca exceder límites sin justificación explícita
- Si excede, refactorizar inmediatamente

### Regla 3: Sin código duplicado
- Extraer lógica común a funciones reutilizables
- Usar interfaces para contratos compartidos

### Regla 4: Documentación obligatoria
- APIs públicas siempre documentadas
- Sistemas complejos siempre documentados
- Code smells siempre explicados

### Regla 5: Code reviews obligatorios
- Cambios en M07, M08, M59 requieren code review
- Cambios críticos en gameplay requieren code review
- Code reviews deben documentarse en PR

### Regla 6: Deuda técnica controlada
- Registrar toda deuda técnica introducida
- Priorizar resolución de deuda alta
- No introducir deuda sin justificación

### Regla 7: Tests obligatorios
- Todo nuevo código debe tener tests (M112)
- Cambios en código existente deben actualizar tests
- Coverage mínimo del 70% para código crítico

### Regla 8: Performance y memory
- No optimizar sin medir (M61)
- Prevenir memory leaks en desconexión de señales
- Validar compatibilidad con plataformas objetivo

## 12. Script de análisis estático (detallado)

**Archivo: scripts/tools/code_quality_check.gd**

**Clase principal:**
```gdscript
## CodeQualityCheck
##
## Herramienta de análisis estático de código GDScript.
##
## Funciones:
## - check_all_files(directory: String) -> Dictionary
## - check_method_length(file_path: String) -> Array
## - check_class_length(file_path: String) -> Array
## - check_naming_conventions(file_path: String) -> Array
## - check_documentation(file_path: String) -> Array
## - generate_report(directory: String) -> String
class_name CodeQualityCheck
extends RefCounted

var violations: Dictionary = {}

func check_all_files(directory: String) -> Dictionary:
    violations = {
        "method_length": [],
        "class_length": [],
        "naming": [],
        "documentation": []
    }
    
    var files = get_all_gdscript_files(directory)
    for file in files:
        _check_file(file)
    
    return violations

func generate_report(directory: String) -> String:
    var report = "=== Code Quality Report ===\n\n"
    report += "Method Length Violations: " + str(violations["method_length"].size()) + "\n"
    report += "Class Length Violations: " + str(violations["class_length"].size()) + "\n"
    report += "Naming Violations: " + str(violations["naming"].size()) + "\n"
    report += "Documentation Violations: " + str(violations["documentation"].size()) + "\n"
    
    return report
```

## 13. Patrones de diseño específicos

**State Machine Pattern:**
- Archivo: scripts/patterns/state_machine.gd
- Usado para: AI de NPC (M64), estados de jugador (M11), puzzles (M24)
- Beneficios: transiciones controladas, debug fácil, extensión simple

**Observer Pattern:**
- Archivo: scripts/patterns/observer.gd
- Usado para: EventBus (M07), eventos del juego
- Beneficios: desacoplamiento, suscriptores dinámicos

**Factory Pattern:**
- Archivo: scripts/patterns/factory.gd
- Usado para: creación de NPCs, items, objetos dinámicos
- Beneficios: centralización de creación, easy mock para tests

**Command Pattern:**
- Archivo: scripts/patterns/command.gd
- Usado para: acciones del jugador, sistema de undo/redo
- Beneficios: acciones deshacibles, colas de comandos

## 14. Utilidades comunes

**Archivo: scripts/utils/math_utils.gd**
```gdscript
## MathUtils
##
## Utilidades matemáticas comunes.
##
## Funciones:
## - distance_squared(p1: Vector3, p2: Vector3) -> float
## - lerp(a: float, b: float, t: float) -> float
## - clamp(value: float, min: float, max: float) -> float
## - normalize_angle(angle: float) -> float
class_name MathUtils
extends RefCounted

static func distance_squared(p1: Vector3, p2: Vector3) -> float:
    return (p1 - p2).length_squared()

static func lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t

static func clamp(value: float, min_val: float, max_val: float) -> float:
    return max(min_val, min(value, max_val))

static func normalize_angle(angle: float) -> float:
    angle = fmod(angle, 360.0)
    if angle < 0:
        angle += 360.0
    return angle
```

**Archivo: scripts/utils/validation_utils.gd**
```gdscript
## ValidationUtils
##
## Utilidades de validación de datos.
##
## Funciones:
## - is_valid_position(position: Vector3) -> bool
## - is_valid_item_id(item_id: String) -> bool
## - is_valid_npc_id(npc_id: String) -> bool
## - is_valid_mission_id(mission_id: String) -> bool
class_name ValidationUtils
extends RefCounted

static func is_valid_position(position: Vector3) -> bool:
    if not is_finite(position):
        return false
    if position.y < -1000 or position.y > 1000:
        return false
    return true

static func is_valid_item_id(item_id: String) -> bool:
    return item_id.length() > 0 and item_id != ""
```

## 15. Constantes del proyecto

**Archivo: scripts/constants/game_constants.gd**
```gdscript
## GameConstants
##
## Constantes globales del juego.
##
## Constantes:
## - MAX_INVENTORY_SIZE: Tamaño máximo del inventario
## - DAY_DURATION_SECONDS: Duración del día en segundos
## - CHUNK_SIZE: Tamaño del chunk en voxels
## - MAX_PLAYERS: Máximo de jugadores (si multiplayer)
class_name GameConstants
extends Resource

const MAX_INVENTORY_SIZE = 30
const DAY_DURATION_SECONDS = 1440
const CHUNK_SIZE = 16
const MAX_PLAYERS = 1  # Single-player por ahora
```

## 16. Enums del proyecto

**Archivo: scripts/enums/game_enums.gd**
```gdscript
## GameEnums
##
## Enums globales del juego.
##
## Enums:
## - State: Estados finitos comunes
## - Category: Categorías de entidades
## - Priority: Prioridades de acciones
class_name GameEnums
extends Resource

enum State {
    IDLE,
    WALKING,
    RUNNING,
    INTERACTING,
    HURT,
    DEAD
}

enum Category {
    GAMEPLAY,
    UI,
    AUDIO,
    SYSTEM
}

enum Priority {
    LOW,
    MEDIUM,
    HIGH,
    IMMEDIATE
}
```

## 17. Estructuras de datos

**Archivo: scripts/data/structs.gd**
```gdscript
## Structs
##
## Estructuras de datos comunes.
##
## Structs:
## - PlayerData: Datos del jugador
## - ItemData: Datos de items
## - NPCData: Datos de NPC
class_name Structs
extends Resource

class PlayerData:
    var position: Vector3
    var health: int
    var inventory: Array
    var equipment: Dictionary

class ItemData:
    var id: String
    var name: String
    var description: String
    var stack_size: int
    var rarity: String

class NPCData:
    var id: String
    var name: String
    var position: Vector3
    var schedule: Dictionary
    var friendship_level: int
```

## 18. Configuración de linting

**Archivo: .gdscriptlint (si gdlint está disponible)**
```ini
[style]
max_line_length = 120
max_function_length = 50
max_class_length = 300
max_function_parameters = 5
max_nesting_depth = 4
```

## 19. Integración con Godot Editor

**Ajustes en Project Settings:**
- Habilitar GDScript Linter en Editor Settings
- Configurar warnings como errores críticos
- Habilitar "Warn On Return" para funciones que deben retornar
- Configurar "Warn On Unused Signal" para señales no conectadas

## 20. Proceso de refactorización

**Pasos:**
1. Identificar código que necesita refactorización (deuda técnica, code smells)
2. Escribir tests para el código existente (M112)
3. Refactorizar paso a paso (métodos pequeños)
4. Verificar que tests pasen después de cada paso
5. Actualizar documentación
6. Registrar cambios en AGENTS.md o log

## 21. Integración con módulos específicos

**Con M07 (Arquitectura):**
- Seguir patrones de Service Locator y EventBus
- Usar interfaces para contratos entre sistemas
- Mantener separación de capas

**Con M112 (Testing Automático):**
- Código testeable (inyección de dependencias)
- Límites claros (input → output)
- Manejo de errores sin crashear

**Con M61 (Rendimiento):**
- No optimizar sin medir
- Usar profiler para identificar cuellos de botella
- Optimizar solo cuando FPS baja en áreas específicas

**Con M62 (Memoria):**
- Validar que no hay memory leaks
- Usar Memory Inspector para monitorear uso
- Liberar recursos cuando no se usan

## 22. Checklist de calidad por commit

**Antes de commit:**
- [ ] No hay warnings de Godot
- [ ] Código sigue convenciones de nomenclatura
- [ ] Métodos dentro de límites de tamaño
- [ ] Clases dentro de límites de tamaño
- [ ] APIs públicas documentadas
- [ ] Tests pasan (M112)
- [ ] No introduce deuda técnica sin registro

**Después de commit:**
- [ ] Actualizar AGENTS.md si hubo deuda técnica
- [ ] Crear log de cambios (Logs/)
- [ ] Actualizar CHECKLIST-GLOBAL si corresponde
- [ ] Verificar que build compila sin errores

## 23. Reglas de calidad

### Regla 1: Convenciones obligatorias
- Seguir guía de estilo GDScript en todo código nuevo
- Revisar código existente y actualizar si es práctico
- Documentar desviaciones con justificación

### Regla 2: Límites de tamaño
- Nunca exceder límites sin justificación explícita
- Si excede, refactorizar inmediatamente

### Regla 3: Sin código duplicado
- Extraer lógica común a funciones reutilizables
- Usar interfaces para contratos compartidos

### Regla 4: Documentación obligatoria
- APIs públicas siempre documentadas
- Sistemas complejos siempre documentados
- Code smells siempre explicados

### Regla 5: Code reviews obligatorios
- Cambios en M07, M08, M59 requieren code review
- Cambios críticos en gameplay requieren code review
- Code reviews deben documentarse en PR

### Regla 6: Deuda técnica controlada
- Registrar toda deuda técnica introducida
- Priorizar resolución de deuda alta
- No introducir deuda sin justificación

### Regla 7: Tests obligatorios
- Todo nuevo código debe tener tests (M112)
- Cambios en código existente deben actualizar tests
- Coverage mínimo del 70% para código crítico

### Regla 8: Performance y memory
- No optimizar sin medir (M61)
- Prevenir memory leaks en desconexión de señales
- Validar compatibilidad con plataformas objetivo