# -*- coding: utf-8 -*-
import io, re

files = [
 "game/isla-ancestral/scripts/houses/house_interior.gd",
 "game/isla-ancestral/scripts/houses/test_m18_sistemas_s2.gd",
 "scripts/t_m37_mark.py",
]
pat = re.compile(u"[\u00c0-\u00c3\u00e2\u00ef\u00c2][\u0080-\u00bf\u2013-\u201e]|[\u00c3][\u0080-\u00bf]|[\u00c2][\u0080-\u00bf]")
for p in files:
    with io.open(p, "r", encoding="utf-8") as f:
        lines = f.read().split("\n")
    hits = []
    for i, l in enumerate(lines):
        if pat.search(l):
            hits.append((i + 1, l))
    print("==", p, "==", len(hits), "lineas con marcadores")
    for n, l in hits[:6]:
        print("   L{0}: {1}".format(n, ascii(l.strip()[:100])))
