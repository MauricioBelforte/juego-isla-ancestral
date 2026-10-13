# Log 1698: M74 - eventos relativos por calendario (RF4.10) + re-validacion al cargar (RF4.12)

**Fecha:** 2026-10-11
**Hora:** 21:45
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 148). **M74: 123 -> 125 `[x]` / 285 (+2).** Las 6 suites
de M74 quedan en **181 checks, 0 fallos**.

## Cambios Realizados

### RF4.10 — eventos relativos por calendario

`EventDefinition.regla_relativa` (String, vacío = fecha fija) con formato
`{orden}_{dia_semana}`. Resuelto por `fechas_relativas(mes) -> Array[int]` y
`static resolver(regla, mes) -> int`.

Base: el calendario Aurora son 12 meses de 28 días = 4 semanas exactas, así que el
día de la semana de (mes, día) es `((mes-1)*28 + (día-1)) % 7`, independiente del
año (mismo criterio que `GameTime.get_semana_dia()`).

Verificado en tests:
- `primer_lunes` cae siempre el día 1 (cualquier mes);
- `segundo_lunes` el 8, `tercer_lunes` el 15, `cuarto_lunes` el 22;
- `ultimo_lunes` también el 22 (solo hay 4 semanas);
- `quinto_lunes` **no existe** -> 0 (el evento no ocurre ese mes; no se inventa fecha);
- `segundo_sabado` = `primer_sabado` + 7;
- los filtros de mes/estación siguen aplicando sobre la regla;
- `coincide_fecha()` y `get_eventos_del_dia()` encuentran el evento relativo sin
  cambios en la agenda;
- round-trip `to_dict()/from_dict()` conserva la regla.

### RF4.12 — re-validar eventos al cargar

`EventManager.revalidar_al_cargar()`, invocado al final de `restore_save_data()`:
- `EN_CURSO` con franja aún abierta -> se **reabre** (`evento_actual`);
- `EN_CURSO` con franja vencida -> `NO_PARTICIPADO` + emisión de `evento_terminado`.
  El token anti-duplicado del año ya está consumido, así que no hay re-entrega.

## Verificacion

```
test_eventos_relativos_m74.gd       38 checks, 0 fallos, 4 bloques   (nueva)
test_event_manager_verificacion.gd  58 checks, 0 fallos, 9 bloques
test_buzon_entregas.gd              31 checks, 0 fallos, 4 bloques
test_event_manager_pure.gd          31 checks, 0 fallos
test_event_manager_headless.gd       8 checks, 0 fallos
test_capitulos_m74.gd               23 checks, 0 fallos
                                     ---
                                     181 checks, 0 fallos
```

Corridas UNA POR VEZ (el lote excede el timeout de 600 s).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/eventos/event_definition.gd` (`regla_relativa`,
  `ORDENES`, `SEMANA`, `es_relativa()`, `fechas_relativas()`, `resolver()`,
  `coincide_fecha()` con regla, serialización)
- `game/isla-ancestral/scripts/eventos/event_manager.gd` (`_fecha_actual()`,
  `revalidar_al_cargar()` + llamada desde `restore_save_data()`)
- `game/isla-ancestral/scripts/eventos/test_eventos_relativos_m74.gd` (nueva, 38 checks)
- `DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md` (2 flips + nota)
- `DOCUMENTACION/74-Eventos/plan-actual/04-Codigo.md` (Notas del Agente)
