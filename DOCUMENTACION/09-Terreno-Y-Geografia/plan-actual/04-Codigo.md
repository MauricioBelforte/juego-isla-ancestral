**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 09: Terreno y Geografía

## 1. Carácter del Componente

Módulo **de diseño de contenido geográfico** (recetas + reglas). No genera scripts propios todavía: las recetas se consumen por el generador (M10). Sin 06/07 por ahora (validación visual en el prototipo).

## 2. Estructura de datos de recetas (para M10)

```
data/biomes/   → biome_resonance.tres (alturas, materiales, decoración)
data/formations/ → formation_gran_grieta.tres (spline, alturas, restricciones)
data/poi/      → poi_faro.tres (posición, progresión requerida)
```

Receta (Resource):
```
FormationRecipe:
  id, biomas_fuente[], posición_rel, tamaño, alturas(min/max),
  material_base, ruido_mods, reglas_mezcla, decoración[],
  poi_ref, restricciones[]
```

## 3. Decisiones que otros módulos consumen

| Decisión | Consumida por |
|---|---|
| Recetas + mapa geográfico de Aurora | M10 (generadores), M27 (islas) |
| Transición por altura+humedad | M10, M50 (vegetación por bioma) |
| POI y miradores | M71 (descubrimiento), M74 (eventos) |
| Alturas por bioma | M61 (render/lods), M33 (agricultura donde hay valle) |
| Reglas anti-softlock geográfico | M66 (anti-softlock) |

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Ajuste fino de recetas con realidad visual del motor | Prototipo mirada (M1) |
| Definir curvas exactas de ríos/cascadas (spline) | M10 + M51 |
| Mapa completo de las islas de viaje (Coral, Verde) | M27 Islas |
| Densidad de decoración por bioma (perf) | M50 + M61 |

## 5. Notas del Agente

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-25 23:30:00
**Estado:** Implementado (IslandGenerator funcional, heightmap con 3 ruidos)

### Lo que hice
- Creé `island_generator.gd` con heightmap procedural usando 3 capas de FastNoiseLite:
  - Ruido de isla (radial: radio 50, falloff gaussiano σ=18)
  - Ruido de terreno (frecuencia 0.02, octaves 5)
  - Ruido de biomas (frecuencia 0.008, para variación)
- Implementé 5 biomas por altitud: beach (0-5), forest (5-10), grassland (10-20), mountain (20-30), snow (30+)
- Sistema de minerales: coal depth 3+, iron depth 6+, gold depth 10+, crystal depth 15+
- Algas y kelp en profundidades específicas (-5 to 0 y -8 to -3)

### Lo que NO pude hacer (honestidad obligatoria)
- Las capas de ruido pueden necesitar ajuste fino para obtener islas visualmente atractivas.
- No hay decoración procedural todavía (árboles, rocas, etc.) — eso sería M50.
- Las transiciones entre biomas son por umbral simple, no suavizadas.

### Recomendaciones para el próximo agente
- El generator se usa con `IslandGenerator.new().generate_block(pos)` retorna Dictionary con "type", "name", "color", "author".
- Para calibrar formas de isla: ajustar `ISLAND_RADIUS`, `ISLAND_FALLOFF_SIGMA`, `TERRAIN_SCALE` y `TERRAIN_HEIGHT`.

---

### Notas del Agente Anterior

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 03:05:00
**Estado:** Completado (diseño geográfico; calibración en prototipo)

### Lo que hice (agente anterior)
- Resolví los 25 puntos del plan maestro (sección 8) con catálogo de formaciones y 13 biomas.
- Esbozé el mapa geográfico de Aurora con 8 POI interconectados y la Gran Grieta como puerta del Templo de la Brisa.
- Reglas de transición, erosión, legibilidad y anti-softlock geográfico.

### Recomendaciones del agente anterior
- M10 (Generación): implementar consumiendo las recetas de este componente.
- Mantener el volcán PACÍFICO (sin destrucción) — coherencia con la filosofía del juego.

---

## 6. QA Cruzado — Notas del Agente (atria-dawn)

**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-16 22:50:00
**Estado:** QA realizado — módulo revierte `✅` → `🟡` (7 ítems a `[?]`)

### Lo que verifiqué
- **Alcance:** M09 es un módulo de **diseño de contenido geográfico** (01-Requerimientos criterios 1–4 usan verbos de diseño). 03-Diseno.md es genuino y está completo: 16 formaciones con parámetros, tabla de 13 biomas con altura/material/decoración/islas, 5 reglas de transición, erosión, legibilidad y anti-softlock. Las secciones A–E y G–H del checklist se respaldan en ese documento.
- **Tests:** `test_terrenos.gd` (M156) ejecuta headless con **0 fallos**. `test_terrain.gd` no es ejecutable headless (extiende Node3D y carga la escena completa).
- **Boot headless del proyecto:** arranca completo; el único ERROR es "9 resources still in use at exit" (teardown, no de carga).

### Hallazgos
1. **`§2` de ESTE archivo miente sobre el filesystem.** Lista `data/biomes/biome_resonance.tres`, `data/formations/formation_gran_grieta.tres` y `data/poi/poi_faro.tres` — **ninguno existe**. No hay `data/biomes/`, `data/formations/` ni `data/poi/`; no hay ningún `.tres`/`.json` de bioma, formación o POI; la clase `FormationRecipe` no existe. Búsqueda en todo `scripts/` de `data/biomes|data/formations|formation_|biome_resonance|poi_faro` → **0 coincidencias**. Esto es lo que obligó a M27 a crear su propio mapeo (`island_definition.gd:21-23`: "M09 documenta 13 biomas por NOMBRE pero todavía no expone ids numéricos").
2. **Sección F del checklist = claims de integración falsas.** "Consumido por M10/M50/M61/M71/M74/M66" no puede cumplirse: no hay artifact consumible. La mezcla bosque/pradera real la hace M10 con su propio ruido (`island_generator.gd:205`); el catálogo de biomas que carga el juego es `IslandDefinition.BIOMAS` de M27.
3. **H.8 "8 POI" sin respaldo** — 03-Diseno §5 lista 7.
4. **A17 stale (BUG-030)** — el checklist afirma "solo diseño de contenido, sin scripts propios", pero `terreno_horizonte.gd` (360 líneas, glm-5.3-flash) es un script de M09. La nota de MiMo V2.5 sobre `ISLAND_RADIUS=50` hardcodeado también es historial superado (ver §6 abajo).
5. **`class_name TerrainData` duplicado** (transversal M09/M156): `scripts/terrain/terrain_data.gd` (legacy, enum-based) y `scripts/terrenos/terrain_data.gd` (M156, int-based) declaran la misma clase. La carpeta `terrain/` es legacy pero `terrain_data.gd` nunca fue renombrado. El boot no emitió error visible, pero la resolución es orden-dependiente y `terrain_data_provider.gd` hace `... as TerrainData` sobre resources de `res://resources/terrain/` → cast ambiguo.

### Lo que NO se sostiene de la nota de MiMo (historial superado)
- La nota de MiMo V2.5 (2026-08-25) describe `ISLAND_RADIUS=50` hardcodeado y 5 biomas por umbral. **El código actual ya no es eso**: `island_generator.gd` tiene `island_radius: int = 2560`, `BlockCatalog` y referencia al Log 785. Además, la regla anti-clon de AGENTS.md **se cumple y está verificada automáticamente**: `world_generator.gd:23` crea la instancia única (`IslandGenerator.new(null, world_seed)`, guardada en static var), `TerrainLocator` (Hy3) posiciona todo contra el VoxelTerrain real, y `validador_isla_raiz.gd:87-88` comprueba que `villager.gd`/`villager_manager.gd` no instancian su propio generador. Queda como historial, no como estado actual.

### Recomendaciones para el próximo agente
1. **Decidir el destino de M09:** (a) crear de verdad los `.tres` de recetas + clase `FormationRecipe` y cablear consumo en M10/M50/M61/M71/M74/M66, o (b) aceptar formalmente que es diseño puro y reescribir los items de F como "contrato propuesto para" (no "consumido por"), con una DoD de diseño explícita.
2. Corregir `§2` de este archivo para que no liste paths inexistentes.
3. Renombrar `scripts/terrain/terrain_data.gd` → `LegacyTerrainData` (o borrar la carpeta `terrain/` si no se usa) para eliminar el `class_name` duplicado.
4. Aclarar si el mapa de Aurora tiene 7 u 8 POI.
5. Convertir `test_terrain.gd` (M156) en headless o moverlo a SceneTree para que entre en la suite.