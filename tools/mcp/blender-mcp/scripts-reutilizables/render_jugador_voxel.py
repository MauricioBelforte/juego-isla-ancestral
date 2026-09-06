# -*- coding: utf-8 -*-
"""
render_jugador_voxel.py — Render de verificación del jugador voxel (M45).
Carga el GLB, arma escena de render (suelo, sol 3/4, cámara CYCLES-CPU)
y guarda un PNG para análisis visual.
Ejecutar: blender.exe -b --factory-startup --python render_jugador_voxel.py
"""

import bpy  # noqa: E402
import os  # noqa: E402
import math  # noqa: E402

GLB = os.path.abspath(os.path.join(
    os.path.dirname(__file__), "..", "..", "..", "..",
    "game", "isla-ancestral", "assets", "3d", "media", "45-Arte3D_jugador_voxel.glb"))
PNG = os.path.abspath(os.path.join(
    os.path.dirname(__file__), "..", "..", "..", "..",
    "tools", "mcp", "blender-mcp", "capturas", "45-Arte-3D",
    "render_jugador_voxel_v1.png"))

# Orden canónico de plantilla_asset.py: limpiar → importar → arena → iluminar
# → asentar → camara → shade_flat → guardar
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=GLB)

# Medir altura real
from mathutils import Vector  # noqa: E402

mins = [1e9] * 3
maxs = [-1e9] * 3
for obj in bpy.context.scene.objects:
    if obj.type != "MESH":
        continue
    for c in obj.bound_box:
        w = obj.matrix_world @ Vector(c)
        for i in range(3):
            mins[i] = min(mins[i], w[i])
            maxs[i] = max(maxs[i], w[i])
alto = maxs[2] - mins[2]
print(f"[M45] GLB importado: alto={alto:.3f}m (esperado 1.8m)")

# Suelo arena
bpy.ops.mesh.primitive_plane_add(size=10, location=(0, 0, 0))
suelo = bpy.context.active_object
m_suelo = bpy.data.materials.new("arena")
m_suelo.use_nodes = True
m_suelo.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.85, 0.78, 0.62, 1)
suelo.data.materials.append(m_suelo)

# Sol (luz cálida 3/4)
bpy.ops.object.light_add(type="SUN", location=(3, -4, 6))
sol = bpy.context.active_object
sol.data.energy = 4.0
sol.data.color = (1.0, 0.9, 0.75)
sol.rotation_euler = (math.radians(50), 0, math.radians(-35))

# Cámara 3/4 (frente-izquierda, encuadre completo del personaje)
bpy.ops.object.camera_add(location=(2.8, -3.4, 1.6))
cam = bpy.context.active_object
cam.rotation_euler = (math.radians(75), 0, math.radians(39))
bpy.context.scene.camera = cam

# Mundo azul cielo
mundo = bpy.context.scene.world or bpy.data.worlds.new("World")
bpy.context.scene.world = mundo
mundo.use_nodes = True
mundo.node_tree.nodes["Background"].inputs[0].default_value = (0.55, 0.75, 0.9, 1)
mundo.node_tree.nodes["Background"].inputs[1].default_value = 1.0

# Render CYCLES-CPU (EEVEE headless no muestra colores — deuda técnica)
esc = bpy.context.scene
esc.render.engine = "CYCLES"
esc.cycles.device = "CPU"
esc.cycles.samples = 64
esc.render.resolution_x = 640
esc.render.resolution_y = 640
os.makedirs(os.path.dirname(PNG), exist_ok=True)
esc.render.filepath = PNG
bpy.ops.render.render(write_still=True)
print("[M45] Render:", PNG)
