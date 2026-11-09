"""Sonda 2 de AUTORIA: agrupa por OBJETO los defectos de decimate.

Responde: ?el dano de BAJA esta SOLO en Herraje o tambien en Musgo?
Publica, por cada SM_: caras, triangulos, ngons, caras inclinadas y
los niveles z espurios en la zona anti-cunia (0.16, 0.26).
"""
import bpy
import sys
from collections import Counter, defaultdict

ruta = sys.argv[sys.argv.index('--') + 1]
bpy.ops.wm.open_mainfile(filepath=ruta)
bpy.context.view_layer.update()

TOL = 1e-4
VACIA_LO, VACIA_HI = 0.16, 0.26
res = defaultdict(lambda: {'caras': 0, 'tris': 0, 'ngons': 0, 'inclinadas': 0})
espurios = Counter()

for o in bpy.context.scene.objects:
    if o.type != 'MESH' or not o.name.startswith('SM_'):
        continue
    d = res[o.name]
    for p in o.data.polygons:
        d['caras'] += 1
        vs = [o.matrix_world @ o.data.vertices[i].co for i in p.vertices]
        for v in vs:
            if VACIA_LO < v.z < VACIA_HI:
                espurios[round(v.z, 4)] += 1
        if len(vs) == 3:
            d['tris'] += 1
            continue
        if len(vs) > 4:
            d['ngons'] += 1
            continue
        constantes = 0
        for eje in range(3):
            vals = [v[eje] for v in vs]
            if max(vals) - min(vals) < TOL:
                constantes += 1
        if constantes != 1:
            d['inclinadas'] += 1

print('SONDA2 archivo=%s' % ruta)
for nom in sorted(res):
    d = res[nom]
    print('SONDA2 OBJ %-40s caras=%3d tris=%2d ngons=%d inclinadas=%2d'
          % (nom, d['caras'], d['tris'], d['ngons'], d['inclinadas']))
print('SONDA2 ZONA_VACIA niveles_espurios=%s' % dict(espurios))
tot = sum(d['tris'] + d['ngons'] + d['inclinadas'] for d in res.values())
print('SONDA2 VEDICTO=%s (defectos=%d)' % ('LIMPIA' if tot == 0 else 'DANADA', tot))
