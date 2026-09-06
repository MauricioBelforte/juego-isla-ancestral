# -*- coding: utf-8 -*-
"""
reescalar_v5.py — Hornea la altura objetivo de los GLBs de vegetación (M50).

POR QUÉ EXISTE: los GLBs de vegetación miden alturas nativas dispares
(arbusto_redondo=12.2m, arbol_frutal=10.9m, flor_isla=1.4m) porque las
iteraciones 4-9 re-escalaron algunos pero no todos, y las escalas de
escalas.json están todas a 1.0. Este script normaliza cada GLB a su altura
objetivo EN Blender (horneado), para dejar escalas.json a 1.0 definitivo.

COMO SE EJECUTA (E-45: siempre headless, nunca por socket):
    "<blender.exe>" -b --factory-startup --python reescalar_v5.py

FLUJO por GLB:
    1. Respaldo del original a Obsoletos/<timestamp>/ (regla AGENTS §5)
    2. Importar GLB
    3. Escalar jerarquía a altura objetivo (factor = objetivo / alto_actual)
    4. Aplicar transforms + asentar base en Z=0 (origen en la base, BUG-022)
    5. Exportar GLB (sobrescribe el original)
    6. Re-verificar midiendo el archivo exportado

La lista OBJETIVOS edita a mano: (nombre_archivo, altura_metro).
Jugador de referencia: 1.8m. Aprobados por usuario: arbol_frutal=6.0,
flor_isla=1.2 (iteraciones 4-9, Logs 646-675).
"""

import bpy  # noqa: E402
import os  # noqa: E402
import shutil  # noqa: E402
from mathutils import Vector  # noqa: E402

# RUTA_BASE se calcula relativa a este archivo: tools/mcp/blender-mcp/scripts-reutilizables/
# -> proyecto raíz es ../../../../..
RUTA_BASE = os.path.abspath(os.path.join(
    os.path.dirname(__file__), "..", "..", "..", "..",
    "game", "isla-ancestral", "assets", "3d", "media"))
RUTA_OBSOLETOS = os.path.abspath(os.path.join(
    RUTA_BASE, "..", "..", "..", "..", "Obsoletos", "glbs_vegetacion_pre_reescalar_v5"))

# (archivo.glb, altura_objetivo_metro)
OBJETIVOS = [
    ("50-Vegetacion_arbol_frutal.glb", 6.0),
    ("50-Vegetacion_arbusto_redondo.glb", 1.0),
    ("50-Vegetacion_arbusto_floral.glb", 1.0),
    ("50-Vegetacion_flor_isla.glb", 1.2),
    ("50-Vegetacion_hierba_alta.glb", 0.6),
    ("50-Vegetacion_helecho_chico.glb", 0.7),
    ("50-Vegetacion_helecho_gigante.glb", 2.5),
    ("50-Vegetacion_palmera_joven.glb", 3.0),
    ("50-Vegetacion_palmera.glb", 7.0),
    ("50-Vegetacion_palmera_inclinada.glb", 7.0),
]


def limpiar_escena():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def medir_alto(objs):
    mins = [1e9] * 3
    maxs = [-1e9] * 3
    hay = False
    for obj in objs:
        if obj.type != "MESH":
            continue
        hay = True
        for corner in obj.bound_box:
            w = obj.matrix_world @ Vector(corner)
            for i in range(3):
                mins[i] = min(mins[i], w[i])
                maxs[i] = max(maxs[i], w[i])
    if not hay:
        return 0.0, 0.0
    return maxs[2] - mins[2], mins[2]


def procesar(nombre, objetivo):
    ruta = os.path.join(RUTA_BASE, nombre)
    if not os.path.exists(ruta):
        print(f"[V5] {nombre}: NO EXISTE — skip")
        return
    # 1. Respaldo
    os.makedirs(RUTA_OBSOLETOS, exist_ok=True)
    destino_bak = os.path.join(RUTA_OBSOLETOS, nombre)
    if not os.path.exists(destino_bak):
        shutil.copy2(ruta, destino_bak)
        print(f"[V5] {nombre}: respaldo -> Obsoletos/")
    # 2. Importar
    limpiar_escena()
    bpy.ops.import_scene.gltf(filepath=ruta)
    raices = [o for o in bpy.context.scene.objects if o.parent is None]
    alto, _ = medir_alto(bpy.context.scene.objects)
    if alto <= 0.0:
        print(f"[V5] {nombre}: sin meshes — skip")
        return
    factor = objetivo / alto
    # 3. Escalar cada raíz (mantiene jerarquía)
    for r in raices:
        r.scale = (r.scale[0] * factor, r.scale[1] * factor, r.scale[2] * factor)
    bpy.context.view_layer.update()
    # 4. Aplicar transforms en los meshes y asentar base en Z=0
    for o in bpy.context.scene.objects:
        if o.type == "MESH" and o.modifiers is not None:
            pass
    for r in raices:
        bpy.ops.object.select_all(action="DESELECT")
        r.select_set(True)
        for c in r.children_recursive:
            c.select_set(True)
        bpy.context.view_layer.objects.active = r
        if any(c.type == "MESH" for c in [r] + list(r.children_recursive)):
            bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    bpy.context.view_layer.update()
    # Asentar: mover toda la jerarquía para que min Z global = 0
    _, min_z = medir_alto(bpy.context.scene.objects)
    for r in raices:
        r.location.z -= min_z
    bpy.context.view_layer.update()
    alto_final, base_final = medir_alto(bpy.context.scene.objects)
    # 5. Exportar GLB (solo meshes: purga de ayudas E-44 preventiva)
    bpy.ops.object.select_all(action="DESELECT")
    for o in bpy.context.scene.objects:
        if o.type == "MESH" or (o.type == "EMPTY" and o.children):
            o.select_set(True)
    bpy.ops.export_scene.gltf(
        filepath=ruta,
        export_format="GLB",
        use_selection=True,
        export_yup=True,
    )
    # 6. Verificación: reimportar el archivo exportado
    limpiar_escena()
    bpy.ops.import_scene.gltf(filepath=ruta)
    alto_ver, _ = medir_alto(bpy.context.scene.objects)
    ok = abs(alto_ver - objetivo) < 0.02
    print(f"[V5] {nombre}: nativo={alto:.2f}m factor={factor:.4f} -> "
          f"horneado={alto_ver:.3f}m (objetivo={objetivo}m) "
          f"{'OK' if ok else 'DESCORRELACION'}")


def main():
    print("=== REESCALAR V5 (M50 iter. 10) ===")
    for nombre, objetivo in OBJETIVOS:
        procesar(nombre, objetivo)
    print("=== FIN REESCALAR V5 ===")


main()
