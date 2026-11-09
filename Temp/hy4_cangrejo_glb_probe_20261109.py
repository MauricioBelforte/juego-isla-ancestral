# Sonda de calibracion para la guardia B21/L39 (cangrejo_ermitano, M36).
# Reusa el decodificador GLB ya medido de B20 (verificar_carrito_vias.py),
# SIN tocar los GLB publicados. Scratch: se conserva, no se versiona.
#
# Objetivo: obtener los conjuntos AUTORIZADOS de niveles x/y/z EN EL BIN
# (glTF Y-up) y los contadores positivos de silueta / apoyo / LOD, para
# escribir aserciones POSITIVAS calibradas y no inventadas.
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.join(REPO, 'tools', 'mcp', 'blender-mcp',
                                '35-Mineria', 'scripts'))
import verificar_carrito_vias as V  # noqa: E402

GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
BASE = '36-Fauna_cangrejo_ermitano.glb'

for lod in ('alta', 'media', 'baja'):
    path = os.path.join(GODOT, lod, BASE)
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
    escalones = {}
    for nivel in (0.185, 0.275, 0.355, 0.425):
        fila = [p[0] for p in puntos if abs(p[1] - nivel) < 1e-4]
        escalones[nivel] = (len(fila), round(max(fila) - min(fila), 4)
                            if fila else None)
    print('PROBE %-5s tris=%-4d mats=%d meshes=%d nodes=%d verts=%d bytes=%d'
          % (lod, tris, len(doc.get('materials', [])), len(doc['meshes']),
             len(doc['nodes']), len(puntos), len(raw)))
    print('  x=[%.4f..%.4f] y=[%.4f..%.4f] z=[%.4f..%.4f] apoyo=%d'
          % (min(xs), max(xs), min(ys), max(ys), min(zs), max(zs), len(apoyo)))
    print('  NIVELES_X=%s' % lx)
    print('  NIVELES_Y=%s' % ly)
    print('  NIVELES_Z=%s' % lz)
    print('  MATS=%s' % sorted(m.get('name', '')
                               for m in doc.get('materials', [])))
    print('  ESCALONES (nivel: (verts, ancho_x))=%s' % escalones)
    print('  OJOS y=0.285 -> %d | DETALLES_BAJOS 0.11<y<0.125 -> %d'
          ' | CONCHA_ALTA y>=0.355 -> %d | RODELA_APOYO y=0.045 -> %d'
          % (sum(1 for p in puntos if abs(p[1] - 0.285) < 1e-4),
             sum(1 for p in puntos if 0.11 < p[1] < 0.125),
             sum(1 for p in puntos if p[1] >= 0.355 - 1e-4),
             sum(1 for p in puntos if abs(p[1] - 0.045) < 1e-4)))
    print('  PINZAS x>0.27 -> %d | CUERPO 0.17<y<0.25 -> %d'
          % (sum(1 for p in puntos if p[0] > 0.27),
             sum(1 for p in puntos if 0.17 < p[1] < 0.25)))
