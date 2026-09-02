# plantilla_asset.py — Boilerplate comun para los generadores crear_*_lowpoly.py
#
# MOTIVO (2026-09-01, cierre de M45 + M27):
#   Habia 66 generadores autocontenidos, cada uno repitiendo el mismo bloque de
#   ~100 lineas: limpieza idempotente, materiales, disco de arena, sol, mundo,
#   asentado E-12/E-24, guard de huella E-50, camara, shade_flat y guardado E-21.
#   Ese bloque es JUSTAMENTE el que concentra los errores criticos del proyecto
#   (E-24 medir en vertices reales, E-50 apoyo puntual, E-21 borrar el "@").
#   Copiarlo y pegarlo 10 veces mas es multiplicar la superficie de bug.
#
#   Los 66 scripts viejos quedan como estan (no se toca lo que funciona). Los
#   NUEVOS importan este modulo.
#
# USO desde un generador:
#     import sys, os
#     sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
#                                     '..', '..', 'scripts-reutilizables'))
#     from plantilla_asset import (limpiar, mat, arena, iluminar, asentar,
#                                  camara, shade_flat, guardar, RAIZ)
#
# ORDEN CANONICO de todo generador (respetarlo: el asentado va AL FINAL):
#   1 limpiar()  2 mat()s  3 geometria  4 arena()  5 iluminar()
#   6 asentar()  7 camara()  8 shade_flat()  9 guardar()
import bpy
import os
from mathutils import Vector, Euler

# Raiz del repo: este archivo vive en <repo>/tools/mcp/blender-mcp/scripts-reutilizables/
RAIZ = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                    '..', '..', '..', '..'))
Z_APOYO = 0.045   # E-12: 5 mm por debajo del tope de arena (z=0.05)


# ---------- 1) Limpieza idempotente (E-05) ----------
def limpiar():
    for _obj in list(bpy.data.objects):
        bpy.data.objects.remove(_obj, do_unlink=True)
    for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                    bpy.data.cameras, bpy.data.worlds):
        for _dato in list(_bloque):
            if _dato.users == 0:
                _bloque.remove(_dato)
    return bpy.context.scene


# ---------- 2) Materiales ----------
def mat(nombre, color, rough=0.95, spec=0.08, emisivo=None):
    """Principled BSDF. `emisivo` = (color_rgb, strength) para lava/luces (E-59)."""
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    if emisivo:
        b.inputs['Emission Color'].default_value = (*emisivo[0], 1.0)
        b.inputs['Emission Strength'].default_value = emisivo[1]
    return m


# ---------- 2b) Helper de caja centrada (E-68) ----------
def caja(nombre, x, y, z, sx, sy, sz, material, rot_euler=None):
    """Crea una caja centrada en (x,y,z) con dimensiones sx × sy × sz.

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !  ATENCION E-68 (2026-09-02, arco entrada templo M25 v3 → v4):       !
    !  primitive_cube_add(size=1, scale=s) produce un cubo de sx × sy × sz !
    !  (la dimension FINAL del cubo), NO de 2*sx × 2*sy × 2*sz.            !
    !                                                                     !
    !  Por lo tanto sx, sy, sz deben ser las DIMENSIONES FINALES que vos  !
    !  queres para el cubo. Si queres "un cubo de 2.36 m de alto centrado !
    !  en z=1.30", pasa sx=cualquiera, sy=cualquiera, sz=2.36 — NUNCA     !
    !  sz=2.36/2=1.18 (eso da un cubo de 1.18 m, la MITAD).               !
    !                                                                     !
    !  Patron de bug que se repite: cualquier llamada de la forma          !
    !      caja(..., ANCHO/2.0, ALTO/2.0, ...)                            !
    !  esta MAL escrita si la intencion es "el cubo mide ANCHO × ALTO".   !
    !  Equivale a confundir BoxGeometry(width, height, depth) de three.js  !
    !  (donde width es la dimension completa) con la API de Blender (donde !
    !  scale es la dimension completa).                                   !
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    Ejemplo (pilar de arco de 0.45 m de ancho × 2.36 m de alto × 0.45 m de
    prof, centrado en x=0.90, z=1.30):
        caja('SM_Pilar', 0.90, 0, 1.30, 0.45, 0.45, 2.36, MAT_piedra)

    Resultado: cubo de 0.45 × 0.45 × 2.36 m, centrado en (0.90, 0, 1.30).
    Va de z=0.12 a z=2.48. (No "de z=-1.06 a z=3.66" como daria el /2.)
    """
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, y, z))
    o = bpy.context.object
    o.name = nombre
    o.scale = (sx, sy, sz)
    if rot_euler is not None:
        o.rotation_euler = rot_euler
    o.data.materials.append(material)
    return o


# ---------- 3) Disco de arena de referencia (para las capturas) ----------
ALTURA_ARENA = 0.05  # E-12: arena top en z=0.05; los assets (Z_APOYO=0.045) van 5mm hundidos


def arena(radio=2.0, profundo=0.22):
    """Disco NO exportado (no empieza con SM_, E-44). Solo da referencia visual.
    La cara superior queda en z=ALTURA_ARENA (=0.05). Asi el asset con
    z_min=0.045 (Z_APOYO) aparece 5mm hundido en la arena, no flotando.
    Antes (E-67): location.z = -profundo/2 -> top en z=0, los assets flotaban
    4.5cm sobre la arena visual en cualquier vista lateral (cliff, faro, etc.).
    """
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=24, radius=radio, depth=profundo,
        location=(0, 0, ALTURA_ARENA - profundo / 2))
    o = bpy.context.object
    o.name = 'Base_Arena'
    return o


# ---------- 4) Iluminacion ----------
def iluminar(escena, energia=3.0, cielo=(0.58, 0.79, 0.95), fuerza=0.55):
    sol_data = bpy.data.lights.new('SOL', type='SUN')
    sol_data.energy = energia
    sol = bpy.data.objects.new('SOL', sol_data)
    escena.collection.objects.link(sol)
    sol.rotation_euler = Euler((0.9076, 0.1047, 0.5585), 'XYZ')  # 52/6/32 grados
    mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
    escena.world = mundo
    mundo.use_nodes = True
    bg = mundo.node_tree.nodes.get('Background')
    bg.inputs[0].default_value = (*cielo, 1.0)
    bg.inputs[1].default_value = fuerza
    return sol


# ---------- 5) Asentado + guard de huella ----------
def zmin_real(o):
    """E-24: medir en VERTICES REALES, nunca bound_box (falso HUNDIDO/FLOTA)."""
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)


def piezas(escena):
    return [o for o in escena.objects
            if o.type == 'MESH' and o.name.startswith('SM_')]


def asentar(escena, z_apoyo=Z_APOYO, min_toca=8, min_fp=0.30, tol=0.005):
    """Asienta el grupo sobre la arena (E-12) y valida la huella (E-50).

    Devuelve (z_fin, n_toca, fp_x, fp_y). Lanza AssertionError si el apoyo es
    puntual — que es exactamente lo que hay que atrapar en autoría, no en QA.
    """
    bpy.context.view_layer.update()
    ps = piezas(escena)
    assert ps, 'no hay ninguna pieza SM_ en la escena'
    z_ini = min(zmin_real(o) for o in ps)
    delta = z_apoyo - z_ini
    for o in ps:
        if o.parent is None:
            o.location.z += delta
    bpy.context.view_layer.update()
    z_fin = min(zmin_real(o) for o in ps)
    print('ASENTADO: z_min %.4f -> %.4f (delta %+.4f)' % (z_ini, z_fin, delta))
    assert abs(z_fin - z_apoyo) < 1e-4, 'z_min %.4f != Z_APOYO %.4f' % (z_fin, z_apoyo)

    pts = []
    for o in ps:
        for v in o.data.vertices:
            w = o.matrix_world @ v.co
            if abs(w.z - z_apoyo) < tol:
                pts.append(w)
    xs = [p.x for p in pts]
    ys = [p.y for p in pts]
    fp_x = max(xs) - min(xs) if xs else 0.0
    fp_y = max(ys) - min(ys) if ys else 0.0
    print('HUELLA: toca=%d  footprint=%.2f x %.2f' % (len(pts), fp_x, fp_y))
    assert len(pts) >= min_toca, \
        'apoyo puntual: solo %d verts tocan el suelo (E-50)' % len(pts)
    assert min(fp_x, fp_y) > min_fp, \
        'huella demasiado chica %.2f x %.2f (E-50)' % (fp_x, fp_y)
    return z_fin, len(pts), fp_x, fp_y


# ---------- 6) Camara ----------
def camara(escena, nombre, loc=(2.2, -2.6, 1.3), mira=(0, 0, 0.4)):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object
    c.name = nombre
    c.rotation_euler = (Vector(mira) - Vector(loc)).to_track_quat('-Z', 'Y').to_euler()
    escena.camera = c
    return c


# ---------- 7) Flat shading ----------
def shade_flat(escena):
    for ob in escena.objects:
        ob.select_set(True)
    ps = piezas(escena)
    if ps:
        bpy.context.view_layer.objects.active = ps[0]
    bpy.ops.object.shade_flat()


# ---------- 8) Guardado ----------
def guardar(escena, modulo, asset):
    """Guarda <RAIZ>/tools/mcp/blender-mcp/<modulo>/<asset>_lowpoly.blend (E-21)."""
    ruta = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', modulo,
                        asset + '_lowpoly.blend')
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    if os.path.exists(ruta + '@'):
        os.remove(ruta + '@')
    bpy.ops.wm.save_as_mainfile(filepath=ruta)
    n = len(piezas(escena))
    print('OK — SM_: %d — blend: %s' % (n, ruta))
    return ruta
