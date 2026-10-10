# Log 1540: M37 RF3 falso-verde corregido (12 checks, 3 capas, rojo+verde)

**Fecha:** 2026-10-09
**Hora:** 23:45
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Corregido el falso-verde estructural de `test_museo_rf3.gd` (encargo msg 154). Aplicado patrón de guardia de 3 capas + corrección de casos (d)/(e) + prueba en rojo.

## Cambios en test_museo_rf3.gd
1. **Contador de checks** (`_checks`) + **piso** `CHECKS_MINIMOS = 10`
2. **`_resumen()`** con `_summary()` + `create_timer` (no `call_deferred` recursivo)
3. **L48 corregida**: `_check(true, ...)` → `_check(museo.call("get_vitrina", exid, "baya_roja").is_occupied(), ...)` (verifica estado real)
4. **Casos (d)/(e) corregidos**: pasan `{"piezas": ..., "recompensas": ...}` (bloque completo) en vez de piezas sueltas a `restore_save_data()`
5. **Diagnóstico**: los casos (d)/(e) eran **bug del test**, no del código. `restore_save_data()` espera el bloque `{piezas, recompensas}`; pasar solo `piezas` hacía que el método recibiera un Dictionary malformado y no reconstruía correctamente. El código de `collection_registry.gd` está correcto.

## Prueba en rojo
- Inyected `_check(false, "INYECCIÓN")` → **13 checks, 1 fallo, EXIT 1** ✓
- Retirada → **12 checks, 0 fallos, EXIT 0** ✓

## --check-only
- test_museo_rf3.gd: 0 errores ✓

## Conteo M37
73/148 (sin cambios — el falso-verde es una corrección de calidad, no un nuevo [x])
