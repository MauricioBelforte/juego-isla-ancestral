**Modelo:** step-5-kilocode (Fase 0, reconstrucción anti-inflación)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10

# 04-Codigo.md — Módulo 48: Animación

> **Estado real (auditado 2026-10-10, BUG-070 LOTE 9 + triaje S1):** el plan anterior citaba rutas
> bajo `Assets/_Project/`, que **no existe en este proyecto**. Las rutas reales del juego son
> `game/isla-ancestral/scripts/...` y `game/isla-ancestral/assets/...`. Este documento fue
> reconstruido contra disco: **de 16 artefactos citados, solo 2 existen**.
> ⚠️ **Backup del documento previo:** `Obsoletos/2026-10-10_16-22-07_04-Codigo.md`.

## 1. Archivos Reales (existen en disco)

### 1.1 Servicio (autoload) — `game/isla-ancestral/scripts/animacion/`

| Archivo | Propósito | Estado real |
|---|---|---|
| `animation_service.gd` | FSM de estados de animación en memoria | ✅ **EXISTE** — autoload en `project.godot:83` (`AnimationService="*res://scripts/animacion/animation_service.gd"`, commit `9e378d6`). **66 líneas.** |

**API real del archivo** (verificado leyendo el código, no el plan):

```gdscript
func registrar_entidad(entidad_id: String, estados: Dictionary) -> void
func cambiar_estado(entidad_id: String, nuevo_estado: String) -> bool
func estado_actual(entidad_id: String) -> String
func tick(delta: float) -> void
func desregistrar_entidad(entidad_id: String) -> void
func entidades_count() -> int
```

**Discrepancia con el diseño:** el plan prevé la API `play(actor, estado, blend_time)`; el archivo
**no la tiene**. No toca `AnimationPlayer` ni ninguna libraría: solo mantiene estados en memoria.
**Ningún sistema del juego lo invoca** (único consumidor: `scripts/editor/_colector_sintaxis.gd`
para parseo/lint). El ítem L127 del checklist ("Definir AnimationService con
play(actor, estado, blend_time)") queda **PARCIAL**: el archivo existe, la firma citada no.

### 1.2 Test — `game/isla-ancestral/scripts/animacion/`

| Archivo | Propósito | Estado real |
|---|---|---|
| `test_animacion_service.gd` | Suite headless del servicio | ✅ **EXISTE** — **no estaba citado en el plan**. Ejecutado 2026-10-10: `=== Resumen M48: 8 checks, 0 fallos ===`, **EXIT 0**. |

### 1.3 FSM de comportamiento que M48 debe reflejar — `game/isla-ancestral/scripts/player/`

| Archivo | Propósito | Estado real |
|---|---|---|
| `player_fsm.gd` | FSM del jugador (M11) | ✅ **EXISTE** — **11 estados**, no 10 |

```gdscript
# player_fsm.gd L25-L37
enum Estado {
    IDLE, WALK, RUN, JUMP, FALL, SWIM, DIVE,
    SURFACE, INTERACT, SLEEP, CRAFT,
}
```

**Corrección aplicada:** RF2 y el ítem L27 del checklist decían "10 estados"; el número real es
**11**. Toda la especificación de clips del jugador debe cubrir los 11.

### 1.4 Convención de import ya aplicada — `game/isla-ancestral/assets/3d/media/`

| Archivo | Propósito | Estado real |
|---|---|---|
| `45-Arte3D_jugador_voxel.glb.import` | Sidecar de import del rig del jugador | ✅ **EXISTE** — `animation/import=true`, `animation/fps=30`. Coincide con el "30 fps base" del diseño, aunque hoy no haya clips que importar. |

### 1.5 Trabajo real NO citado por el plan (cubre parte de los requisitos)

| Archivo | Módulo | Cubre |
|---|---|---|
| `game/isla-ancestral/scripts/world/agua_animada.gd` | M51 | Parte de **RF8** (animación de mundo: ondulación de agua determinista) |
| `game/isla-ancestral/scripts/animales_ia/` (M65) | M65 | Parte de **RF4** (estados de fauna: idle/huir/pastorear) |

El plan listaba `ondas_agua.gd` como pendiente bajo M48: **el trabajo ya existe en M51** con otro
nombre y no está citado. Se documenta para no duplicarlo.

## 2. Archivos Previstos (NO existen — resto del diseño vigente)

Rutas reales propuestas (ya sin `Assets/_Project/`):

### 2.1 Bibliotecas de animación — `game/isla-ancestral/scripts/animacion/libraries/`

| Archivo | Contenido | Estado |
|---|---|---|
| `jugador_lib.tres` | AnimationLibrary del jugador (idle, caminar, correr; faltan saltar, nadar, extraer, pescar, cosechar, dormir) | Vacía — pendiente |
| `npc_humanoide_lib.tres` | Clips de NPC (idle, caminar, rutinas, conversar, gestos) | Vacía — pendiente |
| `fauna_cuadrupedo_lib.tres` / `fauna_ave_lib.tres` / `fauna_pez_lib.tres` | Clips de fauna | Vacía — pendiente |
| `props_*_lib.tres` | Puertas, ascensores, barcos, mecanismos | Vacía — pendiente |

### 2.2 FSM espejo de animación — `game/isla-ancestral/scripts/animacion/controllers/`

| Archivo | Propósito | Estado |
|---|---|---|
| `jugador_animation_fsm.gd` | Espejo de la FSM de M11 (**11 estados**, ver 1.3) | Pendiente |
| `npc_animation_fsm.gd` | Espejo de la FSM de M19/M64 | Pendiente |
| `fauna_animation_fsm.gd` | Espejo de la FSM de M36/M65 | Pendiente |

### 2.3 Procedimental de mundo — `game/isla-ancestral/scripts/animacion/procedural/`

| Archivo | Propósito | Estado |
|---|---|---|
| `viento_vegetacion.gd` | Balanceo de vegetación por fase fija (M50) | Pendiente |
| `fuego_particulas.gd` | Fuego procedural (M52) | Pendiente |
| ~~`ondas_agua.gd`~~ | **Ya existe** en M51 como `scripts/world/agua_animada.gd` (ver 1.5) | ✅ Cubierto por M51 |

### 2.4 UI — `game/isla-ancestral/scripts/animacion/ui/`

| Archivo | Contenido | Estado |
|---|---|---|
| `transiciones_lib.tres` | Transiciones de menú 60 fps (M53) | Pendiente |
| `recompensas_lib.tres` | Popups, contadores, sparkles (M71/M72) | Pendiente |

### 2.5 Editor / validación — `game/isla-ancestral/scripts/editor/` (o `tools/`)

| Archivo | Propósito | Estado |
|---|---|---|
| `validate_animation.gd` | Validador: naming, frames, T-poses, eventos, coste. Debe correr como `--script` headless para CI (M118), no como plugin de import | Pendiente |
| `import_animation_defaults.gd` | Plantilla de import FBX (30 fps, compresión, bones) | Pendiente |

### 2.6 Registro de presupuesto — `game/isla-ancestral/scripts/animacion/budget/`

| Archivo | Contenido | Estado |
|---|---|---|
| `animation_budget.json` | Coste estimado por actor/animación (RF14) | Pendiente |

## 3. Funciones Clave (firmas GDScript previstas)

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

> **Nota de implementación (Fase 1):** extender el `animation_service.gd` existente conservando su
> API actual hacia atrás (`registrar_entidad`/`cambiar_estado`/`estado_actual`/`tick`/
> `desregistrar_entidad`/`entidades_count`) y añadiendo `play()` + las 3 señales.

```gdscript
# ---------- validate_animation.gd (EditorScript headless) ----------
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

## 4. Señales y Eventos

| Evento | Emisor | Consumidor |
|---|---|---|
| `animation_started(actor, estado)` | AnimationService | Logging M103, UI diario (M55), analítica M104 |
| `animation_finished(actor, estado)` | AnimationService | FSM de comportamiento (retomar estado), soluciones |
| `animation_missing(actor, estado)` | AnimationService | Bug tracking M102, QA M101 |
| Eventos de timeline (audio/feedback/VFX) | AnimationPlayer del clip | Audio M43, ASMR M44, VFX M52 |

## 5. Logs Relacionados

| Log | Contexto | Nivel |
|---|---|---|
| `ANIM-PLAY` | reproducción solicitada (actor, estado, blend, LOD) | INFO |
| `ANIM-MISSING` | estado sin clip (fallback idle usado) | WARN |
| `ANIM-REJECT` | clip rechazado por validador con errores | WARN |
| `ANIM-BUDGET` | presupuesto de animación por escena actualizado | INFO |

## 6. Dependencias de Implementación

| Necesita | Módulo | Estado hoy |
|---|---|---|
| Godot 4.7.2 | M04 | ✅ Disponible — `AnimationPlayer`, `AnimationLibrary` (.tres), `AnimationTree` con `BlendSpace2D`, `Skeleton3D`, `play_with_blend()`, `AnimationMixer` son todo nativo |
| Rig y sockets | M45 | ✅ Rig del jugador presente (`assets/3d/media/45-Arte3D_jugador_voxel.glb`), **0 clips** en los 130 GLB (parseo chunk `ANIM`) |
| FSM de comportamiento | M11 | ✅ `player_fsm.gd` con **11 estados** |
| Presupuestos | M61/M62 | Pendiente (burbuja, LOD, pooling) |
| Sonido/feedback | M43/M44 | Pendiente (eventos en timelines) |
| VFX | M52 | Pendiente (triggers desde timelines) |
| Importación | M108/M118 | Sidecar del jugador ya en 30 fps; validación en CI Pendiente |
| UI | M21/M53/M58 | Pendiente (transiciones, diálogos, Reduce Motion) |

## 7. Diagnóstico de inflación (por qué este archivo se reescribió)

| Medición | Valor |
|---|---|
| Artefactos citados por el plan previo | 16 |
| Artefactos que existen en disco | **2** (`animation_service.gd` + su test) |
| Nodos de animación en `game/**/*.tscn` (`AnimationPlayer`/`AnimatedSprite3D`/`AnimationTree`/`Skeleton3D`) | **0** |
| Clips de animación en 130 GLB (chunk binario `ANIM`) | **0** |
| Ítems `[x]` del checklist | **6 de 123** tras el triaje E-12d de agnes-3-flash (L106/L112/L121 degradados: artefactos inexistentes) |
| Implementación real del módulo | **0%** |

**Veredicto:** el estado `⬜ Sin iniciar` de `CHECKLIST-GLOBAL.md` es correcto. El único activo es
una FSM de estados en memoria que ningún sistema consume.

---

## Notas del Agente

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10
**Estado:** Fase 0 completada (documentación reconstruida contra disco, READ-ONLY sobre código)

### Lo que hice
- Reescritura de `04-Codigo.md` con rutas reales: fuera `Assets/_Project/` (inexistente), dentro
  `game/isla-ancestral/scripts/...` y `assets/...`.
- Inventario de los 16 artefactos citados contra disco: **2 existen**.
- Citado el test no documentado (`scripts/animacion/test_animacion_service.gd`, 8 checks, corrido por mí).
- Citado el trabajo real no documentado: `agua_animada.gd` (M51) y `scripts/animales_ia/` (M65).
- Corregido **10 → 11 estados** de la FSM de M11 (`player_fsm.gd` L26-L36).
- Documentada la discrepancia de API: `play(actor, estado, blend_time)` no existe; el archivo real
  mantiene estados en memoria con otra firma.
- Documentada la convención de import ya aplicada en el sidecar del jugador (30 fps).
- Backup del documento previo en `Obsoletos/2026-10-10_16-22-07_04-Codigo.md`.

### Lo que NO hice
- No toqué código ni el checklist (el triaje E-12d de M48 lo está haciendo **agnes-3-flash** en
  paralelo; su conteo 6/114/3 se adopta como el honesto y coincide con mi medición).
- No produje clips: hay 0 en 130 GLB y la Fase 3 requiere Blender (no autorizada).

### Recomendaciones para el próximo agente
- **Fase 1 (autorizada):** MVP end-to-end con el jugador — `jugador_lib.tres` con 3 clips
  placeholder generados por código + `AnimationPlayer` en `Player.tscn` + `AnimationTree`
  BlendSpace2D + `play()` con fallback idle documentado + cableado `player_fsm` →
  `AnimationService` + test headless con guardia anti-falso-verde.
- **Coordinación obligatoria:** DeepSeek cableó el nodo `NucleoM11` en `Player.tscn` (Log 1594).
  El cableo de animación va en un **nodo separado** para no pisar el adaptador.
- Fase 2 (`validate_animation.gd` en CI M118) y Fase 3 (clips reales, requiere Blender) **no
  están autorizadas**.
