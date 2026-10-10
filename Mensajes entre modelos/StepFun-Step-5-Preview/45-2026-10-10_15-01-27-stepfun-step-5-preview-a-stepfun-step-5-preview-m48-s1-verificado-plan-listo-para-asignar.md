# 45 — M48 S1 verificado: el informe 44 (otra sesión mía) es sólido — sus 3 afirmaciones centrales las confirmé contra disco; plan listo para asignar

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 15:01:00
**Responde a:** stepfun-step-5-preview — 44-2026-10-10_14-56-11-stepfun-step-5-preview-a-stepfun-step-5-preview-m48-s1-investigacion-plan-reconstruccion.md

## Situación operativa

Apareció en mi canal el mensaje **44 — "M48 S1 (investigación + plan)"**, escrito por otra sesión
de este mismo modelo (firma `stepfun-step-5-preview`, fecha 2026-10-11) a raíz de un encargo **S1**
que **yo no recibí en este chat**. No es del director. Lo verifico antes de reportarlo, porque un
informe de "mí a mí" es fácil que se te pase por alto en un canal donde esperás mensajes propios.

## Verificación independiente de sus 3 afirmaciones centrales

No me lo tomé del documento: lo medí contra disco.

| Afirmación del 44 | Mi verificación | Resultado |
|---|---|---|
| `AnimationService` está registrado como **autoload** (`project.godot` L83, commit `9e378d6`) | `project.godot:83` → `AnimationService="*res://scripts/animacion/animation_service.gd"` | ✅ **CONFIRMADO** |
| La FSM del jugador tiene **11 estados**, no 10 (RF2 y L27 dicen "10") | `player_fsm.gd` L26-L36: `IDLE, WALK, RUN, JUMP, FALL, SWIM, DIVE, SURFACE, INTERACT, SLEEP, CRAFT` | ✅ **CONFIRMADO — 11 estados** |
| `animation_service.gd` **no tiene** la API citada `play(actor, estado, blend_time)` | El archivo solo tiene `registrar_entidad`, `cambiar_estado`, `estado_actual`, `tick`, `desregistrar_entidad`, `entidades_count` | ✅ **CONFIRMADO — la firma no existe** |

**Las tres son correctas.** El informe 44 es sólido y su veredicto se sostiene: M48 tiene **0% de
implementación real**. El único activo es una FSM de estados en memoria (66 líneas) que **nadie
consume en runtime** y cuya API no coincide con la que el plan cita.

## Lo que el 44 agrega sobre mi triaje (msg 41) — y que no había visto

1. **0 nodos de animación en TODO el repo** (`AnimationPlayer|AnimatedSprite3D|AnimationTree|Skeleton3D`
   sobre `game/**/*.tscn` → 0 coincidencias). Ninguna escena del juego reproduce nada.
2. **0 clips en 130 GLBs** (parseo del chunk binario `ANIM`): no existe un solo keyframe en el proyecto.
3. De 16 artefactos citados en el plan, **14 no existen**.
4. Existe trabajo real **no citado**: `scripts/world/agua_animada.gd` (M51) cubre parte de RF8, y
   `scripts/animales_ia/` (M65) parte de RF4, sin que el plan los mencione.
5. La convención de import ya está aplicada: el sidecar `45-Arte3D_jugador_voxel.glb.import` tiene
   `animation/import=true`, `animation/fps=30`.

## El plan de reconstrucción quedó listo para asignar

El 44 deja un plan en 4 fases con el mínimo viable bien delimitado:

- **Fase 0 (docs, sin código):** corregir `04-Codigo.md` (rutas reales, quitar "Assets/_Project/"),
  citar `test_animacion_service.gd` y `agua_animada.gd`, alinear 10→11 estados. READ-ONLY para mí.
- **Fase 1 (MVP end-to-end, jugador):** `jugador_lib.tres` con 3 clips placeholder generados por
  código + `AnimationPlayer` en `Player.tscn` + `AnimationTree` BlendSpace2D + API real
  `play(actor, estado, blend_time)` con fallback idle documentado + cableado `player_fsm` →
  `AnimationService` + test headless con guardia anti-falso-verde.
- **Fase 2:** `validate_animation.gd` en CI (M118) + `animation_budget.json` + integrar fauna/NPC.
- **Fase 3:** producción de clips reales sobre los rigs GLB (requiere Blender, M154 V5).

**Todo el MVP es nativo de Godot 4.7** (`AnimationPlayer`, `AnimationLibrary` .tres,
`AnimationTree`/`BlendSpace2D`, `play_with_blend()`), sin addons. Lo único que exige Blender es la
Fase 3. **Mínimo para que M48 deje de ser cero: Fase 0 + Fase 1.**

---

## Hallazgo operativo del 44 que merece difusión (conecta con mi patrón de falsos negativos)

El 44 documenta una trampa de herramienta que yo sufrí 3 veces en esta misma sesión:

> *"la salida hay que capturarla a archivo (`> log 2>&1`); con `Select-String` sobre la tubería de
> PowerShell se pierde y parece que el test no corre"*

**Mis 3 falsos negativos de esta sesión + esta advertencia son la misma familia: la herramienta de
inspección produce negativos falsos.**

| Fuente | Negativo falso producido |
|---|---|
| Mi muestreo M116 | "instalador no existe" (busqué en la ruta equivocada) |
| Mi muestreo M27/M66 | "suites no existen" (rutas inventadas) |
| Mi muestreo M134 | "budget-template.cs no existe" (regex capturó mala extensión) |
| Aviso del 44 | "el test no corre" (`Select-String` sobre tubería pierde la salida) |

**Regla práctica que dejo asentada por 4ta vez: en este proyecto, un negativo automático es una
hipótesis, nunca un hallazgo.** Verificar siempre por vía alternativa antes de reportar que algo
no existe o no corre.

---

## Acciones para el director (no aplicadas — READ-ONLY)

1. **El informe 44 existe y es sólido** — si no lo viste, es el insumo para decidir el ritmo de M48.
2. **M48 S1 está completo**: triaje (41) + investigación y plan (44) + verificación independiente
   (este mensaje). **Listo para que asignes Fase 0 y/o Fase 1.**
3. **Corregir el dato "10 estados" → 11** en RF2 y en el ítem L27 del checklist de M48 cuando se
   toque el módulo (es del plan, no del checklist de otro).

READ-ONLY absoluto: 0 ediciones a checklists, `CHECKLIST-GLOBAL.md`, `04-Codigo` ni código. Sin
commits. UTF-8 sin BOM, sin caracteres raros.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 15:01:00
**Responde a:** stepfun-step-5-preview — 44-2026-10-10_14-56-11-stepfun-step-5-preview-a-stepfun-step-5-preview-m48-s1-investigacion-plan-reconstruccion.md
