# Log 1017: M39 Tiendas — cierre iter. glm (fix atomicidad D8 + cierre BUG-028 en causa raiz)

**Fecha:** 2026-09-19
**Hora:** 22:10
**Modelo:** glm-5.3-flash
**Plataforma:** Cline

## Resumen

Cierre de la iteracion de M39 Tiendas (reserva Log 1004, regla 21.4.7). Se corrigio un
BUG REAL de atomicidad D8 (perdida de monedas al comprar con inventario lleno), se cerro
**BUG-028 en causa raiz** (id `OBJ-PLA-001` inexistente en ItemDatabase), y se marco el
checklist del modulo con evidencia: **81/181 → 127 [x] / 54 [ ]**. Las 3 suites headless
quedaron verdes con el binario real.

## Verificacion (binario real Godot 4.7.2, headless)

| Suite | Resultado |
|---|---|
| `test_tiendas.gd` | **EXIT=0** |
| `test_loop_economico.gd` | **EXIT=0 — 15 checks, 0 fallos, "LOOP ECONOMICO OK"** |
| `test_tiendas_iter_glm.gd` | **EXIT=0 — 33 checks, 0 fallos, "M39 ITER GLM OK"** |

Ejecutadas via `scripts/run_shops_tests.bat` (salida a `Logs/_t39_*.txt`).

## Cambios realizados

### 1. Fix atomicidad D8 — `game/isla-ancestral/scripts/shops/shop_manager.gd` (L238-248)
- **BUG:** en compra con inventario lleno, las monedas se PERDIAN. El flujo viejo: `puede_pagar`
  (consulta pura) → mover stock → `agregar_items` falla → revert solo de stock →
  `retirar_monedas(total)` quedaba al final y JAMAS se ejecutaba, pero al revertir se
  emitia rechazo sin devolver monedas en futuros flujos donde el cobro precedia.
- **Fix:** `retirar_monedas(total)` es ahora el paso de validacion+cobro (devuelve false →
  `SIN_FONDOS` sin efectos; su validacion interna reemplaza al `puede_pagar` previo) y el
  revert en fallo de inventario devuelve **stock Y monedas** (`depositar_monedas(total)`).
- **Test nuevo** (`test_tiendas_iter_glm.gd`): llena los 3 contenedores (84 adds: el
  adaptador de M14 cae BOLSILLO→CASA), fuerza `INVENTARIO_LLENO` y verifica revert TOTAL
  (stock exacto + saldo exacto). Lecciones operativas: `remover_items` es todo-o-nada con
  validacion previa (count < pedido → false SIN remover) → cleanup con conteo real.

### 2. BUG-028 cerrado — causa raiz id inexistente (NO precio)
- Mapa real de ids con `scripts/reporte_ids_items.py` (111 `.tres` + cruce con
  `econ_prices.tres`): **`OBJ-PLA-001` NO existe** — `item_obj_pla_001.tres` contiene
  `id = "OBJ-CUA-007"` (BUG-046). El "precio 0" era sintoma del id fantasma.
- `test_loop_economico.gd`: fixture migrado `OBJ-PLA-001` → **`OBJ-PLA-002`** (existe,
  precio_compra=30) + check guardian `"item OBJ-PLA-002 existe en ItemDatabase"`
  (anti-falso-verde: si el id desaparece, el test lo dice).
- `DOCUMENTACION/11-BUGS.md`: BUG-028 → `[x] Resuelto` con resolucion firmada (y
  referencia a la actualizacion de atria-dawn que ya habia identificado la causa).

### 3. Herramientas de diagnostico
- `scripts/reporte_ids_items.py`: seccion CRUCE `econ_prices.tres` (15 item_id) vs
  `data/items/` — todos los ids legacy de economia **FALTAN** en M159 (aviso, dueño M159).
- `scripts/run_shops_tests.bat`: runner de las 3 suites con EXIT real.
- `DOCUMENTACION/39-Tiendas/scripts-prueba/marcar_iter_glm.py`: marcado auditable
  (46 items con evidencia; idempotente).

### 4. Documentacion
- `05-Checklist.md`: cabecera de reserva actualizada a **Liberado (Log 1017)**, 46 items
  `[x]` con la nota `*(iter. glm — Log 1017)*`, resultado **127 [x] / 54 [ ]**.
- `04-Codigo.md`: nuevas Notas del Agente (Lo que hice / NO pude hacer / Recomendaciones).

## Pendientes declarados (honestidad)

- **UI M53:** `tienda_cerrada`/`proxima_apertura` emiten datos pero `shop_ui.gd` no dibuja
  el cartel; `inventario_tienda_cambio` sin consumir.
- **Ferias M73:** canal 3 del generador probado en aislado; ShopManager aun no llena
  `ctx.eventos_activos` con eventos reales.
- **Tipos PUESTO_SEMILLAS/PESCADERIA:** sin tienda oficial (solo general/herreria/viajero).
- **Avisos "item_id inexistente en M15" en boot:** nomenclatura legacy (`madera_roble`...)
  vs ids M159 (`OBJ-*`) — BUG-046, dueño M159; PriceManager funciona porque lee
  `econ_prices.tres` (ids legacy). NO corregido en esta iteracion.
- **QA cruzado §21.8:** pendiente (verificador ≠ glm-5.3-flash).

## Archivos modificados/creados

- `game/isla-ancestral/scripts/shops/shop_manager.gd` (fix atomicidad D8)
- `game/isla-ancestral/scripts/shops/test_tiendas_iter_glm.gd` (test atomicidad + recargo)
- `game/isla-ancestral/scripts/shops/test_loop_economico.gd` (BUG-028: OBJ-PLA-002 + guardian)
- `scripts/reporte_ids_items.py`, `scripts/run_shops_tests.bat`
- `DOCUMENTACION/11-BUGS.md` (BUG-028 resuelto)
- `DOCUMENTACION/39-Tiendas/plan-actual/{04-Codigo,05-Checklist}.md`
- `DOCUMENTACION/39-Tiendas/scripts-prueba/marcar_iter_glm.py` (nuevo)
- `Logs/1017-M39-Tiendas-Cierre-Iter-Glm-Atomicidad-D8_2026-09-19_22-10.md` (este)
- Consumida reserva `Logs/reservas/1017-glm-5.3-flash-M39.txt` (borrada, §6.1.b)