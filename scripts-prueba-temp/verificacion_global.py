# -*- coding: utf-8 -*-
import io, os, re

base = "Mensajes entre modelos"
canales = sorted([d for d in os.listdir(base) if os.path.isdir(os.path.join(base, d)) and d != "RESUELTOS"])
TEMAS = {"01-QA-Cruzado-Gemini", "04-Voxel-Sin-Soporte-Web", "05-Ecosistema-Vision-Para-OpenCode", "06-M70-Conflicto-Edicion-Concurrente"}
ok = 0
for c in canales:
    d = os.path.join(base, c)
    usados, cortos = set(), []
    for f in os.listdir(d):
        if not f.endswith(".md"): continue
        m = re.match(r"^(\d+)-", f)
        if m:
            n = int(m.group(1)); usados.add(n)
            if re.match(r"^\d+-\d{2}-\d{2}-\d{2}-", f): cortos.append(f)
    pp = os.path.join(d, "NUMEROS_DISPONIBLES.txt")
    if c in TEMAS:
        print("%-24s (carpeta de tema: no aplica)" % c); continue
    pool = []
    if os.path.exists(pp):
        with io.open(pp, encoding="utf-8") as f:
            pool = [int(l) for l in f.read().split() if l.isdigit()]
    mx = max(usados) if usados else 0
    probs = []
    if pool:
        if min(pool) != mx + 1: probs.append("pool arranca en %d, deberia %d" % (min(pool), mx+1))
        if pool != list(range(pool[0], pool[-1]+1)): probs.append("pool no contiguo")
        fugas = [n for n in usados if n in set(pool)]
        if fugas: probs.append("fugas %s" % fugas)
    else:
        probs.append("sin pool")
    if cortos: probs.append("nombres cortos %d" % len(cortos))
    if not probs:
        ok += 1
        print("%-24s OK   usados<=%-4d pool %d..%d" % (c, mx, pool[0], pool[-1]))
    else:
        print("%-24s FALLA usados<=%-4d %s" % (c, mx, " | ".join(probs)))
print("")
print("canales OK:", ok)
