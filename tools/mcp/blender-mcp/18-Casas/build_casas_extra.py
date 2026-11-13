# -*- coding: utf-8 -*-
# ERNIE-5.5-Flash-Preview / Kilo Code — Casas extra: Agricultor y Mercader.
# 2 plantas, habitaciones amplias, validador AABB + hueco de escalera.

import bpy, bmesh, math, os
from mathutils import Matrix, Vector

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\18-Casas"
BLEND_OUT = os.path.join(BASE, "casas_ernie_extra_2026-11-12.blend")
CAPT = os.path.join(BASE, "CAPTURAS")
os.makedirs(CAPT, exist_ok=True)

if "Casas_Extra" in bpy.data.scenes:
    old = bpy.data.scenes["Casas_Extra"]
    for ob in list(old.objects):
        bpy.data.objects.remove(ob, do_unlink=True)
    bpy.data.scenes.remove(old)

scene = bpy.data.scenes.new("Casas_Extra")
bpy.context.window.scene = scene
scene.render.engine = 'BLENDER_EEVEE_NEXT'
scene.render.resolution_x = 1600
scene.render.resolution_y = 1000
scene.render.resolution_percentage = 100
scene.view_settings.view_transform = 'AgX'
try:
    scene.view_settings.look = 'AgX - Medium High Contrast'
except Exception:
    pass
scene.view_settings.exposure = -0.55

world = bpy.data.worlds.new("Mundo_Extra")
scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get("Background")
bg.inputs[0].default_value = (0.45, 0.62, 0.85, 1.0)
bg.inputs[1].default_value = 0.35

def mat(name, rgb=(180, 140, 90), rough=0.85, metal=0.0, alpha=1.0, emit=None):
    m = bpy.data.materials.get(name)
    if m:
        return m
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes.get("Principled BSDF")
    b.inputs["Base Color"].default_value = (rgb[0]/255, rgb[1]/255, rgb[2]/255, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    if alpha < 1:
        b.inputs["Alpha"].default_value = alpha
        try:
            m.surface_render_method = 'BLENDED'
        except Exception:
            pass
    if emit:
        b.inputs["Emission Color"].default_value = (emit[0]/255, emit[1]/255, emit[2]/255, 1)
        b.inputs["Emission Strength"].default_value = 2.4
    m.diffuse_color = (rgb[0]/255, rgb[1]/255, rgb[2]/255, alpha)
    return m

MAD = mat("MAT_MaderaClara"); OSC = mat("MAT_MaderaOscura"); PAJ = mat("MAT_PajaClara")
PIE = mat("MAT_Piedra"); TEL = mat("MAT_TelaCrudo"); MUS = mat("MAT_PiedraMusgo")
MET = mat("MAT_MetalForjado"); CRY = mat("MAT_Cristal"); COR = mat("MAT_Coral")
EMI = mat("MAT_Faro"); VINO = mat("MAT_Vino", (120, 45, 55), 0.8)
ORO = mat("MAT_OroViejo", (190, 150, 70), 0.45, 0.7)
VER = mat("MAT_VerdeSage", (110, 140, 100), 0.9)
AGUA = mat("MAT_Agua", (80, 150, 170), 0.15, 0.0, 0.55)
LIB = mat("MAT_Libro", (150, 110, 80), 0.9)
COBRE = mat("MAT_Cobre", (170, 100, 60), 0.4, 0.8)
MARF = mat("MAT_Marfil", (230, 220, 195), 0.7)
ARE = mat("MAT_Arena", (212, 190, 150), 1.0)
TRIGO = mat("MAT_Trigo", (200, 170, 90), 0.9)
AZUL = mat("MAT_Azul", (70, 110, 150), 0.8)
ROJO = mat("MAT_Rojo", (160, 60, 50), 0.8)

PARTS = []
def _fin(name, bm, m, x, y, z, rx=0.0, ry=0.0, rz=0.0):
    me = bpy.data.meshes.new(name)
    if rx or ry or rz:
        R = Matrix.Rotation(rz, 3, 'Z') @ Matrix.Rotation(ry, 3, 'Y') @ Matrix.Rotation(rx, 3, 'X')
        bmesh.ops.rotate(bm, cent=(0, 0, 0), matrix=R, verts=bm.verts)
    bm.to_mesh(me); bm.free()
    ob = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(ob)
    ob.location = (x, y, z)
    ob.data.materials.append(m)
    PARTS.append(ob)
    return ob

def box(name, sx, sy, sz, x, y, z, m, rx=0.0, ry=0.0, rz=0.0):
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(sx, sy, sz), verts=bm.verts)
    return _fin(name, bm, m, x, y, z, rx, ry, rz)

def cyl(name, r, depth, x, y, z, m, segments=10, rx=0.0, ry=0.0, rz=0.0):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=segments,
                          radius1=r, radius2=r, depth=depth)
    return _finish_wrap(name, bm, m, x, y, z, rx, ry, rz)

def _finish_wrap(name, bm, m, x, y, z, rx, ry, rz):
    return _fin(name, bm, m, x, y, z, rx, ry, rz)

def cone(name, r1, r2, depth, x, y, z, m, segments=10):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=segments,
                          radius1=r1, radius2=r2, depth=depth)
    return _fin(name, bm, m, x, y, z)

def sph(name, r, x, y, z, m, u=12, v=8):
    bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=u, v_segments=v, radius=r)
    return _fin(name, bm, m, x, y, z)

def roof(name, length, width, height, x, y, z, m):
    hx, hy = length/2, width/2
    verts = [(-hx,-hy,0),(hx,-hy,0),(hx,hy,0),(-hx,hy,0),(-hx,0,height),(hx,0,height)]
    faces = [(0,1,5,4),(2,3,4,5),(1,2,5),(3,0,4),(0,1,2,3)]
    me = bpy.data.meshes.new(name); me.from_pydata(verts, [], faces); me.update()
    ob = bpy.data.objects.new(name, me); bpy.context.collection.objects.link(ob)
    ob.location = (x, y, z); ob.data.materials.append(m)
    bm = bmesh.new(); bm.from_mesh(me); bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(me); bm.free(); PARTS.append(ob)
    return ob

def wall_y(name, y, x0, x1, z0, z1, th, m, doors=None):
    doors = sorted(doors or [], key=lambda d: d[0]); cur = x0
    for (cx, w, h) in doors:
        if cx - w/2 > cur:
            box(name+"_Seg", cx-w/2-cur, th, z1-z0, (cur+cx-w/2)/2, y, (z0+z1)/2, m)
        if z0 + h < z1:
            box(name+"_Dintel", w, th, z1-(z0+h), cx, y, (z0+h+z1)/2, m)
        cur = max(cur, cx + w/2)
    if cur < x1:
        box(name+"_Seg", x1-cur, th, z1-z0, (cur+x1)/2, y, (z0+z1)/2, m)

def wall_x(name, x, y0, y1, z0, z1, th, m, doors=None):
    doors = sorted(doors or [], key=lambda d: d[0]); cur = y0
    for (cy, w, h) in doors:
        if cy - w/2 > cur:
            box(name+"_Seg", th, cy-w/2-cur, z1-z0, x, (cur+cy-w/2)/2, (z0+z1)/2, m)
        if z0 + h < z1:
            box(name+"_Dintel", th, w, z1-(z0+h), x, cy, (z0+h+z1)/2, m)
        cur = max(cur, cy + w/2)
    if cur < y1:
        box(name+"_Seg", th, y1-cur, z1-z0, x, (cur+y1)/2, (z0+z1)/2, m)

def stairs(name, x, y0, z0, z1, width, steps, mat_=MAD):
    rise = (z1-z0)/steps; run = 0.30
    for i in range(steps):
        box(name+"_Step%d" % i, width, run, rise, x, y0+i*run+run/2, z0+rise*(i+0.5), mat_)
    ang = math.atan2(z1-z0, steps*run)
    L = math.sqrt((z1-z0)**2 + (steps*run)**2)
    box(name+"_Handrail", 0.07, L, 0.07, x+width/2, y0+steps*run/2, z0+(z1-z0)/2+1.0, OSC, rx=-ang)
    for i in range(0, steps, 3):
        box(name+"_Baluster", 0.05, 0.05, 0.95, x+width/2, y0+i*run+run/2, z0+rise*i+0.48, OSC)

def slab_hole(name, x0, x1, y0, y1, hx0, hx1, hy0, hy1, z, th, m):
    box(name+"_L", hx0-x0, y1-y0, th, (x0+hx0)/2, (y0+y1)/2, z, m)
    box(name+"_R", x1-hx1, y1-y0, th, (hx1+x1)/2, (y0+y1)/2, z, m)
    box(name+"_F", hx1-hx0, hy0-y0, th, (hx0+hx1)/2, (y0+hy0)/2, z, m)
    box(name+"_B", hx1-hx0, y1-hy1, th, (hx0+hx1)/2, (hy1+y1)/2, z, m)

def rug(name, x, y, z, w, d, m=VINO):
    box(name, w, d, 0.04, x, y, z, m)

def table(name, x, y, z, w, d, h=0.85, m=MAD):
    box(name+"_Tapa", w, d, 0.09, x, y, z+h, m)
    for dx in (-w/2+0.12, w/2-0.12):
        for dy in (-d/2+0.12, d/2-0.12):
            box(name+"_Pata", 0.10, 0.10, h, x+dx, y+dy, z+h/2, OSC)

def chair(name, x, y, z, rz=0.0, m=MAD):
    box(name+"_Asiento", 0.50, 0.50, 0.09, x, y, z+0.48, m, rz=rz)
    box(name+"_Respaldo", 0.50, 0.09, 0.62, x-0.21*math.sin(rz), y-0.21*math.cos(rz), z+0.84, m, rz=rz)
    for dx in (-0.20, 0.20):
        for dy in (-0.20, 0.20):
            box(name+"_Pata", 0.055, 0.055, 0.48, x+dx, y+dy, z+0.24, OSC, rz=rz)

def shelf(name, x, y, z, w, h, d, levels=4, m=MAD, goods=False):
    box(name+"_L1", 0.07, d, h, x-w/2, y, z+h/2, m)
    box(name+"_L2", 0.07, d, h, x+w/2, y, z+h/2, m)
    box(name+"_Fondo", w, 0.05, h, x, y+d/2, z+h/2, m)
    for i in range(levels):
        zz = z + 0.12 + i*(h-0.22)/(levels-1)
        box(name+"_Balda%d" % i, w, d, 0.055, x, y, zz, m)
        if goods:
            for j in range(3):
                box(name+"_Goods%d_%d" % (i,j), 0.18, 0.2, 0.22,
                    x-w/2+0.25+j*(w-0.5)/2, y-0.08, zz+0.16,
                    [ROJO, AZUL, TRIGO][(i+j)%3])

def bed(name, x, y, z, w=2.0, l=2.2, canopy=False):
    box(name+"_Base", w, l, 0.40, x, y, z+0.28, OSC)
    box(name+"_Colchon", w-0.12, l-0.12, 0.26, x, y, z+0.60, TEL)
    box(name+"_Manta", w-0.06, l*0.60, 0.07, x, y+l*0.17, z+0.75, VINO)
    box(name+"_Almohada1", w*0.38, 0.34, 0.14, x-w*0.21, y-l/2+0.32, z+0.78, MARF)
    box(name+"_Almohada2", w*0.38, 0.34, 0.14, x+w*0.21, y-l/2+0.32, z+0.78, MARF)
    box(name+"_Cabecera", w, 0.15, 1.15, x, y-l/2, z+0.78, OSC)
    if canopy:
        for dx in (-w/2, w/2):
            for dy in (-l/2, l/2):
                cyl(name+"_Poste", 0.06, 2.3, x+dx, y+dy, z+1.45, OSC, 8)
        box(name+"_Dosel", w+0.26, l+0.26, 0.08, x, y, z+2.55, VINO)

def wardrobe(name, x, y, z, w=2.2, h=2.6, d=0.7):
    box(name, w, d, h, x, y, z+h/2, OSC)
    for i in range(2):
        box(name+"_Puerta%d" % i, w/2-0.06, 0.05, h-0.22, x-w/4+i*w/2, y-d/2, z+h/2, MAD)
        sph(name+"_Pomo%d" % i, 0.04, x-w/4+i*w/2+0.09, y-d/2-0.04, z+h/2, ORO, 8, 6)

def chandelier(name, x, y, z, r=0.9):
    cyl(name+"_Cadena", 0.02, 0.9, x, y, z+0.85, MET, 6)
    cyl(name+"_Cuerpo", 0.14, 0.3, x, y, z+0.32, ORO, 8)
    for i in range(6):
        a = i*math.pi/3
        ax, ay = x+r*math.cos(a), y+r*math.sin(a)
        cyl(name+"_Brazo%d" % i, 0.03, r, (x+ax)/2, (y+ay)/2, z+0.38, ORO, 6, rz=a, rx=math.pi/2)
        sph(name+"_Llama%d" % i, 0.05, ax, ay, z+0.55, EMI, 8, 6)

def plant(name, x, y, z, s=1.1):
    cyl(name+"_Maceta", 0.22*s, 0.34*s, x, y, z+0.17*s, COR, 8)
    cyl(name+"_Tallo", 0.03*s, 0.6*s, x, y, z+0.55*s, VER, 6)
    for i in range(5):
        a = i*2*math.pi/5
        sph(name+"_Hoja%d" % i, 0.19*s, x+0.17*s*math.cos(a), y+0.17*s*math.sin(a), z+0.78*s, VER, 8, 6)

def barrel(name, x, y, z, r=0.32, h=0.85):
    cyl(name, r, h, x, y, z+h/2, OSC, 10)
    cyl(name+"_Aro1", r+0.015, 0.05, x, y, z+h*0.25, MET, 10)
    cyl(name+"_Aro2", r+0.015, 0.05, x, y, z+h*0.75, MET, 10)

def crate(name, x, y, z, s=0.7):
    box(name, s, s, s, x, y, z+s/2, MAD)
    box(name+"_Banda1", s+0.02, 0.06, 0.06, x, y, z+s*0.75, OSC)
    box(name+"_Banda2", s+0.02, 0.06, 0.06, x, y, z+s*0.25, OSC)

def counter(name, x, y, z, w, d, h=0.95):
    box(name, w, d, h, x, y, z+h/2, OSC)
    box(name+"_Tapa", w+0.08, d+0.08, 0.07, x, y, z+h+0.035, MAD)

# ============================================================
# CASA A — AGRICULTOR (18 x 13, 2 plantas, 3,6 m)
# ============================================================
PARTS = []
box("AG_Zocalo", 18.4, 13.4, 0.3, 0, 0, 0.15, PIE)
box("AG_Piso_PB", 18.0, 13.0, 0.15, 0, 0, 0.375, MAD)
slab_hole("AG_Piso_PA", -9, 9, -6.5, 6.5, 2.25, 3.55, -6.3, -0.3, 4.05, 0.15, MAD)
wall_y("AG_Muro_N", 6.5, -9, 9, 0.45, 4.05, 0.20, MAD)
wall_x("AG_Muro_O", -9.0, -6.5, 6.5, 0.45, 4.05, 0.20, MAD)
wall_x("AG_Muro_E", 9.0, -6.5, 6.5, 0.45, 4.05, 0.20, MAD)
wall_y("AG_Muro_N2", 6.5, -9, 9, 4.2, 7.8, 0.20, MAD)
wall_x("AG_Muro_O2", -9.0, -6.5, 6.5, 4.2, 7.8, 0.20, MAD)
wall_x("AG_Muro_E2", 9.0, -6.5, 6.5, 4.2, 7.8, 0.20, MAD)
wall_x("AG_Tab_O1", -2.0, -6.5, 2.0, 0.45, 4.05, 0.16, MAD, [(-3.5, 1.6, 2.3), (0.0, 1.6, 2.3)])
wall_x("AG_Tab_E1", 3.5, -6.5, 2.0, 0.45, 4.05, 0.16, MAD, [(-3.5, 1.6, 2.3), (0.0, 1.6, 2.3)])
wall_y("AG_Tab_H1", 2.0, -9, 9, 0.45, 4.05, 0.16, MAD, [(-6.0, 1.6, 2.3), (0.0, 1.6, 2.3), (6.0, 1.6, 2.3)])
wall_x("AG_Tab_O2", -2.0, -6.5, 2.0, 4.2, 7.8, 0.16, MAD, [(-3.0, 1.6, 2.3), (0.0, 1.6, 2.3)])
wall_x("AG_Tab_E2", 3.5, -6.5, 2.0, 4.2, 7.8, 0.16, MAD, [(-3.0, 1.6, 2.3), (0.0, 1.6, 2.3)])
wall_y("AG_Tab_H2", 2.0, -9, 9, 4.2, 7.8, 0.16, MAD, [(-6.0, 1.6, 2.3), (0.0, 1.6, 2.3), (6.0, 1.6, 2.3)])
stairs("AG_Escalera", 2.9, -6.0, 0.45, 4.05, 1.3, 18)
roof("AG_Techo", 19.0, 14.0, 2.4, 0, 0, 7.8, PAJ)
box("AG_Cumbrera", 19.1, 0.16, 0.16, 0, 0, 10.2, OSC)
box("AG_Chimenea", 0.8, 0.8, 2.1, -5.5, 2.0, 8.6, PIE)
box("AG_Chimenea_Cap", 0.95, 0.95, 0.15, -5.5, 2.0, 9.7, PIE)
# silo
cyl("AG_Silo", 1.3, 5.0, 10.5, 4.0, 2.5, PIE, 14)
cone("AG_Silo_Techo", 1.5, 0.0, 1.0, 10.5, 4.0, 5.5, PAJ, 14)

# PB
# Cocina/comedor (left-front)
rug("AG_Alfombra_Cocina", -5.5, -2.0, 0.46, 5.0, 4.0, TEL)
box("AG_Estufa", 1.6, 1.1, 1.45, -8.0, 4.8, 1.18, MARF)
box("AG_Estufa_Hogar", 0.8, 0.6, 0.55, -8.0, 4.35, 0.95, EMI)
cyl("AG_Estufa_Tubo", 0.15, 1.4, -8.0, 5.2, 2.4, MET, 8)
table("AG_Mesa_Cocina", -5.5, -2.0, 0.46, 3.5, 1.5, 0.9, OSC)
for i, (dx, dy) in enumerate([(-1.2,-1.1),(0.0,-1.1),(1.2,-1.1),(-1.2,1.1),(0.0,1.1),(1.2,1.1)]):
    chair("AG_Silla_Cocina%d" % i, -5.5+dx, -2.0+dy, 0.46, rz=0 if dy < 0 else math.pi)
shelf("AG_Alacena", -8.6, 0.0, 0.46, 0.5, 2.2, 2.2, 4, goods=True)
# mantequera y costales
cyl("AG_Mantequera", 0.25, 0.7, -7.5, 1.0, 0.8, MARF, 10)
for i in range(3):
    sph("AG_Costal%d" % i, 0.28, -3.0, -5.8+i*0.6, 0.75, TRIGO, 8, 6)
# Vestíbulo
rug("AG_Alfombra_Vest", -0.5, -3.5, 0.46, 3.5, 3.5, VINO)
table("AG_Consola", -1.2, -5.8, 0.46, 1.6, 0.45, 0.85)
chandelier("AG_Araña", -0.5, -3.0, 5.6, 0.7)
plant("AG_Planta_Vest", 1.4, -5.6, 0.46, 1.0)
# Granero/establo (right-front)
for i, (x, y) in enumerate([(5.0,-5.0),(6.5,-5.0),(5.0,-3.5),(6.5,-3.5)]):
    box("AG_Paca%d" % i, 1.2, 0.8, 0.6, x, y, 0.8, TRIGO)
box("AG_Carretilla", 1.4, 0.7, 0.5, 7.5, -0.5, 0.8, OSC)
cyl("AG_Rueda", 0.3, 0.08, 7.5, -0.9, 0.55, OSC, 10, rx=math.pi/2)
# Despensa (back-left)
shelf("AG_Despensa1", -8.5, 4.0, 0.46, 0.5, 2.2, 2.4, 4, goods=True)
shelf("AG_Despensa2", -5.5, 4.0, 0.46, 2.0, 2.2, 0.5, 4, goods=True)
barrel("AG_Barril1", -3.0, 5.5, 0.46)
barrel("AG_Barril2", -3.8, 5.5, 0.46)
# Almacén herramientas (back-center)
table("AG_Mesa_Trabajo", 0.5, 4.5, 0.46, 2.4, 0.9, 0.95, OSC)
box("AG_Herramientas", 2.8, 0.12, 1.6, 2.8, 4.5, 1.8, OSC)
box("AG_Arado", 0.2, 1.6, 0.12, 0.2, 3.0, 0.8, MET, rx=math.radians(15))
# Cuarto de ordeño (back-right)
for i in range(3):
    cyl("AG_Lechera%d" % i, 0.18, 0.5, 4.5+i*0.7, 5.2, 0.75, MET, 10)
box("AG_Banqueta", 0.5, 0.35, 0.45, 7.5, 4.0, 0.7, MAD)

# PA
# Dormitorio principal
rug("AG_Alfombra_Dorm", -5.5, -3.0, 4.13, 5.0, 4.0, VINO)
bed("AG_Cama_Dosel", -5.5, -3.5, 4.13, 2.4, 2.6, canopy=True)
wardrobe("AG_Armario", -8.4, 1.0, 4.13, 2.4, 2.7, 0.75)
table("AG_Mesa_Noche1", -6.9, -5.3, 4.13, 0.5, 0.5, 0.55)
table("AG_Mesa_Noche2", -4.1, -5.3, 4.13, 0.5, 0.5, 0.55)
# Distribuidor
rug("AG_Alfombra_Pasillo", -0.5, -2.5, 4.13, 1.8, 5.0, VINO)
table("AG_Consola_PA", -1.2, -5.8, 4.13, 1.6, 0.45, 0.85)
chandelier("AG_Araña_PA", -0.5, -2.5, 7.0, 0.65)
plant("AG_Planta_PA", 1.4, -5.6, 4.13, 1.0)
# Dormitorio infantil
bed("AG_Cama_Nino", 6.0, -3.5, 4.13, 1.5, 2.2, canopy=False)
table("AG_Escritorio_Nino", 7.8, -1.0, 4.13, 1.6, 0.7, 0.8)
chair("AG_Silla_Nino", 7.8, -1.8, 4.13)
box("AG_Baul", 0.9, 0.6, 0.6, 4.2, -5.5, 4.4, VINO)
rug("AG_Alfombra_Nino", 6.0, -3.0, 4.13, 3.5, 3.0, VER)
# Taller
table("AG_Mesa_Taller", -5.5, 4.2, 4.13, 2.4, 0.9, 0.95, OSC)
shelf("AG_Estante_Taller", -8.5, 4.0, 4.13, 0.5, 2.2, 2.0, 4)
# Telar
for dx in (-0.8, 0.8):
    box("AG_Telar_Marco", 0.1, 0.1, 1.9, -3.0+dx, 5.2, 5.1, OSC)
box("AG_Telar_Sup", 1.7, 0.1, 0.1, -3.0, 5.2, 6.0, OSC)
box("AG_Telar_Inf", 1.7, 0.1, 0.1, -3.0, 5.2, 4.2, OSC)
# Almacén semillas
shelf("AG_Semillas1", -1.2, 4.0, 4.13, 0.5, 2.2, 2.0, 4, goods=True)
for i in range(3):
    sph("AG_Saco_Semilla%d" % i, 0.26, 1.5, 5.5, 4.4, TRIGO, 8, 6)
# Lavadero
box("AG_Lavadero", 1.4, 0.7, 0.8, 7.0, 5.2, 0.85, PIE)
box("AG_Lavadero_Agua", 1.2, 0.5, 0.05, 7.0, 5.2, 1.27, AGUA)
cyl("AG_Barril_Agua", 0.35, 0.8, 4.5, 5.2, 0.85, OSC, 10)

agricultor = bpy.data.objects.new("CASA_AGRICULTOR", None)
bpy.context.collection.objects.link(agricultor)
for ob in PARTS:
    ob.parent = agricultor
    ob.matrix_parent_inverse = Matrix.Identity(4)
agricultor.location = (-11.0, 0, 0)
print("Agricultor:", len(PARTS), "piezas")

# ============================================================
# CASA B — MERCADER (16 x 12, 2 plantas, 3,8 m)
# ============================================================
PARTS = []
box("ME_Zocalo", 16.4, 12.4, 0.3, 0, 0, 0.15, PIE)
box("ME_Piso_PB", 16.0, 12.0, 0.15, 0, 0, 0.375, MAD)
slab_hole("ME_Piso_PA", -8, 8, -6, 6, 1.8, 3.0, -5.8, 0.5, 4.3, 0.15, MAD)
wall_y("ME_Muro_N", 6.0, -8, 8, 0.5, 4.3, 0.20, MAD)
wall_x("ME_Muro_O", -8.0, -6, 6, 0.5, 4.3, 0.20, MAD)
wall_x("ME_Muro_E", 8.0, -6, 6, 0.5, 4.3, 0.20, MAD)
wall_y("ME_Muro_N2", 6.0, -8, 8, 4.45, 8.25, 0.20, MAD)
wall_x("ME_Muro_O2", -8.0, -6, 6, 4.45, 8.25, 0.20, MAD)
wall_x("ME_Muro_E2", 8.0, -6, 6, 4.45, 8.25, 0.20, MAD)
wall_x("ME_Tab_O1", -1.5, -6, 2, 0.5, 4.3, 0.16, MAD, [(-3.5, 1.6, 2.4), (0.0, 1.6, 2.4)])
wall_x("ME_Tab_E1", 3.0, -6, 2, 0.5, 4.3, 0.16, MAD, [(-3.5, 1.6, 2.4), (0.0, 1.6, 2.4)])
wall_y("ME_Tab_H1", 2.0, -8, 8, 0.5, 4.3, 0.16, MAD, [(-5.0, 1.6, 2.4), (0.0, 1.6, 2.4), (5.0, 1.6, 2.4)])
wall_x("ME_Tab_O2", -1.5, -6, 2, 4.45, 8.25, 0.16, MAD, [(-3.0, 1.6, 2.4), (0.0, 1.6, 2.4)])
wall_x("ME_Tab_E2", 3.0, -6, 2, 4.45, 8.25, 0.16, MAD, [(-3.0, 1.6, 2.4), (0.0, 1.6, 2.4)])
wall_y("ME_Tab_H2", 2.0, -8, 8, 4.45, 8.25, 0.16, MAD, [(-5.0, 1.6, 2.4), (0.0, 1.6, 2.4), (5.0, 1.6, 2.4)])
stairs("ME_Escalera", 2.4, -5.5, 0.5, 4.3, 1.2, 19)
roof("ME_Techo", 17.0, 13.0, 2.6, 0, 0, 8.25, PAJ)
box("ME_Cumbrera", 17.1, 0.16, 0.16, 0, 0, 10.85, OSC)
box("ME_Chimenea", 0.7, 0.7, 2.0, 5.5, 2.0, 9.2, PIE)
box("ME_Chimenea_Cap", 0.85, 0.85, 0.14, 5.5, 2.0, 10.2, PIE)
# toldo y cartel
box("ME_Toldo", 4.0, 0.1, 0.08, -5.0, -6.2, 3.4, ROJO, rx=math.radians(-12))
for x in (-6.8, -3.2):
    cyl("ME_Toldo_Post", 0.04, 2.0, x, -6.2, 2.4, OSC, 6)
box("ME_Cartel", 2.2, 0.08, 0.6, -5.0, -6.4, 3.0, OSC)
box("ME_Cartel_Texto", 1.9, 0.03, 0.35, -5.0, -6.45, 3.0, ORO)

# PB
# Tienda (left-front)
rug("ME_Alfombra_Tienda", -5.0, -3.0, 0.55, 4.5, 4.0, VINO)
counter("ME_Mostrador", -5.5, -4.0, 0.55, 3.6, 0.8, 0.95)
counter("ME_Mostrador_L", -7.3, -2.2, 0.55, 0.8, 2.6, 0.95)
shelf("ME_Estantes_Tienda", -7.5, 0.5, 0.55, 0.5, 2.4, 3.0, 4, goods=True)
shelf("ME_Estantes_Tienda2", -3.0, 0.8, 0.55, 2.0, 2.4, 0.5, 4, goods=True)
cyl("ME_Balanza_Base", 0.18, 0.1, -5.5, -3.2, 1.55, ORO, 8)
cyl("ME_Balanza_Vastago", 0.03, 0.6, -5.5, -3.2, 1.9, ORO, 6)
box("ME_Balanza_Brazo", 0.8, 0.05, 0.05, -5.5, -3.2, 2.2, ORO)
sph("ME_Balanza_Platillo1", 0.12, -5.9, -3.2, 2.05, ORO, 8, 6)
sph("ME_Balanza_Platillo2", 0.12, -5.1, -3.2, 2.05, ORO, 8, 6)
box("ME_Caja_Fuerte", 0.7, 0.6, 0.8, -2.2, -5.0, 1.0, MET)
crate("ME_Caja1", -2.8, -1.5, 0.55, 0.7)
crate("ME_Caja2", -2.0, -1.5, 0.55, 0.6)
barrel("ME_Barril_Tienda", -1.0, 0.5, 0.55)
# Vestíbulo
rug("ME_Alfombra_Vest", -0.5, -3.5, 0.55, 3.0, 3.0, VINO)
table("ME_Consola", -1.0, -5.6, 0.55, 1.4, 0.4, 0.85)
chandelier("ME_Araña", -0.5, -3.0, 6.0, 0.7)
plant("ME_Planta_Vest", 1.2, -5.5, 0.55, 0.9)
# Almacén (right-front)
barrel("ME_Barril1", 5.0, -5.0, 0.55)
barrel("ME_Barril2", 6.0, -5.0, 0.55)
crate("ME_Crate1", 7.0, -5.0, 0.55, 0.8)
crate("ME_Crate2", 7.0, -4.0, 0.55, 0.7)
crate("ME_Crate3", 5.0, -4.0, 0.55, 0.6)
for i in range(3):
    sph("ME_Saco%d" % i, 0.28, 4.5, -1.5+i*0.6, 0.85, TRIGO, 8, 6)
shelf("ME_Estante_Almacen", 7.5, 0.5, 0.55, 0.5, 2.2, 2.4, 4, goods=True)
# Trastienda/oficina (back-left)
table("ME_Escritorio_Of", -5.0, 4.0, 0.55, 2.2, 0.9, 0.85, OSC)
chair("ME_Silla_Of", -5.0, 3.0, 0.55)
shelf("ME_Estante_Of", -7.5, 4.0, 0.55, 0.5, 2.2, 2.0, 4, goods=True)
box("ME_Caja_Fuerte2", 0.6, 0.5, 0.7, -2.5, 5.0, 0.9, MET)
# Cocina (back-center)
box("ME_Estufa", 1.4, 0.9, 1.3, -0.5, 5.3, 1.1, MARF)
box("ME_Estufa_Hogar", 0.7, 0.5, 0.5, -0.5, 4.95, 0.85, EMI)
table("ME_Mesa_Cocina", 0.5, 3.2, 0.55, 2.0, 1.0, 0.85)
chair("ME_Silla_Cocina1", 0.0, 2.4, 0.55, rz=math.pi)
chair("ME_Silla_Cocina2", 1.0, 2.4, 0.55, rz=math.pi)
shelf("ME_Alacena", 2.5, 4.0, 0.55, 0.4, 2.0, 1.6, 4, goods=True)
# Baño (back-right)
box("ME_Bañera", 1.6, 0.8, 0.55, 5.5, 5.2, 0.8, COBRE)
box("ME_Bañera_Agua", 1.4, 0.6, 0.05, 5.5, 5.2, 1.08, AGUA)
cyl("ME_Lavabo", 0.28, 0.15, 7.0, 3.2, 1.2, MARF, 10)
box("ME_Espejo", 0.7, 0.05, 0.9, 7.6, 3.2, 2.0, CRY)

# PA
# Dormitorio principal
rug("ME_Alfombra_Dorm", -5.0, -3.0, 4.53, 4.5, 4.0, VINO)
bed("ME_Cama_Dosel", -5.0, -3.5, 4.53, 2.2, 2.4, canopy=True)
wardrobe("ME_Armario", -7.4, 1.0, 4.53, 2.2, 2.6, 0.7)
table("ME_Mesa_Noche1", -6.2, -5.0, 4.53, 0.5, 0.5, 0.55)
table("ME_Mesa_Noche2", -3.8, -5.0, 4.53, 0.5, 0.5, 0.55)
# Distribuidor
rug("ME_Alfombra_Pasillo", -0.5, -2.5, 4.53, 1.8, 5.0, VINO)
table("ME_Consola_PA", -1.0, -5.6, 4.53, 1.4, 0.4, 0.85)
chandelier("ME_Araña_PA", -0.5, -2.5, 7.4, 0.65)
plant("ME_Planta_PA", 1.2, -5.5, 4.53, 0.9)
# Dormitorio de invitados
bed("ME_Cama_Inv", 5.5, -3.5, 4.53, 1.6, 2.2, canopy=False)
table("ME_Escritorio_Inv", 7.0, -1.0, 4.53, 1.5, 0.7, 0.8)
chair("ME_Silla_Inv", 7.0, -1.8, 4.53)
wardrobe("ME_Armario_Inv", 4.0, 1.0, 4.53, 1.8, 2.3, 0.65)
rug("ME_Alfombra_Inv", 5.5, -3.0, 4.53, 3.5, 3.0, VER)
# Estudio/contabilidad
table("ME_Escritorio_Est", -5.0, 4.2, 4.53, 2.4, 1.0, 0.9, OSC)
chair("ME_Silla_Est", -5.0, 3.2, 4.53)
shelf("ME_Estante_Est", -7.5, 4.0, 4.53, 0.5, 2.4, 2.0, 4, goods=True)
box("ME_Caja_Fuerte3", 0.6, 0.5, 0.7, -2.5, 5.0, 4.9, MET)
sph("ME_Globo", 0.3, -2.0, 3.2, 5.2, VER, 12, 8)
# Sala de estar
rug("ME_Alfombra_Sala", -0.5, 3.2, 4.53, 3.5, 3.0, VINO)
box("ME_Sofa", 0.9, 2.2, 0.45, -0.8, 3.2, 4.95, VINO)
box("ME_Sofa_Respaldo", 0.25, 2.2, 0.8, -1.15, 3.2, 5.3, VINO)
chair("ME_Sillon1", 1.0, 3.2, 4.53, rz=math.pi/2, m=VINO)
chair("ME_Sillon2", 0.2, 3.2, 4.53, rz=-math.pi/2, m=VINO)
table("ME_Mesa_Raton", 0.1, 3.2, 4.53, 0.8, 1.4, 0.45)
box("ME_Chimenea", 0.6, 1.6, 1.8, 2.8, 4.0, 5.4, PIE)
box("ME_Chimenea_Hogar", 0.3, 1.0, 0.8, 2.55, 4.0, 5.0, EMI)
# Vestidor
wardrobe("ME_Vestidor", 7.4, 4.0, 4.53, 2.2, 2.6, 0.7)
box("ME_Banco", 1.4, 0.5, 0.45, 5.5, 5.2, 4.75, VINO)
box("ME_Espejo_Vest", 0.8, 0.05, 1.8, 7.8, 3.0, 5.4, CRY)

mercader = bpy.data.objects.new("CASA_MERCADER", None)
bpy.context.collection.objects.link(mercader)
for ob in PARTS:
    ob.parent = mercader
    ob.matrix_parent_inverse = Matrix.Identity(4)
mercader.location = (12.0, 0, 0)
print("Mercader:", len(PARTS), "piezas")

# ---------------- SUELO / LUZ / CÁMARA ----------------
box("Suelo_Extra", 70.0, 50.0, 0.04, 0, 0, -0.02, ARE)
sun_data = bpy.data.lights.new("Sol_Extra", 'SUN')
sun_data.energy = 2.4; sun_data.angle = math.radians(8)
sun = bpy.data.objects.new("Sol_Extra", sun_data)
bpy.context.collection.objects.link(sun)
sun.location = (10, -12, 18); sun.rotation_euler = (math.radians(46), 0, math.radians(25))
cam_data = bpy.data.cameras.new("Camara_Extra"); cam_data.lens = 52
cam = bpy.data.objects.new("Camara_Extra", cam_data)
bpy.context.collection.objects.link(cam)
cam.location = (0, -45, 22)
tgt = bpy.data.objects.new("Camara_Extra_Target", None)
bpy.context.collection.objects.link(tgt); tgt.location = (0, 0, 3.5)
c = cam.constraints.new(type='TRACK_TO'); c.target = tgt
c.track_axis = 'TRACK_NEGATIVE_Z'; c.up_axis = 'UP_Y'
scene.camera = cam

# ---------------- VALIDADOR ----------------
def aabb(ob):
    mn = Vector((1e9,1e9,1e9)); mx = Vector((-1e9,-1e9,-1e9))
    for c in ob.bound_box:
        w = ob.matrix_world @ Vector(c)
        for i in range(3):
            mn[i] = min(mn[i], w[i]); mx[i] = max(mx[i], w[i])
    return mn, mx

def overlap(a,b,tol=0.02):
    amn,amx=a; bmn,bmx=b
    dx=min(amx.x,bmx.x)-max(amn.x,bmn.x); dy=min(amx.y,bmx.y)-max(amn.y,bmn.y); dz=min(amx.z,bmx.z)-max(amn.z,bmn.z)
    if dx>tol and dy>tol and dz>tol: return dx*dy*dz,min(dx,dy,dz)
    return 0.0,0.0

SOLID=("Muro","Tab","Escalera","Invernadero_Techo","Silo")
def is_solid(n): return any(k in n for k in SOLID)
def is_floor(n): return any(k in n for k in ("Piso","Zocalo","Suelo","Terraza","Techo"))

# world: Agricultor root -11, Mercader +12
HOLES={"CASA_AGRICULTOR":(-11+2.25,-11+3.55,-6.3,-0.3,4.0),"CASA_MERCADER":(12+1.8,12+3.0,-5.8,0.5,4.45)}
def same_group(a,b):
    for k in ("_Base","_Respaldo","_Brazo","_Hogar","_Tapa","_Poste","_Colchon","_Manta","_Almohada","_Cabecera","_Banda","_Aro"):
        if k in a and k in b: return True
    return a.split(".")[0].split("_")[0]==b.split(".")[0].split("_")[0] and a!=b

for hname in ("CASA_AGRICULTOR","CASA_MERCADER"):
    root=bpy.data.objects[hname]; meshes=[o for o in root.children_recursive if o.type=='MESH']
    boxes=[(o,*aabb(o)) for o in meshes]
    furn=[b for b in boxes if not is_floor(b[0].name) and not is_solid(b[0].name)]
    solid=[b for b in boxes if is_solid(b[0].name)]
    hits=[]
    for fo,fmn,fmx in furn:
        for so,smn,smx in solid:
            if "Chimenea" in fo.name and "Techo" in so.name: continue
            vol,pen=overlap((fmn,fmx),(smn,smx))
            if vol>0.005: hits.append((vol,pen,fo.name,so.name))
    hits.sort(reverse=True)
    hx0,hx1,hy0,hy1,hz=HOLES[hname]
    hole_hits=[]
    for fo,fmn,fmx in furn:
        if fmn.z < hz-0.15: continue
        dx=min(fmx.x,hx1)-max(fmn.x,hx0); dy=min(fmx.y,hy1)-max(fmn.y,hy0)
        if dx>0.05 and dy>0.05: hole_hits.append((dx*dy,fo.name))
    hole_hits.sort(reverse=True)
    ff=[]
    for i in range(len(furn)):
        fo,fmn,fmx=furn[i]
        for j in range(i+1,len(furn)):
            go,gmn,gmx=furn[j]
            if same_group(fo.name,go.name): continue
            vol,pen=overlap((fmn,fmx),(gmn,gmx),0.0)
            if vol>0.005: ff.append((vol,pen,fo.name,go.name))
    ff.sort(reverse=True)
    print("====",hname,"====")
    print("muebles:",len(furn),"| estructura sólida:",len(solid))
    print("solapes mueble-estructura:",len(hits))
    for v,p,a,b in hits[:8]: print("  %.3f pen=%.2f | %s <-> %s"%(v,p,a,b))
    print("sobre el hueco:",len(hole_hits))
    for v,a in hole_hits[:8]: print("  %.2f | %s"%(v,a))
    print("mueble-mueble:",len(ff))
    for v,p,a,b in ff[:8]: print("  %.3f pen=%.2f | %s <-> %s"%(v,p,a,b))

bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
scene.render.filepath = os.path.join(CAPT, "casas_extra_exterior_2026-11-12.png")
bpy.ops.render.render(write_still=True)
print("Guardado:", BLEND_OUT)
print("Render:", scene.render.filepath)
print("Total objetos global:", len(bpy.data.objects))