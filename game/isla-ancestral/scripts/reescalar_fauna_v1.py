"""
M36 v1: Medir alturas de fauna GLB y escalar según tabla (cangrejo 0.25m,
gaviota 0.5m, tortuga 0.8m, jabali 1.1m adulto).
"""
import bpy
import os

MEDIA = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media"

FAUNA = {
    "36-Fauna_cangrejo_playa": 0.25,
    "36-Fauna_gaviota": 0.5,
    "36-Fauna_tortuga_marina": 0.8,
    "36-Fauna_jabali": 1.1,
}


def limpiar_escena():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def altura_maxima(objs):
    meshes = [o for o in objs if o.type == "MESH"]
    if not meshes:
        return 0.0
    return abs(max(o.bound_box[7][2] for o in meshes) - min(o.bound_box[0][2] for o in meshes))


limpiar_escena()
for archivo, objetivo in FAUNA.items():
    ruta = os.path.join(MEDIA, archivo + ".glb")
    if not os.path.exists(ruta):
        print(f"SKIP {archivo}")
        continue
    limpiar_escena()
    bpy.ops.import_scene.gltf(filepath=ruta)
    objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    actual = altura_maxima(objs)
    if actual < 0.001:
        print(f"SKIP {archivo}: altura ~0")
        continue
    mult = objetivo / actual
    bpy.ops.object.select_all(action="DESELECT")
    for o in bpy.context.scene.objects:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.transform.resize(value=(mult, mult, mult))
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    final = altura_maxima(objs)
    bpy.ops.export_scene.gltf(filepath=ruta, export_format="GLB")
    print(f"OK {archivo}: x{mult:.2f} — {actual:.2f}m -> {final:.2f}m (objetivo {objetivo}m)")
print("=== FIN ===")
