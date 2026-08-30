# crear_palmera_joven_lowpoly.py — Palmera joven (M50-Vegetacion)
# Variante de la palmera común: más baja, tronco más fino, SIN cocos,
# corona pequeña y frondas cortas. Checklist: "Palmera joven (sin cocos, más baja)".
#
# Se envía vía execute_code del socket BlenderMCP (9876); NO es standalone.
# Lecciones aplicadas de 09-GUIA-BLENDER.md:
#   E-01: tronco como UNA sola malla bmesh (nada de cilindros apilados)
#   E-02: importar todo lo de math que se use
#   E-03: cámara propia + shading forzado para la captura
#   E-04: ruta absoluta (el cwd de Blender es su carpeta de instalación)
#   E-05: limpieza sin wm.read_factory_settings (crashea el server MCP)
#   §7:   Base_Arena / SOL / Mundo / CAM_* son SET DE CAPTURA, no viajan a Godot
import bpy
import bmesh
import os
from math import radians, sin, cos, pi
from mathutils import Vector, Euler

# ---------- 1) Limpieza idempotente (E-05) ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 2) Materiales (reutilizan paleta de la palmera común) ----------
def crear_mat(nombre, color, rough=0.9, spec=0.08):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    return m

MAT_tronco  = crear_mat('MAT_Tronco_PalmeraJoven', (0.52, 0.38, 0.22), rough=0.95)
MAT_hoja    = crear_mat('MAT_Hoja_PalmeraJoven',   (0.20, 0.55, 0.18), rough=0.85)
MAT_corazon = crear_mat('MAT_Corazon_PalmeraJoven',(0.42, 0.55, 0.18), rough=0.90)
MAT_arena   = crear_mat('MAT_Arena_Isla',          (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Set de captura: disco de arena (§7 — NO exportar) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=28, radius=2.2, depth=0.24,
                                    location=(0, 0, -0.12))
suelo = bpy.context.object
suelo.name = 'Base_Arena'
suelo.data.materials.append(MAT_arena)

# ---------- 4) Tronco: UNA malla bmesh, curveado y más bajo (E-01) ----------
SEG_L, LADOS = 8, 7
CURVA  = 0.38      # menos inclinada que la adulta (0.70)
ALTURA = 2.15      # ~55% de la adulta (3.9)
R_BASE, R_PUNTA = 0.19, 0.085

bm = bmesh.new()
anillos = []
for i in range(SEG_L + 1):
    t = i / SEG_L
    x = CURVA * (t ** 2)
    z = 0.06 + t * ALTURA
    r = R_BASE - (R_BASE - R_PUNTA) * t
    anillos.append([bm.verts.new((x + r * cos(2 * pi * k / LADOS),
                                  r * sin(2 * pi * k / LADOS), z))
                    for k in range(LADOS)])
for i in range(SEG_L):
    for k in range(LADOS):
        bm.faces.new([anillos[i][k], anillos[i][(k + 1) % LADOS],
                      anillos[i + 1][(k + 1) % LADOS], anillos[i + 1][k]])
bm.faces.new(anillos[0][::-1])
bm.faces.new(anillos[-1])
me = bpy.data.meshes.new('M_Tronco_Joven')
bm.to_mesh(me); bm.free()
tronco = bpy.data.objects.new('SM_Tronco_Joven', me)
escena.collection.objects.link(tronco)
tronco.data.materials.append(MAT_tronco)

# ---------- 4b) Autocorreccion de apoyo del TRONCO (E-12) ----------
bpy.context.view_layer.update()
z_min = min((tronco.matrix_world @ Vector(c)).z for c in tronco.bound_box)
delta = 0.045 - z_min
tronco.location.z += delta
bpy.context.view_layer.update()
print('TRONCO asento: z_min %.3f -> 0.045 (delta %+.3f)' % (z_min, delta))

top_x = CURVA
top_z = 0.06 + ALTURA

# ---------- 5) Corona (yema apical, sin cocos) ----------
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.17,
                                      location=(top_x, 0, top_z + 0.06))
cora = bpy.context.object
cora.name = 'SM_Corona_Joven'
cora.scale = (1.0, 1.0, 0.8)
cora.data.materials.append(MAT_corazon)

# ---------- 6) Frondas: 6, cortas y más tiesas que la adulta ----------
def crear_fronda(idx, yaw_deg, pitch_deg):
    bm = bmesh.new()
    N = 5
    largo = 1.45 + (0.15 if idx % 2 else 0.0)
    filas = []
    for j in range(N + 1):
        s = j / N
        x = s * largo
        w = 0.03 if (s <= 0.0 or s >= 1.0) else 0.26 * (sin(pi * s) ** 0.6)
        z = 0.40 - 0.06 * s - 0.80 * (s ** 2)
        filas.append((bm.verts.new((x, -w, z)), bm.verts.new((x, w, z))))
    for j in range(N):
        a1, b1 = filas[j]
        a2, b2 = filas[j + 1]
        bm.faces.new((a1, b1, b2, a2))
    me = bpy.data.meshes.new('m_fronda_joven_%02d' % idx)
    bm.to_mesh(me); bm.free()
    ob = bpy.data.objects.new('SM_Fronda_Joven_%02d' % idx, me)
    escena.collection.objects.link(ob)
    ob.rotation_euler = Euler((0.0, radians(pitch_deg), radians(yaw_deg)), 'XYZ')
    ob.location = (top_x, 0.0, top_z - 0.03)
    ob.data.materials.append(MAT_hoja)
    return ob

K = 6
for i in range(K):
    yaw = i * (360.0 / K) + (6.0 if i % 2 else -3.0)
    pitch = 5.0 + (i % 3) * 5.0
    crear_fronda(i, yaw, pitch)

# ---------- 7) Set de captura: sol + mundo + cámara (E-03 / §7) ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.4
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((radians(52), radians(6), radians(32)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

bpy.ops.object.camera_add(location=(4.6, -5.4, 2.4))
cam = bpy.context.object
cam.name = 'CAM_PalmeraJoven'
dir_mira = Vector((top_x * 0.5, 0.0, top_z * 0.55)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam

# ---------- 8) Flat shading ----------
for ob in escena.objects:
    ob.select_set(True)
bpy.context.view_layer.objects.active = tronco
bpy.ops.object.shade_flat()

# ---------- 9) Guardar .blend con ruta absoluta (E-04) ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'palmera_joven_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PALMERA JOVEN OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
