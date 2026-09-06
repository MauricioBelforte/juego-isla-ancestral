# capturar_decor_batch.py — recorre los .blend de decoracion y captura
# cada item (vista 3/4 frontal). HEADLESS.
# E-92: tras open_mainfile, las referencias Python a la camara/luz de la
# escena previa quedan invalidas ("StructRNA removed") — se RE-CREAN
# camara+sol DESPUES de cada apertura, nunca antes.
import bpy
import os
import glob
import math
import time
from mathutils import Vector

RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\18-Casas'
CAP = os.path.join(RAIZ, 'capturas')
os.makedirs(CAP, exist_ok=True)
ts = time.strftime('%Y-%m-%d_%H-%M-%S')

bpy.context.scene.render.resolution_x = 800
bpy.context.scene.render.resolution_y = 600

blends = sorted(glob.glob(os.path.join(RAIZ, 'decor_*_lowpoly.blend')))
print('items: %d' % len(blends))
hechas = 0
for ruta in blends:
    bpy.ops.wm.open_mainfile(filepath=ruta)
    # re-crear contexto de captura (E-92: lo previo murio con el open)
    world = bpy.data.worlds.get('World') or bpy.data.worlds.new('World')
    bpy.context.scene.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes.get('Background')
    bg.inputs[0].default_value = (0.55, 0.75, 0.95, 1.0)

    luz_data = bpy.data.lights.new('CapSol', type='SUN')
    luz_data.energy = 3.0
    luz = bpy.data.objects.new('CapSol', luz_data)
    luz.rotation_euler = (math.radians(-55), math.radians(-30), 0)
    bpy.context.scene.collection.objects.link(luz)

    cam_data = bpy.data.cameras.new('CapCam')
    cam_data.lens = 40
    cam = bpy.data.objects.new('CapCam', cam_data)
    bpy.context.scene.collection.objects.link(cam)
    bpy.context.scene.camera = cam

    sm = [o for o in bpy.data.objects if o.name.startswith('SM_')]
    if not sm:
        continue
    pts = [(o.matrix_world @ v.co) for o in sm for v in o.data.vertices]
    c = Vector((sum(p.x for p in pts) / len(pts), sum(p.y for p in pts) / len(pts),
                sum(p.z for p in pts) / len(pts)))
    zmax = max(p.z for p in pts)
    dist = 1.9 + zmax * 1.35
    a = math.radians(35)
    cam.location = (c.x + math.sin(a) * dist, c.y + math.cos(a) * dist, c.z + zmax * 0.55 + 0.3)
    dir_look = c - cam.location
    cam.rotation_euler = dir_look.to_track_quat('-Z', 'Y').to_euler()
    bpy.context.view_layer.update()
    bpy.ops.render.render()
    nombre = os.path.splitext(os.path.basename(ruta))[0]
    out = os.path.join(CAP, 'cap_18_%s_%s.png' % (nombre, ts))
    bpy.data.images['Render Result'].save_render(out)
    hechas += 1
    print('cap: %s' % os.path.basename(out))
print('LISTO %d/%d' % (hechas, len(blends)))
