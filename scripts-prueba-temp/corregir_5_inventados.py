# -*- coding: utf-8 -*-
import io, os, re

# (canal, numero_viejo, numero_nuevo)
PLAN = [
  ("DeepSeek-V4.1-Flash", 499, 232),
  ("Hy3", 498, 199),
  ("agnes-3-flash", 499, 504),
  ("agnes-3-flash", 498, 505),
  ("agnes-3-flash", 497, 506),
]

hechos = []
for canal, viejo, nuevo in PLAN:
    d = os.path.join("Mensajes entre modelos", canal)
    arch = [f for f in os.listdir(d) if f.startswith("%d-" % viejo) and f.endswith(".md")]
    if len(arch) != 1:
        print("AVISO %s %d: %d archivos encontrados" % (canal, viejo, len(arch)))
        continue
    src = os.path.join(d, arch[0])
    dst_name = "%d-%s" % (nuevo, arch[0].split("-", 1)[1])
    dst = os.path.join(d, dst_name)
    if os.path.exists(dst):
        print("COLISION: ya existe", dst_name, "-> aborto este")
        continue
    os.rename(src, dst)
    hechos.append((canal, viejo, nuevo, dst))
    # header interno
    with io.open(dst, encoding="utf-8") as f:
        t = f.read()
    t2 = re.sub(r"(?m)^# %d\b" % viejo, "# %d" % nuevo, t, count=1)
    if t2 != t:
        with io.open(dst, "w", encoding="utf-8", newline="\n") as f:
            f.write(t2)
    print("  %-20s %d -> %d  (header ok)" % (canal, viejo, nuevo))

# referencias cruzadas en agnes (6 archivos)
print("")
d = os.path.join("Mensajes entre modelos", "agnes-3-flash")
REFS = [("499-2026-10-14_01-10-00", "504-2026-10-14_01-10-00"),
        ("498-2026-10-14_01-20-00", "505-2026-10-14_01-20-00"),
        ("497-2026-10-14_03-10-00", "506-2026-10-14_03-10-00")]
n = 0
for f in sorted(os.listdir(d)):
    if not f.endswith(".md"):
        continue
    p = os.path.join(d, f)
    with io.open(p, encoding="utf-8") as fh:
        t = fh.read()
    orig = t
    for v, nv in REFS:
        t = t.replace(v, nv)
    if t != orig:
        with io.open(p, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(t)
        n += 1
        print("  refs actualizadas:", f[:52])
print("archivos de agnes con refs actualizadas:", n)
