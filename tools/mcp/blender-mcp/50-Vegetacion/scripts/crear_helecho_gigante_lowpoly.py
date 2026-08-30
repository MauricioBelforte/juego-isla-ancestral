# crear_helecho_gigante_lowpoly.py — Helecho gigante (M50-Vegetacion)
# Checklist: "Helecho gigante"
#
# Helecho tropical: tronco central corto + corona de 9-12 frondosas (hojas
# grandes) que se curvan hacia afuera y abajo. Cada fronda es una tira
# alada con un tallo central (cilindro fino) y hojuelas alternadas.
#
# v2 (2026-08-29 19:50) — corrige E-27 (corona desparramada en +X):
#   La v1 hacía `hojuela.matrix_parent_inverse = o_tallo.matrix_world.inverted()`
#   después de emparentar. Eso descarta la rotación azimutal del tallo
#   (o_tallo.rotation_euler = Euler((0,0,azimut)) en L106), de modo que las
#   hojuelas leen su `location` como MUNDO y todas se apilan en +X en vez de
#   seguir al frond. La auditoría geométrica midió 47/80 hojuelas separadas,
#   hasta 0.8351 m de su padre. La v2 deja que Blender calcule el inverse
#   automáticamente y agrega un assert anti-regresión en el asentado.
import bpy
import bmesh
import os
import random
import math
from mathutils import Vector, Euler

# ---------- 1) Limpieza ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.85, spec=0.15, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_hoja   = crear_mat('MAT_Helecho_Hoja',   (0.22, 0.50, 0.25), rough=0.85)
MAT_tallo  = crear_mat('MAT_Helecho_Tallo',  (0.18, 0.42, 0.20), rough=0.90)
MAT_tronco = crear_mat('MAT_Helecho_Tronco', (0.30, 0.22, 0.13), rough=0.92)
MAT_arena  = crear_mat('MAT_Arena_Isla',     (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Tronco central corto (cilindro bajo) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.10, depth=0.40,
                                     location=(0.0, 0.0, 0.20))
tronco = bpy.context.object
tronco.name = 'SM_Helecho_Tronco'
tronco.data.materials.append(MAT_tronco)
bpy.ops.object.select_all(action='DESELECT')
tronco.select_set(True)
bpy.context.view_layer.objects.active = tronco
bpy.ops.object.shade_flat()

# ---------- 5) Función para crear UNA fronda ----------
# Una fronda es: tallo curvo (cilindro fino) + 8 hojuelas alternadas a los lados.
def crear_fronda(idx, azimut, largo, radio):
    """Crea un tallo curvo con hojuelas a los lados. Todo en una sola malla (E-01)."""
    SEG = 12
    LADOS = 5  # tallo finito
    rng = random.Random(idx * 11 + 3)

    bm = bmesh.new()
    anillos = []
    for i in range(SEG + 1):
        t = i / SEG
        # El tallo sale del centro hacia afuera y se curva hacia abajo
        # En coords locales del frond: x = t * largo, y = 0, z = -0.2 * t^2
        x = t * largo
        y = 0.0
        z = 0.40 - 0.20 * t * t  # arranca arriba (0.40) y baja
        # El tallo se afina
        rr = radio * (1.0 - 0.6 * t)
        verts = []
        for k in range(LADOS):
            ang = 2 * math.pi * k / LADOS
            verts.append(bm.verts.new((x, rr * math.cos(ang), z + rr * math.sin(ang))))
        anillos.append(verts)

    for i in range(SEG):
        for k in range(LADOS):
            k2 = (k + 1) % LADOS
            bm.faces.new((anillos[i][k], anillos[i][k2],
                          anillos[i + 1][k2], anillos[i + 1][k]))
    # tapas
    for anillo, invertir in ((anillos[0], True), (anillos[-1], False)):
        centro = bm.verts.new(sum((v.co for v in anillo), Vector()) / LADOS)
        for k in range(LADOS):
            k2 = (k + 1) % LADOS
            if invertir:
                bm.faces.new((centro, anillo[k2], anillo[k]))
            else:
                bm.faces.new((centro, anillo[k], anillo[k2]))

    bm.normal_update()
    me_tallo = bpy.data.meshes.new('SM_Helecho_FrondaTallo_%d' % idx)
    bm.to_mesh(me_tallo)
    bm.free()
    o_tallo = bpy.data.objects.new('SM_Helecho_FrondaTallo_%d' % idx, me_tallo)
    escena.collection.objects.link(o_tallo)
    o_tallo.data.materials.append(MAT_tallo)
    o_tallo.location = (0.0, 0.0, 0.0)
    o_tallo.rotation_euler = Euler((0.0, 0.0, azimut), 'XYZ')
    bpy.ops.object.select_all(action='DESELECT')
    o_tallo.select_set(True)
    bpy.context.view_layer.objects.active = o_tallo
    bpy.ops.object.shade_flat()

    # 8 hojuelas a lo largo del tallo (parentadas al tallo, E-11).
    # El tallo está en X (después de rotar en Z = azimut). El "afuera" del tallo
    # es +Y en local.
    for j in range(8):
        tj = (j + 0.5) / 8  # 0..1
        xj = tj * largo
        zj = 0.40 - 0.20 * tj * tj
        # alternar izq/der
        lado = 1 if j % 2 == 0 else -1
        ancho = 0.10 * (1.0 - tj * 0.6)  # más chico cerca de la punta
        largo_h = 0.18 * (1.0 - tj * 0.4)
        # centro de la hojuela: en +Y (o -Y) del tallo a una distancia ancho/2
        bpy.ops.mesh.primitive_cube_add(size=1.0,
                                         location=(xj, lado * (ancho / 2 + 0.005), zj))
        hojuela = bpy.context.object
        hojuela.name = 'SM_Helecho_Hojuela_%d_%d' % (idx, j)
        hojuela.scale = (largo_h, ancho, 0.005)
        hojuela.rotation_euler = Euler((0.0, 0.0, 0.0), 'XYZ')
        # pequeño twist para que no quede paralelo
        hojuela.rotation_euler.y = math.radians(lado * 12)
        hojuela.data.materials.append(MAT_hoja)
        # emparentar al tallo (E-11). NO tocar matrix_parent_inverse: el
        # frond está rotado en azimut (L106) y la inversa "asignada a mano"
        # descartaría esa rotación, mandando las hojuelas al +X mundial en
        # vez de seguirlas (E-27, v1). Dejar que Blender calcule la inversa
        # automáticamente basta: la `location` se interpreta en local del
        # padre y las hojuelas siguen la rotación azimutal del frond.
        hojuela.parent = o_tallo
        bpy.ops.object.select_all(action='DESELECT')
        hojuela.select_set(True)
        bpy.context.view_layer.objects.active = hojuela
        bpy.ops.object.shade_flat()

# ---------- 6) Crear 10 frondas en corona ----------
N_FRONDAS = 10
for k in range(N_FRONDAS):
    az = 2 * math.pi * k / N_FRONDAS
    largo = 0.95
    radio = 0.030
    crear_fronda(k + 1, az, largo, radio)

# ---------- 7) Asentado (E-12) — solo el tronco toca la arena ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name == 'SM_Helecho_Tronco']
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
print('HELECHO GIGANTE tronco asento: z_min %.3f -> %.3f (delta %+.3f)' % (z_min, Z_APOYO, delta))

# Anti-regresión E-27: el asentado no debe haber dejado los hijos flotando
# respecto de su padre. Si las hojuelas se separan > 2 cm del frond, es que
# alguien volvió a tocar matrix_parent_inverse. Verificamos el peor caso.
bpy.context.view_layer.update()
def aabb_ejes(o):
    pts = [o.matrix_world @ Vector(c) for c in o.bound_box]
    xs = [p.x for p in pts]; ys = [p.y for p in pts]; zs = [p.z for p in pts]
    return ((min(xs), max(xs)), (min(ys), max(ys)), (min(zs), max(zs)))
def dist_min(a, b):
    d = 0.0
    for (a0, a1), (b0, b1) in zip(a, b):
        d += max(0.0, max(a0 - b1, b0 - a1)) ** 2
    return math.sqrt(d)
peor = 0.0
peor_nombre = ''
for o in escena.objects:
    if not o.type == 'MESH' or not o.parent or not o.parent.type == 'MESH':
        continue
    if not o.name.startswith('SM_Helecho_Hojuela_'):
        continue
    d = dist_min(aabb_ejes(o), aabb_ejes(o.parent))
    if d > peor:
        peor = d
        peor_nombre = '%s -> %s' % (o.name, o.parent.name)
assert peor < 0.02, ('E-27: hojuela %s separada %.4f m de su padre tras el '
                     'asentado. NO asignar matrix_parent_inverse a mano: deja '
                     'que Blender lo calcule solo.' % (peor_nombre, peor))

# ---------- 8) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(6), math.radians(28)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 9) Cámara (lateral, un poco alta) ----------
bpy.ops.object.camera_add(location=(1.8, -1.8, 1.1))
cam = bpy.context.object
cam.name = 'CAM_Helecho'
blanco = Vector((0.0, 0.0, 0.50))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 10) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'helecho_gigante_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('HELECHO GIGANTE OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
