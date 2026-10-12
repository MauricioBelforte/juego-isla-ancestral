# Log 1686: M17 iter. 4 - tres edge cases de la seccion L implementados

**Fecha:** 2026-10-11
**Hora:** 19:50
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 140): implementar los edge cases del nucleo de M17 que
se pueden probar en headless. Se implementaron los tres de la lista y se agrego una
cuarta suite. **M17: 66 -> 69 `[x]` / 175.**

## Cambios Realizados

### 1. Rechazo TEMPORAL por NPC (item L187)

El rechazo por NPC existia pero era indistinguible de uno permanente. Ahora:

- `construccion_tipos.gd`: `MOTIVOS_TEMPORALES` (NPC_EN_CELDA, RECURSOS_INSUFICIENTES,
  DOBLE_CONFIRMACION) + `es_temporal()`.
- `resultado_ok/fallo()` exponen `"temporal"` (true si ALGUN motivo es temporal).
- `build_hud.gd`: `linea_estado()` añade "(temporal: probá de nuevo)" y `resumen()`
  expone `temporal`.
- Un NPC en la celda sigue bloqueando la colocacion y NO cobra recursos; cuando el
  NPC se va, la misma celda vuelve a ser valida sin que el jugador haga nada.

### 2. Limite del mundo (item L194)

- `build_manager.gd`: `set_limite_mundo(AABB)` / `limite_mundo()` (AABB vacia = sin
  limite, default documentado para headless).
- `construccion_validator.gd`: nueva regla "mundo" en `ORDEN` (antes del limite de
  zona) y `fuera_del_mundo(celdas, ctx)` que devuelve la LISTA de celdas fuera.
- Nuevo motivo `FUERA_DEL_MUNDO` con texto "fuera de los limites de la isla".
  El borde es inclusivo; negativo y por encima del tope se rechazan.

### 3. Doble confirmacion rapida (item L196)

- `build_manager.gd`: cooldown de 250 ms **por celda** en `confirmar_colocacion()`,
  nuevo motivo `DOBLE_CONFIRMACION` (temporal).
- Decision de diseno: el cooldown se evalua **DESPUES de validar**. Asi un rechazo
  real (celda ocupada, sin soporte) muestra SU motivo y no queda tapado por el
  cooldown.
- El estado del cooldown se resetea en `limpiar_estructuras()` junto con el resto
  del estado de sesion.

## Regresion encontrada y corregida

Al correr la regresion, `test_construccion.gd` dio **20 fallos**: el cooldown
sobrevivia a `limpiar_estructuras()`, as\u00ed que la primera pieza tras un reset
quedaba bloqueada por un click viejo (bloques 8/9/10 encadenan colocaciones en la
misma celda (0,0,0) entre bloques). Corregido reseteando `_ultima_celda` y
`_ultima_confirmacion_ms` en `limpiar_estructuras()`. Vuelta a verde: 131/0.

## Verificacion

```
test_construccion.gd        131 checks, 0 fallos, 12 bloques
test_construccion_iter2.gd   99 checks, 0 fallos,  9 bloques
test_construccion_iter3.gd  138 checks, 0 fallos,  9 bloques
test_construccion_iter4.gd   45 checks, 0 fallos,  4 bloques   (nueva)
                             ---
                             413 checks, 0 fallos
```

Suite iter4: 4 bloques (NPC temporal con NPC entrando y saliendo, limite del mundo
dentro/borde/fuera/negativo/sin AABB, cooldown mismo-otra celda y no-tapa-ocupada,
regresion de enum/textos/ORDEN).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/construccion/construccion_tipos.gd` (motivos + temporales)
- `game/isla-ancestral/scripts/construccion/construccion_validator.gd` (regla mundo + fuera_del_mundo)
- `game/isla-ancestral/scripts/construccion/build_manager.gd` (AABB + cooldown + reset)
- `game/isla-ancestral/scripts/construccion/build_hud.gd` (texto temporal + resumen)
- `game/isla-ancestral/scripts/construccion/test_construccion_iter4.gd` (nueva, 45 checks)
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` (3 flips + Totales + nota)
- `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` (Notas del Agente iter. 4)

## Nota de proceso

La reserva del numero de log salio con el agente mal tipeado (`stepfun-step5`) en la
salida del helper; la firma de este log y de los documentos es la correcta:
`stepfun-step-5-preview`. El numero 1686 queda consumido igual.
