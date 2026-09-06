# crear_npc_base_lowpoly.py — M19/161 · NPC base lowpoly (cuerpo modular sin ropa)
#
# DIRECTIVA DEL USUARIO (2026-09-02): "los diseños tienen que ser premium, en
# los npc no podemos escatimar da tu mejor esfuerzo, mejor pocos pero buenos npc".
# Este es el PRIMER asset de esa tanda y es el mas dificil del backlog: es la
# base sobre la que se montan cabeza/ropa/poses. Si la base es mala, todo lo
# demas hereda el defecto.
#
# ---------------------------------------------------------------------------
# QUE HACE "PREMIUM" A ESTE CUERPO (y que NO se hizo)
# ---------------------------------------------------------------------------
# NO se apilaron cajas. Un torso de caja tiene los hombros tan anchos como la
# cintura: lee como mueble, no como persona. Todo el cuerpo son LOFTS (anillos
# elipticos apilados, helper plantilla_asset.loft()) que permiten:
#   * AFINAR: cadera 0.192 -> cintura 0.156 -> pecho 0.196 -> hombro 0.202
#     (semi-ejes X). La cintura mas angosta que cadera y pecho es la senal
#     anatomica numero 1 de "cuerpo".
#   * CURVAR: pecho adelantado (cy +0.006), cintura atras (cy -0.004) = la S
#     natural de la columna vista de perfil.
#   * CONTRAPPOSTO: el tronco se inclina 2 grados hacia la pierna que carga el
#     peso (funcion dx()). Una figura perfectamente simetrica y vertical lee
#     como maniqui; 2 grados mas un hombro 1.2 cm mas bajo que el otro leen
#     como alguien parado.
#   * MANDIBULA: la cabeza NO es un elipsoide puro. Los vertices bajos se
#     adelantan (menton) y se afinan en X (vease el bloque de deformacion).
#
# E-73 / E-74 (del espantapajaros, aplicados DESDE EL DISEÑO, no como parche):
#   Ninguna pieza horizontal cruza el torso. Nada sobresale perpendicular del
#   pecho. Los brazos salen de los hombros (x=+-0.152, por DENTRO del borde
#   x=0.202) y caen hacia abajo y apenas afuera. La paja/relleno NO va al pecho.
#
# E-24/E-50: apoyo medido en vertices reales, huella validada.
# E-70: 14 SM_ (tope ALTA 16). Se llega a 14 uniendo piezas (join).
# E-75 (NUEVO, ver abajo): antes de join() HAY QUE aplicar transformadas.
#
# ---------------------------------------------------------------------------
# PROPORCIONES — altura total 1.62 m ≈ 5.2 cabezas
# (estilizado "cozy": no bebe de 3 cabezas, no realista de 7.5)
# ---------------------------------------------------------------------------
#   z=0.045 suela · 0.115 tobillo · 0.420 rodilla · 0.730 entrepierna
#   0.880 cresta iliaca · 0.960 cintura · 1.110 pecho · 1.205 hombro
#   1.245 trapecio · 1.290 base cuello · 1.440 centro cabeza · 1.612 cima pelo
#
# Convencion de orientacion: la CARA mira a +Y (igual que el espantapajaros
# M33: ojos y boca en y=+0.115).
#
# v5 (2026-09-02): tras feedback "de la cabeza para arriba esta muy bien
# pero el diseño de los hombros para abajo esta raro el torso mejoralo", se
# reescribio seccion 3 (torso), 7 (brazos), 9 (piernas), 10 (ropa base).
# La cabeza, ojos, cejas, boca y pelo (secciones 4, 5, 6) NO se tocaron —
# estaban aprobadas.

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from math import radians, tan, sin, cos, pi
from mathutils import Vector
import bpy, bmesh

from plantilla_asset import (limpiar, mat, caja, loft, polilinea, arena,
                             iluminar, zmin_real, piezas, asentar, camara,
                             shade_flat, guardar)

# ===========================================================================
# 0) Escena y materiales
# ===========================================================================
escena = limpiar()

# Paleta corta y armonica (6 materiales, tope ALTA 12).
MAT_piel    = mat('MAT_NPC_Piel',    (0.82, 0.66, 0.52))   # arena calida
MAT_cabello = mat('MAT_NPC_Cabello', (0.29, 0.21, 0.15))   # castano oscuro
MAT_ojos    = mat('MAT_NPC_Ojos',    (0.14, 0.11, 0.09))   # casi negro
MAT_boca    = mat('MAT_NPC_Boca',    (0.55, 0.33, 0.31))   # rosa apagado
MAT_ropa    = mat('MAT_NPC_Ropa',    (0.90, 0.86, 0.75))   # lino crema
MAT_botas   = mat('MAT_NPC_Botas',   (0.42, 0.29, 0.18))   # cuero

# ===========================================================================
# 1) Contrapposto — el tronco se inclina hacia la pierna que carga el peso
# ===========================================================================
Z_PIVOTE = 0.780          # la inclinacion nace en la cadera
INCLINA = radians(2.0)    # 2 grados: sutil. Mas de 3 ya parece caido.
TAN_INC = tan(INCLINA)


def dx(z):
    """Desplazamiento en X del eje del cuerpo a la altura z (contrapposto).

    Negativo = hacia -X. El peso va en la pierna IZQUIERDA (-X), asi que el
    tronco se inclina hacia -X y el hombro izquierdo queda MAS BAJO que el
    derecho. Eso es contrapposto honesto, no asimetria al azar.
    """
    return -(z - Z_PIVOTE) * TAN_INC


# ===========================================================================
# 2) E-75 — APLICAR TRANSFORMADAS ANTES DE JOIN
# ===========================================================================
# bpy.ops.object.join() funde las mallas pasando cada vertice por
#     active.matrix_world.inverted() @ obj.matrix_world
# Si el activo tiene escala NO uniforme (ej. la cabeza: 0.130 x 0.118 x 0.155),
# las piezas que se le unen quedan deformadas por el inverso de esa escala:
# un cono de la nariz hecho a escala 1 se multiplicaria por (7.7, 8.5, 6.5).
# El resultado es una masa irreconocible y SILENCIOSA (sin error en consola).
# REGLA: aplicar(location, rotation, scale) en TODAS las piezas antes de unir.
def aplicar(o):
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return o


def unir(nombre, objetos):
    """Join + dedupe de slots de material (join puede duplicarlos).

    E-76 + E-35 + E-83: en Blender 4.x `IDMaterials.pop(update_data=)` ya no
    existe (TypeError), asi que la deduplicacion se hace con `clear()`.
    PERO `clear()` resetea a 0 el `material_index` de TODAS las caras (E-35):
    la pieza termina renderizada con UN solo material aunque tenga N slots.

    Caso real (E-83, 2026-09-03): `SM_NPC_RopaBase` (short de lino + cinturon
    de cuero) se exportaba con 2 slots y las 120 caras en el slot 0 — o sea,
    el cinturon se veia de LINO. El bug paso desapercibido porque la auditoria
    del generador solo imprimia SM_ y triangulos.

    Forma correcta: respaldar los indices de cara ANTES del clear() y
    reasignarlos DESPUES, pasandolos por el mapa slot-viejo -> slot-nuevo.
    Ademas, solo se tocan los slots si realmente hay duplicados (E-35: "solo
    tocar si difieren").
    """
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

    if len(vistos) != len(o.data.materials):      # hay algo que deduplicar
        idx_caras = [p.material_index for p in o.data.polygons]
        o.data.materials.clear()
        for m in vistos:
            o.data.materials.append(m)
        for p, mi in zip(o.data.polygons, idx_caras):
            p.material_index = mapa[mi] if mi < len(mapa) else 0
    return o


# ===========================================================================
# 3) TORSO — loft de 12 anillos, 12 lados + 2 caps de deltoides
# ===========================================================================
# v5 (2026-09-02, feedback del usuario "de los hombros para abajo esta raro
# el torso mejoralo"): la v4 tenia DOS problemas visibles que la fotografia
# orbital evidencio:
#   1) SIN CAP DE HOMBROS. La linea de hombro (rx 0.202) apenas superaba al
#      pecho (0.196) y colapsaba a 0.112 en 5.5 cm. El deltoide humano es una
#      capsula que sobresale 4-5 cm de cada lado del torax. Sin el, los
#      hombros leen como un cierre de perchero, no como un cuerpo.
#   2) PECHO PLANO. Los ry estaban en 0.100-0.124, dando un torax de tablero
#      (ratio ancho:profundo 1.74:1). Un torso humano real es ~1.4:1. La
#      silueta de perfil (az 180) era una tabla.
#
# Solucion:
#   A) Anillos MAS PROFUNDOS en el pecho (ry 0.118 -> 0.132).
#   B) DELTOIDES como elipsoides (ico sphere subdiv=2 deformada) a ambos
#      lados, en el anillo del hombro. Protruyen ~3.4 cm del torax.
#      Asimetricos en Z: der z=1.175, izq z=1.158 → hombro derecho MAS ALTO,
#      que es la lectura natural del contrapposto.
#   C) Trapecio mas largo (1.205 → 1.245 → 1.290): 8.5 cm de pendiente en
#      vez de 5.5 cm → menos cono, mas rampa.
#   D) Cuello metido hacia atras (cy -0.013 vs -0.004) → el cuello se ve,
#      no se funde con el pecho.
ANILLOS_TORSO = [
    (0.720, dx(0.720),  0.000, 0.176, 0.118),   # borde inf. (bajo el short)
    (0.790, dx(0.790), -0.002, 0.194, 0.128),   # cadera — ANCHA y con algo de fondo
    (0.880, dx(0.880), -0.006, 0.170, 0.118),   # cresta iliaca
    (0.960, dx(0.960), -0.008, 0.151, 0.108),   # CINTURA (la mas angosta)
    (1.040, dx(1.040), -0.002, 0.161, 0.118),   # arranca la caja toracica
    (1.110, dx(1.110),  0.008, 0.183, 0.128),   # pecho — adelantado
    (1.165, dx(1.165),  0.012, 0.192, 0.132),   # pecho alto (el + ancho del tronco)
    (1.205, dx(1.205),  0.008, 0.186, 0.128),   # linea de hombros
    (1.245, dx(1.245), -0.002, 0.132, 0.092),   # trapecio
    (1.290, dx(1.290), -0.012, 0.064, 0.058),   # sube al cuello
    (1.340, dx(1.340), -0.013, 0.052, 0.050),   # base cuello (entra en cabeza)
    (1.400, dx(1.400), -0.013, 0.048, 0.046),   # cuello alto
]
# Sin tapa inferior: queda dentro del short, y una tapa ahi se veria como un
# disco desde abajo. Sin tapa tambien evita 12 triangulos.
torso = loft('SM_NPC_Torso', ANILLOS_TORSO, MAT_piel, lados=12,
             tapar_arriba=True, tapar_abajo=False)

# --- 3b) DELTOIDES (caps de hombro) ---
# Cada deltoide: ico-esfera subdiv=2 (320 caras), centrada en
# (dx(z) +- 0.140, 0.006, z), radios (0.084, 0.070, 0.052). Protruye ~3.4 cm
# del borde del torax y queda ENTERRADO en el torax por la cara interna
# (loft + cap = geometria solida).
#
# La asimetria en Z (der z=1.175, izq z=1.158) es el detalle de contrapposto
# que faltaba en v4: el hombro del lado que CARGA peso queda mas bajo.
# Calculo de conectividad verificado en papel: a la altura del polo superior
# del deltoide (1.175+0.052=1.227 der), el borde derecho del torax esta a
# x=0.144 y el punto del deltoide a x=0.126 → el deltoide esta DENTRO.
deltoides = []
for sx, zc in ((+1, 1.175), (-1, 1.158)):
    cx = dx(zc) + sx * 0.140
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0,
                                          location=(cx, 0.006, zc))
    d = bpy.context.object
    d.name = 'SM_NPC_Deltoide_%s' % ('D' if sx > 0 else 'I')
    d.scale = (0.084, 0.070, 0.052)
    d.data.materials.append(MAT_piel)
    deltoides.append(d)

# ===========================================================================
# 4) CABEZA — elipsoide deformado (menton + mandibula), NO esfera pura
# ===========================================================================
Z_CABEZA = 1.440
X_CABEZA = dx(Z_CABEZA)          # -0.023: la cabeza sigue la inclinacion
Y_CABEZA = -0.006
R_CABEZA = (0.132, 0.118, 0.160)  # v2: 0.264 x 0.320 m (ratio 1.21 — huevo
                                  # vertical). v1 era 0.130/0.155 y quedaba
                                  # cuadrada como muneco.

bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0,
                                      location=(0, 0, 0))
cabeza = bpy.context.object
cabeza.name = 'SM_NPC_Cabeza'

# Deformacion en espacio unitario (ANTES de aplicar la escala).
# Una esfera pura no tiene "cara": el craneo y la mandibula son el mismo
# elipsoide. Adelantar el menton y afinar la mandibula es lo que hace que
# la silueta de perfil lea como cabeza humana y no como pelota.
bm = bmesh.new()
bm.from_mesh(cabeza.data)
for v in bm.verts:
    if v.co.z < -0.35:                       # tercio inferior = mandibula
        f = min(1.0, (-0.35 - v.co.z) / 0.65)
        v.co.y += 0.13 * f                   # menton adelantado (+1.5 cm)
        v.co.x *= 1.0 - 0.18 * f             # mandibula mas angosta
        v.co.z *= 1.0 - 0.06 * f             # cara mas plana abajo
    if v.co.y < -0.55:                       # nuca apenas aplanada
        v.co.y *= 0.97
bm.to_mesh(cabeza.data)
bm.free()
cabeza.data.update()
cabeza.scale = R_CABEZA
cabeza.location = (X_CABEZA, Y_CABEZA, Z_CABEZA)
cabeza.data.materials.append(MAT_piel)

# --- 4b) Nariz: cono de 5 lados apuntando adelante y apenas abajo ---
# E-58: Vector(dir).to_track_quat('Z','Y').to_euler() para alinear el cono
# (su eje nativo es +Z) con la direccion deseada.
DIR_NARIZ = Vector((0.0, 0.95, -0.31))
H_NARIZ = 0.032
BASE_NARIZ = (X_CABEZA, 0.092, 1.412)
bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=0.024, radius2=0.0,
                                depth=H_NARIZ,
                                location=tuple(
                                    BASE_NARIZ[k] + DIR_NARIZ[k] * H_NARIZ / 2.0
                                    for k in range(3)))
nariz = bpy.context.object
nariz.rotation_euler = DIR_NARIZ.to_track_quat('Z', 'Y').to_euler()
nariz.data.materials.append(MAT_piel)

# --- 4c) Orejas: discos de 6 lados, eje en X ---
# Van en x = X_CABEZA +- 0.132. El craneo a la altura z=1.375 mide 0.121 de
# semi-eje, asi que asoman 2.4 cm — suficiente para que el pelo no las tape.
orejas = []
for sx in (-1, +1):
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.026, depth=0.026,
                                        location=(X_CABEZA + sx * 0.132,
                                                  -0.016, 1.375))
    o = bpy.context.object
    o.rotation_euler = (0.0, radians(90.0), 0.0)   # eje +Z -> +X
    o.scale = (1.0, 0.577, 1.0)                    # mundo: Z 0.052, Y 0.030
    o.data.materials.append(MAT_piel)
    orejas.append(o)

# ===========================================================================
# 5) CABELLO — loft de 5 anillos. v2: frente mas retraido (cy -0.020, era
#    -0.012) para que la frente se vea y los ojos/cejas no queden "tapados"
#    por el borde inferior del pelo. Tambien subo el anillo 0 a z=1.380.
# ===========================================================================
# ===========================================================================
# 5) CABELLO — v4: casquete PEQUEÑO (cubre solo el 1/3 superior de la
#    cabeza) y recedido hacia atras (cy muy negativo). v3 tenia un "casco"
#    que tapaba ojos y frente, por eso la cara se veia aplastada en el
#    tercio inferior. La frente ahora queda COMPLETAMENTE expuesta.
#    Anillos: 4 (antes 5).
# ===========================================================================
# Verificacion geometrica del ring 0 (z=1.490):
#   frente de la cabeza: y = -0.006 + 0.118*sqrt(1-((1.490-1.44)/0.160)^2)
#                            = 0.108
#   frente del pelo:    y = -0.040 + 0.090 = 0.050
#   -> el pelo esta 5.8 cm DETRAS de la frente.  Exponente = OK.
#   costado de la cabeza: x = 0.128
#   costado del pelo:    x = 0.140
#   -> el pelo sobresale 1.2 cm del lado.          Exponente = OK.
#   nuca del pelo:       y = -0.040 - 0.090 = -0.130
#   nuca de la cabeza:   y = -0.120
#   -> el pelo sobresale 1.0 cm de la nuca.        Exponente = OK.
ANILLOS_PELO = [
    (1.490, X_CABEZA, -0.040, 0.140, 0.090),
    (1.540, X_CABEZA, -0.030, 0.148, 0.110),
    (1.580, X_CABEZA, -0.020, 0.108, 0.092),
    (1.612, X_CABEZA, -0.010, 0.040, 0.034),
]
cabello = loft('SM_NPC_Cabello', ANILLOS_PELO, MAT_cabello, lados=12)

# ===========================================================================
# 6) OJOS, CEJAS, BOCA, MECHONES — v2 mas grandes, con colorete. Lo que
#    convierte un muneco en una persona (no exagero: la mitad de "calidad"
#    en un NPC chibi son los ojos y la boca que se LEAN de lejos).
# ===========================================================================
# --- Ojos: disco de 6 lados, eje en +Y. v4: z=1.445 (v3 1.455 estaba justo
# en el borde inferior del pelo y se veia aplastado; lo bajo 1 cm). ---
ojos = []
for sx in (-1, +1):
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.032, depth=0.020,
                                        location=(X_CABEZA + sx * 0.050,
                                                  0.108, 1.445))
    o = bpy.context.object
    o.rotation_euler = (radians(-90.0), 0.0, 0.0)   # eje +Z -> +Y
    o.scale = (1.0, 0.50, 1.0)                      # mundo: X 0.064, Z 0.032
    o.data.materials.append(MAT_ojos)
    ojos.append(o)

# --- Cejas: v4 a z=1.485 (v3 1.518) para asomarse justo bajo el pelo. ---
cejas = []
for sx in (-1, +1):
    cejas.append(caja('SM_NPC_Ceja_%d' % (0 if sx < 0 else 1),
                      X_CABEZA + sx * 0.052, 0.094, 1.485,
                      0.066, 0.014, 0.018, MAT_cabello,
                      rot_euler=(0.0, sx * radians(10.0), 0.0)))

# --- Boca: v4 a z=1.395 (v3 1.400) — centrada entre ojos y menton. ---
boca = caja('SM_NPC_Boca', X_CABEZA, 0.110, 1.395,
            0.062, 0.016, 0.018, MAT_boca)

# --- Colorete: v4 a z=1.415 (acompanar a ojos nuevos). ---
mejillas = []
for sx in (-1, +1):
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.015, depth=0.006,
                                        location=(X_CABEZA + sx * 0.082,
                                                  0.088, 1.415))
    o = bpy.context.object
    o.rotation_euler = (radians(-90.0), 0.0, 0.0)
    o.scale = (1.0, 0.50, 1.0)
    o.data.materials.append(MAT_boca)
    mejillas.append(o)

# ===========================================================================
# 7) BRAZOS — polilinea hombro -> codo -> muñeca, loft de 5 anillos
# ===========================================================================
# E-73: salen DEL HOMBRO (dentro del cap deltoide) y CAEN. Nada cruza el
# pecho. v5: el hombro del brazo parte del CENTRO del deltoide (der 0.126,
# izq -0.153), no de la superficie del torax — asi el brazo emerge del
# deltoide, no de un costado sin forma.
# El izquierdo (el lado que carga peso, contrapposto) cuelga MAS BAJO y MAS
# RECTO; el derecho se abre y adelanta apenas mas (relajado).
BRAZOS = {
    #            hombro                       codo                        muñeca
    'I': [(-0.153, 0.004, 1.150), (-0.180, 0.000, 0.905), (-0.212, 0.008, 0.668)],
    'D': [( 0.126, 0.012, 1.168), ( 0.164, 0.016, 0.918), ( 0.214, 0.030, 0.686)],
}
TS_BRAZO = (0.0, 0.26, 0.53, 0.78, 1.0)         # hombro -> muñeca
# v5: 0.066 -> 0.040 (v3 era 0.062 -> 0.040). Hombro con mas sustancia para
# anclar el brazo al deltoide.
R_BRAZO = (0.066, 0.056, 0.050, 0.044, 0.040)


def loft_polilinea(nombre, pts, ts, radios, material, lados):
    """Loft siguiendo una polilinea. Devuelve el objeto (anillos ABAJO->ARRIBA).

    E-77: el anillo de loft() es (z, cx, cy, rx, ry) — Z PRIMERO. La polilinea
    devuelve (x, y, z), asi que hay que reordenar al armar el anillo. Si se
    pasa (x, y, z, ...) la malla nace deformada SIN tirar error.
    """
    muestras = polilinea(pts, ts)
    anillos = [(muestras[i][2], muestras[i][0], muestras[i][1],
                radios[i], radios[i])
               for i in range(len(muestras))]
    anillos.reverse()      # muñeca (abajo) -> hombro (arriba)
    return loft(nombre, anillos, material, lados=lados,
                tapar_arriba=True, tapar_abajo=True)


brazos = {}
for lado, pts in BRAZOS.items():
    brazos[lado] = loft_polilinea('SM_NPC_Brazo_' + lado, pts, TS_BRAZO,
                                  R_BRAZO, MAT_piel, lados=8)

# ===========================================================================
# 8) MANOS — icosaedro + pulgar (unidos en una sola pieza)
# ===========================================================================
# Una mano que es solo un elipsoide lee como guante de dibujo animado; el
# pulgar le da "garra" a la silueta y cuesta 6 triangulos.
manos = {}
for lado, w in (('I', BRAZOS['I'][2]), ('D', BRAZOS['D'][2])):
    sx = -1.0 if lado == 'I' else 1.0
    centro = (w[0], w[1] + 0.008, w[2] - 0.050)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0,
                                          location=centro)
    palma = bpy.context.object
    palma.scale = (0.0375, 0.025, 0.065)      # 0.075 x 0.050 x 0.130 m
    palma.rotation_euler = (radians(8.0), 0.0, sx * radians(6.0))
    palma.data.materials.append(MAT_piel)

    # Pulgar: cono apuntando adelante-adentro.
    d = Vector((-sx * 0.45, 0.85, 0.28)).normalized()
    H_PULGAR = 0.040
    base = (centro[0] + sx * 0.022, centro[1] + 0.004, centro[2] + 0.012)
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.015, radius2=0.0,
                                    depth=H_PULGAR,
                                    location=tuple(
                                        base[k] + d[k] * H_PULGAR / 2.0
                                        for k in range(3)))
    pulgar = bpy.context.object
    pulgar.rotation_euler = d.to_track_quat('Z', 'Y').to_euler()
    pulgar.data.materials.append(MAT_piel)

    aplicar(palma)
    aplicar(pulgar)
    manos[lado] = unir('SM_NPC_Mano_' + lado, [palma, pulgar])

# ===========================================================================
# 9) PIERNAS — loft de 5 anillos, lados=10
# ===========================================================================
# Separacion +-0.098 en el tobillo: es lo que hace falta para que la huella
# pase el guard E-50 (min 0.30 m) sin tener que abrir las piernas como
# jinete. Ver el comentario de la huella al final.
# v5: el anillo superior SUBIO de z=0.770 a z=0.800 para que la pierna llene
# el interior del short (antes entre 0.685 y 0.770 el short era un tubo
# vacio: se veia el back-wall del short desde abajo con nada dentro).
PIERNAS = {
    'I': [(-0.102, -0.004, 0.800), (-0.101, -0.002, 0.560),
          (-0.100,  0.004, 0.420), (-0.100,  0.008, 0.240),
          (-0.100,  0.012, 0.100)],
    'D': [( 0.102,  0.014, 0.800), ( 0.103,  0.026, 0.560),
          ( 0.100,  0.038, 0.420), ( 0.100,  0.046, 0.240),
          ( 0.100,  0.052, 0.100)],
}
R_PIERNA = (0.090, 0.080, 0.068, 0.056, 0.046)   # cadera -> tobillo

piernas = {}
for lado, pts in PIERNAS.items():
    # E-77: (z, cx, cy, rx, ry) — Z primero, no (x, y, z, ...).
    anillos = [(p[2], p[0], p[1], R_PIERNA[i], R_PIERNA[i])
               for i, p in enumerate(pts)]
    anillos.reverse()                             # tobillo -> cadera
    piernas[lado] = loft('SM_NPC_Pierna_' + lado, anillos, MAT_piel, lados=10)

# ===========================================================================
# 10) PIES — loft de 8 anillos EN Y (se construye en Z y se rota -90 en X)
# ===========================================================================
# Se construyen a lo largo de Z y se rotan: rotacion -90 en X manda el eje
# local +Z a +Y (largo del pie hacia adelante) y el local +Y a -Z (alto).
# La suela es PLANA en 4 anillos (ry constante 0.036) para que haya vertices
# suficientes tocando el piso y pase el guard E-50 (min 8 verts).
ANILLOS_PIE = [
    (-0.130, 0.038, 0.026),   # talon
    (-0.108, 0.048, 0.034),
    (-0.075, 0.053, 0.036),   # -- suela plana
    (-0.030, 0.054, 0.036),   # -- suela plana
    ( 0.015, 0.054, 0.036),   # -- suela plana
    ( 0.060, 0.052, 0.035),
    ( 0.100, 0.045, 0.030),
    ( 0.130, 0.028, 0.020),   # punta
]
# Separacion +-0.100 y desfase de 5 cm entre pie atras y pie adelante: es lo
# que hace falta para que la huella pase el guard E-50 (min 0.30 m) sin tener
# que abrir las piernas como jinete. Postura natural de "alguien parado".
PIES = {'I': (-0.100, 0.045), 'D': (0.100, 0.095)}   # (x, y_centro)
Z_PIE = 0.082                                        # 0.046 .. 0.118

pies = []
for lado, (px, py) in PIES.items():
    anillos = [(a[0], 0.0, 0.0, a[1], a[2]) for a in ANILLOS_PIE]
    p = loft('SM_NPC_Pie_' + lado, anillos, MAT_botas, lados=8)
    p.rotation_euler = (radians(-90.0), 0.0, 0.0)
    p.location = (px, py, Z_PIE)
    pies.append(p)

# --- Suelas planas ---
# E-78: la huella de E-50 se mide sobre los VERTICES que tocan el piso. En un
# pie loftado con anillos elipticos, el vertice mas bajo de cada anillo esta en
# el CENTRO del anillo (x local = 0), no en su borde. Resultado: la huella
# media la linea media del pie (0.20 x 0.22 en el primer intento) y NO el ancho
# real, y el guard falla aunque el personaje este perfectamente apoyado.
# La solucion no es ensanchar la postura (quedaria patizambo) ni relajar el
# guard: es darle al pie una SUELA PLANA, que ademas es mejor modelado. Una
# caja aporta 4 vertices en las esquinas -> ahi si se mide el ancho real.
# Huella resultante: x de -0.156 a +0.156 = 0.312 · y de -0.081 a +0.221 = 0.302
SUELA = (0.112, 0.252, 0.016)   # ancho X, largo Y, alto Z
suelas = []
for lado, (px, py) in PIES.items():
    suelas.append(caja('SM_NPC_Suela_' + lado, px, py, 0.053,
                       SUELA[0], SUELA[1], SUELA[2], MAT_botas))

# ===========================================================================
# 11) ROPA BASE — short de lino A-line + cinturon de cuero. Presentable y
#     deja el torso libre para que los modulos de ropa (campesina / pescador
#     / tunica) monten encima.
# ===========================================================================
# v5: la v4 era un tubo recto (0.204 -> 0.206 -> 0.188 -> 0.166) que leia
# como un cilindro PEGADO a las piernas, sin forma de prenda. v5 es un
# A-LINE real: ruedo ancho, se angosta hacia la cintura, con cinturon de
# cuero encima. Clearance minimo vs el torso: 1.5 cm (z-fight).
ANILLOS_SHORT = [
    (0.685, dx(0.685),  0.000, 0.224, 0.152),   # ruedo (dobladillo)
    (0.745, dx(0.745), -0.001, 0.216, 0.147),
    (0.820, dx(0.820), -0.003, 0.206, 0.140),
    (0.890, dx(0.890), -0.005, 0.186, 0.128),
    (0.940, dx(0.940), -0.006, 0.172, 0.120),
    (0.968, dx(0.968), -0.007, 0.167, 0.117),   # cintura (con tapa arriba)
]
# Sin tapa inferior: el short es un tubo abierto por donde salen las piernas,
# y la tapa arriba cierra la cintura.
short = loft('SM_NPC_RopaBase', ANILLOS_SHORT, MAT_ropa, lados=12,
             tapar_arriba=True, tapar_abajo=False)

# --- 11b) CINTURON de cuero (anillo fino sobre el short) ---
# Anillos 3, lados=12. Protruye ~0.9 cm del short → se VE como un cinturon
# independiente, no como costura. Material: MAT_botas (cuero). Se une al
# short → SM_NPC_RopaBase tendra 2 materiales (E-42: caras USADAS, slots
# solo).
ANILLOS_CINTO = [
    (0.918, dx(0.918), -0.006, 0.186, 0.130),
    (0.940, dx(0.940), -0.007, 0.182, 0.127),
    (0.962, dx(0.962), -0.007, 0.178, 0.124),
]
cinturon = loft('SM_NPC_Cinturon', ANILLOS_CINTO, MAT_botas, lados=12,
                tapar_arriba=True, tapar_abajo=True)

# ===========================================================================
# 12) E-75 — aplicar transformadas y unir las piezas repetidas
# ===========================================================================
# v5: el orden es importante. aplicar() primero sobre TODOS los SM_, luego
# unir. Si se uniera antes de aplicar, los deltoides (escala no uniforme
# 0.084 x 0.070 x 0.052) deformarian los vertices al ser absorbidos por el
# torso (escala 1) — E-75.
for o in list(bpy.context.scene.objects):
    if o.type == 'MESH' and o.name.startswith('SM_'):
        aplicar(o)

torso = unir('SM_NPC_Torso', [torso] + deltoides)
cabeza = unir('SM_NPC_Cabeza', [cabeza, nariz] + orejas)
ojos = unir('SM_NPC_Ojos', ojos)
cejas = unir('SM_NPC_Cejas', cejas)
pies = unir('SM_NPC_Pies', pies + suelas)
boca = unir('SM_NPC_Boca', [boca] + mejillas)
short = unir('SM_NPC_RopaBase', [short, cinturon])

# ===========================================================================
# 13) Cierre canonico de la plantilla
# ===========================================================================
bpy.context.view_layer.update()
print('Z_MIN: %.4f  Z_MAX: %.4f  PIEZAS: %d'
      % (min(zmin_real(o) for o in piezas(escena)),
         max(zmin_real(o) for o in piezas(escena)),
         len(piezas(escena))))

arena(radio=1.6)
iluminar(escena)
# Huella: los pies van a x=+-0.098 con semi-ancho 0.054 -> 0.304 m en X, y
# de -0.090 a +0.220 -> 0.310 m en Y. Ambos pasan el minimo de 0.30 de E-50
# sin postura de jinete. Suela plana en 4 anillos -> 5 verts por pie = 10.
asentar(escena)
camara(escena, 'CAM_NPC', (1.35, 2.30, 1.15), (X_CABEZA, 0.0, 0.85))
shade_flat(escena)

# --- Auditoria en linea (E-33/E-40: triangulos REALES, no caras) ---
n_tris = 0
for o in piezas(escena):
    o.data.calc_loop_triangles()
    n_tris += len(o.data.loop_triangles)
print('SM_: %d · TRIS: %d' % (len(piezas(escena)), n_tris))
print('CABEZA: x=%.3f  PIES: %s' % (X_CABEZA, [p.name for p in piezas(escena)
                                               if p.name.startswith('SM_NPC_Pie')]))

# --- Auditoria SILUETA numerica (v5) ---
# Vision por imagen esta BLOQUEADA en este modelo. Para verificar sin ojos,
# muestreo el ancho en X y la profundidad en Y del torso+deltoides a 6
# alturas clave, usando vertices REALES (E-24). Esto complementa la captura
# orbital: si los numeros no cuadran, regenero; si cuadran, queda vision
# pendiente de confirmar con la captura.
def silueta(objetos, z, eje='x'):
    """Retorna (min, max) del eje pedido entre los vertices con z en +-0.01."""
    vals = []
    for o in objetos:
        if o.type != 'MESH':
            continue
        for v in o.data.vertices:
            if abs((o.matrix_world @ v.co).z - z) <= 0.012:
                vals.append((o.matrix_world @ v.co).x if eje == 'x'
                            else (o.matrix_world @ v.co).y)
    return (min(vals), max(vals)) if vals else (None, None)


print('--- AUDITORIA DE SILUETA (en metros) ---')
nombres = [p.name for p in piezas(escena)]
cuerpo = [bpy.data.objects[n] for n in nombres
          if any(n.startswith(s) for s in ('SM_NPC_Torso', 'SM_NPC_Deltoide'))]
for z, etq in [(0.790, 'cadera'), (0.960, 'cintura'), (1.110, 'pecho'),
               (1.165, 'pecho alto'), (1.205, 'hombro'),
               (1.175, 'deltoide D')]:
    xs = silueta(cuerpo, z, 'x')
    if xs[0] is None:
        print('  z=%.3f (%s): sin verts' % (z, etq))
        continue
    ancho = xs[1] - xs[0]
    prof = silueta(cuerpo, z, 'y')
    p = (prof[1] - prof[0]) if prof[0] is not None else 0.0
    print('  z=%.3f (%s): ancho=%.3f  profundidad=%.3f  ratio=%.2f'
          % (z, etq, ancho, p, ancho / p if p > 0 else 0.0))

print('FIN AUDITORIA')

guardar(escena, '19-NPCs', 'npc_base')
