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
import bmesh
import os
from math import pi, cos, sin
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


# ---------- 2c) Helper de LOFT (forma premium: afilada y con curvatura) ----------
def loft(nombre, anillos, material, lados=12, tapar_arriba=True,
         tapar_abajo=True, fase=0.0, ondas=None, ondas_z=None):
    """Malla generada apilando anillos elipticos — la alternativa premium a caja().

    MOTIVO (2026-09-02, NPC base M19): apilar cajas da figuras de "muñeco de
    palo" — hombros del mismo ancho que la cintura, brazos de seccion constante.
    Un loft permite AFINAR (cintura mas angosta que cadera y pecho) y CURVAR
    (desplazar el centro de cada anillo), que es lo que hace que una silueta lea
    como un cuerpo y no como un mueble.

    `anillos`: lista de (z, cx, cy, rx, ry), de ABAJO hacia ARRIBA.
      z   = altura del anillo
      cx  = desplazamiento del centro en X   (para inclinar / contrapposto)
      cy  = desplazamiento del centro en Y   (para curva frontal: pecho, panza)
      rx  = semieje en X  (la dimension FINAL, no el radio/2 — ver E-68)
      ry  = semieje en Y

    Los anillos pueden tener distinto rx/ry entre si: ahi esta el afilado.
    No hace falta que tengan el mismo "lados": todos usan el mismo.

    `tapar_abajo=False` deja el extremo inferior ABIERTO (util para mangas,
    short, cuellos: se ve el interior pero no aparece un disco plano visible
    desde abajo). `fase` rota todos los anillos para alinear costuras.

    ONDULACION (2026-09-02, sombrero de paja M19) — lo que separa un "cono de
    plastico" de una pieza tejida:
      `ondas`  = (amp_relativa, k)  -> r *= 1 + amp_relativa * cos(k * angulo)
      `ondas_z`= (amplitud_m,   k)  -> z += amplitud_m       * cos(k * angulo)
    Con `lados` multiplo de `2k` se obtiene un lobulo regular; si no, queda un
    salto en la costura. Ejemplo: ala de paja tejida `lados=24, ondas=(0.018,
    12), ondas_z=(0.006, 12)`.
    Se aplican a TODOS los anillos por igual (son modulaciones angulares, no
    de altura). El vertice central de las tapas usa el z PROMEDIO del anillo,
    no el del vertice 0 (con `ondas_z` el vertice 0 es arbitrario).

    E-79: `ondas_z` puede romper el guard de z crecientes si dos anillos estan
    mas cerca que `2 * ondas_z[0]`. En ese caso el guard salta y esta BIEN que
    salte: hay que separar los anillos o bajar la amplitud.

    Devuelve el objeto (ya linkado a la escena) para poder rotarlo/escalarlo.

    E-32: las normales se calculan con bm.normal_update(), y el orden de los
    vertices de cada cara esta verificado para que apunten hacia AFUERA.
    """
    assert len(anillos) >= 2, 'loft() necesita al menos 2 anillos'
    # E-77 (2026-09-02, NPC base M19): el formato de anillo es (z, cx, cy, ...)
    # con Z PRIMERO, no (x, y, z, ...). Pasar las coordenadas en orden de
    # vector produce una malla SILENCIOSAMENTE deformada: loft() interpreta x
    # como altura y z como desplazamiento en Y, y el objeto nace cualquier
    # cosa (un brazo deberia ir de z=0.68 a 1.14 y nacia de -0.22 a -0.16) sin
    # tirar ningun error. Como los anillos van de ABAJO hacia ARRIBA, las z
    # tienen que ser crecientes: eso da un guard barato y confiable.
    for _i in range(len(anillos) - 1):
        assert anillos[_i][0] <= anillos[_i + 1][0] + 1e-9, (
            'E-77: anillo %d tiene z=%.4f y el siguiente z=%.4f. Los anillos '
            'van de ABAJO hacia ARRIBA y el PRIMER campo es Z, no X. '
            '¿Pasaste (x, y, z, rx, ry) en vez de (z, cx, cy, rx, ry)?'
            % (_i, anillos[_i][0], anillos[_i + 1][0]))
    if ondas:
        assert float(ondas[1]).is_integer(), \
            'ondas k=%.3f no es entero: la onda no cierra en la costura' % ondas[1]
    if ondas_z:
        assert float(ondas_z[1]).is_integer(), \
            'ondas_z k=%.3f no es entero: la onda no cierra en la costura' % ondas_z[1]
    bm = bmesh.new()
    capas = []
    for (_z, _cx, _cy, _rx, _ry) in anillos:
        vs = []
        for _i in range(lados):
            _a = fase + 2.0 * pi * _i / lados
            _m = 1.0 + (ondas[0] * cos(ondas[1] * _a) if ondas else 0.0)
            _dz = ondas_z[0] * cos(ondas_z[1] * _a) if ondas_z else 0.0
            vs.append(bm.verts.new((_cx + _rx * _m * cos(_a),
                                    _cy + _ry * _m * sin(_a),
                                    _z + _dz)))
        capas.append(vs)

    # Costados: (a[i], a[j], b[j], b[i]) -> normal hacia AFUERA (verificado).
    for _k in range(len(capas) - 1):
        _a, _b = capas[_k], capas[_k + 1]
        for _i in range(lados):
            _j = (_i + 1) % lados
            bm.faces.new((_a[_i], _a[_j], _b[_j], _b[_i]))

    # Tapas por abanico a un vertice central.
    for _vs, _arriba in ((capas[0], False), (capas[-1], True)):
        if _arriba and not tapar_arriba:
            continue
        if (not _arriba) and not tapar_abajo:
            continue
        _n = len(_vs)
        # E-79: promedio de z, no _vs[0].co.z — con ondas_z el vertice 0 es
        # arbitrario y el centro de la tapa nace torcido.
        _c = bm.verts.new((sum(v.co.x for v in _vs) / _n,
                           sum(v.co.y for v in _vs) / _n,
                           sum(v.co.z for v in _vs) / _n))
        for _i in range(_n):
            _j = (_i + 1) % _n
            # arriba -> (c, i, j) da normal +Z ; abajo -> (c, j, i) da -Z
            bm.faces.new((_c, _vs[_i], _vs[_j]) if _arriba
                         else (_c, _vs[_j], _vs[_i]))

    bm.normal_update()
    malla = bpy.data.meshes.new(nombre)
    bm.to_mesh(malla)
    bm.free()
    o = bpy.data.objects.new(nombre, malla)
    bpy.context.scene.collection.objects.link(o)
    o.data.materials.append(material)
    return o


def polilinea(pts, ts):
    """Muestrea una polilinea 3D en las fracciones `ts` (0..1 del largo total).

    Para brazos/piernas: pasas [hombro, codo, muñeca] y las fracciones donde
    quieres cada anillo del loft. Devuelve lista de (x, y, z).
    """
    import math
    segs, acum = [], [0.0]
    for _i in range(len(pts) - 1):
        _d = math.sqrt(sum((pts[_i + 1][_k] - pts[_i][_k]) ** 2 for _k in range(3)))
        segs.append(_d)
        acum.append(acum[-1] + _d)
    total = acum[-1]
    assert total > 1e-9, 'polilinea de largo 0'
    out = []
    for _t in ts:
        _obj = _t * total
        _k = 0
        while _k < len(segs) - 1 and acum[_k + 1] < _obj:
            _k += 1
        _f = (_obj - acum[_k]) / segs[_k] if segs[_k] > 1e-9 else 0.0
        out.append(tuple(pts[_k][_m] + _f * (pts[_k + 1][_m] - pts[_k][_m])
                         for _m in range(3)))
    return out


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
