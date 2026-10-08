# -*- coding: utf-8 -*-
import re
files = [
 "game/isla-ancestral/scripts/backup/test_backup_m107.gd",
 "game/isla-ancestral/scripts/debug/test_debug_m110.gd",
 "game/isla-ancestral/scripts/legal/test_legal_m78_v2.gd",
]
note = ('# NOTA (agnes-3-flash, 2026-10-08, BUG-121): los SCRIPT ERROR "instantiate" sobre null que se ven\n'
        '# al correr este test en headless vienen del AUTOLOAD DE FAUNA (tortuga/cangrejo/jabali _instanciar_modelo:\n'
        '# load(.glb) devuelve null en headless y no hay null-guard antes de .instantiate()), NO de este test.\n'
        '# Los checks de modulo de ESTE test pasan. Fix = null-guard en M30-fauna (dueño lo asigna el director).\n')
for f in files:
    c = open(f, "rb").read().decode("utf-8")
    if "BUG-121" in c:
        print(f.split("/")[-1], "ya trae el puntero")
        continue
    # insertar la nota antes de 'extends SceneTree'
    idx = c.find("extends SceneTree")
    assert idx >= 0, "extends no encontrado en " + f
    c = c[:idx] + note + c[idx:]
    open(f, "wb").write(c.encode("utf-8"))
    print("puntero BUG-121 agregado a", f.split("/")[-1])
