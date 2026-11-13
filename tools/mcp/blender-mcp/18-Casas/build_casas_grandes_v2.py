# -*- coding: utf-8 -*-
# ERNIE-5.5-Flash-Preview / Kilo Code — Casas grandes v2 (más amplias, sin solapes).
# Casona 20x15 m, Mansión 28x20 m. Menos objetos, holguras verificadas.

import bpy, bmesh, math, os
from mathutils import Matrix, Vector

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\18-Casas"
BLEND_OUT = os.path.join(BASE, "casas_ernie_grandes_v2_2026-11-12.blend")
CAPT = os.path.join(BASE, "CAPTURAS")
os.makedirs(CAPT, exist_ok=True)

# ---------------- ESCENA ----------------
if "Casas_Grandes_v2" in bpy.data.scenes:
    old = bpy.data.scenes["Casas_Grandes_v2"]
    for ob in list(old.objects):
        bpy.data.objects.remove(ob, do_unlink=True)
    bpy.data.scenes.remove(old)

scene = bpy.data.scenes.new("Casas_Grandes_v2")
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

world = bpy.data.worlds.new("Mundo_Grandes_v2")
scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get("Background")
bg.inputs[0].default_value = (0.45, 0.62, 0.85, 1.0)
bg.inputs[1].default_value = 0.35

# ---------------- MATERIALES ----------------
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

PARTS = []
def _finish(name, bm, m, x, y, z, rx=0.0, ry=0.0, rz=0.0):
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
    return _finish(name, bm, m, x, y, z, rx, ry, rz)

def cyl(name, r, depth, x, y, z, m, segments=10, rx=0.0, ry=0.0, rz=0.0):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=segments,
                          radius1=r, radius2=r, depth=depth)
    return _finish(name, bm, m, x, y, z, rx, ry, rz)

def cone(name, r1, r2, depth, x, y, z, m, segments=10):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=segments,
                          radius1=r1, radius2=r2, depth=depth)
    return _finish(name, bm, m, x, y, z)

def sph(name, r, x, y, z, m, u=12, v=8):
    bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=u, v_segments=v, radius=r)
    return _finish(name, bm, m, x, y, z)

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

# ---------------- MOBILIARIO ----------------
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

def shelf(name, x, y, z, w, h, d, levels=4, m=MAD):
    box(name+"_L1", 0.07, d, h, x-w/2, y, z+h/2, m)
    box(name+"_L2", 0.07, d, h, x+w/2, y, z+h/2, m)
    box(name+"_Fondo", w, 0.05, h, x, y+d/2, z+h/2, m)
    for i in range(levels):
        zz = z + 0.12 + i*(h-0.22)/(levels-1)
        box(name+"_Balda%d" % i, w, d, 0.055, x, y, zz, m)
        for j in range(2):
            box(name+"_Libro%d_%d" % (i, j), 0.07, 0.22, 0.28,
                x-w/2+0.25+j*(w-0.5), y-0.07, zz+0.17, LIB if (i+j) % 2 else VINO)

def bed(name, x, y, z, w=2.2, l=2.4, canopy=True):
    box(name+"_Base", w, l, 0.40, x, y, z+0.28, OSC)
    box(name+"_Colchon", w-0.12, l-0.12, 0.26, x, y, z+0.60, TEL)
    box(name+"_Manta", w-0.06, l*0.60, 0.07, x, y+l*0.17, z+0.75, VINO)
    box(name+"_Almohada1", w*0.38, 0.34, 0.14, x-w*0.21, y-l/2+0.32, z+0.78, MARF)
    box(name+"_Almohada2", w*0.38, 0.34, 0.14, x+w*0.21, y-l/2+0.32, z+0.78, MARF)
    box(name+"_Cabecera", w, 0.15, 1.15, x, y-l/2, z+0.78, OSC)
    if canopy:
        for dx in (-w/2, w/2):
            for dy in (-l/2, l/2):
                cyl(name+"_Poste", 0.07, 2.4, x+dx, y+dy, z+1.5, OSC, 8)
        box(name+"_Dosel", w+0.28, l+0.28, 0.09, x, y, z+2.7, VINO)
        box(name+"_Toldo", w+0.22, 0.06, 0.8, x, y-l/2-0.06, z+2.3, VINO)

def wardrobe(name, x, y, z, w=2.4, h=2.7, d=0.7):
    box(name, w, d, h, x, y, z+h/2, OSC)
    for i in range(2):
        box(name+"_Puerta%d" % i, w/2-0.06, 0.05, h-0.22, x-w/4+i*w/2, y-d/2, z+h/2, MAD)
        sph(name+"_Pomo%d" % i, 0.045, x-w/4+i*w/2+0.10, y-d/2-0.04, z+h/2, ORO, 8, 6)

def chandelier(name, x, y, z, r=1.0):
    cyl(name+"_Cadena", 0.02, 1.0, x, y, z+0.9, MET, 6)
    cyl(name+"_Cuerpo", 0.16, 0.32, x, y, z+0.35, ORO, 8)
    for i in range(8):
        a = i*math.pi/4
        ax, ay = x+r*math.cos(a), y+r*math.sin(a)
        cyl(name+"_Brazo%d" % i, 0.03, r, (x+ax)/2, (y+ay)/2, z+0.4, ORO, 6, rz=a, rx=math.pi/2)
        cyl(name+"_Vela%d" % i, 0.045, 0.22, ax, ay, z+0.58, MARF, 8)
        sph(name+"_Llama%d" % i, 0.055, ax, ay, z+0.74, EMI, 8, 6)

def plant(name, x, y, z, s=1.2):
    cyl(name+"_Maceta", 0.24*s, 0.38*s, x, y, z+0.19*s, COR, 8)
    cyl(name+"_Tallo", 0.035*s, 0.65*s, x, y, z+0.6*s, VER, 6)
    for i in range(6):
        a = i*2*math.pi/6
        sph(name+"_Hoja%d" % i, 0.21*s, x+0.19*s*math.cos(a), y+0.19*s*math.sin(a), z+0.85*s, VER, 8, 6)

def painting(name, x, y, z, w=1.5, h=1.1, rz=0.0):
    box(name+"_Marco", w+0.14, 0.09, h+0.14, x, y, z, ORO, rz=rz)
    box(name+"_Lienzo", w, 0.05, h, x, y-0.06, z, VINO, rz=rz)
    box(name+"_Cielo", w*0.7, 0.02, h*0.5, x, y-0.09, z+h*0.16, VER, rz=rz)

def display_case(name, x, y, z, artifact="vase"):
    box(name+"_Base", 1.1, 1.1, 1.1, x, y, z+0.55, OSC)
    box(name+"_Cristal", 0.95, 0.95, 1.2, x, y, z+1.7, CRY)
    box(name+"_Tapa", 1.15, 1.15, 0.09, x, y, z+2.34, ORO)
    if artifact == "vase":
        cyl(name+"_Vaso", 0.22, 0.6, x, y, z+1.45, COR, 10)
        cyl(name+"_Cuello", 0.11, 0.24, x, y, z+1.85, COR, 8)
    elif artifact == "idol":
        box(name+"_Idolo", 0.36, 0.3, 0.65, x, y, z+1.5, PIE)
        sph(name+"_Idolo_Cabeza", 0.19, x, y, z+1.95, PIE, 8, 6)
    else:
        sph(name+"_Busto", 0.26, x, y, z+1.55, MARF, 10, 8)

def armor(name, x, y, z):
    box(name+"_Base", 0.7, 0.7, 0.18, x, y, z+0.09, PIE)
    box(name+"_Piernas", 0.42, 0.3, 0.9, x, y, z+0.6, MET)
    box(name+"_Torso", 0.6, 0.36, 0.8, x, y, z+1.4, MET)
    sph(name+"_Casco", 0.21, x, y, z+2.0, MET, 10, 6)
    box(name+"_Lanza", 0.05, 0.05, 2.4, x+0.42, y, z+1.3, OSC)
    cone(name+"_Lanza_Punta", 0.07, 0.0, 0.22, x+0.42, y, z+2.6, MET, 6)

def telescope(name, x, y, z):
    for i, (dx, dy) in enumerate([(-0.4,-0.25),(0.4,-0.25),(0.0,0.4)]):
        cyl(name+"_Pata%d" % i, 0.04, 1.7, x+dx, y+dy, z+0.85, MET, 6, rx=0.28 if dy < 0 else -0.28)
    cyl(name+"_Tubo", 0.15, 2.0, x, y, z+2.0, ORO, 12, rx=math.radians(55))
    cyl(name+"_Lente", 0.17, 0.09, x+0.58, y-0.58, z+2.7, CRY, 12, rx=math.radians(55))

def piano(name, x, y, z):
    box(name+"_Cuerpo", 2.8, 1.4, 0.4, x, y, z+1.0, OSC)
    box(name+"_Tapa", 2.8, 1.4, 0.07, x, y-0.12, z+1.22, OSC, rx=math.radians(-12))
    box(name+"_Teclado", 1.6, 0.4, 0.14, x, y-0.95, z+0.9, MARF)
    for i in range(14):
        box(name+"_Tecla%d" % i, 0.09, 0.34, 0.03, x-0.75+i*0.115, y-0.98, z+0.98, OSC)
    for dx in (-1.0, 1.0):
        for dy in (-0.45, 0.45):
            box(name+"_Pata", 0.14, 0.14, 0.85, x+dx, y+dy, z+0.42, OSC)

def harp(name, x, y, z):
    box(name+"_Base", 0.6, 0.4, 0.18, x, y, z+0.09, ORO)
    box(name+"_Columna", 0.12, 0.12, 2.0, x, y+0.18, z+1.1, ORO)
    box(name+"_Brazo", 0.09, 1.0, 0.09, x, y-0.28, z+2.1, ORO, rx=math.radians(20))
    for i in range(8):
        cyl(name+"_Cuerda%d" % i, 0.006, 1.35, x-0.18+i*0.05, y-0.16, z+1.3, MARF, 4)

def armillary(name, x, y, z):
    cyl(name+"_Soporte", 0.24, 0.12, x, y, z+0.06, OSC, 10)
    cyl(name+"_Palo", 0.05, 1.1, x, y, z+0.6, ORO, 6)
    for i, rz in enumerate((0, math.pi/3, 2*math.pi/3)):
        cyl(name+"_Anillo%d" % i, 0.52, 0.035, x, y, z+1.3, ORO, 18, rz=rz, rx=math.pi/2)
    sph(name+"_Esfera", 0.14, x, y, z+1.3, ORO, 10, 6)

def billiard(name, x, y, z):
    box(name+"_Base", 2.8, 1.5, 0.85, x, y, z+0.42, OSC)
    box(name+"_Fieltro", 2.6, 1.3, 0.07, x, y, z+0.88, VER)
    for dx in (-1.3, 1.3):
        for dy in (-0.65, 0.65):
            box(name+"_Pata", 0.16, 0.16, 0.85, x+dx, y+dy, z+0.42, OSC)
    for i in range(3):
        sph(name+"_Bola%d" % i, 0.07, x-0.5+i*0.5, y-0.25+i*0.25, z+0.98, [MARF, COR, ORO][i], 8, 6)

def hammock(name, x, y, z):
    for dx in (-1.2, 1.2):
        cyl(name+"_Poste", 0.07, 2.2, x+dx, y, z+1.1, OSC, 8)
    box(name+"_Tela", 2.4, 0.8, 0.07, x, y, z+1.2, TEL, rx=math.radians(10))

def candelabra(name, x, y, z):
    cyl(name+"_Pie", 0.18, 0.09, x, y, z+0.045, ORO, 8)
    cyl(name+"_Vastago", 0.05, 1.8, x, y, z+0.95, ORO, 6)
    for i, (dx, dy) in enumerate([(-0.3,0),(0.3,0),(0,-0.3),(0,0.3)]):
        cyl(name+"_Brazo%d" % i, 0.022, 0.34, x+dx, y+dy, z+1.9, ORO, 6, rz=math.atan2(dy,dx), rx=math.pi/2)
        cyl(name+"_Vela%d" % i, 0.04, 0.22, x+dx*1.35, y+dy*1.35, z+2.06, MARF, 8)

# ============================================================
# CASA A — CASONA DEL GREMIO v2 (20 x 15 m, 2 plantas, 3,6 m)
# ============================================================
PARTS = []
box("CG_Zocalo", 20.4, 15.4, 0.3, 0, 0, 0.15, PIE)
box("CG_Piso_PB", 20.0, 15.0, 0.15, 0, 0, 0.375, MAD)
slab_hole("CG_Piso_PA", -10, 10, -7.5, 7.5, 7.0, 9.2, -7.3, -1.0, 4.05, 0.15, MAD)
wall_y("CG_Muro_N", 7.5, -10, 10, 0.45, 4.05, 0.20, MAD)
wall_x("CG_Muro_O", -10.0, -7.5, 7.5, 0.45, 4.05, 0.20, MAD)
wall_x("CG_Muro_E", 10.0, -7.5, 7.5, 0.45, 4.05, 0.20, MAD)
wall_y("CG_Muro_N2", 7.5, -10, 10, 4.2, 7.8, 0.20, MAD)
wall_x("CG_Muro_O2", -10.0, -7.5, 7.5, 4.2, 7.8, 0.20, MAD)
wall_x("CG_Muro_E2", 10.0, -7.5, 7.5, 4.2, 7.8, 0.20, MAD)
# tabiques PB
wall_x("CG_Tab_O1", -3.0, -7.5, 2.5, 0.45, 4.05, 0.16, MAD, [(-4.5, 1.8, 2.4), (-0.5, 1.8, 2.4)])
wall_x("CG_Tab_E1", 3.5, -7.5, 2.5, 0.45, 4.05, 0.16, MAD, [(-4.5, 1.8, 2.4), (-0.5, 1.8, 2.4)])
wall_y("CG_Tab_H1", 2.5, -10, 10, 0.45, 4.05, 0.16, MAD, [(-6.5, 1.8, 2.4), (0.0, 1.8, 2.4), (6.5, 1.8, 2.4)])
# tabiques PA
wall_x("CG_Tab_O2", -3.0, -7.5, 2.5, 4.2, 7.8, 0.16, MAD, [(-4.0, 1.8, 2.4), (-0.5, 1.8, 2.4)])
wall_x("CG_Tab_E2", 3.5, -7.5, 2.5, 4.2, 7.8, 0.16, MAD, [(-4.0, 1.8, 2.4), (-0.5, 1.8, 2.4)])
wall_y("CG_Tab_H2", 2.5, -10, 10, 4.2, 7.8, 0.16, MAD, [(-6.5, 1.8, 2.4), (0.0, 1.8, 2.4), (6.5, 1.8, 2.4)])
# escalera (hueco y -7.3..-1.0; escalones -7.0..-1.6)
stairs("CG_Escalera", 8.1, -7.0, 0.45, 4.05, 1.8, 18)
roof("CG_Techo", 21.0, 16.0, 2.4, 0, 0, 7.8, PAJ)
box("CG_Cumbrera", 21.1, 0.16, 0.16, 0, 0, 10.2, OSC)
box("CG_Chimenea1", 0.8, 0.8, 2.1, -5.5, 2.0, 8.6, PIE)
box("CG_Chimenea1_Cap", 0.95, 0.95, 0.15, -5.5, 2.0, 9.7, PIE)
box("CG_Chimenea2", 0.8, 0.8, 2.1, 5.2, 2.2, 8.6, PIE)
box("CG_Chimenea2_Cap", 0.95, 0.95, 0.15, 5.2, 2.2, 9.7, PIE)

# ---------- PB ----------
# Sala de estar (x -10..-3, y -7.5..2.5)
rug("CG_Alfombra_Sala", -7.0, -5.0, 0.46, 5.0, 4.0, VER)
box("CG_Sofa_Base", 1.0, 3.0, 0.45, -9.3, -5.5, 0.68, VINO)
box("CG_Sofa_Respaldo", 0.25, 3.0, 0.9, -9.7, -5.5, 1.05, VINO)
box("CG_Sofa_Brazo1", 1.0, 0.25, 0.6, -9.3, -7.0, 0.78, VINO)
box("CG_Sofa_Brazo2", 1.0, 0.25, 0.6, -9.3, -4.0, 0.78, VINO)
table("CG_Mesa_Raton", -7.3, -5.5, 0.46, 1.0, 2.0, 0.45)
chair("CG_Sillon1", -7.3, -3.8, 0.46, rz=math.pi/2, m=VINO)
chair("CG_Sillon2", -7.3, -7.2, 0.46, rz=-math.pi/2, m=VINO)
box("CG_Chimenea", 0.7, 2.4, 2.0, -9.4, -1.0, 1.45, PIE)
box("CG_Chimenea_Hogar", 0.35, 1.4, 1.0, -9.1, -1.0, 0.95, EMI)
box("CG_Chimenea_Repisa", 0.8, 2.6, 0.14, -9.4, -1.0, 2.5, PIE)
shelf("CG_Estante_Sala", -9.5, 1.5, 0.46, 0.5, 2.4, 2.4, 4)
box("CG_Tapiz", 0.07, 2.0, 1.5, -9.85, -3.5, 2.4, VINO)
for i in range(4):
    box("CG_Tapiz_Glif%d" % i, 0.02, 0.24, 0.24, -9.80, -4.2+i*0.42, 2.5, ORO)
box("CG_Acuario_Base", 1.6, 0.65, 0.7, -4.2, 1.0, 0.8, OSC)
box("CG_Acuario_Vidrio", 1.45, 0.6, 1.2, -4.2, 1.0, 1.75, AGUA)
box("CG_Acuario_Marco", 1.65, 0.7, 0.09, -4.2, 1.0, 2.4, ORO)
for i in range(3):
    sph("CG_Acuario_Pez%d" % i, 0.07, -4.6+i*0.4, 0.95, 1.7, COR, 8, 6)
plant("CG_Planta_Sala", -9.2, 2.0, 0.46, 1.1)
# Vestíbulo (x -3..3.5, y -7.5..2.5)
rug("CG_Alfombra_Vest", 0.2, -4.0, 0.46, 5.0, 4.0, VINO)
cyl("CG_Fuente_Balsa", 1.2, 0.4, 0.2, -4.5, 0.68, PIE, 16)
cyl("CG_Fuente_Agua", 1.04, 0.05, 0.2, -4.5, 0.9, AGUA, 16)
cyl("CG_Fuente_Columna", 0.16, 1.2, 0.2, -4.5, 1.5, PIE, 8)
cyl("CG_Fuente_Taza", 0.6, 0.14, 0.2, -4.5, 2.15, PIE, 14)
sph("CG_Fuente_Bola", 0.16, 0.2, -4.5, 2.38, ORO, 10, 6)
table("CG_Consola", -2.2, -6.8, 0.46, 2.0, 0.5, 0.9, OSC)
box("CG_Espejo", 1.5, 0.07, 1.7, -2.2, -7.1, 2.2, CRY)
box("CG_Espejo_Marco", 1.65, 0.09, 1.85, -2.2, -7.08, 2.2, ORO)
box("CG_Reloj", 0.65, 0.4, 2.5, 2.8, -6.8, 1.7, OSC)
cyl("CG_Reloj_Cara", 0.22, 0.07, 2.8, -7.02, 2.6, MARF, 12, rx=math.pi/2)
box("CG_Reloj_Pendulo", 0.05, 0.05, 0.8, 2.8, -7.0, 1.3, ORO)
chandelier("CG_Araña", 0.2, -3.5, 6.4, 0.8)
plant("CG_Planta_Vest", 2.8, -5.8, 0.46, 1.0)
# Comedor (x 3.5..10, y -7.5..2.5)
rug("CG_Alfombra_Comedor", 6.8, -4.0, 0.46, 5.5, 4.5, VINO)
table("CG_Mesa_Comedor", 6.8, -4.0, 0.46, 3.6, 1.6, 0.9, OSC)
for i, (dx, dy) in enumerate([(-1.2,-1.2),(0.0,-1.2),(1.2,-1.2),(-1.2,1.2),(0.0,1.2),(1.2,1.2)]):
    chair("CG_Silla_Comedor%d" % i, 6.8+dx, -4.0+dy, 0.46, rz=0 if dy < 0 else math.pi)
box("CG_Aparador", 0.7, 2.8, 1.15, 9.4, -0.5, 1.05, OSC)
for i in range(2):
    box("CG_Aparador_Puerta%d" % i, 0.05, 1.2, 0.95, 9.04, -1.1+i*1.2, 1.05, MAD)
chandelier("CG_Araña_Comedor", 6.8, -4.0, 6.2, 0.65)
# Cocina (x -10..-3, y 2.5..7.5)
box("CG_Estufa", 1.6, 1.1, 1.45, -8.8, 6.7, 1.18, MARF)
box("CG_Estufa_Hogar", 0.8, 0.6, 0.55, -8.8, 6.25, 0.95, EMI)
cyl("CG_Estufa_Tubo", 0.15, 1.4, -8.8, 7.1, 2.4, MET, 8)
table("CG_Mesada", -5.5, 6.9, 0.46, 3.0, 0.75, 0.95, MAD)
box("CG_Mesada_Pila", 0.65, 0.45, 0.14, -6.2, 6.9, 1.05, MET)
shelf("CG_Estante_Cocina", -9.5, 4.0, 0.46, 0.5, 2.2, 2.0, 4)
table("CG_Mesa_Cocina", -5.5, 4.2, 0.46, 2.4, 1.1, 0.85)
for i, (dx, dy) in enumerate([(-0.9,-0.9),(0.9,-0.9),(-0.9,0.9),(0.9,0.9)]):
    chair("CG_Banqueta%d" % i, -5.5+dx, 4.2+dy, 0.46, rz=0 if dy < 0 else math.pi)
rug("CG_Alfombra_Cocina", -5.5, 4.2, 0.46, 4.0, 3.0, TEL)
# Estudio / biblioteca (x -3..3.5, y 2.5..7.5)
rug("CG_Alfombra_Estudio", 0.2, 5.2, 0.46, 5.0, 4.0, VER)
table("CG_Escritorio", 0.2, 6.7, 0.46, 2.6, 1.1, 0.9, OSC)
chair("CG_Silla_Estudio", 0.2, 5.7, 0.46, rz=0)
cyl("CG_Bib_Caracol_Eje", 0.15, 2.6, -2.2, 6.6, 1.75, OSC, 8)
for i in range(8):
    a = i*math.pi/4; rr = 0.7
    box("CG_Bib_Caracol_Balda%d" % i, 1.3, 0.45, 0.07, -2.2+rr*math.cos(a), 6.6+rr*math.sin(a), 0.8+i*0.26, MAD, rz=a)
    for j in range(2):
        box("CG_Bib_Caracol_Libro%d_%d" % (i,j), 0.07, 0.22, 0.26,
            -2.2+rr*math.cos(a)+0.25*(j-1), 6.6+rr*math.sin(a), 0.98+i*0.26, LIB if (i+j)%2 else VINO)
table("CG_Mesa_Alquimista", 2.6, 4.2, 0.46, 1.7, 0.9, 0.95, OSC)
for i in range(3):
    cyl("CG_Frasco%d" % i, 0.07, 0.25, 2.2+i*0.3, 4.1, 1.2, AGUA if i%2 else EMI, 8)
sph("CG_Alambique", 0.18, 3.0, 4.4, 1.25, CRY, 10, 6)
cyl("CG_Globo_Soporte", 0.2, 0.09, 2.8, 6.7, 0.55, OSC, 8)
cyl("CG_Globo_Palo", 0.04, 1.0, 2.8, 6.7, 1.05, OSC, 6)
sph("CG_Globo_Esfera", 0.38, 2.8, 6.7, 1.7, VER, 12, 8)
# Baño (x 3.5..10, y 2.5..7.5)
rug("CG_Alfombra_Bano", 6.5, 4.5, 0.46, 2.5, 2.0, TEL)
box("CG_Bañera_Cobre", 1.8, 0.9, 0.6, 6.5, 6.7, 0.75, COBRE)
box("CG_Bañera_Agua", 1.6, 0.7, 0.05, 6.5, 6.7, 1.06, AGUA)
cyl("CG_Lavabo_Pedestal", 0.14, 0.85, 8.8, 4.0, 0.9, MARF, 8)
cyl("CG_Lavabo_Bacha", 0.34, 0.16, 8.8, 4.0, 1.38, MARF, 10)
box("CG_Espejo_Bano", 0.8, 0.06, 1.0, 9.4, 4.0, 2.2, CRY)
box("CG_Espejo_Bano_Marco", 0.9, 0.07, 1.1, 9.4, 4.02, 2.2, ORO)

# ---------- PA ----------
# Dormitorio principal
rug("CG_Alfombra_Dorm", -7.0, -3.8, 4.13, 5.0, 4.0, VINO)
bed("CG_Cama_Dosel", -7.0, -4.5, 4.13, 2.6, 2.8, canopy=True)
wardrobe("CG_Armario", -9.4, 1.0, 4.13, 2.6, 2.8, 0.8)
table("CG_Mesa_Noche1", -8.5, -6.3, 4.13, 0.55, 0.55, 0.6)
table("CG_Mesa_Noche2", -5.5, -6.3, 4.13, 0.55, 0.55, 0.6)
cyl("CG_Lampara_Noche1", 0.09, 0.4, -8.5, -6.3, 5.05, ORO, 8)
cyl("CG_Lampara_Noche2", 0.09, 0.4, -5.5, -6.3, 5.05, ORO, 8)
chair("CG_Sillon_Dorm1", -8.8, -1.5, 4.13, rz=math.pi/2, m=VINO)
chair("CG_Sillon_Dorm2", -5.2, -1.5, 4.13, rz=-math.pi/2, m=VINO)
table("CG_Mesa_Dorm", -7.0, -1.5, 4.13, 1.0, 0.8, 0.5)
# Distribuidor
rug("CG_Alfombra_Pasillo", 0.2, -2.5, 4.13, 2.0, 6.0, VINO)
table("CG_Consola_PA", -2.2, -6.8, 4.13, 1.8, 0.5, 0.85)
cyl("CG_Jarron_PA", 0.18, 0.45, -2.2, -6.8, 5.0, COR, 8)
chandelier("CG_Araña_PA", 0.2, -2.5, 7.2, 0.7)
plant("CG_Planta_PA", 2.8, -6.5, 4.13, 1.0)
# Dormitorio infantil
bed("CG_Cama_Nino", 6.8, -4.5, 4.13, 1.6, 2.4, canopy=False)
table("CG_Escritorio_Nino", 8.8, -1.0, 4.13, 1.8, 0.8, 0.8)
chair("CG_Silla_Nino", 8.8, -1.9, 4.13, rz=0)
box("CG_Baul_Juguetes", 1.1, 0.7, 0.7, 4.5, -6.5, 4.5, VINO)
shelf("CG_Estante_Nino", 4.2, -1.0, 4.13, 0.5, 2.0, 1.8, 4)
rug("CG_Alfombra_Nino", 6.8, -3.8, 4.13, 4.5, 3.5, VER)
# Taller / observatorio
table("CG_Mesa_Trabajo", -7.0, 4.2, 4.13, 2.6, 1.0, 0.95, OSC)
chair("CG_Silla_Taller", -7.0, 3.2, 4.13, rz=0)
telescope("CG_Telescopio", -9.0, 6.5, 4.13)
for dx in (-0.8, 0.8):
    box("CG_Telar_Marco", 0.1, 0.1, 2.0, -4.5+dx, 6.5, 5.2, OSC)
box("CG_Telar_Superior", 1.7, 0.1, 0.1, -4.5, 6.5, 6.2, OSC)
box("CG_Telar_Inferior", 1.7, 0.1, 0.1, -4.5, 6.5, 4.2, OSC)
for i in range(6):
    box("CG_Telar_Hilo%d" % i, 0.012, 0.012, 1.8, -5.0+i*0.2, 6.5, 5.2, MARF)
shelf("CG_Estante_Taller", -9.5, 4.2, 4.13, 0.5, 2.2, 2.0, 4)
rug("CG_Alfombra_Taller", -7.0, 5.0, 4.13, 4.5, 3.5, VER)
# Estudio PA
table("CG_Escritorio2", 0.2, 6.7, 4.13, 2.4, 1.0, 0.9, OSC)
chair("CG_Silla_Estudio2", 0.2, 5.7, 4.13, rz=0)
shelf("CG_Estante_Estudio2", -2.2, 6.7, 4.13, 0.5, 2.4, 2.0, 4)
cyl("CG_Globo2_Sop", 0.2, 0.09, 2.6, 6.7, 4.18, OSC, 8)
sph("CG_Globo2_Esfera", 0.36, 2.6, 6.7, 4.8, VER, 12, 8)
rug("CG_Alfombra_Estudio2", 0.2, 5.2, 4.13, 4.5, 3.5, VINO)
# Vestidor / baño PA
wardrobe("CG_Vestidor", 9.4, 6.7, 4.13, 2.6, 2.9, 0.8)
box("CG_Banco_Vestidor", 1.9, 0.55, 0.5, 6.5, 6.9, 4.4, VINO)
box("CG_Espejo_Vestidor", 0.9, 0.06, 1.9, 9.4, 4.0, 5.4, CRY)
rug("CG_Alfombra_Vestidor", 6.5, 5.0, 4.13, 3.0, 2.5, TEL)

casona = bpy.data.objects.new("CASONA_GREMIO_V2", None)
bpy.context.collection.objects.link(casona)
for ob in PARTS:
    ob.parent = casona
    ob.matrix_parent_inverse = Matrix.Identity(4)
casona.location = (-13.0, 0, 0)
print("Casona v2:", len(PARTS), "piezas")

# ============================================================
# CASA B — MANSIÓN DEL MUSEO v2 (28 x 20 m, 2 plantas + torres, 4,0 m)
# ============================================================
PARTS = []
box("MM_Zocalo", 28.4, 20.4, 0.35, 0, 0, 0.175, PIE)
box("MM_Piso_PB", 28.0, 20.0, 0.15, 0, 0, 0.425, MAD)
slab_hole("MM_Piso_PA", -14, 14, -10, 10, 10.0, 12.5, -9.8, -2.8, 4.5, 0.15, MAD)
wall_y("MM_Muro_N", 10.0, -14, 14, 0.5, 4.5, 0.22, MAD)
wall_x("MM_Muro_O", -14.0, -10, 10, 0.5, 4.5, 0.22, MAD)
wall_x("MM_Muro_E", 14.0, -10, 10, 0.5, 4.5, 0.22, MAD)
wall_y("MM_Muro_N2", 10.0, -14, 14, 4.65, 8.65, 0.22, MAD)
wall_x("MM_Muro_O2", -14.0, -10, 10, 4.65, 8.65, 0.22, MAD)
wall_x("MM_Muro_E2", 14.0, -10, 10, 4.65, 8.65, 0.22, MAD)
# tabiques PB
wall_x("MM_Tab_O1", -4.5, -10, 4, 0.5, 4.5, 0.18, MAD, [(-5.5, 2.0, 2.8), (-1.0, 2.0, 2.8)])
wall_x("MM_Tab_E1", 5.0, -10, 4, 0.5, 4.5, 0.18, MAD, [(-5.5, 2.0, 2.8), (-1.0, 2.0, 2.8)])
wall_y("MM_Tab_H1", 4.0, -14, 14, 0.5, 4.5, 0.18, MAD, [(-9.5, 2.0, 2.8), (0.0, 2.0, 2.8), (9.5, 2.0, 2.8)])
# tabiques PA
wall_x("MM_Tab_O2", -4.5, -10, 4, 4.65, 8.65, 0.18, MAD, [(-5.0, 2.0, 2.8), (-1.0, 2.0, 2.8)])
wall_x("MM_Tab_E2", 5.0, -10, 4, 4.65, 8.65, 0.18, MAD, [(-5.0, 2.0, 2.8), (-1.0, 2.0, 2.8)])
wall_y("MM_Tab_H2", 4.0, -14, 14, 4.65, 8.65, 0.18, MAD, [(-9.5, 2.0, 2.8), (0.0, 2.0, 2.8), (9.5, 2.0, 2.8)])
# escalera (hueco y -9.8..-2.8; escalones -9.5..-3.1)
stairs("MM_Escalera", 11.2, -9.5, 0.5, 4.5, 2.2, 20)
roof("MM_Techo", 29.0, 21.0, 2.8, 0, 0, 8.65, PAJ)
box("MM_Cumbrera", 29.1, 0.18, 0.18, 0, 0, 11.45, OSC)
for sx in (-1, 1):
    cyl("MM_Torre", 1.8, 10.5, 13.0*sx, -9.0, 5.25, PIE, 14)
    cone("MM_Torre_Techo", 2.15, 0.0, 2.4, 13.0*sx, -9.0, 11.7, PAJ, 14)
    cyl("MM_Torre_Banda", 1.88, 0.2, 13.0*sx, -9.0, 8.5, OSC, 14)

# ---------- PB ----------
# Vestíbulo (x -4.5..5, y -10..4)
rug("MM_Alfombra_Vest", 0.0, -5.0, 0.55, 7.0, 5.0, VINO)
cyl("MM_Fuente_Balsa", 1.5, 0.45, 0.0, -5.5, 0.8, PIE, 18)
cyl("MM_Fuente_Agua", 1.3, 0.06, 0.0, -5.5, 1.05, AGUA, 18)
cyl("MM_Fuente_Columna", 0.2, 1.4, 0.0, -5.5, 1.6, PIE, 8)
cyl("MM_Fuente_Taza", 0.8, 0.16, 0.0, -5.5, 2.35, PIE, 16)
sph("MM_Fuente_Bola", 0.2, 0.0, -5.5, 2.6, ORO, 10, 6)
chandelier("MM_Araña_Vest", 0.0, -4.0, 8.2, 1.2)
table("MM_Mesa_Recep", -4.0, -8.5, 0.55, 2.8, 0.8, 0.9, OSC)
armor("MM_Armadura1", -5.0, -7.5, 0.55)
armor("MM_Armadura2", 5.0, -7.5, 0.55)
plant("MM_Planta_Vest1", -8.0, -8.5, 0.55, 1.2)
plant("MM_Planta_Vest2", 8.0, -8.5, 0.55, 1.2)
# Galería (x -14..-4.5, y -10..4)
for i, y in enumerate((-7.0, -3.5, 0.0)):
    display_case("MM_Vitrina%d" % i, -11.5, y, 0.55, ["vase","idol","bust"][i])
for i, x in enumerate((-12.5, -10.5, -8.5, -6.5)):
    painting("MM_Cuadro%d" % i, x, 3.8, 2.8, 1.5, 1.1)
cyl("MM_Pedestal", 0.55, 1.4, -8.0, -3.5, 1.3, PIE, 12)
sph("MM_Escultura", 0.45, -8.0, -3.5, 2.3, MARF, 12, 8)
for i, x in enumerate((-13.0, -5.0)):
    cyl("MM_Barrera_Poste%d" % i, 0.06, 1.0, x, -8.0, 1.1, ORO, 8)
box("MM_Barrera_Cuerda", 8.0, 0.03, 0.03, -9.0, -8.0, 1.55, VINO)
box("MM_Banco_Galeria", 2.4, 0.6, 0.5, -8.0, -9.0, 0.8, VINO)
# Biblioteca (x 5..14, y -10..4)
for i, x in enumerate((6.5, 9.0, 11.5)):
    shelf("MM_Bib_Est%d" % i, x, 3.7, 0.55, 1.8, 2.9, 0.5, 5)
table("MM_Mesa_Lectura1", 7.5, -4.5, 0.55, 2.8, 1.3, 0.9)
table("MM_Mesa_Lectura2", 11.5, -4.5, 0.55, 2.8, 1.3, 0.9)
for i, (dx, dy) in enumerate([(-0.9,-1.0),(0.9,-1.0),(-0.9,1.0),(0.9,1.0)]):
    chair("MM_Silla_Lect1_%d" % i, 7.5+dx, -4.5+dy, 0.55, rz=0 if dy < 0 else math.pi)
    chair("MM_Silla_Lect2_%d" % i, 11.5+dx, -4.5+dy, 0.55, rz=0 if dy < 0 else math.pi)
cyl("MM_Globo1_Sop", 0.22, 0.1, 6.0, -8.5, 0.6, OSC, 8)
sph("MM_Globo1", 0.4, 6.0, -8.5, 1.25, VER, 12, 8)
cyl("MM_Globo2_Sop", 0.22, 0.1, 13.0, 0.5, 0.6, OSC, 8)
sph("MM_Globo2", 0.4, 13.0, 0.5, 1.25, VER, 12, 8)
box("MM_Chimenea_Bib", 0.7, 2.4, 2.1, 13.4, -1.0, 1.6, PIE)
box("MM_Chimenea_Bib_Hogar", 0.35, 1.4, 1.0, 13.1, -1.0, 1.1, EMI)
billiard("MM_Billar", 9.0, 0.5, 0.55)
# Invernadero (x -14..-4.5, y 4..10)
for dx in (-13.5, -5.0):
    for dy in (4.5, 9.5):
        box("MM_Invernadero_Post", 0.12, 0.12, 3.6, dx, dy, 2.3, OSC)
box("MM_Invernadero_Techo", 8.6, 5.0, 0.08, -9.25, 7.0, 4.1, CRY)
box("MM_Invernadero_Techo2", 8.6, 0.08, 2.2, -9.25, 7.0, 5.0, CRY, rx=math.radians(35))
for i, (x, y) in enumerate([(-12.5,5.0),(-10.5,5.0),(-8.5,5.0),(-12.5,8.5),(-10.5,8.5),(-8.5,8.5)]):
    box("MM_Jardinera%d" % i, 1.3, 0.8, 0.5, x, y, 0.85, COR)
    plant("MM_Planta_Inv%d" % i, x, y, 1.1, 1.3)
cyl("MM_Fuente_Inv", 0.7, 0.35, -9.5, 6.8, 0.75, PIE, 14)
cyl("MM_Fuente_Inv_Agua", 0.6, 0.05, -9.5, 6.8, 0.95, AGUA, 14)
box("MM_Banco_Inv", 2.4, 0.6, 0.5, -6.0, 8.8, 0.8, VINO)
hammock("MM_Hamaca", -6.5, 6.5, 0.55)
# Cocina (x -4.5..5, y 4..10)
box("MM_Estufa", 2.2, 1.2, 1.6, -2.5, 9.1, 1.3, MARF)
box("MM_Estufa_Hogar", 1.0, 0.7, 0.6, -2.5, 8.6, 1.0, EMI)
cyl("MM_Estufa_Tubo", 0.18, 1.6, -2.5, 9.6, 2.7, MET, 8)
table("MM_Mesada_Cocina", 2.0, 9.3, 0.55, 4.0, 0.8, 0.95)
box("MM_Pila_Cocina", 0.8, 0.5, 0.14, 1.0, 9.3, 1.05, MET)
shelf("MM_Estante_Cocina", 4.5, 5.0, 0.55, 0.5, 2.4, 2.0, 4)
table("MM_Mesa_Cocina", 0.0, 6.5, 0.55, 3.2, 1.3, 0.9)
for i, (dx, dy) in enumerate([(-1.2,-1.0),(0.0,-1.0),(1.2,-1.0),(-1.2,1.0),(0.0,1.0),(1.2,1.0)]):
    chair("MM_Silla_Cocina%d" % i, 0.0+dx, 6.5+dy, 0.55, rz=0 if dy < 0 else math.pi)
# Comedor de gala (x 5..14, y 4..10)
rug("MM_Alfombra_Comedor", 9.5, 6.5, 0.55, 8.0, 5.0, VINO)
table("MM_Mesa_Gala", 9.5, 6.8, 0.55, 6.0, 2.0, 0.95, OSC)
for i in range(12):
    a = i*2*math.pi/12
    chair("MM_Silla_Gala%d" % i, 9.5+3.3*math.cos(a), 6.8+1.7*math.sin(a), 0.55, rz=a+math.pi/2)
chandelier("MM_Araña_Comedor", 9.5, 6.8, 8.0, 0.95)
box("MM_Aparador_Gala", 0.8, 3.4, 1.2, 13.3, 6.8, 1.15, OSC)
for i in range(3):
    box("MM_Aparador_Puerta%d" % i, 0.06, 1.0, 0.95, 12.88, 5.6+i*1.2, 1.15, MAD)

# ---------- PA ----------
# Dormitorio principal
rug("MM_Alfombra_Dorm", -9.5, -4.5, 4.73, 6.0, 5.0, VINO)
bed("MM_Cama_Dosel", -9.5, -5.0, 4.73, 3.0, 3.2, canopy=True)
wardrobe("MM_Armario_Dorm", -13.4, 1.5, 4.73, 3.0, 2.9, 0.8)
table("MM_Mesa_Salon", -9.5, -1.5, 4.73, 1.2, 0.9, 0.55)
chair("MM_Sillon1", -11.5, -1.5, 4.73, rz=math.pi/2, m=VINO)
chair("MM_Sillon2", -7.5, -1.5, 4.73, rz=-math.pi/2, m=VINO)
candelabra("MM_Candelabro_Dorm", -13.0, -1.5, 4.73)
# Distribuidor
rug("MM_Alfombra_Pasillo", 0.0, -3.5, 4.73, 2.5, 8.0, VINO)
table("MM_Consola_PA", -3.5, -9.2, 4.73, 2.2, 0.55, 0.9)
armor("MM_Armadura_PA", 4.0, -9.0, 4.73)
chandelier("MM_Araña_PA", 0.0, -3.5, 8.6, 0.85)
plant("MM_Planta_PA", 5.5, -9.2, 4.73, 1.1)
# Dormitorio de invitados
bed("MM_Cama_Inv", 9.5, -5.0, 4.73, 2.0, 2.6, canopy=False)
table("MM_Escritorio_Inv", 12.5, -1.5, 4.73, 2.0, 0.8, 0.85)
chair("MM_Silla_Inv", 12.5, -2.6, 4.73, rz=0)
wardrobe("MM_Armario_Inv", 6.0, 1.5, 4.73, 2.4, 2.6, 0.7)
rug("MM_Alfombra_Inv", 9.5, -4.2, 4.73, 5.0, 4.0, VER)
# Observatorio
rug("MM_Alfombra_Obs", -9.5, 6.8, 4.73, 5.0, 4.0, VER)
telescope("MM_Telescopio", -11.5, 7.0, 4.73)
armillary("MM_Esfera_Armilar", -6.5, 8.0, 4.73)
shelf("MM_Estante_Obs", -13.4, 5.0, 4.73, 0.5, 2.6, 2.0, 4)
painting("MM_Carta_Estelar", -13.8, 6.5, 6.6, 1.4, 1.0, rz=0)
# Sala de música
rug("MM_Alfombra_Musica", 0.0, 6.8, 4.73, 6.5, 4.5, VINO)
piano("MM_Piano", 0.0, 6.8, 4.73)
harp("MM_Arpa", 4.0, 8.5, 4.73)
for i, (dx, dy) in enumerate([(-2.0,-1.8),(0.0,-1.8),(2.0,-1.8)]):
    chair("MM_Silla_Musica%d" % i, 0.0+dx, 6.8+dy, 4.73, rz=0)
# Estudio
table("MM_Escritorio_Estudio", 9.5, 6.8, 4.73, 2.8, 1.1, 0.9, OSC)
chair("MM_Silla_Estudio", 9.5, 5.7, 4.73, rz=0)
shelf("MM_Estante_Estudio", 13.4, 6.8, 4.73, 0.5, 2.8, 2.2, 5)
cyl("MM_Globo_Estudio_Sop", 0.22, 0.1, 6.0, 8.5, 4.78, OSC, 8)
sph("MM_Globo_Estudio", 0.4, 6.0, 8.5, 5.4, VER, 12, 8)
box("MM_Chimenea_Estudio", 0.7, 2.0, 2.1, 13.4, 4.8, 5.7, PIE)
box("MM_Chimenea_Estudio_Hogar", 0.35, 1.2, 1.0, 13.1, 4.8, 5.2, EMI)
rug("MM_Alfombra_Estudio", 9.5, 6.5, 4.73, 5.0, 4.0, VER)
# Terraza
box("MM_Terraza", 9.0, 2.5, 0.16, 0.0, -11.0, 4.7, MAD)
for i in range(12):
    box("MM_Terraza_Balustre%d" % i, 0.06, 0.06, 0.9, -4.2+i*0.76, -12.1, 5.2, OSC)
box("MM_Terraza_Barra", 9.0, 0.07, 0.07, 0.0, -12.1, 5.7, OSC)
plant("MM_Maceta_Terraza1", -3.5, -11.2, 4.75, 1.1)
plant("MM_Maceta_Terraza2", 3.5, -11.2, 4.75, 1.1)
telescope("MM_Telescopio_Terraza", 0.0, -11.2, 4.75)
table("MM_Mesa_Bistro", -1.8, -11.0, 4.75, 0.8, 0.8, 0.8)
chair("MM_Silla_Bistro1", -2.6, -11.0, 4.75, rz=math.pi/2)
chair("MM_Silla_Bistro2", -1.0, -11.0, 4.75, rz=-math.pi/2)

mansion = bpy.data.objects.new("MANSION_MUSEO_V2", None)
bpy.context.collection.objects.link(mansion)
for ob in PARTS:
    ob.parent = mansion
    ob.matrix_parent_inverse = Matrix.Identity(4)
mansion.location = (16.0, 0, 0)
print("Mansión v2:", len(PARTS), "piezas")

# ---------------- SUELO ----------------
box("Suelo_Grandes_v2", 90.0, 60.0, 0.04, 0, 0, -0.02, ARE)

# ---------------- LUZ / CÁMARA ----------------
sun_data = bpy.data.lights.new("Sol_v2", 'SUN')
sun_data.energy = 2.4; sun_data.angle = math.radians(8)
sun = bpy.data.objects.new("Sol_v2", sun_data)
bpy.context.collection.objects.link(sun)
sun.location = (10, -12, 18); sun.rotation_euler = (math.radians(46), 0, math.radians(25))
cam_data = bpy.data.cameras.new("Camara_v2"); cam_data.lens = 52
cam = bpy.data.objects.new("Camara_v2", cam_data)
bpy.context.collection.objects.link(cam)
cam.location = (0, -48, 22)
tgt = bpy.data.objects.new("Camara_v2_Target", None)
bpy.context.collection.objects.link(tgt); tgt.location = (0, 0, 3.5)
c = cam.constraints.new(type='TRACK_TO'); c.target = tgt
c.track_axis = 'TRACK_NEGATIVE_Z'; c.up_axis = 'UP_Y'
scene.camera = cam

# ---------------- VALIDADOR DE SOLAPES ----------------
def aabb(ob):
    mn = Vector((1e9,1e9,1e9)); mx = Vector((-1e9,-1e9,-1e9))
    for c in ob.bound_box:
        w = ob.matrix_world @ Vector(c)
        for i in range(3):
            mn[i] = min(mn[i], w[i]); mx[i] = max(mx[i], w[i])
    return mn, mx

def overlap(a, b, tol=0.10):
    amn, amx = a; bmn, bmx = b
    dx = min(amx.x, bmx.x) - max(amn.x, bmn.x)
    dy = min(amx.y, bmx.y) - max(amn.y, bmn.y)
    dz = min(amx.z, bmx.z) - max(amn.z, bmn.z)
    if dx > tol and dy > tol and dz > tol:
        return dx*dy*dz, min(dx,dy,dz)
    return 0.0, 0.0

STRUCT = ("Muro","Tab","Zocalo","Piso","Techo","Escalera","Torre","Suelo","Terraza","Invernadero_Techo")
def is_struct(n):
    return any(k in n for k in STRUCT)

def same_group(a, b):
    # joints intended: base/back/arms, chimney/firebox, piano body/lid, armillary rings, rug
    for k in ("_Base","_Respaldo","_Brazo","_Hogar","_Tapa","_Anillo","_Borde","_Poste","_Toldo","_Colchon","_Manta","_Almohada","_Cabecera","_Tapa"):
        if k in a and k in b:
            return True
    return a.split("_")[0] == b.split("_")[0] and a != b

for hname in ("CASONA_GREMIO_V2","MANSION_MUSEO_V2"):
    root = bpy.data.objects[hname]
    meshes = [o for o in root.children_recursive if o.type == 'MESH']
    boxes = [(o, *aabb(o)) for o in meshes]
    struct = [b for b in boxes if is_struct(b[0].name)]
    furn = [b for b in boxes if not is_struct(b[0].name)]
    hits_fs = []
    for fo, fmn, fmx in furn:
        for so, smn, smx in struct:
            vol, pen = overlap((fmn,fmx),(smn,smx))
            if vol > 0.01:
                hits_fs.append((vol, pen, fo.name, so.name))
    hits_fs.sort(reverse=True)
    hits_ff = []
    for i in range(len(furn)):
        fo, fmn, fmx = furn[i]
        for j in range(i+1, len(furn)):
            go, gmn, gmx = furn[j]
            if same_group(fo.name, go.name):
                continue
            vol, pen = overlap((fmn,fmx),(gmn,gmx))
            if vol > 0.02:
                hits_ff.append((vol, pen, fo.name, go.name))
    hits_ff.sort(reverse=True)
    print("====", hname, "====")
    print("muebles:", len(furn), "| estructura:", len(struct))
    print("solapes mueble-estructura (>0.10 m):", len(hits_fs))
    for v,p,a,b in hits_fs[:10]:
        print("  %.3f m3 pen=%.2f | %s <-> %s" % (v,p,a,b))
    print("solapes mueble-mueble (>0.10 m):", len(hits_ff))
    for v,p,a,b in hits_ff[:10]:
        print("  %.3f m3 pen=%.2f | %s <-> %s" % (v,p,a,b))

# ---------------- GUARDAR / RENDER ----------------
bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
scene.render.filepath = os.path.join(CAPT, "casas_grandes_v2_exterior_2026-11-12.png")
bpy.ops.render.render(write_still=True)
print("Guardado:", BLEND_OUT)
print("Render:", scene.render.filepath)
print("Total objetos global:", len(bpy.data.objects))