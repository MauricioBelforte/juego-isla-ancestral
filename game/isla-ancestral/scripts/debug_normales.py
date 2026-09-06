# -*- coding: utf-8 -*-
# Debug: verificar normales del loft del conejo
import bpy, sys
sys.stdout.reconfigure(encoding='utf-8')
BLEND = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna\conejo_cozy_v10.blend"
bpy.ops.wm.open_mainfile(filepath=BLEND)

for nombre in ['SM_Conejo_Cuerpo', 'SM_Conejo_Cabeza', 'SM_Conejo_Vientre']:
    o = bpy.data.objects.get(nombre)
    if o is None:
        print(f'{nombre}: NO EXISTE')
        continue
    o.data.calc_loop_triangles()
    # normal promedio apuntando hacia afuera de la primera cara
    total_n = [0.0, 0.0, 0.0]
    for p in o.data.polygons[:8]:
        total_n[0] += p.normal.x
        total_n[1] += p.normal.y
        total_n[2] += p.normal.z
    # centro del objeto vs centro de la cara
    c_obj = o.matrix_world.translation
    print(f'{nombre}: polys={len(o.data.polygons)} mats={len(o.data.materials)} '
          f'norm_avg=({total_n[0]:.2f},{total_n[1]:.2f},{total_n[2]:.2f})')
    # materiales
    for i, m in enumerate(o.data.materials):
        if m:
            col = m.node_tree.nodes.get('Principled BSDF')
            colv = col.inputs['Base Color'].default_value[:] if col else None
            print(f'  slot {i}: {m.name} color={colv}')
