# hoja_util.py — Hojas y follaje para assets low-poly (M18, M33, M50...).
#
# MOTIVO (2026-09-11, log 811): la memoria del proyecto daba por existente este
# modulo ("Hojas -> scripts-reutilizables/hoja_util.py, no duplicar en cada
# generador") pero el archivo NO estaba en disco: `find` sobre todo el repo no
# devolvia nada. Es decir, la convencion estaba escrita y no cumplida. Se crea
# aca, de una sola vez, para que la maceta de interior y los futuros follajes
# no vuelvan a reinventar la hoja.
#
# QUE HACE hoja_plana_arqueada():
#   Una hoja NO es una caja plana: es una superficie que sale del tallo, sube
#   y despues se desploma. Se modela como un PRISMA DE CONTORNO cerrado
#   (volumen > 0, E-92) barriendo un perfil a lo largo de X:
#       x(t)      = largo * t
#       ancho(t)  = ancho/2 * (0.18 + 0.82 * sin(pi*t)**0.7)   (punta y base finas)
#       alto(t)   = arco * sin(pi*t) - caida * t               (sube y se cae)
#   El contorno se cierra recorriendo un lado con t creciente y el otro con t
#   decreciente; de ahi salen dos anillos (inferior/superior) que se puentean.
#
# CERRADO Y CON VOLUMEN POSITIVO: importa porque el auditor de apoyo usa el
# volumen firmado (E-92) para detectar normales invertidas. Una hoja de una
# sola cara daria volumen ~0 y ensuciaria el diagnostico.
#
# E-99: BMFace.normal vale (0,0,0) hasta llamar a bm.normal_update(). Si se
# clasifican caras por normal sin eso, queda basura. Se llama al final.
import bpy
import bmesh
import math


def _perfil(largo, ancho, arco, caida, seg):
    """Contorno cerrado de la hoja en el plano XY (z se agrega despues).

    Devuelve (puntos, mitades) con `puntos` = lista de (x, y) en orden tal que
    recorrerlos da normal -Z (ver docstring: orden horario visto desde +Z).
    """
    pts = []
    mitad = ancho / 2.0
    # Ida: lado +Y, t creciente
    for i in range(seg):
        t = i / (seg - 1.0)
        w = mitad * (0.18 + 0.82 * math.sin(math.pi * t) ** 0.7)
        pts.append((largo * t, +w, t))
    # Vuelta: lado -Y, t decreciente
    for i in range(seg - 1, -1, -1):
        t = i / (seg - 1.0)
        w = mitad * (0.18 + 0.82 * math.sin(math.pi * t) ** 0.7)
        pts.append((largo * t, -w, t))
    return pts


def hoja_plana_arqueada(nombre, mat, largo=0.34, ancho=0.10, arco=0.16,
                        caida=None, grosor=0.006, seg=7,
                        loc=(0.0, 0.0, 0.0), rot=(0.0, 0.0, 0.0)):
    """Hoja arqueada CERRADA, en espacio local: base en el origen, punta en +X.

    - `arco`: cuanto sube la hoja en su punto mas alto.
    - `caida`: cuanto baja la punta respecto de la base (default 0.6*arco).
    - `rot`: rotacion Z para repartir hojas alrededor del tallo; X/Y para
      inclinarlas. Se APLICA al objeto (no queda como transform pendiente) para
      que `join()` no la deforme (E-83).
    """
    if caida is None:
        caida = arco * 0.6
    perfil = _perfil(largo, ancho, arco, caida, seg)

    mesh = bpy.data.meshes.new(nombre + '_Mesh')
    bm = bmesh.new()
    # Dos anillos: inferior y superior (mismo contorno, desplazado en Z)
    inf = []
    sup = []
    for (x, y, t) in perfil:
        z = arco * math.sin(math.pi * t) - caida * t
        inf.append(bm.verts.new((x, y, z)))
        sup.append(bm.verts.new((x, y, z + grosor)))
    n = len(perfil)

    # Tapas: el contorno en orden da normal -Z -> la tapa inferior va en orden
    # directo y la superior invertida.
    bm.faces.new(inf)
    bm.faces.new(list(reversed(sup)))
    # Laterales: (inf_i, sup_i, sup_i1, inf_i1) da normal hacia AFUERA.
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((inf[i], sup[i], sup[j], inf[j]))

    bm.normal_update()                      # E-99
    bm.to_mesh(mesh)
    bm.free()

    obj = bpy.data.objects.new(nombre, mesh)
    bpy.context.scene.collection.objects.link(obj)
    obj.data.materials.append(mat)
    obj.rotation_euler = rot
    obj.location = loc
    # E-83: join() aplica la matriz inversa -> hornear la transformacion antes.
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    obj.select_set(False)
    return obj


def colocar(obj, loc=(0.0, 0.0, 0.0), rot=(0.0, 0.0, 0.0)):
    """Mueve `obj` y hornea la transformacion (lista para join())."""
    obj.location = loc
    obj.rotation_euler = rot
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    obj.select_set(False)
    return obj


def vol_firmado(obj):
    """Volumen con signo (E-92). > 0 <=> normales hacia afuera."""
    bpy.context.view_layer.update()
    v = 0.0
    for f in obj.data.polygons:
        pts = [obj.matrix_world @ obj.data.vertices[i].co for i in f.vertices]
        for k in range(1, len(pts) - 1):
            v += pts[0].cross(pts[k]).dot(pts[k + 1]) / 6.0
    return v


def desvio_planar(obj, tol=1e-4):
    """Cantidad de caras cuya normal difiere de la del lote (hojas dobladas)."""
    bpy.context.view_layer.update()
    n = len(obj.data.polygons)
    if n == 0:
        return 0
    prom = [0.0, 0.0, 0.0]
    for f in obj.data.polygons:
        v = f.normal
        prom[0] += v.x
        prom[1] += v.y
        prom[2] += v.z
    m = math.sqrt(sum(c * c for c in prom))
    if m < tol:
        return n
    prom = [c / m for c in prom]
    return sum(1 for f in obj.data.polygons
               if abs(f.normal.dot(prom) - 1.0) > 0.02)
