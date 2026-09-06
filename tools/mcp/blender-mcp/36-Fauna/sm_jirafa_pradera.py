# ============================================================
#  NÚCLEO COMÚN — Fauna procedural cozy (Blender 4.x, bpy)
# ============================================================
import bpy, bmesh, math
from mathutils import Vector, Matrix

LIMPIAR_ESCENA      = True
PIVOTES_ARTICULARES = True
SOMBREADO_SUAVE     = True

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
    V = (1.0, 1.0, 1.0)
    P = tuple(a / b for a, b in zip(lin(pal["principal"]), lin(pal["vientre"])))
    O = tuple(a / b for a, b in zip(lin(pal["oscuro"]),    lin(pal["vientre"])))
    def dorsal(w):
        return lerp(V, P, smooth(w / 0.5)) if w < 0.5 else lerp(P, O, smooth((w - 0.5) / 0.5))
    return V, P, O, dorsal

def ring_Z(cx, cy, cz, rx, ry, n):
    return [Vector((cx + rx * math.cos(a), cy + ry * math.sin(a), cz)) for a in angs(n)]

def frame(tang):
    t  = tang.normalized()
    up = Vector((1, 0, 0)).cross(t)
    if up.length < 1e-6: up = Vector((0, 1, 0))
    up.normalize()
    return t.cross(up).normalized(), up

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
    keys = sorted(keys)
    if z <= keys[0][0]: return keys[0][1]
    for (z0, r0), (z1, r1) in zip(keys[:-1], keys[1:]):
        if z <= z1: return r0 + (r1 - r0) * (z - z0) / (z1 - z0)
    return keys[-1][1]

def coord_local(co, path, radios, muestras=40):
    best = None
    for i in range(muestras + 1):
        t = i / muestras; c = path(t); d = (co - c).length_squared
        if best is None or d < best[0]: best = (d, t, c)
    _, t, c = best
    e = 1e-3
    _, up = frame(path(min(t + e, 1)) - path(max(t - e, 0)))
    return t, clamp((co - c).dot(up) / max(radios(t)[1], 1e-4), -1, 1)

# Voronoi 3D
def _h(i, j, k, s):
    n = (i * 73856093) ^ (j * 19349663) ^ (k * 83492791) ^ (s * 2654435761)
    n = (n * 1103515245 + 12345) & 0x7FFFFFFF
    return n / 0x7FFFFFFF

def voronoi_borde(p, escala, semilla=7):
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

# Materiales
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

# Escena
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
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(nombre); bm.to_mesh(me); bm.free()
    for m in materiales: me.materials.append(m)
    if SOMBREADO_SUAVE: me.polygons.foreach_set("use_smooth", [True] * len(me.polygons))
    if tinte:
        blancos = set()
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
    total = 0; print(f"\n=== {titulo} ===")
    for o in TODOS:
        n = sum(len(p.vertices) - 2 for p in o.data.polygons); total += n
        print(f"  {o.name:22s} {n:5d} tris")
    pts = [o.matrix_world @ v.co for o in TODOS for v in o.data.vertices]
    xs, ys, zs = [p.x for p in pts], [p.y for p in pts], [p.z for p in pts]
    print(f"  TOTAL: {total} tris | objetos: {len(TODOS)} | materiales: {len(MATS)}")
    print(f"  Largo: {max(ys)-min(ys):.2f} m | Alto: {max(zs):.2f} m | Ancho: {max(xs)-min(xs):.2f} m")

# ============================================================
#  SM_Jirafa_Pradera — variante ALTA
# ============================================================
PREFIJO, RAIZ_NOMBRE = "Jirafa", "SM_Jirafa_Pradera"
VARIANTE_INICIAL = 1
COLA_SEPARADA    = False

SEG_CUERPO, ANILLOS_CUERPO = 32, 20
SEG_CUELLO, ANILLOS_CUELLO = 16, 20
SEG_CABEZA, ANILLOS_CABEZA = 20, 14
SEG_PATA,   ANILLOS_PATA   = 10, 14
SEG_COLA,   ANILLOS_COLA   = 8,  10
SEG_OJO,    ANILLOS_OJO    = 10, 5

PALETA = {1: dict(principal=(168, 112, 64), vientre=(232, 210, 170), oscuro=(126, 78, 44)),
          2: dict(principal=(122,  80, 50), vientre=(220, 196, 158), oscuro=( 84, 52, 32))}
COL_OJOS, COL_DETALLE = (30, 20, 10), (62, 46, 36)
ESCALA_MANCHA  = dict(cuerpo=0.42, cuello=0.30, pata=0.24, cabeza=0.16)
GROSOR_LINEA   = 0.12
TINT_V, TINT_P, TINT_O, tinte_dorsal = hacer_tintes(PALETA[1])

CUERPO_Y0, CUERPO_Y1 = -0.95, 0.95
def path_cuerpo(t):  return Vector((0.0, CUERPO_Y0 + (CUERPO_Y1 - CUERPO_Y0) * t, 2.28 + 0.30 * t))
def radios_cuerpo(t):
    u = 2 * t - 1; s = (1 - abs(u) ** 3.0) ** (1 / 3.0)
    return 0.46 * s * (1 - 0.05 * t), 0.56 * s * (1 + 0.12 * t)

def path_cola(t):    return Vector((0.0, -0.93 - 0.08 * t, 2.45 - 1.05 * t))
def radios_cola(t):
    r = 0.025 + 0.02 * (1 - t)
    if t > 0.72: r += 0.06 * math.sin(math.pi * (t - 0.72) / 0.28)
    return r, r

CUELLO_BASE, CUELLO_TOP = Vector((0.0, 0.70, 2.60)), Vector((0.0, 1.60, 3.96))
def path_cuello(t):
    p = CUELLO_BASE.lerp(CUELLO_TOP, t); p.y += 0.08 * math.sin(math.pi * t); return p
def radios_cuello(t):
    rx = 0.24 - 0.14 * t ** 0.9; return rx, rx * 1.25

CABEZA_A, CABEZA_B = Vector((0.0, 1.48, 4.03)), Vector((0.0, 2.22, 3.82))
def path_cabeza(t):  return CABEZA_A.lerp(CABEZA_B, t)
def radios_cabeza(t):
    u = 2 * t - 1
    s = (1 - abs(u) ** 2.8) ** (1 / 2.8) if u < 0 else (1 - u ** 3.4) ** (1 / 3.4)
    k = max(0.0, (t - 0.5) / 0.5)
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

def tinte_manchas(co, escala, dorsal, cobertura=1.0):
    m = smooth((voronoi_borde(co, escala) - GROSOR_LINEA * 0.6) / (GROSOR_LINEA * 1.4)) * cobertura
    return lerp(TINT_V, lerp(TINT_P, TINT_O, smooth(dorsal)), m)

def tinte_cuerpo(co, i):
    if i >= N_CUERPO:
        return TINT_O if co.z < 1.65 else tinte_manchas(co, 0.2, 0.7)
    t, h = coord_local(co, path_cuerpo, radios_cuerpo)
    return tinte_manchas(co, ESCALA_MANCHA["cuerpo"], (h + 1) / 2, smooth((h + 0.75) / 0.45))
def tinte_cuello(co, i):
    t, h = coord_local(co, path_cuello, radios_cuello)
    if h > 0.90: return TINT_O
    return tinte_manchas(co, ESCALA_MANCHA["cuello"], 0.4 + 0.4 * (h + 1) / 2, smooth((h + 0.85) / 0.4))
def tinte_cabeza(co, i):
    t, h = coord_local(co, path_cabeza, radios_cabeza)
    if t > 0.62: return TINT_V
    return tinte_manchas(co, ESCALA_MANCHA["cabeza"], 0.5, 0.7 * smooth((h + 0.5) / 0.5))
def tinte_pata(co, i):
    return tinte_manchas(co, ESCALA_MANCHA["pata"], 0.35, smooth((co.z - 0.85) / 0.5))

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
    curva_tubo(bm, path_cuello, radios_cuello, ANILLOS_CUELLO, SEG_CUELLO, 0.0, 1.0, False, False)
    return bm

def crear_cabeza():
    bm = bmesh.new()
    curva_tubo(bm, path_cabeza, radios_cabeza, ANILLOS_CABEZA, SEG_CABEZA, 0.02, 0.985, True, True, coseno=True, punta=0.35)
    yn = path_cabeza(0.985).y
    for f in bm.faces:
        if len(f.verts) == 3 and min(v.co.y for v in f.verts) > yn - 0.05: f.material_index = 1
    for sg in (-1, 1):
        curva_tubo(bm, path_osicono(sg), radios_osicono, 8, 8, 0.0, 1.0, False, False)
        add_elipsoide(bm, Vector((0.042, 0.042, 0.036)), 8, 4, tf_desplazar(path_osicono(sg)(1.0) + Vector((0, 0, 0.012))), 1)
        c = path_cabeza(0.22); rx, rz = radios_cabeza(0.22)
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
        dx = -sg * 0.04 * smooth((z - 1.8) / 0.6)
        zk = 1.05 if trasera else 1.15
        dy = (-0.03 if trasera else 0.03) * math.exp(-((z - zk) / 0.15) ** 2)
        rings.append(ring_Z(x + dx, y + dy, z, r, r * 1.1, SEG_PATA))
    build_tube(bm, rings, None, Vector((x, y + 0.01, 0.0)))
    for f in bm.faces:
        if max(v.co.z for v in f.verts) <= 0.13 + 1e-4: f.material_index = 1
    return bm

# ---------- ESCENA ----------
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
