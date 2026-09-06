# =====================================================================
#  SM_Pulpo_Arrecife — Generador procedural (Blender 4.x, bpy)
#  Variante ALTA (hero). Cozy: formas redondeadas, low-poly limpio.
# =====================================================================
import bpy, bmesh, math
from mathutils import Vector, Matrix

# ---------------- CONFIGURACIÓN ----------------
LIMPIAR_ESCENA = True
VARIANTE_INICIAL = 1
TENTACULOS_POR_PAR = False

SEG_MANTO, ANILLOS_MANTO = 28, 16
SEG_TENT,  ANILLOS_TENT  = 10, 16
SEG_FALDA                = 32
SEG_OJO,   ANILLOS_OJO   = 12, 6
N_TENT = 8

PALETA = {
    1: dict(principal=(178, 108, 80), vientre=(222, 180, 148), oscuro=(134, 74, 56)),
    2: dict(principal=(122, 124, 92), vientre=(196, 190, 152), oscuro=(84, 88, 62)),
}
COL_OJOS = (30, 20, 10)

# ---------------- UTILIDADES ----------------
def lin(c):
    def f(v):
        v /= 255.0
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
    return tuple(f(x) for x in c)

def clamp(v, a, b): return max(a, min(b, v))
def lerp(a, b, t):  return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))
def smooth(t):      t = clamp(t, 0, 1); return t * t * (3 - 2 * t)
def angs(n):        return [2 * math.pi * i / n for i in range(n)]

def ring_frame(c, tang, rx, rz, n):
    t  = tang.normalized()
    up = Vector((0, 0, 1)) - t * t.z
    if up.length < 1e-6: up = Vector((0, 1, 0))
    up.normalize()
    side = t.cross(up).normalized()
    return [c + rx * math.cos(a) * side + rz * math.sin(a) * up for a in angs(n)]

def build_tube(bm, rings, cap_ini=None, cap_fin=None):
    rv = [[bm.verts.new(p) for p in r] for r in rings]
    n  = len(rings[0])
    for a, b in zip(rv[:-1], rv[1:]):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new((a[i], a[j], b[j], b[i]))
    if cap_ini is not None:
        p = bm.verts.new(cap_ini)
        for i in range(n): bm.faces.new((p, rv[0][(i + 1) % n], rv[0][i]))
    if cap_fin is not None:
        p = bm.verts.new(cap_fin)
        for i in range(n): bm.faces.new((p, rv[-1][i], rv[-1][(i + 1) % n]))
    return rv

def set_mat(bm, n0, idx):
    if idx:
        bm.faces.ensure_lookup_table()
        for f in bm.faces[n0:]: f.material_index = idx

def curva_tubo(bm, path, radios, n_anillos, n_seg, t0=0.0, t1=1.0,
               cap_ini=True, cap_fin=True, coseno=False, punta=0.0, mat=0):
    n0 = len(bm.faces)
    if coseno:
        ts = [t0 + (t1 - t0) * (0.5 - 0.5 * math.cos(math.pi * i / (n_anillos - 1))) for i in range(n_anillos)]
    else:
        ts = [t0 + (t1 - t0) * i / (n_anillos - 1) for i in range(n_anillos)]
    def tang(t):
        e = 1e-3
        return path(min(t + e, 1.0)) - path(max(t - e, 0.0))
    rings = [ring_frame(path(t), tang(t), *radios(t), n_seg) for t in ts]
    ci = path(0.0) if cap_ini else None
    cf = None
    if cap_fin:
        cf = path(t1) + tang(t1).normalized() * radios(t1)[0] * punta
    build_tube(bm, rings, ci, cf)
    set_mat(bm, n0, mat)

def add_elipsoide(bm, r, n, m, tf, mat=0):
    n0 = len(bm.faces)
    rings = []
    for k in range(1, m):
        ph = math.pi * k / m
        rings.append([tf(Vector((r.x * math.sin(ph) * math.cos(a),
                                 r.y * math.sin(ph) * math.sin(a),
                                 r.z * math.cos(ph)))) for a in angs(n)])
    build_tube(bm, rings, tf(Vector((0, 0, r.z))), tf(Vector((0, 0, -r.z))))
    set_mat(bm, n0, mat)

def tf_desplazar(offset):
    return lambda p: p + offset

def _h(i, *seeds):
    h = i
    for s in seeds: h = (h * 31 + s) % 100000
    return (h % 1000) / 1000.0

def voronoi_borde(co, escala, octaves):
    cx = math.floor(co.x / escala)
    cy = math.floor(co.y / escala)
    cz = math.floor(co.z / escala)
    best = 999.0
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            for dz in range(-1, 2):
                hx = _h(int(cx + dx), int(cy + dy), int(cz + dz))
                hy = _h(int(cz + dz), int(cx + dx), int(cy + dy))
                hz = _h(int(cy + dy), int(cz + dz), int(cx + dx))
                px = (cx + dx + hx) * escala
                py = (cy + dy + hy) * escala
                pz = (cz + dz + hz) * escala
                d = ((co.x - px)**2 + (co.y - py)**2 + (co.z - pz)**2) ** 0.5
                if d < best: best = d
    return clamp(best / escala, 0, 1)

def coord_local(co, path, radios, escala=12):
    best_t, best_h = 0.0, 0.0
    best_d = 999.0
    for i in range(escala + 1):
        t = i / escala
        c = path(t)
        rx, rz = radios(t)
        d = (co - c).length
        if d < best_d:
            best_d = d
            best_t = t
            diff = co - c
            best_h = clamp(diff.z / max(rz, 1e-6), -1, 1)
    return best_t, best_h

# ---------------- TINTE POR VERTEX COLOR ----------------
_p1 = PALETA[1]
TINT_V = (1.0, 1.0, 1.0)
TINT_P = tuple(a / b for a, b in zip(lin(_p1["principal"]), lin(_p1["vientre"])))
TINT_O = tuple(a / b for a, b in zip(lin(_p1["oscuro"]),    lin(_p1["vientre"])))

def hacer_tintes(palette):
    tv = (1.0, 1.0, 1.0)
    tp = tuple(a / b for a, b in zip(lin(palette["principal"]), lin(palette["vientre"])))
    to = tuple(a / b for a, b in zip(lin(palette["oscuro"]),    lin(palette["vientre"])))
    def tinte_dorsal(w):
        return lerp(tv, tp, smooth(w / 0.5)) if w < 0.5 else lerp(tp, to, smooth((w - 0.5) / 0.5))
    return tv, tp, to, tinte_dorsal

TINT_V, TINT_P, TINT_O, tinte_dorsal = hacer_tintes(PALETA[1])

# ---------------- PERFILES ANATÓMICOS (metros) ----------------
MANTO_A, MANTO_B = Vector((0.0, 0.12, 0.20)), Vector((0.0, -0.24, 0.36))
def path_manto(t):   return MANTO_A.lerp(MANTO_B, t)
def radios_manto(t):
    u = 2 * t - 1
    s = (1 - abs(u) ** 2.6) ** (1 / 2.6)
    k = 0.86 + 0.14 * smooth(t / 0.35)
    return 0.15 * s * k, 0.15 * s * k

def dir_ojo(sg, t=0.22, ph=math.radians(48)):
    c = path_manto(t); rx, _ = radios_manto(t)
    side, up = frame(path_manto(t + 1e-3) - path_manto(t - 1e-3))
    return c, (side * sg * math.cos(ph) + up * math.sin(ph)).normalized(), rx

def frame(tang):
    t  = tang.normalized()
    up = Vector((0, 0, 1)) - t * t.z
    if up.length < 1e-6: up = Vector((0, 1, 0))
    up.normalize()
    return t.cross(up).normalized(), up

def ring_falda(z, r, lob):
    out = []
    for a in angs(SEG_FALDA):
        rr = r * (1 + lob * math.cos(N_TENT * a - math.pi))
        out.append(Vector((rr * math.cos(a), rr * math.sin(a), z)))
    return out

def ang_tent(i): return 2 * math.pi * i / N_TENT + math.pi / N_TENT
def radios_tent(t):
    rx = 0.009 + 0.036 * (1 - t) ** 1.15
    return rx, rx * 0.85
def path_tent(i):
    th = ang_tent(i)
    d = Vector((math.cos(th), math.sin(th), 0.0)); s = Vector((-d.y, d.x, 0.0))
    fase = _h(i, 3, 7, 11) * 6.283
    def p(t):
        r  = 0.09 + 0.33 * t - 0.05 * t * t - 0.06 * max(0.0, (t - 0.80) / 0.20) ** 2
        zb = 0.12 * max(0.0, (0.80 - t) / 0.80) ** 1.7 + 0.11 * max(0.0, (t - 0.80) / 0.20) ** 2
        w  = 0.045 * t * math.sin(math.pi * 1.4 * t + fase)
        return d * r + s * w + Vector((0, 0, zb + radios_tent(t)[1]))
    return p

# ---------------- TINTES ----------------
def tinte_manto(co, i):
    t, h = coord_local(co, path_manto, radios_manto)
    return tinte_dorsal(0.25 + 0.75 * (h + 1) / 2)
def tinte_tent(co, i):
    th = math.atan2(co.y, co.x)
    k = int(round((th - math.pi / N_TENT) / (2 * math.pi / N_TENT))) % N_TENT
    t, h = coord_local(co, path_tent(k), radios_tent, 24)
    return tinte_dorsal(0.08 + 0.62 * (h + 1) / 2)

# ---------------- GEOMETRÍA ----------------
def crear_cuerpo():
    bm = bmesh.new()
    curva_tubo(bm, path_manto, radios_manto, ANILLOS_MANTO, SEG_MANTO, 0.02, 0.98, True, True, coseno=True, punta=0.3)
    for sg in (-1, 1):
        c, d, rx = dir_ojo(sg)
        add_elipsoide(bm, Vector((0.048, 0.048, 0.042)), 10, 5, tf_desplazar(c + d * rx * 0.90))
    build_tube(bm, [ring_falda(0.17, 0.125, 0.02), ring_falda(0.11, 0.19, 0.06), ring_falda(0.05, 0.245, 0.10)],
               None, Vector((0, 0, 0.05)))
    return bm

def crear_tentaculos(indices):
    bm = bmesh.new()
    for i in indices:
        curva_tubo(bm, path_tent(i), radios_tent, ANILLOS_TENT, SEG_TENT, 0.0, 1.0, False, True, punta=0.6)
    return bm

def crear_ojos():
    bm = bmesh.new()
    for sg in (-1, 1):
        c, d, rx = dir_ojo(sg)
        add_elipsoide(bm, Vector((0.027, 0.027, 0.027)), SEG_OJO, ANILLOS_OJO, tf_desplazar(c + d * (rx * 0.90 + 0.034)))
    return bm

# ---------------- MATERIALES ----------------
def mat_pelaje(nombre, color_rgb, roughness):
    mat = bpy.data.materials.new(name=nombre)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (color_rgb[0]/255, color_rgb[1]/255, color_rgb[2]/255, 1)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = 0.0
    return mat

def mat_ojos(nombre, color_rgb):
    mat = bpy.data.materials.new(name=nombre)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (color_rgb[0]/255, color_rgb[1]/255, color_rgb[2]/255, 1)
    bsdf.inputs["Roughness"].default_value = 0.2
    bsdf.inputs["Emission Color"].default_value = (0.1, 0.08, 0.05, 1)
    bsdf.inputs["Emission Strength"].default_value = 0.1
    return mat

def crear_objeto(nombre, bm, materials, tinte_fn=None, pivot=None):
    mesh = bpy.data.meshes.new(nombre)
    mesh.from_pydata([v.co for v in bm.verts], [], [(f verts_to_indices(f) for f in bm.faces)])
    bm.normal_update()
    
    if tinte_fn:
        color_layer = mesh.vertex_colors.new(name="COLOR_0")
        mesh.polygons.foreach_set("loop_indices", [l for f in mesh.polygons for l in f.loop_indices])
    
    obj = bpy.data.objects.new(nombre, mesh)
    for i, mat in enumerate(materials):
        obj.data.materials.append(mat)
    
    bpy.context.collection.objects.link(obj)
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    
    if pivot:
        obj.location = -pivot
        bpy.ops.object.transform_apply(location=True)
    
    bpy.ops.object.shade_smooth() if SOMBREADO_SUAVE else None
    return obj

def verts_to_indices(face):
    return [v.index for v in face.verts]

# ---------------- ESCENA ----------------
def iniciar_escena(nombre, escala, posicion):
    if LIMPIAR_ESCENA:
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete()
    
    col = bpy.data.collections.new("COL_Fauna")
    bpy.context.scene.collection.children.link(col)
    
    for o in list(bpy.context.scene.collection.objects):
        bpy.context.scene.collection.objects.unlink(o)
        col.objects.link(o)

def estadisticas(nombre):
    total_tris = 0
    total_objs = 0
    for obj in bpy.data.objects:
        if obj.type == 'MESH':
            total_tris += len(obj.data.polygons) * 2
            total_objs += 1
    print(f"\n=== {nombre} ===")
    print(f"Triángulos: {total_tris}")
    print(f"Objetos: {total_objs}")
    print(f"Materiales: {len(bpy.data.materials)}")

# ---------------- EJECUCIÓN ----------------
iniciar_escena("SM_Pulpo_Arrecife", 0.25, (0.8, 0, 0))

MATS = {
    "piel_01": mat_pelaje("MAT_Pulpo_Piel_01", PALETA[1], 0.55),
    "piel_02": mat_pelaje("MAT_Pulpo_Piel_02", PALETA[2], 0.55),
    "ojos":    mat_ojos("MAT_Pulpo_Ojos", COL_OJOS),
}
PEL = MATS["piel_01"]
PIV_BRAZOS = Vector((0, 0, 0.16))
PIV_CABEZA = path_manto(0.15)

OBJS_PELAJE = [crear_objeto("SM_Pulpo_Body", crear_cuerpo(), [PEL], tinte_manto)]

if TENTACULOS_POR_PAR:
    for nombre, idx in (("SM_Pulpo_Tent_Front", (1, 2)), ("SM_Pulpo_Tent_R", (0, 7)),
                        ("SM_Pulpo_Tent_L", (3, 4)),     ("SM_Pulpo_Tent_Back", (5, 6))):
        OBJS_PELAJE.append(crear_objeto(nombre, crear_tentaculos(idx), [PEL], tinte_tent, PIV_BRAZOS))
else:
    OBJS_PELAJE.append(crear_objeto("SM_Pulpo_Tentaculos", crear_tentaculos(range(N_TENT)), [PEL], tinte_tent, PIV_BRAZOS))

TODOS = OBJS_PELAJE + [crear_objeto("SM_Pulpo_Eyes", crear_ojos(), [MATS["ojos"]], None, PIV_CABEZA)]

estadisticas("SM_Pulpo_Arrecife")
print("Pulpo de Arrecife creado exitosamente!")
