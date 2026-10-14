# -*- coding: utf-8 -*-
import io, os, re, glob
libs = glob.glob("game/isla-ancestral/**/jugador_lib.tres", recursive=True)
for lib in libs:
    t = io.open(lib, encoding="utf-8").read()
    names = re.findall(r'resource_name = "([^"]+)"', t)
    print(lib, "->", len(names), "animaciones")
    for n in names[:14]:
        print("   -", n)
