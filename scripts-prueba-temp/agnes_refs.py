# -*- coding: utf-8 -*-
import io, os, re

d = "Mensajes entre modelos/agnes-3-flash"
# viejo -> nuevo (solo los que cambian)
MAPA = {504:395, 505:397, 506:405, 503:407, 508:408, 510:409,
        500:400, 502:401, 507:402, 509:403, 511:404, 501:406, 512:410,
        395:396, 396:398, 397:399}

# 1) referencias con fecha completa: "NNN-AAAA-MM-DD_HH-MM-SS"
for f in sorted(os.listdir(d)):
    if not f.endswith(".md"): continue
    p = os.path.join(d, f)
    with io.open(p, encoding="utf-8") as fh:
        t = fh.read()
    orig = t
    for viejo, nuevo in MAPA.items():
        t = re.sub(r"(?<![\d-])%d-(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})" % viejo,
                   lambda m, n=nuevo: "%d-%s" % (n, m.group(1)), t)
    if t != orig:
        with io.open(p, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(t)
        print("refs con fecha:", f[:48])

# 2) referencias sin fecha, tipo "395 (lote 1" / "y 500 (lote 4" / "396 (lote 2"
pares_sueltas = [("395 (lote", "396 (lote"), ("396 (lote", "398 (lote"),
                   ("397 (lote", "399 (lote"), ("500 (lote", "400 (lote")]
for f in sorted(os.listdir(d)):
    if not f.endswith(".md"): continue
    p = os.path.join(d, f)
    with io.open(p, encoding="utf-8") as fh:
        t = fh.read()
    orig = t
    for viejo, nuevo in pares_sueltas:
        t = t.replace(viejo, nuevo)
    if t != orig:
        with io.open(p, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(t)
        print("refs sueltas:", f[:48])
