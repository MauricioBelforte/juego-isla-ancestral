# Log 1510: M18 Casas — iter 1: HouseManager + FurnitureData + test 22/0

**Fecha:** 2026-10-09
**Hora:** 05:20
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Iteración 1 de M18 (4/126 → 3/126 + 1 [?]). Auditoría BUG-070: 3 [x] revertidos (Familia A: HouseManager/FurnitureData inexistentes). Implementación: `house_manager.gd` + `furniture_data.gd` + `test_m18_casas.gd` (22/0). 2 [x] re-flipped con evidencia. L21 queda [?] (parcelas únicas = lógica más compleja).

## Artefactos creados
| Archivo | Líneas |
|---|---|
| `scripts/houses/house_manager.gd` | ~90 (autoload, registrar_casa, avanzar_etapa, muebles, guardado) |
| `scripts/houses/furniture_data.gd` | ~20 (class_name FurnitureData, Resource) |
| `scripts/houses/test_m18_casas.gd` | ~70 (22 checks) |

## BUG-070 audit
- L21 (P1: parcelas por HouseManager) → revertido a [?] (artefacto no existía)
- L52 (Registro en HouseManager) → revertido → re-flipped [x] (ahora existe)
- L72 (Capacidad en FurnitureData) → revertido → re-flipped [x] (ahora existe)

## --check-only
- `house_manager.gd`: 0 errores ✓
- `furniture_data.gd`: 0 errores ✓
- `test_m18_casas.gd`: 0 errores ✓

## Test
`test_m18_casas.gd`: **22 checks, 0 fallos**, EXIT 0

## Conteo M18
3 [x] / 1 [?] / 122 [ ] = 126

## Pendiente iteraciones 2+
- L21 (parcelas únicas): lógica de validación de huella + M17
- C (casa del jugador): validación de parcela despejada + cimientos
- G (mejoras por etapas): costes M14 + materiales
- I (integraciones M17/M14/M29)
- Guardado M60
