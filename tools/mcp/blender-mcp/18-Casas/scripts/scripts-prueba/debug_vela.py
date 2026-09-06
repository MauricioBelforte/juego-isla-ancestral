# debug_vela.py — aisla el bug de z_min en vela_plato.
import bpy
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)) + '/..')
# ejecutar el framework del batch pero solo hasta vela_plato
exec(compile(open(os.path.dirname(os.path.abspath(__file__)) + '/../crear_decoracion_tienda_batch.py',
               encoding='utf-8').read().split('# ============ BATCH ============')[0],
       'batch', 'exec'))

limpiar()
MAT.clear()
mats()
# replicar vela_plato sin asentar
cilindro('SM_VelaPlato_Plato', MAT['barro'], 0.16, 0.03, 0, 0, 0.06, verts=14)
cilindro('SM_VelaPlato_Borde', MAT['barro_osc'], 0.17, 0.012, 0, 0, 0.075, verts=14)
bpy.context.view_layer.update()
for o in bpy.data.objects:
    if o.name.startswith('SM_'):
        zs = [(o.matrix_world @ v.co).z for v in o.data.vertices]
        print('%s: z %.4f..%.4f (obj z loc %.3f)' % (o.name, min(zs), max(zs), o.location.z))
