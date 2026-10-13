# Log 1693: M74-Eventos - lote de verificacion: 22 [?] -> [x] con 5 bugs reales corregidos

**Fecha:** 2026-10-11
**Hora:** 20:50
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 144): tomar M74-Eventos y cerrar un lote grande de
items `[?]`. La QA cruzada de Hy3 (Log 362) los habia dejado pendientes por no
tener entorno Godot; aca se verificaron con ejecucion headless real.
**M74: 95 -> 117 `[x]` / 285 (+22), 4 suites en 120 checks / 0 fallos.**

## Cambios Realizados

### Suite nueva

`game/isla-ancestral/scripts/eventos/test_event_manager_verificacion.gd`
(58 checks, 0 fallos, 9 bloques) con dobles de prueba para M14/M38/M20/M37/M71 y
el catalogo real. Bloques: catalogo, anti-duplicado, entrega por tipo,
NO_PARTICIPADO/compensatoria, aviso previo, senales, sorpresas, persistencia y
robustez, NFR medibles y estaticos.

### Bugs REALES corregidos

1. **`_set_estado` no escribia si el ano ya existia** (`event_manager.gd`): el
   segundo set del mismo ano (marcar recompensa, NO_PARTICIPADO, cancelacion) se
   perdia en silencio. Ahora crea el diccionario del anio si falta y siempre escribe.
2. **Division ENTERA en `dias_hasta`**: `mins_hasta / 1440` daba 0 para eventos a
   menos de un dia -> el aviso del ultimo dia NUNCA se emitia (RF3.2). Corregido a
   `float(mins_hasta) / 1440.0`.
3. **`restore_save_data` crasheaba con save corrupto**: `"eventos": "string"`
   rompia la carga (RN6 incumplido). Ahora valida tipos, avisa y descarta.
4. **`RecompensaDef.entregar()` llamaba APIs que NO existen**: `Inventario.agregar()`
   y `EconomyManager.suministrar_moneda()` no estan en M14/M38 -> TODA entrega de
   recompensa fallaba en silencio y el anti-duplicado nunca marcaba nada. Ahora usa
   las APIs reales (`add_item`/`agregar_items`, `depositar_monedas`) por duck-typing.
5. **La compensatoria pisaba CANCELADO con PARTICIPADO**: `_entregar_una_recompensa`
   llamaba `marcar_recompensa_recibida()`. Nuevo
   `EventState.marcar_recompensa_compensatoria()` que consume el token del anio y
   conserva CANCELADO.

### NFR medidos

- RN1: tick de `dia_cambio` medido **0.49 ms**; amortizado por frame
  **0.000006 ms** (dia de 86400 frames) -> cumple el < 0.05 ms/frame.
- RN2: cero `_process`/`_physics_process` en `scripts/eventos/` (sin polling).
- RN3: catalogo de datos 12 KB (<< 1 MB).
- RN15: `event_manager.gd` sin referencias a UI concreta.

## Lo que quedo `[?]` a proposito (evidencia negativa)

Buzon de entregas (RF6.9/6.10, I9, J15, M8); campo `version` del save (RN5);
integracion real con M20/M37/M71 (no exponen metodos destino: se dejaron ganchos
que fallan con warning en vez de fingir exito); eventos relativos tipo "segundo
sabado" (RF4.10: `dia_relativo` es un indice, no regla de calendario);
re-validacion al cargar (RF4.12); UI, i18n, efectos M31/M32 y gatillos runtime de
historia.

## Verificacion

```
test_event_manager_verificacion.gd  58 checks, 0 fallos, 9 bloques   (nueva)
test_event_manager_pure.gd          31 checks, 0 fallos
test_event_manager_headless.gd       8 checks, 0 fallos
test_capitulos_m74.gd               23 checks, 0 fallos
                                    ---
                                    120 checks, 0 fallos
```

Sondas de medicion (`probe_*.gd`) eliminadas al terminar.

## Errores propios corregidos durante la sesion

- Mi primer ancla de flips (`"RF6.1"`) matcheo **RF6.10** por substring y lo marco
  `[x]` siendo un item NO implementado. Detectado al verificar, revertido a su
  marca original (`[?]`) y re-aplicado con anclas exactas. Segunda vez que cometo
  esta clase de error (la anterior fue `"Demolici"` en M17): la regla queda
  asentada en ambos logs.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/eventos/test_event_manager_verificacion.gd` (nueva)
- `game/isla-ancestral/scripts/eventos/event_manager.gd` (`_set_estado`, `dias_hasta`,
  `restore_save_data`, marcado de compensatoria)
- `game/isla-ancestral/scripts/eventos/event_state.gd` (`marcar_recompensa_compensatoria`)
- `game/isla-ancestral/scripts/eventos/recompensa_def.gd` (APIs reales M14/M38)
- `DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md` (22 flips + nota)
- `DOCUMENTACION/74-Eventos/plan-actual/04-Codigo.md` (Notas del Agente)
