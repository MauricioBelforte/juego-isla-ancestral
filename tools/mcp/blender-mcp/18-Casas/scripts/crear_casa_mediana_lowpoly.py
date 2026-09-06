# crear_casa_mediana_lowpoly.py — CASA MEDIANA GRANDE HABITABLE (M18-BIS)
# Checklist M18-BIS: "Casa mediana 2 ambientes" — directiva del usuario
# 2026-09-05: casas GRANDES que se puedan ENTRAR DENTRO, amplias,
# proporcionales al NPC M19 (1.75 m), con muebles propios dentro.
#
# DIMENSIONES: 8.0 (X) x 6.0 (Y) exterior, muros 2.60 alto, techo a 2 aguas
# hasta z 3.745. Interior 7.68 x 5.68 = 43.7 m2. DOS ambientes:
#   - DORMITORIO (oeste): 4.68 x 5.68 m — cama, velador+farol, comoda, cofre
#   - SALA/COCINA (este): 2.68 x 5.68 m — mesa + 2 sillas, estufa lena,
#     nevera rustica (pozo de piedra, M147: sin electricidad), estanteria,
#     alfombra
#
# ESCALA NPC (M19 v5 = 1.75 m): puerta principal 1.00x2.10 (vano real,
# hoja abierta 35 grados — se VE que se entra), puerta interior 0.90x2.10,
# techo interior 2.60, cama 2.00x0.90, mesa 0.80 alto, silla asiento 0.45.
#
# NOMBRES por sub-grupo (para que Godot pueda ocultar el techo al entrar
# y encontrar muebles interactivos):
#   SM_Techo_* (grupo ocultable) · SM_Mueble_* (interactivos RF7)
#   SM_Zocalo/Piso/Muro_F/Muro_B/Muro_L/Muro_R/Divisoria (estructura)
#
# Presupuesto: CASA GRANDE — documentado en plan-actual §6.1 que excede el
# tope 16 SM_ de asset individual (sub-grupos por habitacion). Stats al final.
#
# Asentado: z_min = 0.045 del GRUPO medido sobre VERTICES REALES (E-24).
# Ejecutar: blender -b --python crear_casa_mediana_lowpoly.py (headless OK)
import bpy
import math
from mathutils import Vector

# ============ 1) Limpieza ============
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ============ 2) Materiales ============
def crear_mat(nombre, color, rough=0.88, alpha=1.0, emis=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    if alpha < 1.0:
        bsdf.inputs['Alpha'].default_value = alpha
        m.blend_method = 'BLEND'
        m.use_backface_culling = False
    if emis > 0.0:
        bsdf.inputs['Emission Color'].default_value = (*color, 1.0)
        bsdf.inputs['Emission Strength'].default_value = emis
    return m

MAT_madera_clara = crear_mat('MAT_Casa_Madera_Clara',  (0.62, 0.47, 0.30))
MAT_madera_oscura = crear_mat('MAT_Casa_Madera_Oscura', (0.40, 0.28, 0.16))
MAT_piedra        = crear_mat('MAT_Casa_Piedra',        (0.52, 0.52, 0.50))
MAT_paja_clara    = crear_mat('MAT_Casa_Paja_Clara',    (0.80, 0.68, 0.44))
MAT_paja_oscura   = crear_mat('MAT_Casa_Paja_Oscura',   (0.64, 0.52, 0.30))
MAT_vidrio        = crear_mat('MAT_Casa_Vidrio',        (0.55, 0.75, 0.85), alpha=0.45)
MAT_tela_crema    = crear_mat('MAT_Casa_Tela_Crema',    (0.92, 0.88, 0.76))
MAT_tela_roja     = crear_mat('MAT_Casa_Tela_Roja',     (0.72, 0.28, 0.22))
MAT_piedra_oscura = crear_mat('MAT_Casa_Piedra_Oscura', (0.34, 0.34, 0.35))
MAT_bronce        = crear_mat('MAT_Casa_Bronce',        (0.72, 0.55, 0.35), rough=0.4)
MAT_llama         = crear_mat('MAT_Casa_Llama',         (1.0, 0.72, 0.30), emis=2.5)

# ============ 3) Set de captura (NO viaja al GLB: sin prefijo SM_) ============
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=7.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.0))

# ============ 4) Constantes ============
Z_APOYO   = 0.045        # E-12
ANCHO_X   = 16.0         # v4: 8.0 -> 16.0 (usuario: el doble de amplia para
FONDO_Y   = 12.0         # moverse/equipar/comprar y poner objetos dentro)
MURO_ESP  = 0.16
MURO_ALTO = 3.20         # v3: 2.60 -> 3.20 (usuario: mas alta = mejor vision interior)
PISO_Z    = 0.105        # nivel piso interior terminado (losa + tablones)
TECHO_Z   = MURO_ALTO + Z_APOYO   # 3.245
CUMBRERO_H = 1.30        # v4: proporcional a la casa doble

# Vano puerta principal (muro frontal Y+6): X[-1.10, -0.10], z[PISO_Z, 2.205]
PUER_X0, PUER_X1 = -1.10, -0.10
PUER_Z1 = PISO_Z + 2.10   # 2.205
# Ventanas frontal/trasera (v4: 4 vanos por muro largo, spacing amplio)
# v6 FIX (usuario): el vano (1.30, 1.94) tocaba la divisoria (X=2.0, cara
# en 1.94) — "una ventana pegada a la pared divisoria". Reubicados los 2
# vanos del tramo de la sala centrados en su tramo real (2.06..7.84).
VENT_F = [(-6.60, -5.96), (-3.40, -2.76), (2.80, 3.44), (5.40, 6.04)]
VENT_B = [(-6.60, -5.96), (-3.40, -2.76), (2.80, 3.44), (5.40, 6.04)]
VENT_Z0, VENT_Z1 = 1.10, 2.20
# Muro izquierdo X-8: ventana centrada Y[-0.32, 0.32]
# Muro derecho X+8: ventana en Y[1.0, 1.64] (en la sala)
# Divisoria interior: X = +2.0, espesor 0.12, vano puerta Y[0.55, 1.45]
# (v4: divisoria a X=+2.0 — dormitorio 10 m de ancho, sala 5.6 m)
DIV_X = 2.0
DIV_PUER_Y0, DIV_PUER_Y1 = 0.55, 1.45

# ============ 5) Helpers ============
def caja(nombre, mat, sx, sy, sz, cx, cy, cz, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(cx, cy, cz), rotation=rot)
    o = bpy.context.object
    o.name = nombre
    o.scale = (sx, sy, sz)
    o.data.materials.append(mat)
    return o

def cilindro(nombre, mat, r, h, cx, cy, cz, verts=12):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=h,
                                        location=(cx, cy, cz))
    o = bpy.context.object
    o.name = nombre
    o.data.materials.append(mat)
    return o

def join(nombre_base, objs):
    """Une N objetos en 1 mesh (E-70: contar piezas por mesh, no por caja)."""
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    r = bpy.context.object
    r.name = nombre_base
    return r

def sombrear_plano(objs):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.shade_flat()

# ============ 6) ZOCALO (perimetro piedra, 1 mesh) ============
z_seg = []
# losas largas por lado (esquinas compartidas: +0.16 en cada extremo)
z_seg.append(caja('Z_I', MAT_piedra, ANCHO_X, MURO_ESP, 0.30, 0,  (FONDO_Y - MURO_ESP) / 2,  Z_APOYO + 0.15))
z_seg.append(caja('Z_D', MAT_piedra, ANCHO_X, MURO_ESP, 0.30, 0, -(FONDO_Y - MURO_ESP) / 2,  Z_APOYO + 0.15))
z_seg.append(caja('Z_L', MAT_piedra, MURO_ESP, FONDO_Y - 2 * MURO_ESP, 0.30, -(ANCHO_X - MURO_ESP) / 2, 0, Z_APOYO + 0.15))
z_seg.append(caja('Z_R', MAT_piedra, MURO_ESP, FONDO_Y - 2 * MURO_ESP, 0.30,  (ANCHO_X - MURO_ESP) / 2, 0, Z_APOYO + 0.15))
# esquinas oscuras (como zocalo_piedra del modulo)
for cx, cy in ((-ANCHO_X / 2, FONDO_Y / 2), (-ANCHO_X / 2, -FONDO_Y / 2),
               (ANCHO_X / 2, FONDO_Y / 2), (ANCHO_X / 2, -FONDO_Y / 2)):
    z_seg.append(caja('Z_E', MAT_piedra_oscura, MURO_ESP + 0.02, MURO_ESP + 0.02, 0.34,
                      cx, cy, Z_APOYO + 0.17))
SM_zocalo = join('SM_Zocalo_Perimetro', z_seg)

# ============ 7) PISO INTERIOR (losa + tablones decorativos) ============
SM_piso_losa = caja('SM_Piso_Losa', MAT_madera_oscura,
                    ANCHO_X - 2 * MURO_ESP, FONDO_Y - 2 * MURO_ESP, 0.04,
                    0, 0, Z_APOYO + 0.02)
tab = []
TY = FONDO_Y - 2 * MURO_ESP   # 5.68
n_tab = 6
for i in range(n_tab):
    ty = -TY / 2 + TY * (i + 0.5) / n_tab
    tab.append(caja('T', MAT_madera_clara, ANCHO_X - 2 * MURO_ESP - 0.04, 0.86, 0.02,
                    0, ty, Z_APOYO + 0.05))
SM_piso_tablones = join('SM_Piso_Tablones', tab)
sombrar_piso = [SM_piso_losa, SM_piso_tablones]

# ============ 8) MUROS con vanos reales ============
def muro_frontal_trasero(es_frontal):
    """Muro Y=+3 (frontal, con puerta + 2 ventanas) o Y=-3 (trasero, 2 ventanas)."""
    lado = 1.0 if es_frontal else -1.0
    y_c = lado * (FONDO_Y - MURO_ESP) / 2
    vents = VENT_F if es_frontal else VENT_B
    seg = []
    # construccion generica: lista de tramos X con su rango z
    tramos = []  # (x0, x1, z0, z1)
    def full(x0, x1):
        tramos.append((x0, x1, Z_APOYO, Z_APOYO + MURO_ALTO))
    def con_ventana(x0, x1):
        tramos.append((x0, x1, Z_APOYO, VENT_Z0))                 # pretil
        tramos.append((x0, x1, VENT_Z1, Z_APOYO + MURO_ALTO))     # dintel
    def con_puerta(x0, x1):
        tramos.append((x0, x1, PUER_Z1, Z_APOYO + MURO_ALTO))      # dintel
    if es_frontal:
        full(-ANCHO_X / 2, vents[0][0])
        con_ventana(vents[0][0], vents[0][1])
        full(vents[0][1], PUER_X0)
        con_puerta(PUER_X0, PUER_X1)
        full(PUER_X1, vents[1][0])
        con_ventana(vents[1][0], vents[1][1])
        full(vents[1][1], ANCHO_X / 2)
    else:
        full(-ANCHO_X / 2, vents[0][0])
        con_ventana(vents[0][0], vents[0][1])
        full(vents[0][1], vents[1][0])
        con_ventana(vents[1][0], vents[1][1])
        full(vents[1][1], ANCHO_X / 2)
    for (x0, x1, z0, z1) in tramos:
        seg.append(caja('Seg', MAT_madera_clara, x1 - x0, MURO_ESP, z1 - z0,
                        (x0 + x1) / 2, y_c, (z0 + z1) / 2))
    return seg

def muro_lateral(derecha):
    """Muro X=+8 (derecha, ventana en la sala) o X=-8 (izquierda, ventana centrada)."""
    x_c = (1.0 if derecha else -1.0) * (ANCHO_X - MURO_ESP) / 2
    vy = (3.00, 3.64) if derecha else (-0.32, 0.32)
    seg = []
    def full(y0, y1):
        seg.append(caja('Seg', MAT_madera_clara, MURO_ESP, y1 - y0, MURO_ALTO,
                        x_c, (y0 + y1) / 2, Z_APOYO + MURO_ALTO / 2))
    def con_ventana(y0, y1):
        seg.append(caja('Seg', MAT_madera_clara, MURO_ESP, y1 - y0, VENT_Z0 - Z_APOYO,
                        x_c, (y0 + y1) / 2, (Z_APOYO + VENT_Z0) / 2))
        seg.append(caja('Seg', MAT_madera_clara, MURO_ESP, y1 - y0, Z_APOYO + MURO_ALTO - VENT_Z1,
                        x_c, (y0 + y1) / 2, (VENT_Z1 + Z_APOYO + MURO_ALTO) / 2))
    full(-FONDO_Y / 2, vy[0])
    con_ventana(vy[0], vy[1])
    full(vy[1], FONDO_Y / 2)
    return seg

seg_F = muro_frontal_trasero(True)
seg_B = muro_frontal_trasero(False)
seg_L = muro_lateral(False)
seg_R = muro_lateral(True)
SM_muro_F = join('SM_Muro_F', seg_F)
SM_muro_B = join('SM_Muro_B', seg_B)
SM_muro_L = join('SM_Muro_L', seg_L)
SM_muro_R = join('SM_Muro_R', seg_R)

# ============ 9) VENTANAS (marco + vidrio por vano) ============
def ventana(nombre, mat_marco, cx, cy, lateral=False):
    """Marco perimetral 0.05 + parteluz + vidrio, en el vano 0.64x0.92."""
    w, h = 0.64, 0.92
    zc = (VENT_Z0 + VENT_Z1) / 2
    prof = MURO_ESP + 0.04
    fr = []
    if lateral:
        # vano en el plano YZ: listones horizontales arriba/abajo (rot X 90)
        fr.append(caja('M', mat_marco, prof, w, 0.05, cx, cy, VENT_Z0 + 0.025))
        fr.append(caja('M', mat_marco, prof, w, 0.05, cx, cy, VENT_Z1 - 0.025))
        fr.append(caja('M', mat_marco, prof, 0.05, h, cx, cy - w / 2 + 0.025, zc))
        fr.append(caja('M', mat_marco, prof, 0.05, h, cx, cy + w / 2 - 0.025, zc))
        fr.append(caja('M', mat_marco, prof - 0.01, 0.04, h, cx, cy, zc))
        vid = caja('V', MAT_vidrio, MURO_ESP, w - 0.08, h - 0.08, cx, cy, zc)
    else:
        fr.append(caja('M', mat_marco, w, prof, 0.05, cx, cy, VENT_Z0 + 0.025))
        fr.append(caja('M', mat_marco, w, prof, 0.05, cx, cy, VENT_Z1 - 0.025))
        fr.append(caja('M', mat_marco, 0.05, prof, h, cx - w / 2 + 0.025, cy, zc))
        fr.append(caja('M', mat_marco, 0.05, prof, h, cx + w / 2 - 0.025, cy, zc))
        fr.append(caja('M', mat_marco, 0.04, prof - 0.01, h, cx, cy, zc))
        vid = caja('V', MAT_vidrio, w - 0.08, MURO_ESP, h - 0.08, cx, cy, zc)
    m = join(nombre + '_Marco', fr)
    vid.name = nombre + '_Vidrio'
    return [m, vid]

ventanas = []
for (x0, x1) in VENT_F:
    ventanas += ventana('SM_Ventana_F_%d' % VENT_F.index((x0, x1)), MAT_madera_oscura,
                        (x0 + x1) / 2, (FONDO_Y - MURO_ESP) / 2)
for (x0, x1) in VENT_B:
    ventanas += ventana('SM_Ventana_B_%d' % VENT_B.index((x0, x1)), MAT_madera_oscura,
                        (x0 + x1) / 2, -(FONDO_Y - MURO_ESP) / 2)
ventanas += ventana('SM_Ventana_L', MAT_madera_oscura,
                    -(ANCHO_X - MURO_ESP) / 2, 0.0, lateral=True)
ventanas += ventana('SM_Ventana_R', MAT_madera_oscura,
                    (ANCHO_X - MURO_ESP) / 2, 3.32, lateral=True)

# ============ 10) PUERTA PRINCIPAL (marco + hoja ABIERTA 35 grados) ============
# marco: 2 jambas + dintel alrededor del vano X[-1.10,-0.10], z[PISO_Z, 2.205]
jambas = []
jambas.append(caja('J', MAT_madera_oscura, 0.06, MURO_ESP + 0.06, 2.10,
                   PUER_X0 - 0.03, (FONDO_Y - MURO_ESP) / 2, PISO_Z + 1.05))
jambas.append(caja('J', MAT_madera_oscura, 0.06, MURO_ESP + 0.06, 2.10,
                   PUER_X1 + 0.03, (FONDO_Y - MURO_ESP) / 2, PISO_Z + 1.05))
jambas.append(caja('J', MAT_madera_oscura, 1.00 + 0.12, MURO_ESP + 0.06, 0.06,
                   (PUER_X0 + PUER_X1) / 2, (FONDO_Y - MURO_ESP) / 2, PUER_Z1 + 0.03))
SM_puerta_marco = join('SM_Puerta_Marco', jambas)
# hoja abierta 35 grados sobre la jamba izquierda (bisagra X = PUER_X0).
# FIX v2: la hoja mide 0.98 de ANCHO (cierra el vano de 1.00) — v1 la
# hacia de LARGO 1.98 y cruzaba el vano bloqueando la entrada (raycast).
ang = math.radians(35)
Y_MURO_F = (FONDO_Y - MURO_ESP) / 2
cx_h = PUER_X0 + 0.49 * math.cos(ang)
cy_h = Y_MURO_F + 0.49 * math.sin(ang)
SM_puerta_hoja = caja('SM_Puerta_Hoja', MAT_madera_clara, 0.98, 0.05, 2.06,
                       cx_h, cy_h, PISO_Z + 1.03, rot=(0, 0, ang))
# pomo
pomo = caja('P', MAT_bronce, 0.05, 0.05, 0.05,
            cx_h + 0.05, cy_h - 0.85, PISO_Z + 1.00)
pomo.name = 'SM_Puerta_Pomo'
# umbral de piedra bajo la puerta (paso exterior/interior)
umbral = caja('U', MAT_piedra, 1.10, 0.30, 0.06,
              (PUER_X0 + PUER_X1) / 2, (FONDO_Y - MURO_ESP) / 2, Z_APOYO + 0.03)
umbral.name = 'SM_Puerta_Umbral'

# ============ 11) DIVISORIA INTERIOR con puerta interior ============
seg = []
def dfull(y0, y1):
    seg.append(caja('Seg', MAT_madera_clara, 0.12, y1 - y0, MURO_ALTO - (PISO_Z - Z_APOYO),
                    DIV_X, (y0 + y1) / 2, PISO_Z + (MURO_ALTO - (PISO_Z - Z_APOYO)) / 2))
dfull(-FONDO_Y / 2 + MURO_ESP, DIV_PUER_Y0)
dfull(DIV_PUER_Y1, FONDO_Y / 2 - MURO_ESP)
# dintel sobre puerta interior
seg.append(caja('Seg', MAT_madera_clara, 0.12, DIV_PUER_Y1 - DIV_PUER_Y0,
                Z_APOYO + MURO_ALTO - (PISO_Z + 2.10),
                DIV_X, (DIV_PUER_Y0 + DIV_PUER_Y1) / 2,
                (PISO_Z + 2.10 + Z_APOYO + MURO_ALTO) / 2))
SM_divisoria = join('SM_Divisoria', seg)
# marco puerta interior + hoja abierta 100 contra el muro trasero
jin = []
jin.append(caja('J', MAT_madera_oscura, 0.14, 0.05, 2.10, DIV_X, DIV_PUER_Y0 - 0.025, PISO_Z + 1.05))
jin.append(caja('J', MAT_madera_oscura, 0.14, 0.05, 2.10, DIV_X, DIV_PUER_Y1 + 0.025, PISO_Z + 1.05))
jin.append(caja('J', MAT_madera_oscura, 0.14, 0.90 + 0.10, 0.05, DIV_X, (DIV_PUER_Y0 + DIV_PUER_Y1) / 2, PISO_Z + 2.10 + 0.025))
SM_puerta_int_marco = join('SM_Puerta_Int_Marco', jin)
# hoja abierta 90 (plana contra el lado dormitorio de la divisoria)
SM_puerta_int_hoja = caja('SM_Puerta_Int_Hoja', MAT_madera_clara, 0.04, 0.86, 2.04,
                          DIV_X - 0.10, DIV_PUER_Y0 - 0.45, PISO_Z + 1.02)

# ============ 12) TECHO a dos aguas (grupo SM_Techo_* ocultable) ============
# v5 FIX DEL SIGNO (bug reportado por el usuario: "se ve como una V, el
# vertice esta abajo"): la rotacion X de los tableros tenia el signo
# invertido — con `+ang*s` el ALERO subia y el CENTRO bajaba (V colgante,
# paja mirando adentro). El tablero del lado Y+ debe INCLINARSE hacia el
# centro-arriba: rot X NEGATIVA en s=+1 y POSITIVA en s=-1 (=-ang*s).
# Todo derivado de FONDO_Y para escalar con la casa.
tcho = []
ALERO_Y = FONDO_Y / 2 + 0.08           # 6.08 — borde exterior del tablero
pend = math.atan2(CUMBRERO_H, ALERO_Y)  # angulo real de la pendiente
largo = math.sqrt(CUMBRERO_H ** 2 + ALERO_Y ** 2)
MEDIO_Y = ALERO_Y / 2                   # centro del tablero en Y
# cumbrero (la arista superior donde se encuentran ambos tableros)
tcho.append(caja('C', MAT_madera_oscura, ANCHO_X + 0.30, 0.14, 0.14, 0, 0, TECHO_Z + CUMBRERO_H))
# 2 tableros inclinados (paja): de Y=+-ALERO (alero, a nivel de muro) al
# cumbrero (arriba-centro). Centrados a media pendiente, rot X = -ang*s.
for s in (-1, 1):
    tcho.append(caja('Tab', MAT_paja_clara,
                     ANCHO_X + 0.16, largo + 0.10, 0.06,
                     0, s * MEDIO_Y, TECHO_Z + CUMBRERO_H / 2,
                     rot=(-pend * s, 0, 0)))
# franja de paja oscura en el borde inferior de cada tablero (lectura de capa)
for s in (-1, 1):
    tcho.append(caja('Borde', MAT_paja_oscura, ANCHO_X + 0.16, 0.26, 0.05,
                     0, s * (ALERO_Y - 0.16), TECHO_Z + 0.10, rot=(-pend * s, 0, 0)))
# cabios visibles bajo el alero (frente y fondo, 6 por lado en la casa ancha)
for s in (-1, 1):
    for i in range(6):
        x_c = -ANCHO_X / 2 + 0.6 + i * (ANCHO_X - 1.2) / 5
        tcho.append(caja('Cab', MAT_madera_oscura, 0.08, 0.08, 0.42,
                         x_c, s * (FONDO_Y / 2 - 0.14), TECHO_Z - 0.16))
SM_techo = join('SM_Techo_Dos_Aguas', tcho)
# grupo ocultable: nombre ya lleva SM_Techo_*

# v7 FIX (usuario: "parte abierta donde va el techo — el triangulo que une
# las paredes y el techo"): faltaban los FRONTONES (gable ends). Con el
# cumbrero corriendo en X, las pendientes bajan hacia Y± y en los extremos
# X (sobre los muros laterales, tope z 3.245) queda un TRIANGULO abierto
# hasta la arista del techo (z 4.545). Se cierra con un prisma triangular
# de madera por lado, alineado al plano del muro lateral.
import bmesh

def fronton(nombre, x_c):
    bm = bmesh.new()
    esp = 0.12
    y0, y1 = -ALERO_Y, ALERO_Y
    zb = TECHO_Z                      # base = tope de muros
    zp = TECHO_Z + CUMBRERO_H         # pico = arista del cumbrero
    A  = bm.verts.new((x_c - esp / 2, y0, zb))
    B  = bm.verts.new((x_c - esp / 2, y1, zb))
    C  = bm.verts.new((x_c - esp / 2, 0.0, zp))
    A2 = bm.verts.new((x_c + esp / 2, y0, zb))
    B2 = bm.verts.new((x_c + esp / 2, y1, zb))
    C2 = bm.verts.new((x_c + esp / 2, 0.0, zp))
    bm.faces.new((A, B, C))
    bm.faces.new((A2, B2, C2))
    bm.faces.new((A, B, B2, A2))
    bm.faces.new((B, C, C2, B2))
    bm.faces.new((C, A, A2, C2))
    me = bpy.data.meshes.new('M_' + nombre[3:])
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(ob)
    ob.data.materials.append(MAT_madera_clara)
    # viga decorativa bajo la pendiente (lectura de estructura)
    return ob

fronton('SM_Fronton_I', -(ANCHO_X - MURO_ESP) / 2)
fronton('SM_Fronton_D', (ANCHO_X - MURO_ESP) / 2)

# ============ 13) MUEBLES (SM_Mueble_* — interactivos RF7) ============
# v4 LAYOUT 16x12: dormitorio X -7.84..1.94 (10 m), sala X 2.06..7.84 (5.6 m).
# Muebles contra muros, centro LIBRE para moverse/equipar (directiva usuario).
muebles = []

# --- DORMITORIO (X -7.84 .. 1.94) ---
# v6 FIX CAMA (usuario: "madera vertical a un costado"): era el RESPALDO
# parado en el costado -X (contra la pared). La cama mide su largo en Y:
# los pies en Y- (pieza inferior) y la CABEZA en Y+ (donde va la almohada).
# Respaldo movido al extremo Y+ , y la almohada tambien (ambos del mismo
# lado). Antes la almohada estaba en Y- junto a la piecera: la cabeza
# quedaba en los pies.
CX, CY = -6.60, -1.50   # centro de la cama (muro izq X=-7.84)
cama = []
cama.append(caja('Cm', MAT_madera_oscura, 0.08, 1.90, 0.30, CX - 0.46, CY, PISO_Z + 0.15))   # lateral izq
cama.append(caja('Cm', MAT_madera_oscura, 0.08, 1.90, 0.30, CX + 0.46, CY, PISO_Z + 0.15))    # lateral der
cama.append(caja('Cm', MAT_madera_oscura, 0.90, 0.08, 0.30, CX, CY - 0.95, PISO_Z + 0.15))   # piecera (Y-)
cama.append(caja('Cm', MAT_madera_oscura, 0.90, 0.12, 0.95, CX, CY + 0.95, PISO_Z + 0.475))  # RESPALDO (Y+, cabeza)
cama.append(caja('Cm', MAT_madera_oscura, 0.84, 1.82, 0.06, CX, CY, PISO_Z + 0.33))           # base listones
SM_cama_marco = join('SM_Mueble_Cama_Marco', cama)
SM_cama_colchon = caja('SM_Mueble_Cama_Colchon', MAT_tela_crema, 0.86, 1.86, 0.18,
                       CX, CY, PISO_Z + 0.45)
SM_cama_almohada = caja('SM_Mueble_Cama_Almohada', MAT_tela_crema, 0.60, 0.34, 0.10,
                        CX, CY + 0.72, PISO_Z + 0.59)
SM_cama_manta = caja('SM_Mueble_Cama_Manta', MAT_tela_roja, 0.88, 1.10, 0.06,
                     CX, CY - 0.32, PISO_Z + 0.56)

# Velador + farol junto a la CABEZA de la cama (v6: acompana al respaldo)
SM_velador = caja('SM_Mueble_Velador', MAT_madera_oscura, 0.36, 0.36, 0.50,
                  CX, CY + 1.55, PISO_Z + 0.25)
far = []
far.append(cilindro('F', MAT_bronce, 0.02, 0.36, CX, CY + 1.55, PISO_Z + 0.68, verts=8))
far.append(cilindro('F', MAT_bronce, 0.10, 0.12, CX, CY + 1.55, PISO_Z + 0.92, verts=10))
SM_farol = join('SM_Mueble_Farol_Velador', far)
SM_farol_llama = cilindro('SM_Mueble_Farol_Llama', MAT_llama, 0.045, 0.10,
                          CX, CY + 1.55, PISO_Z + 0.90, verts=8)

# Comoda (contra el muro frontal del dormitorio, centro de la pared)
com = []
com.append(caja('Cd', MAT_madera_clara, 1.00, 0.42, 0.85, -5.60, 5.60, PISO_Z + 0.425))
for i in range(3):
    com.append(caja('Cd', MAT_madera_oscura, 0.90, 0.02, 0.24, -5.60, 5.82, PISO_Z + 0.16 + i * 0.28))
com.append(caja('Cd', MAT_madera_clara, 1.06, 0.46, 0.05, -5.60, 5.60, PISO_Z + 0.875))
SM_comoda = join('SM_Mueble_Comoda', com)

# Cofre del jugador (a los pies de la cama)
cof = []
cof.append(caja('Cf', MAT_madera_oscura, 0.55, 0.85, 0.35, CX + 1.30, CY - 0.10, PISO_Z + 0.175))
cof.append(caja('Cf', MAT_madera_clara, 0.58, 0.88, 0.12, CX + 1.30, CY - 0.10, PISO_Z + 0.41))
SM_cofre = join('SM_Mueble_Cofre', cof)

# Alfombra grande redonda (centro del dormitorio, 1.6 m — sala de estar cozy)
SM_alfombra_d = cilindro('SM_Mueble_Alfombra_Dormitorio', MAT_tela_roja, 1.60, 0.02,
                         -4.60, -1.00, PISO_Z + 0.01, verts=16)
# Sofa bajo frente a la zona de alfombra (muro trasero del dormitorio)
sof = []
sof.append(caja('Sf', MAT_madera_clara, 1.80, 0.55, 0.42, -4.60, -5.30, PISO_Z + 0.21))
sof.append(caja('Sf', MAT_madera_clara, 1.80, 0.16, 0.50, -4.60, -5.52, PISO_Z + 0.66))
sof.append(caja('Sf', MAT_madera_clara, 0.16, 0.55, 0.35, -5.58, -5.30, PISO_Z + 0.78))
sof.append(caja('Sf', MAT_madera_clara, 0.16, 0.55, 0.35, -3.62, -5.30, PISO_Z + 0.78))
sof.append(caja('Sf', MAT_tela_crema, 1.70, 0.45, 0.10, -4.60, -5.28, PISO_Z + 0.47))
SM_sofa = join('SM_Mueble_Sofa', sof)
# Mesa baja centro del dormitorio (sala de estar cozy)
mbj = []
mbj.append(caja('Mb', MAT_madera_clara, 1.00, 0.60, 0.05, -4.60, -4.10, PISO_Z + 0.40))
mbj.append(caja('Mp', MAT_madera_oscura, 0.08, 0.08, 0.38, -5.06, -4.38, PISO_Z + 0.19))
mbj.append(caja('Mp', MAT_madera_oscura, 0.08, 0.08, 0.38, -4.14, -4.38, PISO_Z + 0.19))
mbj.append(caja('Mp', MAT_madera_oscura, 0.08, 0.08, 0.38, -5.06, -3.82, PISO_Z + 0.19))
mbj.append(caja('Mp', MAT_madera_oscura, 0.08, 0.08, 0.38, -4.14, -3.82, PISO_Z + 0.19))
SM_mesa_baja = join('SM_Mueble_Mesa_Baja', mbj)

# --- SALA / COCINA (X 2.06 .. 7.84) ---
MX, MY = 5.00, -0.50   # centro de la mesa de comer
mes = []
mes.append(caja('Mt', MAT_madera_clara, 1.20, 0.80, 0.06, MX, MY, PISO_Z + 0.77))
for dx, dy in ((-0.52, -0.32), (0.52, -0.32), (-0.52, 0.32), (0.52, 0.32)):
    mes.append(caja('Mp', MAT_madera_oscura, 0.08, 0.08, 0.74, MX + dx, MY + dy, PISO_Z + 0.37))
SM_mesa = join('SM_Mueble_Mesa', mes)

# 2 sillas (una por lado largo de la mesa, mirandola)
for i, sy in enumerate((-1, 1)):
    sx = MX
    syy = MY + sy * 0.75
    sil = []
    sil.append(caja('Sa', MAT_madera_clara, 0.42, 0.42, 0.05, sx, syy, PISO_Z + 0.445))
    for ddx, ddy in ((-0.16, -0.16), (0.16, -0.16), (-0.16, 0.16), (0.16, 0.16)):
        sil.append(caja('Sp', MAT_madera_oscura, 0.06, 0.06, 0.42, sx + ddx, syy + ddy, PISO_Z + 0.21))
    sil.append(caja('Sr', MAT_madera_clara, 0.42, 0.06, 0.50,
                    sx, syy + sy * 0.21, PISO_Z + 0.72))
    join('SM_Mueble_Silla_%d' % i, sil)

# Estufa de lena (contra muro trasero de la sala)
est = []
est.append(caja('Es', MAT_piedra_oscura, 0.62, 0.52, 0.72, 6.80, -5.30, PISO_Z + 0.36))
est.append(caja('Es', MAT_piedra, 0.66, 0.56, 0.06, 6.80, -5.30, PISO_Z + 0.75))
est.append(caja('Eh', MAT_piedra_oscura, 0.18, 0.18, 0.16, 6.66, -5.30, PISO_Z + 0.86))
est.append(caja('Eh', MAT_piedra_oscura, 0.18, 0.18, 0.16, 6.94, -5.30, PISO_Z + 0.86))
est.append(caja('Ec', MAT_piedra_oscura, 0.14, 0.14, 1.10, 6.80, -5.30, PISO_Z + 1.35))   # chimenea
est.append(caja('Eb', MAT_piedra_oscura, 0.34, 0.02, 0.26, 6.80, -5.02, PISO_Z + 0.32))   # boca
SM_estufa = join('SM_Mueble_Estufa', est)

# Nevera rustica de piedra (pozo de conserva — M147: sin electricidad)
nev = []
nev.append(cilindro('N', MAT_piedra, 0.38, 0.60, 2.60, 5.30, PISO_Z + 0.30, verts=12))
nev.append(cilindro('N', MAT_piedra_oscura, 0.36, 0.10, 2.60, 5.30, PISO_Z + 0.65, verts=12))
SM_nevera = join('SM_Mueble_Nevera', nev)
SM_nevera_tapa = cilindro('SM_Mueble_Nevera_Tapa', MAT_madera_clara, 0.42, 0.08,
                          2.68, 5.30, PISO_Z + 0.70, verts=12)

# Estanteria (contra divisoria, lado sala)
estn = []
for sy in (-0.06, 0.06):
    estn.append(caja('El', MAT_madera_oscura, 0.28, 0.06, 1.90, 2.30, 3.60 + sy, PISO_Z + 0.95))
for z_i in (0.45, 0.95, 1.45):
    estn.append(caja('Et', MAT_madera_clara, 0.28, 1.00, 0.04, 2.30, 3.60, PISO_Z + z_i))
# libros (bloques de color tela)
estn.append(caja('Lb', MAT_tela_roja, 0.18, 0.08, 0.30, 2.30, 3.28, PISO_Z + 0.62))
estn.append(caja('Lb', MAT_tela_crema, 0.18, 0.07, 0.26, 2.30, 3.38, PISO_Z + 0.60))
estn.append(caja('Lb', MAT_tela_roja, 0.18, 0.08, 0.24, 2.30, 3.92, PISO_Z + 1.12))
SM_estanteria = join('SM_Mueble_Estanteria', estn)

# Alfombra sala
SM_alfombra_s = cilindro('SM_Mueble_Alfombra_Sala', MAT_tela_crema, 0.90, 0.02,
                         5.00, -0.50, PISO_Z + 0.01, verts=14)

# ============ 14) Asentado del GRUPO sobre vertices reales (E-24) ============
def z_min_real(objs):
    zmin = 1e9
    for o in objs:
        for v in o.data.vertices:
            wz = (o.matrix_world @ v.co).z
            zmin = min(zmin, wz)
    return zmin

sm_objs = [o for o in bpy.data.objects if o.name.startswith('SM_')]
zmin = z_min_real(sm_objs)
dz = Z_APOYO - zmin
if abs(dz) > 1e-6:
    for o in sm_objs:
        o.location.z += dz
bpy.context.view_layer.update()
zmin2 = z_min_real([o for o in bpy.data.objects if o.name.startswith('SM_')])
assert zmin2 < 0.051 and zmin2 > 0.039, 'z_min del grupo != 0.045: %f' % zmin2

# ============ 15) Stats (hoja de contacto) ============
bpy.context.view_layer.update()
sm_objs = [o for o in bpy.data.objects if o.name.startswith('SM_')]
total_tris = 0
for o in sm_objs:
    total_tris += sum(len(p.vertices) - 2 for p in o.data.polygons)
mats = set()
for o in sm_objs:
    for m in o.data.materials:
        mats.add(m.name)
print('=== CASA MEDIANA M18-BIS — hoja de contacto ===')
print('SM_: %d objetos | %d tris | %d materiales' % (len(sm_objs), total_tris, len(mats)))
grupos = {}
for o in sm_objs:
    g = o.name.split('_')[1]
    grupos[g] = grupos.get(g, 0) + 1
print('Sub-grupos: %s' % grupos)
print('Interior util: %.2f x %.2f m (dormitorio %.2f m ancho, sala %.2f m)' % (
    ANCHO_X - 2 * MURO_ESP, FONDO_Y - 2 * MURO_ESP,
    DIV_X - 0.06 - (-ANCHO_X / 2 + MURO_ESP), ANCHO_X / 2 - MURO_ESP - DIV_X - 0.06))
print('Puerta principal: vano 1.00 x 2.10 (NPC 1.75 entra sin agacharse)')

# ============ 16) Guardar .blend (§9.6: NUNCA exportar sin aprobacion) ============
import os
ruta_blend = bpy.path.abspath('//') + 'casa_mediana_lowpoly.blend'
if not os.path.dirname(ruta_blend) or not os.path.isdir(os.path.dirname(ruta_blend)):
    # headless: relativo a la ubicacion del script
    ruta_blend = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'casa_mediana_lowpoly.blend')
bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(ruta_blend))
print('.blend guardado: %s' % os.path.abspath(ruta_blend))
