# =====================================================================
#  SM_Nutria_Ribera v3 — Generador procedural (Blender 4.x, bpy)
#  Variante ALTA (hero). Estilo cozy: formas orgánicas, low-poly limpio.
#  Mejoras v3: hocico más pronunciado, ondulación en el lomo, bigotes
#              más gruesos, patas corregidas (sin hueco interno).
# =====================================================================
import bpy, bmesh, math
from mathutils import Vector

# ---------------- CONFIGURACIÓN ----------------
LIMPIAR_ESCENA      = True
PIVOTES_ARTICULARES = True
SOMBREADO_SUAVE     = True
USAR_MAT_NARIZ      = True
VARIANTE_INICIAL    = 1

SEG_CUERPO, ANILLOS_CUERPO = 28, 18
SEG_CABEZA, ANILLOS_CABEZA = 24, 16
SEG_COLA,   ANILLOS_COLA   = 14, 10
SEG_PATA                   = 10
SEG_OJO,    ANILLOS_OJO    = 12, 6
SEG_BIGOTE                 = 6

PALETA = {
    1: dict(principal=(140, 97, 72), vientre=(180, 140, 110), oscuro=(100, 68, 48)),
    2: dict(principal=(107, 76, 61), vientre=(150, 115,  90), oscuro=( 70, 48, 35)),
}
COL_OJOS   = (30, 20, 10)
COL_NARIZ  = (50, 35, 25)
COL_BIGOTE = (60, 45, 30)

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

def ring_Y(cy, cz, rx, rz, n, cx=0.0):
    return [Vector((cx + rx * math.cos(a), cy, cz + rz * math.sin(a))) for a in angs(n)]

def ring_Z(cx, cy, cz, rx, ry, n):
    return [Vector((cx + rx * math.cos(a), cy + ry * math.sin(a), cz)) for a in angs(n)]

def build_tube(bm, rings, cap_ini=None, cap_fin=None):
    rv = [[bm.verts.new(p) for p in r] for r in rings]
    n  = len(rings[0])
    for a, b in zip(rv[:-1], rv[1:]):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new((a[i], a[j], b[j], b[i]))
    if cap_ini is not None:
        p = bm.verts.new(cap_ini)
        for i in range(n):
            bm.faces.new((p, rv[0][(i + 1) % n], rv[0][i]))
    if cap_fin is not None:
        p = bm.verts.new(cap_fin)
        for i in range(n):
            bm.faces.new((p, rv[-1][i], rv[-1][(i + 1) % n]))
    return rv

def add_elipsoide(bm, c, r, n, m):
    rings = []
    for k in range(1, m):
        ph = math.pi * k / m
        rings.append([Vector((c.x + r.x * math.sin(ph) * math.cos(a),
                              c.y + r.y * math.sin(ph) * math.sin(a),
                              c.z + r.z * math.cos(ph))) for a in angs(n)])
    build_tube(bm, rings, Vector((c.x, c.y, c.z + r.z)), Vector((c.x, c.y, c.z - r.z)))

# ---------------- PERFILES ANATÓMICOS v2 ----------------
# Largo total nariz->punta de cola ~0.72 m
CUERPO_Y0, CUERPO_Y1 = -0.17, 0.17

def perfil_cuerpo(t):
    u  = 2 * t - 1
    s  = (1 - abs(u) ** 2.4) ** (1 / 2.4)
    bulto = 1.08 - 0.14 * t
    rx = 0.074 * s * bulto
    rz = 0.085 * s * (1.0 + 0.05 * (1 - t))
    # Lomo con ondulación sutil (simula musculatura/ columna vertebral)
    ondulacion = 0.012 * math.sin(math.pi * t * 2.5) * (1 - 0.5 * abs(u))
    zc = 0.118 + 0.025 * math.sin(math.pi * t) + ondulacion
    y  = CUERPO_Y0 + (CUERPO_Y1 - CUERPO_Y0) * t
    return y, zc, rx, rz

# Cabeza más grande y levantada (postura curiosa) + hocico pronunciado
CABEZA_C = Vector((0.0, 0.215, 0.155))
CABEZA_ATRAS, CABEZA_DELANTE = 0.062, 0.105  # Extender hocico hacia adelante

def perfil_cabeza(t):
    y = CABEZA_C.y - CABEZA_ATRAS + (CABEZA_ATRAS + CABEZA_DELANTE) * t
    u = 2 * t - 1
    if u < 0:
        s = (1 - abs(u) ** 2.2) ** (1 / 2.2)
    else:
        s = (1 - u ** 2.8) ** (1 / 2.8)
    rx, rz = 0.064 * s, 0.052 * s
    # Hocico: se estrecha gradualmente hacia la punta
    if t > 0.58:
        k = (t - 0.58) / 0.42
        rx *= 1 - 0.35 * k  # Más estrecho que v2 (0.25 → 0.35)
        rz *= 1 - 0.25 * k  # Más estrecho que v2 (0.20 → 0.25)
        # Agregar un ligero engrosamiento en la punta del hocico (almohadilla nasal)
        if t > 0.88:
            k2 = (t - 0.88) / 0.12
            rx *= 1.0 + 0.15 * k2  # Engrosamiento sutil
            rz *= 1.0 + 0.12 * k2
    zc = CABEZA_C.z - 0.005 * max(0.0, u)
    return y, zc, rx, rz

# Nariz: almohadilla pronunciada en la punta del hocico
NARIZ_C = None  # se calcula dinámicamente
def perfil_nariz(t):
    """Almohadilla nasal más grande y definida"""
    yn = CABEZA_C.y + CABEZA_DELANTE * 0.98  # Posición final del hocico
    zn = CABEZA_C.z - 0.008
    rx_n = 0.022 * (1 - t)  # Más grande que v2 (0.018 → 0.022)
    rz_n = 0.015 * (1 - t)  # Más grande que v2 (0.012 → 0.015)
    y = yn + t * 0.015  # Más largo que v2 (0.012 → 0.015)
    zc = zn + 0.008 * math.sin(math.pi * t)  # Más pronunciado que v2 (0.006 → 0.008)
    return y, zc, rx_n, rz_n

COLA_Y0, COLA_Y1 = -0.14, -0.44

def perfil_cola(t):
    y  = COLA_Y0 + (COLA_Y1 - COLA_Y0) * t
    rx = 0.008 + 0.038 * (1 - t) ** 1.2
    rz = rx * 0.70
    zc = 0.120 - 0.092 * (t ** 1.35)
    return y, zc, rx, rz

# ---------------- TINTE POR VERTEX COLOR ----------------
_p1 = PALETA[1]
TINT_V = (1.0, 1.0, 1.0)
TINT_P = tuple(a / b for a, b in zip(lin(_p1["principal"]), lin(_p1["vientre"])))
TINT_O = tuple(a / b for a, b in zip(lin(_p1["oscuro"]),    lin(_p1["vientre"])))

def tinte_dorsal(w):
    return lerp(TINT_V, TINT_P, smooth(w / 0.5)) if w < 0.5 else lerp(TINT_P, TINT_O, smooth((w - 0.5) / 0.5))

def tinte_cuerpo(co):
    t = clamp((co.y - CUERPO_Y0) / (CUERPO_Y1 - CUERPO_Y0), 0.02, 0.98)
    _, zc, _, rz = perfil_cuerpo(t)
    h = clamp((co.z - zc) / max(rz, 1e-4), -1, 1)
    return tinte_dorsal((h + 1) / 2)

def tinte_cabeza(co):
    t = clamp((co.y - (CABEZA_C.y - CABEZA_ATRAS)) / (CABEZA_ATRAS + CABEZA_DELANTE), 0.02, 0.98)
    _, zc, _, rz = perfil_cabeza(t)
    h = clamp((co.z - zc) / max(rz, 1e-4), -1, 1)
    return tinte_dorsal(0.08 + 0.92 * (h + 1) / 2)

def tinte_cola(co):
    t = clamp((co.y - COLA_Y0) / (COLA_Y1 - COLA_Y0), 0.0, 0.97)
    _, zc, _, rz = perfil_cola(t)
    h = clamp((co.z - zc) / max(rz, 1e-4), -1, 1)
    return tinte_dorsal(0.40 + 0.60 * (h + 1) / 2)

def tinte_pata(co):
    return tinte_dorsal(0.45 + 0.40 * clamp(co.z / 0.09, 0, 1))

# ---------------- GEOMETRÍA v2 ----------------
def crear_cuerpo():
    bm = bmesh.new()
    ts = [0.5 - 0.5 * math.cos(math.pi * i / ANILLOS_CUERPO) for i in range(1, ANILLOS_CUERPO)]
    rings = [ring_Y(*perfil_cuerpo(t), SEG_CUERPO) for t in ts]
    y0, z0, _, _ = perfil_cuerpo(0.0); y1, z1, _, _ = perfil_cuerpo(1.0)
    build_tube(bm, rings, Vector((0, y0, z0)), Vector((0, y1, z1)))
    return bm

def crear_cabeza(mat_idx_nariz):
    bm = bmesh.new()
    # Más anillos para el hocico extendido
    ts = [0.5 - 0.5 * math.cos(math.pi * i / ANILLOS_CABEZA) for i in range(1, ANILLOS_CABEZA)]
    ts = [t * 0.995 / ts[-1] for t in ts]
    rings = [ring_Y(*perfil_cabeza(t), SEG_CABEZA) for t in ts]
    y0, z0, _, _ = perfil_cabeza(0.0); yn, zn, _, _ = perfil_cabeza(0.995)
    build_tube(bm, rings, Vector((0, y0, z0)), Vector((0, yn, zn)))
    # Nariz material - aplicar SOLO a la punta más extrema del hocico
    for f in bm.faces:
        if all(v.co.y >= yn - 0.005 for v in f.verts):  # Rango muy pequeño solo en la punta
            f.material_index = mat_idx_nariz
    # Orejas - posición ajustada para hocico más largo
    y, zc, rx, rz = perfil_cabeza(0.35)  # Ligeramente más atrás
    ph = math.radians(55)
    for sg in (-1, 1):
        c = Vector((sg * rx * math.cos(ph) * 0.95, y, zc + rz * math.sin(ph) * 0.95))
        add_elipsoide(bm, c, Vector((0.011, 0.008, 0.013)), 6, 4)
    return bm

def crear_nariz():
    """Almohadilla nasal pronunciada"""
    bm = bmesh.new()
    ts = [0.5 - 0.5 * math.cos(math.pi * i / 6) for i in range(1, 6)]
    rings = [ring_Y(*perfil_nariz(t), 10) for t in ts]
    y0, z0, _, _ = perfil_nariz(0.0)
    y1, z1, _, _ = perfil_nariz(0.95)
    build_tube(bm, rings, Vector((0, y0, z0)), Vector((0, y1, z1)))
    return bm

def crear_cola():
    bm = bmesh.new()
    ts = [i / (ANILLOS_COLA - 1) * 0.96 for i in range(ANILLOS_COLA)]
    rings = [ring_Y(*perfil_cola(t), SEG_COLA) for t in ts]
    y1, z1, _, _ = perfil_cola(1.0)
    build_tube(bm, rings, None, Vector((0, y1, z1)))
    return bm

def crear_pata(x, y, trasera):
    bm = bmesh.new()
    sg = 1 if x > 0 else -1
    k  = 1.18 if trasera else 1.0
    # Patas con más volumen y pie palmeado ancho
    spec = [
        (0.092, 0.029,     0.029,     -sg * 0.014, 0.0),
        (0.068, 0.026,     0.026,     -sg * 0.008, 0.0),
        (0.045, 0.023,     0.023,      0.0,        0.0),
        (0.025, 0.021,     0.022,      0.0,        0.005),
        (0.013, 0.032 * k, 0.040 * k,  0.0,        0.015 * k),
        (0.005, 0.030 * k, 0.038 * k,  0.0,        0.015 * k),
        (0.001, 0.028 * k, 0.036 * k,  0.0,        0.014 * k),
    ]
    rings = [ring_Z(x + dx, y + dy, z, rx, ry, SEG_PATA) for z, rx, ry, dx, dy in spec]
    # Tapar la parte superior de la pata (donde se conecta al cuerpo)
    cap_top = Vector((x, y + 0.015 * k, 0.092))
    build_tube(bm, rings, cap_top, Vector((x, y + 0.015 * k, 0.0)))
    return bm

def crear_ojos():
    bm = bmesh.new()
    y, zc, rx, rz = perfil_cabeza(0.68)
    ph = math.radians(28)
    for sg in (-1, 1):
        c = Vector((sg * rx * math.cos(ph) * 0.88, y, zc + rz * math.sin(ph) * 0.88))
        add_elipsoide(bm, c, Vector((0.012, 0.012, 0.012)), SEG_OJO, ANILLOS_OJO)
    return bm

def crear_bigotes():
    """6 bigotes (3 por lado) como cilindros más gruesos para que se vean"""
    bm = bmesh.new()
    y_snout, zc_snout, rx_sn, _ = perfil_cabeza(0.82)
    for sg in (-1, 1):
        for i, (ang_vert, largo) in enumerate([
            (math.radians(8),  0.042),
            (math.radians(0),  0.048),
            (math.radians(-8), 0.040),
        ]):
            x_base = sg * rx_sn * 0.85
            z_base = zc_snout + 0.004 * (1 - i)
            y_base = y_snout + 0.003 * (i - 1)
            rings = []
            for j in range(5):
                t = j / 4.0
                cx = x_base + sg * largo * t * math.cos(ang_vert)
                cy = y_base + largo * t * math.sin(ang_vert)
                cz = z_base
                rings.append(ring_Z(cx, cy, cz, 0.0018, 0.0014, SEG_BIGOTE))
            build_tube(bm, rings)
    return bm

# ---------------- MATERIALES ----------------
def _bsdf(mat):
    mat.use_nodes = True
    return mat.node_tree, mat.node_tree.nodes["Principled BSDF"]

def mat_pelaje(nombre, pal):
    mat = bpy.data.materials.new(nombre)
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Roughness"].default_value = 0.75
    bsdf.inputs["Metallic"].default_value  = 0.0
    attr = nt.nodes.new("ShaderNodeVertexColor"); attr.layer_name = "Col_Pelaje"; attr.location = (-600, 300)
    rgb  = nt.nodes.new("ShaderNodeRGB");  rgb.outputs[0].default_value = (*lin(pal["vientre"]), 1.0); rgb.location = (-600, 80)
    mix  = nt.nodes.new("ShaderNodeMix");  mix.data_type = "RGBA"; mix.blend_type = "MULTIPLY"
    mix.inputs["Factor"].default_value = 1.0; mix.location = (-300, 200)
    nt.links.new(attr.outputs["Color"], mix.inputs[6])
    nt.links.new(rgb.outputs[0],        mix.inputs[7])
    nt.links.new(mix.outputs[2],        bsdf.inputs["Base Color"])
    mat.diffuse_color  = (*lin(pal["principal"]), 1.0)
    mat.use_fake_user  = True
    return mat

def mat_ojos():
    mat = bpy.data.materials.new("MAT_Nutria_Ojos")
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Base Color"].default_value = (*lin(COL_OJOS), 1.0)
    bsdf.inputs["Roughness"].default_value  = 0.15
    em = bsdf.inputs.get("Emission Color") or bsdf.inputs.get("Emission")
    em.default_value = (1.0, 0.82, 0.55, 1.0)
    bsdf.inputs["Emission Strength"].default_value = 0.10
    mat.diffuse_color = (*lin(COL_OJOS), 1.0)
    return mat

def mat_nariz():
    mat = bpy.data.materials.new("MAT_Nutria_Nariz")
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Base Color"].default_value = (*lin(COL_NARIZ), 1.0)
    bsdf.inputs["Roughness"].default_value  = 0.35
    mat.diffuse_color = (*lin(COL_NARIZ), 1.0)
    return mat

def mat_bigotes():
    mat = bpy.data.materials.new("MAT_Nutria_Bigotes")
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Base Color"].default_value = (*lin(COL_BIGOTE), 1.0)
    bsdf.inputs["Roughness"].default_value  = 0.6
    mat.diffuse_color = (*lin(COL_BIGOTE), 1.0)
    return mat

# ---------------- ESCENA ----------------
def limpiar():
    for o in list(bpy.data.objects): bpy.data.objects.remove(o, do_unlink=True)
    for bloque in (bpy.data.meshes, bpy.data.materials):
        for d in list(bloque):
            if d.users == 0 or d.name.startswith(("SM_", "MAT_", "REF_")):
                bloque.remove(d)
    for c in list(bpy.data.collections):
        if c.name.startswith("COL_"): bpy.data.collections.remove(c)

def coleccion(nombre):
    c = bpy.data.collections.new(nombre)
    bpy.context.scene.collection.children.link(c)
    return c

def crear_objeto(nombre, bm, materiales, tinte=None, pivote=Vector((0, 0, 0))):
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(nombre); bm.to_mesh(me); bm.free()
    for m in materiales: me.materials.append(m)
    if SOMBREADO_SUAVE:
        me.polygons.foreach_set("use_smooth", [True] * len(me.polygons))
    if tinte:
        ca = me.color_attributes.new("Col_Pelaje", "FLOAT_COLOR", "POINT")
        for i, v in enumerate(me.vertices):
            ca.data[i].color = (*tinte(v.co), 1.0)
        me.color_attributes.active_color = ca
        me.color_attributes.render_color_index = 0
    if PIVOTES_ARTICULARES:
        for v in me.vertices: v.co -= pivote
    ob = bpy.data.objects.new(nombre, me)
    ob.location = pivote if PIVOTES_ARTICULARES else Vector((0, 0, 0))
    COL_FAUNA.objects.link(ob)
    ob.parent = RAIZ
    return ob

if LIMPIAR_ESCENA: limpiar()

COL_FAUNA = coleccion("COL_Fauna")
COL_REF   = coleccion("COL_Referencia")

bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts: v.co.z += 0.5
me = bpy.data.meshes.new("REF_Cubo_1m"); bm.to_mesh(me); bm.free()
ref = bpy.data.objects.new("REF_Cubo_1m", me); ref.display_type = "WIRE"; ref.hide_render = True
COL_REF.objects.link(ref)

RAIZ = bpy.data.objects.new("SM_Nutria_Ribera", None)
RAIZ.empty_display_type = "PLAIN_AXES"; RAIZ.empty_display_size = 0.2
COL_FAUNA.objects.link(RAIZ)

MATS = {
    "MAT_Nutria_Pelaje_01": mat_pelaje("MAT_Nutria_Pelaje_01", PALETA[1]),
    "MAT_Nutria_Pelaje_02": mat_pelaje("MAT_Nutria_Pelaje_02", PALETA[2]),
    "MAT_Nutria_Ojos":      mat_ojos(),
    "MAT_Nutria_Bigotes":   mat_bigotes(),
}
if USAR_MAT_NARIZ: MATS["MAT_Nutria_Nariz"] = mat_nariz()
PEL = MATS[f"MAT_Nutria_Pelaje_0{VARIANTE_INICIAL}"]

PIV_CABEZA = Vector((0.0, 0.155, 0.148))
PIV_COLA   = Vector((0.0, COLA_Y0, 0.120))

OBJS_PELAJE = [
    crear_objeto("SM_Nutria_Body", crear_cuerpo(), [PEL], tinte_cuerpo),
    crear_objeto("SM_Nutria_Head", crear_cabeza(1 if USAR_MAT_NARIZ else 0),
                 [PEL] + ([MATS["MAT_Nutria_Nariz"]] if USAR_MAT_NARIZ else []), tinte_cabeza, PIV_CABEZA),
    crear_objeto("SM_Nutria_Tail", crear_cola(), [PEL], tinte_cola, PIV_COLA),
]
for nombre, x, y, tras in (("SM_Nutria_Leg_FL", -0.050,  0.098, False),
                           ("SM_Nutria_Leg_FR",  0.050,  0.098, False),
                           ("SM_Nutria_Leg_BL", -0.054, -0.102, True),
                           ("SM_Nutria_Leg_BR",  0.054, -0.102, True)):
    OBJS_PELAJE.append(crear_objeto(nombre, crear_pata(x, y, tras), [PEL], tinte_pata, Vector((x, y, 0.092))))

OJOS    = crear_objeto("SM_Nutria_Eyes",    crear_ojos(),    [MATS["MAT_Nutria_Ojos"]],    None, PIV_CABEZA)
NARIZ   = crear_objeto("SM_Nutria_Nose",    crear_nariz(),   [MATS["MAT_Nutria_Nariz"]],   None, PIV_CABEZA)
BIGOTES = crear_objeto("SM_Nutria_Whiskers", crear_bigotes(), [MATS["MAT_Nutria_Bigotes"]], None, PIV_CABEZA)

# Unir nariz y bigotes en la cabeza para reducir a 8 objetos
def unir_en_objetos(base, extras, nombre_final):
    """Une extras en base, mantiene materiales de ambos"""
    bpy.context.view_layer.objects.active = base
    base.select_set(True)
    for e in extras:
        e.select_set(True)
        bpy.ops.object.join()
    base.name = nombre_final
    return base

CABEZA = OBJS_PELAJE[1]  # SM_Nutria_Head
unir_en_objetos(CABEZA, [NARIZ, BIGOTES], "SM_Nutria_Head")

TODOS = OBJS_PELAJE + [OJOS]

# ---------------- UTILIDADES DE PIPELINE ----------------
def aplicar_variante(n):
    m = MATS[f"MAT_Nutria_Pelaje_0{n}"]
    for o in OBJS_PELAJE: o.data.materials[0] = m

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
print("\n=== SM_Nutria_Ribera v3 — variante ALTA ===")
for o in TODOS:
    n = sum(len(p.vertices) - 2 for p in o.data.polygons); total += n
    print(f"  {o.name:20s} {n:5d} tris")
pts = [o.matrix_world @ v.co for o in TODOS for v in o.data.vertices]
ys, zs, xs = [p.y for p in pts], [p.z for p in pts], [p.x for p in pts]
print(f"  TOTAL: {total} tris  (límite 6000)  | objetos: {len(TODOS)} (≤8) | materiales: {len(MATS)} (≤6)")
print(f"  Largo: {max(ys) - min(ys):.3f} m | Alto: {max(zs):.3f} m | Ancho: {max(xs) - min(xs):.3f} m")
print("  Para exportar:  exportar_glb('/ruta/SM_Nutria_Ribera.glb')")
print("  Para variante 2: aplicar_variante(2)")
