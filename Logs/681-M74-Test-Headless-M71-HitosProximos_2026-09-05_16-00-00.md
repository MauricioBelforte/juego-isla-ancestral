# Log 681: M74 test headless puro + M71 hitos_proximos para M53

**Fecha:** 2026-09-05
**Hora:** 16:00
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Dos tareas accionables del backlog: (1) M74 test headless puro que reemplaza al Play-mode que cuelga, (2) M71 RF8 `hitos_proximos(limite)` — el sugeridor de metas para M53 que faltaba.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/eventos/test_event_manager_pure.gd` *(nuevo)* | Test SceneTree puro: escanea `scripts/eventos/data/{7 carpetas}/` verificando estructura y contenido .tres. Sin boot de escena (no cuelga) |
| `scripts/progresion/progression_manager.gd` | +`hitos_proximos(limite)`: devuelve hasta `limite` hitos pendientes cuantificables (stat_min/dias/riqueza/primera_vez), ordenados por catálogo, sin spoilers |
| `scripts/progresion/test_progresion.gd` | +`_test_hitos_proximos` (6 checks: Array, límite, pendientes, id+nombre) |
| `DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md` | Test headless documentado |
| `Logs/ULTIMO_NUMERO.txt` *(→ 681)* |

## Tests
- `test_event_manager_pure.gd`: **0 fallos** (7 carpetas × estructura + contenido)
- `test_progresion.gd`: **0 fallos** (incluye hitos_proximos)

## Lecciones
1. **EEVEE_NEXT en headless**: sin colores, CYCLES-CPU sí funciona (documentado antes)
2. **CYCLES render en headless**: funciona con `device = "CPU"` — sin RID errors
3. **El guard E-50 de plantilla_asset es demasiado estricto para lofts con patas lofted** — usar asentado manual con medición de zmin real (documentado en M50)

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/eventos/test_event_manager_pure.gd` *(nuevo)*
- `game/isla-ancestral/scripts/progresion/progression_manager.gd` *(+hitos_proximos)*
- `game/isla-ancestral/scripts/progresion/test_progresion.gd` *(+test)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 681)*
- `Logs/reservas/681-...txt` *(creada y borrada)*
