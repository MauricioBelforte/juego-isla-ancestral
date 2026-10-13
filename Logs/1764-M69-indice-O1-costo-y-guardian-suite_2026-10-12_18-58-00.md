# Log 1764: M69-Fast-Travel — índice O(1), costo de viaje y guardián de suite

**Fecha:** 2026-10-12
**Hora:** 18:58
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Responde a:** director — `207-...-bug098-aceptado-volve-m153.md` (cola M153 → M69)

## Resumen

Segunda parada de la cola: **M69-Fast-Travel**. **11 → 14 `[x]` / 150 (+3)**.

## Cambios

### 1. Índice O(1) para lookup de destinos (D52)

`fast_travel_service.gd` tenía `solicitar_viaje()` recorriendo el Array completo
de anclas en cada viaje. Se agregó:

- `_indice: Dictionary` (id → ancla), llenado en `_cargar()`.
- `ancla_de(ancla_id) -> Dictionary` con coste O(1), `{}` si no existe.
- `solicitar_viaje()` ahora usa el índice.

La suite verifica que el índice cubre las 4 anclas reales y que un id inexistente
devuelve `{}`.

### 2. Costo de viaje (RF4 / P3)

- `set_costo_viaje({"moneda": n})` / `costo_viaje()` / `costo_total()`.
- `set_puede_pagar_fn(Callable)` para que M38/M59 inyecten la validación real;
  por defecto el viaje es gratuito.
- Nueva señal `viaje_rechazado(ancla_id, motivo)` con motivos `bloqueado`,
  `inexistente` y `costo`.

La suite prueba: default 0, costo simple, costo compuesto, viaje concedido con
saldo y rechazado sin saldo (el rechazo nombra el ancla y el motivo).

### 3. Guardián anti-falso-verde en la suite

La suite tenía 8 checks y **sin `CHECKS_MINIMOS`**. Se agregó el guardián con el
piso medido en 17 checks tras sumarle 9 reales (índice + costo).

## Verificación

```
test_fast_travel_headless.gd   17 checks, 0 fallos, RESULTADO: PASS
```

## Lección de patrón (tercera vez)

Al encolar `_resumen()` con `call_deferred` junto a `_run()`, el resumen corría
**antes** y la suite pasaba en verde con 0 checks. Ya me pasó en M104 y en M58:
el patrón correcto es que `_run()` **llame explícitamente** al resumen al final,
sin `call_deferred`.

## Archivos Modificados

- `game/isla-ancestral/scripts/fasttravel/fast_travel_service.gd`
- `game/isla-ancestral/scripts/fasttravel/test_fast_travel_headless.gd`
- `DOCUMENTACION/69-Fast-Travel/plan-actual/05-Checklist.md` (3 flips)
