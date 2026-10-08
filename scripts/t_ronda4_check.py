# -*- coding: utf-8 -*-
import re, os, glob
# Los 2 "casi-cerrados" a escrutar por inflacion: M126 (101/0/0) + M106 (194/12/0)
for mid in ["126-Marketing-Legal", "106-Seguridad"]:
    base = None
    for d in os.listdir("DOCUMENTACION"):
        if d.startswith(mid.split("-")[0] + "-"):
            base = "DOCUMENTACION/" + d + "/plan-actual"; break
    c = open(base + "/05-Checklist.md", "rb").read().decode("utf-8")
    xs = [re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I).group(1) for L in c.splitlines() if re.match(r"^\s*[-*]\s*\[x\]", L, re.I)]
    impl = [x for x in xs if re.search(r"implement|crear|añadir|añadid|generar|arreglar|fix", x, re.I)]
    print("=== %s: %d [x] total, %d 'Implementar/Crear'-tipo ===" % (mid, len(xs), len(impl)))
    for i in impl[:6]:
        print("   *", i[:80])
# los artefactos ausentes
for a in ["marketing_legal_review.md", "BrandValidator.gd"]:
    print("%s -> %s" % (a, [x.split('isla-ancestral/')[-1] for x in glob.glob('game/isla-ancestral/**/'+a, recursive=True)] + [x.split('DOCUMENTACION/')[-1] for x in glob.glob('DOCUMENTACION/**/'+a, recursive=True)]))
