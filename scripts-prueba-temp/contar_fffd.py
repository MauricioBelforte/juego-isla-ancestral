# -*- coding: utf-8 -*-
import io, os

raiz = "game/isla-ancestral/scripts"
fffd = []
moji = []
for dirpath, dirnames, filenames in os.walk(raiz):
    for fn in filenames:
        if not fn.endswith((".gd", ".tscn", ".tres", ".cfg", ".md", ".gdshader", ".import")):
            continue
        p = os.path.join(dirpath, fn)
        try:
            with io.open(p, "r", encoding="utf-8") as f:
                t = f.read()
        except Exception:
            continue
        n = t.count("\ufffd")
        if n > 0:
            fffd.append((p.replace("\\", "/"), n))

print("archivos con U+FFFD literal (IRREVERSIBLE: fix_encoding NO puede repararlo):", len(fffd))
for p, n in sorted(fffd, key=lambda kv: -kv[1]):
    print("  {0:4d}  {1}".format(n, p))
