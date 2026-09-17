# mobiliario_util.py — Helpers compartidos del MOBILIARIO INTERIOR de M18.
#
# MOTIVO (2026-09-10, log 810): la auditoria del log 809 descubrio que los 14
# muebles de la seccion "Mobiliario interior" estaban marcados [x] en el
# checklist SIN existir. Encararlos copiando y pegando el bloque de helpers en
# cada generador es exactamente el error que `plantilla_asset.py` vino a evitar
# (multiplicar la superficie de bug). Este modulo es la version M18 de eso:
# mismo set de helpers, misma firma que `crear_casa_mediana_lowpoly.py`.
#
# FIRMA DE caja(): `caja(nombre, mat, sx, sy, sz, cx, cy, cz)` — dimensiones
# PRIMERO, centro DESPUES, igual que en los generadores de casas. Ojo con E-100:
# `cz` es el CENTRO, asi que el apoyo queda en `cz - sz/2` y el tope en
# `cz + sz/2`. Para apoyar una pata en Z_APOYO con altura h: cz = Z_APOYO + h/2.
#
# ORDEN CANONICO del generador:
#   1 limpiar()  2 materiales  3 geometria  4 arena()  5 iluminar()
#   6 asentar()  7 camara()  8 sombrear_plano()  9 guardar()
import bpy
import os
from mathutils import Vector, Euler

def raiz_repo():
    """E-101 (log 809): NO contar '..' a mano. Este archivo vive 5 niveles por
    debajo de la raiz y la primer version subio 4 -> intento guardar en
    <repo>/tools/tools/mcp/... . Se busca un marcador en su lugar."""
    d = os.path.dirname(os.path.abspath(__file__))
    for _ in range(8):
        if os.path.isfile(os.path.join(d, 'AGENTS.md')):
            return d
        p = os.path.dirname(d)
        if p == d:
            break
        d = p
    raise SystemExit('No encontre AGENTS.md subiendo desde %s' % __file__)


RAIZ = raiz_repo()
MODULO = '18-Casas'
Z_APOYO = 0.045          # E-12: 5 mm bajo el tope de arena (z=0.05)
ALTURA_ARENA = 0.05


# ---------- 1) Limpieza idempotente (E-05) ----------
def limpiar():
    for _o in list(bpy.data.objects):
        bpy.data.objects.remove(_o, do_unlink=True)
    for _b in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
               bpy.data.cameras, bpy.data.worlds):
        for _d in list(_b):
            if _d.users == 0:
                _b.remove(_d)
    return bpy.context.scene


# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.88, alpha=1.0, emis=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    if alpha < 1.0:
        b.inputs['Alpha'].default_value = alpha
        m.blend_method = 'BLEND'
        m.use_backface_culling = False
    if emis > 0.0:
        b.inputs['Emission Color'].default_value = (*color, 1.0)
        b.inputs['Emission Strength'].default_value = emis
    return m


def paleta():
    """Paleta comun de muebles. Devuelve un dict (no crea nada dos veces)."""
    return {
        'madera_clara':  crear_mat('MAT_Mueble_Madera_Clara',  (0.62, 0.47, 0.30)),
        'madera_oscura': crear_mat('MAT_Mueble_Madera_Oscura', (0.40, 0.28, 0.16)),
        'tela_crema':    crear_mat('MAT_Mueble_Tela_Crema',    (0.92, 0.88, 0.76)),
        'tela_roja':     crear_mat('MAT_Mueble_Tela_Roja',     (0.72, 0.28, 0.22)),
        'lino':          crear_mat('MAT_Mueble_Lino',          (0.95, 0.94, 0.88)),
        'bronce':        crear_mat('MAT_Mueble_Bronce',        (0.72, 0.55, 0.35), rough=0.4),
        'cera':          crear_mat('MAT_Mueble_Cera',          (0.90, 0.86, 0.72)),
        'llama':         crear_mat('MAT_Mueble_Llama',         (1.0, 0.72, 0.30), emis=2.5),
        'paja':          crear_mat('MAT_Mueble_Paja',          (0.80, 0.68, 0.44)),
        'barro':         crear_mat('MAT_Mueble_Barro',         (0.66, 0.42, 0.30)),
        # Ampliada en el log 811 (2do lote de muebles): piedra para la nevera
        # de conserva, hierro para la estufa, vidrio para la tulipa de la
        # lampara, verde/tierra para la maceta. Agregar claves aca es seguro:
        # paleta() construye el dict en cada llamada y los generadores ya
        # existentes solo piden las claves que ya usaban.
        'piedra':        crear_mat('MAT_Mueble_Piedra',        (0.55, 0.53, 0.48), rough=0.95),
        'hierro':        crear_mat('MAT_Mueble_Hierro',        (0.34, 0.35, 0.38), rough=0.50),
        'hielo':         crear_mat('MAT_Mueble_Hielo',         (0.86, 0.93, 0.98), rough=0.25),
        'verde_hoja':    crear_mat('MAT_Mueble_VerdeHoja',     (0.35, 0.55, 0.28)),
        'tierra':        crear_mat('MAT_Mueble_Tierra',        (0.35, 0.26, 0.18)),
        'vidrio':        crear_mat('MAT_Mueble_Vidrio',        (0.85, 0.92, 0.95),
                                   rough=0.15, alpha=0.40),
    }


# ---------- 3) Set de captura (sin prefijo SM_ -> no viaja al GLB, E-44) ----------
def arena(radio=1.6):
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=radio, depth=0.22,
                                        location=(0.0, 0.0, ALTURA_ARENA - 0.11))
    o = bpy.context.object
    o.name = 'Base_Arena'
    o.data.materials.append(crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.0))
    return o


def iluminar(escena, energia=3.0):
    sol_data = bpy.data.lights.new('SOL', type='SUN')
    sol_data.energy = energia
    sol = bpy.data.objects.new('SOL', sol_data)
    escena.collection.objects.link(sol)
    sol.rotation_euler = Euler((0.9076, 0.1047, 0.5585), 'XYZ')
    mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
    escena.world = mundo
    mundo.use_nodes = True
    bg = mundo.node_tree.nodes.get('Background')
    bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
    bg.inputs[1].default_value = 0.55
    return sol


# ---------- 4) Geometria ----------
def caja(nombre, mat, sx, sy, sz, cx, cy, cz, rot=(0, 0, 0)):
    """Caja de dimensiones sx x sy x sz CENTRADA en (cx, cy, cz). Ver E-100."""
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(cx, cy, cz), rotation=rot)
    o = bpy.context.object
    o.name = nombre
    o.scale = (sx, sy, sz)
    o.data.materials.append(mat)
    return o


def pata(nombre, mat, side, h, cx, cy):
    """Pata/prisma vertical apoyado en Z_APOYO: base 0.045, tope 0.045+h."""
    return caja(nombre, mat, side, side, h, cx, cy, Z_APOYO + h / 2.0)


def cilindro(nombre, mat, r, h, cx, cy, cz, verts=12):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=h,
                                        location=(cx, cy, cz))
    o = bpy.context.object
    o.name = nombre
    o.data.materials.append(mat)
    return o


def cono(nombre, mat, r_inf, r_sup, h, cx, cy, cz, verts=12):
    """Cono/tronco de cono CERRADO (primitive_cone_add cierra la base).

    `cz` es el CENTRO: la base queda en cz - h/2 y la punta en cz + h/2 (E-100).
    Sirve para macetas (r_inf < r_sup) y tulipas (r_inf > r_sup).
    """
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r_inf, radius2=r_sup,
                                    depth=h, location=(cx, cy, cz))
    o = bpy.context.object
    o.name = nombre
    o.data.materials.append(mat)
    return o


def toro(nombre, mat, r_mayor, r_menor, cx, cy, cz, seg=16, lados=8):
    """Toroide en el plano XY (horizontal), como en E-85 / crear_frasco_agua."""
    bpy.ops.mesh.primitive_torus_add(major_radius=r_mayor, minor_radius=r_menor,
                                     major_segments=seg, minor_segments=lados,
                                     location=(cx, cy, cz))
    o = bpy.context.object
    o.name = nombre
    o.data.materials.append(mat)
    return o


def join(nombre_base, objs):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    r = bpy.context.object
    r.name = nombre_base
    return r


# ---------- 5) Asentado + guard de huella (E-12 / E-24 / E-50) ----------
def z_min_real(objs):
    """E-24: vertices REALES, no bound_box."""
    bpy.context.view_layer.update()
    return min((o.matrix_world @ v.co).z
               for o in objs for v in o.data.vertices)


def piezas(escena):
    return [o for o in escena.objects
            if o.type == 'MESH' and o.name.startswith('SM_')]


def asentar(escena, z_apoyo=Z_APOYO, min_toca=8, min_fp=0.30, tol=0.005):
    bpy.context.view_layer.update()
    ps = piezas(escena)
    assert ps, 'no hay piezas SM_ en la escena'
    z_ini = z_min_real(ps)
    delta = z_apoyo - z_ini
    for o in ps:
        if o.parent is None:
            o.location.z += delta
    bpy.context.view_layer.update()
    z_fin = z_min_real(ps)
    pts = [(o.matrix_world @ v.co) for o in ps for v in o.data.vertices]
    pts = [p for p in pts if abs(p.z - z_apoyo) < tol]
    xs = [p.x for p in pts]
    ys = [p.y for p in pts]
    fp_x = max(xs) - min(xs) if xs else 0.0
    fp_y = max(ys) - min(ys) if ys else 0.0
    print('ASENTADO: z %.4f -> %.4f (delta %+.4f) | toca=%d | fp=%.2f x %.2f'
          % (z_ini, z_fin, delta, len(pts), fp_x, fp_y))
    assert abs(z_fin - z_apoyo) < 1e-4, 'z_min %.4f != %.4f' % (z_fin, z_apoyo)
    assert len(pts) >= min_toca, 'apoyo puntual: %d verts (E-50)' % len(pts)
    assert min(fp_x, fp_y) > min_fp, 'huella chica %.2fx%.2f (E-50)' % (fp_x, fp_y)
    return z_fin, len(pts), fp_x, fp_y


# ---------- 6) Camara / sombreado / guardado ----------
def camara(escena, nombre='Cam', loc=(2.2, -2.6, 1.3), mira=(0, 0, 0.4)):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object
    c.name = nombre
    c.rotation_euler = (Vector(mira) - Vector(loc)).to_track_quat('-Z', 'Y').to_euler()
    escena.camera = c
    return c


def sombrear_plano(objs):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.shade_flat()


def guardar(escena, asset):
    """<RAIZ>/tools/mcp/blender-mcp/18-Casas/<asset>_lowpoly.blend (E-21)."""
    ruta = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', MODULO,
                        asset + '_lowpoly.blend')
    if os.path.exists(ruta + '@'):
        os.remove(ruta + '@')
    bpy.ops.wm.save_as_mainfile(filepath=ruta)
    print('OK — SM_: %d — %s' % (len(piezas(escena)), ruta))
    return ruta
