# crear_canas_bambu_lowpoly.py — Grupo de 4 cañas de bambú (M50-Vegetacion)
# Checklist: "Cañas de bambú (grupo de 3-4)"
# 4 cilindros bmesh de altura variable con rings horizontales (entrenudos) cada
# 0.35 m. Ligeramente curvados en distintos ángulos para variedad.
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

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.9, spec=0.08):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    return m

MAT_bambu_a  = crear_mat('MAT_Bambu_A', (0.46, 0.58, 0.22), rough=0.85)
MAT_bambu_b  = crear_mat('MAT_Bambu_B', (0.38, 0.50, 0.18), rough=0.85)
MAT_hoja     = crear_mat('MAT_Hoja_Bambu', (0.18, 0.45, 0.16), rough=0.85)
MAT_arena    = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.4, depth=0.24,
                                    location=(0, 0, -0.12))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Cada caña: bmesh única con rings + taper (E-01) ----------
def crear_cana(idx, base_pos, altura, radio, mat, lean_x=0.0, lean_y=0.0, color_leaf=True):
    SEG_R, LADOS = 14, 7
    bm = bmesh.new()
    anillos = []
    for i in range(SEG_R + 1):
        t = i / SEG_R
        # entrenudo de 0.35 cada 7 anillos aprox (con altura dada)
        z = t * altura
        # taper muy suave: 92% a la mitad, 80% al tope
        r = radio * (0.92 - 0.12 * (t ** 1.4))
        # pequeño lean (inclinación): desplazamiento gradual
        x = lean_x * (t ** 1.2)
        y = lean_y * (t ** 1.2)
        anillos.append([bm.verts.new((x + r * cos(2 * pi * k / LADOS),
                                      y + r * sin(2 * pi * k / LADOS), z))
                        for k in range(LADOS)])
    for i in range(SEG_R):
        for k in range(LADOS):
            bm.faces.new([anillos[i][k], anillos[i][(k + 1) % LADOS],
                          anillos[i + 1][(k + 1) % LADOS], anillos[i + 1][k]])
    bm.faces.new(anillos[0][::-1])
    bm.faces.new(anillos[-1])
    me = bpy.data.meshes.new(f'M_Cana_{idx}')
    bm.to_mesh(me); bm.free()
    ob = bpy.data.objects.new(f'SM_Cana_{idx}', me)
    escena.collection.objects.link(ob)
    ob.location = base_pos
    ob.data.materials.append(mat)

    # 2-3 entrenudos (anillos) en relieve, hechos con un torus finito a distintas alturas
    n_ent = max(2, int(altura / 0.55))
    for j in range(1, n_ent + 1):
        bpy.ops.mesh.primitive_torus_add(
            major_radius=radio * 0.97,
            minor_radius=radio * 0.06,
            location=(base_pos[0] + lean_x * ((j / (n_ent + 1)) ** 1.2),
                      base_pos[1] + lean_y * ((j / (n_ent + 1)) ** 1.2),
                      base_pos[2] + (j / (n_ent + 1)) * altura))
        tor = bpy.context.object
        tor.name = f'SM_Cana_{idx}_Anillo_{j}'
        tor.rotation_euler = (radians(90), 0, 0)
        tor.data.materials.append(mat)

    # Hojas: 4 hojas delgadas en el tope, si color_leaf
    if color_leaf and idx < 3:
        for k in range(4):
            ang = k * 90 + idx * 25
            bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.04, radius2=0.0,
                                            depth=0.55,
                                            location=(base_pos[0] + lean_x + cos(radians(ang)) * 0.18,
                                                      base_pos[1] + lean_y + sin(radians(ang)) * 0.18,
                                                      base_pos[2] + altura + 0.15))
            hoja = bpy.context.object
            hoja.name = f'SM_Cana_{idx}_Hoja_{k}'
            hoja.rotation_euler = (radians(35), 0, radians(ang))
            hoja.data.materials.append(MAT_hoja)
    return ob

# 4 cañas en formación agrupada
espec = [
    {'pos': (0.00,  0.00), 'h': 2.80, 'r': 0.16, 'mat': MAT_bambu_a, 'lean': ( 0.18,  0.05)},
    {'pos': (0.55,  0.30), 'h': 3.30, 'r': 0.18, 'mat': MAT_bambu_b, 'lean': (-0.25,  0.15)},
    {'pos': (-0.45, 0.50), 'h': 2.40, 'r': 0.15, 'mat': MAT_bambu_a, 'lean': ( 0.10, -0.20)},
    {'pos': (0.15, -0.55), 'h': 3.00, 'r': 0.17, 'mat': MAT_bambu_b, 'lean': (-0.05,  0.30)},
]
for i, e in enumerate(espec):
    crear_cana(i, (e['pos'][0], e['pos'][1], 0.08),
               e['h'], e['r'], e['mat'],
               lean_x=e['lean'][0], lean_y=e['lean'][1])

# ---------- 4b) Autocorreccion de apoyo del conjunto de cañas (E-12) ----------
# Asentamos TODO el grupo SM_Cana_ (cañas + anillos + hojas) a z_min = 0.045
# en bloque. La inclinacion aleatoria hace que cada caña tenga un z_min
# distinto, asi que tomar el minimo del grupo y aplicar el mismo delta.
bpy.context.view_layer.update()
canas = [o for o in escena.objects if o.name.startswith('SM_Cana_') and o.type == 'MESH']
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in canas)
delta = 0.045 - z_min
for o in canas:
    o.location.z += delta
bpy.context.view_layer.update()
print('CANAS asento: z_min %.3f -> 0.045 (delta %+.3f, n=%d)' % (z_min, delta, len(canas)))

# ---------- 5) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((radians(52), radians(6), radians(32)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 6) Cámara ----------
bpy.ops.object.camera_add(location=(5.2, -5.4, 2.6))
cam = bpy.context.object
cam.name = 'CAM_CanasBambu'
dir_mira = Vector((0.1, 0.0, 1.4)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam

# ---------- 7) Flat shading ----------
for ob in escena.objects: ob.select_set(True)
bpy.context.view_layer.objects.active = escena.objects[0]
bpy.ops.object.shade_flat()

# ---------- 8) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'canas_bambu_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('CAÑAS BAMBÚ OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
