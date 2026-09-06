# Log 711: M49/M50 Visión — día/noche + vegetación

**Fecha:** 2026-09-05
**Hora:** 23:22
**Modelo:** agnes-2.5-flash
**Plataforma:** Kilo Code

## Resumen
Trabajo visual en M49 (iluminación) y M50 (vegetación) usando V4 (godot-mcp) + V2 (capturas).

## Cambios Realizados

### M49 Iluminación
- **DirLightLuna** agregada a main_island.tscn (referenciada por day_night_cycle.gd pero inexistente)
- **WorldEnvironment fog depth** mejorado (start=80, end=256)
- **validate_lighting_m49.gd** creado para verificación headless
- Capuras before/after comparativas

### M50 Vegetación
- **VegetationSpawner** agregado a main_island.tscn (id=18_vegspawn) — antes NO estaba en escena
- **15 GLBs de vegetación** verificados en assets/3d/media/
- Sistema genera ~120 plantas en 5 biomas (playa, pradera, bosque, montana, riberas)
- Captura mostrando vegetación spawnueada: FPS 60, sin errores

### M54 Mapa (continúa)
- **MinimapWidget** conectado a MapManager (fix type error línea 107)
- Widget visible en esquina inferior derecha del HUD

## Estado actual
| Módulo | Antes | Después | Cambio |
|--------|-------|---------|--------|
| M49 | 11/117 (9%) | ~15/117 (13%) | +4 items: dirlight, fog, validate, curva_day |
| M50 | 20/131 (15%) | ~24/131 (18%) | +4 items: spawner node, GLBs, escala, poblar |
| M54 | 82/174 (47%) | 82/174 (47%) | Sin cambio (minimapa ya funcionaba) |

## Capturas
- cap_49_daylight-current + cap_49_daylight-improved (before/after luna+fog)
- cap_50_vegetacion-spawned (vegetación visible en terreno)
- cap_54_minimap-running (minimapa operativo)

## Próximos pasos
- M49: sky material por bioma, presets 5 franjas, PCF >= 4 samples
- M50: LOD, MultiMesh pool, integración con M156 terrenos
- M36 Fauna: integración GLB nutria/elefante (Blender V5)
