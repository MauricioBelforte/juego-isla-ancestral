# crear_volcan_lowpoly.py — Volcán lowpoly (isla central) (M27)
import bpy, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import limpiar, mat, arena, iluminar, asentar, camara, shade_flat, guardar
escena = limpiar()
m1 = mat('MAT_Volcan_Roca', (0.36, 0.32, 0.29))
m2 = mat('MAT_Volcan_Roca_Osc', (0.26, 0.22, 0.20))
m3 = mat('MAT_Volcan_Lava', (1.0, 0.35, 0.05), emisivo=((1.0, 0.40, 0.05), 2.5))
bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=4.0, radius2=1.2, depth=5.5, location=(0, 0, 2.75))
cuerpo = bpy.context.object
cuerpo.name = 'SM_Volcan_Cuerpo'
cuerpo.data.materials.append(m1)
bpy.ops.mesh.primitive_torus_add(major_radius=1.25, minor_radius=0.18, major_segments=10, minor_segments=5, location=(0, 0, 5.45))
borde = bpy.context.object
borde.name = 'SM_Volcan_Borde'
borde.data.materials.append(m2)
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=1.05, depth=0.25, location=(0, 0, 5.45 + 0.125))
lava = bpy.context.object
lava.name = 'SM_Volcan_Lava'
lava.data.materials.append(m3)
arena(radio=5.0)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_Volcan', (10.5, -12.0, 6.5), (0, 0, 3.0))
shade_flat(escena)
guardar(escena, '27-Islas-Ubicaciones', 'volcan')
