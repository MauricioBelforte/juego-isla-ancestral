# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00fc","u"),("\u00bf","?"),("\u2192","->")]:
        s = s.replace(a, b)
    return s.lower()

NOTAS = {
 "moneda ao como \u00fanica divisa": "COMPLETADO 2026-10-14 (step-5-kilocode): AO (aureo de Aurora) definido como unica divisa de fase en 03-Diseno.md 2.5.1; sin moneda de segundo bioma hasta Alpha y trueque conceptual para islas futuras.",
 "las 2 tiendas de aurora": "COMPLETADO 2026-10-14 (step-5-kilocode): verificadas en disco — catalogo_tiendas.gd registra tienda_general (Tia Rua) y herreria (Obe). La 3ra es la glasswork de Coral (Bram), definida en 2.3.1 y pendiente de alta en catalogo (M39). El mercader_viajero es rotativo, no cuenta como fija.",
 "m\u00e1rgenes de venta": "COMPLETADO 2026-10-14 (step-5-kilocode): margen 55-70% sobre precio base definido en 03-Diseno.md 2.5.1 (el jugador vende en ese rango; la tienda recompra al 100%).",
 "stock regenerativo diario": "COMPLETADO 2026-10-14 (step-5-kilocode): regla definida en 2.5.1 — 40% del stock por ciclo de dia, COMUN siempre / RARO cada 3 dias / EPICO no regenera. Nota honesta: shop.gd hoy solo tiene stock inicial; el ciclo diario es trabajo de M39.",
 "banco local de cole": "COMPLETADO 2026-10-14 (step-5-kilocode): interes 0.5% diario ya estaba en 2.5 y se concreto el techo anti-inflacion (10.000 AO base + 500 por nivel de relacion, tope 25.000) en 2.5.1.",
 "techo de dep\u00f3sito del banco": "COMPLETADO 2026-10-14 (step-5-kilocode): techo 10.000 AO base + 500 AO por nivel de relacion con Cole, tope 25.000, definido en 2.5.1.",
 "flujo de venta": "COMPLETADO 2026-10-14 (step-5-kilocode): flujo de 4 pasos definido en 2.5.1 (confirmacion UI M53 -> oro atomico EconomyManager -> sonido ASMR M43/M42 -> persistencia M59). ShopManager ya emite compra_exitosa/venta_exitosa para los pasos 2 y 3.",
 "simulaci\u00f3n econ\u00f3mica en ci": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldada en disco — scripts/shops/test_loop_economico.gd (loop end-to-end M38+M14+M39) y scripts/tests/test_balance_m93_iter4.gd (curvas no exponenciales, anti-grind, techos).",
 "umbral de fallo de la simulaci\u00f3n": "COMPLETADO 2026-10-14 (step-5-kilocode): umbral definido en 2.5.1 — la curva debe mantenerse sana 30 h de juego simulado; romperse antes es fallo (coincide con el criterio de M93 y el H5 de fase).",
 "anti-grind: precios de compra": "COMPLETADO 2026-10-14 (step-5-kilocode): regla definida en 2.5.1 — el precio de compra sube 5% por unidad comprada en la misma sesion, tope 25%.",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    for clave, nota in NOTAS.items():
        if norm(clave) in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                n += 1
            break

t = "\n".join(lines)
t = t.replace("Completados: 43 \u00b7 Pendientes: 97 \u00b7 No resueltos: 2", "Completados: 53 \u00b7 Pendientes: 87 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos: [x]=%d [ ]=%d [?]=%d" % (x, s, q))
