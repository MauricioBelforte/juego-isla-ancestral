# -*- coding: utf-8 -*-
import io, re
p = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION\11-BUGS.md"
lines = io.open(p, encoding="utf-8").read().split("\n")
heads = [(i, m.group(1)) for i, ln in enumerate(lines)
         for m in [re.match(r"^#{2,4}\s+(BUG-[\w\-]+)", ln)] if m]
nada, legacy, canon = [], [], []
for k, (i, bid) in enumerate(heads):
    fin = heads[k+1][0] if k+1 < len(heads) else len(lines)
    b = "\n".join(lines[i:fin])
    if "**Modelo:**" in b:
        canon.append(bid)
    elif re.search(r"\*\*Firma:\*\*|^- \*\*Firma:\*\*|\bFirma:\*\*", b) or "Firma:" in b:
        legacy.append(bid)
    else:
        nada.append((bid, i+1))
print("canonicos:", len(canon))
print("legacy (Firma: sin desglose):", len(legacy), sorted(set(legacy)))
print("SIN NINGUNA FIRMA:", len(nada))
for bid, ln in nada:
    print("  %s (linea %d)" % (bid, ln))