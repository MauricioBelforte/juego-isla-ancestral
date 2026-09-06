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
- `game/isla-ancestral/scripts/fauna/jabali_npc.gd` — NPC cuadrúpedo con sistema de etapas (joven/adulto).
- `game/isla-ancestral/scenes/main_island.tscn` — contiene `JabaliNPC` (etapa=joven) y `JabaliAdultoNPC` (etapa=adulto).
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

## Jabalí — etapas de vida (feedback usuario 2026-09-03)

Tercer animal del pipeline Blender→Godot→movimiento (ver 07-GUIA-GODOT §11, guía 09 §9).
`jabali_npc.gd` implementa un sistema de **etapas** (`@export_enum("joven","adulto") etapa`)
que ajusta automáticamente escala/velocidad/rebote/pausas al setearse en el inspector:

- `_CFG_ETAPA`: diccionario con los parámetros por etapa.
  - `joven`:  escala 1.5, velocidad 1.7, rebote 0.022, pausa 1.5–5.0 s (trote liviano).
  - `adulto`: escala 2.3, velocidad 1.2, rebote 0.030, pausa 3.0–8.0 s (bruto pesado, pausado).
- `_aplicar_etapa()` se llama en `_ready()` y propaga los valores a las `@export`.
- Animación: trote diagonal (FL+BR / FR+BL en contrafase), cola-cuerda, cabeceo de
  husmeo, rebote de trote sincronizado. Escala del GLB desde los pies (crece hacia arriba).
- Snap al terreno vía `TerrainLocator` (get_height + 1), igual que el resto de fauna.
- En `main_island.tscn` se instancian dos nodos: `JabaliNPC` (joven) y `JabaliAdultoNPC` (adulto).

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
