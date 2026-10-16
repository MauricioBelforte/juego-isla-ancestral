# -*- coding: utf-8 -*-
import io, os, re

base = "Mensajes entre modelos"
canales = sorted([d for d in os.listdir(base) if os.path.isdir(os.path.join(base, d)) and d != "RESUELTOS"])
NO_CANALES = {"01-QA-Cruzado-Gemini", "04-Voxel-Sin-Soporte-Web", "05-Ecosistema-Vision-Para-OpenCode", "06-M70-Conflicto-Edicion-Concurrente"}

total_prob = 0
for c in canales:
    d = os.path.join(base, c)
    mds = [f for f in os.listdir(d) if f.endswith(".md")]
    usados, cortos = {}, []
    for f in mds:
        m = re.match(r"^(\d+)-", f)
        if m:
            n = int(m.group(1)); usados.setdefault(n, []).append(f)
            # nombre sin fecha completa: NN-HH-MM-SS-
            if re.match(r"^\d+-\d{2}-\d{2}-\d{2}-", f):
                cortos.append(f)
        else:
            if not f.startswith(("BACKLOG", "ESTADO")) and c not in NO_CANALES:
                print("%-24s SIN-NUM: %s" % (c, f))
    # pool
    pp = os.path.join(d, "NUMEROS_DISPONIBLES.txt")
    pool = []
    if os.path.exists(pp):
        with io.open(pp, encoding="utf-8") as f:
            pool = [int(l) for l in f.read().split() if l.isdigit()]
    max_usado = max(usados) if usados else 0
    dups = {n: fs for n, fs in usados.items() if len(fs) > 1}
    # numeros inventados: usados muy por encima del techo del pool (o sin pool)
    techo = (max(pool) + 5) if pool else 200
    inventados = sorted(n for n in usados if n > techo)
    # fugas: en pool y con archivo
    fugas = sorted(n for n in usados if n in set(pool))
    # pool no arranca en max_usado+1
    pool_mal = pool and (min(pool) != max_usado + 1)
    probs = []
    if inventados: probs.append("INVENTADOS %s" % inventados)
    if dups: probs.append("DUPS %s" % sorted(dups))
    if fugas: probs.append("FUGAS %s" % fugas)
    if pool_mal: probs.append("POOL arranca en %d, deberia %d" % (min(pool), max_usado + 1))
    if cortos: probs.append("NOMBRE-CORTO %s" % [f[:14] for f in cortos])
    if probs:
        total_prob += 1
        print("%-24s %s" % (c, " | ".join(probs)))
print("")
print("canales con problemas:", total_prob, "de", len(canales))
