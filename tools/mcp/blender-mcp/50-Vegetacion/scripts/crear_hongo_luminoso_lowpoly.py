# crear_hongo_luminoso_lowpoly.py — Hongo luminoso (M50-Vegetacion)
# Checklist: "Hongo luminoso (cuevas/templo subterráneo)"
# Composición: estípite cilíndrico (píe), sombrero semiesférico bajo,
# brácteas (anillos) en el estípite. Material emisivo en el sombrero y
# en motas brillantes. Color base azul-violeta para cuevas.
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
def crear_mat(nombre, color, rough=0.6, spec=0.1, emisivo=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    b = m.node_tree.nodes.get('Principled BSDF')
    b.inputs['Base Color'].default_value = (*color, 1.0)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Specular IOR Level'].default_value = spec
    if emisivo > 0:
        # crear Emission y conectarlo
        em = m.node_tree.nodes.new('ShaderNodeEmission')
        em.inputs['Color'].default_value = (*color, 1.0)
        em.inputs['Strength'].default_value = emisivo
        mix = m.node_tree.nodes.new('ShaderNodeMixShader')
        mix.inputs['Fac'].default_value = 0.85
        m.node_tree.links.new(b.outputs['BSDF'], mix.inputs[1])
        m.node_tree.links.new(em.outputs['Emission'], mix.inputs[2])
        out = m.node_tree.nodes.get('Material Output')
        m.node_tree.links.new(mix.outputs[0], out.inputs['Surface'])
    return m

# Material EMISIVO: truco — bpy Principled BSDF + Emission node mezclados
def crear_mat_em(nombre, color, emisivo=2.5):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    em = m.node_tree.nodes.new('ShaderNodeEmission')
    em.inputs['Color'].default_value = (*color, 1.0)
    em.inputs['Strength'].default_value = emisivo
    add = m.node_tree.nodes.new('ShaderNodeAddShader')
    m.node_tree.links.new(bsdf.outputs['BSDF'], add.inputs[0])
    m.node_tree.links.new(em.outputs['Emission'], add.inputs[1])
    out = m.node_tree.nodes.get('Material Output')
    m.node_tree.links.new(add.outputs[0], out.inputs['Surface'])
    return m

MAT_pie   = crear_mat('MAT_Hongo_Pie',   (0.78, 0.78, 0.86), rough=0.55)
MAT_anillo= crear_mat('MAT_Hongo_Anillo',(0.70, 0.65, 0.90), rough=0.50)
MAT_capa  = crear_mat_em('MAT_Hongo_Capa', (0.45, 0.30, 0.95), emisivo=3.5)  # violeta brillante
MAT_mota  = crear_mat_em('MAT_Hongo_Mota', (0.85, 0.95, 1.00), emisivo=4.0)  # motas blancas
MAT_piedra= crear_mat('MAT_Piedra_Cueva',(0.30, 0.30, 0.38), rough=0.95)
MAT_suelo = crear_mat('MAT_Suelo_Cueva', (0.18, 0.20, 0.28), rough=0.95)

# ---------- 3) Suelo cueva (disco) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.2, depth=0.24,
                                    location=(0, 0, -0.12))
suelo = bpy.context.object
suelo.name = 'Base_Arena'
suelo.data.materials.append(MAT_suelo)

# ---------- 4) Piedra base ----------
me = bpy.data.meshes.new('M_Piedra_Hongo')
ob = bpy.data.objects.new('SM_Piedra_Hongo', me)
escena.collection.objects.link(ob)
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=1, radius=0.55)
bm.to_mesh(me); bm.free()
ob.location = (0.0, 0.0, 0.20)
ob.scale = (1.2, 0.9, 0.55)
bpy.ops.object.select_all(action='DESELECT')
ob.select_set(True)
bpy.context.view_layer.objects.active = ob
bpy.ops.object.transform_apply(scale=True)
ob.data.materials.append(MAT_piedra)

# ---------- 5) Estípite del hongo: bmesh cónico invertido ----------
me = bpy.data.meshes.new('M_Pie_Hongo')
ob = bpy.data.objects.new('SM_Pie_Hongo', me)
escena.collection.objects.link(ob)
bm = bmesh.new()
SEG_L, LADOS = 7, 8
anillos = []
for i in range(SEG_L + 1):
    t = i / SEG_L
    z = t * 0.85
    r = 0.13 + 0.06 * sin(pi * t)  # más gordo en el medio (barriguita)
    anillos.append([bm.verts.new((r * cos(2 * pi * k / LADOS),
                                  r * sin(2 * pi * k / LADOS), z))
                    for k in range(LADOS)])
for i in range(SEG_L):
    for k in range(LADOS):
        bm.faces.new([anillos[i][k], anillos[i][(k + 1) % LADOS],
                      anillos[i + 1][(k + 1) % LADOS], anillos[i + 1][k]])
bm.faces.new(anillos[0][::-1])
bm.faces.new(anillos[-1])
bm.to_mesh(me); bm.free()
ob.location = (0.0, 0.0, 0.40)
ob.data.materials.append(MAT_pie)

# Anillo (bráctea) en el estípite
bpy.ops.mesh.primitive_torus_add(major_radius=0.18, minor_radius=0.025,
                                 location=(0.0, 0.0, 0.95))
ani = bpy.context.object
ani.name = 'SM_Anillo_Hongo'
ani.rotation_euler = (radians(90), 0, 0)
ani.data.materials.append(MAT_anillo)

# ---------- 6) Sombrero: media esfera más ancha que el estípite ----------
me = bpy.data.meshes.new('M_Capa_Hongo')
ob = bpy.data.objects.new('SM_Capa_Hongo', me)
escena.collection.objects.link(ob)
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.45)
# mantener solo la mitad inferior (z <= 0 → la cap se orienta hacia abajo)
bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.z > 0.02], context='VERTS')
# rellenar el corte horizontal con un fan de caras hacia un centro
top_loop = sorted([e for e in bm.edges if (v.co.z > 0.0 for v in e.verts) and False], key=lambda e: 0)
# Tomar el anillo de vértices en z~0.02
verts_ring = [v for v in bm.verts if abs(v.co.z) < 0.03]
if verts_ring:
    # ordenar por ángulo
    import math as _m
    verts_ring.sort(key=lambda v: _m.atan2(v.co.y, v.co.x))
    centro = bm.verts.new((0.0, 0.0, 0.0))
    for i in range(len(verts_ring)):
        bm.faces.new((centro, verts_ring[i], verts_ring[(i + 1) % len(verts_ring)]))
bm.to_mesh(me); bm.free()
ob.location = (0.0, 0.0, 1.18)
ob.scale = (1.3, 1.3, 0.55)
bpy.ops.object.select_all(action='DESELECT')
ob.select_set(True)
bpy.context.view_layer.objects.active = ob
bpy.ops.object.transform_apply(scale=True)
ob.data.materials.append(MAT_capa)

# ---------- 7) Motas luminosas (5 pequeñas esferas sobre la piedra) ----------
import random
rng = random.Random(7)
for i in range(5):
    ang = rng.uniform(0, 2 * pi)
    r = rng.uniform(0.30, 0.75)
    h = rng.uniform(0.05, 0.40)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=rng.uniform(0.04, 0.07))
    m = bpy.context.object
    m.name = f'SM_Mota_{i}'
    m.location = (r * cos(ang), r * sin(ang), 0.20 + h)
    m.data.materials.append(MAT_mota)

# ---------- 8) Iluminación tenue + cielo nocturno ----------
sol_data = bpy.data.lights.new('SOL', type='POINT')
sol_data.energy = 60.0
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.location = (0.0, 0.0, 2.0)
sol.data.shadow_soft_size = 1.0

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.04, 0.05, 0.10, 1.0)  # noche cerrada
bg.inputs[1].default_value = 0.25

# ---------- 9) Cámara ----------
bpy.ops.object.camera_add(location=(2.4, -3.0, 1.4))
cam = bpy.context.object
cam.name = 'CAM_HongoLumin'
dir_mira = Vector((0.0, 0.0, 0.7)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam

# ---------- 10) Flat shading ----------
for ob in escena.objects: ob.select_set(True)
bpy.context.view_layer.objects.active = escena.objects[0]
bpy.ops.object.shade_flat()

# ---------- 11) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '50-Vegetacion',
                          'hongo_luminoso_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('HONGO LUMINOSO OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))
