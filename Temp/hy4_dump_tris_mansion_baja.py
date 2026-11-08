"""Sonda: valida copias de malla y vuelca triangulos del .blend BAJA a JSON.

No guarda el .blend. Las copias se validan en memoria.
Uso: blender.exe -b --factory-startup --python-exit-code 1 --python <script> -- <blend> <json>
"""
import bpy
import json
import os
import sys

argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
if len(argv) < 2:
    raise SystemExit('FALTAN ARGS: <blend> <json>')
blend, salida = argv[0], argv[1]
bpy.ops.wm.open_mainfile(filepath=os.path.abspath(blend))
M = 'HY4_DUMP'
print('%s INICIO %s' % (M, blend))

out = {}
for o in sorted([x for x in bpy.data.objects
                 if x.type == 'MESH' and x.name.startswith('SM_')],
                key=lambda x: x.name):
    me = o.data
    me.calc_loop_triangles()
    antes = len(me.loop_triangles)
    copia = me.copy()
    copia.calc_loop_triangles()
    n_copia_antes = len(copia.loop_triangles)
    cambio = copia.validate(verbose=False, clean_customdata=False)
    copia.calc_loop_triangles()
    n_copia_despues = len(copia.loop_triangles)
    print('%s VALIDATE %-42s antes=%-5d copia=%-5d validar_cambio=%s despues=%-5d delta=%d' %
          (M, o.name, antes, n_copia_antes, cambio, n_copia_despues,
           n_copia_despues - n_copia_antes))

    def volcar(malla):
        malla.calc_loop_triangles()
        mw = o.matrix_world
        lista = []
        for t in malla.loop_triangles:
            pts, vv = [], []
            for i in t.vertices:
                v = mw @ malla.vertices[i].co
                vv.append(v)
                pts.append([round(v.x, 5), round(v.y, 5), round(v.z, 5)])
            area = (vv[1] - vv[0]).cross(vv[2] - vv[0]).length * 0.5
            lista.append({'p': pts, 'a': round(area, 6)})
        return lista

    out[o.name] = {'original': volcar(me), 'validado': volcar(copia)}
    bpy.data.meshes.remove(copia)
print('%s TOTAL_OBJETOS=%d TOTAL_TRIS=%d TOTAL_VALIDADO=%d' %
      (M, len(out),
       sum(len(v['original']) for v in out.values()),
       sum(len(v['validado']) for v in out.values())))

with open(salida, 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, separators=(',', ':'))
print('%s JSON_ESCRITO=%s bytes=%d' % (M, salida, os.path.getsize(salida)))
print('%s FIN' % M)
