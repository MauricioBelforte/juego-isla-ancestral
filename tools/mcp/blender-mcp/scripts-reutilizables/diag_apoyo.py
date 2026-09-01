#!/usr/bin/env python3
"""
diag_apoyo.py — M166 · diagnostico fino de apoyo, objeto por objeto.

Complementa a `auditar_flotantes.py`: ademas del z_min reporta CUANTOS
vertices tocan la arena y que superficie (footprint XY) cubre el apoyo.
Es la unica forma de detectar **E-50 (apoyo puntual en domo)**: un huso
apoyado en su vertice da z_min = 0.045 (numerico "OK") pero toca=1 y
footprint 0x0, es decir, visualmente FLOTA.

Criterio de lectura:
    toca=1 y fp=0.000x0.000  -> E-50, apoyo puntual. Hay que aplanar.
    toca>=3 y fp > 0.05      -> apoyo real, OK.
    z_min lejos de 0.045     -> E-12, flota o esta hundido.

Uso:
    python diag_apoyo.py 15-Recursos/veta_hierro_lowpoly.blend [...]
    python diag_apoyo.py $(ls 15-Recursos/*_lowpoly_media.blend)

Corre DENTRO de Blender por socket (import bpy), asi que necesita la GUI.
"""
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
obs = [o for o in bpy.context.scene.objects
       if o.type == 'MESH' and o.name.startswith('SM_')]
print('ARCHIVO|%s' % bpy.path.basename(bpy.data.filepath))
print('GRUPO|%d' % len(obs))
for o in obs:
    co = [o.matrix_world @ v.co for v in o.data.vertices]
    zs = [p.z for p in co]
    zmin = min(zs)
    zmax = max(zs)
    nv = len(zs)
    # vertices que tocan: dentro de 5 mm del minimo
    toc = sum(1 for z in zs if z <= zmin + 0.005)
    # footprint XY de los vertices que tocan
    pt = [p for p in co if p.z <= zmin + 0.005]
    fx = max(p.x for p in pt) - min(p.x for p in pt) if pt else 0.0
    fy = max(p.y for p in pt) - min(p.y for p in pt) if pt else 0.0
    print('OBJ|%s|nv=%d|zmin=%.4f|zmax=%.4f|toca=%d|fp=%.3fx%.3f'
          % (o.name, nv, zmin, zmax, toc, fx, fy))
"""


def main():
    args = sys.argv[1:]
    for rel in args:
        ruta = os.path.join(DIR_BLEND, rel.replace('/', os.sep))
        if not os.path.exists(ruta):
            print('NO EXISTE: %s' % ruta)
            continue
        rf = ruta.replace('\\', '/')
        code = PLANTILLA.replace('@@RUTA@@', rf)
        r = blender_command('execute_code', {'code': code}, timeout=90)
        if r.get('status') != 'success':
            print('%s -> ERROR %s' % (rel, str(r)[:160]))
            continue
        salida = r.get('result', {}).get('result', '') or ''
        for l in salida.splitlines():
            l = l.strip()
            if not l:
                continue
            if l.startswith('ARCHIVO|'):
                print('\n=== %s ===' % l.split('|')[1])
            elif l.startswith('OBJ|'):
                p = l.split('|')
                print('  %-38s %s  z %s..%s  tocando=%s  footprint=%s'
                      % (p[1], p[2], p[3], p[4], p[5], p[6]))


if __name__ == '__main__':
    main()
