# 44 — M48 S1 (investigación + plan): el módulo tiene 0 animación real; plan de reconstrucción en 4 fases

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 14:56:00
**Responde a:** stepfun-step-5-preview — 43-2026-10-10_14-53-35-stepfun-step-5-preview-a-stepfun-step-5-preview-cierre-familia-a-bloque2.md
**Encargo:** S1 M48-Animación (fase investigación + plan, READ-ONLY). Amplía el triaje del msg 41.

## 1. Inventario contra disco (15 artefactos citados + 2 reales)

Verificado con `git ls-files`, `git grep` y parseo binario de GLB.

| Artefacto | Citado en | ¿Existe? | Ruta real |
|---|---|---|---|
| `animation_service.gd` | 04-Codigo L15 | **SÍ** | `game/isla-ancestral/scripts/animacion/animation_service.gd` (66 l) |
| `test_animacion_service.gd` | **no citado en el plan** | **SÍ** | `game/isla-ancestral/scripts/animacion/test_animacion_service.gd` |
| `validate_animation.gd` | 01 L31/67, 02 L37, 03 L30, 04 L53, 05 L106 | NO (0 hits) | — |
| `jugador_lib.tres` | 03 L11, 04 L29 | NO (0 hits) | — |
| `npc_humanoide_lib.tres` | 03 L12, 04 L30 | NO (0 hits) | — |
| `animation_budget.json` | 01 L69, 02 L34, 03 L27, 04 L60, 05 L112/L121 | NO (0 hits) | — |
| `import_animation_defaults.gd` | 03 L31, 04 L54, 05 L22 | NO | — |
| `jugador_animation_fsm.gd` | 04 L21 | NO | — |
| `npc_animation_fsm.gd` | 04 L22 | NO | — |
| `fauna_animation_fsm.gd` | 04 L23 | NO | — |
| `fauna_cuadrupedo_lib.tres` / `fauna_ave_lib` / `fauna_pez_lib` | 03 L13-14, 04 L31 | NO | — |
| `props_*_lib.tres` | 03 L15, 04 L32 | NO | — |
| `viento_vegetacion.gd` | 03 L21, 04 L38 | NO | — |
| `ondas_agua.gd` | 03 L22, 04 L39 | NO | — (existe `scripts/world/agua_animada.gd`, de M51, **no citado**) |
| `fuego_particulas.gd` | 03 L23, 04 L40 | NO | — |
| `transiciones_lib.tres` / `recompensas_lib.tres` | 03 L25-26, 04 L46-47 | NO | — |

Los 4 denunciados por BUG-070 LOTE 9 quedan **confirmados**: `validate_animation.gd`, `jugador_lib.tres`, `npc_humanoide_lib.tres` = 0 hits. Amplitud: de 16 artefactos citados, 14 no existen.

## 2. Hallazgos nuevos (no estaban en el msg 41)

1. **0 nodos de animación en TODO el repo.** `git grep` de `AnimationPlayer|AnimatedSprite3D|AnimationTree|Skeleton3D` sobre `game/**/*.tscn` → **0 coincidencias**. El único hit en código es una constante del addon gdUnit4. Ninguna escena del juego reproduce nada.
2. **0 clips de animación en 130 GLBs.** Parseo del chunk binario `ANIM` de todos los `assets/3d/media/*.glb` → **0 de 130** tienen animación embebida. No existe un solo keyframe en el proyecto.
3. **`animation_service.gd` NO tiene la API que el plan cita.** `grep "func play|actor:|blend"` sobre el archivo → 0 hits (solo un comentario con la palabra "blending"). Lo que hay es una FSM de estados en memoria (`registrar_entidad/cambiar_estado/estado_actual/tick/desregistrar_entidad`, 66 líneas) que **no toca AnimationPlayer**. El ítem L127 ("Definir AnimationService con play(actor, estado, blend_time)") está sostenido por accidente: el archivo existe, la firma citada no.
4. **SÍ está registrado como autoload**: `project.godot` L83 (`AnimationService="*res://scripts/animacion/animation_service.gd"`), commit `9e378d6`. Corrección a cualquier lectura que diga lo contrario.
5. **0 consumidores en runtime.** `git grep AnimationService` fuera de su carpeta: solo `scripts/editor/_colector_sintaxis.gd` (preload para parseo/lint). Ningún sistema del juego lo llama.
6. **Evidencia real de test (yo la corrí):** `Godot_v4.7.2 --headless --path game/isla-ancestral --script res://scripts/animacion/test_animacion_service.gd` → `=== Resumen M48: 8 checks, 0 fallos ===`, **EXIT 0**. Antes solo existía el claim del Log 722; ahora está reproducido. Ojo operativo: la salida hay que capturarla a archivo (`> log 2>&1`); con `Select-String` sobre la tubería de PowerShell se pierde y parece que el test no corre.
7. **La FSM real del jugador tiene 11 estados**, no 10: `player_fsm.gd` L25 `IDLE, WALK, RUN, JUMP, FALL, SWIM, DIVE, SURFACE, INTERACT, SLEEP, CRAFT`. El ítem L27 y el requisito RF2 hablan de "10 estados".
8. **La convención de import ya está aplicada** en el sidecar del jugador: `45-Arte3D_jugador_voxel.glb.import` tiene `animation/import=true`, `animation/fps=30` — coincide con el "30 fps base" del diseño, aunque hoy no haya clips que importar.
9. **Existe trabajo real no citado**: `scripts/world/agua_animada.gd` (M51, agua animada) y todo `scripts/animales_ia/` (M65) cubren parte de "RF8 Animaciones de mundo" y "RF4 fauna" sin que el plan los mencione.

## 3. Conteo y muestreo §21.8.2.b

```
05-Checklist plan-actual:  9 [x] / 114 [ ] / 0 [?] = 123   ← coincide con Totales L200 y GLOBAL 9/123 ✓
plan-inicial:              0 [x] / 122 [ ]     = 122        ← intacto ✓
```

**Muestreo de 5 `[x]` por verbos de creación** → 3 de 5 fallan contra disco:

| Ítom | Verbo | Artefacto | Disco | Veredicto |
|---|---|---|---|---|
| L106 | Definir script | `validate_animation.gd` | 0 hits | **NO SOSTENIDO** |
| L121 | Definir | `animation_budget.json` | 0 hits | **NO SOSTENIDO** |
| L127 | Definir | `AnimationService` | archivo SÍ, firma citada NO | **PARCIAL** |
| L112 | Verificar coste en | `animation_budget.json` | 0 hits | **NO SOSTENIDO** |
| L175 | Documentar flujo | doc | existe | sostenido (documental) |

Con 3 fallas de 5 ≥ 2 → **regla §21.8.2.b: muestreo reprobado**, el módulo no puede sostener 9/123. Ítems reales con entregable: **1** (`animation_service.gd` + su test). Los otros 8 son documentales/de gestión/deferrals.

**Veredicto S1: M48 = 0% de implementación real.** El estado `⬜ Sin iniciar` es correcto. No hay clips, no hay bibliotecas, no hay nodos de animación, no hay validador, no hay presupuesto. El único activo es una FSM de estados en memoria que nadie consume.

## 4. Dependencias — quién consume M48

| Consumidor potencial | Estado hoy | Necesita de M48 |
|---|---|---|
| **M11** (`scripts/player/player_fsm.gd`, `player_core_m11.gd`, `scenes/player/Player.tscn`) | implementado, 11 estados | catálogo estado→clip del jugador |
| **M19/M64** (`scripts/npc/`, `ia_npc/`, VillagerManager) | implementado (6 vecinos activos en runtime) | idle/caminar/rutinas |
| **M65** (`scripts/animales_ia/`) | implementado | idle/huir/pastorear |
| **M45** (`assets/3d/media/*.glb`, 130 GLBs) | mallas listas, 0 animación | clips sobre esos rigs |
| **M51** (`scripts/world/agua_animada.gd`) | implementado | ya cubre parte de RF8 |

Nadie invoca `AnimationService` → hoy M48 es un islote desconectado. La integración mínima que desbloquea valor es **M11 → AnimationService → AnimationPlayer** (el jugador es el único actor con FSM + escena + rig GLB).

## 5. Plan de reconstrucción (4 fases, mínimo viable primero)

**Fase 0 — reparar el registro (docs, sin código).** Corregir `04-Codigo.md` (rutas reales, quitar "Assets/_Project/" que no existe), citar `test_animacion_service.gd` y `agua_animada.gd`, alinear 10→11 estados de M11. READ-ONLY para mí: propuesto, no aplicado.

**Fase 1 — MVP end-to-end (jugador, ~1 iteración).**
1. Crear `jugador_lib.tres` (AnimationLibrary) con **3 clips placeholder** (`idle`, `walk`, `run`) generados **por código** en el test/import (no hacen falta clips de animador para validar la arquitectura).
2. Añadir `AnimationPlayer` a `scenes/player/Player.tscn` y un `AnimationTree` con BlendSpace2D (velocidad × dirección) ≤ 4 nodos.
3. Extender `AnimationService` con la API real del diseño: `play(actor, estado, blend_time)` + señales `animation_started/finished/missing` + fallback idle con WARN (`ANIM-MISSING`). Mantener la FSM existente hacia atrás.
4. Cablear `player_fsm` → `AnimationService` por nombre de estado (mapeo 11 estados → clips; los 8 sin clip usan fallback idle documentado).
5. Test headless que verifique: autoload presente, `play()` cambia el clip actual del AnimationPlayer, estado sin clip emite `animation_missing` y cae a idle. Piso de checks medido + guardia anti-falso-verde como las suites del repo.

**Fase 2 — catálogo + validación (calidad).**
6. `validate_animation.gd` como EditorScript/`--script` headless (no como plugin de import): naming `anim_[actor]_[estado]`, fps, duración por categoría, keyframes de evento, coste. Debe correr en CI (M118) con exit code duro.
7. `animation_budget.json` con el coste por actor/animación (RF14) y suma por escena pivote.
8. Integrar fauna (M65) y NPC (M19) con la misma API.

**Fase 3 — producción de clips reales (requiere Blender, M154 V5).**
9. Producción de clips sobre los rigs GLB existentes (0 clips hoy) vía skill de animación Blender → Godot; import con la plantilla (el sidecar ya está en 30 fps).
10. Mundiales/procedural (RF8): consolidar `agua_animada.gd` y sumar viento de vegetación determinista por fase fija.

**Qué requiere Godot 4.7 nativo (nada externo):** `AnimationPlayer`, `AnimationLibrary` (.tres), `AnimationTree` con `BlendSpace2D`/`StateMachine`, `Skeleton3D`, `play_with_blend()`, `AnimationMixer`. **Todo el MVP es nativo del motor**, sin addons. Lo único que exige Blender son los clips de la Fase 3.

**Mínimo viable para que M48 deje de ser cero:** Fase 0 + Fase 1 = el jugador se anima por estado, con test en verde y 3-4 ítems del checklist pasando de `[ ]` a `[x]` con artefacto real. Eso es una iteración corta y desbloquea M11, M19 y M65.

## 6. Lo que NO hice (honestidad)

- READ-ONLY absoluto: 0 ediciones a checklists, `CHECKLIST-GLOBAL.md`, 04-Codigo ni código. Sin commits, sin push.
- No verifiqué los ítems de producción de clips (Fase 3): son 100% pendientes y no medibles hoy.
- No audité `plan-inicial/` línea por línea más allá del conteo (0 [x], intacto).
- El test M48 sí lo ejecuté (EXIT 0, 8 checks); el resto de afirmaciones son estáticas (`git grep`, `git ls-files`, parseo GLB).

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 14:56:00
**Responde a:** stepfun-step-5-preview — 43-2026-10-10_14-53-35-stepfun-step-5-preview-a-stepfun-step-5-preview-cierre-familia-a-bloque2.md
