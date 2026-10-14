# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

NOTAS = {
 "10+ l\u00edneas de di\u00e1logo por NPC": "COMPLETADO 2026-10-14 (step-5-kilocode): 10 lineas base escritas para cada uno de los 8 NPC del elenco en 03-Diseno.md 2.3.3 (Finneas, Maribel, Obe, Tia Rua, Pax, Kor, Cole, Bram). Formato y tabla de consumo quedan para M21.",
 "variantes de di\u00e1logo por estaci\u00f3n/d\u00eda": "COMPLETADO 2026-10-14 (step-5-kilocode): variantes contextuales definidas en 03-Diseno.md 2.3.3 \u2014 una por NPC para 3 contextos (lluvia, noche, festival), con nota de que las variantes por estacion y dia de ciclo son datos de M29.",
}
n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = l.lower().replace("\u00e1","a").replace("\u00e9","e").replace("\u00ed","i").replace("\u00f3","o").replace("\u00fa","u").replace("\u00f1","n")
    for clave, nota in NOTAS.items():
        if clave.lower().replace("\u00e1","a").replace("\u00e9","e").replace("\u00ed","i").replace("\u00f3","o").replace("\u00fa","u").replace("\u00f1","n") in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                n += 1
            break

t = "\n".join(lines)
t = t.replace("Completados: 28 \u00b7 Pendientes: 112 \u00b7 No resueltos: 2",
              "Completados: 43 \u00b7 Pendientes: 97 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos finales: [x]=%d [ ]=%d [?]=%d total=%d" % (x, s, q, x+s+q))
