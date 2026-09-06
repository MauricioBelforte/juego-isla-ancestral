SM_Elefante_Pradera — Variante ALTA (hero)
Misma estrategia que la nutria: script bpy procedural, sin subsurf, tubos por anillos con edge loops controlados, vertex color para el degradado lomo/vientre, naming y colección según convención. Como no me diste ficha de especie, propongo una coherente con el proyecto (ajústala si hace falta):

Dato	Valor
Nombre	Elefante de Pradera (base Loxodonta africana, proporciones suavizadas)
Bioma	Pradera / sabana abierta, cerca de charcas
Comportamiento	Tranquilo, curioso (se acerca lento, huele con la trompa)
Rareza	Raro (fauna "hero")
Escala en juego	0.8–1.0 → ~2,3 m a la cruz, ~3,2 m de largo con trompa
Variantes	1: Gris Cálido (estándar) / 2: Arcilla (bañado en barro, poco común)
Decisiones de estilo cozy sobre la anatomía real: lomo convexo y redondeado (no el "sillín" hundido del africano), frente abombada, orejas grandes pero de bordes redondos, colmillos cortos y romos (amigable, nunca amenazante), trompa colgando con la punta ligeramente curvada hacia arriba (gesto curioso), patas columnares con 3 uñas sugeridas.

Estructura (8 objetos, presupuesto respetado)
El elefante tiene más partes articuladas que la nutria (trompa, orejas, cola, colmillos, ojos). Para no pasar de 8 objetos:

text

SM_Elefante_Pradera (Empty, pivote en el suelo)
├── SM_Elefante_Body      torso + cola (la cola va al mismo mesh; para el rig se pesa a su hueso igualmente)
├── SM_Elefante_Head      cráneo + ojos (slot MAT_Elefante_Ojos) + colmillos (slot MAT_Elefante_Marfil)
├── SM_Elefante_Trunk     trompa, 18 loops (animación de olfateo/curl)
├── SM_Elefante_Ears      ambas orejas en un mesh (abanicar) — flag para separarlas
├── SM_Elefante_Leg_FL / FR / BL / BR   pata + uñas (slot Marfil)
Materiales: MAT_Elefante_Piel_01, MAT_Elefante_Piel_02, MAT_Elefante_Ojos, MAT_Elefante_Marfil (4 ≤ 6). Hay flags OJOS_SEPARADOS y COLA_SEPARADA si prefieres 9–10 objetos con ojos/cola como en la nutria.

El script
Scripting → New → Run Script (Blender 4.x).

Python

# =====================================================================
#  SM_Elefante_Pradera — Generador procedural (Blender 4.x, bpy)
#  Variante ALTA (hero). Cozy: formas redondeadas, low-poly limpio, sin subsurf.
#  Mira hacia +Y en Blender -> -Z (forward) en Godot.
# =====================================================================
import bpy, bmesh, math
from mathutils import Vector, Matrix

# ---------------- CONFIGURACIÓN ----------------
LIMPIAR_ESCENA      = True
PIVOTES_ARTICULARES = True    # origen de cada parte en su articulación
SOMBREADO_SUAVE     = True
OJOS_SEPARADOS      = False   # True -> SM_Elefante_Eyes como objeto (9 obj)
COLA_SEPARADA       = False   # True -> SM_Elefante_Tail como objeto (+1 obj)
VARIANTE_INICIAL    = 1       # 1 = gris cálido | 2 = arcilla

SEG_CUERPO,   ANILLOS_CUERPO   = 32, 18
SEG_CABEZA,   ANILLOS_CABEZA   = 28, 14
SEG_TROMPA,   ANILLOS_TROMPA   = 12, 18   # muchos loops: la trompa es la parte más animada
SEG_COLA,     ANILLOS_COLA     = 8,  12
SEG_PATA                       = 10
SEG_OREJA,    ANILLOS_OREJA    = 14, 10
SEG_COLMILLO, ANILLOS_COLMILLO = 8,  9
SEG_OJO,      ANILLOS_OJO      = 10, 5

PALETA = {
    1: dict(principal=(128, 118, 110), vientre=(152, 142, 133), oscuro=(98, 88, 82)),   # gris cálido
    2: dict(principal=(136, 110,  95), vientre=(162, 140, 124), oscuro=(104, 82, 70)),  # arcilla
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
    """Anillo perpendicular a la tangente 'tang' (sirve para tubos curvos)."""
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
    """Tubo a lo largo de una curva path(t) con radios(t) -> (rx, rz)."""
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
    """Elipsoide en espacio local transformado por tf(p) -> mundo."""
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
# CUERPO: barril redondeado, lomo convexo (cozy), hombros algo más altos que la grupa
CUERPO_Y0, CUERPO_Y1 = -1.00, 0.95
def path_cuerpo(t):
    return Vector((0.0, CUERPO_Y0 + (CUERPO_Y1 - CUERPO_Y0) * t,
                   1.50 + 0.10 * math.sin(math.pi * t) + 0.06 * t))
def radios_cuerpo(t):
    u = 2 * t - 1
    s = (1 - abs(u) ** 3.0) ** (1 / 3.0)         # superelipse "barril"
    return 0.66 * s * (1.0 - 0.06 * t), 0.74 * s

# COLA: fina, cae desde la grupa con mechón en la punta
def path_cola(t):
    return Vector((0.0, -0.92 - 0.36 * t - 0.05 * math.sin(math.pi * t), 1.66 - 0.80 * t))
def radios_cola(t):
    r = 0.028 + 0.045 * (1 - t) ** 1.3
    if t > 0.80: r += 0.04 * math.sin(math.pi * (t - 0.80) / 0.20)   # mechón
    return r, r

# CABEZA: abombada, frente alta, cara que baja hacia la base de la trompa
def path_cabeza(t):
    return Vector((0.0, 0.70 + 1.02 * t, 1.78 - 0.30 * t * t + 0.03 * math.sin(math.pi * t)))
def radios_cabeza(t):
    u = 2 * t - 1
    s = (1 - abs(u) ** 2.8) ** (1 / 2.8)
    k = max(0.0, (t - 0.70) / 0.30)                # cara se estrecha al frente
    return 0.46 * s * (1 - 0.28 * k), 0.52 * s * (1 - 0.20 * k)

# TROMPA: cuelga hacia delante y abajo, punta curvada hacia arriba (curiosa)
TROMPA_BASE = Vector((0.0, 1.62, 1.40))
def path_trompa(t):
    c = max(0.0, (t - 0.82) / 0.18) ** 2
    y = TROMPA_BASE.y + 0.28 * math.sin(math.pi * t) * (1 - 0.35 * t) + 0.12 * t + 0.10 * c
    z = TROMPA_BASE.z - 1.22 * t + 0.14 * c
    return Vector((0.0, y, z))
def radios_trompa(t):
    rx = 0.045 + 0.125 * (1 - t) ** 1.1
    return rx, rx * 0.95

# COLMILLOS: cortos, romos, curvan suavemente hacia fuera y arriba
def path_colmillo(sg):
    return lambda t: Vector((sg * (0.17 + 0.12 * t), 1.56 + 0.50 * t, 1.32 - 0.30 * t + 0.22 * t * t))
def radios_colmillo(t):
    r = 0.018 + 0.052 * (1 - t)
    return r, r

# OREJAS: disco aplanado con lóbulo superior ancho, giradas hacia atrás/fuera
def tf_oreja(sg):
    P   = Vector((sg * 0.40, 1.13, 1.80))         # punto de anclaje en el lateral del cráneo
    off = Vector((0.0, -0.15, -0.06))             # la oreja cuelga hacia atrás
    R   = Matrix.Rotation(math.radians(sg * 35), 4, 'Z') @ Matrix.Rotation(math.radians(sg * 12), 4, 'Y')
    def tf(p):
        zn = p.z / 0.50
        y  = p.y * (0.72 + 0.32 * zn) - 0.05 * (1 - zn)                          # arriba ancha, abajo lóbulo estrecho
        x  = p.x * (0.45 + 0.55 * (1 - zn * zn)) * (0.55 + 0.45 * clamp((p.y + 0.40) / 0.80, 0, 1))  # fina en bordes
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
    if co.y < -0.97 and co.z < 1.55: return tinte_dorsal(0.75)          # cola
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
        ce = Vector((sg * rx * math.cos(ph) * 0.93, c.y, c.z + rz * math.sin(ph) * 0.93))  # hundidos 7 %
        add_elipsoide(bm, Vector((0.042, 0.042, 0.042)), SEG_OJO, ANILLOS_OJO, lambda p, ce=ce: p + ce, mat)

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
    #        z      r      dx (los anillos altos se meten hacia el vientre para quedar dentro del cuerpo)
    spec = [(1.35, 0.270, -0.04), (1.05, 0.235, -0.02), (0.75, 0.212, 0.0), (0.45, 0.200, 0.0),
            (0.20, 0.215, 0.0),   (0.09, 0.245, 0.0),   (0.00, 0.250, 0.0)]
    rings = [ring_Z(x + sg * dx, y, z, r, r * 1.05, SEG_PATA) for z, r, dx in spec]
    build_tube(bm, rings, None, Vector((x, y, 0.0)))               # planta en Z=0
    for f in bm.faces:                                             # uñas: banda inferior, cara frontal
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
    bsdf.inputs["Roughness"].default_value = 0.85     # piel mate, rugosa
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
        blancos = set()                                  # ojos/marfil/uñas no reciben tinte
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

PIV_CABEZA = Vector((0.0, 0.85, 1.65))     # articulación cuello
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
Qué produce
text

COL_Fauna
└── SM_Elefante_Pradera (Empty, pivote en el suelo)
    ├── SM_Elefante_Body   ~1.340 tris   barril 32×18 + cola (12 loops, mechón)
    ├── SM_Elefante_Head   ~1.220 tris   cráneo abombado 28×14 + 2 colmillos romos + 2 ojos Ø 8,4 cm
    ├── SM_Elefante_Trunk  ~  420 tris   18 loops, Ø 34 cm → 9 cm, punta curvada
    ├── SM_Elefante_Ears   ~  500 tris   2 discos 1,0 × 0,8 m, giradas 35° atrás / 12° abiertas
    └── SM_Elefante_Leg_*  ~  130 tris c/u   columnas 10 lados, 7 loops, 3 uñas de marfil
COL_Referencia
└── REF_Cubo_1m (wire, no se exporta)
Total ≈ 4.000 tris, 8 objetos, 4 materiales.
Dimensiones: ~3,2 m de largo (cola → punta de trompa), ~2,3 m a la cruz, ~1,5 m de ancho con orejas.
Piel: mismo esquema de vertex color Col_Piel (vientre claro → lomo oscuro). Los vértices de ojos, colmillos y uñas se escriben en blanco para que Godot no los tiña cuando active vertex color as albedo en ese mesh.
Marfil cálido #E2D7C0, roughness 0.45 — usado tanto en colmillos como en uñas, sin gastar material extra.
Checklist de validación
Ítem	Cómo lo cumple
≤ 6.000 tris / ≤ 8 obj / ≤ 6 mats	~4.000 / 8 / 4 (impreso en consola)
Sin duplicados / normales outward	remove_doubles + recalc_face_normals por objeto
Sin caras internas	Trompa, colmillos, cola y patas quedan abiertos donde entran en cuerpo/cabeza; los anillos superiores de las patas se desplazan hacia dentro para quedar ocultos en el vientre
Transformaciones	scale (1,1,1), rot 0; location = articulación (cuello, base de trompa, caderas). PIVOTES_ARTICULARES=False para todo a 0
Pivote en base	Plantas en Z=0 exacto, Empty en el origen
Simetría	Analítica, sin Symmetrize
Sin subsurf	Solo quads + abanicos en polos
Vista 3/4 desde arriba (tu cámara): la silueta se lee por el lomo redondo, la cúpula de la cabeza sobresaliendo del cuello, las orejas abiertas y la trompa cayendo por delante. Los colmillos cortos aportan reconocimiento sin agresividad.

Godot 4
exportar_glb(...) → GLB, +Y up, modifiers ON, sin animación, solo selección. Llega como Node3D "SM_Elefante_Pradera" con 8 MeshInstance3D; Head trae 3 surfaces (piel/ojos/marfil), cada pata 2 (piel/marfil). Mira hacia -Z. Variante 2: material_override del surface 0 con el StandardMaterial3D arcilla (mismo mesh) o exportar un segundo GLB tras aplicar_variante(2). Escala 0.8–1.0 en el nodo raíz. Para el CharacterBody usa una cápsula de radio ~0,7 m y alto ~2,3 m centrada en (0, 1.15, 0.0).

Ajustes finos
Más rechoncho/cozy → exponente del barril 3.0 → 3.5 y 0.74 → 0.80 en radios_cuerpo.
Orejas más grandes (africano) / pequeñas (asiático) → r=(0.035, 0.40, 0.50) en crear_orejas; ángulo 35° para abrirlas más.
Trompa más curiosa (curl mayor) → 0.14 * c y 0.10 * c en path_trompa; más recta → bajar 0.28.
Colmillos → 0.052 (grosor) y 0.50 (largo) en radios_colmillo/path_colmillo. Para crías, pon 0.0 en radios y quedan ocultos.
Boca / labio inferior (opcional): 2 loops del cráneo en t≈0.9 → Alt+S -0.02 en la mitad inferior.
Arrugas (opcional, ~150 tris): en Edit Mode selecciona 3 loops de la trompa y 2 del lomo → Alt+S -0.01 alterno; el sombreado suave las lee como pliegues sin geometría extra.
MEDIA (≤1.500 / 4 obj / 4 mats): Decimate Collapse 0.35 y Join → Body+Legs, Head+Ears, Trunk (3 obj; Ojos+Marfil+Piel = 3 mats). BAJA (≤700 / 3 obj / 3 mats): ratio 0.17, todo en un objeto salvo la trompa; pinta las uñas con vertex color en vez de marfil.




SM_Jirafa_Pradera y SM_Oso_Bosque — Variante ALTA (hero)
Misma estrategia: script bpy procedural, tubos por anillos con edge loops controlados, sin subsurf, vertex color para el degradado, naming/colección según convención, pivote en el suelo, +Y forward en Blender → −Z en Godot.

Como ahora son dos especies, separé el código en un NÚCLEO común (utilidades, materiales, escena) y un bloque por especie. Pega en un mismo archivo de texto de Blender: NÚCLEO + JIRAFA o NÚCLEO + OSO, y ejecuta.

Novedad para la jirafa: el patrón de manchas se genera por Voronoi 3D en el vertex color (sin texturas, sin UVs). Como se evalúa en coordenadas de mundo, las manchas continúan sin costura entre cuerpo, cuello y patas.

Fichas propuestas (ajusta lo que quieras)
Dato	Jirafa de Pradera	Oso Pardo de Bosque
Base real	Giraffa camelopardalis	Ursus arctos
Bioma	Pradera / sabana con acacias	Bosque / ribera (pesca)
Comportamiento	Tranquila, curiosa (baja la cabeza a oler)	Tranquilo, curioso (se sienta, olfatea)
Rareza / Horario	Rara / diurna	Poco común / crepuscular
Tamaño (escala 1.0)	~4,4 m alto, ~3,2 m largo	~1,15 m cruz, ~1,9 m largo
Variantes	1 Sabana (crema + caramelo) / 2 Acacia (oscura)	1 Pardo Miel / 2 Pardo Oscuro
Estilo cozy	Cuello y patas un poco más gruesos, osiconos con pompón, hocico redondeado	Muy redondo, joroba suave, hocico corto y claro, orejas grandes redondas
Estructura (8 objetos cada uno):

text

SM_Jirafa_Pradera                     SM_Oso_Bosque
├── SM_Jirafa_Body (torso + cola)     ├── SM_Oso_Body (torso + muñón de cola)
├── SM_Jirafa_Neck (20 loops)         ├── SM_Oso_Head (+ nariz slot MAT_Oso_Nariz)
├── SM_Jirafa_Head (+osiconos+orejas) ├── SM_Oso_Ears (2 discos, animación de twitch)
├── SM_Jirafa_Leg_FL/FR/BL/BR         ├── SM_Oso_Leg_FL/FR/BL/BR (almohadillas + garras slot Nariz)
└── SM_Jirafa_Eyes                    └── SM_Oso_Eyes
Mats: Pelaje_01, Pelaje_02, Ojos,     Mats: Pelaje_01, Pelaje_02, Ojos, Nariz  (4)
      Detalle (pezuñas/hocico/pompón) (4)
1) NÚCLEO COMÚN (pegar primero)
Python

# ============================================================
#  NÚCLEO COMÚN — Fauna procedural cozy (Blender 4.x, bpy)
#  Pega este bloque y, DEBAJO, el bloque de la especie.
# ============================================================
import bpy, bmesh, math
from mathutils import Vector, Matrix

LIMPIAR_ESCENA      = True
PIVOTES_ARTICULARES = True    # origen de cada parte en su articulación
SOMBREADO_SUAVE     = True

# ---------- color ----------
def lin(c):
    def f(v):
        v /= 255.0
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
    return tuple(f(x) for x in c)
def clamp(v, a, b): return max(a, min(b, v))
def lerp(a, b, t):  return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))
def smooth(t):      t = clamp(t, 0, 1); return t * t * (3 - 2 * t)
def angs(n):        return [2 * math.pi * i / n for i in range(n)]

def hacer_tintes(pal):
    """Base Color del material = 'vientre'; el vertex color multiplica hacia principal/oscuro."""
    V = (1.0, 1.0, 1.0)
    P = tuple(a / b for a, b in zip(lin(pal["principal"]), lin(pal["vientre"])))
    O = tuple(a / b for a, b in zip(lin(pal["oscuro"]),    lin(pal["vientre"])))
    def dorsal(w):  # w: 0 vientre -> 1 lomo
        return lerp(V, P, smooth(w / 0.5)) if w < 0.5 else lerp(P, O, smooth((w - 0.5) / 0.5))
    return V, P, O, dorsal

# ---------- geometría ----------
def ring_Z(cx, cy, cz, rx, ry, n):
    return [Vector((cx + rx * math.cos(a), cy + ry * math.sin(a), cz)) for a in angs(n)]

def frame(tang):
    t  = tang.normalized()
    up = Vector((1, 0, 0)).cross(t)
    if up.length < 1e-6: up = Vector((0, 1, 0))
    up.normalize()
    return t.cross(up).normalized(), up          # (side, up=dorsal)

def ring_frame(c, tang, rx, rz, n):
    side, up = frame(tang)
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
    """Tubo a lo largo de path(t) con radios(t)->(rx, rz). punta: redondeo del cierre final."""
    n0 = len(bm.faces)
    if coseno: ts = [t0 + (t1 - t0) * (0.5 - 0.5 * math.cos(math.pi * i / (n_anillos - 1))) for i in range(n_anillos)]
    else:      ts = [t0 + (t1 - t0) * i / (n_anillos - 1) for i in range(n_anillos)]
    def tang(t):
        e = 1e-3
        return path(min(t + e, 1.0)) - path(max(t - e, 0.0))
    rings = [ring_frame(path(t), tang(t), *radios(t), n_seg) for t in ts]
    ci = path(t0) if cap_ini else None
    cf = (path(t1) + tang(t1).normalized() * radios(t1)[0] * punta) if cap_fin else None
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

def tf_desplazar(c): return lambda p: p + c
def tf_rot(P, R):    return lambda p: P + R @ p

def perfil_interp(keys, z):
    """Interpolación lineal de (z, radio)."""
    keys = sorted(keys)
    if z <= keys[0][0]: return keys[0][1]
    for (z0, r0), (z1, r1) in zip(keys[:-1], keys[1:]):
        if z <= z1: return r0 + (r1 - r0) * (z - z0) / (z1 - z0)
    return keys[-1][1]

def coord_local(co, path, radios, muestras=40):
    """Devuelve (t, h): posición a lo largo del tubo y altura dorsal normalizada [-1,1]."""
    best = None
    for i in range(muestras + 1):
        t = i / muestras; c = path(t); d = (co - c).length_squared
        if best is None or d < best[0]: best = (d, t, c)
    _, t, c = best
    e = 1e-3
    _, up = frame(path(min(t + e, 1)) - path(max(t - e, 0)))
    return t, clamp((co - c).dot(up) / max(radios(t)[1], 1e-4), -1, 1)

# ---------- Voronoi 3D (manchas) ----------
def _h(i, j, k, s):
    n = (i * 73856093) ^ (j * 19349663) ^ (k * 83492791) ^ (s * 2654435761)
    n = (n * 1103515245 + 12345) & 0x7FFFFFFF
    return n / 0x7FFFFFFF

def voronoi_borde(p, escala, semilla=7):
    """F2-F1: ~0 en las líneas entre celdas, alto en el centro de la celda."""
    q = p / escala
    ci, cj, ck = math.floor(q.x), math.floor(q.y), math.floor(q.z)
    f1 = f2 = 9.0
    for i in (ci - 1, ci, ci + 1):
        for j in (cj - 1, cj, cj + 1):
            for k in (ck - 1, ck, ck + 1):
                fp = Vector((i + _h(i, j, k, semilla), j + _h(i, j, k, semilla + 1), k + _h(i, j, k, semilla + 2)))
                d = (fp - q).length
                if d < f1: f1, f2 = d, f1
                elif d < f2: f2 = d
    return f2 - f1

# ---------- materiales ----------
def _bsdf(mat):
    mat.use_nodes = True
    return mat.node_tree, mat.node_tree.nodes["Principled BSDF"]

def mat_pelaje(nombre, pal, rough=0.75):
    mat = bpy.data.materials.new(nombre)
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value  = 0.0
    attr = nt.nodes.new("ShaderNodeVertexColor"); attr.layer_name = "Col_Pelaje"; attr.location = (-600, 300)
    rgb  = nt.nodes.new("ShaderNodeRGB"); rgb.outputs[0].default_value = (*lin(pal["vientre"]), 1.0); rgb.location = (-600, 80)
    mix  = nt.nodes.new("ShaderNodeMix"); mix.data_type = "RGBA"; mix.blend_type = "MULTIPLY"
    mix.inputs["Factor"].default_value = 1.0; mix.location = (-300, 200)
    nt.links.new(attr.outputs["Color"], mix.inputs[6])
    nt.links.new(rgb.outputs[0],        mix.inputs[7])
    nt.links.new(mix.outputs[2],        bsdf.inputs["Base Color"])
    mat.diffuse_color = (*lin(pal["principal"]), 1.0)
    mat.use_fake_user = True
    return mat

def mat_ojos(nombre, color=(30, 20, 10)):
    mat = bpy.data.materials.new(nombre)
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Base Color"].default_value = (*lin(color), 1.0)
    bsdf.inputs["Roughness"].default_value  = 0.2
    em = bsdf.inputs.get("Emission Color") or bsdf.inputs.get("Emission")
    em.default_value = (1.0, 0.82, 0.55, 1.0)
    bsdf.inputs["Emission Strength"].default_value = 0.08
    mat.diffuse_color = (*lin(color), 1.0)
    return mat

def mat_plano(nombre, color, rough):
    mat = bpy.data.materials.new(nombre)
    nt, bsdf = _bsdf(mat)
    bsdf.inputs["Base Color"].default_value = (*lin(color), 1.0)
    bsdf.inputs["Roughness"].default_value  = rough
    mat.diffuse_color = (*lin(color), 1.0)
    return mat

# ---------- escena ----------
def limpiar():
    for o in list(bpy.data.objects): bpy.data.objects.remove(o, do_unlink=True)
    for bloque in (bpy.data.meshes, bpy.data.materials):
        for d in list(bloque):
            if d.users == 0 or d.name.startswith(("SM_", "MAT_", "REF_")): bloque.remove(d)
    for c in list(bpy.data.collections):
        if c.name.startswith("COL_"): bpy.data.collections.remove(c)

def coleccion(nombre):
    c = bpy.data.collections.new(nombre); bpy.context.scene.collection.children.link(c); return c

def iniciar_escena(nombre_raiz, tam_empty=0.5, pos_cubo=(2.0, 0, 0)):
    global COL_FAUNA, RAIZ
    if LIMPIAR_ESCENA: limpiar()
    COL_FAUNA = coleccion("COL_Fauna"); col_ref = coleccion("COL_Referencia")
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts: v.co.z += 0.5
    me = bpy.data.meshes.new("REF_Cubo_1m"); bm.to_mesh(me); bm.free()
    ref = bpy.data.objects.new("REF_Cubo_1m", me); ref.display_type = "WIRE"; ref.hide_render = True
    ref.location = pos_cubo; col_ref.objects.link(ref)
    RAIZ = bpy.data.objects.new(nombre_raiz, None)
    RAIZ.empty_display_type = "PLAIN_AXES"; RAIZ.empty_display_size = tam_empty
    COL_FAUNA.objects.link(RAIZ)

def crear_objeto(nombre, bm, materiales, tinte=None, pivote=Vector((0, 0, 0))):
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)      # Merge by Distance
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)           # normales outward
    me = bpy.data.meshes.new(nombre); bm.to_mesh(me); bm.free()
    for m in materiales: me.materials.append(m)
    if SOMBREADO_SUAVE: me.polygons.foreach_set("use_smooth", [True] * len(me.polygons))
    if tinte:
        blancos = set()                                          # slots != 0 no reciben tinte
        for p in me.polygons:
            if p.material_index != 0: blancos.update(p.vertices)
        ca = me.color_attributes.new("Col_Pelaje", "FLOAT_COLOR", "POINT")
        for i, v in enumerate(me.vertices):
            ca.data[i].color = (1, 1, 1, 1) if i in blancos else (*tinte(v.co, i), 1.0)
        me.color_attributes.active_color = ca
        me.color_attributes.render_color_index = 0
    if PIVOTES_ARTICULARES:
        for v in me.vertices: v.co -= pivote
    ob = bpy.data.objects.new(nombre, me)
    ob.location = pivote if PIVOTES_ARTICULARES else Vector((0, 0, 0))
    COL_FAUNA.objects.link(ob); ob.parent = RAIZ
    return ob

def aplicar_variante(n):
    m = MATS[f"MAT_{PREFIJO}_Pelaje_0{n}"]
    for o in OBJS_PELAJE: o.data.materials[0] = m

def exportar_glb(ruta):
    bpy.ops.object.select_all(action="DESELECT")
    RAIZ.select_set(True)
    for o in TODOS: o.select_set(True)
    bpy.context.view_layer.objects.active = RAIZ
    bpy.ops.export_scene.gltf(filepath=ruta, export_format="GLB", use_selection=True,
                              export_yup=True, export_apply=True, export_animations=False)

def estadisticas(titulo):
    bpy.context.view_layer.update()
    total = 0; print(f"\n=== {titulo} — variante ALTA ===")
    for o in TODOS:
        n = sum(len(p.vertices) - 2 for p in o.data.polygons); total += n
        print(f"  {o.name:22s} {n:5d} tris   scale={tuple(round(s, 3) for s in o.scale)}")
    pts = [o.matrix_world @ v.co for o in TODOS for v in o.data.vertices]
    xs, ys, zs = [p.x for p in pts], [p.y for p in pts], [p.z for p in pts]
    print(f"  TOTAL: {total} tris (≤6000) | objetos: {len(TODOS)} (≤8) | materiales: {len(MATS)} (≤6)")
    print(f"  Largo: {max(ys)-min(ys):.2f} m | Alto: {max(zs):.2f} m | Ancho: {max(xs)-min(xs):.2f} m | Z min: {min(zs):.4f}")
    print("  exportar_glb('/ruta/archivo.glb')  |  aplicar_variante(2)")
2) ESPECIE: JIRAFA
Python

# ============================================================
#  SM_Jirafa_Pradera — variante ALTA (pegar debajo del NÚCLEO)
# ============================================================
PREFIJO, RAIZ_NOMBRE = "Jirafa", "SM_Jirafa_Pradera"
VARIANTE_INICIAL = 1
COLA_SEPARADA    = False        # True -> SM_Jirafa_Tail como objeto (9 obj)

SEG_CUERPO, ANILLOS_CUERPO = 32, 20
SEG_CUELLO, ANILLOS_CUELLO = 16, 20     # muchos loops: pastar / mirar al jugador
SEG_CABEZA, ANILLOS_CABEZA = 20, 14
SEG_PATA,   ANILLOS_PATA   = 10, 14
SEG_COLA,   ANILLOS_COLA   = 8,  10
SEG_OJO,    ANILLOS_OJO    = 10, 5

# 'vientre' = crema de fondo | 'principal' = mancha | 'oscuro' = mancha del lomo
PALETA = {1: dict(principal=(168, 112, 64), vientre=(232, 210, 170), oscuro=(126, 78, 44)),   # Sabana
          2: dict(principal=(122,  80, 50), vientre=(220, 196, 158), oscuro=( 84, 52, 32))}   # Acacia
COL_OJOS, COL_DETALLE = (30, 20, 10), (62, 46, 36)
ESCALA_MANCHA  = dict(cuerpo=0.42, cuello=0.30, pata=0.24, cabeza=0.16)   # tamaño de celda (m)
GROSOR_LINEA   = 0.12                                                     # ancho de las líneas crema
TINT_V, TINT_P, TINT_O, tinte_dorsal = hacer_tintes(PALETA[1])

# ---------- perfiles (metros) ----------
CUERPO_Y0, CUERPO_Y1 = -0.95, 0.95
def path_cuerpo(t):  return Vector((0.0, CUERPO_Y0 + (CUERPO_Y1 - CUERPO_Y0) * t, 2.28 + 0.30 * t))  # grupa baja, cruz alta
def radios_cuerpo(t):
    u = 2 * t - 1; s = (1 - abs(u) ** 3.0) ** (1 / 3.0)
    return 0.46 * s * (1 - 0.05 * t), 0.56 * s * (1 + 0.12 * t)

def path_cola(t):    return Vector((0.0, -0.93 - 0.08 * t, 2.45 - 1.05 * t))
def radios_cola(t):
    r = 0.025 + 0.02 * (1 - t)
    if t > 0.72: r += 0.06 * math.sin(math.pi * (t - 0.72) / 0.28)      # mechón
    return r, r

CUELLO_BASE, CUELLO_TOP = Vector((0.0, 0.70, 2.60)), Vector((0.0, 1.60, 3.96))   # arranca dentro del torso
def path_cuello(t):
    p = CUELLO_BASE.lerp(CUELLO_TOP, t); p.y += 0.08 * math.sin(math.pi * t); return p
def radios_cuello(t):
    rx = 0.24 - 0.14 * t ** 0.9; return rx, rx * 1.25

CABEZA_A, CABEZA_B = Vector((0.0, 1.48, 4.03)), Vector((0.0, 2.22, 3.82))
def path_cabeza(t):  return CABEZA_A.lerp(CABEZA_B, t)
def radios_cabeza(t):
    u = 2 * t - 1
    s = (1 - abs(u) ** 2.8) ** (1 / 2.8) if u < 0 else (1 - u ** 3.4) ** (1 / 3.4)
    k = max(0.0, (t - 0.5) / 0.5)                                        # hocico se estrecha
    return 0.17 * s * (1 - 0.42 * k), 0.21 * s * (1 - 0.35 * k)

def path_osicono(sg):
    c = path_cabeza(0.28); rz = radios_cabeza(0.28)[1]
    base = Vector((sg * 0.055, c.y, c.z + rz - 0.03))
    return lambda t: base + Vector((sg * 0.01 * t, -0.04 * t, 0.20 * t))
def radios_osicono(t):
    r = 0.032 - 0.008 * t; return r, r

PERFIL_PATA_DEL = [(2.45, 0.19), (2.00, 0.165), (1.55, 0.125), (1.22, 0.135), (1.05, 0.11),
                   (0.60, 0.095), (0.22, 0.10), (0.13, 0.115), (0.0, 0.115)]
PERFIL_PATA_TRA = [(2.25, 0.19), (1.85, 0.16), (1.45, 0.13), (1.10, 0.13), (0.95, 0.105),
                   (0.55, 0.095), (0.22, 0.10), (0.13, 0.115), (0.0, 0.115)]

# ---------- tintes (manchas Voronoi en espacio de mundo) ----------
def tinte_manchas(co, escala, dorsal, cobertura=1.0):
    m = smooth((voronoi_borde(co, escala) - GROSOR_LINEA * 0.6) / (GROSOR_LINEA * 1.4)) * cobertura
    return lerp(TINT_V, lerp(TINT_P, TINT_O, smooth(dorsal)), m)

def tinte_cuerpo(co, i):
    if i >= N_CUERPO:                                                    # cola
        return TINT_O if co.z < 1.65 else tinte_manchas(co, 0.2, 0.7)
    t, h = coord_local(co, path_cuerpo, radios_cuerpo)
    return tinte_manchas(co, ESCALA_MANCHA["cuerpo"], (h + 1) / 2, smooth((h + 0.75) / 0.45))   # vientre crema
def tinte_cuello(co, i):
    t, h = coord_local(co, path_cuello, radios_cuello)
    if h > 0.90: return TINT_O                                           # crin
    return tinte_manchas(co, ESCALA_MANCHA["cuello"], 0.4 + 0.4 * (h + 1) / 2, smooth((h + 0.85) / 0.4))
def tinte_cabeza(co, i):
    t, h = coord_local(co, path_cabeza, radios_cabeza)
    if t > 0.62: return TINT_V                                           # hocico crema
    return tinte_manchas(co, ESCALA_MANCHA["cabeza"], 0.5, 0.7 * smooth((h + 0.5) / 0.5))
def tinte_pata(co, i):
    return tinte_manchas(co, ESCALA_MANCHA["pata"], 0.35, smooth((co.z - 0.85) / 0.5))   # cañas claras

# ---------- geometría ----------
def crear_cuerpo(con_cola):
    global N_CUERPO
    bm = bmesh.new()
    curva_tubo(bm, path_cuerpo, radios_cuerpo, ANILLOS_CUERPO, SEG_CUERPO, 0.02, 0.98, True, True, coseno=True)
    N_CUERPO = len(bm.verts)
    if con_cola: add_cola(bm)
    return bm
def add_cola(bm):
    curva_tubo(bm, path_cola, radios_cola, ANILLOS_COLA, SEG_COLA, 0.0, 1.0, False, True, punta=0.5)
def crear_cola():
    global N_CUERPO; N_CUERPO = 0
    bm = bmesh.new(); add_cola(bm); return bm

def crear_cuello():
    bm = bmesh.new()
    curva_tubo(bm, path_cuello, radios_cuello, ANILLOS_CUELLO, SEG_CUELLO, 0.0, 1.0, False, False)   # abierto en ambos extremos
    return bm

def crear_cabeza():
    bm = bmesh.new()
    curva_tubo(bm, path_cabeza, radios_cabeza, ANILLOS_CABEZA, SEG_CABEZA, 0.02, 0.985, True, True, coseno=True, punta=0.35)
    yn = path_cabeza(0.985).y
    for f in bm.faces:                                                   # abanico del hocico -> Detalle
        if len(f.verts) == 3 and min(v.co.y for v in f.verts) > yn - 0.05: f.material_index = 1
    for sg in (-1, 1):
        curva_tubo(bm, path_osicono(sg), radios_osicono, 8, 8, 0.0, 1.0, False, False)
        add_elipsoide(bm, Vector((0.042, 0.042, 0.036)), 8, 4, tf_desplazar(path_osicono(sg)(1.0) + Vector((0, 0, 0.012))), 1)
        c = path_cabeza(0.22); rx, rz = radios_cabeza(0.22)             # orejas: hojas apuntando fuera/arriba/atrás
        R = Matrix.Rotation(math.radians(sg * -35), 4, 'Y') @ Matrix.Rotation(math.radians(sg * -20), 4, 'Z')
        add_elipsoide(bm, Vector((0.11, 0.03, 0.055)), 10, 5, tf_rot(Vector((sg * rx * 0.85, c.y, c.z + rz * 0.45)), R))
    return bm

def crear_ojos():
    bm = bmesh.new()
    t = 0.50; c = path_cabeza(t); rx, rz = radios_cabeza(t); ph = math.radians(22)
    for sg in (-1, 1):
        ce = Vector((sg * rx * math.cos(ph) * 0.92, c.y, c.z + rz * math.sin(ph) * 0.92))
        add_elipsoide(bm, Vector((0.036, 0.036, 0.036)), SEG_OJO, ANILLOS_OJO, tf_desplazar(ce))
    return bm

def crear_pata(x, y, trasera):
    bm = bmesh.new(); sg = 1 if x > 0 else -1
    keys = PERFIL_PATA_TRA if trasera else PERFIL_PATA_DEL
    ztop = keys[0][0]
    zs = [round(ztop * (1 - i / (ANILLOS_PATA - 1)), 4) for i in range(ANILLOS_PATA)] + [0.13]
    rings = []
    for z in sorted(set(zs), reverse=True):
        r  = perfil_interp(keys, z)
        dx = -sg * 0.04 * smooth((z - 1.8) / 0.6)                        # muslo hacia dentro del torso
        zk = 1.05 if trasera else 1.15
        dy = (-0.03 if trasera else 0.03) * math.exp(-((z - zk) / 0.15) ** 2)   # rodilla / corvejón
        rings.append(ring_Z(x + dx, y + dy, z, r, r * 1.1, SEG_PATA))
    build_tube(bm, rings, None, Vector((x, y + 0.01, 0.0)))              # planta en Z=0
    for f in bm.faces:                                                   # pezuña
        if max(v.co.z for v in f.verts) <= 0.13 + 1e-4: f.material_index = 1
    return bm

# ---------- escena ----------
iniciar_escena(RAIZ_NOMBRE, 0.6, (2.4, 0, 0))
MATS = {f"MAT_{PREFIJO}_Pelaje_01": mat_pelaje(f"MAT_{PREFIJO}_Pelaje_01", PALETA[1], 0.75),
        f"MAT_{PREFIJO}_Pelaje_02": mat_pelaje(f"MAT_{PREFIJO}_Pelaje_02", PALETA[2], 0.75),
        f"MAT_{PREFIJO}_Ojos":      mat_ojos(f"MAT_{PREFIJO}_Ojos", COL_OJOS),
        f"MAT_{PREFIJO}_Detalle":   mat_plano(f"MAT_{PREFIJO}_Detalle", COL_DETALLE, 0.5)}
PEL = MATS[f"MAT_{PREFIJO}_Pelaje_0{VARIANTE_INICIAL}"]; DET = MATS[f"MAT_{PREFIJO}_Detalle"]

OBJS_PELAJE = [crear_objeto("SM_Jirafa_Body", crear_cuerpo(not COLA_SEPARADA), [PEL], tinte_cuerpo)]
if COLA_SEPARADA:
    OBJS_PELAJE.append(crear_objeto("SM_Jirafa_Tail", crear_cola(), [PEL], tinte_cuerpo, Vector((0, -0.93, 2.45))))
OBJS_PELAJE += [crear_objeto("SM_Jirafa_Neck", crear_cuello(), [PEL],      tinte_cuello, CUELLO_BASE),
                crear_objeto("SM_Jirafa_Head", crear_cabeza(), [PEL, DET], tinte_cabeza, CUELLO_TOP)]
for nombre, x, y, tras in (("SM_Jirafa_Leg_FL", -0.22,  0.65, False), ("SM_Jirafa_Leg_FR", 0.22,  0.65, False),
                           ("SM_Jirafa_Leg_BL", -0.23, -0.65, True),  ("SM_Jirafa_Leg_BR", 0.23, -0.65, True)):
    OBJS_PELAJE.append(crear_objeto(nombre, crear_pata(x, y, tras), [PEL, DET], tinte_pata,
                                    Vector((x, y, (PERFIL_PATA_TRA if tras else PERFIL_PATA_DEL)[0][0]))))
TODOS = OBJS_PELAJE + [crear_objeto("SM_Jirafa_Eyes", crear_ojos(), [MATS[f"MAT_{PREFIJO}_Ojos"]], None, CUELLO_TOP)]
estadisticas(RAIZ_NOMBRE)
3) ESPECIE: OSO
Python

# ============================================================
#  SM_Oso_Bosque — variante ALTA (pegar debajo del NÚCLEO)
# ============================================================
PREFIJO, RAIZ_NOMBRE = "Oso", "SM_Oso_Bosque"
VARIANTE_INICIAL = 1

SEG_CUERPO, ANILLOS_CUERPO = 32, 18
SEG_CABEZA, ANILLOS_CABEZA = 26, 14
SEG_PATA                   = 10
SEG_OREJA,  ANILLOS_OREJA  = 10, 6
SEG_OJO,    ANILLOS_OJO    = 10, 5

PALETA = {1: dict(principal=(128, 90, 58), vientre=(160, 124, 90), oscuro=(92, 62, 40)),   # Pardo Miel
          2: dict(principal=( 84, 62, 46), vientre=(118,  94, 74), oscuro=(54, 38, 28))}   # Pardo Oscuro
COL_OJOS, COL_NARIZ = (30, 20, 10), (35, 26, 20)
TINT_V, TINT_P, TINT_O, tinte_dorsal = hacer_tintes(PALETA[1])

# ---------- perfiles (metros) ----------
CUERPO_Y0, CUERPO_Y1 = -0.68, 0.62
def joroba(t):        return math.exp(-((t - 0.74) / 0.16) ** 2)
def path_cuerpo(t):   return Vector((0.0, CUERPO_Y0 + (CUERPO_Y1 - CUERPO_Y0) * t, 0.58 + 0.04 * t + 0.07 * joroba(t)))
def radios_cuerpo(t):
    u = 2 * t - 1; s = (1 - abs(u) ** 2.8) ** (1 / 2.8)                  # barril rechoncho
    return 0.40 * s * (1 + 0.05 * (1 - t)), 0.40 * s * (1 + 0.10 * joroba(t))

CABEZA_A, CABEZA_B = Vector((0.0, 0.68, 0.86)), Vector((0.0, 1.22, 0.76))
def path_cabeza(t):   return CABEZA_A.lerp(CABEZA_B, t) + Vector((0, 0, 0.03 * math.sin(math.pi * t)))
def radios_cabeza(t):
    u = 2 * t - 1
    s = (1 - abs(u) ** 2.6) ** (1 / 2.6) if u < 0 else (1 - u ** 3.0) ** (1 / 3.0)
    k = max(0.0, (t - 0.56) / 0.44) ** 0.9                               # hocico corto
    return 0.23 * s * (1 - 0.50 * k), 0.21 * s * (1 - 0.42 * k)

# ---------- tintes ----------
def tinte_cuerpo(co, i):
    if i >= N_CUERPO: return tinte_dorsal(0.7)                           # muñón de cola
    t, h = coord_local(co, path_cuerpo, radios_cuerpo); return tinte_dorsal((h + 1) / 2)
def tinte_cabeza(co, i):
    t, h = coord_local(co, path_cabeza, radios_cabeza)
    w = 0.12 + 0.88 * (h + 1) / 2
    if t > 0.60: w *= 1 - 0.6 * smooth((t - 0.60) / 0.25)                # hocico más claro
    return tinte_dorsal(w)
def tinte_oreja(co, i): return tinte_dorsal(0.72)
def tinte_pata(co, i):  return tinte_dorsal(0.55 + 0.25 * clamp(co.z / 0.6, 0, 1))

# ---------- geometría ----------
def crear_cuerpo():
    global N_CUERPO
    bm = bmesh.new()
    curva_tubo(bm, path_cuerpo, radios_cuerpo, ANILLOS_CUERPO, SEG_CUERPO, 0.02, 0.98, True, True, coseno=True)
    N_CUERPO = len(bm.verts)
    add_elipsoide(bm, Vector((0.05, 0.06, 0.045)), 10, 5, tf_desplazar(Vector((0, CUERPO_Y0 - 0.02, 0.60))))   # cola
    return bm

def crear_cabeza():
    bm = bmesh.new()
    curva_tubo(bm, path_cabeza, radios_cabeza, ANILLOS_CABEZA, SEG_CABEZA, 0.02, 0.985, True, True, coseno=True, punta=0.25)
    yn = path_cabeza(0.985).y
    for f in bm.faces:                                                   # trufa -> Nariz
        if len(f.verts) == 3 and min(v.co.y for v in f.verts) > yn - 0.05: f.material_index = 1
    return bm

def crear_orejas():
    bm = bmesh.new()
    t = 0.26; c = path_cabeza(t); rx, rz = radios_cabeza(t); ph = math.radians(52)
    for sg in (-1, 1):
        P = Vector((sg * rx * math.cos(ph) * 0.92, c.y, c.z + rz * math.sin(ph) * 0.92))
        R = Matrix.Rotation(math.radians(sg * -25), 4, 'Y')
        add_elipsoide(bm, Vector((0.075, 0.032, 0.078)), SEG_OREJA, ANILLOS_OREJA, tf_rot(P, R))   # discos redondos
    return bm

def crear_ojos():
    bm = bmesh.new()
    t = 0.62; c = path_cabeza(t); rx, rz = radios_cabeza(t); ph = math.radians(22)
    for sg in (-1, 1):
        ce = Vector((sg * rx * math.cos(ph) * 0.92, c.y, c.z + rz * math.sin(ph) * 0.92))
        add_elipsoide(bm, Vector((0.030, 0.030, 0.030)), SEG_OJO, ANILLOS_OJO, tf_desplazar(ce))   # ojos pequeños
    return bm

def crear_pata(x, y, trasera):
    bm = bmesh.new(); sg = 1 if x > 0 else -1; k = 1.12 if trasera else 1.0
    #        z     r         dx      dy   (zarpa se adelanta; plantígrado)
    spec = [(0.62, 0.140,   -0.06,  0.0), (0.46, 0.135, -0.03, 0.0), (0.30, 0.122, 0.0, 0.0),
            (0.17, 0.125,    0.0,   0.01), (0.08, 0.150 * k, 0.0, 0.05 * k), (0.0, 0.140 * k, 0.0, 0.05 * k)]
    rings = [ring_Z(x + sg * dx, y + dy, z, r, r * 1.15, SEG_PATA) for z, r, dx, dy in spec]
    build_tube(bm, rings, None, Vector((x, y + 0.05 * k, 0.0)))          # planta en Z=0
    for f in bm.faces:
        zs = [v.co.z for v in f.verts]
        if max(zs) <= 1e-4: f.material_index = 1                         # almohadilla
        elif len(f.verts) == 4 and max(zs) <= 0.08 + 1e-4 and sum(v.co.y for v in f.verts) / 4 > y + 0.05 * k + 0.08:
            f.material_index = 1                                         # garras (banda frontal)
    return bm

# ---------- escena ----------
iniciar_escena(RAIZ_NOMBRE, 0.4, (1.4, 0, 0))
MATS = {f"MAT_{PREFIJO}_Pelaje_01": mat_pelaje(f"MAT_{PREFIJO}_Pelaje_01", PALETA[1], 0.82),
        f"MAT_{PREFIJO}_Pelaje_02": mat_pelaje(f"MAT_{PREFIJO}_Pelaje_02", PALETA[2], 0.82),
        f"MAT_{PREFIJO}_Ojos":      mat_ojos(f"MAT_{PREFIJO}_Ojos", COL_OJOS),
        f"MAT_{PREFIJO}_Nariz":     mat_plano(f"MAT_{PREFIJO}_Nariz", COL_NARIZ, 0.4)}
PEL = MATS[f"MAT_{PREFIJO}_Pelaje_0{VARIANTE_INICIAL}"]; NAR = MATS[f"MAT_{PREFIJO}_Nariz"]
PIV_CABEZA = Vector((0.0, 0.62, 0.84))

OBJS_PELAJE = [crear_objeto("SM_Oso_Body", crear_cuerpo(),  [PEL],      tinte_cuerpo),
               crear_objeto("SM_Oso_Head", crear_cabeza(),  [PEL, NAR], tinte_cabeza, PIV_CABEZA),
               crear_objeto("SM_Oso_Ears", crear_orejas(),  [PEL],      tinte_oreja,  PIV_CABEZA)]
for nombre, x, y, tras in (("SM_Oso_Leg_FL", -0.24,  0.40, False), ("SM_Oso_Leg_FR", 0.24,  0.40, False),
                           ("SM_Oso_Leg_BL", -0.25, -0.42, True),  ("SM_Oso_Leg_BR", 0.25, -0.42, True)):
    OBJS_PELAJE.append(crear_objeto(nombre, crear_pata(x, y, tras), [PEL, NAR], tinte_pata, Vector((x, y, 0.62))))
TODOS = OBJS_PELAJE + [crear_objeto("SM_Oso_Eyes", crear_ojos(), [MATS[f"MAT_{PREFIJO}_Ojos"]], None, PIV_CABEZA)]
estadisticas(RAIZ_NOMBRE)
Qué produce
Jirafa	Oso
Tris totales	≈ 4.600 (Body ~1.400, Neck ~600, Head ~1.100 con osiconos/orejas, Legs ~300 c/u, Eyes ~200)	≈ 2.800 (Body ~1.200, Head ~730, Ears ~200, Legs ~110 c/u, Eyes ~200)
Objetos / Materiales	8 / 4	8 / 4
Dimensiones	3,2 m largo · 4,4 m alto (pompones) · 0,6 m ancho	1,9 m largo · 1,15 m a la joroba · 0,8 m ancho
Piel/pelaje	Crema de fondo + manchas Voronoi caramelo que se oscurecen en el lomo; vientre y cañas crema; crin oscura; hocico crema; pezuñas/hocico/pompones en MAT_Jirafa_Detalle	Degradado lomo→vientre; hocico más claro; trufa, almohadillas y garras en MAT_Oso_Nariz
Edge loops de animación	Cuello 20, cola 10 (mechón)	Patas 6 (zarpas adelantadas), orejas separadas
Ambas cumplen el mismo checklist que la nutria y el elefante (remove_doubles, normales recalculadas, escala 1, plantas en Z = 0, extremos abiertos donde una parte entra en otra, sin Symmetrize, sin subsurf). El oso va muy holgado de presupuesto: si quieres más suavidad, sube SEG_CUERPO a 36 y añade loops a las patas.

Godot 4
exportar_glb(...) en ambos casos → Node3D raíz + 8 MeshInstance3D, mirando a −Z. Head y Leg_* llegan con 2 surfaces (pelaje + detalle/nariz). El vertex color viaja como COLOR_0 — activa Vertex Color → Use as Albedo si el importador no lo hace solo (imprescindible en la jirafa: sin eso se ve crema lisa). Variante 2: material_override del surface 0 o segundo GLB tras aplicar_variante(2). Colisiones sugeridas: jirafa cápsula r 0,45 m alto 4,2 m en (0, 2.1, 0) + una BoxShape para el torso si el jugador puede pasar por debajo; oso cápsula r 0,45 m alto 1,9 m tumbada.

Ajustes finos
Jirafa

Tamaño/densidad de manchas → ESCALA_MANCHA; líneas más finas/gruesas → GROSOR_LINEA (mínimo útil ~0.08 con esta densidad de vértices). Otra distribución → semilla en voronoi_borde.
Cuello más grueso (más cozy) → 0.24 y 0.14 en radios_cuello; más curvo → 0.08 * sin en path_cuello.
Osiconos más largos/pompón mayor → 0.20 * t en path_osicono y radio 0.042 de la elipsoide.
Postura "pastando": cambia CUELLO_TOP a (0, 2.1, 1.6) (el cuello y la cabeza siguen la curva automáticamente); útil para generar una segunda pose estática.
Oso

Más rechoncho → exponente 2.8 → 3.2 y 0.40 → 0.44 en radios_cuerpo; joroba más marcada → 0.07 en path_cuerpo.
Hocico más corto (más cachorro) → 0.56 → 0.62 en radios_cabeza; orejas más grandes → radios (0.075, 0.032, 0.078).
Variante negra (Ursus americanus) → añade PALETA[3] con (48,40,36)/(80,70,62)/(30,24,22) y crea MAT_Oso_Pelaje_03.
Pose sentada: no muevas la malla; queda para el rig.
MEDIA / BAJA (misma receta que antes): Decimate Collapse ~0.35 / ~0.17, luego Join. Jirafa MEDIA: Body+Legs, Neck, Head+Eyes (3 obj); pinta pezuñas con vertex color y quita Detalle (3 mats). Oso MEDIA: Body+Legs, Head+Ears+Eyes (2 obj). En BAJA fusiona todo salvo cuello (jirafa) o cabeza (oso), que son lo que se anima.





