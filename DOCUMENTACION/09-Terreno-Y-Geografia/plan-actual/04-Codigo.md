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