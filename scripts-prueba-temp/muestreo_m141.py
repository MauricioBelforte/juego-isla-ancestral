# -*- coding: utf-8 -*-
import io, re, sys
sys.stdout.reconfigure(encoding="utf-8")
c = io.open("DOCUMENTACION/141-Beta/plan-actual/05-Checklist.md", encoding="utf-8").read()
sec = None
out = []
verbos = re.compile(r"Crear|Implementar|Generar|Definir|Integrar|Configurar|Construir")
for l in c.split("\n"):
    m = re.match(r"^## (\d+)\.", l)
    if m:
        sec = m.group(1)
    elif sec in ("3","4","5","7","8","9","10","11","12","13") and re.match(r"^\s*- \[x\]", l) and verbos.search(l):
        out.append("  S%-2s %s" % (sec, l.strip()[:112]))
for o in out[:22]:
    print(o)
print("  total candidatos:", len(out))
