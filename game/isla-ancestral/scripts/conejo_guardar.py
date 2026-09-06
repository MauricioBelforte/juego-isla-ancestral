"""
Conejo v6 (fix de cerca): 
- orejas BAJADAS hasta dentro de la cabeza (gap eliminado)
- ojos a ras de la cara (sobresalen 0.005)
- brillito apenas asomando del ojo (0.003)
"""
import bpy

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
for _ in range(3):
    for bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for item in list(bloque):
            if item.users == 0:
                bloque.remove(item)

def mat(nombre, r, g, b):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (r, g, b, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.9
    return m

M_PELLO = mat("pello_marron", 0.55, 0.38, 0.24)
M_VIENTRE = mat("vientre_crema", 0.92, 0.88, 0.80)
M_OJOS = mat("ojos_negro", 0.03, 0.03, 0.03)
M_BRILLO = mat("brillo_blanco", 0.98, 0.98, 0.98)
M_NARIZ = mat("nariz_rosa", 0.85, 0.55, 0.55)

def cubo(nombre, sx, sy, sz, x, y, z, material):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
    o = bpy.context.active_object
    o.name = nombre
    o.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(scale=True)
    o.data.materials.append(material)
    return o

# ── Cuerpo ──
cubo("cuerpo", 0.18, 0.28, 0.16, 0, 0.02, 0.13, M_PELLO)
cubo("vientre", 0.14, 0.20, 0.05, 0, 0.00, 0.045, M_VIENTRE)
# cabeza: top en z=0.31
cubo("cabeza", 0.15, 0.15, 0.14, 0, -0.19, 0.24, M_PELLO)
cubo("hocico", 0.09, 0.06, 0.08, 0, -0.28, 0.21, M_VIENTRE)
cubo("nariz", 0.04, 0.02, 0.03, 0, -0.315, 0.225, M_NARIZ)

# ── Ojos A RAS: grosor 0.03, sobresalen 0.005 del frente de la cabeza ──
# cara frontal de la cabeza en y=-0.265; ojo centrado en y=-0.2575
cubo("ojo_izq", 0.035, 0.03, 0.035, -0.045, -0.2575, 0.275, M_OJOS)
cubo("ojo_der", 0.035, 0.03, 0.035, 0.045, -0.2575, 0.275, M_OJOS)
# brillito: centrado en y=-0.263 (asoma 0.003 más que el ojo)
cubo("brillo_izq", 0.014, 0.012, 0.014, -0.038, -0.263, 0.287, M_BRILLO)
cubo("brillo_der", 0.014, 0.012, 0.014, 0.038, -0.263, 0.287, M_BRILLO)

# ── Orejas CONECTADAS: centro z=0.38, alto 0.22 → base en 0.27 (dentro cabeza top 0.31) ──
cubo("oreja_izq", 0.05, 0.03, 0.22, -0.05, -0.14, 0.38, M_PELLO)
cubo("oreja_der", 0.05, 0.03, 0.22, 0.05, -0.14, 0.38, M_PELLO)
cubo("oreja_int_izq", 0.025, 0.015, 0.16, -0.05, -0.155, 0.38, M_VIENTRE)
cubo("oreja_int_der", 0.025, 0.015, 0.16, 0.05, -0.155, 0.38, M_VIENTRE)

# ── Patas ──
cubo("pata_di", 0.07, 0.07, 0.10, -0.055, -0.12, 0.05, M_PELLO)
cubo("pata_dd", 0.07, 0.07, 0.10, 0.055, -0.12, 0.05, M_PELLO)
cubo("pata_ti", 0.08, 0.12, 0.10, -0.07, 0.10, 0.05, M_PELLO)
cubo("pata_td", 0.08, 0.12, 0.10, 0.07, 0.10, 0.05, M_PELLO)
cubo("cola", 0.07, 0.07, 0.07, 0, 0.185, 0.145, M_VIENTRE)

# ── Cámara + luces ──
bpy.ops.object.camera_add(location=(0.55, -0.75, 0.45), rotation=(1.134, 0, 0.611))
bpy.context.scene.camera = bpy.context.active_object
bpy.ops.object.light_add(type="SUN", location=(2, -2, 3))
bpy.context.active_object.data.energy = 3.0
bpy.context.active_object.rotation_euler = (0.785, 0, -0.524)
bpy.ops.object.light_add(type="AREA", location=(-1, -1, 1))
l2 = bpy.context.active_object
l2.data.energy = 50
l2.data.size = 2.0
l2.rotation_euler = (1.047, 0, 1.047)

OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\conejo_cozy.blend"
bpy.ops.wm.save_as_mainfile(filepath=OUT)
print("GUARDADO v6:", OUT)
