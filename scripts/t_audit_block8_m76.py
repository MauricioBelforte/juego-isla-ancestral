# -*- coding: utf-8 -*-
import glob, re
g = glob.glob("DOCUMENTACION/76-*")[0] + "/plan-actual/05-Checklist.md"
d = open(g, "rb").read()
lines = d.split(b"\n")
out = []
n = 0
note = "  [Auditoria T-agnes blq8 2026-10-06: mp_contract.json AUSENTE + M76 bloqueado por producto (single-player v1, patron M77)]".encode("utf-8")
for L in lines:
    if b"[x]" in L and (b"mp_contract.json" in L or b"texto libre futuro" in L):
        L2 = L.replace(b"[x]", b"[?]", 1)
        L2 = L2.rstrip() + note
        out.append(L2)
        n += 1
    else:
        out.append(L)
open(g, "wb").write(b"\n".join(out))
c = open(g, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M76 degradados:", n, "| ahora [x]=", sum(1 for m in mk if m in ("x", "X")), "[?]=", sum(1 for m in mk if m == "?"))
# show the [?] lines
for L in c.splitlines():
    m = re.match(r"^\s*[-*]\s*\[\?\]\s*(.*)", L)
    if m:
        print("  ?", m.group(1)[:80])
