# M129: stock y numeracion de tiradas limitadas implementados + boot B-17/B-12-06 en verde

**Modelo:** DeepSeek V4.1 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-11-06 22:27
**Responde a:** agnes-3-flash — `249` (reasignacion M129+M17)
**Rol:** gate-1 (auditor) + codificacion. **No sello.**

---

## 1. M129 — parte codigo/logica: hecha

Tome el item que estaba `[?]` por Familia A (BUG-070 lote 7): **L101 "sistema de control de stock y
numeracion para tiradas limitadas fisicas (artbooks de pasta dura, vinilos)"**. Ahora tiene codigo real.

**Datos — `data/legal/merchandising.json` v3:** seccion `tiradas_limitadas` con 3 SKUs:
`artbook_pasta_dura` (500), `vinilo_soundtrack` (300), `figura_resina_8in` (200), cada uno apuntando a
su `producto_id` del catalogo.

**Servicio — `scripts/legal/merch_manager.gd`:**
- Estado por SKU: `vendidas`, `reservadas`, `numeros` (`unidades` inmutable del JSON).
- API: `get_tiradas/get_tirada/get_tirada_ids/es_tirada_limitada/unidades_totales/unidades_vendidas/
  unidades_reservadas/unidades_disponibles/get_numeros_asignados/reservar_unidades/liberar_reserva/
  confirmar_venta/reiniciar_tiradas`.
- Reglas: reservar **no** asigna numero; `confirmar_venta` consume primero reservas y asigna
  correlativos **1..N unicos y sin huecos**; sobreventa y sobre-reserva se rechazan con motivo;
  un producto sin tirada devuelve `-1` disponibles y `sku_no_limitado`.
- **Persistencia M59:** `get_section_name() == "merch"` + `get_save_data()` + `restore_save_data()`
  (con reconstruccion de correlativos si el save viene inconsistente) + registro como proveedor de
  `SaveManager` en `_ready()`. Dejo de ser solo una fachada de lectura.

**Validador — `scripts/legal/merch_validator.gd`:** valida `sku` no vacio y unico, `producto_id`
existente y `unidades > 0`.

**Tests (Godot 4.7.2 headless):**
- `test_merch_m129.gd` v3 → **58 checks / 0 fallos**, EXIT 0. Ciclo completo: reserva 3 → venta 2
  (numeros `[1,2]`) → venta 2 consume reserva + libre (numeros `[3,4]`) → sobre-reserva/sobre-venta
  rechazadas → save/restore conserva 4 vendidas y 496 disponibles → reinicio deja 500.
- **Boot B-17 / B-12-06** (`test_merch_boot_m129.gd`, nuevo) → **11 checks / 0 fallos**, EXIT 0:
  autoload cargado, contrato `"merch"` en `ServiceRegistry` apuntando al autoload y seccion `"merch"`
  presente en el payload real de `SaveManager.snapshot.collect()`.
- Boot del proyecto (`--quit-after 600`): EXIT 0, **sin** `SCRIPT ERROR`/`Parse Error`;
  `[M129] MerchManager listo (10 productos, 3 tiradas limitadas)`.

**Checklist:** 107 `[x]` / 0 `[ ]` / **1 `[?]`** = 108. El unico pendiente es **L134** (pipeline de
mockups 3D), que queda para **Hy4** como dijiste. No toque `quality.yml` (requiere autorizacion del
fundador); los dos scripts se corren a mano y quedan listos para cablearse.

**Respaldos:** `game/isla-ancestral/scripts/legal/Obsoletos/2026-11-06_22-18-40_*` (manager, validator,
test y JSON anteriores).

## 2. Ojo con los numeros de M129: no coinciden con tu 75/129

Antes de tocar nada medi el archivo en disco: **106 `[x]` / 0 `[ ]` / 2 `[?]` = 108** (la fila GLOBAL
declara 101/108; la diferencia son 5 flips de diseno de Reflection-Beam del 2026-10-26 —L44, L53, L60,
L68, L153— que en items de diseno son validos porque el entregable es la spec). Tu mensaje decia
"75/129: 54 items". No encontre ningun checklist de M129 con 129 items: el del modulo tiene 108 y el
plan-inicial tambien. **Puede que el 75/129 sea de otro modulo o de una tabla vieja.** Te lo marco para
que no se pierda: el estado real hoy es **107/108, con 1 solo `[?]` (L134)**.

## 3. Que sigue

- **M17 Construccion** ahora (segundo de tu orden): 135/175 en disco, 39 `[ ]` + 1 `[?]`. Voy a leer
  los 40 abiertos y separar los verificables headless de los que dependen de arte/navmesh.
- **L134** queda esperando a Hy4.
- Sin tocar `CHECKLIST-GLOBAL.md` ni commits. Los cambios estan en el working tree.

Quedo en beat de 600 s.
