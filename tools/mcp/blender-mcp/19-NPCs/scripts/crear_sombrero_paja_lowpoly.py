# crear_sombrero_paja_lowpoly.py — Sombrero de paja de ala ancha (M19 NPCs)
#
# DIRECTIVA DEL USUARIO (2026-09-02): "los diseños tienen que ser premium,
#   en los npc no podemos escatimar, mejor pocos pero buenos npc".
#   => Nada de "cono + disco". Cada pieza lleva una decision de modelado.
#
# QUE HACE A ESTE SOMBRERO "PREMIUM" (y no un cono con un disco debajo):
#   1. ALA TEJIDA: modulacion radial del radio (ondas=(0.018, 12)) y de la
#      altura del borde (ondas_z=(0.006, 12)). Una elipse perfecta lee como
#      plastico; 12 lobulos leen como paja trenzada. Costo: 0 triangulos.
#   2. ALA QUE CAE: el borde esta 6.3 cm MAS ABAJO que la union con la copa.
#      Un ala plana lee como una bandeja.
#   3. DOBLADILLO: aro de 14 mm en el borde exterior. Da espesor visible
#      (un ala de 1 sola cara se ve como papel de 0 mm de canto).
#   4. CIMA HUNDIDA (pinch): la copa NO termina en punta ni en disco plano,
#      sino en un embudo de 14 mm. Es la diferencia entre un sombrero y un
#      cono de cumpleaños.
#   5. INCLINACION +6° en X (NO -6°): rotacion POSITIVA levanta el ala
#      frontal (+Y, donde estan los ojos) y baja la nuca. Es el gesto
#      "sombrero echado hacia atras". Con -6° el ala TAPABA los ojos.
#      + 4° en Z de yaw para que no parezca puesto con escuadra.
#
# E-79 (NUEVO, este asset): los assets MONTADOS (sombreros, mochilas, alas,
#   armas en mano) NO tocan el suelo. `asentar()` de plantilla_asset los
#   bajaria al piso y ademas reventaria con el guard E-50. Para estos:
#     - el ORIGEN LOCAL es el PUNTO DE MONTAJE (aqui: el centro de la base
#       de la copa), no el centro geometrico. El GLB sale con el pivote
#       listo para colgar del hueso de la cabeza.
#     - la escena de verificacion se arma moviendo el MANIQUI (cabeza con
#       las cotas exactas del NPC base) y la CAMARA. NUNCA el asset.
#     - en vez de E-50 se usa un GUARD DE ENCAJE: que no tape los ojos,
#       que contenga el pelo, que no flote, que no sea una sombrilla.
#
# COTAS DEL NPC BASE (crear_npc_base_lowpoly.py v4) — de ahi sale el encaje:
#   Z_CABEZA=1.440  X_CABEZA=-0.023  Y_CABEZA=-0.006  R_CABEZA=(.132,.118,.160)
#   pelo: (1.490,-0.023,-0.040,.140,.090) (1.540,...,-0.030,.148,.110)
#         (1.580,...,-0.020,.108,.092)    (1.612,...,-0.010,.040,.034)
#   ojos z=1.445 y=0.108 r=0.032 · cejas z=1.485 h=0.018 (sup 1.494)
#   orejas z=1.375 x=+-0.132 · hombro 1.165 · cintura 0.890 · cuello 1.270
#
# SISTEMA DE COORDENADAS del .blend (E-79):
#   origen = punto de montaje del sombrero = centro de la base de la copa.
#   z_abs del origen = Z_REF = 1.548.  El maniqui se expresa en este sistema:
#     z_local = z_abs - Z_REF      x_local = x_abs - X_CABEZA
#     y_local = y_abs - Y_MONTAR   (Y_MONTAR = -0.020, centro de la copa)
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from math import radians
import bpy, bmesh
from mathutils import Vector, Euler
from plantilla_asset import (limpiar, mat, caja, loft, arena, iluminar,
                             piezas, camara, shade_flat, guardar)

# ===========================================================================
# 0) REFERENCIA
# ===========================================================================
Z_REF = 1.548          # altura absoluta del punto de montaje
X_CABEZA = -0.023
Y_CABEZA = -0.006
Y_MONTAR = -0.020      # la copa calza sobre el pelo, no sobre los ojos
R_CABEZA = (0.132, 0.118, 0.160)

GIRAR = (radians(6.0), 0.0, radians(4.0))   # E-79: +6° LEVANTA el ala frontal

# Zonas criticas en LOCAL (para el guard de encaje E-79)
Z_CEJA_SUP = 1.494 - Z_REF      # -0.054  (cejas z=1.485 + h/2)
R_OJO = 0.032
Y_OJO = 0.108 - Y_MONTAR        # 0.128
Y_CEJA = 0.094 - Y_MONTAR       # 0.114


def L(z_abs):
    """Altura absoluta del NPC base -> local del sombrero."""
    return z_abs - Z_REF


def YL(y_abs):
    """Y absoluta del NPC base -> local del sombrero."""
    return y_abs - Y_MONTAR


# ===========================================================================
# 1) Limpieza + materiales
# ===========================================================================
escena = limpiar()

MAT_paja = mat('MAT_paja', (0.86, 0.73, 0.42), rough=0.95, spec=0.05)
MAT_paja_osc = mat('MAT_paja_osc', (0.66, 0.54, 0.29), rough=0.95, spec=0.05)
MAT_cinta = mat('MAT_cinta', (0.58, 0.22, 0.20), rough=0.85, spec=0.10)
MAT_ref = mat('MAT_ref', (0.62, 0.62, 0.64), rough=1.0, spec=0.0)
MAT_ref_osc = mat('MAT_ref_osc', (0.16, 0.15, 0.16), rough=1.0, spec=0.0)

# E-79: el ala y el dobladillo son superficies ABIERTAS (sin tapas). Vistos
# desde abajo serian invisibles con culling de backfaces. glTF soporta
# doubleSided y el exporter lo escribe cuando use_backface_culling=False.
# Costo: 0 triangulos, 0 materiales extra. Alternativa descartada: duplicar
# el ala con una segunda capa (+144 tris y un objeto mas).
MAT_paja.use_backface_culling = False
MAT_paja_osc.use_backface_culling = False

# ===========================================================================
# 2) SOMBRERO — centrado en el ORIGEN (= punto de montaje), sin rotar aun.
#    La rotacion se aplica a los VERTICES al final (no con rotation_euler),
#    porque el lazo tiene su propio origen: rotation_euler lo rotaria sobre
#    si mismo y se despegaria del sombrero (E-79).
# ===========================================================================

# --- 2a) ALA: 4 anillos, de ABAJO (borde exterior) hacia ARRIBA (union) ---
# E-77: z PRIMERO y creciente. El borde esta 6.3 cm mas abajo que la union.
# lados=24 con k=12 => 2 lados por lobulo, la onda cierra exacto.
OND = dict(ondas=(0.018, 12), ondas_z=(0.006, 12))
ala = loft('SM_NPC_Sombrero_Ala', [
    (-0.036, 0.0, 0.0, 0.296, 0.252),   # borde exterior
    (-0.013, 0.0, 0.0, 0.262, 0.222),
    (0.010, 0.0, 0.0, 0.212, 0.180),
    (0.027, 0.0, 0.0, 0.148, 0.124),   # union con la copa
], MAT_paja, lados=24, tapar_arriba=False, tapar_abajo=False, **OND)

# --- 2b) DOBLADILLO: aro de 14 mm en el borde. Mismas ondas => costura
#    exacta con el ala (la modulacion depende solo del angulo).
dobl = loft('SM_NPC_Sombrero_Dobladillo', [
    (-0.050, 0.0, 0.0, 0.300, 0.256),
    (-0.036, 0.0, 0.0, 0.296, 0.252),
], MAT_paja_osc, lados=24, tapar_arriba=False, tapar_abajo=False, **OND)

# --- 2c) COPA: 5 anillos, abierta arriba (la cierra 2d) y abajo (la tapa el
#    pelo). Se estrecha 3.4 cm: no es un cilindro.
ANILLOS_COPA = [
    (0.000, 0.0, 0.0, 0.152, 0.126),   # base: abraza el pelo con 1.2 cm
    (0.037, 0.0, 0.0, 0.146, 0.121),
    (0.077, 0.0, 0.0, 0.137, 0.114),
    (0.117, 0.0, 0.0, 0.127, 0.106),
    (0.152, 0.0, 0.0, 0.118, 0.098),
]
copa = loft('SM_NPC_Sombrero_Copa', ANILLOS_COPA, MAT_paja, lados=16,
            tapar_arriba=False, tapar_abajo=False)

# --- 2d) CIMA HUNDIDA (pinch): embudo de 14 mm. El anillo SUPERIOR coincide
#    con el borde de la copa; el INFERIOR es el fondo. Sin esto la copa
#    termina en punta y lee como gorro de fiesta.
cima = loft('SM_NPC_Sombrero_Cima', [
    (0.138, 0.0, 0.0, 0.028, 0.024),
    (0.152, 0.0, 0.0, 0.118, 0.098),
], MAT_paja, lados=16, tapar_arriba=False, tapar_abajo=True)

# --- 2e) CINTA: aro de 4 cm, 4 mm mas ancha que la copa a esa altura ---
cinta = loft('SM_NPC_Sombrero_Cinta', [
    (0.002, 0.0, 0.0, 0.156, 0.130),
    (0.042, 0.0, 0.0, 0.149, 0.124),
], MAT_cinta, lados=16, tapar_arriba=False, tapar_abajo=False)

# --- 2f) LAZO: 2 alas en V + nudo, sobre el lado derecho de la cinta ---
NUD = (0.156, 0.0, 0.022)
lazo = []
for sgn in (+1, -1):
    ang = sgn * radians(60.0)                 # dir (0.5, +-0.866, 0)
    dx, dy = 0.5, sgn * 0.866
    lazo.append(caja('SM_lazo_al', NUD[0] + 0.042 * dx, NUD[1] + 0.042 * dy,
                     NUD[2], 0.084, 0.014, 0.040, MAT_cinta,
                     rot_euler=(0.0, 0.0, ang)))
lazo.append(caja('SM_lazo_nu', NUD[0], NUD[1], NUD[2],
                 0.028, 0.030, 0.032, MAT_cinta))

# --- 2g) BAKEAR + UNIR (E-75) ---
# E-75: transform_apply en CADA pieza antes del join. El join aplica
# active.matrix_world.inverted() @ obj.matrix_world, y una caja con escala
# no uniforme deformaria a las demas en silencio.
SOMBRERO = [ala, dobl, copa, cima, cinta] + lazo
for o in SOMBRERO:
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

# El lazo son 3 cajas -> 1 objeto (mismo material, asi que el merge por
# material de generar_variante.py no lo cuenta aparte).
bpy.ops.object.select_all(action='DESELECT')
for o in lazo:
    o.select_set(True)
bpy.context.view_layer.objects.active = lazo[0]
bpy.ops.object.join()
lazo_o = bpy.context.object
lazo_o.name = 'SM_NPC_Sombrero_Lazo'
# E-76 + E-35 + E-83: `pop(update_data=)` no existe en 4.x, asi que la
# deduplicacion va con clear(). PERO clear() resetea a 0 el material_index de
# TODAS las caras (E-35) y el lazo terminaria renderizado con un solo
# material. Hay que respaldar los indices y reasignarlos con el mapa
# slot-viejo -> slot-nuevo. Ver `unir()` en crear_npc_base_lowpoly.py.
_vistos = []
_mapa = []
for _m in list(lazo_o.data.materials):
    if _m is None:
        _mapa.append(0)
        continue
    if _m not in _vistos:
        _vistos.append(_m)
    _mapa.append(_vistos.index(_m))
if len(_vistos) != len(lazo_o.data.materials):
    _idx = [_p.material_index for _p in lazo_o.data.polygons]
    lazo_o.data.materials.clear()
    for _m in _vistos:
        lazo_o.data.materials.append(_m)
    for _p, _mi in zip(lazo_o.data.polygons, _idx):
        _p.material_index = _mapa[_mi] if _mi < len(_mapa) else 0


# --- 2h) ROTAR SOBRE EL PIVOTE (E-79) ---
# Rotamos los VERTICES, no el objeto: asi el lazo (que tiene su propio
# origen) gira con el sombrero en vez de sobre si mismo. El pivote (0,0,0)
# se conserva y el asset queda con location/rotation/scale identidad.
def rotar_vertices(objs, euler):
    r = Euler(euler, 'XYZ').to_matrix()
    for o in objs:
        bm = bmesh.new()
        bm.from_mesh(o.data)
        for v in bm.verts:
            v.co = r @ v.co
        bm.to_mesh(o.data)
        bm.free()
        o.data.update()


rotar_vertices([ala, dobl, copa, cima, cinta, lazo_o], GIRAR)

# E-80: el sombrero es un asset MONTADO, no apoyado. Marcar el .blend con un
# Empty `_MONTADO` para que generar_variante.py OMITA el re-asentado.
# El Empty no es geometría y no se exporta (E-44: no tiene prefijo SM_).
bpy.ops.object.empty_add(type='PLAIN_AXES', location=(0.0, 0.0, 0.0))
bpy.context.object.name = '_MONTADO'

# ===========================================================================
# 3) MANIQUI DE REFERENCIA (sin prefijo SM_ => NO se exporta, E-44).
#    Cabeza + pelo con las cotas EXACTAS del NPC base, en el sistema del
#    sombrero, para juzgar encaje y escala en las 6 capturas orbitales.
# ===========================================================================
bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=10, radius=1.0,
                                     location=(0.0, YL(Y_CABEZA), L(1.440)))
ref_cab = bpy.context.object
ref_cab.name = 'REF_Cabeza'
ref_cab.scale = R_CABEZA
ref_cab.data.materials.append(MAT_ref)

# Pelo: mismos anillos que el NPC base (x relativa = x - X_CABEZA = 0)
ref_pelo = loft('REF_Pelo', [
    (L(1.490), 0.0, YL(-0.040), 0.140, 0.090),
    (L(1.540), 0.0, YL(-0.030), 0.148, 0.110),
    (L(1.580), 0.0, YL(-0.020), 0.108, 0.092),
    (L(1.612), 0.0, YL(-0.010), 0.040, 0.034),
], MAT_ref_osc, lados=12)

# Ojos y cejas: la REFERENCIA VISUAL para juzgar si el ala tapa la cara
for sx in (-1, +1):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=6, radius=R_OJO, depth=0.020,
        location=(sx * 0.050, YL(0.108), L(1.445)))
    o = bpy.context.object
    o.name = 'REF_Ojo'
    o.rotation_euler = (radians(90.0), 0.0, 0.0)   # eje +Z -> +Y
    o.data.materials.append(MAT_ref_osc)
    caja('REF_Ceja', sx * 0.052, YL(0.094), L(1.485),
         0.066, 0.014, 0.018, MAT_ref_osc)

# Cuerpo: solo escala visual en la captura
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.052, depth=0.090,
                                    location=(0.0, YL(0.0), L(1.315)))
o = bpy.context.object
o.name = 'REF_Cuello'
o.data.materials.append(MAT_ref)

bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=0.192, radius2=0.202,
                                depth=0.275,
                                location=(0.0, YL(0.0), L(1.0275)))
o = bpy.context.object
o.name = 'REF_Torso'
o.data.materials.append(MAT_ref)

bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=1.0,
                                     location=(0.0, YL(0.0), L(1.165)))
o = bpy.context.object
o.name = 'REF_Hombros'
o.scale = (0.216, 0.118, 0.088)
o.data.materials.append(MAT_ref)

bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=0.190, radius2=0.140,
                                depth=0.840,
                                location=(0.0, YL(0.0), L(0.470)))
o = bpy.context.object
o.name = 'REF_Piernas'
o.data.materials.append(MAT_ref)

# Arena: top absoluto 0.05 -> local L(0.05) = -1.498
ref_arena = arena(radio=1.4)
ref_arena.location.z = L(0.05)
ref_arena.data.materials.append(MAT_ref)

# ===========================================================================
# 4) GUARD DE ENCAJE (E-79) — reemplaza a asentar()/E-50 para assets montados
# ===========================================================================
bpy.context.view_layer.update()


def verts(o):
    return [o.matrix_world @ v.co for v in o.data.vertices]


def radio_copa(z, eje):
    """Semieje de la copa (0=rx, 1=ry) interpolado a la altura z."""
    zs = [a[0] for a in ANILLOS_COPA]
    rs = [a[3] if eje == 0 else a[4] for a in ANILLOS_COPA]
    if z <= zs[0]:
        return rs[0]
    for i in range(len(zs) - 1):
        if z <= zs[i + 1]:
            f = (z - zs[i]) / (zs[i + 1] - zs[i])
            return rs[i] + f * (rs[i + 1] - rs[i])
    return rs[-1]


def verificar_encaje():
    ps = piezas(escena)
    assert ps, 'no hay piezas SM_'
    vs = []
    for o in ps:
        vs.extend(verts(o))

    # (a) NO TAPA LA CARA. Solo la zona de ojos/cejas: un guard sobre todo
    #     y>0 incluiria los costados, donde no hay nada que tapar.
    zona = [v for v in vs if abs(v.x) < 0.10 and v.y > 0.08]
    assert zona, 'E-79(a): el sombrero no tiene vertices sobre la cara!'
    z_cara = min(v.z for v in zona)
    holg = (z_cara - Z_CEJA_SUP) * 100.0
    print('E-79(a) cara: z_min %.4f vs cejas %.4f -> holgura %.1f cm'
          % (z_cara, Z_CEJA_SUP, holg))
    assert holg > 1.0, (
        'E-79(a): el ala tapa la cara (holgura %.1f cm, minimo 1.0). Subi el '
        'ala o la inclinacion en X: recuerda que +X LEVANTA el frente.'
        % holg)

    # (b) LA COPA CONTIENE EL PELO (con 10 % de margen radial)
    fuera, dentro = 0, 0
    for v in verts(ref_pelo):
        if v.z <= 0.005:
            continue                       # pelo bajo la copa: se ve, ok
        t = (v.x / radio_copa(v.z, 0)) ** 2 + (v.y / radio_copa(v.z, 1)) ** 2
        if t > 0.90:
            fuera += 1
        else:
            dentro += 1
    print('E-79(b) pelo dentro de la copa: %d verts, %d rozando' % (dentro, fuera))
    assert fuera == 0, ('E-79(b): %d vertices del pelo asoman por la copa. '
                        'Agrandala o subi el punto de montaje.' % fuera)

    # (c) NO FLOTA: pelo por encima Y por debajo del borde de la copa
    zs = [v.z for v in verts(ref_pelo)]
    arriba = sum(1 for z in zs if z > 0.010)
    abajo = sum(1 for z in zs if z < -0.010)
    print('E-79(c) pelo: %d verts sobre la copa, %d debajo' % (arriba, abajo))
    assert arriba, 'E-79(c): el sombrero flota (el pelo no entra en la copa)'
    assert abajo, 'E-79(c): el sombrero se come toda la cabeza'

    # (d) NO ES UNA SOMBRILLA
    r_max = max((v.x ** 2 + v.y ** 2) for v in vs) ** 0.5
    print('E-79(d) radio max %.3f m (%.0f cm de diametro)' % (r_max, r_max * 200))
    assert r_max < 0.32, 'E-79(d): ala de %.3f m — parece una sombrilla' % r_max

    # (e) NO ATRAVIESA LAS OREJAS (z_abs 1.375 +- 0.026, x = +-0.132)
    oreja_sup = L(1.375) + 0.026
    zona_or = [v for v in vs if abs(abs(v.x) - 0.132) < 0.05 and v.y < YL(0.02)]
    if zona_or:
        z_or = min(v.z for v in zona_or)
        print('E-79(e) orejas: z_min %.4f vs oreja %.4f' % (z_or, oreja_sup))
        assert z_or > oreja_sup, 'E-79(e): el ala atraviesa las orejas'

    zz = [v.z for v in vs]
    print('E-79 OK — z local %.4f..%.4f — %d piezas'
          % (min(zz), max(zz), len(ps)))


verificar_encaje()

# ===========================================================================
# 5) Escena
# ===========================================================================
iluminar(escena)
camara(escena, 'CAM_SOMBRERO', (0.55, -0.72, 0.30), (0.0, 0.0, 0.03))
shade_flat(escena)

# Auditoria de triangulos reales (E-33)
tot = 0
for o in piezas(escena):
    o.data.update()
    o.data.calc_loop_triangles()
    tot += len(o.data.loop_triangles)
print('SM_: %d — triangulos: %d' % (len(piezas(escena)), tot))

guardar(escena, '19-NPCs', 'sombrero_paja')
