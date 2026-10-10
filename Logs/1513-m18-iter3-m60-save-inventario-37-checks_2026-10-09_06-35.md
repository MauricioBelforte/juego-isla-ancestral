# Log 1513: M18 iter 3 — M60 save + InventarioService (37 checks, 6/126)

**Fecha:** 2026-10-09
**Hora:** 06:35
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Iteración 3 de M18: cerradas las deudas de Priority 1. `obtener_estructuras()` + `restaurar_estructuras()` implementados (contrato duck-typing de BuildingsSaveProvider). `cobrar_etapa()` ahora usa `InventarioService` real (`count_item` + `remove_item`). Test ampliado de 31 → 37 checks (0 fallos).

## Cambios en house_manager.gd
| Método | Cambio |
|---|---|
| `obtener_estructuras()` | Nuevo: devuelve Array de dicts {id, tipo, pos, rot_y, planta, variante} |
| `restaurar_estructuras(lista)` | Nuevo: reconstruye `_casas` + `_vecinos` desde lista |
| `cobrar_etapa(casa_id)` | Refactor: usa `/root/Inventario` (count_item + remove_item), transaccional |

## --check-only
- `house_manager.gd`: 0 errores ✓
- `furniture_data.gd`: 0 errores ✓
- `test_m18_casas.gd`: 0 errores ✓

## Test
`test_m18_casas.gd`: **37 checks, 0 fallos**, EXIT 0

## M60 save (Block 4 CERRADO)
- `obtener_estructuras()` → `EstructurasCodec.a_seccion()` → `SaveSchema`
- `restaurar_estructuras(lista)` → reconstruye `_casas`
- BuildingsSaveProvider lo encuentra por duck-typing (autoload)
- **HouseManager necesita ser autoload** para que el provider lo encuentre → agregar a `project.godot [autoload]`

## Inventario (Block 2 CERRADO)
- `cobrar_etapa` ahora usa `InventarioService.count_item(id)` + `remove_item(id, cant)`
- Transaccional: verifica TODOS los materiales antes de descontar
- Si InventarioService no disponible → `{"ok": false, "razon": "InventarioService no disponible"}`

## Conteo M18
6 [x] / 0 [?] / 120 [ ] = 126 (sin nuevos flips — M60 + Inventario extienden items ya flippeados)

## Pendiente iter 4
- Hacer HouseManager autoload en project.godot
- Prioridad 2: colocación de muebles + catálogo
- Prioridad 3: UI panel
