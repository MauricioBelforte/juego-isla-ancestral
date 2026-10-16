# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")
target = "Documentar los 60+ \u00edtems del mundo con precio base"
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[ \]", l) and target in l:
        m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
        if m:
            lines[i] = "- [ ] %s %s \u2014 PENDIENTE REAL 2026-10-14 (step-5-kilocode): conteo verificado en disco — de 1691 items con id en data/, solo 31 tienen campo de precio. Faltan ~30 para el minimo de 60 y el catalogo completo es trabajo de M15. No inflado." % (m.group(1), m.group(2))
            print("item 60+ anotado con el hallazgo")
        break
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
