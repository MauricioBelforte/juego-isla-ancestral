# herramienta_util.py — helpers para HERRAMIENTAS DE MANO (M16-Crafting / M13)
#
# Creado 2026-09-04 (log 679) para el batch hacha de hierro / martillo /
# azada / machete. Extrae el patron que ya usaba `crear_hacha_piedra_lowpoly.py`
# (prisma de secciones variables construido con bmesh) para no repetirlo 4 veces.
#
# CONVENCION DE POSE (identica a hacha_piedra, que es el patron del modulo):
#   APOYADA EN LA ARENA — la herramienta SUELTA en el suelo, no en la mano.
#     - Eje largo a lo largo de X: empuñadura en -X, cabeza/filo en +X.
#     - La cabeza (hacha/martillo/azada) tiene su eje largo en Y,
#       PERPENDICULAR al mango, igual que un hacha real.
#     - El filo corre PARALELO al eje del mango (regla del hacha real).
#   Motivo: un asset apoyado satisface la regla dura de "no flotar" (E-12) con
#   una medicion objetiva (z_min == Z_APOYO), mientras que una herramienta
#   "en la mano" no tiene referencia de suelo y depende del rig del NPC.
#   Al equiparla, el codigo de Godot rota y traslada el mismo GLB.
#
# ---------------------------------------------------------------------------
# E-91 — la huella minima de E-50 (min_fp=0.30) es una heuristica para props
#        de ~1 m; para objetos PEQUEÑOS o ALARGADOS hay que pasarla explicita
# ---------------------------------------------------------------------------
# E-50 exige `min(fp_x, fp_y) > 0.30` para descartar el apoyo PUNTUAL (un
# objeto apoyado en una sola arista/esquina: se ve como si flotara o estuviera
# por volcarse). Esa cifra sale de props de ~1 m de lado (muebles, rocas).
#
# FALLA en dos casos legitimos:
#   1. ALARGADOS INTRINSECOS: un mango de 0.70 x 0.05 apoya a lo largo de una
#      GENERATRIZ (una linea, no un punto). Es ESTABLE — la estabilidad la da
#      el eje LARGO — pero fp_y ~ 0.02 y el guard salta.
#   2. OBJETOS PEQUEÑOS: una gema de 0.12 m jamas va a tener 0.30 m de huella;
#      exigirlo es exigir un objeto 3 veces mas grande que el pedido.
#
# REGLA: pasar `min_fp` explicito ~ 0.25 x la MAYOR dimension del objeto, y
# apoyarse en `min_toca >= 8` (que si es universal: mide cuantos vertices
# realmente tocan). Complementar SIEMPRE con las 6 capturas orbitales (E-13),
# que es lo que de verdad descarta la flotacion visual.
import math
import bpy
import bmesh
from mathutils import Vector


# ---------------------------------------------------------------------------
# Prisma de secciones variables (generalizacion del helper de hacha_piedra)
# ---------------------------------------------------------------------------
def cerrar_prisma(bm, anillos):
    """Caras laterales + tapas por abanico a un vertice central.

    `anillos`: lista de listas de BMVert, todos con la misma cantidad,
    ordenados en el mismo sentido. La tapa inicial se invierte para que las
    normales queden hacia afuera.
    """
    n = len(anillos[0])
    for i in range(len(anillos) - 1):
        for k in range(n):
            k2 = (k + 1) % n
            bm.faces.new((anillos[i][k], anillos[i][k2],
                          anillos[i + 1][k2], anillos[i + 1][k]))
    for anillo, invertir in ((anillos[0], True), (anillos[-1], False)):
        centro = bm.verts.new(sum((v.co for v in anillo), Vector()) / n)
        for k in range(n):
            k2 = (k + 1) % n
            if invertir:
                bm.faces.new((centro, anillo[k2], anillo[k]))
            else:
                bm.faces.new((centro, anillo[k], anillo[k2]))
    bm.normal_update()


def punto(eje, t, rx, ry, ang):
    """Mapea una seccion (t, rx, ry) a un punto 3D seguun el eje del prisma."""
    c, s = math.cos(ang), math.sin(ang)
    if eje == 'X':
        return (t, rx * c, ry * s)
    if eje == 'Y':
        return (rx * c, t, ry * s)
    if eje == 'Z':
        return (rx * c, ry * s, t)
    raise ValueError('eje debe ser X, Y o Z (recibido %r)' % eje)


def prisma(nombre, estaciones, eje='X', material=None, lados=8, fase=0.0,
           escena=None):
    """Prisma de secciones variables a lo largo de un eje.

    `estaciones`: lista de (t, rx, ry), de menor a mayor `t`.
        t  = posicion a lo largo del eje
        rx = semieje perpendicular #1
        ry = semieje perpendicular #2
    `eje`: 'X' (tubos/mangos), 'Y' (cabezas de hacha), 'Z' (mangos verticales).
    `lados`: lados de la seccion. 4 = seccion romboidal (ideal para HOJAS:
             lomo grueso + filo fino). 6/8 = seccion redondeada (mangos).
    `fase`: rotacion de la seccion. Con lados=4, fase=pi/4 deja el rombo
             alineado con los ejes (una punta al lomo, otra al filo).

    Devuelve el objeto ya linkado a la escena.
    """
    escena = escena or bpy.context.scene
    me = bpy.data.meshes.new(nombre)
    ob = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(ob)
    bm = bmesh.new()
    anillos = []
    for (t, rx, ry) in estaciones:
        verts = []
        for k in range(lados):
            ang = fase + 2.0 * 3.141592653589793 * k / lados
            verts.append(bm.verts.new(punto(eje, t, rx, ry, ang)))
        anillos.append(verts)
    cerrar_prisma(bm, anillos)
    bm.to_mesh(me)
    bm.free()
    if material is not None:
        ob.data.materials.append(material)
    return ob


def perfil(estaciones, t):
    """Interpola linealmente (rx, ry) del prisma en la posicion `t` de su eje.

    Imprescindible para las piezas que ENVUELVEN a otra (empuñadura de cuero
    sobre el mango, casquillo sobre el mango): si se escriben las estaciones
    "a ojo" la pieza exterior queda por DENTRO de la interior en algunos
    tramos y desaparece. Muestreando el perfil real y sumando un espesor
    constante, el recubrimiento es parejo en toda su longitud.
    """
    assert len(estaciones) >= 2
    if t <= estaciones[0][0]:
        return estaciones[0][1], estaciones[0][2]
    if t >= estaciones[-1][0]:
        return estaciones[-1][1], estaciones[-1][2]
    for i in range(len(estaciones) - 1):
        t0, r0x, r0y = estaciones[i]
        t1, r1x, r1y = estaciones[i + 1]
        if t0 <= t <= t1:
            f = 0.0 if abs(t1 - t0) < 1e-12 else (t - t0) / (t1 - t0)
            return r0x + f * (r1x - r0x), r0y + f * (r1y - r0y)
    raise AssertionError('perfil: t=%.4f fuera de rango' % t)


def recubrimiento(nombre, estaciones, eje, ts, espesor, material, lados=8,
                  fase=0.0, escena=None):
    """Prisma que recubre otro prisma: muestrea `estaciones` en `ts`.

    Cada seccion queda a `espesor` del perfil original, asi que la pieza
    envuelve a la interior de manera pareja. Devuelve el objeto.
    """
    est = [(t,) + tuple(v + espesor for v in perfil(estaciones, t))
           for t in ts]
    return prisma(nombre, est, eje=eje, material=material, lados=lados,
                  fase=fase, escena=escena)


# ---------------------------------------------------------------------------
# Apoyo adaptado a herramientas (E-91)
# ---------------------------------------------------------------------------
def asentar_herramienta(escena, min_toca=8, min_fp=0.02, frac_largo=0.45,
                        z_apoyo=0.045, tol=0.005):
    """Asienta y valida el apoyo de un objeto ALARGADO o PEQUEÑO (E-91).

    NO delega en `plantilla_asset.asentar` porque ese impone
    `min(fp_x, fp_y) > 0.30`, una cifra pensada para props de ~1 m que
    rechaza de forma espuria a cualquier herramienta (ver E-91 arriba).
    Este guard mide lo que de verdad distingue un apoyo REAL de uno PUNTUAL:

      1. `n_toca >= min_toca`  — cuantos vertices tocan (universal).
      2. `min(fp) >= min_fp`   — la huella no es una linea infinitamente
                                 fina (2 cm: mata el apoyo en arista).
      3. `max(fp) >= frac_largo * L` — el contacto recorre al menos el 45 %
                                 del eje LARGO del objeto. ESTE es el que
                                 sustituye al `min(fp) > 0.30`: una pieza
                                 apoyada de punta da max(fp) ~ 0 y salta,
                                 mientras que un mango de 70 cm apoyado a lo
                                 largo da max(fp) ~ 0.5 y pasa.

    Devuelve (z_fin, n_toca, fp_x, fp_y).
    """
    from plantilla_asset import zmin_real, piezas
    bpy.context.view_layer.update()
    ps = piezas(escena)
    assert ps, 'no hay ninguna pieza SM_ en la escena'

    # --- 1) asentar (identico a plantilla_asset.asentar) ---
    z_ini = min(zmin_real(o) for o in ps)
    delta = z_apoyo - z_ini
    for o in ps:
        if o.parent is None:
            o.location.z += delta
    bpy.context.view_layer.update()
    z_fin = min(zmin_real(o) for o in ps)
    print('ASENTADO: z_min %.4f -> %.4f (delta %+.4f)' % (z_ini, z_fin, delta))
    assert abs(z_fin - z_apoyo) < 1e-4, 'z_min %.4f != Z_APOYO %.4f' % (z_fin, z_apoyo)

    # --- 2) vertices que efectivamente tocan ---
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

    # --- 3) tamano propio del objeto (para escalar la exigencia) ---
    todos = [(o.matrix_world @ v.co) for o in ps for v in o.data.vertices]
    Lx = max(p.x for p in todos) - min(p.x for p in todos)
    Ly = max(p.y for p in todos) - min(p.y for p in todos)
    largo = max(Lx, Ly)

    print('HUELLA: toca=%d  footprint=%.2f x %.2f  (objeto %.2f x %.2f)'
          % (len(pts), fp_x, fp_y, Lx, Ly))

    assert len(pts) >= min_toca, \
        'apoyo puntual: solo %d verts tocan el suelo (E-50)' % len(pts)
    assert min(fp_x, fp_y) >= min_fp, \
        ('huella en arista: %.3f x %.3f, el eje corto mide menos de %.3f (E-91)'
         % (fp_x, fp_y, min_fp))
    assert max(fp_x, fp_y) >= frac_largo * largo, \
        ('el contacto (%.2f) no recorre el %.0f%% del eje largo (%.2f): '
         'el objeto apoya de punta o en un solo extremo (E-91)'
         % (max(fp_x, fp_y), frac_largo * 100, largo))
    return z_fin, len(pts), fp_x, fp_y


# ---------------------------------------------------------------------------
# Cierre canonico para herramientas APOYADAS
# ---------------------------------------------------------------------------
def cerrar_herramienta(escena, modulo, asset, loc_cam, mira_cam,
                       min_toca=8, min_fp=0.02, frac_largo=0.45):
    """Asentar (E-91) + luz + camara + flat + auditoria + guardar.

    NO marca `_MONTADO`: estos assets SI tocan el suelo (E-79 no aplica).
    """
    from plantilla_asset import iluminar, camara, shade_flat, guardar
    from montado_util import auditar
    asentar_herramienta(escena, min_toca=min_toca, min_fp=min_fp,
                        frac_largo=frac_largo)
    iluminar(escena)
    camara(escena, 'CAM_' + asset.upper(), loc_cam, mira_cam)
    shade_flat(escena)
    auditar(escena)
    guardar(escena, modulo, asset)
