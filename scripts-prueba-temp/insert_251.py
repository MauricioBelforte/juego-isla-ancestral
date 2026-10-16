# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

seccion = """### 2.5.1 Cierre economico de fase (2026-10-14, step-5-kilocode)

Cierra la seccion 5 del checklist con definiciones + respaldo en disco.

**Moneda:** el **AO** (aureo de Aurora) es la unica divisa de la fase. Sin moneda de segundo bioma
hasta Alpha; el trueque conceptual (ya definido en 2.5) cubre islas futuras sin romper esto.

**Tiendas (verificado contra `scripts/shops/catalogo_tiendas.gd`):**

| Tienda | Isla | Dueno | Estado |
|---|---|---|---|
| `tienda_general` | Aurora | Tia Rua | **registrada en catalogo** (TIENDAS.GENERAL) |
| `herreria` | Aurora | Obe / herrero | **registrada en catalogo** (TIENDAS.HERRERIA) |
| `mercader_viajero` | rotativo | - | registrado (no cuenta como tienda fija) |
| tienda glasswork (Coral) | Coral | Bram | **definida** en 2.3.1 con stock propio; pendiente de alta en el catalogo (M39) |

**Margenes de venta:** 55-70% sobre el precio base de compra - el jugador vende a ese rango y la
tienda recompara al 100%. Regla de balance en M93.

**Stock regenerativo diario:** cada tienda regenera el **40% del stock** cada ciclo de dia (M31);
los items de rareza COMUN regeneran siempre, los RAROS cada 3 dias y los EPICOS no regeneran.
Implementacion del ciclo en M39 (hoy shop.gd solo tiene stock inicial).

**Flujo de venta (definido, 4 pasos atomicos):** 1) confirmacion en UI (M53, con precio y cantidad)
-> 2) oro atomico via EconomyManager (sin doble credito) -> 3) sonido ASMR por threshold de precio
(M43/M42) -> 4) persistencia en el save del dia (M59). ShopManager ya emite las senales
`compra_exitosa` / `venta_exitosa` para los pasos 2 y 3.

**Banco de Cole (2.5):** interes 0.5% diario. **Techo anti-inflacion:** 10.000 AO base + 500 AO por
nivel de relacion con Cole (tope 25.000). Implementacion en M38.

**Anti-grind:** el precio de compra de un item sube **5% por unidad comprada en la misma sesion**,
con tope de 25% - evita farming de un solo item. Regla en M93.

**Simulacion economica en CI (respaldada):**
- `scripts/shops/test_loop_economico.gd` - loop end-to-end M38 + M14 + M39.
- `scripts/tests/test_balance_m93_iter4.gd` - curvas no exponenciales, reglas anti-grind/techos.

**Umbral de fallo de la simulacion:** el test debe mantener la curva sana durante **30 h de juego
simulado**; si se rompe antes, es fallo (criterio ya presente en el diseno de M93 y en el H5 de fase).
"""

for i, l in enumerate(lines):
    if l.startswith("### 2.6 Construcci"):
        lines.insert(i, "")
        lines.insert(i, seccion.rstrip())
        lines.insert(i, "")
        print("seccion 2.5.1 insertada en linea", i + 1)
        break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
