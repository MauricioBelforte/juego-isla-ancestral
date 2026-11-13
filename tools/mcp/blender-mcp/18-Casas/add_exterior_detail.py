# -*- coding: utf-8 -*-
# ERNIE-5.5-Flash-Preview / Kilo Code — Ventanas, chimeneas visibles y detalle exterior.
# Aplica a Casona/Mansión v2 y a Agricultor/Mercader.

import bpy, math, os
from mathutils import Matrix, Vector

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\18-Casas"
CAPT = os.path.join(BASE, "CAPTURAS")
os.makedirs(CAPT, exist_ok=True)

MAD = bpy.data.materials["MAT_MaderaClara"]
OSC = bpy.data.materials["MAT_MaderaOscura"]
PAJ = bpy.data.materials["MAT_PajaClara"]
PIE = bpy.data.materials["MAT_Piedra"]
TEL = bpy.data.materials["MAT_TelaCrudo"]
MET = bpy.data.materials["MAT_MetalForjado"]
CRY = bpy.data.materials["MAT_Cristal"]
COR = bpy.data.materials["MAT_Coral"]
EMI = bpy.data.materials["MAT_Faro"]
VER = bpy.data.materials["MAT_VerdeSage"]
ROJO = bpy.data.materials.get("MAT_Rojo") or bpy.data.materials["MAT_Coral"]
TRIGO = bpy.data.materials.get("MAT_Trigo") or bpy.data.materials["MAT_PajaClara"]
ORO = bpy.data.materials["MAT_OroViejo"]
AGUA = bpy.data.materials["MAT_Agua"]
ARE = bpy.data.materials["MAT_Arena"]

PARTS = []
def _fin(ob, name, m):
    ob.name = name
    ob.data.materials.append(m)
    PARTS.append(ob)
    return ob

def box(name, sx, sy, sz, x, y, z, m, rx=0.0, ry=0.0, rz=0.0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z), rotation=(rx, ry, rz))
    ob = bpy.context.object
    ob.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return _fin(ob, name, m)

def cyl(name, r, depth, x, y, z, m, vertices=10, rx=0.0, ry=0.0, rz=0.0):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=r, depth=depth,
                                        location=(x, y, z), rotation=(rx, ry, rz))
    ob = bpy.context.object
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return _fin(ob, name, m)

def sph(name, r, x, y, z, m, u=10, v=6):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=u, ring_count=v, radius=r, location=(x, y, z))
    ob = bpy.context.object
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return _fin(ob, name, m)

def cone(name, r1, r2, depth, x, y, z, m, vertices=10):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=r1, radius2=r2, depth=depth,
                                    location=(x, y, z))
    ob = bpy.context.object
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return _fin(ob, name, m)

def window_back(name, x, y, z, w=1.2, h=1.2, out=1):
    box(name+"_Marco", w+0.24, 0.14, h+0.24, x, y+0.02*out, z, OSC)
    box(name+"_Vidrio", w, 0.05, h, x, y+0.10*out, z, CRY)
    box(name+"_TraviesaV", 0.06, 0.06, h, x, y+0.13*out, z, OSC)
    box(name+"_TraviesaH", w, 0.06, 0.06, x, y+0.13*out, z, OSC)
    box(name+"_Postigo1", w*0.45, 0.07, h+0.1, x-w*0.75, y+0.14*out, z, VER)
    box(name+"_Postigo2", w*0.45, 0.07, h+0.1, x+w*0.75, y+0.14*out, z, VER)
    box(name+"_Jardinera", w*0.9, 0.26, 0.22, x, y+0.2*out, z-h/2-0.16, COR)
    for i in range(3):
        sph(name+"_Flor%d" % i, 0.08, x-w*0.3+i*w*0.3, y+0.2*out, z-h/2-0.02, [ROJO, TRIGO, VER][i], 8, 6)

def window_side(name, x, y, z, w=1.2, h=1.2, out=1):
    box(name+"_Marco", 0.14, w+0.24, h+0.24, x+0.02*out, y, z, OSC)
    box(name+"_Vidrio", 0.05, w, h, x+0.10*out, y, z, CRY)
    box(name+"_TraviesaV", 0.06, 0.06, h, x+0.13*out, y, z, OSC)
    box(name+"_TraviesaH", 0.06, w, 0.06, x+0.13*out, y, z, OSC)
    box(name+"_Postigo1", 0.07, w*0.45, h+0.1, x+0.14*out, y-w*0.75, z, VER)
    box(name+"_Postigo2", 0.07, w*0.45, h+0.1, x+0.14*out, y+w*0.75, z, VER)
    box(name+"_Jardinera", 0.26, w*0.9, 0.22, x+0.2*out, y, z-h/2-0.16, COR)
    for i in range(3):
        sph(name+"_Flor%d" % i, 0.08, x+0.2*out, y-w*0.3+i*w*0.3, z-h/2-0.02, [ROJO, TRIGO, VER][i], 8, 6)

def detail_house(scene_name, root_name, x0, x1, y0, y1, wall_top, roof_base,
                 back_windows, side_windows, chimneys):
    global PARTS
    scene = bpy.data.scenes[scene_name]
    bpy.context.window.scene = scene
    root = bpy.data.objects[root_name]
    PARTS = []

    # ventanas
    for i, x in enumerate(back_windows):
        for j, z in enumerate((wall_top*0.55, wall_top*0.82)):
            window_back("%s_Win_B%d_%d" % (root_name, i, j), x, y1, z, 1.3, 1.2, +1)
    for i, y in enumerate(side_windows):
        for j, z in enumerate((wall_top*0.55, wall_top*0.82)):
            window_side("%s_Win_O%d_%d" % (root_name, i, j), x0, y, z, 1.3, 1.2, -1)
            window_side("%s_Win_E%d_%d" % (root_name, i, j), x1, y, z, 1.3, 1.2, +1)

    # chimeneas: subir y acercar a la cumbrera
    for prefix, base_z, new_h in chimneys:
        for ob in bpy.data.objects:
            if not ob.name.startswith(prefix):
                continue
            if "_Cap" in ob.name:
                ob.location.z = base_z + new_h + 0.10
                ob.location.y = 0.8
            elif "_Hogar" in ob.name:
                continue
            else:
                cur_h = max(0.1, ob.dimensions.z)
                ob.scale.z *= new_h / cur_h
                ob.location.z = base_z + new_h/2
                ob.location.y = 0.8
        # tapa si no existe
        if not any(o.name.startswith(prefix) and "_Cap" in o.name for o in bpy.data.objects):
            box(prefix+"_Cap", 1.0, 1.0, 0.15, 0.0, 0.8, base_z+new_h+0.1, PIE)

    # vigas de esquina
    for sx in (x0, x1):
        for sy in (y0, y1):
            box("%s_Viga_X%.0fY%.0f" % (root_name, sx, sy), 0.22, 0.22, wall_top,
                sx, sy, wall_top/2, OSC)

    # zócalo perimetral
    box(root_name+"_Zocalo_B", x1-x0+0.3, 0.12, 0.35, (x0+x1)/2, y1+0.02, 0.175, PIE)
    box(root_name+"_Zocalo_O", 0.12, y1-y0+0.3, 0.35, x0-0.02, (y0+y1)/2, 0.175, PIE)
    box(root_name+"_Zocalo_E", 0.12, y1-y0+0.3, 0.35, x1+0.02, (y0+y1)/2, 0.175, PIE)

    # aleros
    box(root_name+"_Alero_B", x1-x0+0.8, 0.35, 0.12, (x0+x1)/2, y1+0.2, roof_base, OSC)
    box(root_name+"_Alero_O", 0.35, y1-y0+0.8, 0.12, x0-0.2, (y0+y1)/2, roof_base, OSC)
    box(root_name+"_Alero_E", 0.35, y1-y0+0.8, 0.12, x1+0.2, (y0+y1)/2, roof_base, OSC)

    # sendero y cerca
    for i in range(4):
        box(root_name+"_Sendero%d" % i, 1.3, 0.9, 0.06, 0.0, y0-1.0-i*1.0, 0.03, PIE)
    for i in range(5):
        box(root_name+"_Cerca_Post%d" % i, 0.12, 0.12, 1.0, -4.0+i*2.0, y0-4.2, 0.5, OSC)
    box(root_name+"_Cerca_Riel", 8.0, 0.08, 0.08, 0.0, y0-4.2, 0.8, OSC)

    # farol
    cyl(root_name+"_Farol_Post", 0.06, 2.2, x1-1.2, y0-1.2, 1.1, OSC, 8)
    box(root_name+"_Farol_Luz", 0.25, 0.25, 0.3, x1-1.2, y0-1.2, 2.3, EMI)

    # pozo
    cyl(root_name+"_Pozo", 0.7, 0.8, x0+2.0, y0-3.0, 0.4, PIE, 12)
    cyl(root_name+"_Pozo_Agua", 0.55, 0.05, x0+2.0, y0-3.0, 0.82, AGUA, 12)
    for dx in (-0.7, 0.7):
        box(root_name+"_Pozo_Post", 0.1, 0.1, 1.6, x0+2.0+dx, y0-3.0, 1.6, OSC)
    box(root_name+"_Pozo_Techo", 1.7, 1.0, 0.1, x0+2.0, y0-3.0, 2.45, PAJ)

    for ob in PARTS:
        ob.parent = root
        ob.matrix_parent_inverse = Matrix.Identity(4)
    bpy.context.view_layer.update()
    print(root_name, "detalle agregado:", len(PARTS))

# ---------- Casona v2 ----------
detail_house("Casas_Grandes_v2", "CASONA_GREMIO_V2", -10, 10, -7.5, 7.5, 7.8, 7.8,
             back_windows=[-6, 0, 6], side_windows=[-4, 0, 4],
             chimneys=[("CG_Chimenea1", 7.8, 3.4), ("CG_Chimenea2", 7.8, 3.4)])

# ---------- Mansión v2 ----------
detail_house("Casas_Grandes_v2", "MANSION_MUSEO_V2", -14, 14, -10, 10, 8.65, 8.65,
             back_windows=[-10, -4, 4, 10], side_windows=[-6, 0, 6],
             chimneys=[("MM_Chimenea_Bib", 8.65, 3.6), ("MM_Chimenea_Estudio", 8.65, 3.6)])

# ---------- Agricultor ----------
detail_house("Casas_Extra", "CASA_AGRICULTOR", -9, 9, -6.5, 6.5, 7.8, 7.8,
             back_windows=[-5, 0, 5], side_windows=[-3, 2],
             chimneys=[("AG_Chimenea", 7.8, 3.4)])

# ---------- Mercader ----------
detail_house("Casas_Extra", "CASA_MERCADER", -8, 8, -6, 6, 8.25, 8.25,
             back_windows=[-4, 4], side_windows=[-3, 2],
             chimneys=[("ME_Chimenea", 8.25, 3.6)])

# guardar ambas escenas
bpy.context.window.scene = bpy.data.scenes["Casas_Grandes_v2"]
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(BASE, "casas_ernie_v2_guardadas_2026-11-12.blend"))
bpy.context.window.scene = bpy.data.scenes["Casas_Extra"]
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(BASE, "casas_ernie_extra_2026-11-12.blend"))

# render extra
scene = bpy.data.scenes["Casas_Extra"]
bpy.context.window.scene = scene
cam = bpy.data.objects["Camara_Extra"]
cam.location = (0, -45, 22)
scene.render.filepath = os.path.join(CAPT, "casas_extra_exterior_2026-11-12.png")
bpy.ops.render.render(write_still=True)
print("Render extra:", scene.render.filepath)
print("Objetos globales:", len(bpy.data.objects))