"""Sonda de solo lectura: por que chk_asset.py ve 676 tris y el GLB tiene 530.

Uso:
  blender.exe -b --factory-startup --python Temp/hy4_medir_mansion_baja.py -- \
      <ruta.blend> <glb_salida>

No modifica el .blend de origen. El GLB de salida vive en Temp/.
"""
import bpy
import os
import sys

argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
if len(argv) < 2:
    raise SystemExit('FALTAN ARGS: <blend> <glb_salida>')

blend, salida = argv[0], argv[1]
bpy.ops.wm.open_mainfile(filepath=os.path.abspath(blend))

MARCA = 'HY4_SONDA'
print('%s INICIO blend=%s' % (MARCA, blend))

obs = [o for o in bpy.data.objects if o.type == 'MESH' and o.name.startswith('SM_')]
total = 0
for o in sorted(obs, key=lambda x: x.name):
    o.data.calc_loop_triangles()
    n = len(o.data.loop_triangles)
    total += n
    mods = [(m.name, m.type, getattr(m, 'ratio', None),
             m.show_viewport, m.show_render) for m in o.modifiers]
    print('%s OBJ %-42s tris=%-5d polis=%-5d verts=%-5d mats=%d '
          'hide_render=%s hide_viewport=%s mods=%s' %
          (MARCA, o.name, n, len(o.data.polygons), len(o.data.vertices),
           len(o.data.materials), o.hide_render, o.hide_viewport, mods))
print('%s TOTAL_OBJETOS=%d TOTAL_TRIS_BASE=%d' % (MARCA, len(obs), total))

# Conteo con modifiers EVALUADOS (depsgraph), que es lo que export_apply=True usa.
dg = bpy.context.evaluated_depsgraph_get()
total_eval = 0
for o in sorted(obs, key=lambda x: x.name):
    oe = o.evaluated_get(dg)
    me = oe.to_mesh()
    me.calc_loop_triangles()
    n = len(me.loop_triangles)
    total_eval += n
    print('%s EVAL %-42s tris=%-5d polis=%-5d verts=%-5d' %
          (MARCA, o.name, n, len(me.polygons), len(me.vertices)))
    oe.to_mesh_clear()
print('%s TOTAL_TRIS_EVAL=%d' % (MARCA, total_eval))

# Reproducir exactamente la purga + export del exportador compartido.
for o in list(bpy.data.objects):
    if not o.name.startswith('SM_'):
        bpy.data.objects.remove(o, do_unlink=True)
print('%s PURGA_OK objetos_SM=%d' %
      (MARCA, len([o for o in bpy.data.objects if o.name.startswith('SM_')])))

bpy.ops.export_scene.gltf(
    filepath=os.path.abspath(salida),
    export_format='GLB',
    export_materials='EXPORT',
    export_apply=True,
    export_yup=True,
    export_normals=True,
    export_animations=False,
    export_cameras=False,
    export_lights=False,
    export_extras=False,
    use_selection=False,
)
print('%s GLB_ESCRITO=%s bytes=%d' %
      (MARCA, salida, os.path.getsize(salida) if os.path.isfile(salida) else -1))
print('%s FIN' % MARCA)
