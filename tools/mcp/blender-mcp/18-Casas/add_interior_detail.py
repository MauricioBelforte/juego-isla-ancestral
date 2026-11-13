# -*- coding: utf-8 -*-
# ERNIE-5.5-Flash-Preview / Kilo Code — Detalle interior: zócalos, vigas, marcos, vajilla y cuadros.

import bpy, math, os
from mathutils import Matrix

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\18-Casas"
MAD = bpy.data.materials["MAT_MaderaClara"]
OSC = bpy.data.materials["MAT_MaderaOscura"]
MARF = bpy.data.materials["MAT_Marfil"]
ORO = bpy.data.materials["MAT_OroViejo"]
VINO = bpy.data.materials["MAT_Vino"]
VER = bpy.data.materials["MAT_VerdeSage"]
COR = bpy.data.materials["MAT_Coral"]
TRIGO = bpy.data.materials.get("MAT_Trigo") or bpy.data.materials["MAT_PajaClara"]

PARTS = []
def _fin(ob, name, m):
    ob.name = name; ob.data.materials.append(m); PARTS.append(ob); return ob

def box(name, sx, sy, sz, x, y, z, m, rx=0.0, ry=0.0, rz=0.0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z), rotation=(rx, ry, rz))
    ob = bpy.context.object; ob.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return _fin(ob, name, m)

def cyl(name, r, depth, x, y, z, m, vertices=10):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=r, depth=depth, location=(x, y, z))
    ob = bpy.context.object
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return _fin(ob, name, m)

def door_frame_x(name, x, cy, z0, w=1.6, h=2.3):
    for s in (-1, 1):
        box(name+"_Post", 0.12, 0.12, h, x, cy+s*w/2, z0+h/2, OSC)
    box(name+"_Dintel", 0.12, w+0.24, 0.12, x, cy, z0+h, OSC)

def door_frame_y(name, y, cx, z0, w=1.6, h=2.3):
    for s in (-1, 1):
        box(name+"_Post", 0.12, 0.12, h, cx+s*w/2, y, z0+h/2, OSC)
    box(name+"_Dintel", w+0.24, 0.12, 0.12, cx, y, z0+h, OSC)

def painting(name, x, y, z, w=1.2, h=0.9, back=True):
    box(name+"_Marco", w+0.14, 0.08, h+0.14, x, y, z, ORO)
    box(name+"_Lienzo", w, 0.04, h, x, y-0.05 if back else y+0.05, z, VINO)
    box(name+"_Cielo", w*0.7, 0.02, h*0.5, x, y-0.08 if back else y+0.08, z+h*0.15, VER)

def table_setting(name, x, y, z, n=4, dx=0.8):
    for i in range(n):
        cyl(name+"_Plato%d" % i, 0.14, 0.03, x-dx+ (2*dx)*(i/(n-1)), y, z+0.015, MARF, 12)
        cyl(name+"_Copa%d" % i, 0.05, 0.10, x-dx+ (2*dx)*(i/(n-1)), y+0.35, z+0.05, ORO, 8)

def interior(scene_name, root_name, x0, x1, y0, y1, wall_top, doors_x, doors_y, paintings, table):
    global PARTS
    scene = bpy.data.scenes[scene_name]
    bpy.context.window.scene = scene
    root = bpy.data.objects[root_name]
    PARTS = []

    # zócalos interiores (perímetro)
    box(root_name+"_ZocaloInt_B", x1-x0-0.2, 0.06, 0.15, (x0+x1)/2, y1-0.14, 0.52, OSC)
    box(root_name+"_ZocaloInt_O", 0.06, y1-y0-0.2, 0.15, x0+0.14, (y0+y1)/2, 0.52, OSC)
    box(root_name+"_ZocaloInt_E", 0.06, y1-y0-0.2, 0.15, x1-0.14, (y0+y1)/2, 0.52, OSC)

    # vigas de techo por planta
    for z in (wall_top*0.52, wall_top*0.98):
        for i, yy in enumerate((-y1*0.5, 0.0, y1*0.5)):
            box(root_name+"_Viga_Techo_%d_%d" % (int(z), i), x1-x0-0.3, 0.16, 0.16,
                (x0+x1)/2, yy, z, OSC)

    # marcos de puertas
    for i, (x, cy) in enumerate(doors_x):
        door_frame_x(root_name+"_MarcoP_X%d" % i, x, cy, 0.5)
    for i, (y, cx) in enumerate(doors_y):
        door_frame_y(root_name+"_MarcoP_Y%d" % i, y, cx, 0.5)

    # cuadros
    for i, (x, z) in enumerate(paintings):
        painting(root_name+"_Cuadro%d" % i, x, y1-0.15, z, 1.3, 1.0, back=True)

    # vajilla en la mesa principal
    if table:
        tx, ty, tz, n = table
        table_setting(root_name+"_Vajilla", tx, ty, tz, n)

    for ob in PARTS:
        ob.parent = root
        ob.matrix_parent_inverse = Matrix.Identity(4)
    bpy.context.view_layer.update()
    print(root_name, "detalle interior:", len(PARTS))

# Casona
interior("Casas_Grandes_v2", "CASONA_GREMIO_V2", -10, 10, -7.5, 7.5, 7.8,
         doors_x=[(-3.0,-4.5),(3.0,-4.5)], doors_y=[(2.5,0.0)],
         paintings=[(-5.0,2.6),(5.0,2.6)], table=(5.0,-4.0,1.40,4))
# Mansión
interior("Casas_Grandes_v2", "MANSION_MUSEO_V2", -14, 14, -10, 10, 8.65,
         doors_x=[(-4.5,-5.5),(5.0,-5.5)], doors_y=[(4.0,0.0)],
         paintings=[(-8.0,3.0),(8.0,3.0)], table=(9.5,6.8,1.55,6))
# Agricultor
interior("Casas_Extra", "CASA_AGRICULTOR", -9, 9, -6.5, 6.5, 7.8,
         doors_x=[(-2.0,-3.5),(3.5,-3.5)], doors_y=[(2.0,0.0)],
         paintings=[(-5.0,2.4),(5.0,2.4)], table=(-5.5,-2.0,1.40,4))
# Mercader
interior("Casas_Extra", "CASA_MERCADER", -8, 8, -6, 6, 8.25,
         doors_x=[(-1.5,-3.5),(3.0,-3.5)], doors_y=[(2.0,0.0)],
         paintings=[(-4.0,2.6),(4.0,2.6)], table=(-5.5,-4.0,1.53,3))

# guardar
bpy.context.window.scene = bpy.data.scenes["Casas_Grandes_v2"]
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(BASE, "casas_ernie_v2_guardadas_2026-11-12.blend"))
bpy.context.window.scene = bpy.data.scenes["Casas_Extra"]
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(BASE, "casas_ernie_extra_2026-11-12.blend"))
print("Guardado v2 y extra")