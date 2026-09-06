# =====================================================================
#  SM_Elefante_Pradera — Generador procedural (Blender 4.x, bpy)
#  Variante ALTA (hero). Cozy: formas redondeadas, low-poly limpio, sin subsurf.
#  Mira hacia +Y en Blender -> -Z (forward) en Godot.
# =====================================================================
import bpy, bmesh, math
from mathutils import Vector, Matrix

# ---------------- CONFIGURACIÓN ----------------
LIMPIAR_ESCENA      = True
PIVOTES_ARTICULARES = True
SOMBREADO_SUAVE     = True
OJOS_SEPARADOS      = False
COLA_SEPARADA       = False
VARIANTE_INICIAL    = 1

SEG_CUERPO,   ANILLOS_CUERPO   = 32, 18
SEG_CABEZA,   ANILLOS_CABEZA   = 28, 14
SEG_TROMPA,   ANILLOS_TROMPA   = 12, 18
SEG_COLA,     ANILLOS_COLA     = 8,  12
SEG_PATA                       = 10
SEG_OREJA,    ANILLOS_OREJA    = 14, 10
SEG_COLMILLO, ANILLOS_COLMILLO = 8,  9
SEG_OJO,      ANILLOS_OJO      = 10, 5

PALETA = {
    1: dict(principal=(128, 118, 110), vientre=(152, 142, 133), oscuro=(98, 88, 82)),
    2: dict(principal=(136, 110,  95), vientre=(162, 140, 124), oscuro=(104, 82, 70)),
}
COL_OJOS   = (35, 25, 18)
COL_MARFIL = (226, 215, 192)

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

def ring_Z(cx, cy, cz, rx, ry, n):
    return [Vector((cx + rx * math.cos(a), cy + ry * math.sin(a), cz)) for a in angs(n)]

def ring_frame(c, tang, rx, rz, n):
    t  = tang.normalized()
    up = Vector((1, 0, 0)).cross(t)
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

# ---------------- PERFILES ANATÓMICOS (metros) ----------------
CUERPO_Y0, CUERPO_Y1 = -1.00, 0.95
def path_cuerpo(t):
    return Vector((0.0, CUERPO_Y0 + (CUERPO_Y1 - CUERPO_Y0) * t,
                   1.50 + 0.10 * math.sin(math.pi * t) + 0.06 * t))
def radios_cuerpo(t):
    u = 2 * t - 1
    s = (1 - abs(u) ** 3.0) ** (1 / 3.0)
    return 0.66 * s * (1.0 - 0.06 * t), 0.74 * s

def path_cola(t):
    return Vector((0.0, -0.92 - 0.36 * t - 0.05 * math.sin(math.pi * t), 1.66 - 0.80 * t))
def radios_cola(t):
    r = 0.028 + 0.045 * (1 - t) ** 1.3
    if t > 0.80: r += 0.04 * math.sin(math.pi * (t - 0.80) / 0.20)
    return r, r

def path_cabeza(t):
    return Vector((0.0, 0.70 + 1.02 * t, 1.78 - 0.30 * t * t + 0.03 * math.sin(math.pi * t)))
def radios_cabeza(t):
    u = 2 * t - 1
    s = (1 - abs(u) ** 2.8) ** (1 / 2.8)
    k = max(0.0, (t - 0.70) / 0.30)
    return 0.46 * s * (1 - 0.28 * k), 0.52 * s * (1 - 0.20 * k)

TROMPA_BASE = Vector((0.0, 1.62, 1.40))
def path_trompa(t):
    c = max(0.0, (t - 0.82) / 0.18) ** 2
    y = TROMPA_BASE.y + 0.28 * math.sin(math.pi * t) * (1 - 0.35 * t) + 0.12 * t + 0.10 * c
    z = TROMPA_BASE.z - 1.22 * t + 0.14 * c
    return Vector((0.0, y, z))
def radios_trompa(t):
    rx = 0.045 + 0.125 * (1 - t) ** 1.1
    return rx, rx * 0.95

def path_colmillo(sg):
    return lambda t: Vector((sg * (0.17 + 0.12 * t), 1.56 + 0.50 * t, 1.32 - 0.30 * t + 0.22 * t * t))
def radios_colmillo(t):
    r = 0.018 + 0.052 * (1 - t)
    return r, r

def tf_oreja(sg):
    P   = Vector((sg * 0.40, 1.13, 1.80))
    off = Vector((0.0, -0.15, -0.06))
    R   = Matrix.Rotation(math.radians(sg * 35), 4, 'Z') @ Matrix.Rotation(math.radians(sg * 12), 4, 'Y')
    def tf(p):
        zn = p.z / 0.50
        y  = p.y * (0.72 + 0.32 * zn) - 0.05 * (1 - zn)
        x  = p.x * (0.45 + 0.55 * (1 - zn * zn)) * (0.55 + 0.45 * clamp((p.y + 0.40) / 0.80, 0, 1))
        return P + (R @ (Vector((x, y, p.z)) + off))
    return tf

# ---------------- TINTE POR VERTEX COLOR ----------------
_p1 = PALETA[1]
TINT_V = (1.0, 1.0, 1.0)
TINT_P = tuple(a / b for a, b in zip(lin(_p1["principal"]), lin(_p1["vientre"])))
TINT_O = tuple(a / b for a, b in zip(lin(_p1["oscuro"]),    lin(_p1["vientre"])))
def tinte_dorsal(w):
    return lerp(TINT_V, TINT_P, smooth(w / 0.5)) if w < 0.5 else lerp(TINT_P, TINT_O, smooth((w - 0.5) / 0.5))

def tinte_cuerpo(co):
    if co.y < -0.97 and co.z < 1.55: return tinte_dorsal(0.75)
    return tinte_dorsal(clamp((co.z - 0.85) / 1.45, 0, 1))
def tinte_cabeza(co): return tinte_dorsal(0.15 + 0.85 * clamp((co.z - 1.15) / 1.15, 0, 1))
def tinte_trompa(co): return tinte_dorsal(0.45 + 0.25 * clamp(co.z / 1.4, 0, 1))
def tinte_oreja(co):  return tinte_dorsal(0.55 + 0.15 * clamp((co.z - 1.3) / 0.9, 0, 1))
def tinte_pata(co):   return tinte_dorsal(0.35 + 0.35 * clamp(co.z / 1.35, 0, 1))

# ---------------- GEOMETRÍA ----------------
def crear_cuerpo(con_cola):
    bm = bmesh.new()
    curva_tubo(bm, path_cuerpo, radios_cuerpo, ANILLOS_CUERPO, SEG_CUERPO, 0.02, 0.98, True, True, coseno=True)
    if con_cola: add_cola(bm)
    return bm

def add_cola(bm):
    curva_tubo(bm, path_cola, radios_cola, ANILLOS_COLA, SEG_COLA, 0.0, 1.0, False, True, punta=0.6)

def crear_cola():
    bm = bmesh.new(); add_cola(bm); return bm

def add_ojos(bm, mat):
    t = 0.72; c = path_cabeza(t); rx, rz = radios_cabeza(t); ph = math.radians(18)
    for sg in (-1, 1):
        ce = Vector((sg * rx * math.cos(ph) * 0.95, c.y, c.z + rz * math.sin(ph) * 0.95))
        add_elipsoide(bm, Vector((0.070, 0.070, 0.070)), SEG_OJO, ANILLOS_OJO, lambda p, ce=ce: p + ce, mat)

def crear_cabeza(idx_ojos, idx_marfil, con_ojos):
    bm = bmesh.new()
    curva_tubo(bm, path_cabeza, radios_cabeza, ANILLOS_CABEZA, SEG_CABEZA, 0.02, 0.985, True, True, coseno=True)
    for sg in (-1, 1):
        curva_tubo(bm, path_colmillo(sg), radios_colmillo, ANILLOS_COLMILLO, SEG_COLMILLO,
                   0.0, 1.0, False, True, punta=0.7, mat=idx_marfil)
    if con_ojos: add_ojos(bm, idx_ojos)
    return bm

def crear_ojos():
    bm = bmesh.new(); add_ojos(bm, 0); return bm

def crear_trompa():
    bm = bmesh.new()
    curva_tubo(bm, path_trompa, radios_trompa, ANILLOS_TROMPA, SEG_TROMPA, 0.0, 1.0, False, True, punta=0.5)
    return bm

def crear_orejas():
    bm = bmesh.new()
    for sg in (-1, 1):
        add_elipsoide(bm, Vector((0.035, 0.40, 0.50)), SEG_OREJA, ANILLOS_OREJA, tf_oreja(sg))
    return bm

def crear_pata(x, y):
    bm = bmesh.new()
    sg = 1 if x > 0 else -1
    spec = [(1.35, 0.270, -0.04), (1.05, 0.235, -0.02), (0.75, 0.212, 0.0), (0.45, 0.200, 0.0),
            (0.20, 0.215, 0.0),   (0.09, 0.245, 0.0),   (0.00, 0.250, 0.0)]
    rings = [ring_Z(x + sg * dx, y, z, r, r * 1.05, SEG_PATA) for z, r, dx in spec]
    build_tube(bm, rings, None, Vector((x, y, 0.0)))
    for f in bm.faces:
        zs = [v.co.z for v in f.verts]
        if len(f.verts) == 4 and max(zs) <= 0.09 + 1e-4 and min(zs) >= -1e-4:
            if sum(v.co.y for v in f.verts) / 4 > y + 0.10: f.material_index = 1
    return bm

# ---------------- MATERIALES ----------------
def _bsdf(mat):
    mat.use_nodes = True
    return mat.node_tree, mat.node_tree.nodes["Principled BSDF"]

def mat_piel(nombre, pal):
    mat = bpy.data.materials.new(nombre)
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Roughness"].default_value = 0.85
    bsdf.inputs["Metallic"].default_value  = 0.0
    attr = nt.nodes.new("ShaderNodeVertexColor"); attr.layer_name = "Col_Piel"; attr.location = (-600, 300)
    rgb  = nt.nodes.new("ShaderNodeRGB"); rgb.outputs[0].default_value = (*lin(pal["vientre"]), 1.0); rgb.location = (-600, 80)
    mix  = nt.nodes.new("ShaderNodeMix"); mix.data_type = "RGBA"; mix.blend_type = "MULTIPLY"
    mix.inputs["Factor"].default_value = 1.0; mix.location = (-300, 200)
    nt.links.new(attr.outputs["Color"], mix.inputs[6])
    nt.links.new(rgb.outputs[0],        mix.inputs[7])
    nt.links.new(mix.outputs[2],        bsdf.inputs["Base Color"])
    mat.diffuse_color = (*lin(pal["principal"]), 1.0)
    mat.use_fake_user = True
    return mat

def mat_ojos():
    mat = bpy.data.materials.new("MAT_Elefante_Ojos")
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Base Color"].default_value = (*lin(COL_OJOS), 1.0)
    bsdf.inputs["Roughness"].default_value  = 0.2
    em = bsdf.inputs.get("Emission Color") or bsdf.inputs.get("Emission")
    em.default_value = (1.0, 0.82, 0.55, 1.0)
    bsdf.inputs["Emission Strength"].default_value = 0.08
    mat.diffuse_color = (*lin(COL_OJOS), 1.0)
    return mat

def mat_marfil():
    mat = bpy.data.materials.new("MAT_Elefante_Marfil")
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Base Color"].default_value = (*lin(COL_MARFIL), 1.0)
    bsdf.inputs["Roughness"].default_value  = 0.45
    mat.diffuse_color = (*lin(COL_MARFIL), 1.0)
    return mat

# ---------------- ESCENA ----------------
def limpiar():
    for o in list(bpy.data.objects): bpy.data.objects.remove(o, do_unlink=True)
    for bloque in (bpy.data.meshes, bpy.data.materials):
        for d in list(bloque):
            if d.users == 0 or d.name.startswith(("SM_", "MAT_", "REF_")): bloque.remove(d)
    for c in list(bpy.data.collections):
        if c.name.startswith("COL_"): bpy.data.collections.remove(c)

def coleccion(nombre):
    c = bpy.data.collections.new(nombre); bpy.context.scene.collection.children.link(c); return c

def crear_objeto(nombre, bm, materiales, tinte=None, pivote=Vector((0, 0, 0))):
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(nombre); bm.to_mesh(me); bm.free()
    for m in materiales: me.materials.append(m)
    if SOMBREADO_SUAVE: me.polygons.foreach_set("use_smooth", [True] * len(me.polygons))
    if tinte:
        blancos = set()
        for p in me.polygons:
            if p.material_index != 0: blancos.update(p.vertices)
        ca = me.color_attributes.new("Col_Piel", "FLOAT_COLOR", "POINT")
        for i, v in enumerate(me.vertices):
            ca.data[i].color = (1, 1, 1, 1) if i in blancos else (*tinte(v.co), 1.0)
        me.color_attributes.active_color = ca
        me.color_attributes.render_color_index = 0
    if PIVOTES_ARTICULARES:
        for v in me.vertices: v.co -= pivote
    ob = bpy.data.objects.new(nombre, me)
    ob.location = pivote if PIVOTES_ARTICULARES else Vector((0, 0, 0))
    COL_FAUNA.objects.link(ob); ob.parent = RAIZ
    return ob

if LIMPIAR_ESCENA: limpiar()
COL_FAUNA = coleccion("COL_Fauna")
COL_REF   = coleccion("COL_Referencia")

bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts: v.co.z += 0.5
me = bpy.data.meshes.new("REF_Cubo_1m"); bm.to_mesh(me); bm.free()
ref = bpy.data.objects.new("REF_Cubo_1m", me); ref.display_type = "WIRE"; ref.hide_render = True
ref.location = (1.6, 0, 0); COL_REF.objects.link(ref)

RAIZ = bpy.data.objects.new("SM_Elefante_Pradera", None)
RAIZ.empty_display_type = "PLAIN_AXES"; RAIZ.empty_display_size = 0.5
COL_FAUNA.objects.link(RAIZ)

MATS = {
    "MAT_Elefante_Piel_01": mat_piel("MAT_Elefante_Piel_01", PALETA[1]),
    "MAT_Elefante_Piel_02": mat_piel("MAT_Elefante_Piel_02", PALETA[2]),
    "MAT_Elefante_Ojos":    mat_ojos(),
    "MAT_Elefante_Marfil":  mat_marfil(),
}
PIEL = MATS[f"MAT_Elefante_Piel_0{VARIANTE_INICIAL}"]
OJOS, MARFIL = MATS["MAT_Elefante_Ojos"], MATS["MAT_Elefante_Marfil"]

PIV_CABEZA = Vector((0.0, 0.85, 1.65))
PIV_TROMPA = TROMPA_BASE.copy()
PIV_COLA   = Vector((0.0, -0.92, 1.66))

OBJS_PIEL, EXTRA = [], []
OBJS_PIEL.append(crear_objeto("SM_Elefante_Body", crear_cuerpo(not COLA_SEPARADA), [PIEL], tinte_cuerpo))
if COLA_SEPARADA:
    OBJS_PIEL.append(crear_objeto("SM_Elefante_Tail", crear_cola(), [PIEL], tinte_cuerpo, PIV_COLA))
if OJOS_SEPARADOS:
    OBJS_PIEL.append(crear_objeto("SM_Elefante_Head", crear_cabeza(0, 1, False), [PIEL, MARFIL], tinte_cabeza, PIV_CABEZA))
    EXTRA.append(crear_objeto("SM_Elefante_Eyes", crear_ojos(), [OJOS], None, PIV_CABEZA))
else:
    OBJS_PIEL.append(crear_objeto("SM_Elefante_Head", crear_cabeza(1, 2, True), [PIEL, OJOS, MARFIL], tinte_cabeza, PIV_CABEZA))
OBJS_PIEL.append(crear_objeto("SM_Elefante_Trunk", crear_trompa(), [PIEL], tinte_trompa, PIV_TROMPA))
OBJS_PIEL.append(crear_objeto("SM_Elefante_Ears",  crear_orejas(), [PIEL], tinte_oreja,  PIV_CABEZA))
for nombre, x, y in (("SM_Elefante_Leg_FL", -0.30,  0.55), ("SM_Elefante_Leg_FR", 0.30,  0.55),
                     ("SM_Elefante_Leg_BL", -0.32, -0.58), ("SM_Elefante_Leg_BR", 0.32, -0.58)):
    OBJS_PIEL.append(crear_objeto(nombre, crear_pata(x, y), [PIEL, MARFIL], tinte_pata, Vector((x, y, 1.35))))
TODOS = OBJS_PIEL + EXTRA

# ---------------- PIPELINE ----------------
def aplicar_variante(n):
    m = MATS[f"MAT_Elefante_Piel_0{n}"]
    for o in OBJS_PIEL: o.data.materials[0] = m

def exportar_glb(ruta):
    bpy.ops.object.select_all(action="DESELECT")
    RAIZ.select_set(True)
    for o in TODOS: o.select_set(True)
    bpy.context.view_layer.objects.active = RAIZ
    bpy.ops.export_scene.gltf(filepath=ruta, export_format="GLB", use_selection=True,
                              export_yup=True, export_apply=True, export_animations=False)

# ---------------- ESTADÍSTICAS ----------------
bpy.context.view_layer.update()
total = 0
print("\n=== SM_Elefante_Pradera — variante ALTA ===")
for o in TODOS:
    n = sum(len(p.vertices) - 2 for p in o.data.polygons); total += n
    print(f"  {o.name:22s} {n:5d} tris   scale={tuple(round(s, 3) for s in o.scale)}")
pts = [o.matrix_world @ v.co for o in TODOS for v in o.data.vertices]
xs, ys, zs = [p.x for p in pts], [p.y for p in pts], [p.z for p in pts]
print(f"  TOTAL: {total} tris (≤6000) | objetos: {len(TODOS)} (≤8) | materiales: {len(MATS)} (≤6)")
print(f"  Largo: {max(ys)-min(ys):.2f} m | Alto: {max(zs):.2f} m | Ancho (con orejas): {max(xs)-min(xs):.2f} m | Z min: {min(zs):.4f}")
print("  exportar_glb('/ruta/SM_Elefante_Pradera.glb')   |   aplicar_variante(2)")
