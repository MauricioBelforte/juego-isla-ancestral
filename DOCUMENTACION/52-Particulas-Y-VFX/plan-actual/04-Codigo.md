**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 52: Partículas y VFX

> Rutas previstas dentro de `Assets/_Project/` (estructura del proyecto Godot 4.x, ver AGENTS.md §24).
> ⚠️ **Estado: Pendiente de implementación.** Los archivos listados son diseño/documentación; no existe código runtime todavía.

## 1. Archivos Previstos

### 1.1 Catálogo y emisores — `Assets/_Project/VFX/`

| Archivo | Contenido | Estado |
|---|---|---|
| `catalog/vfx_catalog.tres` | 25+ efectos: tipo, material (M45/M47), emisor, presupuesto | Vacía — pendiente |
| `emitters/*.tscn` | Escenas de emisores reutilizables (humo, polvo, hojas, pétalos, chispas, agua, lluvia, nieve, fuego, lava, runas, Sello, puzzle, construcción, cosecha, pesca, descubrimiento, estaciones) | Vacías — pendientes |

### 1.2 Managers — `Assets/_Project/VFX/systems/`

| Archivo | Propósito | Estado |
|---|---|---|
| `vfx_manager.gd` (autoload) | Pool de emisores, catálogo, presupuesto, vfx_quality (M58) | Pendiente de implementación |
| `vfx_trigger.gd` | Punto único: VFX + sonido (M43) + feedback (M44) | Pendiente de implementación |
| `vfx_atmospheric.gd` | Lluvia/nieve/polvo por clima y estación (M32/M29) | Pendiente de implementación |

### 1.3 UI y validación — `Assets/_Project/VFX/` + `Assets/_Project/Editor/`

| Archivo | Contenido | Estado |
|---|---|---|
| `ui/ui_vfx.gd` | Partículas 2D para M53 con Reduce Motion (M58) | Pendiente de implementación |
| `budget/vfx_budget.json` | Emisores y partículas vivas por escena | Vacía — pendiente |
| `validate_vfx.gd` | Validador: presupuesto, naming, determinismo, sin luz por partícula | Pendiente de implementación |

## 3. Inicio de Implementación (ox-alpha/Cline, 2026-08-24)

> **Actualizado por:** ox-alpha (Cline) — 2026-08-24
> Estado previo: "Pendiente de implementación". Se añadió una **escena de preview** como primer asset runtime real del módulo.

### Archivo real creado
| Archivo | Ruta | Contenido |
|---|---|---|
| `preview_particles.tscn` | `game/isla-ancestral/scenes/` | Escena de demo: cielo procedural, luz direccional, cámara fija, nodo Tree, emisor CPUParticles3D, label FPS |
| `preview_particles.gd` | `game/isla-ancestral/scripts/particles/` | Crea emisor de polen en runtime (CPUParticles3D: 60 partículas, dirección Y, spread, gravedad sutil, color amarillo) |

> Corresponde a la categoría `emitters/*.tscn` del catálogo (§1.1). Es una prueba de concepto visual validada con godot-mcp (V4). Ver Log 145 para detalles y cómo lanzarla cuando se libere el proyecto.

### Validación visual (2026-08-24)

La escena fue ejecutada en vivo y el **usuario confirmó la validación visual**: partículas amarillas visibles emergiendo desde abajo con comportamiento tipo chispas/fuegos artificiales, dentro de lo esperado para el emisor de prueba (dirección Y + spread + gravedad sutil). Sin errores en consola durante la corrida. El lanzamiento es reproducible con `tools/mcp/godot-mcp/scripts-reutilizables/lanzar_preview.py`. Registro también anotado en `06-GUIA-DE-CONEXION-VISION.md` (registro de verificación V4).

> ⚠️ **Aclaración (2026-08-25, actualizada):** la validación inicial fue **exclusivamente humana** (observación en vivo del usuario). Ese mismo día se generó la **primera captura automatizada real**: `capturas/52-Particulas-Y-VFX/cap_52_2026-08-24_21-19-22_polen-validacion.png`, verificada visualmente por el agente (ventana "isla-ancestral (DEBUG)", FPS 59, partículas amarillas visibles). El historial de capturas del módulo arranca allí.

```gdscript
# ---------- vfx_manager.gd (autoload) ----------
class_name VfxManager
extends Node

const MAX_EMISORES := 12          # preset medio (M90)
const MAX_PARTICULAS := 4000      # partículas vivas totales

enum Calidad { FULL, REDUCED, OFF }  # M58

func _ready() -> void:
    # precalentar pool: 8 emisores genéricos (M62)
    pass

func emitir(efecto_id: StringName, pos: Vector3, ctx: Dictionary = {}) -> void:
    # 1) verificar presupuesto: emisores_activos < MAX_EMISORES
    #    y partículas vivas < MAX_PARTICULAS → si no, log VFX-SKIP
    # 2) tomar emisor del pool (o crearlo si catálogo lo exige)
    # 3) semilla = hash(ctx.semilla_contexto or 0, efecto_id, _contador)
    # 4) one-shot: reproducir y devolver al pool al terminar
    # 5) loop: registrar y aplicar LOD por distancia
    pass

func aplicar_calidad(calidad: Calidad) -> void:
    # full/reduced/off: opacidad, velocidad, loops, atmosféricos (M58)
    pass
```

```gdscript
# ---------- vfx_trigger.gd (punto único de emisión) ----------
class_name VfxTrigger
extends Node

## Llama SIEMPRE VFX + SFX + feedback juntos para no desincronizar.
static func emitir(efecto_id: StringName, pos: Vector3, ctx: Dictionary = {}) -> void:
    VfxManager.emitir(efecto_id, pos, ctx)
    AudioService.play_one_shot(ctx.get("sonido", efecto_id), pos)   # M43
    FeedbackService.emit(ctx.get("feedback", "default"), pos)       # M44
```

```gdscript
# ---------- vfx_atmospheric.gd (lluvia/nieve/polvo) ----------
class_name VfxAtmospheric
extends Node

func _on_clima_cambiado(clima: StringName, bioma: StringName) -> void:
    # 1) desactivar emisores atmosféricos actuales
    # 2) activar el del clima+bioma (un solo emisor global por zona)
    #    lluvia → gotas + salpicadura leve; nieve → copos (M32/M29)
    # 3) log VFX-ATMO
    pass
```

```gdscript
# ---------- validate_vfx.gd (EditorTool) ----------
class_name VfxValidator
extends RefCounted

func validar_escena(escena: Node3D) -> Array[String]:
    var errores: Array[String] = []
    # 1) emisores GPUParticles activos <= MAX_EMISORES
    # 2) partículas vivas estimadas <= MAX_PARTICULAS (por catálogo)
    # 3) sin OmniLight dentro de emisores (la luz es M49)
    # 4) naming vfx_/part_ (M108)
    # 5) todos los eventos de juego (M13/M17/M22/M24/M33/M34/M71)
    #    tienen efecto en el catálogo
    # 6) semillas definidas en one-shots (determinismo M10)
    return errores
```

## 3. Señales y Eventos

| Evento | Emisor | Consumidor |
|---|---|---|
| `VFX_EMITIDO(efecto_id, pos)` | VfxManager | Logging M103, analítica M104 |
| `VFX_SKIP(efecto_id, motivo)` | VfxManager | Bug tracking M102 (presupuesto) |
| `CLIMA_CAMBIADO` / `ESTACION_CAMBIADA` | M32/M29 | VfxAtmospheric |
| Triggers de animación (M48) | AnimationPlayer | VfxTrigger |

## 4. Logs Relacionados

| Log | Contexto | Nivel |
|---|---|---|
| `VFX-PLAY` | efecto one-shot emitido (id, pos, semilla) | INFO |
| `VFX-LOOP` | loop registrado/pausado por LOD | INFO |
| `VFX-ATMO` | atmosférico activado/desactivado | INFO |
| `VFX-SKIP` | emisión rechazada por presupuesto | WARN |
| `VFX-REJECT` | escena rechazada por validador | WARN |

## 5. Dependencias de Implementación

| Necesita | Módulo | Uso |
|---|---|---|
| Godot 4.x (>= 4.4.1) | M04 | GPUParticles3D/2D |
| Sprites/materiales | M45/M47 | Texturas de partículas, emisivos |
| Triggers de juego | M13/M17/M22/M24/M33/M34/M71 | Eventos que emiten VFX |
| Animación | M48 | Triggers en timelines |
| Audio/feedback | M43/M44 | Coordinación en un solo trigger |
| Clima/estaciones | M32/M29 | Atmosféricos |
| Iluminación | M49 | Luz de fuego/lava (nunca por partícula) |
| UI | M53/M58 | VFX 2D y Reduce Motion |
| Presupuestos | M61/M62 | Límites y pool |
| Import/CI | M108/M118 | Validación automática |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentado (diseño completo, checklist completo en 05-Checklist.md)

### Lo que hice
- Documentación completa del módulo 52-Partículas y VFX (5 archivos en plan-inicial y plan-actual).
- Catálogo de los 25 efectos del plan maestro (sección 51): humo, polvo, hojas, pétalos, chispas, agua, lluvia, nieve, fuego, lava, luz, magia, resonancia, runas, teletransporte (si existe), Sello, puzzle, construcción, cosecha, pesca, descubrimiento, estaciones, interfaz, atmosféricos.
- VfxManager (autoload) con pool precalentado, presupuesto por escena (≤12 emisores, ≤4.000 partículas preset medio), determinismo con semillas de contexto (M10), VfxTrigger como punto único VFX+SFX+feedback (M43/M44), atmosféricos por clima/estación (M32/M29), VFX 2D de UI con Reduce Motion (M58), regla dura "sin luz por partícula" (luz = M49).
- Integrado con M13/M17/M22/M24/M33/M34/M71, M48, M50/M51, M61/M62, M53/M58, M108/M118.

### Lo que NO pude hacer
- No implementé `vfx_manager.gd`, `vfx_trigger.gd` ni los emisores `.tscn` (se implementan en el hito M1).
- No definí los números exactos de partículas por efecto (requieren calibración visual posterior).

### Recomendaciones para el próximo agente
- Implementar primero el pool con 3 efectos (humo, polvo de mina, chispas) end-to-end.
- Coordinar con M48 los triggers de timeline y con M43/M44 el trigger conjunto.
- Validar el presupuesto temprano en la escena pivote (M61).
- Considerar QA cruzado (sección 21.8) por otro modelo.