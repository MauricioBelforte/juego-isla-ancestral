# 36-Fauna — Código (plan-actual)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

## Archivos involucrados
- `game/isla-ancestral/scripts/fauna/fauna_species.gd` — Resource (datos + validación).
- `game/isla-ancestral/scripts/fauna/fauna_catalog.gd` — RefCounted (carga JSON/fallback).
- `game/isla-ancestral/scripts/fauna/fauna_registry.gd` — autoload (descubrimiento + save).
- `game/isla-ancestral/scripts/fauna/fauna_manager.gd` — autoload (orquestación + tick M65).
- `game/isla-ancestral/scripts/fauna/fauna_behavior.gd` — Node3D (FSM + avistamiento).
- `game/isla-ancestral/scripts/fauna/test_fauna.gd` — test headless (59 checks).
- `game/isla-ancestral/data/fauna/catalog.json` — 7 especies.

## Funciones clave
- `FaunaCatalog.candidatas_para(hora, bioma)` — filtro ventana horaria + bioma.
- `FaunaRegistry.registrar_avistamiento` — dedupe 30s, tolerancia 0.5s, distancia ≤24m.
- `FaunaBehavior.tick` — transiciones de FSM y emisión de avistamiento/movimiento.
- `FaunaManager._process` — delega tick a `animal_ai` (M65).

## Logs relacionados
- Log 376 (implementación minimax-m3-free, 59 OK/0).
- Log 414 (QA cruzado Hy3: fix deriva constantes).

## Notas del Agente (QA)
**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 00:30
**Estado:** QA cruzado aprobado (mantiene 🟡; resto de `[?]` con dueño externo).

### Lo que verifiqué
- Coherencia de código, integridad de `catalog.json`, autoloads en `project.godot`,
  contrato API M36↔M65.

### Lo que corregí
- Deriva de constantes en `fauna_behavior.gd` (literales 24.0/0.5 → constantes de
  `fauna_registry.gd`).

### Recomendaciones para el próximo agente
- Crear `DOCUMENTACION/36-Fauna/plan-inicial/` (reversa) si se requiere trazabilidad.
- Resolver `[?]` con dueño: spawner M09 (burbuja 72m), UI diario M55/M37, visuales M45, clima M32.
