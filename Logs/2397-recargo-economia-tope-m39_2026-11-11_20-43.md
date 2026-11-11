# Log 2397: Recargo de mercader viajero — el tope de M38 que no existía

**Fecha:** 2026-11-11
**Hora:** 20:43
**Modelo:** DeepSeek-V4.1-Flash (OpenCode)
**Plataforma:** OpenCode

## Resumen

Se cerró la deuda detectada en la tanda económica anterior: `price_manager.gd` aceptaba
cualquier `recargo_pct` de mercader viajero sin tope, aunque M39 marca `[x]` "recargos
dentro de topes de M38" (L50) y `shop_data.gd` L83 documenta el campo como "±10-15%".
Se midió el defecto en RED (3 fallos), se implementó el tope de 15 % con saneo de NaN/INF,
y se verificó con 16 suites (todas 0 fallos, EXIT 0).

No se flipeó ninguna marca: M39 es módulo ajeno y §21.4 exige GO. El fix **vuelve
verdadera** la marca existente.

## Cambios Realizados

### 1. RED medido (3 fallos antes de tocar código)

Bloque `recargo` nuevo en `scripts/economia/test_edge_cases_precio.gd` (8 checks),
con `"recargo"` agregado a `_WB_BLOQUES`, sobre un precio base controlado de 100:

- `recargo 500 %` → esperado CLAMP 15 = 115 · **medido 600**
- `recargo INF` → esperado CLAMP 15 = 115 · **medido basura silenciosa**
  (`int(round(INF))` en GDScript no lanza error)
- `recargos_clampeados()` → **no existía**

Controles que ya pasaban: sin recargo 100 · 12 % → 112 · 15 % → 115 · NaN → 100 ·
negativo → 100.

Corrida RED: **28 checks, 3 fallos, EXIT 1**.

### 2. Corrección en `price_manager.gd`

- `const RECARGO_MAX_PCT: float = 15.0` junto a `DESCUENTO_VOLUMEN_MAX` / `DESCUENTO_TOTAL_MAX`.
  Se eligió 15 % porque es el extremo superior del rango documentado y deja holgado el
  único recargo real del catálogo (12 %, `catalogo_tiendas.gd` L156).
- Saneo del parámetro en `precio_compra_vigente()`: `NaN` se ignora, `±INF` satura al tope,
  `> RECARGO_MAX_PCT` clampea. Cada caso emite `push_warning("[DOM-ECO-RECARGO] …")`
  con item, valor recibido y valor aplicado.
- Contador `_recargos_clampeados` + accesor `recargos_clampeados()`.

### 3. Evidencia (Godot 4.7.2 headless)

- `test_edge_cases_precio.gd` → **29 checks, 0 fallos, EXIT 0** (`CHECKS_MINIMOS` 20 → 28).
  Warnings `DOM-ECO-RECARGO` visibles para 500 % e INF.
- Regresión economía (8 suites, 0 fallos / EXIT 0): `test_topos_banda` 11 ·
  `test_minorista_mayorista` 14 · `test_mercado_estacion_ferias` 23 · `test_t7_amistad` 12 ·
  `test_iter5_jkl` 33 · `test_iter4_brechas` 20 · `test_t9_rendimiento` 6 ·
  `test_economy_manager` (bloque P, 53 checks).
- Regresión tiendas (8 suites, 0 fallos / EXIT 0): `test_tiendas` · `test_tiendas_iter_glm` 39 ·
  `test_m38_economia_smoke` 7 · `test_tabla_dia_transacciones` 29 · `test_economy_npc_shop` 19 ·
  `test_inventory_economy` 52 · `test_stable_flows` 32 · `test_pergaminos_tienda`.

### 4. Documentación

`DOCUMENTACION/38-Economia/plan-actual/04-Codigo.md`: sección nueva
"Tanda del recargo (2026-11-11)" con disparador, tabla RED, corrección, evidencia y
notas para el próximo agente. Se preservó el **CRLF** del archivo (660 líneas, 0 LF sueltos).

## Hallazgos colaterales (verificados, NO tocados)

- **M112 está cerrado contra disco:** 228 `[x]` / 0 `[ ]` / 4 `[?]` = 232, coincide con
  CHECKLIST-GLOBAL. La línea del backlog ("211/225, 14 `[ ]`") está vieja.
- **Coalescing de la cola de guardado (Nemotron Fase 2): NO es defecto.**
  `qa_m59_doble_guardado.gd` L38-41 exige que dos `request_save` en el mismo frame
  completen AMBOS en FIFO ("la segunda petición no se perdió"). Implementar coalescing
  rompería un contrato ya testeado de M59. `_process_queue()` es síncrono, así que la cola
  nunca acumula por diseño.
- **Magic number `0.02` en `_ajuste_por_oferta`:** ya acotado por `AJUSTE_OFERTA_MAX`;
  cosmético, se deja.
- **M39 L50/L132/L216** quedan como `[x]` y ahora con sustento real en código.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/economia/price_manager.gd` — tope + saneo + contador
- `game/isla-ancestral/scripts/economia/test_edge_cases_precio.gd` — bloque `recargo`, `_WB_BLOQUES`, `CHECKS_MINIMOS` 28
- `DOCUMENTACION/38-Economia/plan-actual/04-Codigo.md` — sección nueva (CRLF preservado)
- `Logs/2397-recargo-economia-tope-m39_2026-11-11_20-43.md` — este log

## Nota de trazabilidad Git

El commit **`c983236`** ("… + DS-OC economia") de la directora barrió las dos primeras
modificaciones a HEAD antes de que se escribiera este log. El código del fix está en HEAD;
la documentación y el log van en el commit siguiente.
