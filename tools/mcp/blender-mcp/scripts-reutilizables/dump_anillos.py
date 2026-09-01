#!/usr/bin/env python3
# TEMPORAL - dump de vertices de un objeto ordenados por z, con anillos BFS.
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

RAIZ = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
DIR_BLEND = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp')

PLANTILLA = r"""
import bpy
bpy.ops.wm.open_mainfile(filepath="@@RUTA@@")
bpy.context.view_layer.update()

PATRON = '@@PATRON@@'
obs = [o for o in bpy.context.scene.objects
       if o.type == 'MESH' and PATRON.lower() in o.name.lower()]
for o in obs:
    world = [o.matrix_world @ v.co for v in o.data.vertices]
    ady = {}
    for e in o.data.edges:
        a, b = e.vertices[0], e.vertices[1]
        ady.setdefault(a, set()).add(b)
        ady.setdefault(b, set()).add(a)
    imin = min(range(len(world)), key=lambda i: world[i].z)
    # anillos BFS
    anillo = {imin: 0}
    frontera = [imin]
    lvl = 0
    while frontera:
        lvl += 1
        sig = []
        for n in frontera:
            for v in ady.get(n, ()):
                if v not in anillo:
                    anillo[v] = lvl
                    sig.append(v)
        frontera = sig
    print('OBJ|%s|nv=%d|zmin=%.4f|zmax=%.4f' % (
        o.name, len(world),
        min(p.z for p in world), max(p.z for p in world)))
    for i in sorted(range(len(world)), key=lambda i: world[i].z):
        r = (world[i].x ** 2 + world[i].y ** 2) ** 0.5
        print('  V|i=%d|z=%.4f|r_xy=%.3f|anillo=%d' % (
            i, world[i].z, r, anillo.get(i, -1)))
"""


def main():
    args = sys.argv[1:]
    modulo, asset, patron = args[0], args[1], args[2]
    variantes = ['source', 'media', 'baja']
    if '--variantes' in args:
        i = args.index('--variantes')
        variantes = args[i + 1].split(',')
    for variante in variantes:
        suf = '' if variante == 'source' else '_' + variante
        ruta = os.path.join(DIR_BLEND, modulo, asset + suf + '.blend')
        if not os.path.exists(ruta):
            continue
        code = (PLANTILLA.replace('@@RUTA@@', ruta.replace('\\', '/'))
                .replace('@@PATRON@@', patron))
        r = blender_command('execute_code', {'code': code}, timeout=90)
        if r.get('status') != 'success':
            print('%s ERROR %s' % (asset + suf, str(r)[:160]))
            continue
        for l in (r.get('result', {}).get('result', '') or '').splitlines():
            if l.strip():
                print(l)


if __name__ == '__main__':
    main()
