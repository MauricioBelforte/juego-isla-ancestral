# -*- coding: utf-8 -*-
"""I-08 proxy de coste de carga .po (parse regex sobre bytes reales, ms).
No reemplaza medicion Godot (sin MCP en sesion Ling); acota el orden de magnitud."""
import io
import re
import time

total_bytes = 0
for loc in ("es", "en", "pt"):
    p = "game/isla-ancestral/locales/%s.po" % loc
    b = io.open(p, "rb").read()
    total_bytes += len(b)
    t0 = time.perf_counter()
    msgids = re.findall(r'msgid "([^"]*)"', b.decode("utf-8"))
    t1 = time.perf_counter()
    print("%s.po: %d bytes, %d msgids (regex), parse %.2f ms" % (loc, len(b), len(msgids), (t1 - t0) * 1000.0))
print("total 3 .po: %d bytes (~%.1f KB)" % (total_bytes, total_bytes / 1024.0))
print("nota: proxy Python; runtime Godot usa _parse_po linea a linea (manager L275-328), carga UNICA en _ready (L30), cache _catalogs (L21)")
