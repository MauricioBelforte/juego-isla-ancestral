**Modelo:** atria-dawn-s3 (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 23:40

# Plan de implementación M48-Animación — mapeo de los 111 `[ ]`

> Pedido del director (msg 166 §2: "M48 es el próximo cuello de botella... necesita un plan de
> implementación — es tu próximo análisis de delegación. Preparalo."). Prometido en mi msg 139.

## Estado actual verificado en disco

| Artefacto | Estado |
|---|---|
| `scripts/animacion/animation_service.gd` | ✅ existe (5.1 KB) — Fase 1 Step 5 (Log 1603) |
| `scripts/animacion/animacion_jugador_m48.gd` | ✅ existe (1.8 KB) — polling de FSM por estado |
| `scripts/animacion/test_animacion_play_m48.gd` | ✅ existe (4.4 KB) — 12/0 |
| `scripts/animacion/test_animacion_service.gd` | ✅ existe (2.6 KB) |
| `scripts/animacion/libraries/jugador_lib.tres` | ✅ existe — 3 clips placeholder (ruta confirmada) |
| Conteo estricto | 9 `[x]` / 111 `[ ]` / 3 `[?]` = 123 (GLOBAL L236 dice 9/123 — cuadra) |

**Nota resuelta:** el checklist L28 cita `jugador_lib.tres` y está en
`scripts/animacion/libraries/jugador_lib.tres` (confirmado en disco). La carpeta `resources/animacion/`
no existe — la librería vive junto a los scripts. **Punto a decidir al delegar Fase 2:** si las
librerías futuras van en `scripts/animacion/libraries/` (actual) o en `resources/animacion/` (más
idomático para Godot). Recomiendo `resources/animacion/` para clips importados, dejando
`scripts/` solo para `.gd`.

## Mapeo de los 111 `[ ]` por tipo de trabajo

### Grupo 1 — Documentación pura (46 items, delegable HOY, sin dependencias)

Definiciones, convenciones, pipeline, integraciones, riesgos, criterios. No toca código ni Blender.

| Sec | Items | Contenido |
|---|---|---|
| A | 7 | Objetivos, dependencias, restricciones, criterios de aceptación, contexto plan producción |
| B | 5 | Pipeline rig→blocking→polish→export, convenciones FBX, familias de rigs, máx. duración |
| N | 2 | Prefijos `anim_`, librerías por actor |
| Q | 6 | RNF: rendimiento, memoria, cozy, accesible, determinismo, mantenible |
| R | 6 | Alternativas descartadas (6 documentos de decisión) |
| S | 6 | Riesgos y mitigaciones |
| T | 10 | Documentar integraciones con M11/M19/M36, M64/M65, M45, M13, M43/M44/M52, M50/M51, M21/M53/M58, M61/M62, M74, M108/M118 |
| U | 3 | Flujo de producción de un clip, flujo de validación al importar, plantilla import FBX |
| W | 1 | Desfase de numeración plan maestro (47=ANIMACIÓN → ID 48) |

**Candidato:** cualquier modelo con créditos (agnes, mimo, DeepSeek). Es trabajo de planificación
que ya hicieron en otros módulos. **No requiere visión.**

### Grupo 2 — Godot puro, sin Blender (24 items, dependencias externas)

Script/shaders/data Godot. **No requiere assets 3D.**

| Sec | Items | Contenido | Dependencia |
|---|---|---|---|
| I | 4 | Viento procedural determinista, ondas de agua, fuego procedural, sin RNG en runtime | M50/M51/M52 (🟡) |
| J | 6 | Transiciones de menú 60 fps, recompensas/sparkles, tooltips, diálogos, Reduce Motion, no animar UI off-screen | **M53 ✅** (libre), M58 (🟡 131/183) |
| L | 5 | Burbuja ≤60 actores, idle simplificado fuera de burbuja, blend trees ≤4 nodos, pooling, keyframes optimizados | M61/M62 (🟡) |
| M | 5 | `validate_animation.gd`, naming, fps, duración, T-pose, keyframes de evento — 2 ya son `[?]` | autónomo |
| O | 2 | `animation_budget.json`, suma por escena pivote, alerta de excedente — 1 ya es `[?]` | M61 |
| P | 2 | Señales `animation_started/finished/missing`, prohibir que animación decida comportamiento | **autónomo — extiende AnimationService existente** |

**Candidato ideal para P:** Step 5 (escribió `animation_service.gd`, conoce el código) o DeepSeek.
**J es el sub-bloque más desbloqueado** (M53 ✅ sellado hoy).

### Grupo 3 — Requiere Blender / assets 3D (33 items, Fase 3, **NO AUTORIZADA**)

Clips de animación reales. Bloqueados por M45-Arte-3D (🟡 20/171).

| Sec | Items | Contenido |
|---|---|---|
| C | 6 | 11 estados FSM jugador (saltar, nadar, escalar, extraer, minar, pescar, cosecha, dormir), blend space 2D, sockets de herramientas |
| D | 5 | NPC: idle, caminata, rutinas de trabajo, conversación, festivas, variantes por personalidad |
| E | 3 | Fauna: estados M36/M65, fases de manada, LOD de animación |
| F | 5 | 9 herramientas × 4 niveles, swing de minado, plantación, pesca, martillo y lupa |
| G | 6 | Puertas, puentes, mecanismos, ascensores, construcción, puzzles |
| H | 3 | Barcos, dirigibles, submarinos |
| K | 5 | Sincronía: eventos de sonido/feedback/partículas embebidos en timelines |

**M45 está 20/171** — sin rigs, no hay clips. **K además depende de M43 (59/100).** Ninguno se delega
hasta que el director autorice Fase 3 y M45 avance.

### Grupo 4 — Verificación con runtime (8 items)

Sección V: los 8 criterios de aceptación. Requiere juego corriendo con clips reales → **va al final,
después del Grupo 3.**

## Orden propuesto (Fase 2)

```
Paso 1 (resuelto): ruta de jugador_lib.tres confirmada -> scripts/animacion/libraries/
Paso 2: Grupo 1 (46 items doc) → 1-2 modelos en paralelo, sin pisarse por sección
Paso 3: Grupo 2-P (2 items) → Step 5 o DeepSeek, extiende su propio código
Paso 4: Grupo 2-J (6 items UI) → depende M53 ✅, delegable ya
Paso 5: Grupo 2-I/L/M/O (16 items) → dependencias M50/M51/M52/M61/M62; M y O autónomos
Paso 6: Grupo 3 (33 items) → ESPERAR autorización Fase 3 + M45
Paso 7: Grupo 4 (8 items V) → al final, con runtime completo
```

## Por qué este orden

1. **El Grupo 1 es el 41% del módulo y no tiene bloqueos.** Es lo de mayor retorno/hora ahora mismo.
2. **El Grupo 2-P es el más barato y desbloquea el Grupo 3-K** (las señales son la API que los
   timelines van a emitir).
3. **M45 (20/171) es el cuello real.** Sin rigs no hay Fase 3. Si el director quiere acelerar M48,
   la palanca es M45, no M48.
4. **Fase 3 sin autorización = no tocar** (director msg 166: "M48 Fase 2-3 siguen sin autorizar";
   mi msg 139 lo marcó como no delegable).

## Lo que NO incluye este plan

- **Fase 3 (Blender) no se delega** — falta autorización del director y M45 no está listo.
- **BUG-107 sigue sin dueño** (reportado en mi msg 139).
- **Drift del `.gitignore` raíz (3144 archivos)** sigue sin dueño (mimo msg 108).
