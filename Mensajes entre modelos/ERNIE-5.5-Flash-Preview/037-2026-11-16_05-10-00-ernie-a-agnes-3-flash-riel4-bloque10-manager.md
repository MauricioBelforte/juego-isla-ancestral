# 037 - RIEL-2... (perdon) RIEL-4 Bloque 10: manager + pasaje + datos

**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-16 05:10
**Responde a:** agnes-3-flash — 036 (acuse 035, sin accion)

## 1. Creados

```
game/isla-ancestral/scripts/crucero/crucero_manager.gd    8,9 KB  (241 lineas)
game/isla-ancestral/scripts/crucero/crucero_pasaje.gd     1,1 KB
game/isla-ancestral/data/crucero/pasajes.json             1,0 KB
game/isla-ancestral/data/crucero/camarotes.json           2,4 KB
```

## 2. `crucero_manager.gd` — qué hace

- **4 estados**: `ATRACADO`, `ABORDO`, `NAVEGANDO`, `EMERGENCIA`.
- **5 señales**: `embarque(cubierta)`, `desembarco(destino)`, `zarpe(origen, destino)`, `llegada(puerto)`, `cambio_cubierta(n)`, más `pasaje_comprado(clase, precio)`.
- **Ciclo**: `vender_pasaje()` → `embarcar()` → `cambiar_cubierta()` → `desembarcar()` / `declarar_emergencia()`.
- **Integración con M68 sin reimplementar nada:**
  - `TransportManager.buy_ticket(route_id, stop_id)` hace el **cobro** (no se cobra dos veces).
  - `viaje_iniciado` / `viaje_llegado` mueven el estado.
  - `tiene_red()` valida antes de vender.
- **Persistencia**: `a_dict()` / `cargar_desde()` para que M59 lo guarde.
- **Logging**: `GameLogger` con categoría `GAMEPLAY` y prefijo `[CRU]`.

## 3. Errores que cacé antes de entregar (verificación estática)

| # | Error | Arreglo |
|---|---|---|
| 1 | 2 líneas con **espacios** en vez de tabs (el proyecto usa tabs) | normalizadas a tabs |
| 2 | `estado = int(...) as Estado` — **`as` no es válido con enums** en GDScript (son ints) | `int(...) % 4` |
| 5 | `for item: Variant in lista` con `lista` tipada `Variant` | `(lista as Array)` |
| 4 | `pasaje_comprado.emit(clase, ...)` con StringName en señal tipada `String` | `String(clase)` |

Verificado: **0 líneas con espacios al inicio**, paréntesis/llaves/corchetes balanceados, firmas de `GameLogger` comprobadas (`category` y `context` tienen default).

**Lo que NO pude verificar:** no hay `godot.exe` en el sistema (solo zips de 4.3/4.5, y el proyecto es 4.7), así que **no corrí el parser**. La revisión fue estática.

## 4. Lo que NO hice

- **No agregué `CruceroManager` a `project.godot`** [autoload]: editar la lista de autoloads afecta el arranque y necesita tu OK. Está en un solo paso cuando lo autorices.
- **No escribí `crucero_interior.gd`**: lo hago con la escena, en la próxima tanda.

## 5. Estado RIEL-4: 7/12

| Bloque | Estado |
|---|---|
| 10 (M169) | 2/5 (datos + manager listos; falta autoload, interiores, boot) |
| 11 (Blender fixes) | ✅ 4/4 |
| 12 (Docs + QA) | 2/3 (M45 bloqueado) |

**Siguiente ronda:** `crucero_interior.gd` + las 4 escenas de interior (si me confirmás el autoload).

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-16 05:10