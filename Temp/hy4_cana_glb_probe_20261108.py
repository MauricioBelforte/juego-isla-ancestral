# Sonda de calibracion para la guardia B19/L37. Reusa el decodificador GLB
# ya medido de B18 (verificar_valla_madera.py), sin tocar los GLB publicados.
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.join(REPO, 'tools', 'mcp', 'blender-mcp',
                                '40-Infraestructura', 'scripts'))
import verificar_valla_madera as V  # noqa: E402

GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
for lod in ('alta', 'media', 'baja'):
    path = os.path.join(GODOT, lod, '35-Mineria_cana_pescar.glb')
    raw, doc, bin_, ok = V.cargar(path)
    assert ok, 'GLB ilegible: ' + path
    _, instancias = V.recorrer(doc)
    mat_por_mesh = {}
    for mi, m in instancias:
        mat_por_mesh.setdefault(mi, []).append(m)
    puntos, tris = [], 0
    for mi, mesh in enumerate(doc['meshes']):
        for pr in mesh.get('primitives', []):
            pos_i = pr['attributes']['POSITION']
            pos, e1 = V.leer_vec(doc, bin_, pos_i, 'f', 3)
            assert not e1 and pos, (lod, mi, e1)
            ai = pr.get('indices')
            if ai is None:
                count = len(pos)
            else:
                fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(
                    doc['accessors'][ai]['componentType'], 'H')
                vals, e2 = V.leer_vec(doc, bin_, ai, fmt, 1)
                assert not e2
                count = doc['accessors'][ai]['count']
            tris += count // 3
            for m in mat_por_mesh.get(mi, [V.ident()]):
                for q in pos:
                    puntos.append(V.aplicar(m, q))
    xs = [p[0] for p in puntos]
    ys = [p[1] for p in puntos]
    zs = [p[2] for p in puntos]
    lx = sorted({round(v, 4) for v in xs})
    ly = sorted({round(v, 4) for v in ys})
    lz = sorted({round(v, 4) for v in zs})
    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in puntos
             if abs(p[1] - 0.045) <= 1e-3}
    print('PROBE %-5s tris=%-4d mats=%d meshes=%d nodes=%d verts=%d'
          % (lod, tris, len(doc.get('materials', [])), len(doc['meshes']),
             len(doc['nodes']), len(puntos)))
    print('  x=[%.4f..%.4f] y=[%.4f..%.4f] z=[%.4f..%.4f] apoyo=%d'
          % (min(xs), max(xs), min(ys), max(ys), min(zs), max(zs), len(apoyo)))
    print('  NIVELES_X=%s' % lx)
    print('  NIVELES_Y=%s' % ly)
    print('  NIVELES_Z=%s' % lz)
    print('  MATS=%s' % sorted(m.get('name', '') for m in doc.get('materials', [])))
    print('  GUIA_ALTA=%d GUIA_BAJA=%d PUNTA=%d CARRETE=%d'
          % (sum(1 for p in puntos if p[0] > 0.06),
             sum(1 for p in puntos if p[0] < -0.20 and p[1] < 0.5),
             sum(1 for p in puntos if p[1] > 1.60),
             sum(1 for p in puntos if p[0] < -0.15 and 0.30 < p[1] < 0.50)))
