# Log 748: M95 Monetización — núcleo data-driven (ediciones, DLC, P2W audit, impuestos)

**Fecha:** 2026-09-06
**Hora:** 04:15
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
MonetizacionManager autoload con catálogo data-driven (3 ediciones + 2 DLC), auditoría P2W (M94/M152), impuestos por plataforma (M96), persistencia de compras. 11 checks, 0 fallos.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/monetizacion/monetizacion_manager.gd` *(nuevo)* | Autoload: comprar_edicion(), comprar_dlc(), esta_comprado(), auditar_p2w(), calcular_impuesto(), get_ediciones/dlc/compras(), guardar/cargar persistencia |
| `data/monetizacion/monetizacion.json` *(nuevo)* | 3 ediciones ($24.99-$49.99), 2 DLC ($4.99-$14.99), impuestos por plataforma (Steam 30%, EGS 12%, GOG 30%, itch 10%) |
| `scripts/monetizacion/test_monetizacion.gd` *(nuevo)* | 11 checks |
| `project.godot` | Autoload MonetizacionManager registrado |

## Tests
- `test_monetizacion.gd`: **0 fallos** (11 checks — compra, re-compra, inexistente, DLC, P2W audit, impuestos, persistencia)

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/monetizacion/monetizacion_manager.gd` *(nuevo)*
- `game/isla-ancestral/data/monetizacion/monetizacion.json` *(nuevo)*
- `game/isla-ancestral/scripts/monetizacion/test_monetizacion.gd` *(nuevo)*
- `game/isla-ancestral/project.godot` *(autoload)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 721)*
- `Logs/reservas/721-...txt` *(creada y borrada)*
