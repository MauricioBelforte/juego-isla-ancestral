"""Sonda de AUTORIA: ¿las diagonales vistas en las capturas son geometria real?

Abre un .blend de valla y, para cada objeto SM_, verifica que TODAS las caras
sean quads axis-aligned (los 4 vertices comparten 2 de las 3 coordenadas).
Una cunia de decimate o un join() deformado produce triangulos o quads con
vertices en planos inclinados. Tambien publica los niveles Y (altura) reales.
"""
import bpy
import sys
from collections import Counter

ruta = sys.argv[sys.argv.index('--') + 1]
bpy.ops.wm.open_mainfile(filepath=ruta)
bpy.context.view_layer.update()

TOL = 1e-4
total_caras = 0
triangulos = 0
ngons = 0
inclinadas = []
niveles = Counter()

for o in bpy.context.scene.objects:
    if o.type != 'MESH' or not o.name.startswith('SM_'):
        continue
    for p in o.data.polygons:
        total_caras += 1
        vs = [o.matrix_world @ o.data.vertices[i].co for i in p.vertices]
        for v in vs:
            niveles[round(v.z, 4)] += 1
        if len(vs) == 3:
            triangulos += 1
            continue
        if len(vs) > 4:
            ngons += 1
            continue
        # quad: una cara de caja AXIS-ALIGNED tiene EXACTAMENTE 1 coordenada
        # constante (el plano) y las otras 2 varian. 0 constantes = cara
        # inclinada (cunia real); 2 o mas = quad degenerado.
        constantes = 0
        for eje in range(3):
            vals = [v[eje] for v in vs]
            if max(vals) - min(vals) < TOL:
                constantes += 1
        if constantes != 1:
            inclinadas.append((o.name, p.index,
                               [tuple(round(c, 4) for c in v) for v in vs]))

print('SONDA archivo=%s' % ruta)
print('SONDA objetos=%d caras=%d triangulos=%d ngons=%d inclinadas=%d'
      % (len([o for o in bpy.context.scene.objects
              if o.type == 'MESH' and o.name.startswith('SM_')]),
         total_caras, triangulos, ngons, len(inclinadas)))
print('SONDA niveles_z=%s' % sorted(niveles.items()))
for nom, idx, vs in inclinadas[:6]:
    print('SONDA CARA_INCLINADA %s p%d %s' % (nom, idx, vs))
print('SONDA VEDICTO=%s' % ('LIMPIA' if not (triangulos or ngons or inclinadas)
                            else 'GEOMETRIA_NO_CAJA'))
