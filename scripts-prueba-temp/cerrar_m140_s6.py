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
 "dashboard: fps/p99": "COMPLETADO 2026-10-14 (step-5-kilocode): ya definido en M139 4.1 — panel de superposicion (F3) 100% local con FPS, p99, memoria, tiempos de carga y presupuesto por categoria, leyendo BudgetProfile + AssetProfile. Reconfirmado para Alpha en 2.8.1.",
 "gate ci de presupuestos por zona": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — validate_budget.gd (usa draw_calls) + test_budget_profile.gd + pipeline M108 como gate. Regla de M139 4.1: zona sin presupuesto declarado o fuera de techo falla la CI.",
 "presupuesto de memoria global alpha": "COMPLETADO 2026-10-14 (step-5-kilocode): preset base 1.500 MB (tabla de M62: 1.500/2.000/2.500 MB), definido en M139 4.1. Reconfirmado en 2.8.1.",
 "presupuesto de tiempos de carga/streaming": "COMPLETADO 2026-10-14 (step-5-kilocode): carga < 2 s con barra real de pantalla_carga.gd + presupuesto de ms por frame de stream_manager.gd (ambos de M139). Reconfirmado en 2.8.1.",
 "reporte semanal de rendimiento": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.8.1 — resumen semanal comparando build actual vs anterior con p99 de frame, memoria pico y tiempo de carga de la zona mas pesada, marcando tendencia.",
 "plan de acci\u00f3n ante regresiones": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.8.1 — si p99 sube > 15% o memoria pasa el presupuesto, la zona se marca fuera_de_presupuesto, se hace rollback a la ultima version OK (git tag por zona) y se abre bug en 11-BUGS.md.",
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
                lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota); n += 1
            break
t = "\n".join(lines)
t = t.replace("Completados: 58 \u00b7 Pendientes: 66 \u00b7 No resueltos: 0", "Completados: 64 \u00b7 Pendientes: 60 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
