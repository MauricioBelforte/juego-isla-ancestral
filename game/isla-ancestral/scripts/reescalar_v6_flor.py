"""
M50 v6: flor_isla de 2.4m -> 0.3m (demasiado grande según el usuario).
"""
import bpy
import os

MEDIA = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media"
OBJETIVO = 0.3


def limpiar_escena():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def altura_maxima(objs):
    meshes = [o for o in objs if o.type == "MESH"]
    if not meshes:
        return 0.0
    return abs(max(o.bound_box[7][2] for o in meshes) - min(o.bound_box[0][2] for o in meshes))


limpiar_escena()
ruta = os.path.join(MEDIA, "50-Vegetacion_flor_isla.glb")
bpy.ops.import_scene.gltf(filepath=ruta)
objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
actual = altura_maxima(objs)
mult = OBJETIVO / actual
bpy.ops.object.select_all(action="DESELECT")
for o in bpy.context.scene.objects:
    o.select_set(True)
bpy.context.view_layer.objects.active = objs[0]
bpy.ops.transform.resize(value=(mult, mult, mult))
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
final = altura_maxima(objs)
bpy.ops.export_scene.gltf(filepath=ruta, export_format="GLB")
print(f"OK flor_isla: x{mult:.2f} — {actual:.2f}m -> {final:.2f}m")
