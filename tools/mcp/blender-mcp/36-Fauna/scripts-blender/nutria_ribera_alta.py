# =====================================================================
#  SM_Nutria_Ribera — Generador procedural (Blender 4.x, bpy)
#  Variante ALTA (hero). Estilo cozy: formas orgánicas, low-poly limpio.
#  Ejes: la nutria mira hacia +Y en Blender -> en Godot mira hacia -Z (forward).
# =====================================================================
import bpy, bmesh, math
from mathutils import Vector

# ---------------- CONFIGURACIÓN ----------------
LIMPIAR_ESCENA      = True   # borra todo lo previo
PIVOTES_ARTICULARES = True   # origen de cada parte en su articulación (cuello, base cola, cadera)
                             # False -> todos los orígenes en (0,0,0) (transform 100% aplicado)
SOMBREADO_SUAVE     = True
USAR_MAT_NARIZ      = True   # False -> 3 materiales exactos (la nariz usa pelaje)
VARIANTE_INICIAL    = 1      # 1 = chocolate (estándar) | 2 = oscura

SEG_CUERPO, ANILLOS_CUERPO = 28, 16
SEG_CABEZA, ANILLOS_CABEZA = 24, 14
SEG_COLA,   ANILLOS_COLA   = 14, 9     # >= 5 loops para animar la cola
SEG_PATA                   = 8         # cilindros de 8 lados
SEG_OJO,    ANILLOS_OJO    = 12, 6

PALETA = {
    1: dict(principal=(140, 97, 72), vientre=(180, 140, 110), oscuro=(100, 68, 48)),
    2: dict(principal=(107, 76, 61), vientre=(150, 115,  90), oscuro=( 70, 48, 35)),
}
COL_OJOS  = (30, 20, 10)
COL_NARIZ = (50, 35, 25)

# ---------------- UTILIDADES ----------------
def lin(c):
    """sRGB 0-255 -> lineal 0-1 (Blender/glTF trabajan en lineal)."""
    def f(v):
        v /= 255.0
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
    return tuple(f(x) for x in c)

def clamp(v, a, b): return max(a, min(b, v))
def lerp(a, b, t):  return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))
def smooth(t):      t = clamp(t, 0, 1); return t * t * (3 - 2 * t)
def angs(n):        return [2 * math.pi * i / n for i in range(n)]

def ring_Y(cy, cz, rx, rz, n, cx=0.0):
    """Anillo elíptico en el plano XZ (tubo a lo largo de Y)."""
    return [Vector((cx + rx * math.cos(a), cy, cz + rz * math.sin(a))) for a in angs(n)]

def ring_Z(cx, cy, cz, rx, ry, n):
    """Anillo elíptico en el plano XY (tubo a lo largo de Z)."""
    return [Vector((cx + rx * math.cos(a), cy + ry * math.sin(a), cz)) for a in angs(n)]

def build_tube(bm, rings, cap_ini=None, cap_fin=None):
    """Conecta anillos con quads; polos opcionales cerrados con abanico de tris."""
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

# ---------------- PERFILES ANATÓMICOS ----------------
# Todas las medidas en metros. Largo total nariz->punta de cola ~0.70 m.
CUERPO_Y0, CUERPO_Y1 = -0.17, 0.17          # torso (34 cm)
def perfil_cuerpo(t):                        # t: 0 grupa -> 1 cuello
    u  = 2 * t - 1
    s  = (1 - abs(u) ** 2.6) ** (1 / 2.6)    # superelipse = "salchicha suave"
    bulto = 1.06 - 0.12 * t                  # caderas algo más anchas que hombros
    rx = 0.072 * s * bulto
    rz = 0.082 * s * (1.0 + 0.04 * (1 - t))
    zc = 0.115 + 0.018 * math.sin(math.pi * t)   # lomo ligeramente arqueado
    y  = CUERPO_Y0 + (CUERPO_Y1 - CUERPO_Y0) * t
    return y, zc, rx, rz

CABEZA_C = Vector((0.0, 0.205, 0.136))
CABEZA_ATRAS, CABEZA_DELANTE = 0.058, 0.070  # cráneo / hocico
def perfil_cabeza(t):                        # t: 0 nuca -> 1 nariz
    y = CABEZA_C.y - CABEZA_ATRAS + (CABEZA_ATRAS + CABEZA_DELANTE) * t
    u = 2 * t - 1
    s = (1 - abs(u) ** 2.4) ** (1 / 2.4) if u < 0 else (1 - u ** 3.2) ** (1 / 3.2)  # hocico romo
    rx, rz = 0.057 * s, 0.046 * s            # ancha y achatada
    if t > 0.62:                             # estrechamiento suave del hocico
        k = (t - 0.62) / 0.38
        rx *= 1 - 0.30 * k; rz *= 1 - 0.30 * k
    zc = CABEZA_C.z - 0.006 * max(0.0, u)    # nariz un pelín más baja
    return y, zc, rx, rz

COLA_Y0, COLA_Y1 = -0.14, -0.43              # 29 cm (~41 % del total)
def perfil_cola(t):                          # t: 0 base -> 1 punta
    y  = COLA_Y0 + (COLA_Y1 - COLA_Y0) * t
    rx = 0.007 + 0.037 * (1 - t) ** 1.25     # gruesa en la base, con volumen a media cola
    rz = rx * 0.72                           # cola aplanada dorsoventralmente
    zc = 0.118 - 0.090 * (t ** 1.4)          # cae suavemente hacia el suelo
    return y, zc, rx, rz

# ---------------- TINTE POR VERTEX COLOR (lomo oscuro / vientre claro) ----------------
# Base Color del material = color VIENTRE; el vertex color oscurece hacia el lomo.
_p1 = PALETA[1]
TINT_V = (1.0, 1.0, 1.0)
TINT_P = tuple(a / b for a, b in zip(lin(_p1["principal"]), lin(_p1["vientre"])))
TINT_O = tuple(a / b for a, b in zip(lin(_p1["oscuro"]),    lin(_p1["vientre"])))

def tinte_dorsal(w):  # w: 0 vientre -> 1 lomo
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
    return tinte_dorsal(0.10 + 0.90 * (h + 1) / 2)   # garganta/mejillas claras

def tinte_cola(co):
    t = clamp((co.y - COLA_Y0) / (COLA_Y1 - COLA_Y0), 0.0, 0.97)
    _, zc, _, rz = perfil_cola(t)
    h = clamp((co.z - zc) / max(rz, 1e-4), -1, 1)
    return tinte_dorsal(0.45 + 0.55 * (h + 1) / 2)

def tinte_pata(co):
    return tinte_dorsal(0.50 + 0.35 * clamp(co.z / 0.09, 0, 1))

# ---------------- GEOMETRÍA ----------------
def crear_cuerpo():
    bm = bmesh.new()
    ts = [0.5 - 0.5 * math.cos(math.pi * i / ANILLOS_CUERPO) for i in range(1, ANILLOS_CUERPO)]
    rings = [ring_Y(*perfil_cuerpo(t), SEG_CUERPO) for t in ts]
    y0, z0, _, _ = perfil_cuerpo(0.0); y1, z1, _, _ = perfil_cuerpo(1.0)
    build_tube(bm, rings, Vector((0, y0, z0)), Vector((0, y1, z1)))
    return bm

def crear_cabeza(mat_idx_nariz):
    bm = bmesh.new()
    ts = [0.5 - 0.5 * math.cos(math.pi * i / ANILLOS_CABEZA) for i in range(1, ANILLOS_CABEZA)]
    ts = [t * 0.995 / ts[-1] for t in ts]              # último anillo = almohadilla nasal
    rings = [ring_Y(*perfil_cabeza(t), SEG_CABEZA) for t in ts]
    y0, z0, _, _ = perfil_cabeza(0.0); yn, zn, _, _ = perfil_cabeza(0.995)
    build_tube(bm, rings, Vector((0, y0, z0)), Vector((0, yn, zn)))   # nariz plana (abanico)
    # Nariz: solo el abanico frontal
    for f in bm.faces:
        if all(v.co.y >= yn - 1e-5 for v in f.verts):
            f.material_index = mat_idx_nariz
    # Orejas: protuberancias diminutas sobre la cabeza (misma malla)
    y, zc, rx, rz = perfil_cabeza(0.40)
    ph = math.radians(58)
    for sg in (-1, 1):
        c = Vector((sg * rx * math.cos(ph) * 0.96, y, zc + rz * math.sin(ph) * 0.96))
        add_elipsoide(bm, c, Vector((0.0095, 0.0070, 0.0105)), 6, 4)
    return bm

def crear_cola():
    bm = bmesh.new()
    ts = [i / (ANILLOS_COLA - 1) * 0.96 for i in range(ANILLOS_COLA)]
    rings = [ring_Y(*perfil_cola(t), SEG_COLA) for t in ts]
    y1, z1, _, _ = perfil_cola(1.0)
    build_tube(bm, rings, None, Vector((0, y1, z1)))   # base abierta dentro del cuerpo
    return bm

def crear_pata(x, y, trasera):
    bm = bmesh.new()
    sg = 1 if x > 0 else -1
    k  = 1.15 if trasera else 1.0                      # pies traseros algo mayores
    spec = [   # (z, rx, ry, dx, dy)   -> hombro/cadera, codo, muñeca, tobillo, pie palmeado
        (0.090, 0.027,     0.027,     -sg * 0.013, 0.0),
        (0.065, 0.024,     0.024,     -sg * 0.007, 0.0),
        (0.042, 0.021,     0.021,      0.0,        0.0),
        (0.022, 0.019,     0.020,      0.0,        0.004),
        (0.011, 0.029 * k, 0.036 * k,  0.0,        0.013 * k),
        (0.003, 0.027 * k, 0.034 * k,  0.0,        0.013 * k),
    ]
    rings = [ring_Z(x + dx, y + dy, z, rx, ry, SEG_PATA) for z, rx, ry, dx, dy in spec]
    build_tube(bm, rings, None, Vector((x, y + 0.013 * k, 0.0)))   # planta en Z=0
    return bm

def crear_ojos():
    bm = bmesh.new()
    y, zc, rx, rz = perfil_cabeza(0.70)
    ph = math.radians(30)
    for sg in (-1, 1):
        c = Vector((sg * rx * math.cos(ph) * 0.90, y, zc + rz * math.sin(ph) * 0.90))
        add_elipsoide(bm, c, Vector((0.0105, 0.0105, 0.0105)), SEG_OJO, ANILLOS_OJO)
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
    mat.diffuse_color  = (*lin(pal["principal"]), 1.0)   # color en viewport sólido
    mat.use_fake_user  = True                            # la variante no asignada no se pierde
    return mat

def mat_ojos():
    mat = bpy.data.materials.new("MAT_Nutria_Ojos")
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Base Color"].default_value = (*lin(COL_OJOS), 1.0)
    bsdf.inputs["Roughness"].default_value  = 0.2
    em = bsdf.inputs.get("Emission Color") or bsdf.inputs.get("Emission")
    em.default_value = (1.0, 0.82, 0.55, 1.0)            # cálido
    bsdf.inputs["Emission Strength"].default_value = 0.08
    mat.diffuse_color = (*lin(COL_OJOS), 1.0)
    return mat

def mat_nariz():
    mat = bpy.data.materials.new("MAT_Nutria_Nariz")
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Base Color"].default_value = (*lin(COL_NARIZ), 1.0)
    bsdf.inputs["Roughness"].default_value  = 0.4
    mat.diffuse_color = (*lin(COL_NARIZ), 1.0)
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
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)      # Merge by Distance
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)           # normales hacia fuera
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

# Cubo de referencia 1 m (NO exportar)
bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts: v.co.z += 0.5
me = bpy.data.meshes.new("REF_Cubo_1m"); bm.to_mesh(me); bm.free()
ref = bpy.data.objects.new("REF_Cubo_1m", me); ref.display_type = "WIRE"; ref.hide_render = True
COL_REF.objects.link(ref)

# Empty raíz con el pivote en el suelo (pies en Z=0)
RAIZ = bpy.data.objects.new("SM_Nutria_Ribera", None)
RAIZ.empty_display_type = "PLAIN_AXES"; RAIZ.empty_display_size = 0.2
COL_FAUNA.objects.link(RAIZ)

MATS = {
    "MAT_Nutria_Pelaje_01": mat_pelaje("MAT_Nutria_Pelaje_01", PALETA[1]),
    "MAT_Nutria_Pelaje_02": mat_pelaje("MAT_Nutria_Pelaje_02", PALETA[2]),
    "MAT_Nutria_Ojos":      mat_ojos(),
}
if USAR_MAT_NARIZ: MATS["MAT_Nutria_Nariz"] = mat_nariz()
PEL = MATS[f"MAT_Nutria_Pelaje_0{VARIANTE_INICIAL}"]

PIV_CABEZA = Vector((0.0, 0.155, 0.130))
PIV_COLA   = Vector((0.0, COLA_Y0, 0.118))

OBJS_PELAJE = [
    crear_objeto("SM_Nutria_Body", crear_cuerpo(), [PEL], tinte_cuerpo),
    crear_objeto("SM_Nutria_Head", crear_cabeza(1 if USAR_MAT_NARIZ else 0),
                 [PEL] + ([MATS["MAT_Nutria_Nariz"]] if USAR_MAT_NARIZ else []), tinte_cabeza, PIV_CABEZA),
    crear_objeto("SM_Nutria_Tail", crear_cola(), [PEL], tinte_cola, PIV_COLA),
]
for nombre, x, y, tras in (("SM_Nutria_Leg_FL", -0.048,  0.095, False),
                           ("SM_Nutria_Leg_FR",  0.048,  0.095, False),
                           ("SM_Nutria_Leg_BL", -0.052, -0.100, True),
                           ("SM_Nutria_Leg_BR",  0.052, -0.100, True)):
    OBJS_PELAJE.append(crear_objeto(nombre, crear_pata(x, y, tras), [PEL], tinte_pata, Vector((x, y, 0.09))))

OJOS = crear_objeto("SM_Nutria_Eyes", crear_ojos(), [MATS["MAT_Nutria_Ojos"]], None, PIV_CABEZA)
TODOS = OBJS_PELAJE + [OJOS]

# ---------------- UTILIDADES DE PIPELINE ----------------
def aplicar_variante(n):
    """Cambia el material de pelaje de todas las partes (1 o 2)."""
    m = MATS[f"MAT_Nutria_Pelaje_0{n}"]
    for o in OBJS_PELAJE: o.data.materials[0] = m

def exportar_glb(ruta):
    """Exporta solo la nutria (sin cubo de referencia). +Y up, modifiers ON, sin animación."""
    bpy.ops.object.select_all(action="DESELECT")
    RAIZ.select_set(True)
    for o in TODOS: o.select_set(True)
    bpy.context.view_layer.objects.active = RAIZ
    bpy.ops.export_scene.gltf(filepath=ruta, export_format="GLB", use_selection=True,
                              export_yup=True, export_apply=True, export_animations=False)

# ---------------- ESTADÍSTICAS / CHECKLIST ----------------
bpy.context.view_layer.update()
total = 0
print("\n=== SM_Nutria_Ribera — variante ALTA ===")
for o in TODOS:
    n = sum(len(p.vertices) - 2 for p in o.data.polygons); total += n
    print(f"  {o.name:20s} {n:5d} tris   scale={tuple(round(s, 3) for s in o.scale)}")
pts = [o.matrix_world @ v.co for o in TODOS for v in o.data.vertices]
ys, zs, xs = [p.y for p in pts], [p.z for p in pts], [p.x for p in pts]
print(f"  TOTAL: {total} tris  (límite 6000)  | objetos: {len(TODOS)} (≤8) | materiales: {len(MATS)} (≤6)")
print(f"  Largo total: {max(ys) - min(ys):.3f} m | alto: {max(zs):.3f} m | ancho: {max(xs) - min(xs):.3f} m | Z min: {min(zs):.4f}")
print("  Para exportar:  exportar_glb('/ruta/SM_Nutria_Ribera.glb')")
print("  Para variante 2: aplicar_variante(2)")
