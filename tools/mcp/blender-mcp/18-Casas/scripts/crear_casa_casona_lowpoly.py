# crear_casa_casona_lowpoly.py — CASONA HABITABLE 10x8 m (M18-BIS)
# Checklist M18-BIS: "Casa amplia / casona (10x8 m: sala + 2 dormitorios +
# cocina)".
#
# ESCALON 3 de 5 en la progresion de vivienda: choza (5x4) -> casa mediana
# (16x12) -> CASONA (10x8) -> mansion (14x10) -> casa de vecino.
# Lenguaje visual, a proposito, DISTINTO al de la choza (log 808):
#   - techo de TABLONES de madera oscura, NO paja (la paja ES la choza)
#   - piso de TABLONES en sala y dormitorios; losa de PIEDRA en la cocina
#     (la cocina es la unica zona con fuego: piedra = seguridad + lectura)
#   - muros de madera clara con 6 ventanas (la choza tenia 2): la casona es
#     mas luminosa y eso se lee desde fuera
#   - PORTICO de entrada con 2 postes (la choza no tiene: es el salto de
#     "refugio" a "casa")
#   - chimenea de piedra que ATRAVIESA el techo (señal "hogar", aprendida en
#     la v8 de la casa mediana y reaplicada en la choza)
#
# PLANTA (interior 9.64 x 7.64):
#   +-------------------------------------------+ Y=+3.82
#   |                  SALA                     |
#   |              (9.64 x 3.82)                |
#   +------[ ]--------[    ]--------[ ]---------+ Y=0  (tabique, 3 vanos)
#   | DORM 1 |      COCINA      |    DORM 2     |
#   | 3.15   |      3.06        |    3.15       |
#   +-------------------------------------------+ Y=-3.82
# X=-4.82                                    X=+4.82
# Cada dormitorio y la cocina tienen su vano sobre la sala: los 3 se ven
# desde la puerta, asi que la planta se entiende de una sola mirada.
#
# COTAS: exterior 10.0 (X) x 8.0 (Y), muros 0.18 esp / 3.00 alto, zocalo 0.30,
# cumbrero 1.45 sobre semiluz 4.08 -> PENDIENTE 19.6 deg (a proposito: 12 deg
# leia "galpon" en la v5 de la casa mediana, 29 deg es choza; 19.6 lee "casa").
#
# PRESUPUESTO: 30 SM_ > 16, amparado por la excepcion de casas grandes del
# plan §6.1 (sub-grupos <=16 SM_ por ambiente; la casa mediana v8 usa 60).
# Tris y mats SI entran en el limite duro M166 §3.3: <=6000 tris / <=12 mats.
#
# NOMBRES por sub-grupo (Godot oculta SM_Techo_* al entrar y encuentra
# SM_Mueble_* interactivos RF7):
#   SM_Techo_* · SM_Mueble_* · SM_Zocalo/Piso/Muro/Tabique/Puerta/Ventana_*
#
# Asentado: z_min = 0.045 del GRUPO medido sobre VERTICES REALES (E-24).
# Ejecutar: blender -b --python crear_casa_casona_lowpoly.py (headless OK)
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

# ============ 2) Materiales (mismo set que choza/mediana = coherencia) ======
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
MAT_acento        = crear_mat('MAT_Casa_Acento',        (0.55, 0.18, 0.12))

# ============ 3) Set de captura (NO viaja al GLB: sin prefijo SM_) ============
bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=11.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.0))

# ============ 4) Constantes ============
Z_APOYO   = 0.045
ANCHO_X   = 10.0
FONDO_Y   = 8.0
MURO_ESP  = 0.18
MURO_ALTO = 3.00
PISO_Z    = 0.105          # cara superior del pavement (se camina ahi)
TECHO_Z   = MURO_ALTO + Z_APOYO          # 3.045 = cabeza de los muros
CUMBRERO_H = 1.45
ALERO_Y   = FONDO_Y / 2 + 0.08           # 4.08
PEND      = math.atan2(CUMBRERO_H, ALERO_Y)   # 19.57 deg
LARGO     = math.sqrt(CUMBRERO_H ** 2 + ALERO_Y ** 2)   # 4.330
MEDIO_Y   = ALERO_Y / 2                  # 2.04
TOP_MURO  = Z_APOYO + MURO_ALTO          # 3.045

# Interior
IX0, IX1 = -(ANCHO_X - 2 * MURO_ESP) / 2, (ANCHO_X - 2 * MURO_ESP) / 2   # -4.82 .. 4.82
IY0, IY1 = -(FONDO_Y - 2 * MURO_ESP) / 2, (FONDO_Y - 2 * MURO_ESP) / 2   # -3.82 .. 3.82
TAB_ESP  = 0.14            # tabiques interiores mas finos que los muros
TAB_X    = 1.60            # tabiques verticales dorm1|cocina|dorm2
VANO_ALTO = 2.05           # altura libre de los vanos interiores

# Puerta principal (muro frontal Y+): X[-0.50, 0.50]
PUER_X0, PUER_X1 = -0.50, 0.50
PUER_Z1 = PISO_Z + 2.10
# Ventanas 0.80 x 1.00
VENT_W  = 0.80
VENT_Z0 = 1.00
VENT_Z1 = 2.00
# posiciones: 2 al frente (flanqueando la puerta), 2 al fondo (1 por dormitorio),
# 1 por lateral (las 2 en la sala, que es el ambiente de estar)
VENT_X_F = (-2.30, 2.30)       # muro frontal
VENT_X_B = (-3.05, 3.05)       # muro trasero
VENT_Y_L = (1.60,)             # muro X-
VENT_Y_R = (1.60,)             # muro X+

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

def tramos_con_vanos(a0, a1, vanos):
    """
    Parte un tramo [a0, a1] en sub-tramos saltando los vanos.
    vanos: lista de (a_ini, a_fin, z_ini, z_fin). Devuelve lista de
    (a_ini, a_fin, z_ini, z_fin) de muro LLENO. Un vano con z_ini == Z_APOYO
    no genera pretil (es una puerta, se entra a ras de piso).
    """
    cortes = sorted(set([a0, a1] + [v[0] for v in vanos] + [v[1] for v in vanos]))
    out = []
    for i in range(len(cortes) - 1):
        x0, x1 = cortes[i], cortes[i + 1]
        if x1 - x0 < 1e-6:
            continue
        cubre = [v for v in vanos if v[0] <= x0 + 1e-6 and v[1] >= x1 - 1e-6]
        if not cubre:
            out.append((x0, x1, Z_APOYO, TOP_MURO))
            continue
        v = cubre[0]
        if v[2] > Z_APOYO + 1e-6:                      # pretil bajo el vano
            out.append((x0, x1, Z_APOYO, v[2]))
        if v[3] < TOP_MURO - 1e-6:                     # dintel sobre el vano
            out.append((x0, x1, v[3], TOP_MURO))
    return out

# ============ 6) ZOCALO de piedra (perimetro, 1 mesh) ============
z_seg = []
z_seg.append(caja('Z_I', MAT_piedra, ANCHO_X, MURO_ESP, 0.30, 0,  (FONDO_Y - MURO_ESP) / 2, Z_APOYO + 0.15))
z_seg.append(caja('Z_D', MAT_piedra, ANCHO_X, MURO_ESP, 0.30, 0, -(FONDO_Y - MURO_ESP) / 2, Z_APOYO + 0.15))
z_seg.append(caja('Z_L', MAT_piedra, MURO_ESP, FONDO_Y - 2 * MURO_ESP, 0.30, -(ANCHO_X - MURO_ESP) / 2, 0, Z_APOYO + 0.15))
z_seg.append(caja('Z_R', MAT_piedra, MURO_ESP, FONDO_Y - 2 * MURO_ESP, 0.30,  (ANCHO_X - MURO_ESP) / 2, 0, Z_APOYO + 0.15))
# esquinas de piedra oscura (sillares): 4
for cx, cy in ((-ANCHO_X / 2, FONDO_Y / 2), (-ANCHO_X / 2, -FONDO_Y / 2),
               (ANCHO_X / 2, FONDO_Y / 2), (ANCHO_X / 2, -FONDO_Y / 2)):
    z_seg.append(caja('Z_E', MAT_piedra_oscura, MURO_ESP + 0.05, MURO_ESP + 0.05, 0.36,
                      cx, cy, Z_APOYO + 0.18))
SM_zocalo = join('SM_Zocalo_Perimetro', z_seg)

# ============ 7) PISOS (3 meshes: sala / dormitorios / cocina) ============
# Sala y dormitorios = TABLONES de madera clara. Cocina = losa de PIEDRA: es la
# unica zona con fuego y la piedra lo dice sinCartel. 3 SM_ y no 1 porque en
# Godot queremos poder cambiar el piso de un ambiente sin tocar los otros.
def piso_tablas(nombre, x0, x1, y0, y1, mat):
    seg = [caja('P', mat, x1 - x0, y1 - y0, 0.06, (x0 + x1) / 2, (y0 + y1) / 2, Z_APOYO + 0.03)]
    # juntas de tablon: listones finos cada ~0.8 m, en la MISMA mesh
    n = max(1, int((y1 - y0) / 0.9))
    for i in range(n + 1):
        yy = y0 + i * (y1 - y0) / n
        if abs(yy - y0) < 1e-6 or abs(yy - y1) < 1e-6:
            continue
        seg.append(caja('J', MAT_madera_oscura, x1 - x0, 0.03, 0.01,
                        (x0 + x1) / 2, yy, PISO_Z + 0.005))
    return join(nombre, seg)

SM_piso_sala = piso_tablas('SM_Piso_Sala', IX0, IX1, 0.0, IY1, MAT_madera_clara)
SM_piso_dorm = join('SM_Piso_Dormitorios', [
    piso_tablas('D1', IX0, -TAB_X - TAB_ESP / 2, IY0, 0.0, MAT_madera_clara),
    piso_tablas('D2', TAB_X + TAB_ESP / 2, IX1, IY0, 0.0, MAT_madera_clara)])
SM_piso_cocina = caja('SM_Piso_Cocina', MAT_piedra,
                      (TAB_X - TAB_ESP / 2) - (-TAB_X + TAB_ESP / 2),
                      IY1 - IY0, 0.06, 0.0, (IY0 + 0.0) / 2, Z_APOYO + 0.03)

# ============ 8) MUROS EXTERIORES con vanos reales ============
def muro_paralelo_X(nombre, y_c, vanos):
    """Muro frontal/trasero (corre en X). vanos: (x0, x1, z0, z1)."""
    seg = []
    for (x0, x1, z0, z1) in tramos_con_vanos(-ANCHO_X / 2, ANCHO_X / 2, vanos):
        seg.append(caja('Seg', MAT_madera_clara, x1 - x0, MURO_ESP, z1 - z0,
                        (x0 + x1) / 2, y_c, (z0 + z1) / 2))
    return join(nombre, seg)

def muro_paralelo_Y(nombre, x_c, vanos):
    """Muro lateral (corre en Y). vanos: (y0, y1, z0, z1)."""
    seg = []
    for (y0, y1, z0, z1) in tramos_con_vanos(-FONDO_Y / 2, FONDO_Y / 2, vanos):
        seg.append(caja('Seg', MAT_madera_clara, MURO_ESP, y1 - y0, z1 - z0,
                        x_c, (y0 + y1) / 2, (z0 + z1) / 2))
    return join(nombre, seg)

Y_F = (FONDO_Y - MURO_ESP) / 2      # 3.91
Y_B = -Y_F
X_L = -(ANCHO_X - MURO_ESP) / 2     # -4.91
X_R = 4.91

vanos_frente = [(PUER_X0, PUER_X1, Z_APOYO, PUER_Z1)]
for vx in VENT_X_F:
    vanos_frente.append((vx - VENT_W / 2, vx + VENT_W / 2, VENT_Z0, VENT_Z1))

vanos_fondo = [(vx - VENT_W / 2, vx + VENT_W / 2, VENT_Z0, VENT_Z1) for vx in VENT_X_B]
vanos_izq = [(vy - VENT_W / 2, vy + VENT_W / 2, VENT_Z0, VENT_Z1) for vy in VENT_Y_L]
vanos_der = [(vy - VENT_W / 2, vy + VENT_W / 2, VENT_Z0, VENT_Z1) for vy in VENT_Y_R]

SM_muro_f = muro_paralelo_X('SM_Muro_F', Y_F, vanos_frente)
SM_muro_b = muro_paralelo_X('SM_Muro_B', Y_B, vanos_fondo)
SM_muro_l = muro_paralelo_Y('SM_Muro_L', X_L, vanos_izq)
SM_muro_r = muro_paralelo_Y('SM_Muro_R', X_R, vanos_der)

# ============ 9) TABIQUES INTERIORES ============
# Tabique principal en Y=0 con 3 vanos (dorm1 / cocina / dorm2). Los vanos
# arrancan en Z_APOYO: son pasos, no ventanas, y no llevan hoja (asi el
# jugador ve la circulacion de la planta de un vistazo).
Y_TAB = 0.0
vanos_tabique = [
    (-3.70, -2.70, Z_APOYO, PISO_Z + VANO_ALTO),   # dorm 1
    (-0.70,  0.70, Z_APOYO, PISO_Z + VANO_ALTO),   # cocina (mas ancho)
    ( 2.70,  3.70, Z_APOYO, PISO_Z + VANO_ALTO),   # dorm 2
]
seg = []
for (x0, x1, z0, z1) in tramos_con_vanos(IX0, IX1, vanos_tabique):
    seg.append(caja('Seg', MAT_madera_clara, x1 - x0, TAB_ESP, z1 - z0,
                    (x0 + x1) / 2, Y_TAB, (z0 + z1) / 2))
SM_tabique_principal = join('SM_Tabique_Principal', seg)

# 2 tabiques en X = +-1.60, del fondo (IY0) hasta el tabique principal (Y=0)
seg = []
for s in (-1, 1):
    seg.append(caja('Seg', MAT_madera_clara, TAB_ESP, IY1 - IY0, MURO_ALTO,
                    s * TAB_X, (IY0 + 0.0) / 2, Z_APOYO + MURO_ALTO / 2))
SM_tabiques_dorm = join('SM_Tabiques_Dorm', seg)

# ============ 10) PUERTA principal (marco + hoja abierta) ============
pm = []
pm.append(caja('J', MAT_madera_oscura, 0.09, 0.22, 2.10, PUER_X0 - 0.045, Y_F, PISO_Z + 1.05))
pm.append(caja('J', MAT_madera_oscura, 0.09, 0.22, 2.10, PUER_X1 + 0.045, Y_F, PISO_Z + 1.05))
pm.append(caja('J', MAT_madera_oscura, 1.08, 0.22, 0.10, 0, Y_F, PUER_Z1 + 0.05))
pm.append(caja('U', MAT_piedra, 1.16, 0.30, 0.06, 0, Y_F, PISO_Z - 0.02))
SM_puerta_marco = join('SM_Puerta_Marco', pm)

ang = math.radians(38.0)
ANCHO_HOJA = PUER_X1 - PUER_X0
HOJA_ALTO = 2.04
ph = []
ph.append(caja('H', MAT_madera_oscura, ANCHO_HOJA, 0.07, HOJA_ALTO,
               PUER_X0 + ANCHO_HOJA / 2 * math.cos(ang),
               Y_F - ANCHO_HOJA / 2 * math.sin(ang),
               PISO_Z + HOJA_ALTO / 2, rot=(0, 0, ang)))
for zr in (0.55, 1.45):
    ph.append(caja('R', MAT_madera_clara, 0.90, 0.02, 0.07,
                   PUER_X0 + 0.48 * math.cos(ang),
                   Y_F - 0.48 * math.sin(ang), PISO_Z + zr, rot=(0, 0, ang)))
ph.append(cilindro('P', MAT_bronce, 0.035, 0.08,
                   PUER_X0 + 0.88 * math.cos(ang),
                   Y_F - 0.88 * math.sin(ang), PISO_Z + 1.05, verts=8))
SM_puerta_hoja = join('SM_Puerta_Hoja', ph)

# ============ 11) VENTANAS (6: marcos+casings 1 mesh, vidrio otro) ============
def ventana(nombre_parcial, cx, cy, lateral):
    zc = (VENT_Z0 + VENT_Z1) / 2
    h = VENT_Z1 - VENT_Z0
    prof = MURO_ESP + 0.04
    fr = []
    if lateral:      # muro que corre en Y: el vano se abre en X
        fr.append(caja('A', MAT_madera_oscura, prof, VENT_W, 0.05, cx, cy, VENT_Z0 + 0.025))
        fr.append(caja('A', MAT_madera_oscura, prof, VENT_W, 0.05, cx, cy, VENT_Z1 - 0.025))
        fr.append(caja('A', MAT_madera_oscura, prof, 0.05, h, cx, cy - VENT_W / 2 + 0.025, zc))
        fr.append(caja('A', MAT_madera_oscura, prof, 0.05, h, cx, cy + VENT_W / 2 - 0.025, zc))
        fr.append(caja('A', MAT_acento, prof + 0.02, VENT_W + 0.16, 0.05, cx, cy, VENT_Z0 - 0.02))
        fr.append(caja('A', MAT_acento, prof + 0.02, VENT_W + 0.16, 0.05, cx, cy, VENT_Z1 + 0.02))
        fr.append(caja('A', MAT_acento, prof + 0.02, 0.05, h + 0.12, cx, cy - VENT_W / 2 - 0.08, zc))
        fr.append(caja('A', MAT_acento, prof + 0.02, 0.05, h + 0.12, cx, cy + VENT_W / 2 + 0.08, zc))
    else:            # muro que corre en X: el vano se abre en Y
        fr.append(caja('A', MAT_madera_oscura, VENT_W, prof, 0.05, cx, cy, VENT_Z0 + 0.025))
        fr.append(caja('A', MAT_madera_oscura, VENT_W, prof, 0.05, cx, cy, VENT_Z1 - 0.025))
        fr.append(caja('A', MAT_madera_oscura, 0.05, prof, h, cx - VENT_W / 2 + 0.025, cy, zc))
        fr.append(caja('A', MAT_madera_oscura, 0.05, prof, h, cx + VENT_W / 2 - 0.025, cy, zc))
        fr.append(caja('A', MAT_acento, VENT_W + 0.16, prof + 0.02, 0.05, cx, cy, VENT_Z0 - 0.02))
        fr.append(caja('A', MAT_acento, VENT_W + 0.16, prof + 0.02, 0.05, cx, cy, VENT_Z1 + 0.02))
        fr.append(caja('A', MAT_acento, 0.05, prof + 0.02, h + 0.12, cx - VENT_W / 2 - 0.08, cy, zc))
        fr.append(caja('A', MAT_acento, 0.05, prof + 0.02, h + 0.12, cx + VENT_W / 2 + 0.08, cy, zc))
    return join(nombre_parcial, fr)

marcos, vidrios = [], []
for vx in VENT_X_F:
    marcos.append(ventana('VF', vx, Y_F, False))
for vx in VENT_X_B:
    marcos.append(ventana('VB', vx, Y_B, False))
for vy in VENT_Y_L:
    marcos.append(ventana('VL', X_L, vy, True))
for vy in VENT_Y_R:
    marcos.append(ventana('VR', X_R, vy, True))
SM_ventana_marco = join('SM_Ventana_Marco', marcos)

for vx in VENT_X_F:
    vidrios.append(caja('V', MAT_vidrio, VENT_W - 0.06, 0.02, VENT_Z1 - VENT_Z0 - 0.06, vx, Y_F, (VENT_Z0 + VENT_Z1) / 2))
for vx in VENT_X_B:
    vidrios.append(caja('V', MAT_vidrio, VENT_W - 0.06, 0.02, VENT_Z1 - VENT_Z0 - 0.06, vx, Y_B, (VENT_Z0 + VENT_Z1) / 2))
for vy in VENT_Y_L:
    vidrios.append(caja('V', MAT_vidrio, 0.02, VENT_W - 0.06, VENT_Z1 - VENT_Z0 - 0.06, X_L, vy, (VENT_Z0 + VENT_Z1) / 2))
for vy in VENT_Y_R:
    vidrios.append(caja('V', MAT_vidrio, 0.02, VENT_W - 0.06, VENT_Z1 - VENT_Z0 - 0.06, X_R, vy, (VENT_Z0 + VENT_Z1) / 2))
SM_ventana_vidrio = join('SM_Ventana_Vidrio', vidrios)

# ============ 12) TECHO de TABLONES a dos aguas + FRONTONES ============
# Signo de la rotacion: rot X = -PEND*s (con +PEND*s el alero sube y el centro
# baja => V colgante, bug ya corregido en la v5 de la casa mediana).
tcho = []
tcho.append(caja('C', MAT_acento, ANCHO_X + 0.30, 0.15, 0.15, 0, 0, TECHO_Z + CUMBRERO_H))
for s in (-1, 1):
    tcho.append(caja('Tab', MAT_madera_oscura, ANCHO_X + 0.20, LARGO + 0.10, 0.10,
                     0, s * MEDIO_Y, TECHO_Z + CUMBRERO_H / 2, rot=(-PEND * s, 0, 0)))
# franja de paja clara bajo el alero: recuerdo del lenguaje de la choza, la
# casona es el escalon siguiente y conserva la costumbre (lectura de capa)
for s in (-1, 1):
    tcho.append(caja('Borde', MAT_paja_clara, ANCHO_X + 0.20, 0.34, 0.07,
                     0, s * (ALERO_Y - 0.18), TECHO_Z + 0.13, rot=(-PEND * s, 0, 0)))
# cabios vistos bajo el alero (6 por lado: la casona es ancha)
for s in (-1, 1):
    for i in range(6):
        x_c = -ANCHO_X / 2 + 0.9 + i * (ANCHO_X - 1.8) / 5
        tcho.append(caja('Cab', MAT_madera_oscura, 0.09, 0.09, 0.40,
                         x_c, s * (FONDO_Y / 2 - 0.16), TECHO_Z - 0.16))
SM_techo = join('SM_Techo_Dos_Aguas', tcho)

def fronton(nombre, x_c):
    """Prisma triangular que cierra el hastial (v7 FIX de la casa mediana)."""
    bm = bmesh.new()
    esp = 0.14
    y0, y1 = -ALERO_Y, ALERO_Y
    zb, zp = TECHO_Z, TECHO_Z + CUMBRERO_H
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
    bm.normal_update()                      # E-99: sin esto valen (0,0,0)
    me = bpy.data.meshes.new('M_' + nombre[3:])
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(ob)
    ob.data.materials.append(MAT_madera_clara)
    return ob

# frontones en la MISMA mesh del techo (E-70): Godot oculta SM_Techo_* completo
SM_techo = join('SM_Techo_Dos_Aguas', [SM_techo,
                                       fronton('SM_Fronton_I', X_L),
                                       fronton('SM_Fronton_D', X_R)])

# ============ 13) PORTICO de entrada (el salto "refugio" -> "casa") ============
Y_PORT = Y_F - 0.45          # 3.46: bajo el alero, no compite con el techo
por = []
for s in (-1, 1):
    por.append(caja('Po', MAT_madera_oscura, 0.14, 0.14, 2.50,
                    s * 1.25, Y_PORT, PISO_Z + 1.25))
por.append(caja('Vg', MAT_madera_oscura, 2.80, 0.16, 0.18, 0.0, Y_PORT, PISO_Z + 2.55))
# escalon de piedra en el acceso
por.append(caja('Es', MAT_piedra, 2.20, 0.45, 0.09, 0.0, Y_F + 0.30, Z_APOYO + 0.045))
SM_porche = join('SM_Porche_Entrada', por)

# ============ 14) MUEBLES (SM_Mueble_* — interactivos RF7) ============
# ---- SALA: sofa + mesa de centro + estanteria + alfombra + lampara de pie ----
# sofa 1.90 (Y) x 0.80 (X) contra el muro X-, mirando al centro
SX, SY = -3.55, 1.40
sof = []
sof.append(caja('B', MAT_tela_roja, 0.80, 1.90, 0.32, SX, SY, PISO_Z + 0.20))
sof.append(caja('R', MAT_tela_roja, 0.16, 1.90, 0.52, SX - 0.32, SY, PISO_Z + 0.50))
for dy in (-0.92, 0.92):
    sof.append(caja('Br', MAT_madera_oscura, 0.80, 0.16, 0.30, SX, SY + dy, PISO_Z + 0.51))
for dx, dy in ((-0.32, -0.82), (0.32, -0.82), (-0.32, 0.82), (0.32, 0.82)):
    sof.append(caja('Pt', MAT_madera_oscura, 0.08, 0.08, 0.18, SX + dx, SY + dy, PISO_Z + 0.09))
SM_mueble_sofa = join('SM_Mueble_Sofa', sof)

# mesa de centro 1.10 x 0.60
MX, MY = -2.15, 1.40
mes = [caja('Tb', MAT_madera_clara, 1.10, 0.60, 0.06, MX, MY, PISO_Z + 0.42)]
for dx, dy in ((-0.47, -0.24), (0.47, -0.24), (-0.47, 0.24), (0.47, 0.24)):
    mes.append(caja('Pt', MAT_madera_oscura, 0.07, 0.07, 0.42, MX + dx, MY + dy, PISO_Z + 0.21))
SM_mueble_mesa_centro = join('SM_Mueble_Mesa_Centro', mes)

# estanteria contra el tabique principal (Y=0), en X+
EX, EY = 3.70, 0.30
est = []
est.append(caja('L1', MAT_madera_oscura, 1.20, 0.06, 0.04, EX, EY, PISO_Z + 0.55))
est.append(caja('L2', MAT_madera_oscura, 1.20, 0.06, 0.04, EX, EY, PISO_Z + 1.15))
est.append(caja('L3', MAT_madera_oscura, 1.20, 0.06, 0.04, EX, EY, PISO_Z + 1.75))
for dx in (-0.58, 0.58):
    est.append(caja('Mt', MAT_madera_clara, 0.06, 0.34, 1.80, EX + dx, EY, PISO_Z + 0.90))
# libros (3 bloques de color): detalle chico unido al mismo mesh (E-96)
for i, mat in enumerate((MAT_acento, MAT_tela_crema, MAT_paja_oscura)):
    est.append(caja('Lb', mat, 0.30, 0.22, 0.26, EX - 0.35 + i * 0.34, EY, PISO_Z + 0.70))
SM_mueble_estanteria = join('SM_Mueble_Estanteria', est)

# alfombra 2.40 x 1.60 (1 sola caja; el fleco son 4 listones en la misma mesh)
alf = [caja('Al', MAT_tela_roja, 2.40, 1.60, 0.03, -2.60, 1.60, PISO_Z + 0.015)]
for s in (-1, 1):
    alf.append(caja('Fl', MAT_tela_crema, 2.40, 0.10, 0.02, -2.60, 1.60 + s * 0.83, PISO_Z + 0.01))
SM_mueble_alfombra = join('SM_Mueble_Alfombra', alf)

# lampara de pie: base + varilla + pantalla (pantalla en la misma mesh, E-96)
LX, LY = -4.30, 2.90
lam = []
lam.append(cilindro('Bs', MAT_piedra_oscura, 0.16, 0.05, LX, LY, PISO_Z + 0.025, verts=10))
lam.append(cilindro('Vr', MAT_bronce, 0.025, 1.30, LX, LY, PISO_Z + 0.70, verts=8))
lam.append(cilindro('Pt', MAT_llama, 0.20, 0.26, LX, LY, PISO_Z + 1.48, verts=10))
SM_mueble_lampara = join('SM_Mueble_Lampara_Pie', lam)

# ---- COCINA: cocina de lena + chimenea que ATRAVIESA el techo + mesa + pozo --
CX, CY = 0.0, -3.15
coc = []
coc.append(caja('Eb', MAT_piedra_oscura, 0.90, 0.62, 0.68, CX, CY, PISO_Z + 0.34))
coc.append(caja('Eh', MAT_piedra_oscura, 0.50, 0.06, 0.38, CX, CY - 0.31, PISO_Z + 0.32))
coc.append(cilindro('Ho', MAT_bronce, 0.14, 0.04, CX, CY, PISO_Z + 0.70, verts=10))
coc.append(cilindro('Fl', MAT_llama, 0.10, 0.14, CX, CY, PISO_Z + 0.77, verts=8))
# La paja/tablon en Y=-3.15 esta en z = TECHO_Z + CUMBRERO_H*(1-|Y|/ALERO_Y)
#   = 3.045 + 1.45*(1 - 3.15/4.08) = 3.045 + 0.331 = 3.376
# el caño (centro PISO_Z+2.05, sz=3.90) llega a PISO_Z+4.00 -> asoma 62 cm.
coc.append(caja('Ec', MAT_piedra, 0.24, 0.24, 3.90, CX, CY, PISO_Z + 2.05))
coc.append(caja('Ecp', MAT_acento, 0.34, 0.34, 0.10, CX, CY, PISO_Z + 4.05))
SM_mueble_cocina = join('SM_Mueble_Cocina_Lena', coc)

MX2, MY2 = -0.55, -1.35
mc = [caja('Tb', MAT_madera_clara, 1.00, 0.70, 0.06, MX2, MY2, PISO_Z + 0.74)]
for dx, dy in ((-0.42, -0.27), (0.42, -0.27), (-0.42, 0.27), (0.42, 0.27)):
    mc.append(caja('Pt', MAT_madera_oscura, 0.07, 0.07, 0.74, MX2 + dx, MY2 + dy, PISO_Z + 0.37))
SM_mueble_mesa_cocina = join('SM_Mueble_Mesa_Cocina', mc)

# pozo de conserva ("nevera rustica"): 4 patas CILINDRICAS, no cajas (E-104/105:
# una caja sola aporta 4 vertices y el guard de apoyo la rechaza; el decimate
# de BAJA se come primero los apoyos chicos -> hay que darles vertices)
NX, NY = 0.95, -1.35
nz = []
for sx, sy in ((-1, -1), (-1, 1), (1, -1), (1, 1)):
    nz.append(cilindro('Pt', MAT_piedra, 0.09, 0.09, NX + sx * 0.34, NY + sy * 0.28, PISO_Z + 0.045, verts=10))
nz.append(caja('Cb', MAT_piedra, 0.86, 0.72, 0.78, NX, NY, PISO_Z + 0.09 + 0.39))
nz.append(caja('Tp', MAT_madera_clara, 0.94, 0.80, 0.06, NX, NY, PISO_Z + 0.09 + 0.81))
SM_mueble_nevera = join('SM_Mueble_Nevera_Pozo', nz)

# ---- DORMITORIO 1 (X-): cama doble + velador + comoda ----
DX, DY = -3.90, -1.70
cd = []
cd.append(caja('Bs', MAT_madera_oscura, 1.44, 1.94, 0.24, DX, DY, PISO_Z + 0.16))
cd.append(caja('Cb', MAT_madera_oscura, 1.44, 0.10, 0.72, DX, DY + 0.97, PISO_Z + 0.48))
cd.append(caja('Co', MAT_tela_crema, 1.36, 1.86, 0.16, DX, DY - 0.04, PISO_Z + 0.36))
for dx in (-0.36, 0.36):
    cd.append(caja('Al', MAT_tela_crema, 0.46, 0.28, 0.10, DX + dx, DY + 0.72, PISO_Z + 0.49))
cd.append(caja('Mt', MAT_tela_roja, 1.38, 1.00, 0.05, DX, DY - 0.38, PISO_Z + 0.46))
SM_mueble_cama_doble = join('SM_Mueble_Cama_Doble', cd)

VX, VY = -2.55, -0.85
vel = [caja('Cb', MAT_madera_clara, 0.44, 0.44, 0.46, VX, VY, PISO_Z + 0.23 + 0.06)]
for sx, sy in ((-1, -1), (-1, 1), (1, -1), (1, 1)):
    vel.append(cilindro('Pt', MAT_madera_oscura, 0.035, 0.06, VX + sx * 0.17, VY + sy * 0.17, PISO_Z + 0.03, verts=8))
# vela + llama juntas en el mismo mesh (E-96 inversa: la llama es la firma)
vel.append(cilindro('Vl', MAT_tela_crema, 0.045, 0.14, VX, VY, PISO_Z + 0.29 + 0.07, verts=8))
vel.append(cilindro('Ll', MAT_llama, 0.03, 0.07, VX, VY, PISO_Z + 0.29 + 0.175, verts=6))
SM_mueble_velador_1 = join('SM_Mueble_Velador_1', vel)

CX2, CY2 = -2.30, -3.30
com = [caja('Cb', MAT_madera_clara, 0.90, 0.48, 0.80, CX2, CY2, PISO_Z + 0.46)]
for dz in (0.20, 0.52):
    com.append(caja('Cj', MAT_madera_oscura, 0.86, 0.02, 0.26, CX2, CY2 - 0.25, PISO_Z + dz))
    com.append(cilindro('Ti', MAT_bronce, 0.035, 0.06, CX2, CY2 - 0.27, PISO_Z + dz, verts=8))
SM_mueble_comoda = join('SM_Mueble_Comoda', com)

# ---- DORMITORIO 2 (X+): cama basica + velador + cuadro ancestral ----
DX2, DY2 = 3.90, -1.70
cb = []
cb.append(caja('Bs', MAT_madera_oscura, 0.94, 1.94, 0.24, DX2, DY2, PISO_Z + 0.16))
cb.append(caja('Cb', MAT_madera_oscura, 0.94, 0.10, 0.72, DX2, DY2 + 0.97, PISO_Z + 0.48))
cb.append(caja('Co', MAT_tela_crema, 0.86, 1.86, 0.16, DX2, DY2 - 0.04, PISO_Z + 0.36))
cb.append(caja('Al', MAT_tela_crema, 0.50, 0.28, 0.10, DX2, DY2 + 0.72, PISO_Z + 0.49))
cb.append(caja('Mt', MAT_tela_crema, 0.88, 0.90, 0.05, DX2, DY2 - 0.40, PISO_Z + 0.46))
SM_mueble_cama_basica = join('SM_Mueble_Cama_Basica', cb)

VX2, VY2 = 2.55, -0.85
vel2 = [caja('Cb', MAT_madera_clara, 0.44, 0.44, 0.46, VX2, VY2, PISO_Z + 0.23 + 0.06)]
for sx, sy in ((-1, -1), (-1, 1), (1, -1), (1, 1)):
    vel2.append(cilindro('Pt', MAT_madera_oscura, 0.035, 0.06, VX2 + sx * 0.17, VY2 + sy * 0.17, PISO_Z + 0.03, verts=8))
vel2.append(cilindro('Vl', MAT_tela_crema, 0.045, 0.14, VX2, VY2, PISO_Z + 0.29 + 0.07, verts=8))
vel2.append(cilindro('Ll', MAT_llama, 0.03, 0.07, VX2, VY2, PISO_Z + 0.29 + 0.175, verts=6))
SM_mueble_velador_2 = join('SM_Mueble_Velador_2', vel2)

# cuadro ancestral sobre el muro X+ (2 peanas CILINDRICAS, E-104)
QX, QY = 4.55, -3.10
cua = []
for s in (-1, 1):
    cua.append(cilindro('Pe', MAT_madera_oscura, 0.07, 0.06, QX, QY + s * 0.22, PISO_Z + 0.03, verts=8))
cua.append(caja('Mr', MAT_madera_oscura, 0.70, 0.10, 0.90, QX, QY, PISO_Z + 0.06 + 0.55))
cua.append(caja('Lm', MAT_tela_crema, 0.58, 0.02, 0.78, QX - 0.03, QY, PISO_Z + 0.06 + 0.55))
SM_mueble_cuadro = join('SM_Mueble_Cuadro_Ancestral', cua)

# ============ 15) SOMBREADO PLANO (low-poly) ============
todos = [o for o in bpy.data.objects if o.name.startswith('SM_')]
sombrear_plano(todos)

# ============ 16) ASENTADO + VERIFICACION (E-12 / E-24 / E-94) ============
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

# ============ 17) REPORTE ============
tris = 0
for o in todos:
    o.data.calc_loop_triangles()
    tris += len(o.data.loop_triangles)
mats = set()
for o in todos:
    for m in o.data.materials:
        if m:
            mats.add(m.name)
print('--- CASONA 10x8 (M18-BIS) ---')
print('SM_: %d objetos | %d tris | %d materiales' % (len(todos), tris, len(mats)))
print('z_min medido en vertices reales: %.4f (E-24)' % z_final)
print('Presupuesto M166 §3.3 ALTA: <=6000 tris / <=12 mats')
print('  tris      : %s' % ('OK' if tris <= 6000 else 'EXCEDE'))
print('  materiales: %s' % ('OK' if len(mats) <= 12 else 'EXCEDE'))
print('  objetos   : %d (excepcion casas grandes, plan §6.1)' % len(todos))
print('Sub-grupos:')
grupos = {}
for o in todos:
    g = o.name.split('_')[1] if len(o.name.split('_')) > 1 else '?'
    grupos[g] = grupos.get(g, 0) + 1
for g in sorted(grupos):
    print('  %-12s %d' % (g, grupos[g]))

# E-92: volumen firmado > 0 => normales hacia afuera
print('--- Volumen firmado por objeto (E-92, >0 = normales OK) ---')
malos = 0
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
    if v <= 0:
        malos += 1
        print('  !!! %-30s %+9.4f m3' % (o.name, v))
print('  objetos con volumen <= 0: %d' % malos)

# guardar
import os
ruta = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..',
                    'casa_casona_lowpoly.blend')
bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(ruta))
print('OK — guardado %s' % os.path.abspath(ruta))
