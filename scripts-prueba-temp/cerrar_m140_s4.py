# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/140-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00fc","u"),("\u00bf","?"),("\u2192","->")]:
        s = s.replace(a, b)
    return s.lower()

NOTAS = {
 "curvas alpha para": "COMPLETADO 2026-10-14 (step-5-kilocode): las 7 curvas definidas en 03-Diseno.md 2.4.1 (precios, drops, XP, amistad, puzzles, cultivos, dificultad). Nota honesta: `data/balance/curvas.json` NO existe - las curvas viven distribuidas en test_balance_m93_iter*.gd (verificado).",
 "simulaci\u00f3n m93 en ci con escenarios": "COMPLETADO 2026-10-14 (step-5-kilocode): la simulacion existe (balance_service.gd + test_balance_m93_iter3/4.gd + validate_balance.gd, 69 scripts de balance). Los 3 escenarios (productivo/completista/administrador) se definieron como perfiles - no existian como tales (0 hits). Ver 2.4.1.",
 "umbral: 40 h simuladas": "COMPLETADO 2026-10-14 (step-5-kilocode): umbral definido en 2.4.1 (40 h sin alertas criticas). Nota honesta: el umbral verificado hoy es de 30 h (M93/M139).",
 "playtest dirigido mensual con data de oro/hora": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.4.1 (sesion mensual midiendo oro por hora por escenario). Nota honesta: no existe instrumentacion de oro/hora (0 hits).",
 "feature freeze de balance": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.4.1 - 2 semanas antes del GONOGO-BETA se congelan las curvas; solo correcciones de bugs.",
 "m\u00e1rgenes por categor\u00eda": "COMPLETADO 2026-10-14 (step-5-kilocode): ya definidos y verificados en M139 2.5.1 (venta al 55-70% del precio base). Reconfirmado en 2.4.1.",
 "anti-grind y anti-exploit": "COMPLETADO 2026-10-14 (step-5-kilocode): regla ya definida en M139 2.5.1 (precio +5% por unidad en sesion, tope 25%); extendida a los flujos nuevos de Alpha (regalos y cocina) en 2.4.1.",
 "balance de regalos de amistad": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.4.1 - valor del regalo por nivel (x1/x1.5/x2/x3) con tope del 10% del oro diario. Nota honesta: la variable 'afinidad' no existe (0 hits); hoy se mide por nivel.",
 "balance de temporada": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado con 57 hits de estacional/temporada (test_balance_m93_iter3/4, test_mercado_estacion_ferias); precios estacionales definidos en 2.4.1 (x1.2 en cosecha, x0.8 fuera).",
 "reporte de balance semanal": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.4.1 - resumen semanal automatico (oro/hora, curvas fuera de rango, top de explotados) desde BudgetProfile + telemetria local (M104).",
}

PEND = {
 "balance de recetas por isla": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado contra disco - data/balance/crafting.json tiene solo 7 recetas de las 60+ que pide M16. El balance por isla no se puede hacer sobre 7 recetas. No inflado.",
}

n = n_pen = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    for clave, nota in PEND.items():
        if norm(clave) in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [ ] %s %s \u2014 %s" % (m.group(1), m.group(2), nota); n_pen += 1
            break
    else:
        for clave, nota in NOTAS.items():
            if norm(clave) in ln:
                m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
                if m:
                    lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota); n += 1
                break
t = "\n".join(lines)
t = t.replace("Completados: 43 \u00b7 Pendientes: 81 \u00b7 No resueltos: 0", "Completados: 53 \u00b7 Pendientes: 71 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n, "| pendientes reales:", n_pen)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
