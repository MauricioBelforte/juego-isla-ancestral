# -*- coding: utf-8 -*-
import io, os, re, glob

base = "Mensajes entre modelos"
canales = sorted([d for d in os.listdir(base) if os.path.isdir(os.path.join(base, d)) and d not in ("RESUELTOS",)])
print("canales:", len(canales))
print("")

for c in canales:
    d = os.path.join(base, c)
    mds = [f for f in os.listdir(d) if f.endswith(".md")]
    # numeros usados
    usados = {}
    sin_num = []
    for f in mds:
        m = re.match(r"^(\d+)-", f)
        if m:
            n = int(m.group(1))
            usados.setdefault(n, []).append(f)
        else:
            sin_num.append(f)
    # pool
    pool = []
    pp = os.path.join(d, "NUMEROS_DISPONIBLES.txt")
    if os.path.exists(pp):
        with io.open(pp, encoding="utf-8") as fh:
            pool = [int(x) for x in fh.read().split() if x.strip().isdigit()]
    pool_set = set(pool)
    # duplicados de numero
    dups = {n: fs for n, fs in usados.items() if len(fs) > 1}
    # fugas: numero en pool que ya tiene archivo
    fugas = sorted(n for n in usados if n in pool_set)
    # usados fuera del rango "esperado": mayor usado vs mayor pool
    max_usado = max(usados) if usados else 0
    max_pool = max(pool) if pool else 0
    min_pool = min(pool) if pool else 0
    # sospechosos: usados > max_pool + 5 (muy por encima del techo del pool)
    techo = max_pool + 5
    above = sorted(n for n in usados if n > techo)
    # faltantes (huecos) dentro de 1..max_usado
    huecos = [n for n in range(1, max_usado + 1) if n not in usados]

    problemas = []
    if sin_num: problemas.append("SIN-NUM:%d" % len(sin_num))
    if dups: problemas.append("DUPS:%s" % sorted(dups))
    if fugas: problemas.append("FUGAS-POOL:%s" % fugas[:12])
    if above: problemas.append("ENCIMA-TECHO:%s" % above[:12])
    print("== {0} :: msgs={1} pool={2} (min {3} max {4}) max_usado={5}".format(
        c, len(mds), len(pool), min_pool, max_pool, max_usado))
    if problemas:
        print("   PROBLEMAS:", " | ".join(problemas))
        for f in sin_num[:5]:
            print("     sin-num:", f)
        for n in above[:8]:
            for f in usados[n][:2]:
                print("     encima:", f)
    else:
        print("   OK (solo huecos historicos: %d)" % len(huecos))
