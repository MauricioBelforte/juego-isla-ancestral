# crear_cultivo_etapa_lowpoly.py - Hortaliza de cultivo, 4 etapas (M33)
#
# USO (headless, E-45):
#   blender -b --factory-startup --python crear_cultivo_etapa_lowpoly.py -- 3
#
# El argumento despues de `--` es la ETAPA (1..4). Un solo script para las 4
# porque comparten el 95 % del codigo: solo cambian alturas, cantidad de hojas
# y frutos. Asi las 4 etapas quedan coherentes entre si (misma paleta, mismo
# lenguaje de formas), que es justamente lo que exige un cultivo.
#
# MAPEO CON EL DISENO (DOCUMENTACION/33-Agricultura/plan-actual/03-Diseno.md):
#   El enum EtapaCultivo tiene CINCO valores: SEMILLA, Brote, CRECIENDO,
#   MADURA, LISTA. La etapa 0 (SEMILLA, recien plantada) NO necesita mesh de
#   planta: la cubre el tile `Tierra arada`. Por eso hay 4 assets, no 5:
#     1 -> Brote      2 -> CRECIENDO      3 -> MADURA      4 -> LISTA
#   MADURA (3) y LISTA (4) comparten silueta y se distinguen por el FRUTO:
#   verde y chico en MADURA ("falta 1 dia"), rojo y lleno en LISTA.
#
# APOYO (E-91): la planta NO apoya sobre el tallo (un tallo de r=0.02 daria
#   `max(fp) ~ 0.02` y el guard `max(fp) >= 0.45 * largo` saltaria). Cada
#   planta nace de un MONTICULO de tierra (cono truncado cerrado, r=0.14)
#   que aporta 12 vertices en el suelo y huella 0.27 x 0.27. Ademas de
#   cumplir el guard, es lo correcto: una planta cultivada se planta en un
#   pequeño monticulo de tierra suelta.
#
# E-70 (contar ANTES de generar): tope ALTA = 16 SM_.
#   etapa 1: 1 monticulo + 1 tallo + 2 hojas            =  4
#   etapa 2: 1 + 1 + 4                                  =  6
#   etapa 3: 1 + 1 + 6 + 2 frutos                       = 10
#   etapa 4: 1 + 1 + 6 + 3 frutos                       = 11   OK
#
# Presupuesto M166 ALTA: <=16 obj / <=6000 tris / <=12 mats.
#   El mas pesado (etapa 4) ronda 48 (monticulo) + 48 (tallo)
#   + 6 x 20 (hoja solida) + 3 x 48 (fruto) = ~360 tris · 5 mats. Holgado.
import bpy, bmesh, os, sys
from math import cos, sin, pi, radians, sqrt

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, revolucion, loft,
                             piezas, zmin_real)
from herramienta_util import cerrar_herramienta

# --------------------------------------------------------------------------
# Etapa por argumento
# --------------------------------------------------------------------------
_av = sys.argv
_arg = _av[_av.index('--') + 1:] if '--' in _av else []
ETAPA = int(_arg[0]) if _arg else 1
assert ETAPA in (1, 2, 3, 4), 'etapa debe ser 1..4 (recibido %r)' % (_arg,)

#                    asset                h_tallo n_hoj lhoj  ahoj  n_fr r_fr  h_fr  fruto_verde
CFG = {
    1: dict(asset='cultivo_brote',     h=0.105, nh=2, lh=0.090, ah=0.031, nf=0, rf=0.0,   hf=0.0,   verde=True,
            cam=(-0.34, -0.44, 0.26), mira=(0.0, 0.0, 0.085)),
    2: dict(asset='cultivo_creciendo', h=0.300, nh=4, lh=0.165, ah=0.056, nf=0, rf=0.0,   hf=0.0,   verde=True,
            cam=(-0.42, -0.55, 0.33), mira=(0.0, 0.0, 0.205)),
    3: dict(asset='cultivo_madura',    h=0.420, nh=6, lh=0.215, ah=0.072, nf=2, rf=0.026, hf=0.034, verde=True,
            cam=(-0.48, -0.62, 0.42), mira=(0.0, 0.0, 0.290)),
    4: dict(asset='cultivo_lista',     h=0.480, nh=6, lh=0.235, ah=0.079, nf=3, rf=0.031, hf=0.042, verde=False,
            cam=(-0.50, -0.65, 0.47), mira=(0.0, 0.0, 0.330)),
}
C = CFG[ETAPA]

escena = limpiar()

MAT_tierra = mat('MAT_Cultivo_Tierra', (0.27, 0.19, 0.11))
MAT_tallo = mat('MAT_Cultivo_Tallo', (0.31, 0.47, 0.21))
MAT_hoja = mat('MAT_Cultivo_Hoja', (0.40, 0.60, 0.25))
MAT_fruto = mat('MAT_Cultivo_Fruto',
                (0.47, 0.64, 0.23) if C['verde'] else (0.82, 0.23, 0.16))

# --------------------------------------------------------------------------
# Utilidades de geometria
# --------------------------------------------------------------------------
def vol_firmado(bm):
    """Volumen firmado de una malla CERRADA. > 0 ssi las normales apuntan
    hacia afuera (tecnica de E-92). Permite verificar la orientacion de cada
    pieza sin mirar una sola captura."""
    v = 0.0
    for f in bm.faces:
        vs = [x.co for x in f.verts]
        for k in range(1, len(vs) - 1):
            a, b, c = vs[0], vs[k], vs[k + 1]
            v += (a.x * (b.y * c.z - b.z * c.y)
                  - a.y * (b.x * c.z - b.z * c.x)
                  + a.z * (b.x * c.y - b.y * c.x))
    return v / 6.0


def newell(pts):
    nx = ny = nz = 0.0
    for i in range(len(pts)):
        a, b = pts[i], pts[(i + 1) % len(pts)]
        nx += (a[1] - b[1]) * (a[2] + b[2])
        ny += (a[2] - b[2]) * (a[0] + b[0])
        nz += (a[0] - b[0]) * (a[1] + b[1])
    m = sqrt(nx * nx + ny * ny + nz * nz)
    assert m > 1e-9, 'contorno degenerado (Newell nulo)'
    return (nx / m, ny / m, nz / m)


def prisma_contorno(nombre, contorno, grosor, material, escena):
    """Solido a partir de un contorno 3D: tapa + contra-tapa + faldon.

    Se usa para las HOJAS. Una hoja de una sola cara desapareceria al
    mirarla del lado equivocado (culling en Godot), asi que necesita
    espesor real. El orden del faldon es (top_i, bot_i, bot_j, top_j):
    el orden (top_i, top_j, bot_j, bot_i) da normales hacia ADENTRO
    (verificado a mano y por `vol_firmado`).
    """
    n = newell(contorno)
    h = grosor / 2.0
    bm = bmesh.new()
    top = [bm.verts.new((p[0] + n[0] * h, p[1] + n[1] * h, p[2] + n[2] * h))
           for p in contorno]
    bot = [bm.verts.new((p[0] - n[0] * h, p[1] - n[1] * h, p[2] - n[2] * h))
           for p in contorno]
    bm.faces.new(top)
    bm.faces.new(list(reversed(bot)))
    nv = len(contorno)
    for i in range(nv):
        j = (i + 1) % nv
        bm.faces.new((top[i], bot[i], bot[j], top[j]))

    vol = vol_firmado(bm)
    assert vol > 0, '%s: volumen firmado %+.3e -> normales hacia ADENTRO' % (
        nombre, vol)

    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(o)
    o.data.materials.append(material)
    return o, vol


def cruz(a, b):
    return (a[1] * b[2] - a[2] * b[1],
            a[2] * b[0] - a[0] * b[2],
            a[0] * b[1] - a[1] * b[0])


def hoja(nombre, z_att, az, largo, ancho, incl, material, roll=0.0,
         grosor=0.006, estaciones=4):
    """Hoja lanceolada, PLANA y solida, que nace del tallo.

    E-93: la hoja es PLANA a proposito. La version anterior le daba pandeo
    (espina con caida cuadratica) y un pliegue en V para levantar los bordes.
    Quedaba mas bonita sobre el papel, pero era INVIABLE:

      1. El pandeo saca la hoja del plano, asi que el contorno deja de ser
         plano y el "prisma" (tapa + contratapa desplazadas a lo largo de la
         normal MEDIA) se AUTO-INTERSECTA cuando la hoja se curva mas de ~90
         grados. Resultado: volumen firmado NEGATIVO (normales hacia adentro).
      2. Y aunque el solido aguantara, el check de volumen firmado usa
         triangulacion en ABANICO, que solo es valida en caras PLANAS. En una
         cara alabeada el abanico da un numero sin significado: puede dar
         negativo aunque la malla este perfecta.

    El pandeo y la planaridad son mutuamente excluyentes: una hoja plana solo
    puede curvarse DENTRO de su plano, y curvarse dentro del plano significa
    desviarse de costado, no caer. Por eso se descarta el pandeo. La variedad
    la dan `incl` (18 -> 48 grados segun la altura), el azimut por angulo
    aureo y `roll` (giro de la hoja sobre su propio nervio, +-22 grados), que
    mantienen la hoja plana y aun asi rompen el aspecto de helice.
    """
    ci, si = cos(incl), sin(incl)
    d = (ci * cos(az), ci * sin(az), si)          # direccion del nervio
    l0 = (-sin(az), cos(az), 0.0)                 # ancho, sin rotar
    cr, sr = cos(roll), sin(roll)
    n0 = cruz(d, l0)                              # |n0| = 1 (d y l0 son ortonormales)
    lat = tuple(l0[k] * cr + n0[k] * sr for k in range(3))   # Rodrigues sobre d
    n = cruz(d, lat)                              # normal del limbo
    O = (0.0, 0.0, z_att)

    def punto(t, s):
        w = ancho * 4.0 * t * (1.0 - t) * s       # 0 en la base y en la punta
        return tuple(O[k] + d[k] * largo * t + lat[k] * w for k in range(3))

    ts = [i / float(estaciones) for i in range(1, estaciones)]
    cont = [punto(0.0, 0.0)]
    for t in ts:
        cont.append(punto(t, -1.0))
    cont.append(punto(1.0, 0.0))
    for t in reversed(ts):
        cont.append(punto(t, +1.0))
    return prisma_contorno(nombre, cont, grosor, material, escena)


# --------------------------------------------------------------------------
# 1) Monticulo de tierra (E-91: aporta los vertices de apoyo)
# --------------------------------------------------------------------------
# Perfil (r, z): apice abajo -> disco de apoyo -> pared -> disco de tapa.
# Cerrado en ambos extremos del eje => superficie cerrada => vol_firmado
# valida la orientacion sin mirar nada (E-92).
R_MONTE, H_MONTE = 0.14, 0.045
monte = revolucion('SM_Cultivo_Monticulo',
                   [(0.0, 0.0), (R_MONTE, 0.0), (R_MONTE * 0.75, H_MONTE),
                    (0.0, H_MONTE)],
                   materiales=MAT_tierra, lados=12)

# --------------------------------------------------------------------------
# 2) Tallo (ligeramente conico)
# --------------------------------------------------------------------------
Z_TALLO_0 = 0.030                       # nace DENTRO del monticulo (E-24)
Z_TALLO_1 = C['h']
tallo = loft('SM_Cultivo_Tallo',
             [(Z_TALLO_0, 0.0, 0.0, 0.026, 0.026),
              (Z_TALLO_0 + 0.45 * (Z_TALLO_1 - Z_TALLO_0), 0.0, 0.0, 0.020, 0.020),
              (Z_TALLO_1, 0.0, 0.0, 0.013, 0.013)],
             material=MAT_tallo, lados=8)

# --------------------------------------------------------------------------
# 3) Hojas
# --------------------------------------------------------------------------
# Distribucion por ANGULO AUREO (2.39996 rad): es la que usan las plantas
# reales para que ninguna hoja tape a la de arriba, y de paso evita el
# aspecto de "helice" que da un reparto simetrico.
ANG_AUREO = 2.39996323
nh = C['nh']
vols = []
for i in range(nh):
    # t = fraccion de altura a la que se inserta la hoja. Arranca en 0.30 y
    # NO en 0.22: la hoja mas baja debe nacer por encima del borde superior
    # del monticulo (z=0.045) o su vertice pasa a ser el z_min de la escena y
    # `asentar` levantaria TODA la planta para apoyar la hoja, dejando el
    # monticulo flotando (E-12).
    t = 0.30 + 0.65 * (i / float(max(1, nh - 1)))
    z_att = Z_TALLO_0 + t * (Z_TALLO_1 - Z_TALLO_0)
    az = i * ANG_AUREO
    incl = radians(18.0 + 30.0 * t)
    roll = radians(22.0 * sin(i * 1.7))
    largo = C['lh'] * (1.0 - 0.22 * t)
    o, v = hoja('SM_Cultivo_Hoja_%d' % i, z_att, az, largo, C['ah'], incl,
                MAT_hoja, roll=roll)
    vols.append(v)

# --------------------------------------------------------------------------
# 4) Frutos (etapas 3 y 4)
# --------------------------------------------------------------------------
if C['nf']:
    for i in range(C['nf']):
        t = 0.42 + 0.20 * i
        z = Z_TALLO_0 + t * (Z_TALLO_1 - Z_TALLO_0)
        az = 0.9 + 2.1 * i
        off = 0.048
        rf, hf = C['rf'], C['hf']
        # Perfil (r, z) relativo al centro del fruto, cerrado en el eje.
        # Forma de "baya": panza a la mitad, hombros redondeados.
        f = revolucion('SM_Cultivo_Fruto_%d' % i,
                       [(0.0, -hf / 2.0), (rf * 0.72, -hf * 0.30),
                        (rf, 0.0), (rf * 0.80, hf * 0.32), (0.0, hf / 2.0)],
                       materiales=MAT_fruto, lados=8)
        f.location = (off * cos(az), off * sin(az), z)
        # Un fruto es cerrado: el volumen firmado verifica la orientacion.
        _bm = bmesh.new()
        _bm.from_mesh(f.data)
        assert vol_firmado(_bm) > 0, 'fruto %d dado vuelta' % i
        _bm.free()

# --------------------------------------------------------------------------
# Guard: el monticulo tiene que ser lo MAS BAJO de la escena.
# Si una hoja o un fruto cuelga por debajo del borde del monticulo, pasa a
# ser el z_min global y `asentar_herramienta` levanta la planta entera para
# apoyar ESA punta -> el monticulo queda flotando (E-12). Se verifica antes
# de asentar porque despues ya es tarde.
# --------------------------------------------------------------------------
# E-94: `zmin_real` multiplica por `matrix_world`, y esa matriz queda VIEJA
# hasta que se llama a `view_layer.update()`. Los frutos se colocan con
# `o.location = ...` y, sin este update, se miden como si estuvieran en el
# origen: daban z = -0.017 y el guard saltaba por un problema que no existia.
bpy.context.view_layer.update()
_z = {o.name: zmin_real(o) for o in piezas(escena)}
_zmin = min(_z.values())
assert _z['SM_Cultivo_Monticulo'] <= _zmin + 1e-9, (
    'el monticulo NO es lo mas bajo (%.4f) — lo es %s (%.4f): alguna hoja o '
    'fruto cuelga por debajo y la planta flotaria al asentar (E-12)'
    % (_z['SM_Cultivo_Monticulo'],
       min(_z, key=lambda k: _z[k]), _zmin))

# --------------------------------------------------------------------------
# Cierre canonico
# --------------------------------------------------------------------------
arena(radio=0.9)
cerrar_herramienta(escena, '33-Agricultura', C['asset'],
                   loc_cam=C['cam'], mira_cam=C['mira'])

for o in sorted(piezas(escena), key=lambda p: p.name):
    print('   %-24s z %.4f' % (o.name, zmin_real(o)))
print('CULTIVO etapa %d (%s) OK — %d SM_, %d hojas, %d frutos'
      % (ETAPA, C['asset'], len(piezas(escena)), nh, C['nf']))
print('VOLUMEN hojas (todos > 0): %s'
      % ', '.join('%+.2e' % v for v in vols))
