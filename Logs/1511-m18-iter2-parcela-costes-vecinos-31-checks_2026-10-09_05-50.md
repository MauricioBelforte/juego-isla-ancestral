# Log 1511: M18 iter 2 — parcela + costes + vecinos + guardado (31 checks, 6/126)

**Fecha:** 2026-10-09
**Hora:** 05:50
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Iteración 2 de M18: 4 bloques implementados. Test ampliado de 22 → 31 checks (0 fallos).

## Bloques implementados

### Block 1 — Validación de parcela
- `parcela_despejada(pos)` en `house_manager.gd`: verifica distancia mínima 20m entre casas + `TerrainLocator.get_height() > 0` (sobre tierra)
- `MIN_DISTANCIA_CASAS = 20.0`
- L21 flippeada: [?] → [x]
- L49 flippeada: [ ] → [x]

### Block 2 — Costes M14
- `COSTES_ETAPA` (5 etapas, materiales: wood, stone, grass, copper_ore, iron_ore, crystal)
- `cobrar_etapa(casa_id, inventario)`: verifica + descuenta; si falta → `{"ok": false, "razon": "..."}`
- L98 flippeada: [ ] → [x]
- Nota: `inventario.tiene_item()` / `remover_item()` — si M13/M14 no expone estas APIs, el método retorna `{"ok": false, "razon": "inventario no tiene remover_item"}`

### Block 3 — Vecinos M19
- `asignar_vecino(casa_id, vecino_id)`: 1 vecino por casa (rechaza segundo)
- `obtener_vecino(casa_id)` → String
- `cantidad_vecinos()` → int

### Block 4 — Guardado M60
- `obtener_datos_guardado()` / `restaurar_desde_guardado()` ya existen desde iter 1
- Conectar al provider "buildings" de M60: **pendiente** (requiere acceso al DataStore)

## Artefactos modificados
| Archivo | Cambio |
|---|---|
| `house_manager.gd` | + `parcela_despejada()`, `COSTES_ETAPA`, `cobrar_etapa()`, `asignar_vecino()`, `obtener_vecino()`, `cantidad_vecinos()`, `MIN_DISTANCIA_CASAS` |
| `test_m18_casas.gd` | + 9 checks nuevos (parcela, vecinos, costes) → 31/0 |

## --check-only
- `house_manager.gd`: 0 errores ✓
- `furniture_data.gd`: 0 errores ✓
- `test_m18_casas.gd`: 0 errores ✓

## Conteo M18
- Antes: 3 [x] / 1 [?] / 122 [ ]
- Después: **6 [x] / 0 [?] / 120 [ ]** = 126

## Pendiente iter 3
- Guardado M60 (conectar al DataStore provider "buildings")
- Cimientos visuales (M17)
- Interior + habitaciones
- Edge cases (J)
