**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 138: Vertical Slice

## 1. Archivos Involucrados

| Archivo | Tipo | Propósito |
|---|---|---|
| `scenes/vslice/vslice_aurora.tscn` | Escena | Zona principal del slice |
| `scenes/vslice/player_vs.gd` | Juego | Jugador + animaciones (M11/M48) |
| `scenes/vslice/npc_finneas.gd` | Juego | NPC con rutina y diálogo (M19/M64/M21) |
| `scenes/vslice/ruina_puzzle.gd` | Juego | Puzzle de palancas/símbolos (M24/M25) |
| `scenes/vslice/casa_save.gd` | Juego | Casa + dormir + autosave (M18/M59) |
| `scenes/vslice/zona_vs.gd` | Juego | Configuración de la zona (M10/M50) |
| `scenes/vslice/mision_finneas.gd` | Juego | Misión de 3 pasos (M22/M23) |
| `ui/vslice/ui_inventario.gd` | UI | Inventario funcional (M53) |
| `ui/vslice/ui_dialogo.gd` | UI | Caja de diálogo (M53) |
| `ui/vslice/ui_prompt.gd` | UI | Indicador de interactivo (M53) |
| `audio/vslice/audio_manager.gd` | Audio | Música/SFX/ambiente (M41-M44) |
| `vfx/vslice/vfx_manager.gd` | VFX | Efectos de acciones (M52) |
| `tutorial/vslice/tutorial_visual.gd` | UI | Guiado visual (M92) |
| `autoload/game_state_vs.gd` | Autoload | GameState full del slice (M59) |
| `autoload/save_v2.gd` | Autoload | Save v2 schema_version (M60) |
| `tools/vslice/bench_slice.gd` | Tool | Reporte FPS por categoría (M61) |
| `docs/vslice/PLAYTEST.md` | Doc | Plan + resultados |
| `docs/vslice/REPORTE-FPS.md` | Doc | Rendimiento |
| `docs/vslice/GONOGO-M139.md` | Doc | Decisión de escala |
| `docs/vslice/IDEAS-DESCARTADAS.md` | Doc | Congelación de alcance |

## 2. Funciones Clave

### 2.1 `npc_finneas.gd` (extracto)

```gdscript
extends CharacterBody3D
## Finneas: rutina de día (waypoints) + estado de misión.

enum Estado { IDLE, CAMINANDO, DIALOGO }

var mision_estado: int = 0   # 0=esperando, 1=entregado_madera, 2=hacha_perdida, 3=completada

func _physics_process(delta: float) -> void:
    if estado == Estado.CAMINANDO:
        _mover_a_waypoint(delta)

func dialogo_linea() -> String:
    match mision_estado:
        0: return "bienvenida_finneas"
        1: return "pide_hacha_finneas"
        2: return "agradece_finneas"
        3: return "despues_finneas"
```

### 2.2 `ruina_puzzle.gd` (extracto)

```gdscript
extends Node3D
## Puzzle: 2 palancas alinean 2 símbolos del canon (M147).

var simbolo_objetivo: String = "sello_brisa"
var alineados: int = 0

func _on_palanca_activada(id: int) -> void:
    alineados = palanca_a.activa + palanca_b.activa
    if alineados == 2:
        _abrir_puerta()
        vfx_manager.explosion_noble(position)
        mision_finneas.hacha_recuperada = true
```

### 2.3 `save_v2.gd` (extracto, M60)

```gdscript
extends Node
## Formato save v2 con schema_version y validaciones.

const SCHEMA := 2

func guardar(path: String) -> void:
    var data := {
        "schema_version": SCHEMA,
        "zona": zona_vs.serializar(),   # incluye chunks modificados
        "player": player.serializar(),
        "npcs": { "finneas": {"mision": mision_finneas.mision_estado, "pos": npc_finneas.serializar()} },
        "puzzle": { "resuelto": ruina_puzzle.resuelto },
        "economia": {"ao": mision_finneas.ao, "inventario": inventario.serializar()}
    }
    _escribir_json(path, data)

func cargar(path: String) -> Result:
    var data: Dictionary = _leer_json(path)
    if data.get("schema_version") != SCHEMA:
        return Result.ERR_SCHEMA   # migración futura
    zona_vs.deserializar(data["zona"])
    player.deserializar(data["player"])
    ...
    return Result.OK
```

### 2.4 `bench_slice.gd` (M61, framework de reporte)

```gdscript
extends Node
## Mide por categoría (perfil M61) durante el slice.

var budget := {
    "gameplay": 2.5, "voxel": 4.0, "ia": 2.0, "particulas": 1.0,
    "culling": 0.5, "render": 5.0, "ui": 1.5
}
var mediciones: Dictionary = {}

func _process(_delta: float) -> void:
    for cat in budget.keys():
        mediciones[cat] = _medir_categoria(cat)

func reporte() -> Dictionary:
    var out := {}
    for cat in budget.keys():
        out[cat] = { "ms": mediciones[cat], "budget": budget[cat], "ok": mediciones[cat] <= budget[cat] }
    return out
```

## 3. Logs Relacionados

| Mensaje | Nivel | Cuándo |
|---|---|---|
| `VSLICE zona cargada (N nodos, M multimesh)` | info | Carga del slice |
| `VSLICE autosave guardado ({size} KB)` | info | Dormir/hito |
| `VSLICE puzzle resuelto` | info | Fin del puzzle |
| `VSLICE FPS medio {fps}, P99 {ms}` | warning si P99>40 | Reporte de rendimiento |
| `VSLICE save schema mismatch` | error | Carga con schema vieja |

## 4. Tests (M112)

- `test_vs_save.gd`: 10 ciclos guardar→cargar con 0 pérdidas; schema migration mock.
- `test_vs_puzzle.gd`: puzzle con combinatoria de palancas (todas las secuencias).
- `test_vs_ia.gd`: Finneas no atraviesa paredes en sus waypoints.
- `test_vs_bench.gd`: el reporte FPS se genera con las 7 categorías completas.
- `test_vs_tutorial.gd`: el guiado visual se oculta al terminar la primera acción.

## 5. Definición del Entregable (Checklist de Cierre)

1. Loop de 20-30 min jugable de punta a punta.
2. `REPORTE-FPS.md` con las 7 categorías del budget (M61).
3. Playtest con 5+ testers y encuesta agregada en `PLAYTEST.md`.
4. `GONOGO-M139.md` firmado con decisión de escalar a Pre-Alpha.
5. `IDEAS-DESCARTADAS.md` con todo lo que NO entró (congelación).
6. Demo empaquetada (M116) y tag git `vslice-v1`.

## 6. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-19 05:20
**Estado:** Documentación completa

### Lo que hice
- Documenté el módulo Vertical Slice completo (5 archivos, plan-inicial y plan-actual idénticos al inicio).
- Checklist de 130 ítems verificables, derivados de la sección 137 del plan maestro (18 ítems) + estrategia de producción del Plan-de-produccion.md (sección 16) + alineación M61/M152/M153.

### Lo que NO pude hacer
- Ningún ítem quedó `[?]`: la documentación es diseño de hito; depende del Prototipo (M137) para implementarse.

### Recomendaciones para el próximo agente
- Ejecutar SOLO después del GO del Prototipo (M137).
- Aplicar el frame budget M61 desde el día 1 del slice, no al final.
- Finneas debe consumir el canon de M147 (world_data.json) para su diálogo.