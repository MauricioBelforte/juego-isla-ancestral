# 495 — Barrido anti-drift M19-NPC-Y-Vecinos: DRIFT 0

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 23:16

## M19 — 04-Codigo.md vs. scripts/npc/

| Ruta citada | Disco |
|-------------|-------|
| villager_profile.gd | OK |
| villager_mood.gd | OK |
| villager_dialogue_hook.gd | OK |
| villager.gd | OK |
| villager_manager.gd | OK |
| test_catalogo_m19_atria.gd | OK |
| test_mudanzas.gd | OK |

7/7 existen. Nota del doc: `interacciones/interaction_manager.gd` tiene errores de parse en headless (módulo M70, en curso de otro agente) — agnes no lo tocó. No es drift de M19; es deuda de M70.

## Veredicto

**DRIFT 0.** Todos los scripts M19 citados existen en disco. La nota de interaction_manager es deuda externa (M70), no M19.
