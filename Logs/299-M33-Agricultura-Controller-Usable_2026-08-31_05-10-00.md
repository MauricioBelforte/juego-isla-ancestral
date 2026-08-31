# Log 299: M33 Agricultura (iter. 2) — FarmToolController usables + QA demo

**Fecha:** 2026-08-31
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Iteración 2 del M33 sobre el núcleo (Log 296): la agricultura se hace **usable en el mundo** —
FarmToolController (arar/regar/cosechar con la acción interactuar sobre el suelo mirado),
puede_plantar_en() en el servicio, y botones de QA en el DebugMenu (plantar tomate + avanzar día).
Test headless de la ruta completa 0 fallos.

## Cambios Realizados

### Código (Godot) — solo archivos de M33/míos
- `scripts/farm/farm_tool_controller.gd` — **NUEVO** class_name FarmToolController (Node3D):
  - Raycast propio desde la cámara hacia el suelo (independiente del ToolController de M13).
  - Acción `interactuar`: sin cultivo → till_tile (arar); cultivo LISTO → harvest;
    cultivo activo → water. Contextual y cozy (sin castigos).
  - `plantar_demo()` para QA (da 5 semillas y planta el cultivo en el punto dado).
- `scripts/farm/farm_service.gd` — Modificado: `puede_plantar_en(voxel)` (true si no hay tile).
- `scripts/farm/test_farm.gd` — **Extendido**: `_test_controller_ruta()` — simula headless la
  ruta del controller (till→plant→water→crecer→harvest) vía API pública. 0 fallos.
- `scripts/main_island.gd` — Modificado: monta FarmToolController en el mundo.
- `scripts/debug/debug_menu.gd` — Modificado: botones "Plantar tomate demo" (da semillas +
  planta) y "Ayudar cosecha (1 día)" (apply_rain simulado + advance_day + stats en log).

### Verificación
- `test_farm.gd` headless: 0 fallos (incluye ruta controller completa).
- Regresión: M34 (0), M39 (0), M53 (0).
- Arranque del juego: `[M33] FarmToolController montado`, capturas con el DebugMenu mostrando
  los nuevos botones (verificación visual parcial — la simulación de clicks cerró el proceso,
  la lógica quedó cubierta por el test headless de la ruta).

## Archivos Modificados/Creados
| Archivo | Acción |
|---------|--------|
| `scripts/farm/farm_tool_controller.gd` | Creado |
| `scripts/farm/farm_service.gd` | Modificado (puede_plantar_en) |
| `scripts/farm/test_farm.gd` | Extendido (ruta controller) |
| `scripts/main_island.gd` | Modificado (monta controller) |
| `scripts/debug/debug_menu.gd` | Modificado (2 botones QA) |
| `Logs/ULTIMO_NUMERO.txt` | Modificado (298 → 299) |
| `Logs/299-M33-Agricultura-Controller-Usable_2026-08-31_05-10-00.md` | Creado (este log) |

## Pendientes honestos (iter. 3+)
- Validación de bloque voxel real (TIERRA vs TIERRA_ARADA vía M08) en till/plant.
- HUD tooltip agrícola (get_growth_hint ya expuesto; falta capa M53 dedicada — no se hizo
  para no duplicar widgets, regla §9.47) y FarmHUD oficial del diseño.
- MultiMesh de visuales (M50/M61): hoy es 1 Node3D por tile (≤400, dentro de presupuesto).
- Lluvia real M32 (apply_rain ya expuesto y usado en QA; M32 de GLM lo conectará).
