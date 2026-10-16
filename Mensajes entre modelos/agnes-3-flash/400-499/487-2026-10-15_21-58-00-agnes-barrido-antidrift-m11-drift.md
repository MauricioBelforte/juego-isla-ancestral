# 487 — Barrido anti-drift M11-Personaje-Del-Jugador: DRIFT (nota QA obsoleta)

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 21:58

## M11 — 04-Codigo.md vs. scripts/player/

El 04-Codigo.md (sección "Notas del Agente", L115) afirma:

> "**6 scripts previstos no existen**: `player_controller.gd`, `player_fsm.gd`, `interaction_service.gd`, `light_collector.gd`, `player_energy.gd` y `character_selector.gd`"

## Verificación contra disco (Get-ChildItem scripts/player/*.gd)

| Script | Afirmación doc | Realidad disco | Drift |
|--------|---------------|----------------|-------|
| player_controller.gd | no existe | no existe | OK |
| **player_fsm.gd** | **no existe** | **EXISTE** | **DRIFT** |
| interaction_service.gd | no existe | no existe | OK |
| light_collector.gd | no existe | no existe | OK |
| **player_energy.gd** | **no existe** | **EXISTE** | **DRIFT** |
| **character_selector.gd** | **no existe** | **EXISTE** | **DRIFT** |

## Veredicto

**DRIFT = 3**: la nota QA de M11 está **obsoleta** — fue escrita cuando `player_fsm.gd`, `player_energy.gd` y `character_selector.gd` aún no existían. Hoy los 3 están en `scripts/player/` (lista real: 15 .gd, incluye también player_core_m11.gd, equipment_*.gd, terrain_bonus_table.gd).

La nota de "0 menciones de stamina/FSM/IInteractable" (L112) también quedó obsoleta: `i_interactable.gd` y `interaction_manager.gd` sí existen en scripts/.

## Recomendación

El que actualice M11 (o QA) debe refrescar la sección "Notas del Agente" del 04-Codigo.md: los 6 "no existen" se reducen a 3 reales (`player_controller`, `interaction_service`, `light_collector`); `player_fsm`, `player_energy`, `character_selector` **ya existen**. No es bloqueante: no hay ítem `[x]` inflado, solo una nota de estado desactualizada.
