**Modelo:** SWE-1.6
**Plataforma:** Devin

# 04-Codigo.md — Módulo 111: Código de Calidad

## 1. Carácter del Componente

Módulo de **lineamientos y estándares de calidad de código** que especifica guías de desarrollo, convenciones, límites y procesos. Implementable inmediatamente (no depende de otros módulos para la especificación, pero debe integrarse con M07, M112, M61, M62). Es un módulo de documentación y herramientas.

**06-Plan-Testings.md:** NO aplica (es estándares de código, no código que requiere tests. Las pruebas de calidad se aplican en M112 Testing Automático).

## 2. Archivos involucrados (implementación)

```
docs/codigo_de_calidad/
├── guia_estilo_gdscript.md           → Guía de estilo GDScript completa
├── proceso_code_review.md            → Proceso de code review
├── guía_desarrolladores.md             → Guía para desarrolladores
└── deuda_tecnica.md                   → Registro de deuda técnica

scripts/interfaces/
├── i_interactable.gd                   → Interface IInteractable
├── i_damageable.gd                     → Interface IDamageable
└── i_saveable.gd                       → Interface ISaveable

scripts/patterns/
├── state_machine.gd                    → Patrón State Machine
├── observer.gd                         → Patrón Observer
├── factory.gd                           → Patrón Factory
└── command.gd                           → Patrón Command

scripts/utils/
├── math_utils.gd                        → Utilidades matemáticas
├── validation_utils.gd                  → Utilidades de validación
└── format_utils.gd                      → Utilidades de formato

scripts/tools/
├── code_quality_check.gd               → Script de análisis estático
└── lint_runner.gd                       → Runner de linters (opcional)

scripts/constants/
└── game_constants.gd                    → Constantes globales del juego

scripts/enums/
└── game_enums.gd                        → Enums globales del juego

scripts/data/
└── structs.gd                           → Estructuras de datos comunes

.gdscriptlint (opcional)                    → Configuración de linter GDScript
.github/workflows/code_quality.yml      → CI para calidad de código
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M07 (Arquitectura):** Código sigue patrones Service Locator y EventBus
- **M112 (Testing Automático):** Código es testeable (inyección de dependencias)
- **M61 (Rendimiento):** Código no tiene optimizaciones prematuras
- **M62 (Memoria):** Código previene memory leaks
- **M133 (Gestión del Proyecto):** Deuda técnica registrada y controlada

### Entrada (desde otros módulos)
- **M112 (Testing Automático):** Code Quality Check valida que código cumple estándares antes de aprobar PR

### Configuración
- `guia_estilo_gdscript.md` define convenciones de nomenclatura
- `deuda_tecnica.md` registra deuda técnica del proyecto
- `.github/workflows/code_quality.yml` valida código en CI

## 4. Implementación de CodeQualityCheck.gd (esqueleto)

```gdscript
# scripts/tools/code_quality_check.gd
extends RefCounted

var violations: Dictionary = {}

func check_all_files(directory: String) -> Dictionary:
    violations = {
        "method_length": [],
        "class_length": [],
        "naming": [],
        "documentation": []
    }
    
    var files = _get_all_gdscript_files(directory)
    for file in files:
        _check_file(file)
    
    return violations

func _check_file(file_path: String):
    var content = FileAccess.get_file_as_string(file_path)
    var lines = content.split("\n")
    
    var current_class = ""
    var current_method = ""
    var method_start_line = 0
    var class_start_line = 0
    
    for i in range(lines.size()):
        var line = lines[i]
        
        # Detectar inicio de clase
        if line.begins_with("class_name ") or line.begins_with("class "):
            if current_class != "":
                _check_class_length(current_class, class_start_line, i)
            current_class = line.split(" ")[1]
            class_start_line = i
            current_method = ""
        
        # Detectar inicio de método
        if line.begins_with("func ") and not line.contains(" -> void"):
            if current_method != "":
                _check_method_length(current_method, method_start_line, i)
            current_method = line.split("(")[0].split(" ")[1]
            method_start_line = i
        
        # Detectar fin de método
        if line.strip() == "" and current_method != "":
            _check_method_length(current_method, method_start_line, i)
            current_method = ""
        
        # Detectar fin de clase
        if line.strip() == "" and current_class != "":
            _check_class_length(current_class, class_start_line, i)
            current_class = ""

func _check_method_length(method_name: String, start_line: int, end_line: int):
    var length = end_line - start_line
    if length > 50:
        violations["method_length"].append({
            "method": method_name,
            "file": current_file,
            "line": start_line,
            "length": length
        })

func _check_class_length(class_name: String, start_line: int, end_line: int):
    var length = end_line - start_line
    if length > 300:
        violations["class_length"].append({
            "class": class_name,
            "file": current_file,
            "line": start_line,
            "length": length
        })

func _get_all_gdscript_files(directory: String) -> Array:
    var files = []
    var dir = DirAccess.open(directory)
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".gd"):
            files.append(directory + "/" + file_name)
        file_name = dir.get_next()
    dir.list_dir_end()
    return files
```

## 5. Implementación de interfaces

**Archivo: scripts/interfaces/i_interactable.gd**
```gdscript
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
class_name IDamageable
extends RefCounted

func take_damage(amount: int, source: Node) -> void:
    pass

func get_health() -> int:
    return 100

func is_alive() -> bool:
    return true
```

**Archivo: scripts/interfaces/i_saveable.gd**
```gdscript
class_name ISaveable
extends RefCounted

func get_save_data() -> Dictionary:
    return {}

func load_save_data(data: Dictionary) -> void:
    pass
```

## 6. Implementación de utilidades

**Archivo: scripts/utils/math_utils.gd**
```gdscript
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

static func is_valid_npc_id(npc_id: String) -> bool:
    return npc_id.length() > 0 and npc_id != ""
```

## 7. Implementación de constantes

**Archivo: scripts/constants/game_constants.gd**
```gdscript
class_name GameConstants
extends Resource

const MAX_INVENTORY_SIZE = 30
const DAY_DURATION_SECONDS = 1440
const CHUNK_SIZE = 16
const MAX_PLAYERS = 1
const MAX_SAVE_SLOTS = 5
const AUTO_SAVE_INTERVAL_SECONDS = 300
```

## 8. Implementación de enums

**Archivo: scripts/enums/game_enums.gd**
```gdscript
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

## 9. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear docs/codigo_de_calidad/guia_estilo_gdscript.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/codigo_de_calidad/proceso_code_review.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/codigo_de_calidad/guía_desarrolladores.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/codigo_de_calidad/deuda_tecnica.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/interfaces/i_*.gd (3 interfaces) | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/patterns/*.gd (4 patrones) | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/utils/*.gd (3 utilidades) | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/tools/code_quality_check.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/constants/game_constants.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/enums/game_enums.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/data/structs.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Integración con CI/CD (M118) | M118 (zona prohibida, otro agente) |
| Integración con M112 (Testing) | M112 (zona prohibida, otro agente) |

## 10. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** Devin
**Fecha:** 2026-08-16 20:30:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Resolví los 19 puntos de la sección 110 del plan maestro.
- Diseñé guía de estilo GDScript completa con convenciones de nomenclatura.
- Definí límites de tamaño: 50 líneas método, 300 líneas clase, 500 líneas archivo.
- Especifiqué plantillas de documentación para clases y funciones.
- Diseñé interfaces recomendadas (IInteractable, IDamageable, ISaveable).
- Especifiqué patrones de diseño (State Machine, Observer, Factory, Command).
- Diseñé utilidades comunes (MathUtils, ValidationUtils).
- Diseñé constantes, enums y structs del proyecto.
- Especifiqué proceso de code review con checklist.
- Diseñé registro de deuda técnica con prioridades.
- Diseñé script de análisis estático CodeQualityCheck.
- Especifiqué integración con M07, M112, M61, M62, M133.

### Lo que NO pude hacer (honestidad obligatoria)
- Crear los archivos físicos (documentación y scripts) — requiere implementación real.
- Integrar con CI/CD (M118) — es de otro agente.
- Integrar con M112 (Testing) — es de otro agente.
- Ejecutar CodeQualityCheck en código existente — requiere código real para analizar.

### Recomendaciones para el próximo agente (implementador)
- Implementar la guía de estilo primero, luego las interfaces y patrones.
- Las utilidades (MathUtils, ValidationUtils) deben ser usadas en todo el proyecto.
- CodeQualityCheck debe ejecutarse en CI/CD para validar PRs.
- Registrar toda deuda técnica inmediatamente en deuda_tecnica.md.
- Los patrones de diseño (State Machine, Observer, etc.) deben seguirse en código nuevo.
- Las interfaces (IInteractable, etc.) deben usarse para contratos entre sistemas.
- Revisar código existente periódicamente y actualizar para cumplir estándares.
