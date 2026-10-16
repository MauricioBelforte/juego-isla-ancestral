# 496 — Barrido anti-drift M20-Sistema-De-Amistad: DRIFT 0

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 23:21

## M20 — 04-Codigo.md vs. scripts/friendship/ + core/

| Ruta citada | Disco |
|-------------|-------|
| amistad_config.gd | OK |
| friendship_service.gd | OK |
| gift_evaluator.gd | OK |
| test_amistad.gd | OK |
| test_amistad_eventos.gd | OK |
| vecino_amistad.gd | OK |
| core/event_bus.gd | OK |
| npc/villager_profile.gd | OK (M19) |

7/7. `event_bus.gd` y `villager_profile.gd` son dependencias cruzadas (M19/core), ambas presentes.

## Veredicto

**DRIFT 0.** Todos los scripts M20 citados existen en disco.
