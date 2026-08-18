**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 48: Animación

## 1. Arquitectura

```
Assets/_Project/Animation/
├── libraries/                  (AnimationLibrary por actor/familia)
│   ├── jugador_lib.tres        (clips de la FSM de M11)
│   ├── n ncp_humanoide_lib.tres
│   ├── fauna_cuadrupedo_lib.tres
│   ├── fauna_ave_lib.tres · fauna_pez_lib.tres
│   └── props_*_lib.tres        (puertas, ascensores, barcos, mecanismos)
├── controllers/                (FSM de animación por actor)
│   ├── jugador_animation_fsm.gd
│   ├── npc_animation_fsm.gd
│   └── fauna_animation_fsm.gd
├── procedural/                 (animación procedural de mundo)
│   ├── viento_vegetacion.gd
│   ├── ondas_agua.gd
│   └── fuego_particulas.gd
├── ui/                         (animaciones UI 60 fps)
│   ├── transiciones_lib.tres
│   └── recompensas_lib.tres
└── budget/                     (animation_budget.json)

Assets/_Project/Editor/
├── validate_animation.gd
└── import_animation_defaults.gd   (plantilla de import FBX)

Assets/_Project/Services/       (autoload)
└── animation_service.gd        (API play(actor, estado, blend_time))
```

El jugador (M11), los NPC (M19/M64) y la fauna (M36/M65) llaman a `AnimationService.play(...)` con su estado de comportamiento; el servicio resuelve en qué library/clip, con qué blend y qué LOD (burbuja M64). Los eventos (sonido M43, feedback M44, partículas M52) se disparan desde las timelines de los clips. La UI (M53) usa AnimationPlayer propio con duraciones y Reduce Motion (M58).

## 2. Diagramas de Flujo (texto)

### 2.1 De estado de comportamiento a animación

```
FSM de comportamiento (M11/M64/M65) emite evento "estado cambiado"
  → AnimationService.play(actor, estado, blend_time)
    → 1) resolver familia del actor (humanoide/cuadrúpedo/ave/pez/prop)
    → 2) elegir library y nombre de clip por catálogo (estado → clip)
    → 3) LOD: ¿actor en burbuja? sí → blend normal (250 ms)
               no → idle simplificado / sin update de huesos
    → 4) precargar clip si es la primera vez (pool de AnimationPlayer)
    → 5) reproducir con blend por crossfade; evento "animation_started (actor, estado)"
  → timing de eventos (audio/feedback/partículas) sale de la timeline del clip
```

### 2.2 Producción de una animación de jugador

```
estado FSM (ej: "minar") → ficha en catálogo (anim_minar_swing_1.3s)
  → rig de M45 (humanoide voxel, sockets en manos)
  → blocking: 3 poses (windup → impacto → recovery)
  → polish: anticipación 120ms, impacto 60ms, follow-through
  → eventos: sonido impacto al frame 18, partículas al frame 20
  → export FBX 30 fps, T-pose única, bones subset del rig
  → import con plantilla (import_animation_defaults.gd) → library del jugador
  → validate_animation.gd (naming, frames, eventos, coste)
  → registro en animation_budget.json
```

### 2.3 Validación al importar (validate_animation.gd)

```
al importar clip (M108):
  → naming: anim_[actor]_[estado] (ej: anim_jugador_minar)
  → frames: 30 fps base (UI 60), duración dentro de máximos por categoría
  → rig: T-pose única, bones subset válido para la familia
  → eventos: keyframes de sonido/feedback/partículas sin desplazamiento físico
  → keyframes: sin redundancias (bicubic optimizada)
  → coste: huesos × duración vs presupuesto M61; actor en burbuja
  → emitir lista acumulada de errores
```

## 3. Tablas de Métricas (técnico)

### 3.1 FPS, duraciones y blend por categoría

| Categoría | FPS | Duración típica | Blend default | Notas |
|---|---|---|---|---|
| Locomoción (jugador/NPC) | 30 | 0.8-1.6 s | 250 ms | Blend space 2D direccion×vel |
| Acciones (herramientas, pesca, mina) | 30 | 1.0-2.5 s | 200 ms | Evento de impacto al frame 55-65% |
| Fauna (idle, huir, volar) | 30 | 1.0-3.0 s | 300 ms | Variantes de fase en manadas |
| Mecánicas (puertas, ascensores, barcos) | 30 | 1.5-4.0 s | — | Loops marca final con señal `animation_finished` |
| UI (transiciones, recompensas) | 60 | 150-600 ms | Tween | Reduce Motion M58 |
| Mundo procedural (viento/agua/fuego) | GPU | ∞ | — | Determinista por TIME con fase fija |

### 3.2 Presupuesto de animación (registro contra M61)

- Burbuja de animación plena: ≤ 60 actores (M64), cada uno ≤ 40 huesos activos.
- Fuera de burbuja: idle simplificado (2-4 huesos) o sin animación por distancia > LOD_anim.
- Blend trees: ≤ 4 nodos por actor (espacios 2D de locomoción contados como 1).
- Todos los AnimationPlayer en pooling (props reutilizables no crean players por instancia).
- Coste sincrónico de UI: solo activa mientras visible (no animar offscreen).

### 3.3 Catálogo de animaciones por dominio (25 del plan maestro)

| Dominio | Clip o aproximación | Origen FSM |
|---|---|---|
| Jugador | idle, caminar, correr, saltar, nadar, extraer, pescar, cosechar, dormir | M11 |
| NPC | idle, caminar, rutinas, conversar, gestos | M19/M64 |
| Animales | idle, pastorear, huir, volar, nadar, dormir | M36/M65 |
| Herramientas | swing, minar, plantar, regar, pescar, martillar, lupa | M13 |
| Vegetación | procedural viento (shader/script) | M50 |
| Agua | procedural ondas (shader) | M51 |
| Fuego | procedural partículas (M52) | M52 |
| Partículas | N/A (las partículas SE trigger desde clips) | M52 |
| Puertas | abrir/cerrar (rotación con easing) | M17/M24 |
| Puentes | bajar/subir | M24/M66 |
| Mecanismos | activar/desactivar | M24/M26 |
| Ascensores | subir/bajar con easing | M26 |
| Barcos | balanceo en agua, atraque | M28/M67 |
| Dirigibles | ascender/descender, balanceo | M67 |
| Submarinos | sumergir/emergir | M67 |
| UI | transiciones de menú | M53 |
| Diálogos | retratos, burbujas, gestos de conversación | M21/M46 |
| Recompensas | popup, contador, sparkle | M71/M72 |
| Descubrimientos | nuevo desbloqueo, tooltip | M71 |
| Festivales | bailes, decoraciones pixel-ID | M74 |
| Construcciones | colocar/levantar piezas | M17 |
| Cosecha | arrancar/recoger | M33 |
| Pesca | lanzar, espera, tensión, cobro | M34 |
| Minería | golpe, recogida | M35 |
| Puzzles | mover piezas, activación | M24 |

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M11/M19/M36 | FSM de comportamiento → estados → AnimationService |
| M45 | Rigs, sockets de herramientas, T-poses por familia |
| M13 | Sockets de herramientas (grip), swings por nivel |
| M64/M65 | Burbuja de animación (≤60 plenos), LOD de animación |
| M43/M44 | Eventos de sonido y feedback en timelines |
| M52 | Triggers de partículas desde timelines |
| M50/M51 | Procedural de viento/ondas deterministas |
| M21/M53/M58 | UI animada, diálogos, Reduce Motion |
| M61/M62 | Presupuesto de animación, pooling, registro |
| M74 | Animaciones de festivales y eventos |
| M108/M118 | Importación con plantilla + validación en CI |