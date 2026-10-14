# -*- coding: utf-8 -*-
import io, os
d = "Mensajes entre modelos/Step-5-WorkBuddy"
p = os.path.join(d, "17-2026-10-13_16-35-00-mimo-a-wb-iter5-aceptada-jolt-iter6-autorizada.md")
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")
if lines[0].startswith("# 15"):
    lines[0] = "# 17" + lines[0][4:]
    with io.open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines))
    print("17: header '# 15' -> '# 17' ->", lines[0][:40])
