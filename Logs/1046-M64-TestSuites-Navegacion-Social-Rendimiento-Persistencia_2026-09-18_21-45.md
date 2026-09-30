# Log 1046: M64 — FASE 1 COMPLETADA: Docs + GameClock + CI + Group C + Release

**Fecha:** 2026-09-18
**Hora:** 22:25
**Modelo:** mimo-v2.5
**Plataforma:** OpenCode

## Resumen
Cierre de FASE 1 de M64: documentación actualizada (03-Diseno + 04-Codigo), GameClock pause integration, CI gate duro para 5 suites, Group C [?] con owners, Totales corregidos a 100/117. Release como 🟡 (17 [?] pendientes: 12 external + 5 runtime).

## Resumen
Creación de 4 suites de testing nuevas para M64 (navegación, social, rendimiento, persistencia), fix de bug en `npc_needs.gd` que bloqueaba compilación, implementación de selectividad social y separación entre NPCs, actualización de checklist a 88/120.

## Cambios Realizados

### FASE 1 (22:10-22:25)
- **03-Diseno.md:** Reescrito completo — FSM plana, PlanStack, Watchdog, rutinas Dictionary, necesidades config, navegación, social, reacciones, GameClock
- **04-Codigo.md:** Actualizado — 12 scripts, 8 estados, 5 tests (142 checks), CI, firmas, correcciones
- **npc_agent.gd:** pause_ai()/resume_ai()/is_paused() + dia_cambio signal connection para reset de rutinas
- **quality.yml:** 4 tests nuevos cableados con gate duro (lineas 328-331)
- **05-Checklist.md:** 12 docs items [x] + 2 routine items [x] (no requeridos) + GameClock [x] + perf [x] = 100/117
- **Group C:** 12 [?] con owners (M08, M17, M20, M21, M65) + 5 [?] runtime + 1 visual [?] (host sin GUI)
- **CHECKLIST-GLOBAL row 64:** 🟡 100/117 (released)
- **ESTADO-PARALELO.md:** Entry updated
- **BACKLOG-MASTER.md:** M64 section updated

### FASE anterior (21:45)
- 4 suites de testing (60 checks, 0 fallos)
- npc_needs_config.gd/.tres
- npc_agent.gd selectividad social + separación
- npc_needs.gd fix set_config()
- **`test_navegacion_m64.gd`** — 9 checks, 0 fallos
  - Watchdog: register_npc, on_state_changed, unregister_npc, ciclo de transiciones
  - Separación: constantes SEPARATION_FORCE=1.5, SEPARATION_RADIUS=1.5, MAX_SIMULTANEOUS_SOCIALS=3
  - Verificación de distancias entre NPCs
- **`test_social_m64.gd`** — 14 checks, 0 fallos
  - NPCNeeds: iniciales, decremento por delta, recuperación (eat/sleep/socialize), config override
  - Selectividad social: partner matching por job
  - Límites: MAX_SIMULTANEOUS_SOCIALS=3, SEPARATION_RADIUS=1.5
- **`test_rendimiento_m64.gd`** — 8 checks, 0 fallos
  - 60 NPCs × 60 frames: 3ms (dentro de budget)
  - 100 NPCs × 100 frames mixed: 4ms (dentro de budget)
  - Watchdog integrado sin overhead significativo
- **`test_persistencia_m64.gd`** — 29 checks, 0 fallos
  - Bloque A: NPCNeeds serialización (to_dict/from_dict, 10 checks)
  - Bloque B: NPCBlackboard serialización (to_dict/from_dict, 8 checks)
  - Bloque C: NPCPlanStack serialización (to_dict/from_dict, 7 checks)
  - Bloque D: Roundtrip completo cross-component + independencia de copias (4 checks)

### 2. Bug fix `npc_needs.gd` (línea 38-48)
- **Problema:** `cfg.get("hunger_rate", hunger_rate)` fallaba porque `Resource.get()` solo acepta 1 argumento
- **Causa:** API de GDScript `Object.get()` ≠ `Dictionary.get()`
- **Solución:** Cambiado a `cfg.get("hunger_rate")` con null-check posterior
- **Impacto:** Sin este fix, `npc_agent.gd` y todos los tests que importan `npc_needs.gd` no compilaban

### 3. `npc_agent.gd` — Selectividad social + Separación
- `_select_social_partner()` prioriza NPCs con mismo job (same_role_weight)
- `apply_separation()` fuerza de repulsion SEPARATION_FORCE=1.5, radio SEPARATION_RADIUS=1.5
- `MAX_SIMULTANEOUS_SOCIALS=3` — límite de socializaciones activas
- `_get_nearby_node()` helper para obtener nodos cercanos por nombre

### 4. `npc_needs_config.gd` + `npc_needs_config.tres`
- Resource configurável con rates (hunger_rate=1.0, energy_rate=0.5, social_rate=0.3)
- Umbrales configuráveis (hunger_urgency=20.0, energy_urgency=15.0, social_urgency=20.0)
- Valores default en `data/ia/npc_needs_config.tres`

### 5. Actualización de checklist
- **05-Checklist.md:** 78/117 → 88/120 (+10 [x])
- **CHECKLIST-GLOBAL row 64:** 78/117 → 88/120, column drift corregido (11→10 fields)
- **Totales block** agregado al final del checklist
- **Notas del Agente** agregadas al final del checklist

### 6. Group A re-verification
- Rutinas: RoutineDefinition/RoutineSlot no existen como .gd separados — correcto por diseño (Dictionary en VillagerProfile)
- Day-change reset: GAP (no `dia_cambio` connection)
- ±15min variation: GAP (no randomization en routine_player.gd)
- Erratic behavior: necesita verificación runtime
- Visual transitions: sin vía de visión en este host

## Archivos Modificados/Creados
- `scripts/ia_npc/test_navegacion_m64.gd` — NUEVO (9 checks)
- `scripts/ia_npc/test_social_m64.gd` — NUEVO (14 checks)
- `scripts/ia_npc/test_rendimiento_m64.gd` — NUEVO (8 checks)
- `scripts/ia_npc/test_persistencia_m64.gd` — NUEVO (29 checks)
- `scripts/ia_npc/npc_needs.gd` — FIX set_config() (líneas 38-48)
- `scripts/ia_npc/npc_agent.gd` — ADD selectividad social + separación + límites
- `scripts/ia_npc/npc_needs_config.gd` — NUEVO Resource config
- `data/ia/npc_needs_config.tres` — NUEVO valores default
- `DOCUMENTACION/64-IA-De-NPC/plan-actual/05-Checklist.md` — UPDATE 88/120 + Totales + Notas
- `CHECKLIST-GLOBAL.md` — UPDATE row 64: 88/120

## Tests — Resumen Final
| Suite | Checks | Fallos | Estado |
|-------|--------|--------|--------|
| test_ia_npc_m64_iterN | 82 | 0 | ✅ |
| test_navegacion_m64 | 9 | 0 | ✅ |
| test_social_m64 | 14 | 0 | ✅ |
| test_rendimiento_m64 | 8 | 0 | ✅ |
| test_persistencia_m64 | 29 | 0 | ✅ |
| **TOTAL** | **142** | **0** | ✅ |
