# Log 1040: M64 — FSM PlanStack + Watchdog + Test Suite Headless (82/0)

**Fecha:** 2026-09-18
**Hora:** 21:05
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen

Implementación completa del core de IA de NPC (M64) con FSM plan-aware, watchdog anti-atascos, 6 perfiles de rutina, y suite de test headless 82/0.

## Cambios Realizados

### Archivos creados
- `scripts/ia_npc/plan_stack.gd` — NPCPlanStack: memoria de planes con push/pop/peek/serialización/profundidad máx 8
- `scripts/ia_npc/npc_watchdog.gd` — NPCWatchdog: detección de stuck por timeout, transiciones burst, recovery actions
- `scripts/ia_npc/test_ia_npc_m64_iterN.gd` — Suite headless 82 checks en 6 bloques (PlanStack/Watchdog/Needs/Blackboard/FSM/Integration)
- `data/villagers/mercedes_lince.tres` — Perfil de mercader viajero (lince, birthday Apr 7, 31 años, rutina 06:00-20:00)

### Archivos modificados
- `scripts/ia_npc/state_machine.gd` — Integración plan_stack, fallback→pop+recover, `clear_plans()`, fix `is_fallback` para estados no existentes
- `scripts/ia_npc/npc_manager.gd` — BudgetRegistry (32MB), init_watchdog, agent↔watchdog routing
- `scripts/ia_npc/test_ia_npc_m64_iterN.gd` — 9 iteraciones de debugging hasta 82/0
- `data/villagers/mateo_mapache.tres` — Rutina diaria enhanced 06:00-20:00
- `data/villagers/luna_zorra.tres` — Rutina diaria child 07:00-20:00
- `data/villagers/bruno_sapo.tres` — Rutina diaria elderly 07:00-19:00
- `.github/workflows/quality.yml` — Test M64 wired (`|| FAIL=1`)
- `DOCUMENTACION/64-IA-De-NPC/plan-actual/05-Checklist.md` — 78/117 (was 61/110)

### Bug corregido
- `state_machine.gd:69` — `is_fallback` solo detectaba `target == "Idle"`. Cuando un estado no existe (ej: "Eat"), el fallback a Idle no se detectaba y el estado fantasma se pusheaba. Fix: variable `fell_back` que marca cuando `next == null`.

## Lecciones Aprendidas (GDScript)

1. **`preload()` de scripts con `class_name` puede fallar** con "Could not find type" durante compilación. Fix: `preload().new()` local.
2. **`Resource.get()` solo toma 1 argumento** (no como `Dictionary.get(key, default)`).
3. **`_ready()` no se llama** si el nodo no está en SceneTree. Tests que instancian `Node.new()` deben inicializar dependencias manualmente.
4. **Lambda captures en signal.connect() son poco confiables** en GDScript. Usar flags de clase en vez de lambdas para callbacks de signals.

## Archivos Modificados/Creados
- Ver lista arriba

## Estado
✅ **82 checks, 0 fallos — EXIT CODE: 0**
