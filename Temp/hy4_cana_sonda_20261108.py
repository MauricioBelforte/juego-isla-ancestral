# Sonda geometrica de autoría para B19/L37 (caña de pescar, M35).
# `chk_asset.py` mide COSTE, no FORMA. Aca se verifica que TODA cara de
# todo objeto SM_ sea un quad AXIS-ALIGNED (exactamente 1 coordenada
# constante) y que no aparezcan triangulos ni ngons: es la familia del
# defecto invisible por DECIMATE medido en B18 (acta 28).
import bpy
import sys
from collections import Counter

argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else sys.argv[1:]
ruta = argv[0]
bpy.ops.wm.open_mainfile(filepath=ruta)
bpy.context.view_layer.update()

TOL = 0.0005
objetos = [o for o in bpy.data.objects
           if o.type == 'MESH' and o.name.startswith('SM_')]

inclinadas = []
tris = []
ngons = []
niveles = {0: set(), 1: set(), 2: set()}
for o in objetos:
    vs = [o.matrix_world @ v.co for v in o.data.vertices]
    for w in vs:
        for eje in range(3):
            niveles[eje].add(round(w[eje], 4))
    for p in o.data.polygons:
        if len(p.vertices) == 3:
            tris.append((o.name, p.index))
            continue
        if len(p.vertices) != 4:
            ngons.append((o.name, p.index, len(p.vertices)))
            continue
        vs4 = [vs[i] for i in p.vertices]
        constantes = 0
        for eje in range(3):
            vals = [v[eje] for v in vs4]
            if max(vals) - min(vals) < TOL:
                constantes += 1
        if constantes != 1:
            inclinadas.append((o.name, p.index, constantes))

defectos = len(inclinadas) + len(tris) + len(ngons)
print('SONDA ARCHIVO %s' % ruta.replace('\\', '/').split('/')[-1])
print('SONDA OBJETOS %d | caras=%d | quads_inclinados=%d | tris=%d | ngons=%d'
      % (len(objetos),
         sum(len(o.data.polygons) for o in objetos),
         len(inclinadas), len(tris), len(ngons)))
if inclinadas:
    print('SONDA DETALLE inclinadas=%s' % (inclinadas[:8],))
if tris:
    print('SONDA DETALLE tris=%s' % (tris[:8],))
print('SONDA NIVELES x=%d y=%d z=%d'
      % (len(niveles[0]), len(niveles[1]), len(niveles[2])))
print('SONDA NIVELES_Z %s' % sorted(niveles[2]))
print('SONDA VEDICTO=%s (defectos=%d)'
      % ('LIMPIA' if defectos == 0 else 'DANADA', defectos))
