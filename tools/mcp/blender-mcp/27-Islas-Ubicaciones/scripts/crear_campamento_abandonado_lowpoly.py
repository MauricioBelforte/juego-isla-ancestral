# crear_campamento_abandonado_lowpoly.py - Campamento abandonado (M27)
import bpy, os, sys, math
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'scripts-reutilizables'))
from plantilla_asset import limpiar, mat, arena, iluminar, asentar, camara, shade_flat, guardar
escena = limpiar()
MAT_tela = mat('MAT_Campamento_Tela', (0.62, 0.50, 0.36))
MAT_tela_osc = mat('MAT_Campamento_Tela_Osc', (0.45, 0.34, 0.24))
MAT_piedra = mat('MAT_Campamento_Piedra', (0.46, 0.44, 0.42))
MAT_madera = mat('MAT_Campamento_Madera', (0.36, 0.24, 0.15))
MAT_ceniza = mat('MAT_Campamento_Ceniza', (0.22, 0.20, 0.20))

# Toldo plano -> 4 verts en z=0
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-1.4, 0, 0.025))
toldo = bpy.context.object; toldo.name = 'SM_Campamento_Toldo'
toldo.scale = (2.4, 1.8, 0.05); toldo.data.materials.append(MAT_tela_osc)

# Carpa: piramide (cono 3 verts) con base triangular en z=0
bpy.ops.mesh.primitive_cone_add(vertices=3, radius1=0.85, radius2=0.0, depth=1.4, location=(-1.4, 0, 0.7))
carpa = bpy.context.object; carpa.name = 'SM_Campamento_Carpa'
carpa.data.materials.append(MAT_tela)

# Anillo de 6 piedras
for i in range(6):
    ang = i * math.radians(60)
    cx = 0.9 + 0.42 * math.cos(ang); cy = 0.42 * math.sin(ang)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=0, radius=0.16, location=(cx, cy, 0.16))
    p = bpy.context.object; p.name = 'SM_Campamento_Piedra_%d' % i
    p.data.materials.append(MAT_piedra)

# Ceniza -> 12 verts
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.32, depth=0.04, location=(0.9, 0, 0.02))
cen = bpy.context.object; cen.name = 'SM_Campamento_Ceniza'
cen.data.materials.append(MAT_ceniza)

# 3 lenos cruzados SOBRE la ceniza (E-60): location.z = top_ceniza + D/2 = 0.04 + 0.275 = 0.315
# Asi el fondo del leno queda EXACTAMENTE en 0.04, encima de la ceniza (z=0..0.04).
LENO_Z = 0.04 + 0.55 / 2   # = 0.315
for i, (ax, az) in enumerate([(0, 0), (90, 0), (0, 60)]):
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.05, depth=0.55, location=(0.9, 0, LENO_Z))
    l = bpy.context.object; l.name = 'SM_Campamento_Leno_%d' % i
    l.rotation_euler = (math.radians(ax), 0.0, math.radians(az))
    l.data.materials.append(MAT_madera)

arena(radio=3.5); iluminar(escena); asentar(escena)
camara(escena, 'CAM_Campamento', (5.5, -6.5, 3.0), (-0.2, 0, 0.6))
shade_flat(escena); guardar(escena, '27-Islas-Ubicaciones', 'campamento_abandonado')
