#!/usr/bin/env python3
"""
chk_asset.py — Auditor rapido de un .blend SIN socket MCP (headless puro).

Motivo:
    `stats_asset.py` y `auditar_presupuesto.py` exigen el socket MCP (Blender
    GUI abierto). Cuando se trabaja headless (E-55) no hay auditor disponible.
    Este script cubre ese hueco y corrige dos errores clasicos:
      - E-40: cuenta TRIANGULOS REALES con `calc_loop_triangles()`, no poligonos
              (un quad = 2 tris, un n-gon = n-2).
      - E-42: cuenta materiales USADOS POR CARAS, no slots. Un material en un
              slot hueco no cuenta como coste.
      - E-24: `z_min` medido sobre VERTICES REALES en coordenadas de mundo, no
              sobre `bound_box` (falso HUNDIDO/FLOTA en objetos rotados).

Uso:
    blender -b --factory-startup --python chk_asset.py -- <ruta.blend>

Ejemplo:
    blender -b --factory-startup --python chk_asset.py -- \
        18-Casas/pared_madera_lowpoly.blend

Salida:
    objetos, triangulos reales, materiales por cara, bbox global, z_min del
    grupo, desglose por pieza, y veredicto contra el presupuesto M166 §3.3.
"""
import bpy
import sys
from mathutils import Vector

# Presupuesto M166 §3.3 (POST-merge).
PRESUPUESTO = {
    'ALTA':  {'objetos': 16, 'tris': 6000, 'materiales': 12},
    'MEDIA': {'objetos': 8,  'tris': 1500, 'materiales': 8},
    'BAJA':  {'objetos': 6,  'tris': 700,  'materiales': 4},
}

argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
if not argv:
    print('FALTA ruta del .blend')
    sys.exit(1)

bpy.ops.wm.open_mainfile(filepath=argv[0])
obs = [o for o in bpy.context.scene.objects
       if o.type == 'MESH' and o.name.startswith('SM_')]
bpy.context.view_layer.update()

if not obs:
    print('SIN objetos SM_* en %s. ¿Te equivocaste de archivo o de prefijo?' % argv[0])
    sys.exit(2)


def zmin_real(o):
    """E-24: z minimo sobre VERTICES REALES. AABB solo si la malla esta vacia."""
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)


tris = 0
mats = {}
mn = Vector((1e9,) * 3)
mx = Vector((-1e9,) * 3)
for o in obs:
    o.data.calc_loop_triangles()
    tris += len(o.data.loop_triangles)
    # E-42: histograma de material_index sobre las CARAS, no sobre los slots.
    hist = {}
    for f in o.data.polygons:
        hist[f.material_index] = hist.get(f.material_index, 0) + 1
    for mi, n in hist.items():
        m = o.data.materials[mi] if mi < len(o.data.materials) else None
        nm = m.name if m else '?'
        mats[nm] = mats.get(nm, 0) + n
    for v in o.data.vertices:
        w = o.matrix_world @ v.co
        for i in range(3):
            mn[i] = min(mn[i], w[i])
            mx[i] = max(mx[i], w[i])

print('archivo     :', argv[0])
print('objetos     :', len(obs))
print('tris reales :', tris)
print('materiales  :', len(mats), mats)
print('z_min grupo : %.4f  (arena -> esperado 0.0450)' % min(zmin_real(o) for o in obs))
print('bbox X [%.3f .. %.3f]  ancho=%.3f' % (mn[0], mx[0], mx[0] - mn[0]))
print('bbox Y [%.3f .. %.3f]  prof =%.3f' % (mn[1], mx[1], mx[1] - mn[1]))
print('bbox Z [%.3f .. %.3f]  alto =%.3f' % (mn[2], mx[2], mx[2] - mn[2]))

print('--- veredicto M166 ---')
for perfil, p in PRESUPUESTO.items():
    ok = (len(obs) <= p['objetos'] and tris <= p['tris']
          and len(mats) <= p['materiales'])
    print('%s %-6s obj %3d/%-3d  tris %5d/%-5d  mats %d/%d'
          % ('OK ' if ok else 'NO ', perfil, len(obs), p['objetos'],
             tris, p['tris'], len(mats), p['materiales']))

print('--- por pieza ---')
for o in sorted(obs, key=lambda x: x.name):
    o.data.calc_loop_triangles()
    print('  %-26s z=%.4f  tris=%d' % (o.name, zmin_real(o),
                                       len(o.data.loop_triangles)))
