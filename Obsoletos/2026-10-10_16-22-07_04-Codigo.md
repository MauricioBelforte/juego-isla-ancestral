**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 48: Animación

> Rutas previstas dentro de `Assets/_Project/` (estructura del proyecto Godot 4.x, ver AGENTS.md §24).
> ⚠️ **Estado: Pendiente de implementación.** Los archivos listados son diseño/documentación; no existe código runtime todavía.

## 1. Archivos Previstos

### 1.1 Servicios (autoload) — `Assets/_Project/Services/`

| Archivo | Propósito | Estado |
|---|---|---|
| `animation_service.gd` | API única `play(actor, estado, blend_time)`; resuelve library/clip/LOD; pool de AnimationPlayer; emite eventos | Pendiente de implementación |

### 1.2 FSM de animación — `Assets/_Project/Animation/controllers/`

| Archivo | Propósito | Estado |
|---|---|---|
| `jugador_animation_fsm.gd` | Espejo de la FSM de M11 (10 estados) | Pendiente de implementación |
| `npc_animation_fsm.gd` | Espejo de la FSM de M19/M64 (rutinas, social) | Pendiente de implementación |
| `fauna_animation_fsm.gd` | Espejo de la FSM de M36/M65 (estados zoo) | Pendiente de implementación |

### 1.3 Bibliotecas de animaciones — `Assets/_Project/Animation/libraries/`

| Archivo | Contenido | Estado |
|---|---|---|
| `jugador_lib.tres` | Clips de jugador (idle, caminar, correr, saltar, nadar, extraer, pescar, cosechar, dormir) | Vacía — pendiente |
| `npc_humanoide_lib.tres` | Clips de NPC (idle, caminar, rutinas, conversar, gestos) | Vacía — pendiente |
| `fauna_cuadrupedo_lib.tres` / `ave_lib` / `pez_lib` | Clips de fauna | Vacía — pendiente |
| `props_*_lib.tres` | Puertas, ascensores, barcos, mecanismos | Vacía — pendiente |

### 1.4 Procedural de mundo — `Assets/_Project/Animation/procedural/`

| Archivo | Propósito | Estado |
|---|---|---|
| `viento_vegetacion.gd` | Balanceo de vegetación por fase fija (M50) | Pendiente de implementación |
| `ondas_agua.gd` | Ondulación de agua determinista (M51) | Pendiente de implementación |
| `fuego_particulas.gd` | Fuego procedural esencialmente por M52 | Pendiente de implementación |

### 1.5 UI — `Assets/_Project/Animation/ui/`

| Archivo | Contenido | Estado |
|---|---|---|
| `transiciones_lib.tres` | Transiciones de menú 60 fps (M53) | Vacía — pendiente |
| `recompensas_lib.tres` | Popups, contadores, sparkles (M71/M72) | Vacía — pendiente |

### 1.6 Editor — `Assets/_Project/Editor/`

| Archivo | Propósito | Estado |
|---|---|---|
| `validate_animation.gd` | Validador: naming, frames, T-poses, eventos, coste | Pendiente de implementación |
| `import_animation_defaults.gd` | Plantilla de import FBX (30 fps, compresión, bones) | Pendiente de implementación |

### 1.7 Registro de presupuesto — `Assets/_Project/Animation/budget/`

| Archivo | Contenido | Estado |
|---|---|---|
| `animation_budget.json` | Coste estimado por actor/animación (RF14) | Vacía — pendiente |

## 2. Funciones Clave (firmas GDScript previstas)

```gdscript
# ---------- animation_service.gd (autoload) ----------
class_name AnimationService
extends Node

## Única puerta de entrada: la lógica de gameplay NUNCA
## llama a AnimationPlayer directamente; pide por ESTADO.
func play(actor: Node3D, estado: StringName, blend_time: float = 0.25) -> void:
    # 1) familia = actor.get_meta("animation_family")  # humanoide/cuadrupedo/ave/pez/prop
    # 2) (library, clip) = _catalogo.estado_a_clip(familia, estado)
    #    -> Si no existe: registrar en log ANIM-MISSING y usar idle fallback
    # 3) lod = _burbuja.es_pleno(actor)  # M64; si no pleno:
    #    -> idle simplificado (2-4 huesos) o skip si fuera de rango LOD_anim
    # 4) player = _pool.obtener(actor)  # pool de AnimationPlayer (M62)
    # 5) player.play_with_blend(library + "/" + clip, blend_time)
    #    animation_started.emit(actor, estado)
    pass

signal animation_started(actor: Node3D, estado: StringName)
signal animation_finished(actor: Node3D, estado: StringName)
signal animation_missing(actor: Node3D, estado: StringName)
```

```gdscript
# ---------- validate_animation.gd (EditorTool) ----------
class_name AnimationValidator
extends RefCounted

const FPS_BASE := 30.0
const UI_FPS := 60.0
const MAX_DURACION := {"locomocion": 1.6, "accion": 2.5, "fauna": 3.0,
                       "mecanica": 4.0, "ui": 0.6, "mundo": INF}

func validar_clip(ruta: String, categoria: String) -> Array[String]:
    var errores: Array[String] = []
    # 1) naming: anim_[actor]_[estado] (M108)
    # 2) frames: 30 fps base (UI 60); duración <= MAX_DURACION[categoria]
    # 3) rig: T-pose única; bones subset válido para la familia
    # 4) keyframes de evento (audio/feedback/particulas) presentes donde
    #    el catálogo los exige (ej: minar -> impacto en 55-65% del clip)
    # 5) sin keyframes redundantes (optimización de clave, M61)
    # 6) coste: huesos_activos * duracion vs animation_budget.json (M61)
    return errores

func validar_actor(actor_cfg: Dictionary, burbuja: int) -> Array[String]:
    # 1) actores plenos <= 60 (M64)
    # 2) blend trees <= 4 nodos por actor
    # 3) todos los estados FSM del actor tienen clip en catálogo
    return errores
```

```gdscript
# ---------- import_animation_defaults.gd (EditorTool) ----------
class_name AnimationImportDefaults
extends EditorImportPlugin  # usa ImportDefaults de FBX (ver M108)

# Configura el import de .fbx animado: 30 fps, optimización de clave,
# skeleton único por familia, T-pose de referencia, compresión (M108).
```

## 3. Señales y Eventos

| Evento | Emisor | Consumidor |
|---|---|---|
| `animation_started(actor, estado)` | AnimationService | Logging M103, UI diario (M55), analítica M104 |
| `animation_finished(actor, estado)` | AnimationService | FSM de comportamiento (retomar estado), soluciones |
| `animation_missing(actor, estado)` | AnimationService | Bug tracking M102, QA M101 |
| Eventos de timeline (audio/feedback/VFX) | AnimationPlayer del clip | Audio M43, ASMR M44, VFX M52 |

## 4. Logs Relacionados

| Log | Contexto | Nivel |
|---|---|---|
| `ANIM-PLAY` | reproducción solicitada (actor, estado, blend, LOD) | INFO |
| `ANIM-MISSING` | estado sin clip (fallback idle usado) | WARN |
| `ANIM-REJECT` | clip rechazado por validador con errores | WARN |
| `ANIM-BUDGET` | presupuesto de animación por escena actualizado | INFO |

## 5. Dependencias de Implementación

| Necesita | Módulo | Uso |
|---|---|---|
| Godot 4.x (>= 4.4.1) | M04 | AnimationPlayer, AnimationLibrary, Skeleton3D, Tweens |
| Rig y sockets | M45 | T-poses, bones por familia, sockets de herramientas |
| FSM de comportamiento | M11/M19/M36/M64/M65 | Estados que la animación refleja |
| Presupuestos | M61/M62 | Burbuja, LOD, pooling de players |
| Sonido/feedback | M43/M44 | Eventos en timelines |
| VFX | M52 | Triggers desde timelines |
| Importación | M108/M118 | Plantilla FBX + validación en CI |
| UI | M21/M53/M58 | Transiciones, diálogos, Reduce Motion |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentado (diseño completo, checklist completo en 05-Checklist.md)

### Lo que hice
- Documentación completa del módulo 48-Animación (5 archivos en plan-inicial y plan-actual).
- Catálogo de los 25 dominios de animación del plan maestro (sección 47), kit de animación por familia (jugador, NPC, fauna), reproducción vía AnimationService con FSM espejo, blending 250 ms, LOD de animación con burbuja M64, procedural determinista para mundo y UI con Reduce Motion M58.
- Integrado con M11/M19/M36/M64/M65 (FSM), M45 (rigs/sockets), M43/M44/M52 (eventos en timelines) y M61/M62 (presupuesto).

### Lo que NO pude hacer
- No implementé `animation_service.gd`, los FSM de animación ni los validadores (herramientas de editor; se implementan en el hito M1).
- No produje clips de animación reales (fase de producción de assets).

### Recomendaciones para el próximo agente
- Implementar primero el AnimationService con un solo actor (jugador) y 3 estados (idle/caminar/correr) end-to-end con blending.
- Coordinar con M45 los rigs por familia antes de producir clips masivos.
- Definir la burbuja de M64 y el LOD_anim en conjunto con M61 antes de optimizar.
- Considerar QA cruzado (sección 21.8) por otro modelo.