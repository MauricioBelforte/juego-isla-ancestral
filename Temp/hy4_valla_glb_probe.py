"""Sonda de CALIBRACION: decodifica el BIN de los 6 GLB de valla_madera.

Publica, por GLB: tris, materiales, nodos/mallas, cotas x/y/z, niveles de
coordenada por eje (redondeados a 4 decimales), esquinas apoyadas en y=0.045
y la senal de los dos brazos de la L. Reusa el decodificador ya probado de
verificar_estructura_sumergida.py (B17) para no duplicar logica.
"""
import os
import sys
from collections import Counter

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, os.path.join(
    REPO, 'tools', 'mcp', 'blender-mcp', '25-Ruinas-Templos', 'scripts'))
import verificar_estructura_sumergida as v  # noqa: E402

GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')


def puntos_glb(path):
    raw, doc, bin_, ok = v.cargar(path)
    assert ok, 'GLB ilegible %s' % path
    _, instancias = v.recorrer(doc)
    mat_por_mesh = {}
    for mi, m in instancias:
        mat_por_mesh.setdefault(mi, []).append(m)
    pts, tris = [], 0
    for mi, mesh in enumerate(doc['meshes']):
        mats = mat_por_mesh.get(mi, [v.ident()])
        for pr in mesh.get('primitives', []):
            pi = pr['attributes']['POSITION']
            pos, e = v.leer_vec(doc, bin_, pi, 'f', 3)
            assert not e and pos, e
            ai = pr.get('indices')
            if ai is None:
                count = len(pos)
            else:
                fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(
                    doc['accessors'][ai]['componentType'], 'H')
                vals, e2 = v.leer_vec(doc, bin_, ai, fmt, 1)
                assert not e2
                count = len(vals)
            tris += count // 3
            for m in mats:
                for q in pos:
                    pts.append(v.aplicar(m, q))
    return pts, tris, len(doc.get('materials', [])), len(doc['meshes']), len(doc['nodes'])


for tipo in ('recto', 'esquina'):
    for lod in ('alta', 'media', 'baja'):
        p = os.path.join(GODOT, lod,
                         '40-Infraestructura_valla_madera_%s.glb' % tipo)
        pts, tris, mats, nmesh, nnode = puntos_glb(p)
        xs = [q[0] for q in pts]
        ys = [q[1] for q in pts]
        zs = [q[2] for q in pts]
        lv = lambda eje: sorted({round(q[eje], 4) for q in pts})
        apoyo = sorted({(round(q[0], 4), round(q[2], 4)) for q in pts
                        if abs(q[1] - 0.045) < 1e-3})
        brazo_x = sum(1 for q in pts if q[0] > 0.8 and abs(q[2]) < 0.25)
        brazo_y = sum(1 for q in pts if q[2] < -0.8 and abs(q[0]) < 0.25)
        print('=== %s/%s ===' % (tipo, lod))
        print('P tris=%d mats=%d meshes=%d nodes=%d verts=%d'
              % (tris, mats, nmesh, nnode, len(pts)))
        print('P x=[%.4f..%.4f] rango=%.4f  y=[%.4f..%.4f]  z=[%.4f..%.4f] rango=%.4f'
              % (min(xs), max(xs), max(xs) - min(xs),
                 min(ys), max(ys), min(zs), max(zs), max(zs) - min(zs)))
        print('P niveles_x=%s' % lv(0))
        print('P niveles_y=%s' % lv(1))
        print('P niveles_z=%s' % lv(2))
        print('P apoyo pares(x,z) en y=0.045 = %d -> %s'
              % (len(apoyo), apoyo))
        print('P brazo_x=%d brazo_y=%d' % (brazo_x, brazo_y))
