# crear_puente_cuerda_lowpoly.py — Puente de cuerda (M25-Ruinas-Templos)
# Checklist: "Puentes de cuerda (M25)"
#
# Puente colgante de tablones entre dos pares de postes de piedra: 2 cuerdas
# maestras en catenaria que sostienen la pasarela, 2 pasamanos arriba y 10
# colgantes verticales que los unen. Pensado para salvar un hueco entre
# plataformas de ruinas.
#
# Todo en UNA sola malla bmesh y UN solo objeto (E-01): mínima cantidad de
# draw calls y cero parenting, con lo que E-27 queda fuera de juego por
# construcción.
#
# Lecciones aplicadas:
#   E-01  una sola malla y un solo objeto, no primitivas apiladas
#   E-12  asentado MEDIDO en caliente (no calculado de la altura nominal)
#   E-16  winding invertido en tapas/cierres
#   E-21  borrar el .blend@ antes de save_as_mainfile
#   E-32  winding: no deducirlo a mano, MEDIRLO
#   E-33  el presupuesto se mide en triangulos reales, no en caras
#
# ---------------------------------------------------------------------------
# E-32 v2 — el test de orientacion correcto es el VOLUMEN CON SIGNO
# ---------------------------------------------------------------------------
# En la vieira (log 244) documenté dos patrones: recalc + medicion global para
# islas conexas, y recalc + test de centroide para islas convexas. El segundo
# es INCOMPLETO: solo funciona si la isla es convexa. Un tubo que sigue una
# catenaria (como las cuerdas de este puente) NO es convexo, y el test de
# centroide le erraría fuerte.
#
# El test exacto para CUALQUIER isla cerrada (convexa o no) es el volumen con
# signo, por el teorema de la divergencia:
#
#     V = (1/6) * sum_caras sum_k (v0 · (vk × vk+1))
#
# V > 0 -> las normales miran hacia afuera. V < 0 -> la isla esta dada vuelta.
# No depende de la forma, solo de que la isla sea watertight.
#
# Patron final (reemplaza a los dos de E-32 v1):
#     bmesh.ops.recalc_face_normals(bm, faces=isla)   # unifica por topologia
#     if volumen_firmado(bm, isla) < 0.0:
#         bmesh.ops.reverse_faces(bm, faces=isla)     # una sola decision global
# Aplicar UNA VEZ POR ISLA (cada primitiva de este script es su propia isla).
# ---------------------------------------------------------------------------
import bpy
import bmesh
import os
import math
from mathutils import Vector, Euler

# ---------- 1) Limpieza (E-14: NUNCA wm.read_factory_settings por socket) ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.85, spec=0.20, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_piedra = crear_mat('MAT_Piedra_Puente', (0.56, 0.54, 0.50), rough=0.92)
MAT_madera = crear_mat('MAT_Madera_Puente', (0.44, 0.30, 0.18), rough=0.88)
MAT_cuerda = crear_mat('MAT_Cuerda_Puente', (0.74, 0.60, 0.37), rough=0.95)
MAT_arena  = crear_mat('MAT_Arena_Isla',    (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.6, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Parámetros ----------
LARGO    = 2.40            # luz libre entre postes
ANCHO    = 0.90            # ancho de la pasarela
MITAD_X  = LARGO / 2.0     # 1.20
MITAD_Y  = ANCHO / 2.0     # 0.45

Z_CUERDA_EXT = 0.72        # cuerda maestra en los extremos
SAG_CUERDA   = 0.24        # flecha de la catenaria maestra (centro -> 0.48)
Z_PASAM_EXT  = 1.28        # pasamanos en los extremos
SAG_PASAM    = 0.16        # flecha del pasamanos (centro -> 1.12)

H_POST   = 1.40            # altura de los postes de piedra
R_POST   = 0.085           # semilado de la seccion cuadrada del poste

N_TAB    = 13              # tablones de la pasarela
ANCHO_TAB = 0.125          # ancho de cada tablon (eje X)
GROSOR_TAB = 0.030         # espesor del tablon

R_CUERDA = 0.024           # radio de cuerda maestra y pasamanos
LAD_CUERDA = 5             # seccion pentagonal (lowpoly, se ve facetas a proposito)
N_SEG    = 12              # tramos a lo largo de cada cuerda

R_COLGANTE = 0.011         # semilado de los colgantes verticales
HANG_X   = (-0.90, -0.45, 0.0, 0.45, 0.90)

# ---------- 5) Helpers de geometría ----------
bm = bmesh.new()

def volumen_firmado(caras):
    """Volumen con signo de una isla CERRADA (teorema de la divergencia).

    > 0 -> las normales miran hacia afuera. < 0 -> esta dada vuelta.
    Vale para CUALQUIER isla cerrada, convexa o no. Es el test que E-32 v1
    no tenia: el de centroide solo servia para islas convexas.
    """
    v = 0.0
    for f in caras:
        co = [vert.co for vert in f.verts]
        for k in range(1, len(co) - 1):
            v += co[0].dot(co[k].cross(co[k + 1]))
    return v / 6.0

def cerrar_isla(caras):
    """Unifica el winding de una isla y la deja mirando hacia afuera (E-32 v2).

    Se llama UNA vez por isla, no una vez por malla: cada primitiva de este
    script (poste, tablon, cuerda, colgante) es su propia isla.
    """
    bmesh.ops.recalc_face_normals(bm, faces=caras)
    if volumen_firmado(caras) < 0.0:
        bmesh.ops.reverse_faces(bm, faces=caras)
    return caras

def caja(cx, cy, cz, sx, sy, sz, mat):
    """Caja alineada a los ejes. El winding lo arregla `cerrar_isla`."""
    v = []
    for iz in (-1, 1):
        for iy in (-1, 1):
            for ix in (-1, 1):
                v.append(bm.verts.new((cx + ix * sx, cy + iy * sy, cz + iz * sz)))
    # indice = (iz+1)/2*4 + (iy+1)/2*2 + (ix+1)/2
    caras = [
        bm.faces.new((v[0], v[1], v[3], v[2])),   # z-
        bm.faces.new((v[4], v[6], v[7], v[5])),   # z+
        bm.faces.new((v[0], v[4], v[5], v[1])),   # y-
        bm.faces.new((v[2], v[3], v[7], v[6])),   # y+
        bm.faces.new((v[0], v[2], v[6], v[4])),   # x-
        bm.faces.new((v[1], v[5], v[7], v[3])),   # x+
    ]
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

def tubo(centros, radio, lados, mat):
    """Barre un poligono de `lados` lados por la polilinea `centros`.

    El marco de cada anillo se arma con la tangente local, asi que sirve
    igual para una cuerda en catenaria que para un tramo recto.
    """
    anillos = []
    n = len(centros)
    for i in range(n):
        c = Vector(centros[i])
        if n < 2:
            t = Vector((1.0, 0.0, 0.0))
        elif i == 0:
            t = Vector(centros[1]) - c
        elif i == n - 1:
            t = c - Vector(centros[n - 2])
        else:
            t = Vector(centros[i + 1]) - Vector(centros[i - 1])
        if t.length < 1e-9:
            t = Vector((1.0, 0.0, 0.0))
        t.normalize()
        ref = Vector((0.0, 0.0, 1.0)) if abs(t.z) < 0.9 else Vector((1.0, 0.0, 0.0))
        e1 = t.cross(ref).normalized()
        e2 = t.cross(e1).normalized()
        anillo = []
        for k in range(lados):
            a = 2.0 * math.pi * k / lados
            anillo.append(bm.verts.new(c + radio * (math.cos(a) * e1 +
                                                   math.sin(a) * e2)))
        anillos.append(anillo)
    caras = [bm.faces.new(anillos[0]),
             bm.faces.new(list(reversed(anillos[-1])))]
    for i in range(n - 1):
        a0, a1 = anillos[i], anillos[i + 1]
        for k in range(lados):
            k2 = (k + 1) % lados
            caras.append(bm.faces.new((a0[k], a0[k2], a1[k2], a1[k])))
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

def z_cat(x, z_ext, flecha):
    """Catenaria aproximada por parabola: z_ext en los extremos, menos `flecha`
    en el centro."""
    t = x / MITAD_X
    return z_ext - flecha * (1.0 - t * t)

def linea_cuerda(z_ext, flecha, y):
    return [( -MITAD_X + (LARGO * i / N_SEG), y, z_cat(-MITAD_X + (LARGO * i / N_SEG),
                                                       z_ext, flecha))
            for i in range(N_SEG + 1)]

# ---------- 6) Postes de piedra (4) ----------
# Van desde la arena (z=0, despues el asentado los entierra 5 mm) hasta H_POST.
for sx in (-1, +1):
    for sy in (-1, +1):
        caja(sx * MITAD_X, sy * MITAD_Y, H_POST / 2.0,
             R_POST, R_POST, H_POST / 2.0, 0)      # material 0 = piedra

# ---------- 7) Tablones de la pasera (13), apoyados sobre las cuerdas ----------
PITCH = LARGO / N_TAB
for k in range(N_TAB):
    x = -MITAD_X + (k + 0.5) * PITCH
    z = z_cat(x, Z_CUERDA_EXT, SAG_CUERDA) + R_CUERDA + GROSOR_TAB / 2.0
    caja(x, 0.0, z, ANCHO_TAB / 2.0, MITAD_Y + 0.045, GROSOR_TAB / 2.0,
         1)                                             # material 1 = madera

# ---------- 8) Cuerdas maestras (2) y pasamanos (2) ----------
for sy in (-1, +1):
    y = sy * MITAD_Y
    tubo(linea_cuerda(Z_CUERDA_EXT, SAG_CUERDA, y), R_CUERDA, LAD_CUERDA, 2)
    tubo(linea_cuerda(Z_PASAM_EXT,  SAG_PASAM,   y), R_CUERDA, LAD_CUERDA, 2)

# ---------- 9) Colgantes verticales (5 por lado) ----------
for x in HANG_X:
    z_bajo = z_cat(x, Z_CUERDA_EXT, SAG_CUERDA)
    z_alto = z_cat(x, Z_PASAM_EXT,  SAG_PASAM)
    for sy in (-1, +1):
        caja(x, sy * MITAD_Y, (z_bajo + z_alto) / 2.0,
             R_COLGANTE, R_COLGANTE, (z_alto - z_bajo) / 2.0,
             2)                                         # material 2 = cuerda

# ---------- 10) Cerrar y crear el objeto ----------
bm.normal_update()
n_tris = sum(len(f.verts) - 2 for f in bm.faces)
me = bpy.data.meshes.new('SM_Puente_Cuerda')
bm.to_mesh(me)
bm.free()

puente = bpy.data.objects.new('SM_Puente_Cuerda', me)
escena.collection.objects.link(puente)
puente.data.materials.append(MAT_piedra)   # slot 0
puente.data.materials.append(MAT_madera)   # slot 1
puente.data.materials.append(MAT_cuerda)   # slot 2

bpy.ops.object.select_all(action='DESELECT')
puente.select_set(True)
bpy.context.view_layer.objects.active = puente
bpy.ops.object.shade_flat()

# ---------- 11) Asentado (E-12) — medido en caliente ----------
# Lo mas bajo son las bases de los 4 postes. Se mide el z_min real y se
# traslada hasta Z_APOYO (5 mm enterrado en la arena).
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Puente')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:      # solo la raiz; los hijos la siguen solos
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
print('PUENTE asentado: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_fin, delta, len(piezas)))

# ---------- 12) Iluminación + mundo (set IDENTICO al resto de los assets) ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.4
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(8), math.radians(35)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 13) Cámara ----------
bpy.ops.object.camera_add(location=(2.10, -1.80, 1.05))
cam = bpy.context.object
cam.name = 'CAM_Puente'
blanco = Vector((0.0, 0.0, 0.75))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 14) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '25-Ruinas-Templos',
                          'puente_cuerda_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
# E-21: si quedo un .blend@ de un crash, save_as_mainfile falla.
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_obj = len([o for o in escena.objects if o.name.startswith('SM_')])
print('PUENTE CUERDA OK — objetos SM_: %d — tris: %d — materiales: %d — blend: %s'
      % (n_obj, n_tris, len(puente.data.materials), ruta_blend))
