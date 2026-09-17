# auditar_mobiliario.py — Auditoria numerica de los muebles M18 (log 810).
#
# Una sola pasada headless sobre las 12 variantes (4 assets x ALTA/MEDIA/BAJA).
# Por cada blend imprime: SM_, triangulos REALES (loop_triangles, no caras),
# materiales, z_min (E-24), huella (E-50), vertices apoyando y volumen firmado
# (E-92, >0 <=> normales hacia afuera).
#
# USO:
#   blender -b --factory-startup --python auditar_mobiliario.py
import os
import sys
import bpy

_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _DIR)
from mobiliario_util import RAIZ, MODULO, Z_APOYO   # noqa: E402

# Lote 1 = log 810. Lote 2 = log 811 (10 muebles restantes del checklist).
ASSETS = ['cama_basica', 'velador', 'silla_madera', 'mesa_madera',
          'cama_doble', 'sillon', 'nevera_rustica', 'estufa_lena',
          'estanteria', 'comoda', 'lampara_pie', 'alfombra',
          'cuadro_ancestral', 'maceta_interior']
VARIANTES = [('alta', '_lowpoly'), ('media', '_lowpoly_media'),
             ('baja', '_lowpoly_baja')]
# Presupuesto M166 §3.3
LIM = {'alta': (16, 6000, 12), 'media': (8, 1500, 8), 'baja': (6, 700, 4)}


def zmin(objs):
    return min((o.matrix_world @ v.co).z for o in objs for v in o.data.vertices)


def main():
    print('%-14s %-6s %4s %6s %5s %8s %14s %6s %10s  %s'
          % ('asset', 'var', 'SM_', 'tris', 'mats', 'z_min', 'huella', 'toca',
             'vol_firm', 'ok'))
    fallos = []
    for asset in ASSETS:
        for var, suf in VARIANTES:
            ruta = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', MODULO,
                                asset + suf + '.blend')
            if not os.path.exists(ruta):
                print('%-14s %-6s  FALTA %s' % (asset, var, ruta))
                fallos.append(asset + '/' + var)
                continue
            bpy.ops.wm.open_mainfile(filepath=ruta)
            bpy.context.view_layer.update()          # E-94
            objs = [o for o in bpy.context.scene.objects
                    if o.type == 'MESH' and o.name.startswith('SM_')]
            tris = 0
            mats = set()
            vol = 0.0
            for o in objs:
                o.data.calc_loop_triangles()
                tris += len(o.data.loop_triangles)
                for s in o.material_slots:
                    if s.material:
                        mats.add(s.material.name)
                for lt in o.data.loop_triangles:
                    a, b, c = (o.matrix_world @ o.data.vertices[i].co
                               for i in lt.vertices)
                    vol += a.cross(b).dot(c) / 6.0
            zm = zmin(objs)
            pts = [(o.matrix_world @ v.co) for o in objs for v in o.data.vertices]
            apoyo = [p for p in pts if abs(p.z - Z_APOYO) < 0.005]
            xs = [p.x for p in apoyo]
            ys = [p.y for p in apoyo]
            fp = (max(xs) - min(xs), max(ys) - min(ys)) if apoyo else (0.0, 0.0)
            lo, lt_, lm = LIM[var]
            ok = (len(objs) <= lo and tris <= lt_ and len(mats) <= lm
                  and abs(zm - Z_APOYO) < 1e-4 and min(fp) > 0.30
                  and len(apoyo) >= 8 and vol > 0)
            if not ok:
                fallos.append('%s/%s' % (asset, var))
            print('%-14s %-6s %4d %6d %5d %8.4f %6.2fx%-6.2f %6d %10.4f  %s'
                  % (asset, var, len(objs), tris, len(mats), zm,
                     fp[0], fp[1], len(apoyo), vol, 'OK' if ok else 'FALLA'))
    print()
    print('FALLOS: %d %s' % (len(fallos), fallos if fallos else ''))


if __name__ == '__main__':
    main()
