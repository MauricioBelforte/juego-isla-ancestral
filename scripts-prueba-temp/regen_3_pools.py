# -*- coding: utf-8 -*-
import io, os, subprocess

d = "Mensajes entre modelos/agnes-3-flash"
v = "394-2026-10-14_01-05-00-agnes-recibido-499-listo-implementacion.md"
n = "394-2026-10-14_01-05-00-agnes-recibido-luz-verde-listo-implementacion.md"
p_v, p_n = os.path.join(d, v), os.path.join(d, n)
if os.path.exists(p_v) and not os.path.exists(p_n):
    r = subprocess.run(["git", "ls-files", "--", p_v], capture_output=True, text=True)
    if r.stdout.strip():
        r2 = subprocess.run(["git", "mv", p_v, p_n], capture_output=True, text=True)
        print("394: slug '499' -> 'luz-verde' (git mv):", "ok" if r2.returncode == 0 else r2.stderr[:60])
    else:
        os.rename(p_v, p_n)
        print("394: slug '499' -> 'luz-verde' (rename): ok")
else:
    print("394: nada que hacer")

# regenerar los 3 pools desde max_usado+1 con span 200 (mismo criterio que el director)
SPAN = 200
for canal in ("DeepSeek-V4.1-Flash", "Hy3", "agnes-3-flash"):
    d2 = os.path.join("Mensajes entre modelos", canal)
    usados = set()
    import re as _re
    for f in os.listdir(d2):
        m = _re.match(r"^(\d+)-", f)
        if m:
            usados.add(int(m.group(1)))
    mx = max(usados) if usados else 0
    nuevo = list(range(mx + 1, mx + 1 + SPAN))
    # evitar colisiones con existentes
    nuevo = [n for n in nuevo if n not in usados]
    pp = os.path.join(d2, "NUMEROS_DISPONIBLES.txt")
    with io.open(pp, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(str(x) for x in nuevo) + "\n")
    print("  %-20s max_usado=%d -> pool %d..%d (%d num)" % (canal, mx, nuevo[0], nuevo[-1], len(nuevo)))
