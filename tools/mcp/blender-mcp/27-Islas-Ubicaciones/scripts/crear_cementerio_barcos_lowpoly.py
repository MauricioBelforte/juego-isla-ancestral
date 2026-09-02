# crear_cementerio_barcos_lowpoly.py - Cementerio de barcos (M27)
import bpy, os, sys, math
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'scripts-reutilizables'))
from plantilla_asset import limpiar, mat, arena, iluminar, asentar, camara, shade_flat, guardar
escena = limpiar()
MAT_mad = mat('MAT_Cementerio_Madera', (0.44, 0.30, 0.18))
MAT_mad_osc = mat('MAT_Cementerio_Madera_Osc', (0.30, 0.19, 0.11))
MAT_arena = mat('MAT_Cementerio_Arena', (0.92, 0.84, 0.63))

# 3 cascos: location.z = scale.z/2 para que bottom=0 por construccion (E-12)
cascos = [
    dict(loc=(-1.0,  0.9, 0.45), sc=(2.6, 1.3, 0.9),  rz=math.radians(30)),
    dict(loc=( 1.1, -0.6, 0.40), sc=(2.2, 1.1, 0.8),  rz=math.radians(-20)),
    dict(loc=( 0.2, -1.1, 0.35), sc=(1.8, 0.9, 0.7),  rz=math.radians(0)),
]
for i, c in enumerate(cascos):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=c['loc'])
    h = bpy.context.object; h.name = 'SM_Cementerio_Casco_%d' % i
    h.scale = c['sc']; h.rotation_euler = (0.0, 0.0, c['rz'])
    h.data.materials.append(MAT_mad if i % 2 == 0 else MAT_mad_osc)

# 2 mastiles rotos sobre los cascos (E-60)
for i, (x, y, ang) in enumerate([(-0.6, 0.7, 35), (0.9, -0.9, -25)]):
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.07, depth=1.4, location=(x, y, 1.1))
    m = bpy.context.object; m.name = 'SM_Cementerio_Mastil_%d' % i
    m.rotation_euler = (math.radians(ang), math.radians(15), 0.0)
    m.data.materials.append(MAT_mad_osc)

# 4 costillas sobre el casco 0 (E-60)
for i, x in enumerate([-1.6, -1.2, -0.8, -0.4]):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, 0.9, 0.65))
    r = bpy.context.object; r.name = 'SM_Cementerio_Costilla_%d' % i
    r.scale = (0.05, 1.0, 0.05)
    r.data.materials.append(MAT_mad_osc)

# Medano de arena (12 verts)
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=1.6, depth=0.18, location=(0.0, 0.0, 0.09))
med = bpy.context.object; med.name = 'SM_Cementerio_Medano'
med.data.materials.append(MAT_arena)

arena(radio=4.0); iluminar(escena); asentar(escena)
camara(escena, 'CAM_Cementerio', (6.5, -7.5, 3.5), (0, 0, 0.6))
shade_flat(escena); guardar(escena, '27-Islas-Ubicaciones', 'cementerio_barcos')
