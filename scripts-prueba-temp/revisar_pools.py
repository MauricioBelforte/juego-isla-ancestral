# -*- coding: utf-8 -*-
import io, os, re

base = "Mensajes entre modelos"
canales = sorted([d for d in os.listdir(base) if os.path.isdir(os.path.join(base, d)) and d != "RESUELTOS"])

for c in canales:
    d = os.path.join(base, c)
    mds = [f for f in os.listdir(d) if f.endswith(".md")]
    usados = set()
    for f in mds:
        m = re.match(r"^(\d+)-", f)
        if m:
            usados.add(int(m.group(1)))
    pp = os.path.join(d, "NUMEROS_DISPONIBLES.txt")
    if not os.path.exists(pp):
        if usados:
            print("%-28s SIN POOL (max_usado=%d)" % (c, max(usados)))
        continue
    with io.open(pp, encoding="utf-8") as f:
        raw = [l.strip() for l in f.read().split("\n") if l.strip()]
    nums = [int(l) for l in raw if re.match(r"^\d+$", l)]
    malos = [l for l in raw if not re.match(r"^\d+$", l)]
    if malos:
        print("%-28s POOL CON LINEAS NO NUMERICAS: %s" % (c, malos[:5]))
    if not nums:
        print("%-28s POOL VACIO (max_usado=%s)" % (c, max(usados) if usados else "-"))
        continue
    max_usado = max(usados) if usados else 0
    min_p, max_p = min(nums), max(nums)
    contiguo = (nums == list(range(nums[0], nums[-1] + 1)))
    arranca_bien = (min_p == max_usado + 1)
    fugas = sorted(n for n in usados if n in set(nums))
    if contiguo and arranca_bien and not fugas:
        print("%-28s OK   usados<=%-4d pool %d..%d contiguo (%d num)" % (c, max_usado, min_p, max_p, len(nums)))
    else:
        motivos = []
        if not arranca_bien: motivos.append("arranca en %d, deberia %d" % (min_p, max_usado + 1))
        if not contiguo: motivos.append("no contiguo")
        if fugas: motivos.append("fugas %s" % fugas[:8])
        print("%-28s FALLA usados<=%-4d pool %d..%d (%d num) :: %s" % (c, max_usado, min_p, max_p, len(nums), "; ".join(motivos)))
