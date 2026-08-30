#!/usr/bin/env python3
# diagnosticar_pose.py — Mide el bounding box mundial de los SM_ de uno o mas
# blends e imprime una tabla. Sirve para decidir que rotacion aplicar a un asset
# que esta tumbado (largo en X/Y, corto en Z) en vez de parado (largo en Z).
#
# Uso:
#   python diagnosticar_pose.py 13-Herramientas antorcha_mano_lowpoly
#   python diagnosticar_pose.py 13-Herramientas antorcha_mano_lowpoly pico_hierro_lowpoly
#   python diagnosticar_pose.py --todos            # lista armada de sospechosos
#
# Para cada nombre prueba las tres variantes: sin sufijo (source), _media, _baja.
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

RAIZ = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
DIR_BLEND = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp')

SOSPECHOSOS = [
    ('13-Herramientas', 'antorcha_mano_lowpoly'),
    ('13-Herramientas', 'pico_hierro_lowpoly'),
    ('13-Herramientas', 'pico_piedra_lowpoly'),
    ('16-Crafting', 'hacha_piedra_lowpoly'),
    ('16-Crafting', 'lingote_metal_lowpoly'),
    ('16-Crafting', 'tablon_madera_lowpoly'),
    ('15-Recursos', 'veta_hierro_lowpoly'),
    ('15-Recursos', 'nido_cocos_lowpoly'),
    ('15-Recursos', 'monton_ramas_lowpoly'),
    ('15-Recursos', 'piedra_afilar_lowpoly'),
    ('45-Arte3D', 'concha_mar_lowpoly'),
    ('45-Arte3D', 'estrella_mar_lowpoly'),
    ('40-Infraestructura', 'bote_pesca_lowpoly'),
    ('50-Vegetacion', 'helecho_chico_lowpoly'),
    ('50-Vegetacion', 'canas_bambu_lowpoly'),
]

PLANTILLA = """
import bpy
from mathutils import Vector
bpy.context.view_layer.update()
obs = [o for o in bpy.context.scene.objects
       if o.type == 'MESH' and o.name.startswith('SM_')]
if not obs:
    print('SIN_SM')
else:
    def wb(o):
        return [o.matrix_world @ Vector(c) for c in o.bound_box]
    pts = []
    for o in obs:
        pts.extend(wb(o))
    xs = [p.x for p in pts]; ys = [p.y for p in pts]; zs = [p.z for p in pts]
    mnx, mxx = min(xs), max(xs)
    mny, mxy = min(ys), max(ys)
    mnz, mxz = min(zs), max(zs)
    dx, dy, dz = mxx - mnx, mxy - mny, mxz - mnz
    print('DIM|%.4f|%.4f|%.4f|zmin=%.4f|n=%d' % (dx, dy, dz, mnz, len(obs)))
    for o in obs:
        p = wb(o)
        ox = [q.x for q in p]; oy = [q.y for q in p]; oz = [q.z for q in p]
        print('  OBJ|%s|%.3f|%.3f|%.3f|zmin=%.4f' % (
            o.name[:34], max(ox)-min(ox), max(oy)-min(oy), max(oz)-min(oz), min(oz)))
"""


def medir(modulo, nombre):
    """Abre cada variante y devuelve (variante, dx, dy, dz, zmin, n, objs)."""
    out = []
    for variante in ['', '_media', '_baja']:
        blend = nombre + variante + '.blend'
        ruta = os.path.join(DIR_BLEND, modulo, blend)
        if not os.path.exists(ruta):
            continue
        rf = ruta.replace('\\', '/')
        code = ('import bpy\n'
                'bpy.ops.wm.open_mainfile(filepath="%s")\n' % rf) + PLANTILLA
        r = blender_command('execute_code', {'code': code}, timeout=60)
        if r.get('status') != 'success':
            out.append((variante or 'source', None, None, None, None, 0, []))
            continue
        salida = r.get('result', {}).get('result', '') or ''
        lineas = [l.strip() for l in salida.splitlines() if l.strip()]
        dims = None
        objs = []
        for l in lineas:
            if l.startswith('DIM|'):
                p = l.split('|')
                # formato: DIM|dx|dy|dz|zmin=..|n=..
                dims = (float(p[1]), float(p[2]), float(p[3]),
                        float(p[4].replace('zmin=', '')),
                        int(p[5].replace('n=', '')))
            elif l.startswith('OBJ|'):  # strip() ya quito la indentacion
                p = l.split('|')
                objs.append((p[1], float(p[2]), float(p[3]), float(p[4]),
                             float(p[5].replace('zmin=', ''))))
        if dims is None:
            out.append((variante or 'source', None, None, None, None, 0, []))
            continue
        out.append((variante or 'source', dims[0], dims[1], dims[2], dims[3],
                    dims[4], objs))
    return out


DETALLE = '--detalle' in sys.argv
if DETALLE:
    sys.argv.remove('--detalle')


def main():
    if len(sys.argv) >= 3 and sys.argv[1] != '--todos':
        modulo = sys.argv[1]
        nombres = sys.argv[2:]
    elif len(sys.argv) == 2 and sys.argv[1] == '--todos':
        modulo = None
        nombres = None
    else:
        print(__doc__)
        sys.exit(1)

    lista = [(modulo, n) for n in nombres] if modulo else SOSPECHOSOS

    print('%-22s %-26s %-8s %7s %7s %7s %8s %s' % (
        'modulo', 'asset', 'variante', 'dx', 'dy', 'dz', 'z_min', 'pose'))
    print('-' * 100)
    for mod, nom in lista:
        for (variante, dx, dy, dz, zmin, n, objs) in medir(mod, nom):
            if dx is None:
                print('%-22s %-26s %-8s %7s %7s %7s %8s %s' % (
                    mod, nom, variante, '-', '-', '-', '-', '(sin SM_ o error)'))
                continue
            # pose: si el eje mas largo es Z esta parado; si es X o Y esta tumbado
            mas_largo = max(dx, dy, dz)
            if mas_largo == 0:
                pose = '?'
            elif dz == mas_largo:
                pose = 'parado'
            elif dx == mas_largo:
                pose = 'tumbado-X'
            else:
                pose = 'tumbado-Y'
            marca = ''
            if pose.startswith('tumbado'):
                marca = '  <<<'
            print('%-22s %-26s %-8s %7.3f %7.3f %7.3f %8.4f %s%s' % (
                mod, nom, variante, dx, dy, dz, zmin, pose, marca))
            if DETALLE:
                for (on, ox, oy, oz, ozmin) in objs:
                    gap = ozmin - zmin
                    aviso = '  <== LEVANTADO %.3f' % gap if gap > 0.02 else ''
                    print('        %-36s dx=%.3f dy=%.3f dz=%.3f  z_min=%.4f%s' % (
                        on, ox, oy, oz, ozmin, aviso))


if __name__ == '__main__':
    main()
