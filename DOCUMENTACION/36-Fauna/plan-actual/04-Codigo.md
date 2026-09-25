# 36-Fauna — Código (plan-actual)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-25 (P-49, Log 1165)

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
- `game/isla-ancestral/scripts/fauna/fauna_spawner.gd` — nodo de escena (P-49, Log 1165): instancia criaturas `fauna_behavior` en main_island.
- `game/isla-ancestral/scenes/main_island.tscn` — contiene además `FaunaSpawner` (nodo con el script anterior, P-49).

## Funciones clave
- `FaunaCatalog.candidatas_para(hora, bioma)` — filtro ventana horaria + bioma.
- `FaunaRegistry.registrar_avistamiento` — dedupe 30s, tolerancia 0.5s, distancia ≤24m.
- `FaunaBehavior.tick` — transiciones de FSM y emisión de avistamiento/movimiento.
- `FaunaManager._process` — delega tick a `animal_ai` (M65).
- `FaunaSpawner._process` — poblado inicial (frame 2) + re-spawn periódico (P-49): especie por `especie_aleatoria_para(hora, bioma)` + tamaño de grupo por `candidatos_de_especie`.

### P-49 (Log 1165, agnes-3-flash) — Spawner de fauna en main_island
El "iter 2" que `fauna_manager.gd` dejaba pendiente ("instanciar los nodos") se cerró
parcialmente con `fauna_spawner.gd` + el nodo `FaunaSpawner` de `main_island.tscn`:
- **Zonas de bioma** nominales derivadas de `MundoRaiz` (pradera = `SPAWN_CONTENIDO`,
  playa/humedal = banda costera hacia `RADIO_ORILLA`): M09 aún no expone
  `bioma_de_posicion`, así el spawner usa anillos documentados, no magic numbers.
- **Criaturas**: `Node3D` + `fauna_behavior` + mesh placeholder de esfera (M45 entregará
  modelos reales) + escala/color por `FaunaSpecies` (`escala_min/max`, `color_variantes`).
- **Auto-registro M65**: al `add_child`, `fauna_behavior._ready` registra en
  `animal_ai` → la especie gregaria crea `PackLogic`/`SchoolLogic` reales en la escena.
- **Snap de terreno**: `TerrainLocator.get_height` (tierra `h>=3`, BUG-022; acuáticas en
  franja 2.5–4.5; aéreas sobrevuelan).
- **Lookup de autoloads lazy** vía `Engine.get_main_loop().root.get_node_or_null(...)`
  (el `fauna` no está listo en el `_ready` del nodo: se reintenta hasta frame 120).
- **Evidencia headless (Godot 4.7.2)**: `main_island.tscn --quit-after 300` ×2 = 0 SCRIPT
  ERROR; logs `[M65] Manada (PackLogic) creada para conejo_pradera` + 2× `[M65] Banco
  (SchoolLogic) creado para gaviota_playera/cangrejo_humedal` + `[M36-SPAWNER] población
  inicial: 9/10 individuos en 3 zonas` (tamaños de grupo = range manada_min..max).
- **Queda `[?]` (dueño M09)**: el spawner completo "burbuja 72m" con `bioma_de_posicion`
  del M09 y despawn/densidad por distancia al jugador. Este spawner es la base (zonas
  fijas, tope `MAX_INDIVIDUOS=24` ≤ presupuesto de `animal_ai` 40).

## Logs relacionados
- Log 376 (implementación minimax-m3-free, 59 OK/0).
- Log 414 (QA cruzado Hy3: fix deriva constantes).
- Log 1165 (P-49, agnes-3-flash: spawner `fauna_spawner.gd` + nodo en main_island; grupos [M65] visibles en runtime).

## Jabalí — etapas de vida (feedback usuario 2026-09-03)

Tercer animal del pipeline Blender→Godot→movimiento (ver GUIA-GODOT/11-blender-godot.md §11, guía 09 §9).
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
