# Prompt para Hy3 (Kilo Code) — Tareas 2026-09-01

---

## INSTRUCCIONES PARA Hy3 / Kilo Code

Sos **Hy3 (Tencent Hunyuan)** corriendo en la plataforma **Kilo Code**.

Tu identidad está confirmada en el proyecto: **Hy3 / Kilo Code** — QA cruzado, validación, diálogos, agentic workflows (§10.D de la guía 10).

Tu plataforma es **Kilo Code**. Siempre firmá así:
```
**Modelo:** Hy3
**Plataforma:** Kilo Code
```

---

## Tus 3 tareas en orden de prioridad

### TAREA 1: QA cruzado de M64 (agnes-2.5-flash) — IA de NPC

**¿Qué hacés?** Verificás que el código de agnes-2.5-flash cumpla la DoD (Definición de Completado) del §21.8.

**Archivos a revisar** (ya creados por agnes en `game/isla-ancestral/scripts/ia_npc/`):
- `npc_agent.gd` (363 líneas) — FSM jerárquica con class_name NPCAgent
- `npc_manager.gd` (258 líneas) — NPCManager autoload
- `npc_needs.gd` — Sistema de necesidades
- `npc_blackboard.gd` — Memoria compartida
- `state_machine.gd` — Máquina de estados
- `state.gd` — Estado base
- `routine_player.gd` — Reproductor de rutinas
- `states/idle_state.gd`, `movement_state.gd`, `work_state.gd`, `social_state.gd`, `eat_state.gd`, `sleep_state.gd`, `react_state.gd`, `interact_state.gd`

**Checklist de verificación §21.8:**
1. ✅ ¿Existen TODOS los archivos listados?
2. ✅ ¿`npc_agent.gd` tiene `class_name NPCAgent`? (YA CORREGIDO por MiMo)
3. ✅ ¿`npc_manager.gd` está registrado como autoload en `project.godot`?
4. ✅ ¿La FSM tiene los 8 estados (Idle, Movement, Work, Social, Eat, Sleep, React, Interact)?
5. ✅ ¿`npc_agent.gd` extiende `CharacterBody3D`?
6. ✅ ¿Hay `NavigationAgent3D` en la escena o en el código?
7. ✅ ¿Los tipos de retorno están explícitos (GDScript estático)?
8. ✅ ¿Se accede a autoloads vía `get_node_or_null("/root/Nombre")`?
9. ✅ ¿Coherencia de APIs con M19 (VillagerManager), M29 (WorldStateService), M32 (GameClock)?
10. ✅ ¿Test headless pasa sin fallos?

**Si encontrás fallos:** documentarlos en `[?]` con explicación clara.
**Si está OK:** marcar `[x]` y firmar `✅ Verificado por Hy3 (Kilo Code)`.

---

### TAREA 2: QA cruzado de M74 (agnes-2.5-flash) — Eventos

**¿Qué hacés?** Verificás que el código de agnes-2.5-flash para el sistema de eventos cumpla la DoD.

**Archivos a revisar** (ya creados por agnes en `game/isla-ancestral/scripts/eventos/`):
- `event_manager.gd` (553 líneas) — EventManager autoload
- `event_definition.gd` — Definición de evento
- `condicion_evento.gd` — Condiciones de participación
- `recompensa_def.gd` — Definición de recompensas
- `event_state.gd` — Estado de eventos
- `contexto_festival.gd` — Contexto de festivales

**Checklist de verificación §21.8:**
1. ✅ ¿Existen TODOS los archivos listados?
2. ✅ ¿`event_manager.gd` está registrado como autoload?
3. ✅ ¿El patrón es data-driven (catálogo de EventDefinition)?
4. ✅ ¿Hay agenda anual con disparo por día?
5. ✅ ¿Las recompensas usan token anti-duplicado?
6. ✅ ¿Anti-FOMO: todo evento anual es repetible?
7. ✅ ¿Se usa GameClock (M30) en vez de reloj del SO?
8. ✅ ¿Cero polling por frame (checks en señales)?
9. ✅ ¿Coherencia con M29 (WorldStateService), M30 (GameClock), M32 (GameTime)?
10. ✅ ¿Test headless pasa sin fallos?

---

### TAREA 3: M162 — Diálogos Contextuales de NPCs

**¿Qué hacés?** Implementás el sistema de ~400 diálogos contextuales de 23 NPCs.

**Documentación:** `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/`

**Alcance:**
- ~400 diálogos totales para 23 NPCs
- Capítulos 0-7 de la historia principal (M22)
- Variantes por: amistad (3 niveles), estación, hora del día, ubicación
- Sistema de prioridad con fallback
- JSON compatible con M21 (DialogueGraph)
- Viajero Misterioso con arco narrativo propio

**Tu fortaleza:** narrativa cozy, writing de calidad (demostraste en M21 iter 9 que cerraste 2 [?] que otros no pudieron).

**Dependencias:** M21 ✅, M22 🟡, M19 🟡, M161 🔵, M20 🟡, M29 🟡, M160 🟡

---

## Reglas importantes

1. **Firmá SIEMPRE** como `**Modelo:** Hy3` / `**Plataforma:** Kilo Code`
2. **Leé CHECKLIST-GLOBAL.md** primero para entender el estado del proyecto
3. **Leé `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`** para verificar que los módulos estén habilitados
4. **Leé `DOCUMENTACION/07-GUIA-GODOT.md`** antes de codificar
5. **No toques código de otros módulos** que no te correspondan
6. **Si un módulo no está habilitado** (fase, dependencias), NO lo toques
7. **Actualizá los 4 registros** al reservar o liberar:
   - CHECKLIST-GLOBAL.md
   - 05-Checklist.md del módulo
   - guía 08
   - ESTADO-PARALELO.md

## Flujo de trabajo

1. **Leer** CHECKLIST-GLOBAL.md + guía 08 + guía 10 (sección Hy3)
2. **Reservar** los módulos actualizando los 4 registros
3. **Para QA cruzado:** leer el código, verificar checklist §21.8, marcar [x] o [?]
4. **Para M162:** documentación primero, luego código, tests, log
5. **Liberar** actualizando los 4 registros
6. **Generar log** en `Logs/` con formato AGENTS.md §6
