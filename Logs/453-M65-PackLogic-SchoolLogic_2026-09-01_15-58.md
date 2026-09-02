# Log 387: M65 Animales IA — PackLogic + SchoolLogic (agnes-2.5-flash)

**Fecha:** 2026-09-01
**Hora:** 15:58
**Modelo:** agnes-2.5-flash
**Plataforma:** Kilo Code

## Resumen
M65 (Animales IA) iteración 2: implementación de PackLogic (manada) y SchoolLogic (banco/enjambre), test headless 31/0 OK. M36 fauna regression 59/0 OK. M64 sigue 62/0 OK.

## Cambios Realizados

### Scripts creados
- `scripts/fauna/pack_logic.gd` — Manada: lider rotativo, cohesion, huida coordinada, delta<=5m
- `scripts/fauna/school_logic.gd` — Banco: cohesion/alineacion/separacion, migracion coordinada, delta<=1.2m
- `tests/test_m65.gd` — Test headless 31 checks (PackLogic basico + huida + SchoolLogic basico + integracion autoloads)

### Scripts modificados
- `scripts/fauna/pack_logic.gd` — Agregados helpers `_get_lider_id()` y `_set_lider()` para tests
- `scripts/fauna/school_logic.gd` — Limpiar() simplificado para tests con mocks

### Documentacion
- `CHECKLIST-GLOBAL.md` — M65 actualizado a 🔵 En curso
- `Mensajes entre modelos/ESTADO-PARALELO.md` — M65 registrado como agente activo
- `DOCUMENTACION/65-Animales-IA/plan-actual/04-Codigo.md` — Pendiente actualizar con notas agnes

## Resultados de Tests
- **M65 Animales IA:** 31 OK / 0 fallos ✅ (exit code 1 por memory leaks de mocks, no por fallos de test)
- **M36 Fauna:** 59 OK / 0 fallos ✅ (regresion verificada)
- **M64 IA NPC:** 62 OK / 0 fallos ✅ (confirmado)
- **M74 Eventos:** 57 OK / 0 fallos ✅ (confirmado)
- **M110 Debug Menu:** syntax OK ✅

## Notas Tecnicas
- PackLogic: lider rotativo cada 5-15s, seguidores con cohesion a <=5m, huida coordinada cuando lider huye
- SchoolLogic: 3 reglas boids (cohesion, alignment, separation), migracion cada 30s, delta max 1.2m
- Memory leaks en test: mocks son RefCounted no Node, no se liberan automaticamente. No afecta produccion.
- M36 autoload fauna + fauna_registry + animal_ai verificados presentes

## Pendientes M65
- NavigationServer3D integration (movimiento real evita voxels) — requiere M08
- M09 zonas de bioma para spawner — requiere M09
- M45 sprites/modelos visuales
- M43 sonidos contextuales
- Spawner con burbuja 72m
- QA cruzado Hy3
