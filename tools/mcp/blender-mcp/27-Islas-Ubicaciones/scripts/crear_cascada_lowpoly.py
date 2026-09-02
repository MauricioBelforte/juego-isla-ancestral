# crear_cascada_lowpoly.py - Cascada (roca; agua en M51) (M27)
import bpy, os, sys
from math import radians
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import limpiar, mat, arena, iluminar, asentar, camara, shade_flat, guardar
escena = limpiar()
MAT_roca = mat('MAT_Cascada_Roca', (0.48, 0.45, 0.42))
MAT_roca_osc = mat('MAT_Cascada_Roca_Osc', (0.33, 0.30, 0.28))
MAT_musgo = mat('MAT_Cascada_Musgo', (0.32, 0.46, 0.22))

bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 2.0))
pared = bpy.context.object
pared.name = 'SM_Cascada_Pared'
pared.scale = (4.0, 0.8, 4.0)
pared.data.materials.append(MAT_roca)

bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.45, 3.85))
repisa = bpy.context.object
repisa.name = 'SM_Cascada_Repisa'
repisa.scale = (1.4, 0.25, 0.30)
repisa.rotation_euler = (radians(-12), 0.0, 0.0)
repisa.data.materials.append(MAT_roca_osc)

for i, (x, y) in enumerate([(-1.6, 0.3), (1.4, -0.2), (0.2, 0.55)]):
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.32, depth=0.20,
                                        location=(x, y, 0.10))
    r = bpy.context.object
    r.name = 'SM_Cascada_Musgo_%d' % i
    r.data.materials.append(MAT_musgo)

arena(radio=4.5)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_Cascada', (7.5, -9.0, 4.0), (0, 0, 1.8))
shade_flat(escena)
guardar(escena, '27-Islas-Ubicaciones', 'cascada')
