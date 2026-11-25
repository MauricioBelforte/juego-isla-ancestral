# -*- coding: utf-8 -*-
# b62 premise scan: list pending [ ] items in the 10 M01-derived module checklists
import os, re, io

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION"

mods = [
    ("T62-01", "M12 Herramientas", "13-Herramientas"),
    ("T62-02", "M16 Construccion", "17-Construccion"),
    ("T62-03", "M36 Museos", "37-Museos-Y-Colecciones"),
    ("T62-04", "M39 Infraestructura", "40-Infraestructura"),
    ("T62-05", "M44 Arte-3D", "45-Arte-3D"),
    ("T62-06", "M50 Agua", "51-Agua"),
    ("T62-07", "M58 Guardado", "59-Guardado"),
    ("T62-08", "M66 Vehiculos", "67-Vehiculos"),
    ("T62-09", "M68 Fast-Travel", "69-Fast-Travel"),
    ("T62-10", "M108 Herramientas-Internas", "109-Herramientas-Internas"),
]

rx_open = re.compile(r"^\s*-?\s*\[ \]", re.M)
out = []
for tid, name, folder in mods:
    path = os.path.join(ROOT, folder, "plan-actual", "05-Checklist.md")
    if not os.path.isfile(path):
        out.append("%s %s -> NO FILE %s" % (tid, name, path))
        continue
    text = io.open(path, encoding="utf-8", errors="replace").read()
    lines = text.splitlines()
    hits = [(i + 1, l) for i, l in enumerate(lines) if re.match(r"^\s*-?\s*\[ \]", l)]
    out.append("%s %s [%s] real_[ ]=%d, [x]=%d, [?]=%d" % (
        tid, name, folder, len(hits),
        len(re.findall(r"^\s*-?\s*\[x\]", text, re.M)),
        len(re.findall(r"^\s*-?\s*\[\?\]", text, re.M))))
    for n, l in hits[:20]:
        out.append("   L%d %s" % (n, l[:400]))
    if len(hits) > 20:
        out.append("   ... %d more" % (len(hits) - 20))

print("\n".join(out))
