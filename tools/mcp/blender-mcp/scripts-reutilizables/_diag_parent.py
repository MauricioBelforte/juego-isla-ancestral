import bpy
from mathutils import Vector
bpy.context.view_layer.update()
print("=== DIAGNOSTICO PARENTING (escena actual) ===")
for o in bpy.context.scene.objects:
    if not o.name.startswith('SM_'):
        continue
    bb = [o.matrix_world @ Vector(c) for c in o.bound_box]
    cx = sum(v.x for v in bb)/8; cy = sum(v.y for v in bb)/8; cz = sum(v.z for v in bb)/8
    zmin = min(v.z for v in bb); zmax = max(v.z for v in bb)
    par = o.parent.name if o.parent else '-'
    print("%-32s padre=%-24s centro_world=(%.3f, %.3f, %.3f)  z=[%.3f, %.3f]"
          % (o.name, par, cx, cy, cz, zmin, zmax))
m = bpy.data.objects.get('SM_PicoHierro_Mango')
if m:
    print("\nMango matrix_world (filas):")
    for r in m.matrix_world:
        print("   [%.3f %.3f %.3f %.3f]" % tuple(r))
    print("Mango rotation_euler:", [round(d,1) for d in [__import__('math').degrees(a) for a in m.rotation_euler]])
