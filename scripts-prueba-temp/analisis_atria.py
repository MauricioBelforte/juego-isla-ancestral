# -*- coding: utf-8 -*-
import io, os, re, sys
sys.stdout.reconfigure(encoding="utf-8")

base = "Mensajes entre modelos"
canales = {
    "atria-dawn (deep work)": "atria-dawn",
    "atria-dawn-s2 (verificador)": "Step-5-WorkBuddy",
    "atria-dawn-s3 (estratega)": "atria-dawn-s3",
}
for etiqueta, carpeta in canales.items():
    d = os.path.join(base, carpeta)
    if not os.path.isdir(d):
        print(etiqueta, "-> NO EXISTE")
        continue
    mds = [f for f in os.listdir(d) if f.endswith(".md")]
    # clasificar por emisor segun el nombre del archivo
    de_s2 = [f for f in mds if "atria-dawn-s2" in f or "-s2-a-" in f or "-a-s2-" in f]
    print("== %s  (%d mensajes, %d firmados s2)" % (etiqueta, len(mds), len(de_s2)))
    # ultimos 4 por mtime
    mds_ord = sorted(mds, key=lambda f: os.path.getmtime(os.path.join(d, f)), reverse=True)
    for f in mds_ord[:4]:
        t = io.open(os.path.join(d, f), encoding="utf-8", errors="replace").read()
        h = t.split("\n")[0]
        print("   ", h[:88].encode("ascii", "replace").decode())
    print()
