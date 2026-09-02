# verificar_ojos_coco.py — Comprueba que los "ojos" del coco queden SOBRE la
# superficie y no enterrados dentro de la malla.
#
# Metodo correcto: ray_cast en espacio LOCAL del coco. Se lanza un rayo desde
# muy lejos hacia el centro a lo largo de la direccion del ojo; la distancia del
# impacto es el radio real de la superficie en esa direccion (la malla tiene
# ruido por vertice, asi que un elipsoide analitico no sirve).
#
#   ratio = distancia_ojo / radio_superficie
#   ratio < 0.90 -> enterrado (invisible)
#   ratio > 1.15 -> flotando (pegote suelto)
#
# Uso: python verificar_ojos_coco.py
import sys
import os
import json

# bpy_cliente vive en scripts-reutilizables/, no en scripts-prueba/
_RUTA_REUTIL = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                            'scripts-reutilizables')
sys.path.insert(0, _RUTA_REUTIL)
from bpy_cliente import blender_command

code = """
import bpy
from mathutils import Vector

cocos = {o.name: o for o in bpy.data.objects
         if o.name.startswith('SM_Coco_') and o.type == 'MESH'}
ojos = [o for o in bpy.data.objects if o.name.startswith('SM_CocoOjo_')]

enterrados = 0
flotando = 0
ok = 0
ratios = []
for oj in ojos:
    nombre_coco = oj.name.replace('SM_CocoOjo_', 'SM_Coco_').rsplit('_', 1)[0]
    coco = cocos.get(nombre_coco)
    if coco is None:
        continue
    local = Vector(oj.location)          # coords en espacio local del coco
    d = local.length
    if d < 1e-6:
        continue
    direccion = local.normalized()
    hit, punto, normal, cara = coco.ray_cast(direccion * 3.0, -direccion, distance=6.0)
    if not hit:
        flotando += 1
        continue
    r_sup = Vector(punto).length
    ratio = d / r_sup
    ratios.append(round(ratio, 3))
    if ratio < 0.90:
        enterrados += 1
    elif ratio > 1.15:
        flotando += 1
    else:
        ok += 1

print('ojos:', len(ojos))
print('sobre la superficie (0.90-1.15):', ok)
print('enterrados (< 0.90):', enterrados)
print('fuera de la malla (> 1.15):', flotando)
if ratios:
    print('ratio min/med/max:', min(ratios),
          round(sum(ratios) / len(ratios), 3), max(ratios))
"""

r = blender_command('execute_code', {'code': code})
print(json.dumps(r, ensure_ascii=False)[:700])
