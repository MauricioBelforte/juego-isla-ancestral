# crear_vestimenta_anciano_lowpoly.py — M19 · Túnica de anciano del templo
#
# Perfil: ANCIANO DEL TEMPLO (sabio ermitaño, consejero del Oráculo).
# Asset MONTADO (E-79): se AUTORA en cotas de mundo (z_ref_ropa = 0) y se
# renderea ENCIMA del cuerpo del NPC base. Cuando un NPC viste esta
# vestimenta, en Godot se ocultan los SM_NPC_RopaBase / SM_NPC_Torso del
# NPC base y se instancia este GLB como hijo del nodo raiz.
#
# Componentes:
#   1) Tunica  — lino crudo, A-line larga hasta la arena (1.250 -> 0.045)
#   2) Mangas  — lino, hasta la muñeca (1.150 -> 0.668)
#   3) Capucha — cogote del sabio, medio domo SOLO en la parte trasera
#   4) Cinturon — cuero, a la cintura (0.960) con hebilla plana delante
#   5) Hebilla — bronce plano (no cilindro, E-74)
#   6) Bolsa    — saquito colgando del cinturon al costado (E-73/E-74 safe)
#
# E-73/E-74: la bolsa cuelga de la CINTURA, no del pecho (costura correcta).
#   La hebilla es una caja PLANA contra el abdomen (no cilindro perpendicular).
# E-89: cada pieza declara contra que partes del cuerpo se audita.
# E-87: tapas OCULTO en tunica (cuello), mangas (hombro).
#
# Budget M166 ALTA: <=16 obj / <=6000 tris / <=12 mats. Esta: 7 SM_,
# 4 mats.

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from math import radians, pi, cos, sin
from mathutils import Vector, Matrix
import bpy, bmesh

from plantilla_asset import limpiar, mat, loft, caja, piezas, polilinea
from montado_util import (maniqui_cuerpo, verificar_ropa, marcar_montado,
                          iluminar, camara, shade_flat, auditar, guardar,
                          aplicar, unir, aplicar_todos_sm,
                          Z_REF_ROPA, BRAZOS, PIERNAS, dx, _interpolar,
                          ANILLOS_TORSO, marcar_ocultos)

escena = limpiar()

MATS = {
    'lino':   mat('MAT_Tun_Lino',   (0.55, 0.50, 0.40)),    # tunic, mangas
    'cuero':  mat('MAT_Tun_Cuero',  (0.32, 0.22, 0.14)),    # cinturon, bolsa
    'bronce': mat('MAT_Tun_Bronce', (0.62, 0.48, 0.22)),    # hebilla
    'hilo':   mat('MAT_Tun_Hilo',   (0.42, 0.36, 0.26)),    # cordon bolsa
}


def centro_de_tapa(punto, tol=0.010):
    """Predicado: el vertice es el CENTRO de la tapa de un tubo cerrado (E-87)."""
    p = Vector(punto)

    def _pred(w):
        return (w - p).length < tol
    return _pred


# ===========================================================================
# 1) TUNICA — lino A-line, del cuello a los pies
# ===========================================================================
ANILLOS_TUNICA = [
    (0.045, dx(0.045),  0.000, 0.300, 0.230),   # piso: amplia (suela)
    (0.250, dx(0.250),  0.000, 0.295, 0.225),
    (0.500, dx(0.500), -0.005, 0.275, 0.210),
    (0.700, dx(0.700), -0.005, 0.245, 0.190),
    (0.790, dx(0.790), -0.003, 0.232, 0.170),
    (0.880, dx(0.880), -0.008, 0.210, 0.158),
    (0.960, dx(0.960), -0.008, 0.186, 0.140),
    (1.050, dx(1.050), -0.003, 0.192, 0.142),
    (1.130, dx(1.130),  0.009, 0.230, 0.156),
    (1.150, dx(1.150),  0.011, 0.238, 0.156),
    (1.175, dx(1.175),  0.013, 0.242, 0.156),
    (1.200, dx(1.200),  0.010, 0.232, 0.154),
    (1.245, dx(1.245), -0.002, 0.160, 0.118),
    (1.275, dx(1.275), -0.008, 0.118, 0.094),
    (1.300, dx(1.300), -0.012, 0.092, 0.084),
]
tunica = loft('SM_Tun_Tunica', ANILLOS_TUNICA, MATS['lino'],
              lados=14, tapar_arriba=True, tapar_abajo=False)

# ===========================================================================
# 2) MANGAS — lino, hasta la muñeca (1.150 -> 0.668)
# ===========================================================================
def construir_mangas_largas(prefijo, ts, radios, mat_prenda, lados=8):
    """Mangas largas de la túnica: hombro -> muñeca, abiertas abajo."""
    hechas = []
    for lado in ('I', 'D'):
        pts = BRAZOS[lado]
        muestras = polilinea(pts, ts)
        anillos = [(muestras[i][2], muestras[i][0], muestras[i][1],
                    radios[i], radios[i]) for i in range(len(muestras))]
        anillos.reverse()
        hechas.append(loft(prefijo + '_Brazo_' + lado, anillos,
                           mat_prenda, lados=lados,
                           tapar_arriba=True, tapar_abajo=False))
    return hechas


mangas = construir_mangas_largas(
    'SM_Tun_Manga',
    (0.0, 0.5, 1.0),
    (0.094, 0.080, 0.072),
    MATS['lino'])

# ===========================================================================
# 3) CAPUCHA — cogote, medio domo SOLO en la parte trasera (apex -Y)
# ===========================================================================
def construir_capucha(nombre='SM_Tun_Capucha', material=None):
    """Casquete con base anillo completo (apoyo hombros) y tip solo atras.

    Apex del casquete en a = 3*pi/2 (atras, -Y). Niveles: bajo = anillo
    completo, arriba = arco cada vez mas pequeno centrado en el apex.
    Ningun vertice queda con y > 0.09 por encima de z=1.30 (regla E-79 b).
    """
    bm = bmesh.new()
    APEX = 3.0 * pi / 2.0
    cfg = [
        (1.205, 0.235, pi,             14),
        (1.260, 0.220, 2.0 * pi / 3,   12),
        (1.330, 0.190, pi / 2,         10),
        (1.395, 0.140, pi / 3,          8),
        (1.440, 0.095, pi / 4,          6),
    ]
    capas = []
    for (z, r, alpha, n) in cfg:
        capa = []
        if alpha >= pi:
            for i in range(n):
                a = 2.0 * pi * i / n
                capa.append(bm.verts.new((r * cos(a), r * sin(a), z)))
        else:
            for i in range(n):
                tfrac = i / (n - 1) if n > 1 else 0.0
                a = APEX - alpha + 2.0 * alpha * tfrac
                capa.append(bm.verts.new((r * cos(a), r * sin(a), z)))
        capas.append(capa)

    for k in range(len(capas) - 1):
        a, b = capas[k], capas[k + 1]
        n_comun = min(len(a), len(b))
        for i in range(n_comun - 1):
            bm.faces.new((a[i], a[i + 1], b[i + 1], b[i]))
        if len(b) < len(a):
            bm.faces.new((a[n_comun - 1], a[n_comun], b[-1], b[0]))

    # Tapa superior del último nivel: abanico al vertice central.
    v_c = bm.verts.new(
        (0.0,
         sum(v.co.y for v in capas[-1]) / len(capas[-1]),
         sum(v.co.z for v in capas[-1]) / len(capas[-1])))
    for i in range(len(capas[-1]) - 1):
        bm.faces.new((v_c, capas[-1][i], capas[-1][i + 1]))

    bm.normal_update()
    malla_b = bpy.data.meshes.new(nombre)
    bm.to_mesh(malla_b)
    bm.free()
    o = bpy.data.objects.new(nombre, malla_b)
    bpy.context.scene.collection.objects.link(o)
    o.data.materials.append(material)
    return o


capucha = construir_capucha('SM_Tun_Capucha', MATS['lino'])

# ===========================================================================
# 4) CINTURON — torus horizontal a la altura de la cintura de la tunic
# ===========================================================================
bpy.ops.mesh.primitive_torus_add(major_segments=14, minor_segments=6,
                                 major_radius=0.205, minor_radius=0.010,
                                 location=(dx(0.960), -0.005, 0.960))
cinturon = bpy.context.object
cinturon.name = 'SM_Tun_Cinturon'
cinturon.data.materials.append(MATS['cuero'])

# ===========================================================================
# 5) HEBILLA — caja plana delante del cinturon (+Y)
# ===========================================================================
hebilla = caja('SM_Tun_Hebilla', 0.0, 0.198, 0.960,
               0.050, 0.006, 0.035, MATS['bronce'])

# ===========================================================================
# 6) BOLSA — saquito colgando del cinturon al costado (-X, lado izq)
# ===========================================================================
def construir_bolsa(nombre='SM_Tun_Bolsa', material=None):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=8,
                              radius=0.055, matrix=Matrix.Identity(4),
                              calc_uvs=True)
    for v in bm.verts:
        v.co.y *= 1.15
        v.co.z *= 0.85
    bm.normal_update()
    malla = bpy.data.meshes.new(nombre)
    bm.to_mesh(malla)
    bm.free()
    o = bpy.data.objects.new(nombre, malla)
    o.location = (-0.250, -0.005, 0.870)
    bpy.context.scene.collection.objects.link(o)
    o.data.materials.append(material)
    return o


bolsa = construir_bolsa('SM_Tun_Bolsa', MATS['cuero'])

# Cordon que cuelga la bolsa del cinturon (pequeno cilindro fino, OBLICUO)
bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.004, depth=0.110,
                                     location=(-0.215, -0.005, 0.920))
cordon_bolsa = bpy.context.object
cordon_bolsa.name = 'SM_Tun_CordonBolsa'
cordon_bolsa.rotation_euler = (0.18, 0.0, 0.0)
cordon_bolsa.data.materials.append(MATS['hilo'])

# ===========================================================================
# CIERRE
# ===========================================================================
aplicar_todos_sm()

# E-87: tapas marcadas OCULTO
marcar_ocultos(tunica, centro_de_tapa((dx(1.300), -0.012, 1.300)))
marcar_ocultos(mangas[0], centro_de_tapa(BRAZOS['I'][0]))
marcar_ocultos(mangas[1], centro_de_tapa(BRAZOS['D'][0]))

# Mangas se unen para no disparar el presupuesto SM_
mangas = unir('SM_Tun_Mangas', mangas)

maniqui_cuerpo(escena)
bpy.context.view_layer.update()

# E-89: contra que partes del cuerpo se audita cada pieza
PARTES = {
    'SM_Tun_Tunica':       ('torso', 'deltoides'),
    'SM_Tun_Mangas':       ('brazos', 'deltoides'),
    'SM_Tun_Capucha':      ('torso',),
    'SM_Tun_Cinturon':     ('torso',),
    'SM_Tun_Hebilla':      ('torso',),
    'SM_Tun_Bolsa':        ('torso',),
    'SM_Tun_CordonBolsa':  ('torso',),
}
verificar_ropa(escena, partes=PARTES)

marcar_montado()
iluminar(escena)
camara(escena, 'CAM_ANCIANO', (1.40, 2.30, 1.10), (0.0, 0.0, 0.90))
shade_flat(escena)
auditar(escena)
guardar(escena, '19-NPCs', 'vestimenta_anciano')