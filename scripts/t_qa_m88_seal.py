# -*- coding: utf-8 -*-
import re
P = "CHECKLIST-GLOBAL.md"
d = open(P, "rb").read()
anchor = b"QA 21.8; log 1376"
i = d.find(anchor)
assert i >= 0, "anchor not found"
end = i + len(anchor)
seal = (
    " -- QA §21.8 agnes (Kilo Code, 2026-10-06) SELLADO: verificador!=autor mimo; "
    "174/11/0 verificado (coincide 174/185); 3 suites 76 checks 0 fallos "
    "(test_fonts_m88 11/0 + test_fuentes_binarias_bug042 22/0 + test_fuentes_reales_m88 43/0, EXIT 0); "
    "11 [?] = bloqueos EXTERNOS reales (M154 vision caido, Nunito-Light/Medium dueño humano, "
    "M90 no existe, prueba 1280x720/1366x768 dueño M58/M53); 0 falsos-cierres en los 174 [x]. "
    "Estado queda 🟡 (DoD: 11 [?])."
).encode("utf-8")
d = d[:end] + seal + d[end:]
open(P, "wb").write(d)
v = open(P, "rb").read()
print("seal en M88 GLOBAL:", "QA §21.8 agnes (Kilo Code, 2026-10-06) SELLADO" in v.decode("utf-8"))
for L in v.decode("utf-8").split("\n"):
    if re.match(r"^\|\s*88\s*\|", L):
        c = re.split(r"(?<!\\)\|", L)
        print("M88 Estado:", "".join(c[3]).strip(), "| Progreso:", "".join(c[4]).strip())
        break
print("GLOBAL EOL: CRLF=%d CR=%d LF=%d" % (
    v.count(b"\r\n"), v.count(b"\r") - v.count(b"\r\n"), v.count(b"\n") - v.count(b"\r\n")))
