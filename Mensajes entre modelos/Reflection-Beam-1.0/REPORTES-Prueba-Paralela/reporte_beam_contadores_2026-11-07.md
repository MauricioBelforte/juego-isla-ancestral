# Reporte de Verificación de Consistencia de Contadores

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-07

## Alcance

Análisis de archivos `.gd` en `game/isla-ancestral/scripts/core/`, `game/isla-ancestral/scripts/progresion/` y `game/isla-ancestral/scripts/economia/` que usan contadores, totales o verificaciones de consistencia (`CHECKS_MINIMOS`, conteos de suites, totales de checklists).

## 1. Contadores que se incrementan sin validación

- `game/isla-ancestral/scripts/core/registro.gd:26,31` — `avisos += 1` / `errores += 1` sin tope, sin validación de entrada y sin trazabilidad de origen.
- `game/isla-ancestral/scripts/progresion/player_profile.gd:31-36` — `incrementar()` suma `cantidad` (int) sin validar signo ni magnitud; `_contribucion` solo se actualiza para `stat_id == "monedas_ganadas"`, pero `set_stat()` (línea 39-42) sobrescribe `_totales` sin sincronizar `_dia` ni `_contribucion`.
- `game/isla-ancestral/scripts/economia/economy_manager.gd:101-108` — `depositar_monedas(total=0)` pasa la validación (`total < 0` es false), registra transacción y ejecuta `ajustar_reputacion(1)` (línea 108), inflando reputación sin ingreso real.
- `game/isla-ancestral/scripts/economia/price_manager.gd:252` — `_ventas_hoy[item_id] = ventas_hoy(item_id) + cantidad` sin validar `cantidad >= 0`; un valor negativo corrompe el contador diario y el flag `precio_rebajado_hoy`.
- `game/isla-ancestral/scripts/core/service_registry.gd:25` — `_duplicados_rechazados += 1` sin límite ni validación de que el contrato sea válido.

## 2. Totales que no coinciden con el conteo real

- `game/isla-ancestral/scripts/coleccionables/coleccionables_manager.gd:122-130` — `porcentaje_total()` suma `_categoria_collected` (caché) en lugar de contar `_collected` por categoría; si la caché se desincroniza, el total reportado no refleja la realidad.
- `game/isla-ancestral/scripts/coleccionables/coleccionables_manager.gd:156-167` — `restore_save_data()` sobrescribe `_categoria_collected` desde disco sin recalcular desde `_collected`; un save stale o manipulado produce totales inconsistentes.
- `game/isla-ancestral/scripts/coleccionables/coleccionables_manager.gd:73` — `_categoria_collected[cat]` se incrementa en `registrar()` incluso si `cat` no existe en `_categoria_total`, por lo que el collected puede superar el total esperado.
- `game/isla-ancestral/scripts/economia/price_manager.gd:320-335` — `deserializar()` no resetea `_cache_tabla_valida`, por lo que la tabla del día puede quedar stale tras cargar partida.

## 3. Verificación cruzada de consistencia

- `game/isla-ancestral/scripts/core/service_registry.gd:63-68` — `validate_required()` solo verifica un subset `required`, no compara contra `Contratos.TODOS` (`contratos.gd:74-84`); no hay validación de que todos los contratos registrados sean conocidos.
- `game/isla-ancestral/scripts/core/test_infraestructura.gd:14,32` (y patrón similar en `test_m40_contratos.gd`, `test_m38_economia_smoke.gd`, `test_progresion.gd`) — se compara `_checks < CHECKS_MINIMOS` (piso), pero no se verifica que `_checks` sea igual al número esperado de `_check()`; un test que ejecuta de más o de menos puede pasar si supera el piso.
- `game/isla-ancestral/scripts/core/softlock_guard.gd:144-156` — ventana de fallos por categoría sin validar que `now >= fallos[0]` ni que los timestamps sean monotónicos; un timestamp retroactivo puede corromper el conteo.
- `game/isla-ancestral/scripts/core/probe_runtime_bus_m14.gd:93-98` — `total` cuenta keys de `_cuenta` (señales conectadas) y `emitidas` las que tienen `> 0`; no hay verificación de que `emitidas + (total - emitidas) == total` (trivial pero no asertado), ni de que `_cuenta` no tenga duplicados.

## 4. Problemas de off-by-one

- `game/isla-ancestral/scripts/economia/price_manager.gd:263` — `precio_rebajado_hoy()` usa `ventas_hoy(item_id) > limite_ventas_dia(item_id)`: al límite exacto no se rebaja; el cruce ocurre en `limite + 1` (consistente con `registrar_venta`, pero el umbral "superado" podría interpretarse como `>=`).
- `game/isla-ancestral/scripts/economia/price_manager.gd:543` — `_podar_ventana()` elimina entradas con `(dia - dia_entrada) > VENTANA_OFERTA_DIAS`, conservando entradas de exactamente 3 días; si la ventana es "3 días laborables", el límite debería ser `>= VENTANA_OFERTA_DIAS` (o `> VENTANA_OFERTA_DIAS - 1`).
- `game/isla-ancestral/scripts/core/softlock_guard.gd:153` — dispara toast en `fallos.size() >= 3` y resetea `_fallos_instancia[key] = []`; si llega un 4.º fallo dentro de la misma ventana, se pierde porque el historial fue vaciado.
- `game/isla-ancestral/scripts/core/probe_runtime_bus_m14.gd:89` — bucle `while _frames < MAX_FRAMES` con `_frames += 1` produce exactamente 60 frames (correcto, sin off-by-one); se documenta como referencia de patrón correcto.

## 5. Dos mejoras concretas de validación

1. **Reconciliación centralizada en managers**:
   - Añadir `verificar_consistencia()` en `economy_manager.gd` que compare `saldo` contra la suma de deltas del historial (retiros/depositos) y reporte discrepancia vía `Registro`.
   - En `coleccionables_manager.gd`, recalcular `_categoria_collected` desde `_collected` en `restore_save_data()` y en `_ready()`, y asertar `collected_count(cat) <= total_count(cat)`; si no se cumple, loggear y clampear.
   - En `price_manager.gd`, resetear `_cache_tabla_valida = false` en `deserializar()` y validar `cantidad >= 0` en `registrar_venta()`.

2. **Tests con conteo exacto y validación de entrada**:
   - En los tests con `CHECKS_MINIMOS`, añadir constante `CHECKS_ESPERADOS` y assert `_checks == CHECKS_ESPERADOS` (no solo piso), para detectar tests que se saltan o duplican.
   - En `player_profile.incrementar()` y `price_manager.registrar_venta()`, validar `cantidad >= 0` (y en `incrementar`, actualizar `_dia` y `_contribucion` de forma atómica o documentar que `set_stat` no los sincroniza).
   - En `service_registry`, añadir `validar_todos()` que compare `_registry.keys()` contra `Contratos.TODOS` y reporte contratos faltantes/sobrantes.
   - En `softlock_guard`, cambiar el reset a ventana deslizante real (no vaciar el array al disparar) y validar `now >= fallos[0]` antes de append.

## Conclusión

Se identificaron contadores sin validación de entrada, cachés de totales que pueden desincronizarse con el conteo real, ausencia de verificación cruzada entre registros y contratos, y varios límites off-by-one en umbrales de rebaja y ventanas de oferta. Las mejoras propuestas se centran en reconciliación centralizada y tests con conteo exacto.
