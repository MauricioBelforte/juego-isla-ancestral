# Sonda de calibración: vuelca coordenadas REALES del BIN de los 3 GLB.
# Reutiliza el decodificador ya medido de verificar_bloque_tallado.py (B15).
import importlib.util
import os
from collections import Counter

REPO = os.getcwd()
GUARD = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp',
                     '25-Ruinas-Templos', 'scripts',
                     'verificar_bloque_tallado.py')
spec = importlib.util.spec_from_file_location('v', GUARD)
v = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v)

for lod in ('alta', 'media', 'baja'):
    p = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d', lod,
                     '25-Ruinas-Templos_dintel_caido.glb')
    raw, doc, bin_, ok = v.cargar(p)
    _, inst = v.recorrer(doc)
    mat_por_mesh = {}
    for mi, m in inst:
        mat_por_mesh.setdefault(mi, []).append(m)
    puntos, tris = [], 0
    for mi, mesh in enumerate(doc['meshes']):
        mats = mat_por_mesh.get(mi, [v.ident()])
        for pr in mesh.get('primitives', []):
            pos_i = pr['attributes'].get('POSITION')
            if pos_i is None:
                continue
            pos, err = v.leer_vec(doc, bin_, pos_i, 'f', 3)
            if err:
                continue
            ai = pr.get('indices')
            if ai is None:
                cnt = len(pos)
            else:
                fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(
                    doc['accessors'][ai]['componentType'], 'H')
                vals, _ = v.leer_vec(doc, bin_, ai, fmt, 1)
                cnt = len(vals)
            tris += cnt // 3
            for m in mats:
                for q in pos:
                    puntos.append(v.aplicar(m, q))
    xs = [p[0] for p in puntos]
    ys = [p[1] for p in puntos]
    zs = [p[2] for p in puntos]
    print('=== %s ===' % lod)
    print('  bytes=%d tris=%d verts=%d mats=%d nodos=%d inst=%d' %
          (len(raw), tris, len(puntos), len(doc.get('materials', [])),
           len(doc['nodes']), len(inst)))
    print('  x=[%.4f..%.4f]  y=[%.4f..%.4f]  z=[%.4f..%.4f]' %
          (min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)))
    print('  niveles Y:', sorted(Counter(round(y, 4) for y in ys).items()))
    print('  niveles X:', sorted(Counter(round(x, 4) for x in xs).items()))
    print('  niveles Z:', sorted(Counter(round(z, 4) for z in zs).items()))
