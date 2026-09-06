"""
M50 v5: Escala final usando arbol_frutal (6m) como REFERENCIA.
Ajustes del usuario: arbustos demasiado grandes, palmeras chicas, hierba alta,
lianas pequeñas. arbol_frutal tiene el tamaño más acorde.
"""
import bpy
import os

MEDIA = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media"

# Referencia: arbol_frutal = 6.0m (aprobado por el usuario)
AJUSTES = {
    "50-Vegetacion_arbusto_redondo": 0.5,
    "50-Vegetacion_arbusto_floral": 0.5,
    "50-Vegetacion_liana_colgante": 8.0,
    "50-Vegetacion_palmera": 8.0,
    "50-Vegetacion_palmera_inclinada": 8.0,
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
for archivo, objetivo in AJUSTES.items():
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
