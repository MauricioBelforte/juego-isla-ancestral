# Log 2219: M20 — BUG del límite diario (regalo/carta) corregido + validación de texto_id

**Fecha:** 2026-10-27
**Hora:** 20:25
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Resumen

Tanda 5 del riel M20. Se corrigió el **BUG M20** routeado por la directora `agnes-3-flash`
(canal MiniMax #059): `regalar()` consumía el límite diario **antes** de validar el inventario, de
modo que un regalo rechazado por falta de item **quemaba el intento del día** (el jugador se quedaba
sin poder regalar hasta el día siguiente). En el mismo paso se implementó la validación de `texto_id`
en `enviar_carta()` (ítem L164 del checklist, que estaba mapeado como deuda).

Se añadió la suite de regresión `res://tests/test_m20_limite_regalo.gd` (**19 checks, 0 fallos,
EXIT 0**) con prueba rojo-verde, y se cableó en `quality.yml` (M118).

## Cambios Realizados

### Código (fix del bug)

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/scripts/friendship/vecino_amistad.gd` | Nueva primitiva `devolver_limite(tipo: String) -> void`: descuenta 1 uso del límite diario (para devolver el límite cuando la acción que lo consumió falló después). |
| `game/isla-ancestral/scripts/friendship/friendship_service.gd` | `regalar()`: si `remover_items()` falla → `v.devolver_limite("regalo")` antes de devolver `sin_item`. |
| `game/isla-ancestral/scripts/friendship/friendship_service.gd` | `regalar_en_cumpleanos()`: ídem con el límite propio `"cumpleanos"`. |
| `game/isla-ancestral/scripts/friendship/friendship_service.gd` | `enviar_carta()`: adjunto inexistente → `v.devolver_limite("carta")`; **valida `texto_id` antes de consumir el límite**: `""` → `texto_vacio`, id inexistente en `data/amistad/cartas.json` → `texto_invalido`. Nuevo helper privado `_hay_item_para_regalo(inv, item_id)` (`count_item(item_id, true)` = bolsa+mochila+casa, igual que `remover_items`). |
| `game/isla-ancestral/scripts/friendship/test_ciclo_amistad_m20_hy3.gd` | Ajuste MÍNIMO de determinismo: se asegura `PIEDRA` en el inventario antes del primer regalo, para que el caso negativo que la suite quiere probar (2º regalo del mismo día → `limite_diario`) no dependa del estado ambiental del inventario. No se cambió ninguna aserción de fondo de la suite de Hy3. |

### Suite de regresión

- `game/isla-ancestral/tests/test_m20_limite_regalo.gd` (NUEVA): **19 checks, 0 fallos, EXIT 0**.

Checks nombrados (texto literal):

1. "regalo rechazado por falta de item: se avisa sin_item y no se entrega nada"
2. "regalo rechazado por falta de item NO consume el limite diario de regalo"
3. "regalo valido del mismo dia tras el fallo: se acepta (limite conservado)"
4. "carta con adjunto inexistente: se rechaza con sin_adjunto"
5. "carta con adjunto inexistente NO consume el limite diario de carta"
6. "carta valida del mismo dia tras el fallo: se envia (limite de carta conservado)"
7. "carta sin texto seleccionado (texto_id vacio): se rechaza con texto_vacio"
8. "carta sin texto no consume el limite diario de carta"
9. "carta con texto_id inexistente en data: se rechaza con texto_invalido"
10. "carta con texto_id inexistente no consume el limite diario de carta"
11. "carta con texto_id valido tras los rechazos: se envia (limite de carta conservado)"
12. "cumpleanos: la fecha de prueba coincide con el cumpleanos del vecino"
13. "regalo de cumpleanos rechazado por falta de item: se avisa sin_item"
14. "regalo de cumpleanos fallido NO consume el limite diario de cumpleanos"
15. "regalo de cumpleanos valido tras el fallo: se acepta (limite conservado)"
16. "regalo de cumpleanos NO consume el limite diario de regalo"
17. "regalo valido: el limite diario de regalo queda consumido (usado=1)"
18. "segundo regalo del mismo dia: se rechaza con limite_diario"
19. "dia siguiente: el limite diario de regalo se reinicia y el regalo se acepta"

### Prueba rojo-verde (anti-falso-verde)

| Escenario | Resultado medido |
|---|---|
| Suite **sin** el fix (`devolver_limite` ausente) | 14 checks / **6 fallos** / EXIT 1 |
| Suite **sin** la validación de `texto_id` | 19 checks / **5 fallos** / EXIT 1 |
| Suite **con** el fix completo | 19 checks / **0 fallos** / EXIT 0 |

### Regresión (todas verdes, EXIT 0)

`scripts/friendship/test_amistad.gd` 14/0 · `scripts/friendship/test_amistad_eventos.gd` 53/0 ·
`scripts/friendship/test_amistad_rf48_m20.gd` 12/0 · `scripts/friendship/test_ciclo_amistad_m20_hy3.gd`
30/0 · `tests/test_m20_amistad_cobertura.gd` 15/0 · `tests/test_m20_limite_regalo.gd` 19/0.

### Documentación

- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/04-Codigo.md` → nueva §7.6 con el análisis del bug,
  el fix, la tabla de checks y la prueba rojo-verde.
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/05-Checklist.md` → +2 `[x]`
  (100 → 102 de 150; pendientes 49 → 48; total 149 → 150 al añadir el ítem del bug):
  · **"El limite diario NO se consume cuando la accion falla por falta de item (regalo, carta con adjunto, regalo de cumpleanos)"** (ítem NUEVO)
  · **"Carta sin texto seleccionado: validacion"** (L164, estaba mapeado como deuda)
  · El ítem L163 ("Inventario vacio: opcion regalar deshabilitada con tooltip") sigue `[ ]`: la parte de
    **UI** (opción deshabilitada + tooltip) es de M53/UI, no de M20; su nota se actualizó para dejar
    constancia de que la parte de **servicio** quedó completa y corregida.
- `CHECKLIST-GLOBAL.md` → fila 20 sincronizada a **102/150** (estado `🔵 En curso`, agente
  `minimax-m3-1-flash`, actividad `2026-10-27 20:25`) + nota con la evidencia.
- `.github/workflows/quality.yml` → suite M20 nueva cableada en el job `test-suite` (lane M20).

## Archivos Modificados/Creados

**Creados:**
- `game/isla-ancestral/tests/test_m20_limite_regalo.gd`
- `Logs/2219-M20-BUG-LIMITE-DIARIO-Y-VALIDACION-TEXTO-ID_2026-10-27_20-25-00.md` (este)

**Modificados:**
- `game/isla-ancestral/scripts/friendship/vecino_amistad.gd`
- `game/isla-ancestral/scripts/friendship/friendship_service.gd`
- `game/isla-ancestral/scripts/friendship/test_ciclo_amistad_m20_hy3.gd`
- `.github/workflows/quality.yml`
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/04-Codigo.md`
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/05-Checklist.md`
- `CHECKLIST-GLOBAL.md`

## Notas

- **No auto-sello** (§21.8/§21.23): la verificación de M20 la hacen Hy3 o agnes-3-flash. Este log solo
  documenta el trabajo; el sello formal no me corresponde.
- **Deuda que NO se tocó** (ajena): escala `amistad_<npc_id>` (M20 entrega NIVEL 1..11, el registry de
  M162 exige >= 60 / >= 90) · deriva de umbrales entre `data/balance/friendship.json` y
  `data/amistad/amistad_config.tres` · CI de M112 por encima del presupuesto de 600 s (lane voxel).
