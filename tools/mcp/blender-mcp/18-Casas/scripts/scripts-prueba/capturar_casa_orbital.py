# capturar_casa_orbital.py — 6 capturas orbitales de la casa mediana (M18-BIS).
# Se ejecuta DENTRO de Blender MCP (socket) con la casa ya abierta.
# Guarda en capturas/ con timestamp (nunca sobrescribir).
import bpy
import os
import math
from mathutils import Vector

RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\18-Casas\capturas'
os.makedirs(RAIZ, exist_ok=True)

# Camara orbital: la casa mide 8x6, centro (0,0,0), alto hasta 3.745
DIST = 10.5
ALT = 3.2
AZIMUTS = [30, 90, 150, 210, 270, 330]  # 6 vistas

# Escena de captura: fondo cielo + sol
world = bpy.data.worlds.get('World') or bpy.data.worlds.new('World')
bpy.context.scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.55, 0.75, 0.95, 1.0)
bg.inputs[1].default_value = 1.0

cam_data = bpy.data.cameras.new('CapCam')
cam_data.lens = 32
cam = bpy.data.objects.new('CapCam', cam_data)
bpy.context.scene.collection.objects.link(cam)
bpy.context.scene.camera = cam

luz_data = bpy.data.lights.new('CapSol', type='SUN')
luz_data.energy = 3.0
luz_data.angle = 0.5
luz = bpy.data.objects.new('CapSol', luz_data)
luz.rotation_euler = (math.radians(-55), math.radians(-30), 0)
bpy.context.scene.collection.objects.link(luz)

bpy.context.scene.render.engine = 'BLENDER_EEVEE_NEXT' if hasattr(bpy.types, 'RenderEngine') else 'BLENDER_EEVEE'
bpy.context.scene.render.resolution_x = 1280
bpy.context.scene.render.resolution_y = 720
bpy.context.scene.render.film_transparent = False

import time
ts = time.strftime('%Y-%m-%d_%H-%M-%S')
rutas = []
for az in AZIMUTS:
    a = math.radians(az)
    cam.location = (math.sin(a) * DIST, math.cos(a) * DIST, ALT)
    dir_look = Vector((0, 0, 1.6)) - cam.location
    cam.rotation_euler = dir_look.to_track_quat('-Z', 'Y').to_euler()
    bpy.context.view_layer.update()
    bpy.ops.render.render()
    ruta = os.path.join(RAIZ, 'cap_18_casa_mediana_%s_az%d.png' % (ts, az))
    bpy.data.images['Render Result'].save_render(ruta)
    rutas.append(ruta)
    print('captura: %s' % ruta)
print('LISTO %d capturas' % len(rutas))
