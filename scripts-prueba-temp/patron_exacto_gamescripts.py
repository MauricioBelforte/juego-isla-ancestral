# -*- coding: utf-8 -*-
import io, os, re

PAT = re.compile(
    '\u00c3[\u0080-\u00bf]'
    '|\u00c2[\u00a0-\u00bf]'
    '|\u00e2\u20ac'
    '|\u00e2[\u0080-\u0093]'
    '|\u00f0'
    '|\u00ef\u00bb\u00bf'
    '|\ufffd')

# 1) marcador exacto en t_m37_mark.py
p = "scripts/t_m37_mark.py"
with io.open(p, "r", encoding="utf-8") as f:
    for i, l in enumerate(f.read().split("\n")):
        if PAT.search(l):
            print("t_m37_mark.py L{0}: {1}".format(i + 1, ascii(l.strip()[:110])))

# 2) barrido con el patron EXACTO sobre el subarbol del juego
print("")
raiz = "game/isla-ancestral/scripts"
total = 0
sucios = []
for dirpath, dirnames, filenames in os.walk(raiz):
    for fn in filenames:
        if not fn.endswith(('.md', '.gd', '.txt', '.json', '.cfg', '.py', '.godot', '.tscn', '.tres')):
            continue
        fp = os.path.join(dirpath, fn)
        total += 1
        try:
            with io.open(fp, "r", encoding="utf-8") as f:
                t = f.read()
        except Exception:
            continue
        n = len(PAT.findall(t))
        if n > 0:
            sucios.append((fp.replace("\\", "/"), n))
print("escaneados:", total, "| SUCIOS:", len(sucios))
for fp, n in sorted(sucios, key=lambda kv: -kv[1]):
    print("  {0:4d}  {1}".format(n, fp))
