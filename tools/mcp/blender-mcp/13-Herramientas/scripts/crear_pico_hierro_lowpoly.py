# crear_pico_hierro_lowpoly.py — Pico de hierro (M13-Herramientas)
# Checklist Tier C: "Pico de hierro"
#
# v2 (2026-08-29) — CORRECCIÓN DEL BUG DE SEPARACIÓN (E-27)
#
# Misma geometría que el pico de piedra, pero con cabeza y refuerzos metálicos.
# Variante de nivel 2 de la herramienta. Mismas dimensiones, materiales distintos.
#
# El bug y el fix son los mismos que en pico_piedra v2: hijo() NO debe tocar
# matrix_parent_inverse (E-27), el mango debe tener matrix_world identidad para
# que local == mundo, y la pose es VERTICAL nativa.
#
# QUÉ ESTABA MAL EN v1 (medido en el .blend):
#   SM_PicoHierro_Mango   X[-0.123..-0.063]   (x centro -0.093)
#   todo lo demás         X ≈ 0               (x centro  0.000)
#   Separación: 9.3 cm entre el mango y la cabeza/ataduras/pomo.
#   z_min global: -0.4629 (source hundido 46 cm).
#
# Convenciones: E-08 (cono para puntas), E-11/E-27 (hijos del mango sin tocar
# matrix_parent_inverse), E-12 (asentado medido z_min -> 0.045).
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

MAT_madera = crear_mat('MAT_Madera_Mango',  (0.38, 0.26, 0.16), rough=0.86)
MAT_hierro = crear_mat('MAT_Hierro_Pico',   (0.60, 0.62, 0.66), rough=0.38,
                       spec=0.55, metal=0.85)
MAT_cuero  = crear_mat('MAT_Cuero_Atadura', (0.30, 0.19, 0.11), rough=0.96)
MAT_arena  = crear_mat('MAT_Arena_Isla',    (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.6, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Mango (eje Z, VERTICAL) ----------
LARGO_MANGO = 0.86
R_MANGO = 0.032
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=R_MANGO,
                                    depth=LARGO_MANGO, location=(0.0, 0.0, 0.0))
mango = bpy.context.object
mango.name = 'SM_PicoHierro_Mango'
mango.data.materials.append(MAT_madera)
bpy.ops.object.select_all(action='DESELECT')
mango.select_set(True)
bpy.context.view_layer.objects.active = mango
bpy.ops.object.shade_flat()

# ---------- 5) Cabeza ----------
Z_CABEZA = 0.34

# 5a) bloque central de la cabeza (la dimensión "a lo largo del mango" pasa a Z)
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, 0.0, Z_CABEZA))
bloque = bpy.context.object
bloque.name = 'SM_PicoHierro_BloqueCabeza'
bloque.scale = (0.060, 0.100, 0.080)
bloque.data.materials.append(MAT_hierro)
hijo(bloque, mango)
bpy.ops.object.select_all(action='DESELECT')
bloque.select_set(True)
bpy.context.view_layer.objects.active = bloque
bpy.ops.object.shade_flat()

# 5b) dos puntas cónicas a lo largo de Y (perpendiculares al mango)
LARGO_PUNTA = 0.32
for signo, sufijo in ((1, 'A'), (-1, 'B')):
    bpy.ops.mesh.primitive_cone_add(vertices=8,
                                    radius1=0.048, radius2=0.006,
                                    depth=LARGO_PUNTA,
                                    location=(0.0,
                                              signo * (0.048 + LARGO_PUNTA / 2),
                                              Z_CABEZA))
    punta = bpy.context.object
    punta.name = 'SM_PicoHierro_Punta_%s' % sufijo
    punta.rotation_euler = (math.radians(-90.0) * signo, 0.0, 0.0)
    punta.data.materials.append(MAT_hierro)
    hijo(punta, mango)
    bpy.ops.object.select_all(action='DESELECT')
    punta.select_set(True)
    bpy.context.view_layer.objects.active = punta
    bpy.ops.object.shade_flat()

# 5c) cuello metálico entre el mango y la cabeza (coaxial con el mango)
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.042, depth=0.075,
                                    location=(0.0, 0.0, Z_CABEZA - 0.075))
cuello = bpy.context.object
cuello.name = 'SM_PicoHierro_Cuello'
cuello.data.materials.append(MAT_hierro)
hijo(cuello, mango)

# ---------- 6) Ataduras (coaxiales al mango, envuelven el cuello) ----------
for i, z_off in enumerate((Z_CABEZA - 0.060, Z_CABEZA - 0.110)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.044, depth=0.028,
                                        location=(0.0, 0.0, z_off))
    vuelta = bpy.context.object
    vuelta.name = 'SM_PicoHierro_Atadura_%d' % (i + 1)
    vuelta.data.materials.append(MAT_cuero)
    hijo(vuelta, mango)

# ---------- 7) Pomo: abultamiento en el extremo -Z ----------
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=R_MANGO * 1.15,
                                      location=(0.0, 0.0, -LARGO_MANGO / 2))
pomo = bpy.context.object
pomo.name = 'SM_PicoHierro_Pomo'
pomo.data.materials.append(MAT_madera)
hijo(pomo, mango)
bpy.ops.object.select_all(action='DESELECT')
pomo.select_set(True)
bpy.context.view_layer.objects.active = pomo
bpy.ops.object.shade_flat()

# ---------- 8) Asentado medido (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_PicoHierro')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
mango.location.z += (Z_APOYO - z_min)
bpy.context.view_layer.update()
z_final = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
assert abs(z_final - Z_APOYO) < 1e-4, (
    'E-27: el asentado no movió el conjunto (z_min %.4f -> %.4f). '
    'Revisá hijo(): no debe tocar matrix_parent_inverse.' % (z_min, z_final))
print('PICO HIERRO asentado: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_final, Z_APOYO - z_min, len(piezas)))

# ---------- 9) Luz + mundo ----------
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

# ---------- 10) Cámara ----------
bpy.ops.object.camera_add(location=(1.55, -1.75, 0.95))
cam = bpy.context.object
cam.name = 'CAM_PicoHierro'
blanco = Vector((0.0, 0.0, 0.47))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 11) Guardar ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '13-Herramientas',
                          'pico_hierro_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PICO HIERRO v2 OK — objetos SM_: %d — blend: %s'
      % (len(piezas), ruta_blend))
