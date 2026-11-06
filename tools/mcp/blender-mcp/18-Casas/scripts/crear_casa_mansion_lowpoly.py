# crear_casa_mansion_lowpoly.py — MANSION 14x10 m (M18-BIS) — Hy4 / 2026-11-06
#
# Spec MEDIDA, no inventada:
#   DOCUMENTACION/18-Casas/plan-actual/01-Requerimientos.md L205:
#       "Mansion (etapa 4): multi-habitacion 14x10 m, biblioteca/sala de museo"
#                                     L62: etapa 4, 5 ambientes (+ jardin interior),
#       sala de museo, 10 cofres
#                                     L190: altura de techo interior >= 2.60 m
#                                     L195: hueco REAL de puerta 1.00x2.10 m
#                                     L206-209: casas grandes pueden exceder 16 SM_
#       (grupos jerarquicos); excepcion documentada por casa.
#   02-Backlog-Pendientes-Assets.md L62 y CHECKLIST-OBJETOS-BLENDER.md L91:
#       "[ ] Mansion (14x10 m, multi-habitacion, biblioteca + sala de museo)"
#
# BLOQUEO LEVANTADO: el fundador informo en el chat que MiMo ya no esta en la
# flota ("mimo no esta mas en la flota asi que podes trabajar en sus tareas si
# queres"). Respaldo documental: mensaje 271 de agnes-3-flash a Nemotron
# ("M64: MiMo (inactivo)"; flota activa Hy3/Hy4/DS-OC/Nemotron/GLM). La clausula
# de 02 L44 "No retomar mansion ... salvo que MiMo los libere" queda sin sujeto.
#
# PLANTA (exterior 14x10, interior 13.6x9.6). 5 ambientes + patio-jardin:
#   Y=+4.80  +----------------------+-----------------+
#            |      VESTIBULO       |  COCINA/COMEDOR |   banda frontal
#   Y=+1.80  +---[ ]----[    ]-----[ ]---+-----------+   tabique P1 (3 vanos)
#            | BIBLIOTECA |  JARDIN  |  SALA DE MUSEO |
#   Y=-1.40  +---[ ]------+ INTERIOR |                |   tabique P5 (dormitorio)
#            | DORMITORIO |          |                |
#   Y=-4.80  +------------+----------+----------------+
#          X=-6.80     X=-2.20  X=+2.20          X=+6.80
#   P2 (X=+2.40) separa vestibulo/cocina; P3/P4 (X=+-2.20) separan las 3 zonas
#   traseras; P5 (Y=-1.40) separa dormitorio de biblioteca.
#
# LENGUAJE VISUAL (heredado de casona, escalon 3 -> 4):
#   muros de PIEDRA clara (la mansion ya no es de madera), suelo y techo de
#   MADERA oscura, cumbrera/casings/estandarte en TERRACOTA, vidrio + plantas en
#   JADE. PENDIENTE 19.24 deg (regla dura: 12 = galpon, 29 = choza, 19-20 = casa).
#   Chimenea SIEMPRE asomando sobre el techo; frontones en la MISMA mesh del
#   techo (E-70); apoyos chicos en CILINDRO, nunca en caja suelta (E-104/105).
#
# DECISION DE 4 MATERIALES (criterio T-01c/T-01d/T-02/columna_entera):
#   generar_variante.py agrupa por TUPLA de materiales. Si cada objeto SM_ lleva
#   UN solo material y solo hay 4, el merge produce exactamente 4 mallas y la
#   poda --max-mats 4 de BAJA es un NO-OP: ninguna pieza de identidad se blanquea.
#   NO se modifica el script compartido generar_variante.py.
#
# PRESUPUESTO: se busca M166 REAL en los 3 perfiles (ALTA <=16 obj/6000 tris/12
# mats, MEDIA <=8/1500/8, BAJA <=6/700/4), sin invocar la excepcion de casas
# grandes. MEDIA conserva los tris del ALTA (merge lossless), asi que el ALTA
# debe nacer por debajo de 1500 tris; BAJA se deriva con --ratio medido.
#
# DEFECTO MEDIDO EN LA PRIMERA BAJA (ratio 0.48 SIN proteccion):
#   chk_asset.py daba verde (684/700 tris) pero el DECIMATE sobre la malla de
#   piedra fundida se comia 1 de las 4 esquinas del cuerpo (3/4) y el escalon
#   de acceso desaparecia del nivel de apoyo (Y max de 5.4700 -> 5.0000).
#   Mismo defecto que el PLINTO/ABACO de columna_entera (M25, acta 19).
# FIX: el sufijo _NOFUNDIR del derivador excluye a esas dos mallas de poda,
#   merge y decimate; su geometria de identidad viaja intacta a MEDIA y BAJA.
#   Barrido de --ratio MEDIDO con ambas protegidas (6 obj en BAJA):
#     0.38 -> 650 tris | 0.40 -> 676 | 0.42 -> 700 | 0.45 -> 740 (FUERA)
#   En todos: esquinas 4/4, escalon presente, vano de puerta 0 vertices de
#   piedra, 6 zonas interiores con contenido. Se adopta 0.40 por margen de
#   24 tris bajo el techo de 700. Comando de cierre:
#     generar_variante_headless.py -- 18-Casas casa_mansion_lowpoly \
#         --media --baja --ratio 0.40 --max-mats 4
#
# Asentado: z_min = 0.045 medido sobre VERTICES REALES (E-24), no bound_box.
# Ejecutar: blender -b --factory-startup --python crear_casa_mansion_lowpoly.py
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

# ============ 2) Exactamente 4 materiales ============
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

MAT_PIEDRA = crear_mat('MAT_Mansion_Piedra', (0.72, 0.70, 0.65))
MAT_MADERA = crear_mat('MAT_Mansion_Madera', (0.42, 0.29, 0.17))
MAT_ACENTO = crear_mat('MAT_Mansion_Acento', (0.58, 0.20, 0.14))
MAT_JADE   = crear_mat('MAT_Mansion_Jade',   (0.36, 0.60, 0.48), alpha=0.55)

# ============ 3) Set de captura (NO viaja al GLB: sin prefijo SM_) ============
bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=17.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
_base = bpy.context.object
_base.name = 'Base_Arena'
_base.data.materials.append(crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.0))

# ============ 4) Constantes ============
Z_APOYO    = 0.045
ANCHO_X    = 14.0
FONDO_Y    = 10.0
MURO_ESP   = 0.20
MURO_ALTO  = 3.00
PISO_Z     = 0.105
TOP_MURO   = Z_APOYO + MURO_ALTO          # 3.045
CUMBRERO_H = 1.85
ALERO_Y    = FONDO_Y / 2 + 0.30          # 5.30
PEND       = math.atan2(CUMBRERO_H, ALERO_Y)   # 19.24 deg
LARGO      = math.sqrt(CUMBRERO_H ** 2 + ALERO_Y ** 2)
MEDIO_Y    = ALERO_Y / 2
TECHO_Z    = TOP_MURO

IX0, IX1 = -(ANCHO_X - 2 * MURO_ESP) / 2, (ANCHO_X - 2 * MURO_ESP) / 2  # +-6.80
IY0, IY1 = -(FONDO_Y - 2 * MURO_ESP) / 2, (FONDO_Y - 2 * MURO_ESP) / 2  # +-4.80
TAB_ESP  = 0.16
Y_F, Y_B = (FONDO_Y - MURO_ESP) / 2, -(FONDO_Y - MURO_ESP) / 2          # +-4.90
X_L, X_R = -(ANCHO_X - MURO_ESP) / 2, (ANCHO_X - MURO_ESP) / 2          # +-6.90

PUER_X0, PUER_X1 = -0.60, 0.60           # hueco REAL 1.20 x 2.10
PUER_Z1 = PISO_Z + 2.10                   # 2.205
VENT_W  = 0.90
VENT_Z0, VENT_Z1 = 1.15, 2.15
VENT_X_F = (-3.40, 3.40)
VENT_X_B = (-3.40, 3.40)
VENT_Y_L = (0.0,)
VENT_Y_R = (0.0,)

# Chimenea de la cocina: el techo en Y=3.30 esta en
#   TECHO_Z + CUMBRERO_H*(1-3.30/5.30) = 3.045 + 0.698 = 3.743
# el cano llega a PISO_Z+4.15 = 4.255 -> asoma 0.51 m (medicion positiva).
CHIM_X, CHIM_Y = 4.30, 3.30
CHIM_TOP = PISO_Z + 4.15

# ============ 5) Helpers ============
def caja(mat, sx, sy, sz, cx, cy, cz, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(cx, cy, cz), rotation=rot)
    o = bpy.context.object
    o.name = 'Pieza'
    o.scale = (sx, sy, sz)
    o.data.materials.append(mat)
    return o

def cono(mat, r1, h, cx, cy, cz, verts=6):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=0.02,
                                    depth=h, location=(cx, cy, cz))
    o = bpy.context.object
    o.name = 'Pieza'
    o.data.materials.append(mat)
    return o

def join(nombre, objs):
    """Une N objetos en 1 mesh (E-70: contar piezas por mesh, no por caja)."""
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    r = bpy.context.object
    r.name = nombre
    return r

def tramos_con_vanos(a0, a1, vanos):
    """Parte [a0,a1] saltando vanos. Devuelve (ini,fin,z0,z1) de muro LLENO."""
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
        if v[2] > Z_APOYO + 1e-6:
            out.append((x0, x1, Z_APOYO, v[2]))       # pretil
        if v[3] < TOP_MURO - 1e-6:
            out.append((x0, x1, v[3], TOP_MURO))      # dintel
    return out

def segmentos(esp, eje, fijo, a0, a1, vanos):
    """Muro con vanos: eje='X' corre en X (fijo=Y), eje='Y' corre en Y."""
    seg = []
    for (b0, b1, z0, z1) in tramos_con_vanos(a0, a1, vanos):
        if eje == 'X':
            seg.append(caja(MAT_PIEDRA, b1 - b0, esp, z1 - z0,
                            (b0 + b1) / 2, fijo, (z0 + z1) / 2))
        else:
            seg.append(caja(MAT_PIEDRA, esp, b1 - b0, z1 - z0,
                            fijo, (b0 + b1) / 2, (z0 + z1) / 2))
    return seg

# ============ 6) ZOCALO de piedra (4 lados, 1 mesh) ============
_zoc = []
# El zocalo frontal se PARTE en el ancho de la puerta: una franja continua de
# 0.30 m atravesaria el umbral y el "hueco REAL de 1.00x2.10 para entrar
# caminando" (requerimientos L195) seria falso. El escalon exterior SI queda.
_zoc.append(caja(MAT_PIEDRA, PUER_X0 + ANCHO_X / 2, MURO_ESP, 0.30,
                 (-ANCHO_X / 2 + PUER_X0) / 2, Y_F, Z_APOYO + 0.15))
_zoc.append(caja(MAT_PIEDRA, ANCHO_X / 2 - PUER_X1, MURO_ESP, 0.30,
                 (PUER_X1 + ANCHO_X / 2) / 2, Y_F, Z_APOYO + 0.15))
_zoc.append(caja(MAT_PIEDRA, ANCHO_X, MURO_ESP, 0.30, 0, Y_B, Z_APOYO + 0.15))
_zoc.append(caja(MAT_PIEDRA, MURO_ESP, FONDO_Y - 2 * MURO_ESP, 0.30,
                 X_L, 0, Z_APOYO + 0.15))
_zoc.append(caja(MAT_PIEDRA, MURO_ESP, FONDO_Y - 2 * MURO_ESP, 0.30,
                 X_R, 0, Z_APOYO + 0.15))
SM_zocalo = join('SM_Mansion_Zocalo_NOFUNDIR', _zoc)

# ============ 7) PISO (1 losa de madera; 2 alfombras Acento) ============
SM_piso = join('SM_Mansion_Piso', [
    caja(MAT_MADERA, IX1 - IX0, IY1 - IY0, 0.06, 0, 0, Z_APOYO + 0.03),
    caja(MAT_MADERA, IX1 - IX0, 0.04, 0.01, 0, 0.0, PISO_Z + 0.005),
    caja(MAT_MADERA, 0.04, IY1 - IY0, 0.01, 0.0, 0, PISO_Z + 0.005),
])

# ============ 8) MUROS EXTERIORES con vanos REALES ============
_vf = [(PUER_X0, PUER_X1, Z_APOYO, PUER_Z1)]
for vx in VENT_X_F:
    _vf.append((vx - VENT_W / 2, vx + VENT_W / 2, VENT_Z0, VENT_Z1))
_vb = [(vx - VENT_W / 2, vx + VENT_W / 2, VENT_Z0, VENT_Z1) for vx in VENT_X_B]
_vl = [(vy - VENT_W / 2, vy + VENT_W / 2, VENT_Z0, VENT_Z1) for vy in VENT_Y_L]
_vr = [(vy - VENT_W / 2, vy + VENT_W / 2, VENT_Z0, VENT_Z1) for vy in VENT_Y_R]

_mur = []
_mur += segmentos(MURO_ESP, 'X', Y_F, -ANCHO_X / 2, ANCHO_X / 2, _vf)
_mur += segmentos(MURO_ESP, 'X', Y_B, -ANCHO_X / 2, ANCHO_X / 2, _vb)
_mur += segmentos(MURO_ESP, 'Y', X_L, -FONDO_Y / 2, FONDO_Y / 2, _vl)
_mur += segmentos(MURO_ESP, 'Y', X_R, -FONDO_Y / 2, FONDO_Y / 2, _vr)
SM_muro = join('SM_Mansion_Muro', _mur)

# ============ 9) TABIQUES: 5 particiones, 5 ambientes + jardin ============
VANO_TOP = PISO_Z + 2.05     # altura libre de los pasos interiores (2.155 m)
_tab = []
# P1 Y=+1.80: 3 vanos (biblioteca / jardin / museo)
_tab += segmentos(TAB_ESP, 'X', 1.80, IX0, IX1, [
    (-5.20, -4.00, Z_APOYO, VANO_TOP),
    (-0.70, 0.70, Z_APOYO, VANO_TOP),
    (4.00, 5.20, Z_APOYO, VANO_TOP)])
# P2 X=+2.40: vestibulo | cocina
_tab += segmentos(TAB_ESP, 'Y', 2.40, 1.80, IY1, [
    (2.90, 4.00, Z_APOYO, VANO_TOP)])
# P3/P4 X=+-2.20: biblioteca/dormitorio | jardin | museo
_tab += segmentos(TAB_ESP, 'Y', -2.20, IY0, 1.80, [
    (-0.60, 0.60, Z_APOYO, VANO_TOP)])
_tab += segmentos(TAB_ESP, 'Y', 2.20, IY0, 1.80, [
    (-0.60, 0.60, Z_APOYO, VANO_TOP)])
# P5 Y=-1.40: biblioteca | dormitorio
_tab += segmentos(TAB_ESP, 'X', -1.40, IX0, -2.20, [
    (-5.00, -3.90, Z_APOYO, VANO_TOP)])
SM_tabique = join('SM_Mansion_Tabique', _tab)

# ============ 10) PEDRALES: 3 pedestales museo + 4 jardineras + chimenea ===
_ped = []
for px, py in ((3.40, -2.60), (4.60, -2.60), (4.00, -3.70)):
    _ped.append(caja(MAT_PIEDRA, 0.62, 0.62, 0.86, px, py, PISO_Z + 0.43))
for px, py in ((-1.35, -3.60), (1.35, -3.60), (-1.35, 0.90), (1.35, 0.90)):
    _ped.append(caja(MAT_PIEDRA, 0.90, 0.90, 0.34, px, py, PISO_Z + 0.17))
# Hogar de la cocina + cano que ATRAVIESA el techo (regla dura de las casas)
_ped.append(caja(MAT_PIEDRA, 1.00, 0.70, 0.72, CHIM_X, CHIM_Y, PISO_Z + 0.36))
_ped.append(caja(MAT_PIEDRA, 0.28, 0.28, CHIM_TOP - PISO_Z,
                 CHIM_X, CHIM_Y, (PISO_Z + CHIM_TOP) / 2))
# Escalon de acceso
_ped.append(caja(MAT_PIEDRA, 2.40, 0.50, 0.09, 0.0, Y_F + 0.32, Z_APOYO + 0.045))
SM_pedestal = join('SM_Mansion_Pedestal_NOFUNDIR', _ped)

# ============ 11) PUERTA principal (marco + hoja abierta) + portico ============
_pue = []
_pue.append(caja(MAT_MADERA, 0.10, 0.24, 2.10, PUER_X0 - 0.05, Y_F, PISO_Z + 1.05))
_pue.append(caja(MAT_MADERA, 0.10, 0.24, 2.10, PUER_X1 + 0.05, Y_F, PISO_Z + 1.05))
_pue.append(caja(MAT_MADERA, 1.30, 0.24, 0.10, 0, Y_F, PUER_Z1 + 0.05))
_ang = math.radians(38.0)
_pue.append(caja(MAT_MADERA, 1.18, 0.07, 2.04,
                 PUER_X0 + 0.59 * math.cos(_ang),
                 Y_F - 0.59 * math.sin(_ang), PISO_Z + 1.02, rot=(0, 0, _ang)))
# Portico: 2 postes + viga (apoyos chicos -> CILINDRO, E-104/105).
# DEFECTO DETECTADO POR REVISION VISUAL 2026-11-06: la version inicial ponia
# el portico en `Y_F - 0.55 = 4.35`, es decir DENTRO del muro frontal
# (que ocupa 4.80..5.00): en las 6 orbitales no se veia nada. Ademas los
# postes nacian en z=0.105 y flotaban 6 cm sobre Z_APOYO=0.045 (E-13).
# Fix medido: exterior en `Y_F + 0.55 = 5.45` y apoyados en Z_APOYO.
# La viga queda solapada con la cabeza de los postes (sin aire).
PORTICO_Y = Y_F + 0.55
for sx in (-1, 1):
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.11, depth=2.50,
                                        location=(sx * 1.55, PORTICO_Y,
                                                  Z_APOYO + 1.25))
    _o = bpy.context.object
    _o.name = 'Pieza'
    _o.data.materials.append(MAT_MADERA)
    _pue.append(_o)
_pue.append(caja(MAT_MADERA, 3.40, 0.18, 0.20, 0.0, PORTICO_Y,
                 Z_APOYO + 2.55))
SM_puerta = join('SM_Mansion_Puerta', _pue)

# ============ 12) MUEBLES (biblioteca / dormitorio / vestibulo / cocina) ====
_mue = []
# Biblioteca: 2 estanterias contra el muro X-
for ey in (-0.60, 1.00):
    _mue.append(caja(MAT_MADERA, 0.34, 1.30, 1.90, -6.40, ey, PISO_Z + 0.95))
    for dz in (0.55, 1.15, 1.75):
        _mue.append(caja(MAT_MADERA, 0.40, 1.34, 0.06, -6.40, ey, PISO_Z + dz))
# Dormitorio: cama doble + velador
_mue.append(caja(MAT_MADERA, 1.50, 2.00, 0.26, -4.55, -3.20, PISO_Z + 0.17))
_mue.append(caja(MAT_MADERA, 1.50, 0.12, 0.72, -4.55, -2.22, PISO_Z + 0.50))
# Vestibulo: mesa central + 2 sillas
_mue.append(caja(MAT_MADERA, 1.50, 0.80, 0.07, -2.00, 3.20, PISO_Z + 0.74))
for sx in (-1, 1):
    _mue.append(caja(MAT_MADERA, 0.42, 0.42, 0.46, -2.00 + sx * 1.15, 3.20,
                     PISO_Z + 0.23))
# Cocina: mesa de trabajo
_mue.append(caja(MAT_MADERA, 1.20, 0.70, 0.07, 3.20, 2.40, PISO_Z + 0.74))
SM_mueble = join('SM_Mansion_Mueble', _mue)

# ============ 13) Acento: casings, cumbrera, sombrerete, piezas de museo ===
_ace = []
for vx in VENT_X_F:
    _ace.append(caja(MAT_ACENTO, VENT_W + 0.24, MURO_ESP + 0.06, 0.07,
                     vx, Y_F, VENT_Z1 + 0.05))
for vx in VENT_X_B:
    _ace.append(caja(MAT_ACENTO, VENT_W + 0.24, MURO_ESP + 0.06, 0.07,
                     vx, Y_B, VENT_Z1 + 0.05))
for vy in VENT_Y_L:
    _ace.append(caja(MAT_ACENTO, MURO_ESP + 0.06, VENT_W + 0.24, 0.07,
                     X_L, vy, VENT_Z1 + 0.05))
for vy in VENT_Y_R:
    _ace.append(caja(MAT_ACENTO, MURO_ESP + 0.06, VENT_W + 0.24, 0.07,
                     X_R, vy, VENT_Z1 + 0.05))
_ace.append(caja(MAT_ACENTO, ANCHO_X + 0.34, 0.16, 0.16,
                 0, 0, TOP_MURO + CUMBRERO_H + 0.02))          # cumbrera
_ace.append(caja(MAT_ACENTO, 0.40, 0.40, 0.12,
                 CHIM_X, CHIM_Y, CHIM_TOP + 0.06))             # sombrerete
for px, py in ((3.40, -2.60), (4.60, -2.60), (4.00, -3.70)):
    _ace.append(cono(MAT_ACENTO, 0.20, 0.52, px, py, PISO_Z + 1.12))  # piezas museo
# 2 alfombras + estandarte del vestibulo
_ace.append(caja(MAT_ACENTO, 2.60, 1.80, 0.03, -2.00, 3.20, PISO_Z + 0.015))
_ace.append(caja(MAT_ACENTO, 1.80, 1.30, 0.03, 4.60, 0.30, PISO_Z + 0.015))
_ace.append(caja(MAT_ACENTO, 0.06, 0.90, 1.30, 2.35, 3.40, PISO_Z + 1.75))
SM_acento = join('SM_Mansion_Acento', _ace)

# ============ 14) Jade: 6 vidrios + 4 plantas del jardin interior ============
_jad = []
for vx in VENT_X_F:
    _jad.append(caja(MAT_JADE, VENT_W - 0.10, 0.06, VENT_Z1 - VENT_Z0 - 0.10,
                     vx, Y_F, (VENT_Z0 + VENT_Z1) / 2))
for vx in VENT_X_B:
    _jad.append(caja(MAT_JADE, VENT_W - 0.10, 0.06, VENT_Z1 - VENT_Z0 - 0.10,
                     vx, Y_B, (VENT_Z0 + VENT_Z1) / 2))
for vy in VENT_Y_L:
    _jad.append(caja(MAT_JADE, 0.06, VENT_W - 0.10, VENT_Z1 - VENT_Z0 - 0.10,
                     X_L, vy, (VENT_Z0 + VENT_Z1) / 2))
for vy in VENT_Y_R:
    _jad.append(caja(MAT_JADE, 0.06, VENT_W - 0.10, VENT_Z1 - VENT_Z0 - 0.10,
                     X_R, vy, (VENT_Z0 + VENT_Z1) / 2))
for px, py in ((-1.35, -3.60), (1.35, -3.60), (-1.35, 0.90), (1.35, 0.90)):
    _jad.append(cono(MAT_JADE, 0.30, 0.90, px, py, PISO_Z + 0.34 + 0.45))
SM_jade = join('SM_Mansion_Jade', _jad)

# ============ 15) TECHO a dos aguas + FRONTONES en la misma mesh (E-70) =====
_tch = []
_tch.append(caja(MAT_MADERA, ANCHO_X + 0.30, 0.34, 0.12,
                 0, 0, TOP_MURO + CUMBRERO_H - 0.10))     # viga cumbrera
for s in (-1, 1):
    _tch.append(caja(MAT_MADERA, ANCHO_X + 0.20, LARGO + 0.12, 0.12,
                     0, s * MEDIO_Y, TOP_MURO + CUMBRERO_H / 2,
                     rot=(-PEND * s, 0, 0)))
# alero de terracota? No: se deja en Acento para no mezclar materiales.

def fronton(x_c):
    """Prisma triangular que cierra el hastial (v7 FIX casa mediana)."""
    bm = bmesh.new()
    esp = 0.16
    y0, y1 = -ALERO_Y, ALERO_Y
    zb, zp = TOP_MURO, TOP_MURO + CUMBRERO_H
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
    me = bpy.data.meshes.new('M_Fronton')
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new('Pieza', me)
    escena.collection.objects.link(ob)
    ob.data.materials.append(MAT_MADERA)
    return ob

# Convencion MEDIDA del modulo: las 3 casas existentes (choza_ampliada,
# mediana, casona) nombran el techo `SM_Techo_Dos_Aguas`, los prompts M18-BIS
# documentan `SM_Techo_Izq` / `SM_Techo_Der` y el GLB ALTA de casona conserva
# el nodo `SM_Techo_Dos_Aguas`. Se mantiene el prefijo `SM_Techo_` para que un
# futuro ocultado del techo al entrar pueda encontrarlo. OJO: medido hoy, NO
# existe ningun .gd en game/ que haga ese ocultado (0 referencias; solo los
# GLB binarios matchean), asi que esto es convencion de nombre, NO integracion.
SM_techo = join('SM_Techo_Mansion_Dos_Aguas',
                _tch + [fronton(X_L), fronton(X_R)])

# ============ 16) SOMBREADO PLANO ============
todos = [o for o in bpy.data.objects if o.name.startswith('SM_')]
bpy.ops.object.select_all(action='DESELECT')
for o in todos:
    o.select_set(True)
bpy.context.view_layer.objects.active = todos[0]
bpy.ops.object.shade_flat()

# ============ 17) ASENTADO + GUARDIAS POSITIVAS DEL GENERADOR ============
bpy.context.view_layer.update()      # E-94: matrix_world viejo sin update

def vertices_mundo(o):
    return [o.matrix_world @ Vector(v.co) for v in o.data.vertices]

def zmin_real(o):
    return min(v.z for v in vertices_mundo(o))

z_actual = min(zmin_real(o) for o in todos)
for o in todos:
    o.location.z += Z_APOYO - z_actual
bpy.context.view_layer.update()
z_final = min(zmin_real(o) for o in todos)
assert abs(z_final - Z_APOYO) < 1e-6, 'z_min %.6f != %.3f' % (z_final, Z_APOYO)

# Huella de APOYO del CUERPO (no bbox global: el techo vuela 0.30 m y el
# escalon de acceso sobresale 0.47 m, ambos legitimos). Se mide sobre los
# vertices reales del ZOCALO que tocan z_min: debe dar 14.00 x 10.00 exactos.
# Medicion del 2026-11-06: medir sobre `todos` daba 10.4700 por el escalon;
# un assert debil (aceptar cualquier Y) habria dejado pasar una casa de 10.47 m.
apoyo = [v for v in vertices_mundo(SM_zocalo)
         if abs(v.z - Z_APOYO) < 1e-5]
hx = max(v.x for v in apoyo) - min(v.x for v in apoyo)
hy = max(v.y for v in apoyo) - min(v.y for v in apoyo)
assert abs(hx - ANCHO_X) < 1e-4, 'huella X %.4f != 14.00' % hx
assert abs(hy - FONDO_Y) < 1e-4, 'huella Y %.4f != 10.00' % hy
# El escalon es la UNICA pieza de PIEDRA que puede salir del cuerpo: medir y
# acotar la saliente en vez de ignorarla (guardia positiva, no `not` sobre un
# literal). Se mide SOLO sobre SM_pedestal: tras sacar el portico al exterior
# sus postes tambien tocan Z_APOYO en y=5.56, y medir sobre `todos` daria
# 0.5600 (falso roto) aunque el escalon siga perfecto en 0.4700.
saliente = max(v.y for v in vertices_mundo(SM_pedestal)
               if abs(v.z - Z_APOYO) < 1e-5) - FONDO_Y / 2
assert 0.0 < saliente < 0.50, 'saliente del escalon %.4f fuera de (0, 0.50)' % saliente

# Portico: asercion POSITIVA de que EXISTE, esta AFUERA y esta APOYADO.
# Sin esto, un portico enterrado o flotante pasa todos los presupuestos M166.
_base_portico = [v for v in vertices_mundo(SM_puerta)
                 if abs(v.z - Z_APOYO) < 1e-5
                 and 1.40 < abs(v.x) < 1.70]
assert len(_base_portico) >= 20, \
    'portico sin apoyo: %d vertices en Z_APOYO' % len(_base_portico)
assert min(v.y for v in _base_portico) > Y_F + 0.30, \
    'portico enterrado: y_min %.4f (muro frontal en %.2f)' % (
        min(v.y for v in _base_portico), Y_F)

# Techo: la pendiente debe estar en 19-20 deg y la cumbrera por encima del muro
grados = math.degrees(PEND)
assert 19.0 <= grados <= 20.0, 'pendiente %.2f deg fuera de 19-20' % grados
z_cumbrera = max(v.z for v in vertices_mundo(SM_techo))
assert z_cumbrera > TOP_MURO + CUMBRERO_H - 0.01, \
    'cumbrera %.4f por debajo de %.4f' % (z_cumbrera, TOP_MURO + CUMBRERO_H)

# Chimenea: el sombrerete debe asomar SOBRE el techo en su propio Y (union
# positiva contra el aire, no solo "z_min >= 0.045").
z_techo_en_chim = TOP_MURO + CUMBRERO_H * (1.0 - abs(CHIM_Y) / ALERO_Y)
z_sombrerete = max(v.z for v in vertices_mundo(SM_acento)
                   if abs(v.x - CHIM_X) < 0.25 and abs(v.y - CHIM_Y) < 0.25)
assert z_sombrerete > z_techo_en_chim + 0.30, \
    'sombrerete %.4f no asoma sobre techo %.4f' % (z_sombrerete, z_techo_en_chim)

# Hueco REAL de la puerta: ningun vertice de MURO ni de ZOCALO dentro del vano
# a baja altura. Incluir el zocalo es lo que detecta el umbral de 0.30 m que
# hacia inpaseable la puerta (corregido partiendo la franja frontal).
en_vano = [v for o in (SM_muro, SM_zocalo) for v in vertices_mundo(o)
           if abs(v.y - Y_F) < MURO_ESP / 2 + 1e-4
           and PUER_X0 + 0.05 < v.x < PUER_X1 - 0.05
           and v.z < PUER_Z1 - 0.05]
assert not en_vano, 'puerta pintada: %d vertices de muro/zocalo en el hueco' % len(en_vano)

# 4 materiales exactos, 1 por objeto (contrato del derivador de variantes).
for o in todos:
    assert len(o.data.materials) == 1, '%s tiene %d materiales' % (
        o.name, len(o.data.materials))
mats = set(o.data.materials[0].name for o in todos)
assert len(mats) == 4, 'materiales %s' % sorted(mats)

# ============ 18) REPORTE ============
tris = 0
for o in todos:
    o.data.calc_loop_triangles()
    tris += len(o.data.loop_triangles)
print('--- MANSION 14x10 (M18-BIS) ---')
print('SM_: %d objetos | %d tris | %d materiales' % (len(todos), tris, len(mats)))
print('z_min real: %.4f | huella apoyo: %.4f x %.4f' % (z_final, hx, hy))
print('pendiente techo: %.2f deg | cumbrera z=%.4f' % (grados, z_cumbrera))
print('techo en Y=chim: %.4f | sombrerete: %.4f (asoma %.4f m)'
      % (z_techo_en_chim, z_sombrerete, z_sombrerete - z_techo_en_chim))
print('puerta 1.20x2.10: HUECO REAL (0 vertices de muro en el vano)')
print('vertices de apoyo del zocalo: %d | saliente escalon: %.4f m'
      % (len(apoyo), saliente))
print('M166 ALTA: obj %d/16 tris %d/6000 mats %d/12'
      % (len(todos), tris, len(mats)))
print('--- por pieza ---')
for o in sorted(todos, key=lambda x: x.name):
    o.data.calc_loop_triangles()
    print('  %-28s z=%.4f tris=%3d mat=%s'
          % (o.name, zmin_real(o), len(o.data.loop_triangles),
             o.data.materials[0].name))

import os
ruta = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..',
                    'casa_mansion_lowpoly.blend')
bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(ruta))
print('OK — guardado %s' % os.path.abspath(ruta))
