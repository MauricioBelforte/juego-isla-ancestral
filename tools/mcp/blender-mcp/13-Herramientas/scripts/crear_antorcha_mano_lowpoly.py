# crear_antorcha_mano_lowpoly.py — Antorcha de mano (M13-Herramientas)
# Checklist Tier C: "Antorcha de mano"
#
# v2 (2026-08-29) — CORRECCIÓN DEL BUG DE SEPARACIÓN (E-27) + BRASA ARRIBA
#
# QUÉ ESTABA MAL EN v1 (medido en el .blend):
#   El mango terminó flotando en Z[0.262..0.862] con el resto (tela, remate,
#   brasa) en X≈0.46, Z[0.045..0.299]: separados 35 cm en X y la tela
#   apoyaba en la arena en vez del mango. Además la brasa quedó ABAJO
#   (debería estar arriba — eso es lo que arde).
#
# QUÉ CAMBIA EN v2:
#   1. hijo() NO toca matrix_parent_inverse (E-27).
#   2. Mango vertical nativo (eje Z, sin rotación): matrix_world identidad.
#   3. Brasa y remate ARRIBA del mango (donde corresponde: la cabeza de la
#      antorcha es lo que arde). En v1 la rotación post-hoc los dejó abajo.
#   4. Tela, cordeles y pomo coherentes con la pose vertical.
#
# Composición: mango de madera cilíndrico VERTICAL (eje Z) con cabeza
# envuelta en tela carbonizada en el extremo +Z, dos vueltas de cordel
# sujetando la tela al mango, y la brasa emisiva asomando en la punta. La
# llama en sí es VFX de Godot (M52); acá sólo queda el emisor.
#
# Convenciones: E-11/E-27 (hijos del mango sin tocar matrix_parent_inverse),
# E-12 (asentado medido z_min 0.045).
import bpy
import os
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

# ---------- 1bis) Parenting correcto (E-27) ----------
def hijo(objeto, padre):
    bpy.context.view_layer.update()
    objeto.parent = padre
    return objeto

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.85, spec=0.12, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

def hacer_emisivo(m, color, fuerza=2.2):
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Emission Color'].default_value = (*color, 1.0)
    bsdf.inputs['Emission Strength'].default_value = fuerza
    return m

MAT_madera = crear_mat('MAT_Madera_Antorcha', (0.40, 0.27, 0.16), rough=0.88)
MAT_tela   = crear_mat('MAT_Tela_Carbonizada', (0.16, 0.13, 0.12), rough=0.98)
MAT_cordel = crear_mat('MAT_Cordel_Antorcha', (0.52, 0.44, 0.28), rough=0.95)
MAT_brasa  = hacer_emisivo(crear_mat('MAT_Brasa_Antorcha', (0.95, 0.42, 0.10),
                                     rough=0.60), (1.0, 0.45, 0.10), 2.4)
MAT_arena  = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.4, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Mango (eje Z, VERTICAL) ----------
LARGO = 0.60
R = 0.029
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=R, depth=LARGO,
                                    location=(0.0, 0.0, 0.0))
mango = bpy.context.object
mango.name = 'SM_Antorcha_Mango'
mango.data.materials.append(MAT_madera)
bpy.ops.object.select_all(action='DESELECT')
mango.select_set(True)
bpy.context.view_layer.objects.active = mango
bpy.ops.object.shade_flat()

# ---------- 5) Cabeza: envoltura de tela + remate + brasa (todo arriba) ----------
Z_CAB = LARGO / 2 + 0.055   # apenas pasado el extremo +Z del mango

# 5a) envoltura carbonizada (coaxial con el mango, sin rotación)
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.056, depth=0.185,
                                    location=(0.0, 0.0, Z_CAB))
tela = bpy.context.object
tela.name = 'SM_Antorcha_Tela'
tela.data.materials.append(MAT_tela)
hijo(tela, mango)
bpy.ops.object.select_all(action='DESELECT')
tela.select_set(True)
bpy.context.view_layer.objects.active = tela
bpy.ops.object.shade_flat()

# 5b) remate achatado en Z (escala 0.85 en el eje del mango, perpendicular a
#     los lados). En v1 era (0.85, 1, 1) para squash sobre X; con mango en
#     Z, el squash pasa a Z.
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.054,
                                      location=(0.0, 0.0, Z_CAB + 0.0925))
remate = bpy.context.object
remate.name = 'SM_Antorcha_Remate'
remate.scale = (1.0, 1.0, 0.85)
remate.data.materials.append(MAT_tela)
hijo(remate, mango)
bpy.ops.object.select_all(action='DESELECT')
remate.select_set(True)
bpy.context.view_layer.objects.active = remate
bpy.ops.object.shade_flat()

# 5c) brasa emisiva asomando en la punta (encima del remate)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.030,
                                      location=(0.0, 0.0, Z_CAB + 0.135))
brasa = bpy.context.object
brasa.name = 'SM_Antorcha_Brasa'
brasa.data.materials.append(MAT_brasa)
hijo(brasa, mango)
bpy.ops.object.select_all(action='DESELECT')
brasa.select_set(True)
bpy.context.view_layer.objects.active = brasa
bpy.ops.object.shade_flat()

# ---------- 6) Cordel (2 vueltas donde la tela se ata al mango) ----------
# Coaxiales al mango, sin rotación. La primera vuelta queda sobre el borde
# de la tela, la segunda más abajo en el mango.
for i, z_off in enumerate((LARGO / 2 - 0.015, LARGO / 2 - 0.055)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.042, depth=0.022,
                                        location=(0.0, 0.0, z_off))
    vuelta = bpy.context.object
    vuelta.name = 'SM_Antorcha_Cordel_%d' % (i + 1)
    vuelta.data.materials.append(MAT_cordel)
    hijo(vuelta, mango)

# ---------- 7) Asentado (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Antorcha')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
mango.location.z += (Z_APOYO - z_min)
bpy.context.view_layer.update()
z_final = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
assert abs(z_final - Z_APOYO) < 1e-4, (
    'E-27: el asentado no movió el conjunto (z_min %.4f -> %.4f). '
    'Revisá hijo(): no debe tocar matrix_parent_inverse.' % (z_min, z_final))
print('ANTORCHA MANO asentada: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_final, Z_APOYO - z_min, len(piezas)))

# ---------- 8) Luz + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(8), math.radians(35)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 9) Cámara (encuadre para antorcha vertical ~0.84 m, brasa arriba) ----------
bpy.ops.object.camera_add(location=(1.05, -1.20, 0.80))
cam = bpy.context.object
cam.name = 'CAM_Antorcha'
blanco = Vector((0.0, 0.0, 0.42))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 10) Guardar ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '13-Herramientas',
                          'antorcha_mano_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('ANTORCHA MANO v2 OK — objetos SM_: %d — blend: %s'
      % (len(piezas), ruta_blend))
