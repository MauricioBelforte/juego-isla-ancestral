"""
M50 v3: Re-escalar según feedback del usuario:
  - palmera_joven: 3m -> 4.5m (muy pequeña)
  - flor_isla: 0.25m -> 0.8m (invisible)
  - arbol_frutal: 6m OK pero no se ve (está lejos) — se agrega al spawn por plan
"""
import bpy
import os

MEDIA = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media"

FIXES = {
    "50-Vegetacion_palmera_joven": 4.5,
    "50-Vegetacion_flor_isla": 0.8,
}


def limpiar_escena():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for _ in range(3):
        for bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
            for item in list(bloque):
                if item.users == 0:
                    bloque.remove(item)


def altura_maxima(objs):
    meshes = [o for o in objs if o.type == "MESH"]
    if not meshes:
        return 0.0
    min_z = min(o.bound_box[0][2] for o in meshes)
    max_z = max(o.bound_box[7][2] for o in meshes)
    return abs(max_z - min_z)


limpiar_escena()
for archivo, objetivo in FIXES.items():
    ruta = os.path.join(MEDIA, archivo + ".glb")
    if not os.path.exists(ruta):
        print(f"SKIP {archivo}")
        continue
    limpiar_escena()
    bpy.ops.import_scene.gltf(filepath=ruta)
    objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    actual = altura_maxima(objs)
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
