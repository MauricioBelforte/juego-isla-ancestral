# -*- coding: utf-8 -*-
import io, os, re

base = "Mensajes entre modelos"
FALLAS = ["DeepSeek-V4.1-Flash", "Ling-3.1-Flash", "Step-5-WorkBuddy",
          "atria-dawn", "atria-dawn-s2", "atria-dawn-s3", "step-5-kilocode"]

for c in FALLAS:
    d = os.path.join(base, c)
    usados = set()
    for f in os.listdir(d):
        if f.endswith(".md"):
            m = re.match(r"^(\d+)-", f)
            if m:
                usados.add(int(m.group(1)))
    pp = os.path.join(d, "NUMEROS_DISPONIBLES.txt")
    with io.open(pp, encoding="utf-8") as f:
        nums_viejos = [int(l) for l in f.read().split() if l.strip().isdigit()]
    techo = max(nums_viejos) if nums_viejos else max(usados) + 100
    max_usado = max(usados) if usados else 0
    nuevo = list(range(max_usado + 1, techo + 1))
    # doble verificacion: ninguno debe tener archivo
    conflicto = [n for n in nuevo if n in usados]
    if conflicto:
        print("%-24s CONFLICTO, no toco: %s" % (c, conflicto[:10]))
        continue
    with io.open(pp, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(str(n) for n in nuevo) + "\n")
    print("%-24s %d..%d (%d) -> %d..%d (%d) contiguo desde max_usado+1" % (
        c, min(nums_viejos), max(nums_viejos), len(nums_viejos),
        nuevo[0], nuevo[-1], len(nuevo)))
