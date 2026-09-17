# crear_casa_choza_ampliada_lowpoly.py — CHOZA AMPLIADA HABITABLE (M18-BIS)
# Checklist M18-BIS: "Casa choza ampliada (1 ambiente 5x4 m: cama + cofre +
# mesa + cocina de lena)".
#
# Es la MAS PEQUEÑA de las 5 casas del M18-BIS y la PRIMERA escalon del
# progreso de vivienda del jugador: arranca en la choza y termina en la
# mansion. Por eso el lenguaje visual es mas rustico que la casa mediana:
#   - piso de TIERRA APISONADA (no tablones de madera)
#   - zocalo de PIEDRA mas alto y tosco
#   - muros de madera rustica (madera_clara) con vanos chicos
#   - techo de PAJA MUY EMPINADO (28.9 deg) y grueso: la paja ES la choza
#   - chimenea de piedra que ATRAVIESA el techo (señal "hogar", aprendida
#     en la v8 de la casa mediana: sin humo visible leia "galpon sin hogar")
#
# DIMENSIONES: 5.0 (X) x 4.0 (Y) exterior, muros 2.60 alto, cumbrero 1.15
# (pendiente 28.9 deg). Interior 4.68 x 3.68 = 17.2 m2. UN ambiente.
#
# ESCALA NPC (M19 v5 = 1.75 m): puerta 0.90x2.00 (vano real, hoja abierta
# 35 grados — se VE que se entra), ventana 0.70x0.70, cama 1.90x0.90,
# mesa 0.72 alto, banco 0.44 asiento.
#
# PRESUPUESTO M166 §3.3: a diferencia de la casa mediana (que necesita la
# excepcion de casas grandes del plan §6.1), la choza es lo bastante chica
# para cumplir ALTA <=16 obj / <=6000 tris / <=12 mats. OBJETIVO: 16 SM_.
#
# NOMBRES por sub-grupo (Godot oculta SM_Techo_* al entrar y encuentra
# SM_Mueble_* interactivos RF7):
#   SM_Techo_* (ocultable) · SM_Mueble_* (RF7) · SM_Zocalo/Piso/Muro_* (estructura)
#
# Asentado: z_min = 0.045 del GRUPO medido sobre VERTICES REALES (E-24).
# Ejecutar: blender -b --python crear_casa_choza_ampliada_lowpoly.py (headless OK)
import bpy
import math
import bmesh
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

# ============ 2) Materiales (12 = tope exacto M166 §3.3 ALTA) ============
# Mismo set que la casa mediana v8 para COHERENCIA VISUAL entre las 5 casas.
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
# Acento ancestral (rojo): cumbrera + casings de ventana + sombrerete chimenea.
MAT_acento        = crear_mat('MAT_Casa_Acento',        (0.55, 0.18, 0.12))

# ============ 3) Set de captura (NO viaja al GLB: sin prefijo SM_) ============
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=7.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.0))

# ============ 4) Constantes ============
Z_APOYO    = 0.045
ANCHO_X    = 5.0
FONDO_Y    = 4.0
MURO_ESP   = 0.16
MURO_ALTO  = 2.60     # choza mas baja que la casa mediana (3.20)
PISO_Z     = 0.105    # tierra apisonada + apisonado terminado
TECHO_Z    = MURO_ALTO + Z_APOYO           # 2.645
# Cumbrero ALTO a proposito: aprendimos en la v8 de la casa mediana que 12 deg
# leia "galpon". Con 1.15 sobre 2.08 de semiluz la pendiente es 28.9 deg:
# la paja domina la silueta y lee "choza" sin discusion.
CUMBRERO_H = 1.15

# Puerta principal (muro frontal Y+): X[-0.45, 0.45], z[PISO_Z, PISO_Z+2.00]
PUER_X0, PUER_X1 = -0.45, 0.45
PUER_Z1 = PISO_Z + 2.00
# Ventanas 0.70x0.70: una al fondo (muro Y-, centrada) y una al lado (muro X-)
VENT_W    = 0.70
VENT_Z0   = 1.00
VENT_Z1   = 1.70
VENT_B_Y0, VENT_B_Y1 = -0.35, 0.35     # muro trasero, centrada en X
VENT_L_Y0, VENT_L_Y1 = 0.45, 1.15      # muro izquierdo (X-)

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

# ============ 6) ZOCALO de piedra (perimetro, 1 mesh) ============
# Choza = zocalo mas ALTO y tosco (0.34 vs 0.30 de la casa mediana) y de
# piedra OSCURA alternada, para que la base lea "rustico" y no "losa prolija".
z_seg = []
z_seg.append(caja('Z_I', MAT_piedra, ANCHO_X, MURO_ESP, 0.34, 0,  (FONDO_Y - MURO_ESP) / 2,  Z_APOYO + 0.17))
z_seg.append(caja('Z_D', MAT_piedra, ANCHO_X, MURO_ESP, 0.34, 0, -(FONDO_Y - MURO_ESP) / 2,  Z_APOYO + 0.17))
z_seg.append(caja('Z_L', MAT_piedra, MURO_ESP, FONDO_Y - 2 * MURO_ESP, 0.34, -(ANCHO_X - MURO_ESP) / 2, 0, Z_APOYO + 0.17))
z_seg.append(caja('Z_R', MAT_piedra, MURO_ESP, FONDO_Y - 2 * MURO_ESP, 0.34,  (ANCHO_X - MURO_ESP) / 2, 0, Z_APOYO + 0.17))
# esquinas de piedra oscura (sillares toscos)
for cx, cy in ((-ANCHO_X / 2, FONDO_Y / 2), (-ANCHO_X / 2, -FONDO_Y / 2),
               (ANCHO_X / 2, FONDO_Y / 2), (ANCHO_X / 2, -FONDO_Y / 2)):
    z_seg.append(caja('Z_E', MAT_piedra_oscura, MURO_ESP + 0.04, MURO_ESP + 0.04, 0.40,
                      cx, cy, Z_APOYO + 0.20))
SM_zocalo = join('SM_Zocalo_Perimetro', z_seg)

# ============ 7) PISO de TIERRA APISONADA (1 sola mesh) ============
# Sin tablones: la choza es el escalon mas bajo de vivienda. Una sola losa
# de tierra oscura + unas piedras planas embutidas para que no quede plano.
SM_piso = caja('SM_Piso_Tierra', MAT_piedra_oscura,
               ANCHO_X - 2 * MURO_ESP, FONDO_Y - 2 * MURO_ESP, 0.06,
               0, 0, Z_APOYO + 0.03)
# piedras embutidas (van en la MISMA mesh del piso para no sumar SM_)
pis_extra = [SM_piso]
for px, py, pr in ((-1.20, -1.10, 0.34), (1.10, 0.90, 0.28), (0.20, 1.30, 0.22)):
    pis_extra.append(cilindro('Piedra', MAT_piedra, pr, 0.03, px, py,
                              Z_APOYO + 0.055, verts=7))
SM_piso = join('SM_Piso_Tierra', pis_extra)

# ============ 8) MUROS con vanos reales ============
def muro_frontal_trasero(es_frontal):
    """Muro Y=+2 (frontal, con puerta) o Y=-2 (trasero, con 1 ventana)."""
    lado = 1.0 if es_frontal else -1.0
    y_c = lado * (FONDO_Y - MURO_ESP) / 2
    seg = []
    tramos = []  # (x0, x1, z0, z1)
    def full(x0, x1):
        tramos.append((x0, x1, Z_APOYO, Z_APOYO + MURO_ALTO))
    def con_puerta(x0, x1):
        tramos.append((x0, x1, PUER_Z1, Z_APOYO + MURO_ALTO))   # dintel
    def con_ventana(x0, x1):
        tramos.append((x0, x1, Z_APOYO, VENT_Z0))                # pretil
        tramos.append((x0, x1, VENT_Z1, Z_APOYO + MURO_ALTO))    # dintel
    if es_frontal:
        full(-ANCHO_X / 2, PUER_X0)
        con_puerta(PUER_X0, PUER_X1)
        full(PUER_X1, ANCHO_X / 2)
    else:
        full(-ANCHO_X / 2, VENT_B_Y0)
        con_ventana(VENT_B_Y0, VENT_B_Y1)
        full(VENT_B_Y1, ANCHO_X / 2)
    for (x0, x1, z0, z1) in tramos:
        seg.append(caja('Seg', MAT_madera_clara, x1 - x0, MURO_ESP, z1 - z0,
                        (x0 + x1) / 2, y_c, (z0 + z1) / 2))
    return join('SM_Muro_F' if es_frontal else 'SM_Muro_B', seg)

def muro_lateral(es_izq, con_ventana_flag):
    """Muro X=-2.5 (izq, con ventana) o X=+2.5 (der, ciego)."""
    lado = -1.0 if es_izq else 1.0
    x_c = lado * (ANCHO_X - MURO_ESP) / 2
    seg = []
    tramos = []
    def full(y0, y1):
        tramos.append((y0, y1, Z_APOYO, Z_APOYO + MURO_ALTO))
    def con_ventana(y0, y1):
        tramos.append((y0, y1, Z_APOYO, VENT_Z0))
        tramos.append((y0, y1, VENT_Z1, Z_APOYO + MURO_ALTO))
    if con_ventana_flag:
        full(-FONDO_Y / 2, VENT_L_Y0)
        con_ventana(VENT_L_Y0, VENT_L_Y1)
        full(VENT_L_Y1, FONDO_Y / 2)
    else:
        full(-FONDO_Y / 2, FONDO_Y / 2)
    for (y0, y1, z0, z1) in tramos:
        seg.append(caja('Seg', MAT_madera_clara, MURO_ESP, y1 - y0, z1 - z0,
                        x_c, (y0 + y1) / 2, (z0 + z1) / 2))
    return join('SM_Muro_L' if es_izq else 'SM_Muro_R', seg)

SM_muro_f = muro_frontal_trasero(True)
SM_muro_b = muro_frontal_trasero(False)
SM_muro_l = muro_lateral(True, True)
SM_muro_r = muro_lateral(False, False)

# ============ 9) PUERTA (marco + umbral juntos, hoja aparte p/ animar) ============
Y_MURO_F = (FONDO_Y - MURO_ESP) / 2      # 1.92
pm = []
pm.append(caja('J', MAT_madera_oscura, 0.08, 0.20, 2.00, PUER_X0 - 0.04, Y_MURO_F, PISO_Z + 1.00))
pm.append(caja('J', MAT_madera_oscura, 0.08, 0.20, 2.00, PUER_X1 + 0.04, Y_MURO_F, PISO_Z + 1.00))
pm.append(caja('J', MAT_madera_oscura, 0.98, 0.20, 0.10, 0, Y_MURO_F, PUER_Z1 + 0.05))
pm.append(caja('U', MAT_piedra, 1.06, 0.26, 0.05, 0, Y_MURO_F, PISO_Z - 0.02))
SM_puerta_marco = join('SM_Puerta_Marco', pm)

# hoja abierta 35 grados (se VE que se entra) — pivote en la jamba izquierda
ang = math.radians(35.0)
ANCHO_HOJA = PUER_X1 - PUER_X0
HOJA_ALTO = 1.94
px_pivote = PUER_X0
ph = []
ph.append(caja('H', MAT_madera_oscura, ANCHO_HOJA, 0.06, HOJA_ALTO,
               px_pivote + ANCHO_HOJA / 2 * math.cos(ang),
               Y_MURO_F - ANCHO_HOJA / 2 * math.sin(ang),
               PISO_Z + HOJA_ALTO / 2, rot=(0, 0, ang)))
# refuerzos diagonales + pomo de bronce (detalle que se ve de cerca)
ph.append(caja('R', MAT_madera_clara, 0.86, 0.02, 0.07,
               px_pivote + 0.45 * math.cos(ang),
               Y_MURO_F - 0.45 * math.sin(ang), PISO_Z + 0.55, rot=(0, 0, ang)))
ph.append(caja('R', MAT_madera_clara, 0.86, 0.02, 0.07,
               px_pivote + 0.45 * math.cos(ang),
               Y_MURO_F - 0.45 * math.sin(ang), PISO_Z + 1.40, rot=(0, 0, ang)))
ph.append(cilindro('P', MAT_bronce, 0.035, 0.08,
                   px_pivote + 0.82 * math.cos(ang),
                   Y_MURO_F - 0.82 * math.sin(ang), PISO_Z + 1.00, verts=8))
SM_puerta_hoja = join('SM_Puerta_Hoja', ph)

# ============ 10) VENTANAS (marco+casings juntos, vidrio aparte) ============
def ventana(nombre, mat_marco, cx, cy, w, lateral):
    """Marco + CASING PINTADO en acento, unidos al MISMO SM_ (E-70)."""
    zc = (VENT_Z0 + VENT_Z1) / 2
    h = VENT_Z1 - VENT_Z0
    prof = MURO_ESP + 0.04
    fr = []
    if lateral:
        fr.append(caja('A', mat_marco, prof, w, 0.05, cx, cy, VENT_Z0 + 0.025))
        fr.append(caja('A', mat_marco, prof, w, 0.05, cx, cy, VENT_Z1 - 0.025))
        fr.append(caja('A', mat_marco, prof, 0.05, h, cx, cy - w / 2 + 0.025, zc))
        fr.append(caja('A', mat_marco, prof, 0.05, h, cx, cy + w / 2 - 0.025, zc))
        # casing pintado (mismo lenguaje que la casa mediana v8)
        fr.append(caja('A', MAT_acento, prof + 0.02, w + 0.14, 0.05, cx, cy, VENT_Z0 - 0.02))
        fr.append(caja('A', MAT_acento, prof + 0.02, w + 0.14, 0.05, cx, cy, VENT_Z1 + 0.02))
        fr.append(caja('A', MAT_acento, prof + 0.02, 0.05, h + 0.10, cx, cy - w / 2 - 0.07, zc))
        fr.append(caja('A', MAT_acento, prof + 0.02, 0.05, h + 0.10, cx, cy + w / 2 + 0.07, zc))
    else:
        fr.append(caja('A', mat_marco, w, prof, 0.05, cx, cy, VENT_Z0 + 0.025))
        fr.append(caja('A', mat_marco, w, prof, 0.05, cx, cy, VENT_Z1 - 0.025))
        fr.append(caja('A', mat_marco, 0.05, prof, h, cx - w / 2 + 0.025, cy, zc))
        fr.append(caja('A', mat_marco, 0.05, prof, h, cx + w / 2 - 0.025, cy, zc))
        fr.append(caja('A', MAT_acento, w + 0.14, prof + 0.02, 0.05, cx, cy, VENT_Z0 - 0.02))
        fr.append(caja('A', MAT_acento, w + 0.14, prof + 0.02, 0.05, cx, cy, VENT_Z1 + 0.02))
        fr.append(caja('A', MAT_acento, 0.05, prof + 0.02, h + 0.10, cx - w / 2 - 0.07, cy, zc))
        fr.append(caja('A', MAT_acento, 0.05, prof + 0.02, h + 0.10, cx + w / 2 + 0.07, cy, zc))
    return join(nombre, fr)

fr_trasera = ventana('V_B', MAT_madera_oscura, 0.0, (VENT_B_Y0 + VENT_B_Y1) / 2, VENT_W, False)
fr_lateral = ventana('V_L', MAT_madera_oscura, -(ANCHO_X - MURO_ESP) / 2,
                     (VENT_L_Y0 + VENT_L_Y1) / 2, VENT_W, True)
# las 2 ventanas en UNA sola mesh: la choza es chica y no vale 2 SM_
SM_ventana_marco = join('SM_Ventana_Marco', [fr_trasera, fr_lateral])

# vidrio (material aparte por la transparencia — se une en 1 mesh)
vd = []
vd.append(caja('V', MAT_vidrio, VENT_W - 0.06, 0.02, VENT_Z1 - VENT_Z0 - 0.06,
               0.0, -(FONDO_Y - MURO_ESP) / 2, (VENT_Z0 + VENT_Z1) / 2))
vd.append(caja('V', MAT_vidrio, 0.02, VENT_W - 0.06, VENT_Z1 - VENT_Z0 - 0.06,
               -(ANCHO_X - MURO_ESP) / 2, (VENT_L_Y0 + VENT_L_Y1) / 2, (VENT_Z0 + VENT_Z1) / 2))
SM_ventana_vidrio = join('SM_Ventana_Vidrio', vd)

# ============ 11) TECHO a dos aguas + FRONTONES (grupo SM_Techo_*) ============
# Mismo signo que la v5 FIX de la casa mediana: rot X = -ang*s. Con +ang*s
# el alero sube y el centro baja (V colgante, bug reportado por el usuario).
ALERO_Y = FONDO_Y / 2 + 0.08           # 2.08 — borde exterior del tablero
pend = math.atan2(CUMBRERO_H, ALERO_Y)  # 28.9 deg
largo = math.sqrt(CUMBRERO_H ** 2 + ALERO_Y ** 2)
MEDIO_Y = ALERO_Y / 2

tcho = []
# cumbrera en ACENTO (linea mas alta y mas vista = señal "hogar" barata)
tcho.append(caja('C', MAT_acento, ANCHO_X + 0.28, 0.13, 0.13, 0, 0, TECHO_Z + CUMBRERO_H))
# 2 tableros de paja GRUESOS (0.09 vs 0.06 de la casa mediana): choza = paja
for s in (-1, 1):
    tcho.append(caja('Tab', MAT_paja_clara, ANCHO_X + 0.16, largo + 0.10, 0.09,
                     0, s * MEDIO_Y, TECHO_Z + CUMBRERO_H / 2,
                     rot=(-pend * s, 0, 0)))
# franja de paja oscura en el alero (lectura de capa)
for s in (-1, 1):
    tcho.append(caja('Borde', MAT_paja_oscura, ANCHO_X + 0.16, 0.28, 0.07,
                     0, s * (ALERO_Y - 0.16), TECHO_Z + 0.11, rot=(-pend * s, 0, 0)))
# cabios visibles bajo el alero (3 por lado: la choza es chica)
for s in (-1, 1):
    for i in range(3):
        x_c = -ANCHO_X / 2 + 0.8 + i * (ANCHO_X - 1.6) / 2
        tcho.append(caja('Cab', MAT_madera_oscura, 0.08, 0.08, 0.36,
                         x_c, s * (FONDO_Y / 2 - 0.14), TECHO_Z - 0.14))
SM_techo = join('SM_Techo_Dos_Aguas', tcho)

# FRONTONES (gable ends): con el cumbrero corriendo en X, quedan triangulos
# abiertos en los extremos X. Prisma triangular de MADERA por lado (v7 FIX).
def fronton(nombre, x_c):
    bm = bmesh.new()
    esp = 0.12
    y0, y1 = -ALERO_Y, ALERO_Y
    zb = TECHO_Z
    zp = TECHO_Z + CUMBRERO_H
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
    return ob

# Los frontones van en la MISMA mesh del techo (E-70): si no, la choza se
# pasa de 16 SM_. Materialmente son madera_clara sobre techo de paja, pero
# al unirlos quedan en un solo SM_Techo_* que Godot oculta completo al entrar.
SM_techo = join('SM_Techo_Dos_Aguas', [SM_techo,
                                       fronton('SM_Fronton_I', -(ANCHO_X - MURO_ESP) / 2),
                                       fronton('SM_Fronton_D', (ANCHO_X - MURO_ESP) / 2)])

# ============ 12) MUEBLES (SM_Mueble_* — interactivos RF7) ============
# Interior 4.68 x 3.68. Distribucion: cama contra el muro X- (izq), cocina
# de lena contra el muro X+ (der), mesa+banco al centro, cofre a los pies
# de la cama. Todo deja un pasillo central de ~1.3 m para el NPC (1.75 m alto).

# --- CAMA 1.90 x 0.90 (cabecera en Y+, contra el muro X-) ---
CX, CY = -1.55, 0.45
cama = []
cama.append(caja('Cm', MAT_madera_oscura, 0.08, 1.90, 0.26, CX - 0.41, CY, PISO_Z + 0.13))
cama.append(caja('Cm', MAT_madera_oscura, 0.08, 1.90, 0.26, CX + 0.41, CY, PISO_Z + 0.13))
cama.append(caja('Cm', MAT_madera_oscura, 0.90, 0.08, 0.26, CX, CY - 0.95, PISO_Z + 0.13))
cama.append(caja('Cm', MAT_madera_oscura, 0.90, 0.10, 0.80, CX, CY + 0.95, PISO_Z + 0.40))  # respaldo
cama.append(caja('Cm', MAT_madera_oscura, 0.84, 1.82, 0.05, CX, CY, PISO_Z + 0.28))           # listones
cama.append(caja('Co', MAT_tela_crema, 0.82, 1.80, 0.14, CX, CY - 0.02, PISO_Z + 0.37))       # colchon
cama.append(caja('Al', MAT_tela_crema, 0.56, 0.30, 0.09, CX, CY + 0.68, PISO_Z + 0.49))       # almohada
cama.append(caja('Mt', MAT_tela_roja, 0.84, 0.95, 0.05, CX, CY - 0.32, PISO_Z + 0.46))        # manta
SM_cama = join('SM_Mueble_Cama', cama)

# --- COFRE a los pies de la cama (con tapa y herrajes de bronce) ---
cof = []
COF_X, COF_Y = -1.55, -1.30
cof.append(caja('Cf', MAT_madera_oscura, 0.62, 0.48, 0.42, COF_X, COF_Y, PISO_Z + 0.21))
cof.append(caja('Cf', MAT_madera_clara, 0.66, 0.52, 0.08, COF_X, COF_Y, PISO_Z + 0.46))
cof.append(caja('Cf', MAT_bronce, 0.10, 0.06, 0.14, COF_X, COF_Y - 0.24, PISO_Z + 0.34))
SM_cofre = join('SM_Mueble_Cofre', cof)

# --- MESA 1.00 x 0.70 + BANCO (1 sola mesh) ---
MES_X, MES_Y = 0.85, -0.55
mes = []
mes.append(caja('Tb', MAT_madera_clara, 1.00, 0.70, 0.06, MES_X, MES_Y, PISO_Z + 0.72))
for dx, dy in ((-0.42, -0.27), (0.42, -0.27), (-0.42, 0.27), (0.42, 0.27)):
    mes.append(caja('Pt', MAT_madera_oscura, 0.07, 0.07, 0.72,
                    MES_X + dx, MES_Y + dy, PISO_Z + 0.36))
# banco (asiento 0.44 como la silla de la casa mediana)
mes.append(caja('Bc', MAT_madera_clara, 0.90, 0.28, 0.06, MES_X, MES_Y + 0.72, PISO_Z + 0.44))
for dx in (-0.38, 0.38):
    mes.append(caja('Bp', MAT_madera_oscura, 0.06, 0.24, 0.44,
                    MES_X + dx, MES_Y + 0.72, PISO_Z + 0.22))
SM_mesa = join('SM_Mueble_Mesa_Banco', mes)

# --- COCINA DE LEÑA + CHIMENEA QUE ATRAVIESA EL TECHO ---
# Aprendido en la v8 de la casa mediana: la chimenea DEBE asomar sobre la
# paja. Si muere debajo del techo la casa no tiene humo visible y lee
# "galpon sin hogar". Aca sube hasta 4.10 (la paja en Y=+0.80 esta en 3.40).
est = []
EST_X, EST_Y = 1.55, 0.60
# base de piedra (hogar)
est.append(caja('Eb', MAT_piedra_oscura, 0.70, 0.60, 0.62, EST_X, EST_Y, PISO_Z + 0.31))
# boca del hogar (hueco oscuro) + hornalla
est.append(caja('Eh', MAT_piedra_oscura, 0.44, 0.06, 0.34, EST_X, EST_Y - 0.30, PISO_Z + 0.30))
est.append(cilindro('Ho', MAT_bronce, 0.13, 0.04, EST_X, EST_Y, PISO_Z + 0.64, verts=10))
# llama (emisiva)
est.append(cilindro('Fl', MAT_llama, 0.09, 0.12, EST_X, EST_Y, PISO_Z + 0.70, verts=8))
# CAÑON de la chimenea: sube desde el hogar y ATRAVIESA el techo
# la paja en Y=+0.60 esta en z = TECHO_Z + CUMBRERO_H*(1 - |0.60|/ALERO_Y)
#   = 2.645 + 1.15*(1 - 0.288) = 2.645 + 0.819 = 3.464
# el caño (centro PISO_Z+2.30, sz=3.40) llega hasta PISO_Z+4.00 -> asoma
# 54 cm sobre la pendiente. Sombrerete encima, apoyado en el caño.
est.append(caja('Ec', MAT_piedra_oscura, 0.20, 0.20, 3.40, EST_X, EST_Y, PISO_Z + 2.30))
# sombrerete de piedra clara + acento
est.append(caja('Ecp', MAT_acento, 0.30, 0.30, 0.10, EST_X, EST_Y, PISO_Z + 4.05))
SM_cocina = join('SM_Mueble_Cocina_Lena', est)

# ============ 13) SOMBREADO PLANO (low-poly) ============
todos = [o for o in bpy.data.objects if o.name.startswith('SM_')]
sombrear_plano(todos)

# ============ 14) ASENTADO + VERIFICACION (E-12 / E-24 / E-94) ============
# E-94: zmin_real() usa matrix_world, que queda VIEJO hasta view_layer.update().
bpy.context.view_layer.update()

def zmin_real(o):
    """Minimo Z mundial sobre VERTICES REALES (no bound_box, E-24)."""
    return min((o.matrix_world @ Vector(v.co)).z for v in o.data.vertices)

z_actual = min(zmin_real(o) for o in todos)
dz = Z_APOYO - z_actual
for o in todos:
    o.location.z += dz
bpy.context.view_layer.update()
z_final = min(zmin_real(o) for o in todos)
assert abs(z_final - Z_APOYO) < 1e-6, 'z_min %.6f != %.3f' % (z_final, Z_APOYO)

# ============ 15) REPORTE ============
tris = sum(len(o.data.loop_triangles) if o.data.loop_triangles else len(o.data.polygons)
           for o in todos)
for o in todos:
    o.data.update()
tris = 0
for o in todos:
    o.data.calc_loop_triangles()
    tris += len(o.data.loop_triangles)
mats = set()
for o in todos:
    for m in o.data.materials:
        if m:
            mats.add(m.name)
print('--- CHOZA AMPLIADA (M18-BIS) ---')
print('SM_: %d objetos | %d tris | %d materiales' % (len(todos), tris, len(mats)))
print('z_min medido en vertices reales: %.4f (E-24)' % z_final)
print('Presupuesto M166 §3.3 ALTA: <=16 obj / <=6000 tris / <=12 mats')
print('  objetos  : %s' % ('OK' if len(todos) <= 16 else 'EXCEDE'))
print('  tris     : %s' % ('OK' if tris <= 6000 else 'EXCEDE'))
print('  materiales: %s' % ('OK' if len(mats) <= 12 else 'EXCEDE'))
print('Sub-grupos:')
grupos = {}
for o in todos:
    g = o.name.split('_')[1] if len(o.name.split('_')) > 1 else '?'
    grupos[g] = grupos.get(g, 0) + 1
for g in sorted(grupos):
    print('  %-12s %d' % (g, grupos[g]))

# E-92: volumen firmado > 0 => normales hacia afuera
print('--- Volumen firmado por objeto (E-92, >0 = normales OK) ---')
for o in sorted(todos, key=lambda x: x.name):
    bm = bmesh.new()
    bm.from_mesh(o.data)
    bm.normal_update()
    v = 0.0
    for f in bm.faces:
        verts = f.verts
        n = len(verts)
        if n < 3:
            continue
        for i in range(1, n - 1):
            v0 = o.matrix_world @ verts[0].co
            v1 = o.matrix_world @ verts[i].co
            v2 = o.matrix_world @ verts[i + 1].co
            v += (v0.x * (v1.y * v2.z - v1.z * v2.y)
                  + v0.y * (v1.z * v2.x - v1.x * v2.z)
                  + v0.z * (v1.x * v2.y - v1.y * v2.x)) / 6.0
    bm.free()
    marca = 'OK ' if v > 0 else '!!!'
    print('  %s %-28s %+9.4f m3' % (marca, o.name, v))

# guardar
import os
ruta = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..',
                    'casa_choza_ampliada_lowpoly.blend')
bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(ruta))
print('Guardado: ' + os.path.abspath(ruta))
