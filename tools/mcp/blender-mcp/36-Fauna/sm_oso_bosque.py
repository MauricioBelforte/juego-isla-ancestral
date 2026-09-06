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
#  SM_Oso_Bosque — variante ALTA
# ============================================================
PREFIJO, RAIZ_NOMBRE = "Oso", "SM_Oso_Bosque"
VARIANTE_INICIAL = 1

SEG_CUERPO, ANILLOS_CUERPO = 32, 18
SEG_CABEZA, ANILLOS_CABEZA = 26, 14
SEG_PATA                   = 10
SEG_OREJA,  ANILLOS_OREJA  = 10, 6
SEG_OJO,    ANILLOS_OJO    = 10, 5

PALETA = {1: dict(principal=(128, 90, 58), vientre=(160, 124, 90), oscuro=(92, 62, 40)),
          2: dict(principal=( 84, 62, 46), vientre=(118,  94, 74), oscuro=(54, 38, 28))}
COL_OJOS, COL_NARIZ = (30, 20, 10), (35, 26, 20)
TINT_V, TINT_P, TINT_O, tinte_dorsal = hacer_tintes(PALETA[1])

CUERPO_Y0, CUERPO_Y1 = -0.68, 0.62
def joroba(t):        return math.exp(-((t - 0.74) / 0.16) ** 2)
def path_cuerpo(t):   return Vector((0.0, CUERPO_Y0 + (CUERPO_Y1 - CUERPO_Y0) * t, 0.58 + 0.04 * t + 0.07 * joroba(t)))
def radios_cuerpo(t):
    u = 2 * t - 1; s = (1 - abs(u) ** 2.8) ** (1 / 2.8)
    return 0.40 * s * (1 + 0.05 * (1 - t)), 0.40 * s * (1 + 0.10 * joroba(t))

CABEZA_A, CABEZA_B = Vector((0.0, 0.68, 0.86)), Vector((0.0, 1.22, 0.76))
def path_cabeza(t):   return CABEZA_A.lerp(CABEZA_B, t) + Vector((0, 0, 0.03 * math.sin(math.pi * t)))
def radios_cabeza(t):
    u = 2 * t - 1
    s = (1 - abs(u) ** 2.6) ** (1 / 2.6) if u < 0 else (1 - u ** 3.0) ** (1 / 3.0)
    k = max(0.0, (t - 0.56) / 0.44) ** 0.9
    return 0.23 * s * (1 - 0.50 * k), 0.21 * s * (1 - 0.42 * k)

def tinte_cuerpo(co, i):
    if i >= N_CUERPO: return tinte_dorsal(0.7)
    t, h = coord_local(co, path_cuerpo, radios_cuerpo); return tinte_dorsal((h + 1) / 2)
def tinte_cabeza(co, i):
    t, h = coord_local(co, path_cabeza, radios_cabeza)
    w = 0.12 + 0.88 * (h + 1) / 2
    if t > 0.60: w *= 1 - 0.6 * smooth((t - 0.60) / 0.25)
    return tinte_dorsal(w)
def tinte_oreja(co, i): return tinte_dorsal(0.72)
def tinte_pata(co, i):  return tinte_dorsal(0.55 + 0.25 * clamp(co.z / 0.6, 0, 1))

def crear_cuerpo():
    global N_CUERPO
    bm = bmesh.new()
    curva_tubo(bm, path_cuerpo, radios_cuerpo, ANILLOS_CUERPO, SEG_CUERPO, 0.02, 0.98, True, True, coseno=True)
    N_CUERPO = len(bm.verts)
    add_elipsoide(bm, Vector((0.05, 0.06, 0.045)), 10, 5, tf_desplazar(Vector((0, CUERPO_Y0 - 0.02, 0.60))))
    return bm

def crear_cabeza():
    bm = bmesh.new()
    curva_tubo(bm, path_cabeza, radios_cabeza, ANILLOS_CABEZA, SEG_CABEZA, 0.02, 0.985, True, True, coseno=True, punta=0.25)
    yn = path_cabeza(0.985).y
    for f in bm.faces:
        if len(f.verts) == 3 and min(v.co.y for v in f.verts) > yn - 0.05: f.material_index = 1
    return bm

def crear_orejas():
    bm = bmesh.new()
    t = 0.26; c = path_cabeza(t); rx, rz = radios_cabeza(t); ph = math.radians(52)
    for sg in (-1, 1):
        P = Vector((sg * rx * math.cos(ph) * 0.92, c.y, c.z + rz * math.sin(ph) * 0.92))
        R = Matrix.Rotation(math.radians(sg * -25), 4, 'Y')
        add_elipsoide(bm, Vector((0.075, 0.032, 0.078)), SEG_OREJA, ANILLOS_OREJA, tf_rot(P, R))
    return bm

def crear_ojos():
    bm = bmesh.new()
    t = 0.62; c = path_cabeza(t); rx, rz = radios_cabeza(t); ph = math.radians(22)
    for sg in (-1, 1):
        ce = Vector((sg * rx * math.cos(ph) * 0.92, c.y, c.z + rz * math.sin(ph) * 0.92))
        add_elipsoide(bm, Vector((0.030, 0.030, 0.030)), SEG_OJO, ANILLOS_OJO, tf_desplazar(ce))
    return bm

def crear_pata(x, y, trasera):
    bm = bmesh.new(); sg = 1 if x > 0 else -1; k = 1.12 if trasera else 1.0
    spec = [(0.62, 0.140,   -0.06,  0.0), (0.46, 0.135, -0.03, 0.0), (0.30, 0.122, 0.0, 0.0),
            (0.17, 0.125,    0.0,   0.01), (0.08, 0.150 * k, 0.0, 0.05 * k), (0.0, 0.140 * k, 0.0, 0.05 * k)]
    rings = [ring_Z(x + sg * dx, y + dy, z, r, r * 1.15, SEG_PATA) for z, r, dx, dy in spec]
    build_tube(bm, rings, None, Vector((x, y + 0.05 * k, 0.0)))
    for f in bm.faces:
        zs = [v.co.z for v in f.verts]
        if max(zs) <= 1e-4: f.material_index = 1
        elif len(f.verts) == 4 and max(zs) <= 0.08 + 1e-4 and sum(v.co.y for v in f.verts) / 4 > y + 0.05 * k + 0.08:
            f.material_index = 1
    return bm

# ---------- ESCENA ----------
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
