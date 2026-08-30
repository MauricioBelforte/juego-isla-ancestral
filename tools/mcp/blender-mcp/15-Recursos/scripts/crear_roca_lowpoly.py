# crear_roca_lowpoly.py — Roca común recolectable (M15-Recursos)
# Asset lowpoly reutilizable. Ver DOCUMENTACION/09-GUIA-BLENDER.md
#
# Lecciones aplicadas (guía 09):
#   E-01: bmesh sobre apilado de primitivas (superficie lisa)
#   E-04: ruta absoluta al proyecto (cwd de Blender = su carpeta de instalación)
#   §6.3: .blend y capturas viven en la carpeta del módulo 15-Recursos
import bpy
import bmesh
from math import radians, sin, cos, pi
from mathutils import Vector

# ---------- 0) Escena limpia (idempotencia) ----------
# E-05: NO usar wm.read_factory_settings dentro de execute_code — crashea el
# servidor MCP. Limpieza segura: borrar todos los objetos y datos huérfanos.
import bpy
import bmesh
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 1) Materiales ----------
def material(nombre, color):
    mat = bpy.data.materials.new(nombre)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = color
    bsdf.inputs['Roughness'].default_value = 0.9
    return mat

MAT_Roca   = material('MAT_Roca',   (0.26, 0.24, 0.22, 1.0))  # gris-pardo piedra
MAT_Arena  = material('MAT_Arena',  (0.87, 0.79, 0.62, 1.0))

# ---------- 2) Roca: icosfera deformada con bmesh (E-01) ----------
mesh = bpy.data.meshes.new('SM_Roca_Comun')
obj = bpy.data.objects.new('SM_Roca_Comun', mesh)
escena.collection.objects.link(obj)

bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=2, radius=1.45)
rng = __import__('random')
rng.seed(7)
for v in bm.verts:
    v.co += v.normal * rng.uniform(-0.18, 0.18)   # baches irregulares
bm.to_mesh(mesh)
bm.free()
obj.scale = (1.2, 1.0, 0.75)       # aplastada, más ancha que alta
obj.location = (0.0, 0.0, 0.92)    # apoyada sobre el disco (no lo atraviesa)
bpy.ops.object.select_all(action='DESELECT')
obj.select_set(True)
bpy.context.view_layer.objects.active = obj
bpy.ops.object.transform_apply(scale=True)         # fijar escala (export a Godot)
obj.data.materials.append(MAT_Roca)

# ---------- 3) Segunda roca chica apoyada (composición) ----------
mechita = bpy.data.meshes.new('SM_Roca_Comun_Chica')
roca2 = bpy.data.objects.new('SM_Roca_Comun_Chica', mechita)
escena.collection.objects.link(roca2)
bm2 = bmesh.new()
bmesh.ops.create_icosphere(bm2, subdivisions=1, radius=0.68)
for v in bm2.verts:
    v.co += v.normal * rng.uniform(-0.10, 0.10)
bm2.to_mesh(mechita)
bm2.free()
roca2.location = (1.35, 0.55, 0.42)
roca2.rotation_euler = (0.2, -0.15, 1.1)
roca2.data.materials.append(MAT_Roca)

# ---------- 4) Disco de arena (base de referencia) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.2, depth=0.12,
                                    location=(0.1, 0.05, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_Arena)

# ---------- 5) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 2.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = (radians(55), 0, radians(35))

mundo = bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
mundo.node_tree.nodes.get('Background').inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
mundo.node_tree.nodes.get('Background').inputs[1].default_value = 0.6

# ---------- 5b) Ajuste de composición: rocas más chicas, sombra marcada ----------
for ob in escena.collection.objects:
    if ob.name.startswith('SM_Roca'):
        ob.scale = (0.72, 0.72, 0.72)
        ob.location.z *= 0.72
sol_data.energy = 3.0
mundo.node_tree.nodes.get('Background').inputs[1].default_value = 0.45

# ---------- 6) Cámara de captura (E-03) + viewport con luces de escena (E-06) ----------
bpy.ops.object.camera_add(location=(4.2, -5.0, 2.2))
cam = bpy.context.object
cam.name = 'CAM_Roca'
dir_mira = Vector((0.15, 0.1, 0.45)) - cam.location
cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
escena.camera = cam

# E-06: en Material Preview hay que forzar el uso de luces y mundo de la escena,
# sino el viewport usa el estudio HDRI por defecto (sin sombras, colores lavados)
for area in bpy.context.screen.areas:
    if area.type == 'VIEW_3D':
        for space in area.spaces:
            if space.type == 'VIEW_3D':
                space.shading.type = 'MATERIAL'
                space.shading.use_scene_lights = True
                space.shading.use_scene_world = True

# ---------- 7) Guardar .blend en la carpeta del módulo (E-04) ----------
import os
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '15-Recursos',
                          'roca_comun.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('ROCA OK — objetos: %d — blend: %s' % (len(bpy.data.objects), ruta_blend))