# -*- coding: utf-8 -*-
import os, re, io
BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION\TAREAS-POR-MODELO\HY4 Flash\BACKLOGS"
tot = {"x":0, " ":0, "?":0}
files = 0
per = []
rx = re.compile(r"^\s*- \[([ x?])\]")
for fn in sorted(os.listdir(BASE)):
    p = os.path.join(BASE, fn)
    if not os.path.isfile(p) or not fn.lower().endswith(".md"): continue
    with io.open(p, encoding="utf-8", errors="replace") as f:
        c = {"x":0, " ":0, "?":0}
        for line in f:
            m = rx.match(line)
            if m: c[m.group(1)] += 1
    files += 1
    for k in tot: tot[k] += c[k]
    per.append("%s %d/%d/%d" % (fn[:12], c["x"], c[" "], c["?"]))
print("backlogs=%d total [x]=%d [ ]=%d [?]=%d" % (files, tot["x"], tot[" "], tot["?"]))
print(" | ".join(per))
