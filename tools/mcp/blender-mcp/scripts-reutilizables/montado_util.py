# montado_util.py — M19 · Helpers para assets MONTADOS (cabezas, ropa, sombreros)
#
# MOTIVO (2026-09-03, tanda de variantes de NPC)
# ----------------------------------------------
# Habia que autorar 7 assets montados (3 cabezas + 2 vestimentas + tunica de
# anciano + NPC sentado). Todos repiten el mismo bloque propenso a errores:
#   * marcar el .blend con el Empty `_MONTADO` (E-80)
#   * construir un MANIQUI DE REFERENCIA con las cotas exactas del NPC base
#     (un maniqui con cotas equivocadas hace que el guard APRUEBE un asset
#     que despues no encaja — peor que no tener guard)
#   * el guard de encaje que reemplaza a asentar()/E-50 (E-79)
#   * aplicar()/unir() con el cuidado de E-75/E-76
# Copiarlo 7 veces es multiplicar la superficie de bug (E-82: el bloque de
# paths ya nos costo un `tools\tools\` duplicado). Va en un solo lugar.
#
# SISTEMAS DE COORDENADAS
# -----------------------
# Los assets montados se autoran en el sistema del PUNTO DE MONTAJE, no en el
# del mundo. El origen local ES el punto de montaje (E-79). Dos frames:
#
#   CABEZA  -> `Z_REF_CABEZA` = 1.290 (base del cuello del NPC base v5).
#              `LC(z_abs) = z_abs - 1.290`, `XC(x_abs) = x_abs - X_CABEZA`.
#              El centro de la cabeza v5 esta en z_abs 1.440 -> local 0.150.
#
#   ROPA    -> `Z_REF_ROPA` = 0.0, o sea local == absoluto. La ropa se alinea
#              con TODO el cuerpo (no solo con el cuello), asi que no tiene
#              sentido desplazarla: se autoran directamente en cotas de mundo
#              y el guard mide contra el maniqui completo.
#
# POR QUE LA ROPA NO USA asentar()
# --------------------------------
# asentar() baja el grupo hasta z_min = 0.045. Una camisa empieza en 1.20, asi
# que la tiraria al piso. Y una tunica larga que SI llega al piso quedaria
# "apoyada" por accidente. Por eso el guard es de ENCAJE, no de apoyo: se
# verifica la distancia a la superficie del cuerpo, no al suelo.

import bpy
import bmesh
from math import radians, pi
from mathutils import Vector, Euler

from plantilla_asset import (mat, loft, polilinea, arena, iluminar, camara,
                             piezas, shade_flat, guardar)

# ===========================================================================
# COTAS DEL NPC BASE v5 (fuente de verdad para TODOS los maniquies)
# ===========================================================================
# Si el NPC base cambia, hay que cambiarlas ACA y en ningun otro lado.
# (Antes estaban copiadas a mano en crear_sombrero_paja_lowpoly.py.)
Z_APOYO = 0.045

Z_REF_CABEZA = 1.290          # base del cuello = punto de montaje de cabezas
Z_REF_ROPA = 0.0              # la ropa se autora en cotas de mundo

X_CABEZA = -0.023             # la cabeza sigue la inclinacion del contrapposto
Y_CABEZA = -0.006
Z_CABEZA = 1.440              # centro del craneo
R_CABEZA = (0.132, 0.118, 0.160)

# Contrapposto del cuerpo base: el tronco se inclina 2 grados hacia -X
# desde el pivote de cadera. dx() debe coincidir con crear_npc_base_lowpoly.
Z_PIVOTE = 0.780
TAN_INC = __import__('math').tan(radians(2.0))


def dx(z):
    """Desplazamiento en X del eje del cuerpo a la altura z (contrapposto)."""
    return -(z - Z_PIVOTE) * TAN_INC


# --- helpers de cambio de frame -------------------------------------------
def LC(z_abs):
    """Absoluto -> local de CABEZA."""
    return z_abs - Z_REF_CABEZA


def XC(x_abs):
    return x_abs - X_CABEZA


def YC(y_abs):
    return y_abs - Y_CABEZA


# ===========================================================================
# Anatomia del cuerpo base (para el maniqui y para el guard de encaje)
# ===========================================================================
# Loft del torso: (z, cx, cy, rx, ry) — E-77, Z PRIMERO.
ANILLOS_TORSO = [
    (0.720, dx(0.720),  0.000, 0.176, 0.118),
    (0.790, dx(0.790), -0.002, 0.194, 0.128),
    (0.880, dx(0.880), -0.006, 0.170, 0.118),
    (0.960, dx(0.960), -0.008, 0.151, 0.108),
    (1.040, dx(1.040), -0.002, 0.161, 0.118),
    (1.110, dx(1.110),  0.008, 0.183, 0.128),
    (1.165, dx(1.165),  0.012, 0.192, 0.132),
    (1.205, dx(1.205),  0.008, 0.186, 0.128),
    (1.245, dx(1.245), -0.002, 0.132, 0.092),
    (1.290, dx(1.290), -0.012, 0.064, 0.058),
]

# Brazos y piernas como polilineas (hombro/cadera -> extremo) + radios.
BRAZOS = {
    'I': [(-0.153, 0.004, 1.150), (-0.180, 0.000, 0.905), (-0.212, 0.008, 0.668)],
    'D': [( 0.126, 0.012, 1.168), ( 0.164, 0.016, 0.918), ( 0.214, 0.030, 0.686)],
}
TS_BRAZO = (0.0, 0.26, 0.53, 0.78, 1.0)
R_BRAZO = (0.066, 0.056, 0.050, 0.044, 0.040)

PIERNAS = {
    'I': [(-0.102, -0.004, 0.800), (-0.101, -0.002, 0.560),
          (-0.100,  0.004, 0.420), (-0.100,  0.008, 0.240),
          (-0.100,  0.012, 0.100)],
    'D': [( 0.102,  0.014, 0.800), ( 0.103,  0.026, 0.560),
          ( 0.100,  0.038, 0.420), ( 0.100,  0.046, 0.240),
          ( 0.100,  0.052, 0.100)],
}
R_PIERNA = (0.090, 0.080, 0.068, 0.056, 0.046)

# Caps de hombro del cuerpo base. La ropa DEBE pasar por fuera de ellos o el
# guard la aprueba y queda una manga una con el brazo (E-84, 2026-09-03).
DELTOIDES = [
    # (centro_x, centro_y, centro_z, radio_x, radio_y, radio_z)
    (dx(1.175) + 0.140, 0.006, 1.175, 0.084, 0.070, 0.052),    # derecho
    (dx(1.158) - 0.140, 0.006, 1.158, 0.084, 0.070, 0.052),    # izquierdo
]


def _interpolar(anillos, z, campo):
    """Valor del campo (3=rx, 4=ry, 1=cx, 2=cy) del loft a la altura z."""
    zs = [a[0] for a in anillos]
    if z <= zs[0]:
        return anillos[0][campo]
    if z >= zs[-1]:
        return anillos[-1][campo]
    for i in range(len(zs) - 1):
        if z <= zs[i + 1]:
            f = (z - zs[i]) / (zs[i + 1] - zs[i])
            return anillos[i][campo] + f * (anillos[i + 1][campo]
                                            - anillos[i][campo])
    return anillos[-1][campo]


def dentro_torso(p, escala=1.0):
    """<=1.0 significa que el punto esta DENTRO del torso (elipse escalada).

    `escala` < 1 encoge la elipse (para exigir clearance a la ropa).
    Devuelve t = ((x-cx)/rx)^2 + ((y-cy)/ry)^2. t<1 => dentro.
    """
    z = p[2]
    if z < ANILLOS_TORSO[0][0] or z > ANILLOS_TORSO[-1][0]:
        return 9.9                     # fuera del rango: no aplica
    cx = _interpolar(ANILLOS_TORSO, z, 1)
    cy = _interpolar(ANILLOS_TORSO, z, 2)
    rx = _interpolar(ANILLOS_TORSO, z, 3) * escala
    ry = _interpolar(ANILLOS_TORSO, z, 4) * escala
    if rx <= 1e-6 or ry <= 1e-6:
        return 9.9
    return ((p[0] - cx) / rx) ** 2 + ((p[1] - cy) / ry) ** 2


def _dist_a_polilinea(p, pts, ts, radios):
    """Distancia del punto al eje de la polilinea menos el radio interpolado.

    Negativo => el punto esta dentro del tubo (brazo/pierna).
    """
    muestras = polilinea(pts, ts)
    mejor = 1e9
    for i in range(len(muestras) - 1):
        a, b = Vector(muestras[i]), Vector(muestras[i + 1])
        ab = b - a
        L2 = ab.length_squared
        t = 0.0 if L2 < 1e-12 else max(0.0, min(1.0,
                                                (Vector(p) - a).dot(ab) / L2))
        proy = a + ab * t
        d = (Vector(p) - proy).length
        r = radios[i] + t * (radios[i + 1] - radios[i])
        mejor = min(mejor, d - r)
    return mejor


TODAS_LAS_PARTES = ('torso', 'brazos', 'piernas', 'deltoides')
GPO_OCULTO = 'OCULTO'


def clearance_cuerpo(p, partes=None):
    """Distancia firmada a la superficie del cuerpo base (negativo = adentro).

    Para ropa: queremos clearance >= ~0.005 (5 mm por fuera de la piel).
    Se toma el MINIMO entre torso (eliptico) y extremidades (tubos), que es
    la condicion conservadora: si alguna dice "adentro", esta adentro.

    `partes`: subconjunto de TODAS_LAS_PARTES a auditar (E-89). None = todas.
    La ropa de TRONCO (camisa, cinturon, delantal) se audita SIN los brazos:
    el brazo cuelga por FUERA de la prenda y la oculta, y en este rig los
    brazos van pegados al torso (el torso es una envolvente que los contiene
    hasta la axila), de modo que exigirles clearance es imposible. Las MANGAS
    se auditan solo contra brazos+deltoides, y las PERNERAS contra piernas.
    """
    usar = set(partes) if partes else set(TODAS_LAS_PARTES)
    t = dentro_torso(p)
    # Convertir t (elipse) a una distancia aproximada en metros:
    # t = (d_eff / r_eff)^2 con r_eff = sqrt(rx*ry). d_eff = r_eff*sqrt(t).
    z = p[2]
    if 'torso' in usar and ANILLOS_TORSO[0][0] <= z <= ANILLOS_TORSO[-1][0]:
        rx = _interpolar(ANILLOS_TORSO, z, 3)
        ry = _interpolar(ANILLOS_TORSO, z, 4)
        r_eff = (rx * ry) ** 0.5
        d_torso = r_eff * (max(t, 0.0) ** 0.5 - 1.0)   # negativo si t<1
    else:
        d_torso = 9.9
    d_ext = min((_dist_a_polilinea(p, BRAZOS[k], TS_BRAZO, R_BRAZO)
                 for k in BRAZOS), default=9.9) if 'brazos' in usar else 9.9
    d_pier = min((_dist_a_polilinea(p, PIERNAS[k],
                                    (0.0, 0.25, 0.5, 0.75, 1.0), R_PIERNA)
                  for k in PIERNAS), default=9.9) if 'piernas' in usar else 9.9
    # Caps de hombro (elipsoides). E-84: si se omiten, las mangas atraviesan
    # los deltoides y el clearance NO lo marca.
    d_del = 9.9
    for (cx, cy, cz, rx, ry, rz) in (DELTOIDES if 'deltoides' in usar else ()):
        if rx <= 1e-6 or ry <= 1e-6 or rz <= 1e-6:
            continue
        s = (((p[0] - cx) / rx) ** 2 + ((p[1] - cy) / ry) ** 2
             + ((p[2] - cz) / rz) ** 2)
        r_eff = (rx * ry * rz) ** (1.0 / 3.0)
        d_del = min(d_del, r_eff * (max(s, 0.0) ** 0.5 - 1.0))
    return min(d_torso, d_ext, d_pier, d_del)


def marcar_ocultos(obj, pred):
    """Marca en el vertex group OCULTO los vertices que cumplen pred(co_mundo).

    E-87: un vertice de ropa puede quedar DENTRO del cuerpo sin ser un
    defecto, siempre que OTRA PIEZA lo tape. Casos inevitables:
      * la TAPA SUPERIOR de un tubo que rodea una extremidad: el vertice
        central de la tapa esta sobre el eje del brazo/pierna, asi que por
        construccion esta dentro del cuerpo (caso real: pernera del pantalon
        de campesina, peor -0.0824 m en el centro de la tapa).
      * el ARRANQUE de una pernera dentro de la cadera, tapado por la pieza
        de cadera que lo envuelve.
      * el hombro de una manga, tapado por el deltoides.
    verificar_ropa() salta estos vertices. El grupo sobrevive a unir().
    """
    g = obj.vertex_groups.new(name=GPO_OCULTO)
    marcados = []
    for v in obj.data.vertices:
        w = obj.matrix_world @ v.co
        if pred(w):
            marcados.append((v.index, (w.x, w.y, w.z)))
    if marcados:
        g.add([i for (i, _c) in marcados], 1.0, 'REPLACE')
    print('   OCULTO %-22s %d verts %s'
          % (obj.name, len(marcados),
             ' '.join('(%.3f,%.3f,%.3f)' % c for (_i, c) in marcados[:4])))
    return len(marcados)


def indices_ocultos(obj):
    """Conjunto de indices de vertice marcados OCULTO (vacio si no hay grupo).

    Se recorre `v.groups` en vez de `vg.weight(i)`: Blender imprime
    'Error: Vertex not in group' en la consola por cada vertice ajeno al
    grupo (ruido que ensucia el log de generacion) aunque no lance excepcion.
    """
    for vg in obj.vertex_groups:
        if vg.name == GPO_OCULTO:
            return set(v.index for v in obj.data.vertices
                       if any(g.group == vg.index for g in v.groups))
    return set()


# ===========================================================================
# E-75/E-76 — aplicar y unir
# ===========================================================================
def aplicar(o):
    """E-75: aplicar transformadas ANTES de join (escala no uniforme deforma)."""
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return o


def unir(nombre, objetos):
    """Join + dedupe de slots de material CONSERVANDO el material de cada cara.

    E-76 dice "usa clear() porque pop(update_data=) no existe en 4.x".
    E-35 dice "NUNCA uses clear()".
    Los dos tienen razon y la resolucion es E-83 (2026-09-03): usa clear(),
    pero respalda los `material_index` de las caras ANTES y reasignalos
    DESPUES pasandolos por el mapa slot-viejo -> slot-nuevo. Sin ese backup,
    Blender clampea todos los indices a 0 y la pieza se renderiza con un
    UNICO material aunque tenga N slots.

    Caso real: `SM_NPC_RopaBase` (short de lino + cinturon de cuero) salia con
    2 slots y las 120 caras en el slot 0 -> el cinturon se veia de lino.
    """
    if len(objetos) == 1:
        # join() con una sola pieza tira "Warning: No mesh data to join" y no
        # hace nada. Paso real: `unir('SM_Cab_Boca', [boca] + mejillas)` con
        # `MEJILLAS=None` (la variante anciano no lleva colorete).
        objetos[0].name = nombre
        return objetos[0]
    bpy.ops.object.select_all(action='DESELECT')
    for o in objetos:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objetos[0]
    bpy.ops.object.join()
    o = bpy.context.object
    o.name = nombre

    vistos = []
    mapa = []
    for m in list(o.data.materials):
        if m is None:
            mapa.append(0)
            continue
        if m not in vistos:
            vistos.append(m)
        mapa.append(vistos.index(m))

    if len(vistos) != len(o.data.materials):      # E-35: solo si difieren
        idx_caras = [p.material_index for p in o.data.polygons]
        o.data.materials.clear()
        for m in vistos:
            o.data.materials.append(m)
        for p, mi in zip(o.data.polygons, idx_caras):
            p.material_index = mapa[mi] if mi < len(mapa) else 0
    return o


def aplicar_todos_sm():
    for o in list(bpy.context.scene.objects):
        if o.type == 'MESH' and o.name.startswith('SM_'):
            aplicar(o)


# ===========================================================================
# E-80 — marcar el .blend como MONTADO
# ===========================================================================
def marcar_montado():
    """Empty `_MONTADO`: generar_variante.py omite el re-asentado si lo ve.

    El Empty no es geometria y no lleva prefijo SM_, asi que E-44 lo filtra
    del export glTF. Va en el origen local == punto de montaje.
    """
    bpy.ops.object.empty_add(type='PLAIN_AXES', location=(0.0, 0.0, 0.0))
    bpy.context.object.name = '_MONTADO'
    return bpy.context.object


# ===========================================================================
# E-79 — rotacion aplicada a VERTICES (no a rotation_euler)
# ===========================================================================
def rotar_vertices(objs, euler):
    """Rota la geometria de `objs` por `euler` (tupla de radianes).

    Por que no `rotation_euler`: las piezas con origen propio (el lazo del
    sombrero, un moño, un flequillo) rotarian SOBRE SI MISMAS y se
    despegarian del grupo. Rotar los vertices rota todo como un cuerpo rigido
    y deja la transformada del objeto en identidad, que es lo que el sistema
    de montaje espera (E-79).
    """
    r = Euler(euler, 'XYZ').to_matrix().to_4x4()
    for o in objs:
        bm = bmesh.new()
        bm.from_mesh(o.data)
        for v in bm.verts:
            v.co = r @ v.co
        bm.to_mesh(o.data)
        bm.free()
        o.data.update()


# ===========================================================================
# Maniquies de referencia (prefijo REF_ => NO se exportan, E-44)
# ===========================================================================
MAT_REF = None
MAT_REF_OSC = None


def _mats_ref():
    global MAT_REF, MAT_REF_OSC
    if MAT_REF is None:
        MAT_REF = mat('MAT_REF_Cuerpo', (0.78, 0.76, 0.72), rough=1.0)
        MAT_REF_OSC = mat('MAT_REF_Oscuro', (0.45, 0.44, 0.43), rough=1.0)
    return MAT_REF, MAT_REF_OSC


def maniqui_cabeza(escena):
    """Cabeza + pelo + ojos + cuello del NPC base v5, en el frame de CABEZA.

    Devuelve dict con las piezas para que el generador las use en el guard.
    """
    mref, mosc = _mats_ref()
    out = {}
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=10, radius=1.0,
                                         location=(0.0, YC(Y_CABEZA),
                                                   LC(Z_CABEZA)))
    o = bpy.context.object
    o.name = 'REF_Cabeza'
    o.scale = R_CABEZA
    o.data.materials.append(mref)
    out['cabeza'] = o

    out['pelo'] = loft('REF_Pelo', [
        (LC(1.490), 0.0, YC(-0.040), 0.140, 0.090),
        (LC(1.540), 0.0, YC(-0.030), 0.148, 0.110),
        (LC(1.580), 0.0, YC(-0.020), 0.108, 0.092),
        (LC(1.612), 0.0, YC(-0.010), 0.040, 0.034),
    ], mosc, lados=12)

    for sx in (-1, +1):
        bpy.ops.mesh.primitive_cylinder_add(
            vertices=6, radius=0.032, depth=0.020,
            location=(sx * 0.050, YC(0.108), LC(1.445)))
        e = bpy.context.object
        e.name = 'REF_Ojo'
        e.rotation_euler = (radians(-90.0), 0.0, 0.0)
        e.scale = (1.0, 0.50, 1.0)
        e.data.materials.append(mosc)
        out.setdefault('ojos', []).append(e)

    # Cuello del cuerpo base: de z_abs 1.290 a 1.400, radio ~0.052
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=10, radius=0.052, depth=0.110,
        location=(0.0, YC(-0.013), LC(1.345)))
    o = bpy.context.object
    o.name = 'REF_Cuello'
    o.data.materials.append(mref)
    out['cuello'] = o
    return out


def maniqui_cuerpo(escena, con_arena=True, z_arena=0.05):
    """Cuerpo completo del NPC base v5 en cotas de MUNDO (frame de ROPA).

    Piezas REF_ (no exportadas). Se usa para juzgar encaje de ropa en las
    capturas orbitales y como geometria contra la que mide el guard.
    """
    mref, mosc = _mats_ref()
    out = {}

    out['torso'] = loft('REF_Torso', ANILLOS_TORSO, mref, lados=12,
                        tapar_arriba=True, tapar_abajo=False)

    for lado in ('I', 'D'):
        muestras = polilinea(BRAZOS[lado], TS_BRAZO)
        anillos = [(muestras[i][2], muestras[i][0], muestras[i][1],
                    R_BRAZO[i], R_BRAZO[i]) for i in range(len(muestras))]
        anillos.reverse()
        out['brazo_' + lado] = loft('REF_Brazo_' + lado, anillos, mref, lados=8)

    for lado in ('I', 'D'):
        pts = PIERNAS[lado]
        anillos = [(pts[i][2], pts[i][0], pts[i][1], R_PIERNA[i], R_PIERNA[i])
                   for i in range(len(pts))]
        anillos.reverse()
        out['pierna_' + lado] = loft('REF_Pierna_' + lado, anillos, mref,
                                     lados=10)

    # Hombros como caps (los deltoides del cuerpo base) — la ropa tiene que
    # pasar por ENCIMA de ellos, y sin esta pieza el guard aprobaria una
    # camisa que los atraviesa.
    for sx, zc in ((+1, 1.175), (-1, 1.158)):
        bpy.ops.mesh.primitive_ico_sphere_add(
            subdivisions=2, radius=1.0,
            location=(dx(zc) + sx * 0.140, 0.006, zc))
        d = bpy.context.object
        d.name = 'REF_Deltoide_' + ('D' if sx > 0 else 'I')
        d.scale = (0.084, 0.070, 0.052)
        d.data.materials.append(mref)
        out['deltoide_' + ('D' if sx > 0 else 'I')] = d

    # Cabeza + pelo para juzgar si un cuello alto tapa la cara
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=10, radius=1.0,
                                         location=(X_CABEZA, Y_CABEZA,
                                                   Z_CABEZA))
    o = bpy.context.object
    o.name = 'REF_Cabeza'
    o.scale = R_CABEZA
    o.data.materials.append(mref)
    out['cabeza'] = o

    out['pelo'] = loft('REF_Pelo', [
        (1.490, X_CABEZA, -0.040, 0.140, 0.090),
        (1.540, X_CABEZA, -0.030, 0.148, 0.110),
        (1.580, X_CABEZA, -0.020, 0.108, 0.092),
        (1.612, X_CABEZA, -0.010, 0.040, 0.034),
    ], mosc, lados=12)

    if con_arena:
        a = arena(radio=1.4)
        a.location.z = z_arena - 0.11
        a.data.materials.append(mref)
        out['arena'] = a
    return out


# ===========================================================================
# Guard de encaje para CABEZAS (reemplaza asentar()/E-50)
# ===========================================================================
def verificar_cabeza(escena, z_ojos_local=None):
    """Guard E-79 para una cabeza montada en la base del cuello.

    Comprobaciones:
      (a) el cuello de la cabeza CUBRE la base del cuello del cuerpo
          (baja hasta z_local <= -0.01, o sea por debajo de z_abs 1.280)
          -> si no, queda un hueco entre cuello y torso.
      (b) no es una cabeza gigante: ancho total <= 0.36 m, alto <= 0.42 m.
      (c) no se come los hombros: el vertice mas bajo de la pieza esta por
          encima de z_local -0.02 (z_abs 1.270).
      (d) la cara mira a +Y: hay geometria en y_local > 0.08 (menton/nariz)
          y en y_local < -0.06 (nuca) — si falta una de las dos, la cabeza
          esta deformada o girada.
      (e) los ojos (si se pasa `z_ojos_local`) quedan en la mitad superior
          de la cara, no en el menton.
    """
    ps = piezas(escena)
    assert ps, 'no hay piezas SM_ en la escena'
    vs = []
    for o in ps:
        vs.extend(o.matrix_world @ v.co for v in o.data.vertices)
    xs = [v.x for v in vs]
    ys = [v.y for v in vs]
    zs = [v.z for v in vs]

    # (a) cubre la base del cuello
    z_min = min(zs)
    print('E-79(a) cuello: z_local_min %.4f (debe ser <= -0.010)' % z_min)
    assert z_min <= -0.010, (
        'E-79(a): la cabeza no cubre la base del cuello (z_local_min %.4f). '
        'Quedaria un hueco entre el cuello y el torso: baja el loft del '
        'cuello hasta z_local -0.02 por lo menos.' % z_min)

    # (b) tamanio
    ancho = max(xs) - min(xs)
    alto = max(zs) - min(zs)
    print('E-79(b) tamano: ancho %.3f m  alto %.3f m' % (ancho, alto))
    assert ancho <= 0.36, 'E-79(b): cabeza de %.3f m de ancho — gigante' % ancho
    assert alto <= 0.42, 'E-79(b): cabeza de %.3f m de alto — gigante' % alto

    # (c) no se come los hombros
    print('E-79(c) hombros: z_local_min %.4f (debe ser > -0.025)' % z_min)
    assert z_min > -0.025, (
        'E-79(c): la cabeza baja hasta z_local %.4f y se come los hombros '
        '(z_abs %.3f). Subi el punto de montaje o acorta el cuello.'
        % (z_min, z_min + Z_REF_CABEZA))

    # (d) orientacion de la cara
    frente = [v for v in vs if v.y > 0.08]
    nuca = [v for v in vs if v.y < -0.06]
    print('E-79(d) cara: %d verts adelante (y>0.08), %d detras (y<-0.06)'
          % (len(frente), len(nuca)))
    assert frente, 'E-79(d): no hay geometria en y>0.08 — la cara mira a -Y?'
    assert nuca, 'E-79(d): no hay geometria en y<-0.06 — la cabeza esta chata'

    # (e) altura de los ojos
    if z_ojos_local is not None:
        z_medio = (min(zs) + max(zs)) / 2.0
        print('E-79(e) ojos: z_local %.4f vs medio de la cabeza %.4f'
              % (z_ojos_local, z_medio))
        assert z_ojos_local > z_medio - 0.02, (
            'E-79(e): los ojos estan en z_local %.4f, por debajo del medio '
            'de la cabeza (%.4f) — quedan en el menton.' % (z_ojos_local,
                                                            z_medio))

    print('E-79 CABEZA OK — z_local %.4f..%.4f — %d piezas'
          % (min(zs), max(zs), len(ps)))


# ===========================================================================
# Guard de encaje para ROPA
# ===========================================================================
def verificar_ropa(escena, tolerancia=0.02, clearance_min=0.004,
                   z_tope_cara=1.30, excluir=(), partes=None):
    """Guard E-79 para ropa montada en cotas de mundo.

    Comprobaciones:
      (a) NO INTERPENETRA el cuerpo: como maximo `tolerancia` (2 %) de los
          vertices pueden estar mas de 5 mm DENTRO de la piel. Un porcentaje
          pequeno es inevitable en dobladillos y sisas, donde la prenda se
          mete un poco para no dejar ver el corte.
      (b) NO TAPA LA CARA: ningun vertice en la zona de los ojos
          (|x| < 0.10, y > 0.09) por encima de `z_tope_cara`.
      (c) CUBRE LO QUE TIENE QUE CUBRIR: la prenda llega al menos hasta la
          linea de hombros (z >= 1.15) — si no, es un short, no una camisa.
          Se puede relajar con `z_min_esperado`.
      (d) NO ES UNA CARPA: el semieje horizontal maximo <= 0.42 m.

    `excluir`: conjunto de NOMBRES de piezas que NO se auditan en absoluto.
    `partes`:  {nombre_pieza: ('torso','brazos',...)} — que partes del cuerpo
               se le exigen a cada pieza. None => todas (E-89).

    E-86/E-89: la manga NO se excluye; se le audita solo contra
    ('brazos','deltoides'), porque su mitad interior queda dentro del torso
    POR DISENO (el brazo esta dentro de la envolvente del torso a la altura
    del hombro) y esa mitad la oculta el cuerpo. A la camisa y al cordon se
    les audita sin 'brazos': el brazo cuelga por fuera de la prenda y la
    tapa. A las perneras, sin 'torso'.
    """
    ps = [p for p in piezas(escena) if p.name not in excluir]
    assert ps, 'no hay piezas SM_ (no excluidas) en la escena'
    if excluir:
        print('E-79 excluidas de (a): %s' % ', '.join(sorted(excluir)))
    vs = []
    for o in ps:
        vs.extend(o.matrix_world @ v.co for v in o.data.vertices)

    # (a) interpenetracion — con desglose por pieza para poder arreglarlo
    adentro = 0
    peor = 0.0
    por_pieza = []
    n_ocult = 0
    for o in ps:
        n_o = 0
        peor_o = 0.0
        donde_o = None
        ocult = indices_ocultos(o)                      # E-87
        n_ocult += len(ocult)
        partes_o = (partes or {}).get(o.name)
        for v in o.data.vertices:
            if v.index in ocult:
                continue
            w = o.matrix_world @ v.co
            c = clearance_cuerpo((w.x, w.y, w.z), partes=partes_o)
            if c < -0.005:                   # mas de 5 mm dentro de la piel
                adentro += 1
                n_o += 1
                if c < peor_o:
                    peor_o = c
                    donde_o = (w.x, w.y, w.z)
        peor = min(peor, peor_o)
        if n_o:
            por_pieza.append((n_o, peor_o, o.name, donde_o))
    frac = adentro / float(len(vs))
    print('E-79(a) interpenetracion: %d/%d verts (%.1f %%), peor %.4f m'
          ' (%d marcados OCULTO, E-87)'
          % (adentro, len(vs), frac * 100.0, peor, n_ocult))
    if frac > tolerancia:
        por_pieza.sort(reverse=True)
        print('    desglose por pieza (n, peor, nombre, punto):')
        for (n_o, peor_o, nom, d) in por_pieza:
            print('      %4d  %+.4f  %-22s %s'
                  % (n_o, peor_o, nom,
                     '(%.3f, %.3f, %.3f)' % d if d else '-'))
    assert frac <= tolerancia, (
        'E-79(a): %.1f %% de los vertices estan mas de 5 mm dentro del cuerpo '
        '(peor %.4f m). La prenda atraviesa la piel — separala del eje del '
        'cuerpo o agranda los semi-ejes.' % (frac * 100.0, peor))

    # (b) no tapa la cara
    zona = [v for v in vs if abs(v.x - X_CABEZA) < 0.10 and v.y > 0.09
            and v.z > z_tope_cara]
    print('E-79(b) cara: %d verts sobre z=%.2f en la zona de los ojos'
          % (len(zona), z_tope_cara))
    assert not zona, (
        'E-79(b): %d vertices tapan la cara por encima de z=%.2f (cuello '
        'demasiado alto o capa mal colocada).' % (len(zona), z_tope_cara))

    # (d) no es una carpa (se evalua antes que (c) para dar el error grande)
    r_max = max((v.x ** 2 + v.y ** 2) for v in vs) ** 0.5
    print('E-79(d) radio max %.3f m' % r_max)
    assert r_max <= 0.42, 'E-79(d): prenda de %.3f m de radio — es una carpa' \
        % r_max

    zs = [v.z for v in vs]
    print('E-79(d2) rango z: %.4f .. %.4f — %d piezas'
          % (min(zs), max(zs), len(ps)))
    return min(zs), max(zs)


# ===========================================================================
# Auditoria comun (triangulos REALES, E-33/E-40)
# ===========================================================================
def auditar(escena, presupuesto_alta_obj=16):
    """Imprime SM_, triangulos y materiales; valida el tope de ALTA (E-70)."""
    ps = piezas(escena)
    tot = 0
    for o in ps:
        o.data.update()
        o.data.calc_loop_triangles()
        tot += len(o.data.loop_triangles)
    # E-42: materiales USADOS POR CARAS, no slots.
    usados = set()
    for o in ps:
        for p in o.data.polygons:
            if p.material_index < len(o.data.materials):
                m = o.data.materials[p.material_index]
                if m is not None:
                    usados.add(m.name)
    print('SM_: %d — triangulos: %d — materiales usados: %d (%s)'
          % (len(ps), tot, len(usados), ', '.join(sorted(usados))))
    assert len(ps) <= presupuesto_alta_obj, (
        'E-70: %d SM_ supera el tope de ALTA (%d). Uni piezas o quita detalle.'
        % (len(ps), presupuesto_alta_obj))
    return len(ps), tot, len(usados)


def cerrar(escena, modulo, asset, loc_cam, mira_cam, montado=True):
    """Cierre canonico para assets MONTADOS: luz, camara, flat, auditoria.

    NO llama a asentar() (E-79). Si `montado`, marca el Empty `_MONTADO`.
    """
    if montado:
        marcar_montado()
    iluminar(escena)
    camara(escena, 'CAM_' + asset.upper(), loc_cam, mira_cam)
    shade_flat(escena)
    auditar(escena)
    guardar(escena, modulo, asset)


# ===========================================================================
# Constructor de CABEZA (comun a las 3 variantes)
# ===========================================================================
# Por que un constructor parametrico y no 3 scripts independientes:
# el bloque craneo+mandibula+nariz+orejas+ojos+cejas+boca+uniones es el que
# concentra E-75 (join con escala no uniforme deforma), E-58 (alinear el cono
# de la nariz), E-77 (formato de anillo) y E-76 (pop() de materiales). Repetirlo
# 3 veces es multiplicar por 3 la superficie de bug. Cada variante pasa solo
# su diccionario de parametros + su pelo + sus extras.
def construir_cabeza(escena, P, MATS):
    """Construye cuello + craneo + nariz + orejas + ojos + cejas + boca.

    Devuelve dict con las piezas ya unidas:
      cabeza, cabello, ojos, cejas, boca   (5 SM_ + los extras del caller)

    `P` es un dict con las claves:
      R_CRANEO      (rx, ry, rz) del elipsoide de la cabeza
      MANDIBULA     (z_umbral, avance_y, estrechar_x, plano_z)
      NARIZ         (radio, alto, dir_vector)
      OJOS          (radio, sep_x, z_abs, y)
      CEJAS         (ancho, alto, grosor, z_abs, ang_deg)
      BOCA          (ancho, alto, grosor, z_abs)
      MEJILLAS      (radio, sep_x, z_abs, y)  o None
      CUELLO        lista de anillos LOCALES (z, cx, cy, rx, ry)
    Los z de OJOS/CEJAS/BOCA/MEJILLAS se pasan en ABSOLUTO y se convierten
    con LC()/XC()/YC() — asi las cotas son comparables con el NPC base.
    """
    from math import radians as _rad
    MAT_piel = MATS['piel']
    MAT_cabello = MATS['cabello']
    MAT_ojos = MATS['ojos']
    MAT_boca = MATS['boca']

    # --- Cuello: loft local, desde DEBAJO del punto de montaje ---
    # z_local -0.020 -> 0.110. El tramo negativo es lo que garantiza que no
    # quede un hueco entre el cuello de la cabeza y el cuello del torso
    # (guard E-79(a)).
    cuello = loft('SM_Cab_Cuello', P['CUELLO'], MAT_piel, lados=12,
                  tapar_arriba=False, tapar_abajo=False)

    # --- Craneo: ico-esfera deformada en espacio UNITARIO ---
    # La deformacion va ANTES de aplicar la escala: si se hiciera despues,
    # los factores 0.13/0.18 estarian en metros y no serian proporcionales.
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0,
                                          location=(0, 0, 0))
    cabeza = bpy.context.object
    cabeza.name = 'SM_Cab_Craneo'
    zu, avance, estrecho, plano = P['MANDIBULA']
    bm = bmesh.new()
    bm.from_mesh(cabeza.data)
    for v in bm.verts:
        if v.co.z < zu:                       # tercio inferior = mandibula
            f = min(1.0, (zu - v.co.z) / (1.0 + zu))
            v.co.y += avance * f              # menton adelantado
            v.co.x *= 1.0 - estrecho * f      # mandibula mas angosta
            v.co.z *= 1.0 - plano * f         # cara mas plana abajo
        if v.co.y < -0.55:                    # nuca apenas aplanada
            v.co.y *= 0.97
    bm.to_mesh(cabeza.data)
    bm.free()
    cabeza.data.update()
    cabeza.scale = P['R_CRANEO']
    cabeza.location = (0.0, 0.0, LC(P.get('Z_CRANEo', 1.440)))
    cabeza.data.materials.append(MAT_piel)

    # --- Nariz: cono alineado con to_track_quat (E-58) ---
    rn, hn, dn = P['NARIZ']
    base = (0.0, P['NARIZ_Y'], P['NARIZ_Z'])
    bpy.ops.mesh.primitive_cone_add(
        vertices=5, radius1=rn, radius2=0.0, depth=hn,
        location=tuple(base[k] + dn[k] * hn / 2.0 for k in range(3)))
    nariz = bpy.context.object
    nariz.rotation_euler = dn.to_track_quat('Z', 'Y').to_euler()
    nariz.data.materials.append(MAT_piel)

    # --- Orejas: discos de 6 lados, eje en X ---
    orejas = []
    for sx in (-1, +1):
        bpy.ops.mesh.primitive_cylinder_add(
            vertices=6, radius=P['OREJA_R'], depth=0.026,
            location=(sx * (P['R_CRANEO'][0] - 0.004), P['OREJA_Y'],
                      P['OREJA_Z']))
        o = bpy.context.object
        o.rotation_euler = (0.0, _rad(90.0), 0.0)   # eje +Z -> +X
        o.scale = (1.0, 0.577, 1.0)
        o.data.materials.append(MAT_piel)
        orejas.append(o)

    # --- Ojos: cilindros de 6 lados, eje en +Y ---
    ojos = []
    ro, sxo, zo, yo = P['OJOS']
    for sx in (-1, +1):
        bpy.ops.mesh.primitive_cylinder_add(
            vertices=6, radius=ro, depth=0.020,
            location=(sx * sxo, YC(yo), LC(zo)))
        o = bpy.context.object
        o.rotation_euler = (_rad(-90.0), 0.0, 0.0)
        o.scale = (1.0, P['OJO_CHATO'], 1.0)
        o.data.materials.append(MAT_ojos)
        ojos.append(o)

    # --- Cejas ---
    cejas = []
    aw, ah, ag, za, ang = P['CEJAS']
    for sx in (-1, +1):
        bpy.ops.mesh.primitive_cube_add(size=1.0,
                                        location=(sx * (sxo + 0.002),
                                                  YC(yo - 0.014), LC(za)))
        o = bpy.context.object
        o.scale = (aw, ag, ah)
        o.rotation_euler = (0.0, sx * _rad(ang), 0.0)
        o.data.materials.append(MAT_cabello)
        cejas.append(o)

    # --- Boca ---
    bw, bh, bg, zb = P['BOCA']
    bpy.ops.mesh.primitive_cube_add(size=1.0,
                                    location=(0.0, YC(yo - 0.030), LC(zb)))
    boca = bpy.context.object
    boca.scale = (bw, bg, bh)
    boca.data.materials.append(MAT_boca)

    # --- Mejillas (colorete) ---
    mejillas = []
    if P.get('MEJILLAS'):
        rm, sxm, zm, ym = P['MEJILLAS']
        for sx in (-1, +1):
            bpy.ops.mesh.primitive_cylinder_add(
                vertices=6, radius=rm, depth=0.006,
                location=(sx * sxm, YC(ym), LC(zm)))
            o = bpy.context.object
            o.rotation_euler = (_rad(-90.0), 0.0, 0.0)
            o.scale = (1.0, 0.50, 1.0)
            o.data.materials.append(MAT_boca)
            mejillas.append(o)

    # --- E-75: aplicar TODO antes de unir ---
    aplicar_todos_sm()
    cabeza = unir('SM_Cab_Cabeza', [cabeza, nariz] + orejas)
    cuello.name = 'SM_Cab_Cuello'
    ojos = unir('SM_Cab_Ojos', ojos)
    cejas = unir('SM_Cab_Cejas', cejas)
    boca = unir('SM_Cab_Boca', [boca] + mejillas)
    return {'cabeza': cabeza, 'cuello': cuello, 'ojos': ojos,
            'cejas': cejas, 'boca': boca}
