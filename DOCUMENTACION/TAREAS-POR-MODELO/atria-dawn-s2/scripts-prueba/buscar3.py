# -*- coding: utf-8 -*-
import os
ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
NOMBRES = ["thread_pool.gd", "game_state.gd", "voxel_world.gd"]
for dp, dn, fn in os.walk(os.path.join(ROOT, "game")):
    for f in fn:
        if f in NOMBRES:
            print(os.path.relpath(os.path.join(dp, f), ROOT))
