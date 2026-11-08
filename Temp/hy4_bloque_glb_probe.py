#!/usr/bin/env python3
"""Sonda de calibracion: vuelca niveles de coordenadas de los 3 GLB de L28.

Reusa el decodificador YA MEDIDO de verificar_triangulos_runtime.py (B12).
Solo lectura; no muta nada. Scratch: se conserva, no se borra.
"""
import importlib.util
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
RT = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp', '18-Casas',
                  'scripts', 'verificar_triangulos_runtime.py')
spec = importlib.util.spec_from_file_location('vtr', RT)
vtr = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vtr)

GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
BASE = '25-Ruinas-Templos_bloque_tallado.glb'


def niveles(vals, tol=1e-4):
    out = []
    for v in sorted(vals):
        if not out or abs(v - out[-1][0]) > tol:
            out.append([v, 1])
        else:
            out[-1][1] += 1
    return out


def main():
    for lod in ('alta', 'media', 'baja'):
        p = os.path.join(GODOT, lod, BASE)
        raw, doc, bin_ = vtr.cargar(p)
        _, instancias = vtr.recorrer(doc)
        mat_por_mesh = {}
        for mi, m in instancias:
            mat_por_mesh.setdefault(mi, []).append(m)
        puntos = []
        for mi, mesh in enumerate(doc['meshes']):
            mats = mat_por_mesh.get(mi, [vtr.ident()])
            for pr in mesh.get('primitives', []):
                pos_i = pr['attributes']['POSITION']
                pos, e = vtr.leer_vec(doc, bin_, pos_i, 'f', 3)
                if e:
                    print('  ERR POS', e)
                    continue
                for m in mats:
                    for q in pos:
                        puntos.append(vtr.aplicar(m, q))
        xs = [p[0] for p in puntos]
        ys = [p[1] for p in puntos]
        zs = [p[2] for p in puntos]
        print('=== %s | %d puntos ===' % (lod, len(puntos)))
        print('  X:', [(round(a, 4), n) for a, n in niveles(xs)])
        print('  Y:', [(round(a, 4), n) for a, n in niveles(ys)])
        print('  Z:', [(round(a, 4), n) for a, n in niveles(zs)])
        # Esquinas en el plano de apoyo
        base = [p for p in puntos if abs(p[1] - 0.045) < 1e-4]
        print('  BASE %d:' % len(base), sorted(set((round(p[0], 4), round(p[2], 4)) for p in base)))
        top = [p for p in puntos if abs(p[1] - 2.045) < 1e-4]
        print('  TOP  %d:' % len(top), sorted(set((round(p[0], 4), round(p[2], 4)) for p in top)))
        # Plano frontal: candidatos z positivos extremos
        front = [p for p in puntos if p[2] > 0.20]
        print('  FRONT(z>0.20) %d, niveles z=' % len(front),
              [(round(a, 4), n) for a, n in niveles([p[2] for p in front])])
        print('  panel x=+-0.36:', sorted(set((round(p[0], 4), round(p[1], 4), round(p[2], 4))
                                             for p in puntos if abs(abs(p[0]) - 0.36) < 1e-4))[:14])
    return 0


if __name__ == '__main__':
    sys.exit(main())
