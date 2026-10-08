# -*- coding: utf-8 -*-
P = "DOCUMENTACION/11-BUGS.md"
c = open(P, "rb").read().decode("utf-8")
i = c.find("### BUG-121")
j = c.find("### BUG-104", i)
head, seg, tail = c[:i], c[i:j], c[j:]

lines = seg.split("\n")
out = []
k = 0
while k < len(lines):
    L = lines[k]
    if L.startswith("- **Estado:** [ ] Abierto"):
        out.append(
            "- **Estado:** [x] **Resuelto 2026-10-08 por agnes-3-flash (Kilo Code, canal 76).** Dueño pasa a "
            "**agnes-3-flash** (antes 'M30-fauna, a delegar'; el director autorizó el fix en los 3 NPCs). "
            "Evidencia: 3 tests re-corridos headless tras el null-guard = 0 SCRIPT ERROR `instantiate` null: "
            "M78 `test_legal_m78_v2` 60/0 EXIT 0; M107 `test_backup_m107` 28/0 EXIT 0; M110 `test_debug_m110` 18/0 EXIT 0. "
            "Hallazgo Ronda 1/2 + T-TESTS-ROTOS (canal 74). Sin commit/push (regla de la tanda).")
        k += 1
        while k < len(lines) and lines[k].startswith("  "):
            # tragó la continuación del Estado ANTES de reescribirla
            k += 1
        continue
    if "El director debe derivar el null-guard" in L:
        out.append(
            "  **FIX APLICADO por agnes-3-flash (canal 76):** null-guard en los 3 NPCs (tortuga usa "
            "`_instanciar_placeholder()`; cangrejo/jabali sin placeholder -> `return`, documentado). Runtime-safe: "
            "con gráficos `load(glb)` resuelve y el guard no se dispara; solo headless/null activa el fallback.")
        k += 1
        continue
    out.append(L)
    k += 1

seg2 = "\n".join(out)
c2 = head + seg2 + tail
open(P, "wb").write(c2.encode("utf-8"))
import re
v = open(P, "rb").read().decode("utf-8")
vi = v.find("### BUG-121"); vj = v.find("### BUG-104", vi)
print("Estado resuelto:", "[x] **Resuelto" in v[vi:vj])
print("FIX APLICADO:", "FIX APLICADO" in v[vi:vj])
print("mojibake en BUG-121:", len(re.findall(r"Ã|Â|â€", v[vi:vj])))
