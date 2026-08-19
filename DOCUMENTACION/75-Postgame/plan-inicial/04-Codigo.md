**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 75: Postgame

## 1. Archivos Involucrados

| Archivo | Ruta (proyecto) | Tipo | Estado |
|---|---|---|---|
| `postgame_manager.gd` | `Assets/_Project/Scripts/Postgame/` | Servicio (autoload) | Prototipo de diseño (sin editor Godot) |
| `postgame_catalog.tres` | `Assets/_Project/Data/Postgame/` | Resource | Prototipo de diseño (sin editor Godot) |
| `validate_postgame.gd` | `Assets/_Project/Editor/` | Validación | Prototipo de diseño (sin editor Godot) |
| `postgame_catalog` (ResourceScript) | `Assets/_Project/Scripts/Data/` | Definición de datos | Prototipo de diseño (sin editor Godot) |
| `roadmap_source.gd` (interface) | `Assets/_Project/Scripts/Postgame/` | Contrato | Prototipo de diseño (sin editor Godot) |

## 2. Funciones Clave

### 2.1 `postgame_manager.gd` — Orquestador

| Función | Firma | Propósito |
|---|---|---|
| `unlock_postgame()` | `void` | Desbloquea el postgame al terminar M22; guarda `postgame_unlocked` (M59) |
| `is_postgame_unlocked()` | `bool` | Estado del postgame (fuente: save M59) |
| `get_roadmap()` | `Dictionary` | Hoja de ruta: % por categoría derivado de cada sistema |
| `get_next_goal()` | `String` | Próxima meta visible (anti-spoiler M55) |
| `get_expansion(id)` | `PostgameExpansion` | Acceso al catálogo (fase 2 interna, `hidden`) |
| `on_festival_postgame()` | `void` | Enlace M74: festival postgame rotativo |

### 2.2 `postgame_catalog.tres` — Catálogo declarativo

| Campo | Tipo | Propósito |
|---|---|---|
| `id` | `String` | Identificador unívoco de la expansión |
| `nombre` | `String` | Nombre para diseñador (i18n M92 para jugador) |
| `fase` | `int` | 1 = lanzamiento, 2 = post-lanzamiento |
| `requisito` | `String` | Condición de desbloqueo |
| `modulo` | `String` | Módulo dueño (M27, M51, M10...) |
| `hidden` | `bool` | Oculto al jugador hasta lanzamiento |

### 2.3 `roadmap_source.gd` — Contrato de hoja de ruta

```gdscript
class_name RoadmapSource
## Contrato: cada sistema expone su % de completado sin spoilers.

func total_conocido() -> int: pass
func completado() -> int: pass
func proxima_meta() -> String: pass
```

Implementado por: M73 (colecciones), M37 (museo), M25 (ruinas), M24 (puzzles), M16 (recetas), M17 (mejoras), M74 (eventos).

### 2.4 `validate_postgame.gd` — Validación (test validable)

| Método | Propósito |
|---|---|
| `validate_expansions()` | `id` únicos; `fase` ∈ {1,2}; `modulo` existe |
| `validate_achievements()` | Logros Epílogo (M72) referencian hitos reales |
| `validate_roadmap()` | Cada fuente responde el contrato |
| `validate_events()` | Fechas M29 sin colisión |

## 3. Fragmento de Núcleo (prototipo de diseño)

```gdscript
# postgame_manager.gd — núcleo del postgame (M75)
extends Node

signal postgame_unlocked

const CATALOG := preload("res://Assets/_Project/Data/Postgame/postgame_catalog.tres")

var _unlocked := false
var _roadmap_sources: Dictionary = {}

func _ready() -> void:
    _unlocked = SaveManager.get_flag("postgame_unlocked", false)   # M59

func unlock_postgame() -> void:
    if _unlocked: return
    _unlocked = true
    SaveManager.set_flag("postgame_unlocked", true)                # M59
    DayNightCycle.events.show_cutscene("epilogo")                  # M22 epílogo
    TutorialManager.show_hint("ap_despues_del_final")              # M92
    postgame_unlocked.emit()

func get_roadmap() -> Dictionary:
    var roadmap := {}
    for key in _roadmap_sources:
        var src: RoadmapSource = _roadmap_sources[key]
        roadmap[key] = {
            "total": src.total_conocido(),      # anti-spoiler (M55)
            "done": src.completado(),
        }
    return roadmap

func get_next_goal() -> String:
    for key in _roadmap_sources:
        var src: RoadmapSource = _roadmap_sources[key]
        if src.completado() < src.total_conocido():
            return src.proxima_meta()           # solo la próxima visible
    return "TR_AWA_100_COMPLETADO"
```

## 4. Logs de Ejecución (sin runtime Godot — estado honesto)

No existe editor/binary Godot en el entorno de trabajo: los `.gd` de este documento son **prototipos de diseño verificados estáticamente** (estructura y tipado por inspección). La ejecución queda pendiente para el entorno destino (sección 12 del AGENTS.md aplica al editor). Sin logs de runtime disponibles hoy.

## 5. Integración Clave (regla M15: no tocar lo que funciona)

- El M75 **NO modifica** M22, M73, M37, M55, M72, M74, M59: solo los configura (categoría "Epílogo" en M72, eventos postgame en M74) o los consulta (hoja de ruta).
- La única escritura nueva: `postgame_unlocked` en save global (M59, versión 1.4 vía M60).

## 6. Desfase Plan Maestro

- PLAN MAESTRO: sección 74 "POSTGAME" (20 ítems).
- TABLA GLOBAL: ID 75 — Postgame. Desfase = +1 (documentado por directiva del usuario).

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Completado (documentación de diseño; implementación pendiente)

### Lo que hice
- Documenté el postgame completo: catálogo de expansiones FASE 1/FASE 2, hoja de ruta del 100% anti-spoiler, logros finales (categoría Epílogo, M72), eventos rotativos postgame (M74/M29), epílogo (M22) y criterios de validación.
- La hoja de ruta es derivada (nunca almacenada): cada sistema responde `RoadmapSource` (M73/M37/M25/M24/M16/M17/M74).
- Diseñé `postgame_catalog.tres` declarativo con `fase` y `hidden`: la fase 2 (islas flotantes M10, arrecife M51, jardín acuático M16) es interna al diseñador, jamás visible al jugador (sin promesas rotas).
- Documenté reglas cozy: sin grindeo, sin fechas únicas missable, sin logros imposibles.

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Sin editor Godot ni build: los `.gd` son prototipos de diseño; la ejecución queda para el entorno destino (criterios de aceptación 6 y 8 pendientes de prueba real).
- `[?]` Logros Epílogo concretos (M72): el listado final de hitos postgame depende de la implementación de M72; aquí quedó la categoría y los hitos tipo (colección completa, ruina restaurada, primer festival).
- `[?]` Nombres/tipos de actores expandidos (vecinos M19, muebles M18, plantas M50, animales M36): el catálogo referencia los módulos; los insets concretos son de cada módulo.

### Intentos fallidos / decisiones
- Descartada la pestaña postgame propia (nueva UI duplicada): la hoja de ruta vive en el diario (M55) y el museo (M37). Registrado en 02-Analisis.md (alternativas A1/A2).
- Descartado el estado "postgame" dentro de M72 (acoplamiento historia-logros): los hitos van en la categoría "Epílogo".

### Recomendaciones para el próximo agente
- Implementar `RoadmapSource` como contrato primero y los adaptadores de M73/M37/M25/M24/M16/M17/M74 después (cero sorpresas).
- Al implementar M72, crear la categoría "Epílogo" y respetar el criterio "sin logros de grindeo".
- Los eventos postgame (M74) deben programarse en el calendario (M29) con ciclo anual, sin fechas únicas.
- Al lanzar una expansión FASE 2, cambiar `hidden=false` y agregar su data real en el módulo dueño (M27/M51/M10...).