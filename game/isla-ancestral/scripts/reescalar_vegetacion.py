"""
M45/M50: Re-escalar GLBs de vegetación según la tabla de tamaños estándar.
Ejecutar con: blender --background --python reescalar_vegetacion.py

Para cada GLB en media/50-Vegetacion_*.glb:
  1. Importar el GLB
  2. Aplicar la escala objetivo (de escalas.json vía tabla inline)
  3. Aplicar transform (Apply All Transforms) para hornear el scale en los vértices
  4. Exportar el GLB reescalado (sobrescribe el original)

Referencia de mundo: personaje = 1.8m, voxel = 1m.
Altura GLB de origen: ~1m (medida promedio del pipeline M166).
"""
import bpy
import os
import sys
import json

MEDIA = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media"

# Tabla de escalas objetivo (de data/escalas/escalas.json — categoría vegetacion)
# multiplicador = altura_objetivo / altura_glb_original (~1m)
ESCALAS = {
    "50-Vegetacion_palmera": 5.0,
    "50-Vegetacion_palmera_inclinada": 5.0,
    "50-Vegetacion_palmera_joven": 3.0,
    "50-Vegetacion_arbol_frutal": 6.0,
    "50-Vegetacion_arbusto_redondo": 3.0,
    "50-Vegetacion_arbusto_floral": 3.0,
    "50-Vegetacion_helecho_gigante": 4.0,
    "50-Vegetacion_helecho_chico": 2.0,
    "50-Vegetacion_raices_expuestas": 2.0,
    "50-Vegetacion_hierba_alta": 2.5,
    "50-Vegetacion_flor_isla": 1.5,
    "50-Vegetacion_hongo_luminoso": 2.0,
    "50-Vegetacion_liana_colgante": 4.0,
    "50-Vegetacion_musgo_roca": 1.0,
    "50-Vegetacion_canas_bambu": 4.0,
}


def limpiar_escena():
    """Elimina todos los objetos de la escena."""
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for _ in range(3):
        for bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
            for item in list(bloque):
                if item.users == 0:
                    bloque.remove(item)


def altura_maxima(objs):
    """Altura Z máxima de los objetos dados."""
    if not objs:
        return 0.0
    min_z = min(o.bound_box[0][2] for o in objs if o.type == "MESH")
    max_z = max(o.bound_box[7][2] for o in objs if o.type == "MESH")
    return abs(max_z - min_z)


def procesar(archivo, escala):
    limpiar_escena()
    ruta_in = os.path.join(MEDIA, archivo)
    bpy.ops.import_scene.gltf(filepath=ruta_in)
    objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    if not objs:
        print(f"  SKIP {archivo}: sin meshes")
        return False
    altura_antes = altura_maxima(objs)
    # Seleccionar todos los objetos importados y escalar
    bpy.ops.object.select_all(action="DESELECT")
    for o in bpy.context.scene.objects:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.transform.resize(value=(escala, escala, escala))
    # Hornear el scale en los vértices (crítico: evita issues de normales/física)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    altura_despues = altura_maxima(objs)
    # Exportar al mismo archivo (sobrescribe)
    ruta_out = ruta_in
    bpy.ops.export_scene.gltf(filepath=ruta_out, export_format="GLB")
    print(f"  OK {archivo}: escala x{escala} — altura {altura_antes:.3f}m -> {altura_despues:.3f}m")
    return True


def main():
    # Limpiar escena inicial
    limpiar_escena()
    procesados = 0
    errores = 0
    for archivo, escala in ESCALAS.items():
        ruta = os.path.join(MEDIA, archivo + ".glb")
        if not os.path.exists(ruta):
            print(f"  SKIP {archivo}: GLB no existe")
            continue
        try:
            if procesar(archivo + ".glb", escala):
                procesados += 1
        except Exception as e:
            errores += 1
            print(f"  ERROR {archivo}: {e}")
    print(f"=== RESUMEN: {procesados} procesados, {errores} errores ===")


main()
