# -*- coding: utf-8 -*-
import io, re
p = "Mensajes entre modelos/step-5-kilocode/288-2026-10-14_02-40-00-step-5-kilocode-a-step-5-kilocode-m27-auditada-completa-recreado-log1819.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")
pat = re.compile("\u00c3[\u0080-\u00bf]|\u00c2[\u00a0-\u00bf]|\u00e2\u20ac|\u00e2[\u0080-\u0093]|\ufffd")
for i, l in enumerate(lines):
    if pat.search(l):
        print("L%d: %s" % (i+1, ascii(l)))
