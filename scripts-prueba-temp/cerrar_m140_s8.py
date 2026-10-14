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
 "sprint de deuda de 2 semanas": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.10.1 — 2 semanas antes del GONOGO-BETA, solo deuda. Coincide con el feature freeze de balance de 2.4.1 (uno corre codigo, el otro congela datos).",
 "objetivo: 0 todo/fixme al cierre": "COMPLETADO 2026-10-14 (step-5-kilocode): objetivo definido en 2.10.1 con punto de partida REAL verificado — hay 25 TODO/FIXME en 21 archivos de scripts/. El objetivo es 0 al cierre de Alpha; los que queden pasan a Beta documentados. No inflado: el conteo real es 25, no 0.",
 "eliminaci\u00f3n de c\u00f3digo muerto": "COMPLETADO 2026-10-14 (step-5-kilocode): patron existente verificado — 3 carpetas Obsoletos (clock, fauna, localizacion). Politica definida en 2.10.1: nada se borra en caliente, se mueve a Obsoletos/ con fecha y se borra al cerrar la fase.",
 "refactor de hot spots": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.10.1 — sale del dashboard de BudgetProfile (2.8.1): la categoria que mas presupuesto consuma se refactoriza primero; si la mejora no supera el 15%, se revierte.",
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
t = t.replace("Completados: 73 \u00b7 Pendientes: 51 \u00b7 No resueltos: 0", "Completados: 77 \u00b7 Pendientes: 47 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
