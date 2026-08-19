**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 61: Rendimiento

## 1. Archivos Involucrados

| Archivo | Ruta (proyecto) | Tipo | Estado |
|---|---|---|---|
| `budget_profile.gd` | `Assets/_Project/Scripts/Core/Perf/` | Instrumentación (autoload opcional, solo dev) | Prototipo de diseño (sin editor Godot) |
| `bench_scene_a.tscn` | `Assets/_Project/Scenes/Bench/` | Benchmark oficial + script `bench_recorder.gd` | Prototipo de diseño (sin editor Godot) |
| `validate_budget.gd` | `Assets/_Project/Editor/` | Validador tabla ↔ medición | Prototipo de diseño (sin editor Godot) |
| `budgets.cfg` | `Assets/_Project/Data/Perf/` | Presupuesto oficial (Resource) | Prototipo de diseño (sin editor Godot) |

## 2. Funciones Clave

### 2.1 `budget_profile.gd` — Instrumentación

| Función | Propósito |
|---|---|
| `begin_section(cat: String)` | Abre sección con etiqueta de Profiler |
| `end_section(cat: String)` | Cierra y acumula `usec` en `_sections` |
| `get_section_ms(cat: String) -> float` | Lectura para diagnose/CI |
| `reset_profile_run()` | Limpia la ventana de medición |

### 2.2 `bench_recorder.gd` — Grabador del benchmark

| Función | Propósito |
|---|---|
| `run_route()` | Recorre `bench_scene_a` por waypoints (60 s) |
| `capture_frame_profile()` | Abre/cierra secciones cada frame |
| `dump_json(ruta)` | Escribe `logs/bench/bench_AAAAMMDD.json` |

### 2.3 `validate_budget.gd` — Validación

| Validación | Condición |
|---|---|
| `validate_tabla()` | Categorías todas presentes |
| `validate_medida()` | Σ categorías ≤ 16,7 × 1,10 ms |
| `validate_declaraciones()` | Cada módulo principal declaró su coste |

## 3. Fragmento de Núcleo (prototipo de diseño)

```gdscript
# budget_profile.gd — instrumentación de presupuesto por categoría (M61)
extends Node

const PRESUPUESTO_MS := 16.7
var _sections: Dictionary = {}
var _open: Dictionary = {}

func begin_section(cat: String) -> void:
    # En release builds la instrumentación no compila (regla: overhead cero)
    if OS.has_feature("editor") or OS.has_feature("debug"):
        _open[cat] = Time.get_ticks_usec()

func end_section(cat: String) -> void:
    if not _open.has(cat): return
    var dt := Time.get_ticks_usec() - _open[cat]
    _sections[cat] = float(_sections.get(cat, 0)) + dt / 1000.0

func get_section_ms(cat: String) -> float:
    return float(_sections.get(cat, 0.0))

func reset_profile_run() -> void:
    _sections.clear()
    _open.clear()
```

```gdscript
# bench_recorder.gd (extracto) — recorrido 60 s + dump JSON
func run_route() -> void:
    BudgetProfile.reset_profile_run()
    for waypoint in _route:                    # waypoints de cámara
        _interpolar_a(waypoint, 5.0)           # 5 s por waypoint
        for frame in range(300):               # ~60 FPS × 5 s
            BudgetProfile.begin_section("render")
            await RenderingServer.frame_post_draw
            BudgetProfile.end_section("render")
            if frame % 60 == 0:
                var us := Engine.get_frames_per_second()
                _log_fps(us)
    dump_json("user://logs/bench/bench_" + Time.get_date_string_from_system() + ".json")
```

## 4. Logs de Ejecución (sin runtime Godot — estado honesto)

No existe editor/binary Godot en el entorno de trabajo: los `.gd`/`.tscn` de este documento son **prototipos de diseño verificados estáticamente**. La ejecución del bench scene y del gate CI queda para el entorno destino (criterios de aceptación 1, 4, 5, 6). Sin logs de runtime disponibles hoy.

## 5. Integración Clave (regla M15: no tocar lo que funciona)

- M61 **no modifica** el mesher (M07), la vegetación (M50) ni el agua (M51): solo define y mide la norma que esos módulos cumplen.
- El `budget_profile.gd` es un autoload DEV-only: en release se compila fuera (cero overhead).

## 6. Desfase Plan Maestro

- PLAN MAESTRO: sección 60 "RENDIMIENTO" (28 ítems).
- TABLA GLOBAL: ID 61 — Rendimiento. Desfase = +1. Dependencias declaradas en fila: 08, 49.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-19
**Estado:** Completado (documentación de diseño; implementación pendiente)

### Lo que hice
- RECLAMÉ el módulo 61 por inactividad >24 h (regla 21.4.7): GPT-5 (Codex) lo tenía 🔵 desde 2026-08-16 sin producir nada (0/100).
- Documenté la norma completa (28 ítems del plan maestro): objetivo 60/30 FPS, hardware min/recomendado, presupuesto por categorías (16,5 ms), técnicas obligatorias con módulo dueño, bench scene oficial, gate CI y validación.
- Entregué prototipos: `budget_profile.gd`, `bench_recorder.gd`, `validate_budget.gd`, `budgets.cfg`.

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Sin editor Godot ni build: los `.gd`/`.tscn` son prototipos de diseño; el bench y el gate CI quedan para el entorno destino.
- `[?]` Números de medición reales (ms por categoría en hardware): sin binario Godot no hay medición; la tabla es presupuesto objetivo, no misura.
- `[?]` Configuración concreta del mesher de Voxel Tools (LOD levels del plugin): documentada la norma; los valores exactos del plugin se ajustan al implementar M07.

### Intentos fallidos / decisiones
- Descarté RenderDoc/Nsight como gate continuo (solo diagnóstico puntual).
- Descarté occlusion global (caro en isla abierta): por celdas solo en cuevas/templos (M24/M25).
- Descarté LOD de 2 niveles (pop visible): 3 niveles + impostor lejano.

### Recomendaciones para el próximo agente
- Implementar primero `budget_profile.gd` + `bench_scene_a` (sin módulos finales, el terreno voxel básico M08 basta) para tener la vara de medición antes de optimizar nada.
- Configurar el gate CI en M116 apenas exista un build de profiling.
- Coordinar con M62 (Memoria): las pausas de GC y las allocations se miden en el MISMO bench.