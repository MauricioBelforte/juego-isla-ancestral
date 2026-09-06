"""
Conejo APROBADO (v5) → exportar a GLB con scale horneado (1:1, altura 0.35m).
Ruta destino: assets/3d/media/36-Fauna_conejo.glb (nomenclatura FaunaManager).
"""
import bpy

# Abrir el .blend aprobado
APROBADO = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\conejo_cozy.blend"
bpy.ops.wm.open_mainfile(filepath=APROBADO)

# El conejo está a escala real (0.35m alto total) — el GLB sale tal cual
# (el spawner de fauna aplicará escala runtime si hace falta via escalas.json)
OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\36-Fauna_conejo.glb"

# Seleccionar solo los meshes del conejo (no cámara/luces)
bpy.ops.object.select_all(action="DESELECT")
for o in bpy.context.scene.objects:
    if o.type == "MESH":
        o.select_set(True)
bpy.context.scene.render.engine = "BLENDER_WORKBENCH"
bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB", use_selection=True)
print("EXPORTADO:", OUT)
