# Log 2378: Tanda económica M38 — retiro de 0, monto real acreditado y tope lleno

**Fecha:** 2026-11-08
**Hora:** 23:00
**Modelo:** DeepSeek-V4.1-Flash (OpenCode)
**Plataforma:** OpenCode

## Resumen

Continuación de la tanda de críticos funcionales de la evaluación Nemotron (Log 2377), esta vez
sobre el modo **economía** de M38. Tres defectos medidos en RED primero y corregidos con suite
propia: `retirar_monedas(0)` era el gemelo del depósito de 0 ya corregido; el historial de
transacciones anotaba el monto **pedido** y no el **acreditado** cuando el tope de saldo recortaba;
y con el tope lleno el depósito se aceptaba, las monedas se evaporaban y el jugador recibía un "OK".
Hallazgo colateral: el aviso `DOM-ECO-SALDO`, que el checklist de M38 daba por hecho en tres ítems
`[x]`, no existía en ninguna parte del proyecto.

## Cambios Realizados

### RED primero (6 fallos antes de tocar código)

Bloque **P** nuevo en `tests/unit/economia/test_economy_manager.gd` (+17 checks) y `'P'` agregado a
`BLOQUES_ESPERADOS`. Fallos iniciales: `retirar_monedas(0)` devolvía `true`; registraba la
transacción de 0; emitía `saldo_cambiado` con `[100]` sin cambio de saldo; la transacción del
depósito recortado traía `monto: 200` cuando habían entrado 99; y `depositos_clampeados()` no
existía. Un sexto fallo era del propio test: la lambda capturaba el `Dictionary` por valor, así que
el `Array` pasó a ser el recolector (lección de GDScript ya documentada).

### Correcciones en `scripts/economia/economy_manager.gd`

1. **`retirar_monedas`:** `if total <= 0: return false`. `puede_pagar(0)` sigue siendo `true`
   porque es una consulta válida y la usan tiendas y crafting.
2. **Monto real acreditado:** `depositar_monedas` calcula `acreditado = saldo - saldo_antes` y
   registra **eso** en el historial, no el monto pedido. El historial es la fuente de M103/M104.
3. **Tope lleno:** si `saldo >= MAX_SALDO`, el depósito se rechaza con
   `[DOM-ECO-SALDO] ... rechazado: saldo en el tope ...`. Antes devolvía `true` y evaporaba las
   monedas.
4. **Aviso `DOM-ECO-SALDO`:** implementado en las dos ramas de recorte (recortado / rechazado), con
   contador `_depositos_clampeados` y accesor `depositos_clampeados()`. El warning no es verificable
   desde un test headless; el contador sí. Es telemetría, no gameplay.

El invariante que queda: **la reputación cuenta ingresos reales, no llamadas**. Un depósito
recortado suma una vez (entró algo); uno rechazado por tope lleno o por monto `<= 0` no suma.

### Documentación

Sección nueva en `DOCUMENTACION/38-Economia/plan-actual/04-Codigo.md` con diagnóstico, código
corregido, evidencia y deudas. **No se flipeó ninguna marca** de M38 (módulo ajeno a mi reserva):
los ítems L56 (RNF10) y L172 que afirmaban el `[x]` del clamp con aviso ahora son **verdaderos**
por el fix, no hubo que degradarlos.

## Verificación (Godot 4.7.2 headless)

- `tests/unit/economia/test_economy_manager.gd`: **53 checks / 0 fallos / EXIT 0** (36 previos + 17).
- Regresión de las 9 suites que llaman `retirar_monedas`/`depositar_monedas`, todas **0 fallos / EXIT 0**:
  - `scripts/shops/test_tiendas.gd` — 0 fallos
  - `scripts/shops/test_tiendas_iter_glm.gd` — 39 checks / 0
  - `scripts/economia/test_iter4_brechas.gd` — 20 / 0
  - `scripts/economia/test_m38_economia_smoke.gd` — 7 / 0
  - `scripts/economia/test_tabla_dia_transacciones.gd` — 29 / 0
  - `tests/integration/test_economy_npc_shop.gd` — 19 / 0
  - `tests/integration/test_inventory_economy.gd` — 52 / 0
  - `tests/regression/test_stable_flows.gd` — 32 / 0
  - `scripts/crafting/test_pergaminos_tienda.gd` — 0 fallos
- **Riesgo de crafting descartado antes de correr:** `crafting_service.gd` L291 llama
  `retirar_monedas(coste_ao * cantidad)`, pero `if receta.coste_ao > 0:` (L286) y `cantidad < 1`
  rechazado en L269 impiden que llegue un 0. Las recetas gratuitas siguen crafteándose.
- Warnings reales observados: `[DOM-ECO-SALDO] deposito de 200 recortado a 99: tope 999999
  alcanzado` y `[DOM-ECO-SALDO] deposito de 200 rechazado: saldo en el tope 999999`.

## Hallazgos que NO se tocaron

- **`DOM-ECO-SALDO` no existía** en todo el proyecto (0 coincidencias de grep) pese a tres `[x]` de
  M38 (L47/L56/L172). Queda resuelto por esta tanda; se documenta para que el próximo auditor no lo
  lea como inflación.
- **`price_manager.gd` sin tope de `recargo_pct`:** el comentario dice "recargo opcional de
  mercaderes viajeros" pero nada limita el porcentaje. Un 500 % convertiría un ítem de 10 AO en 60.
  Dueño: M39 (el recargo es suyo), no M38.
- **Caracteres perdidos en el checklist de M38:** `dep?sitos` (L172), `inv?lidas` (L211),
  `? escalones` (L91) son prosa dañada por una reparación de encoding vieja. `fix_encoding.py` no
  las recupera (el byte ya se perdió). Requiere GO del dueño del módulo.
- **Dos líneas `**Totales:**`** en ese checklist: la primera (164/164/0/0) es vieja; la última
  (163 completados / 0 pendientes / 1 no resuelto) coincide con el disco: **163 `[x]` / 0 `[ ]` /
  1 `[?]` = 164**.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/economia/economy_manager.gd` (modificado)
- `game/isla-ancestral/tests/unit/economia/test_economy_manager.gd` (bloque P + `BLOQUES_ESPERADOS`)
- `DOCUMENTACION/38-Economia/plan-actual/04-Codigo.md` (sección nueva)
- `Logs/2378-tanda-economia-m38-retiro-cero-tope-saldo_2026-11-08_23-00.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (cabeza consumida: 2378 → 2379)

## Estado

Sin commit propio (los sellos y commits son de la directora). Working tree sobre `47246de`.
Informe en el canal: mensaje **259**.
