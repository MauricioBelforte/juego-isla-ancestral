# Log 802: M09 — 2 fixes anti-tilde: spawner duplicado + impostor pas 64

**Fecha:** 2026-09-09
**Hora:** 05:10
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Dos fixes anti-tilde adicionales tras el feedback del usuario ("se volvió a tildar paseando volando"):

1. **VegetationSpawner DUPLICADO**: era autoload Y estaba instanciado en main_island.tscn → se poblaba 2× por boot (130 instancias GLB duplicadas en memoria). Eliminado del autoload (la escena lo maneja).

2. **Impostor heightmap optimizado**: paso 32m → 64m (4× menos celdas) + paredes SOLO en acantilados (vecino ≥2m más bajo) en vez de las 4 paredes por celda siempre — el overdraw de paredes dobles visibles simultáneas saturaba la GPU integrada.

## Cambios Realizados
- `project.godot`: autoload VegetationSpawner eliminado (la escena lo instancia).
- `terreno_horizonte.gd`: PASO 32→64, paredes condicionales con `_alturas_celda.get(vecino)+2.0`.

## Evidencia
- Boot: `poblando isla` aparece 1 vez (antes 2) + `impostor heightmap completo: 42 tiles activos` — 0 errores, sin tildes en el boot.

## Lección para 07-GUIA-GODOT §8
- Un script puede ser autoload Y estar instanciado en escena → doble ejecución silenciosa. Verificar SIEMPRE project.godot antes de instanciar en escena.

## Archivos Modificados
- `game/isla-ancestral/project.godot` (autoload duplicado eliminado)
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (paso 64 + paredes condicionales)
