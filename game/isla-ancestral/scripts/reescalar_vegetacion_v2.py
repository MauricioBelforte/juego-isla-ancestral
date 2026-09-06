"""
M45/M50 v2: Corregir alturas. La pasada v1 multiplicó por el factor de la tabla
pero los GLB tenían alturas ORIGINALES variadas (0.05m a 3.86m), no ~1m.
Ahora: escalar cada GLB para alcanzar la ALTURA OBJETIVO exacta:
  multiplicador = altura_objetivo / altura_actual
Alturas objetivo (5-FUTURAS-MEJORAS): palmera 4-6m, arbusto ~1m, flor 0.2m, etc.
"""
import bpy
import os

MEDIA = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media"

# Altura OBJETIVO en metros (el tamaño que el usuario quiere ver en juego)
OBJETIVOS = {
    "50-Vegetacion_palmera": 5.0,
    "50-Vegetacion_palmera_inclinada": 5.0,
    "50-Vegetacion_palmera_joven": 3.0,
    "50-Vegetacion_arbol_frutal": 6.0,
    "50-Vegetacion_arbusto_redondo": 1.0,
    "50-Vegetacion_arbusto_floral": 1.0,
    "50-Vegetacion_helecho_gigante": 1.5,
    "50-Vegetacion_helecho_chico": 0.6,
    "50-Vegetacion_raices_expuestas": 0.5,
    "50-Vegetacion_hierba_alta": 0.4,
    "50-Vegetacion_flor_isla": 0.25,
    "50-Vegetacion_hongo_luminoso": 0.5,
    "50-Vegetacion_liana_colgante": 2.0,
    "50-Vegetacion_musgo_roca": 0.3,
    "50-Vegetacion_canas_bambu": 2.5,
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


def procesar(archivo, altura_objetivo):
    limpiar_escena()
    ruta_in = os.path.join(MEDIA, archivo)
    bpy.ops.import_scene.gltf(filepath=ruta_in)
    objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    if not objs:
        return False
    altura_actual = altura_maxima(objs)
    if altura_actual < 0.001:
        print(f"  SKIP {archivo}: altura ~0")
        return False
    multiplicador = altura_objetivo / altura_actual
    bpy.ops.object.select_all(action="DESELECT")
    for o in bpy.context.scene.objects:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.transform.resize(value=(multiplicador, multiplicador, multiplicador))
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    altura_final = altura_maxima(objs)
    bpy.ops.export_scene.gltf(filepath=ruta_in, export_format="GLB")
    print(f"  OK {archivo}: x{multiplicador:.2f} — {altura_actual:.3f}m -> {altura_final:.3f}m (objetivo {altura_objetivo}m)")
    return True


def main():
    limpiar_escena()
    procesados = 0
    errores = 0
    for archivo, objetivo in OBJETIVOS.items():
        ruta = os.path.join(MEDIA, archivo + ".glb")
        if not os.path.exists(ruta):
            continue
        try:
            if procesar(archivo + ".glb", objetivo):
                procesados += 1
        except Exception as e:
            errores += 1
            print(f"  ERROR {archivo}: {e}")
    print(f"=== RESUMEN: {procesados} procesados, {errores} errores ===")


main()
