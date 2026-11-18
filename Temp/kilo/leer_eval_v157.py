# -*- coding: utf-8 -*-
import io, os, glob
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
cands = glob.glob(os.path.join(root, r"Mensajes entre modelos\**\evaluacion_informes*"), recursive=True)
print("RUTAS:", cands)
for p in cands:
    t = io.open(p, encoding="utf-8").read()
    print("=" * 60)
    print("ARCHIVO:", os.path.relpath(p, root))
    print("BYTES:", len(t.encode("utf-8")))
    print(t)
