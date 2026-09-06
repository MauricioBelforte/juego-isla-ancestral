# inspeccionar_blend.py — lista SM_ y bounding de un .blend (headless).
# Uso: blender -b --factory-startup --python inspeccionar_blend.py -- <ruta.blend>
import bpy
import sys

argv = sys.argv[sys.argv.index("--") + 1:]
ruta = argv[0]
bpy.ops.wm.open_mainfile(filepath=ruta)
sm = sorted(o.name for o in bpy.context.scene.objects if o.name.startswith('SM_'))
print('ARCHIVO: %s' % ruta)
print('SM_ (%d): %s' % (len(sm), ', '.join(sm)))
# bounding de patas/alas si existen
for o in bpy.context.scene.objects:
    if o.name.startswith('SM_Gaviota_Pata') or o.name.startswith('SM_Gaviota_Ala'):
        dims = o.dimensions
        print('  %s dims=%.3f x %.3f x %.3f rot=%s' % (
            o.name, dims.x, dims.y, dims.z,
            tuple(round(r, 3) for r in o.rotation_euler)))
