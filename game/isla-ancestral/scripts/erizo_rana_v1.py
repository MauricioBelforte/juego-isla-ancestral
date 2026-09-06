"""
M36: ERIZO voxel cozy (0.4m) — cuerpo base + púas diagonales + cara blanca.
M36: RANA voxel cozy (0.15m) — cuerpo achatado verde + ojos saltones.
Ambos en un script, render CYCLES-CPU por separado.
"""
import bpy
import math
import os
import mathutils

OUT_BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\godot-mcp\capturas\36-Fauna"

def mat(nombre, r, g, b):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (r, g, b, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.85
    return m

def cubo(nombre, sx, sy, sz, x, y, z, material):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
    o = bpy.context.active_object
    o.name = nombre
    o.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(scale=True)
    o.data.materials.append(material)
    return o

# ══════════════════════════════════════════════════════
# ERIZO (0.4m) — cuerpo pardo + púas blancas/marrón
# ══════════════════════════════════════════════════════
def crear_erizo():
    limpiar()
    M_CUERPO = mat("erizo_cuerpo", 0.45, 0.30, 0.20)
    M_ESPINAS = mat("erizo_espinas", 0.75, 0.65, 0.50)
    M_CARA = mat("erizo_cara", 0.85, 0.75, 0.65)
    M_OJOS = mat("ojos_negro", 0.03, 0.03, 0.03)
    M_BRILLO = mat("brillo_blanco", 0.98, 0.98, 0.98)
    M_NARIZ = mat("nariz_negro", 0.08, 0.06, 0.05)

    # cuerpo bajo
    cubo("cuerpo", 0.16, 0.20, 0.10, 0, 0.02, 0.06, M_CUERPO)
    # cara blanca (frente)
    cubo("cara", 0.12, 0.10, 0.08, 0, -0.14, 0.06, M_CARA)
    # nariz negra
    cubo("nariz", 0.035, 0.02, 0.03, 0, -0.195, 0.075, M_NARIZ)
    # ojos con brillito
    cubo("ojo_izq", 0.03, 0.02, 0.03, -0.035, -0.185, 0.095, M_OJOS)
    cubo("ojo_der", 0.03, 0.02, 0.03, 0.035, -0.185, 0.095, M_OJOS)
    cubo("brillo_izq", 0.010, 0.012, 0.010, -0.035, -0.193, 0.105, M_BRILLO)
    cubo("brillo_der", 0.010, 0.012, 0.010, 0.035, -0.193, 0.105, M_BRILLO)
    # púas diagonales en la espalda (4 filas de 4)
    for fila in range(4):
        z = 0.11 + fila * 0.035
        y = -0.03 + fila * 0.035
        for col in range(4):
            x = -0.06 + col * 0.04
            cubo(f"pua_{fila}_{col}", 0.02, 0.025, 0.05, x, y, z, M_ESPINAS)
    # patitas
    cubo("pata_di", 0.04, 0.04, 0.03, -0.04, -0.10, 0.015, M_CUERPO)
    cubo("pata_dd", 0.04, 0.04, 0.03, 0.04, -0.10, 0.015, M_CUERPO)
    cubo("pata_ti", 0.04, 0.04, 0.03, -0.04, 0.10, 0.015, M_CUERPO)
    cubo("pata_td", 0.04, 0.04, 0.03, 0.04, 0.10, 0.015, M_CUERPO)

    # cámara + luces
    bpy.ops.object.camera_add(location=(0.35, -0.45, 0.30), rotation=(1.134, 0, 0.611))
    sc = bpy.context.scene
    sc.camera = bpy.context.active_object
    bpy.ops.object.light_add(type="SUN", location=(1, -1, 1.5))
    bpy.context.active_object.data.energy = 3.0
    bpy.context.active_object.rotation_euler = (0.785, 0, -0.524)
    bpy.ops.object.light_add(type="AREA", location=(-0.5, -0.5, 0.5))
    l2 = bpy.context.active_object
    l2.data.energy = 30
    l2.data.size = 0.8
    l2.rotation_euler = (1.047, 0, 1.047)

    sc.render.engine = "CYCLES"
    sc.cycles.device = "CPU"
    sc.cycles.samples = 32
    sc.render.resolution_x = 640
    sc.render.resolution_y = 640
    sc.render.image_settings.file_format = "PNG"

    target = mathutils.Vector((0, 0, 0.08))
    for nombre, angulo in [("perfil_izq", 90), ("trescuartos", 45), ("frente", 0)]:
        ang = math.radians(angulo)
        offset = mathutils.Vector((math.sin(ang) * 0.4, -math.cos(ang) * 0.4, 0.15))
        sc.camera.location = target + offset
        dirv = target - sc.camera.location
        sc.camera.rotation_euler = dirv.to_track_quat("-Z", "Y").to_euler()
        sc.render.filepath = os.path.join(OUT_BASE, "erizo", f"erizo_{nombre}.png")
        bpy.ops.render.render(write_still=True)
        print(f"RENDER: erizo_{nombre}")

    OUT_BLEND = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\erizo_cozy.blend"
    bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
    print("GUARDADO:", OUT_BLEND)


# ══════════════════════════════════════════════════════
# RANA (0.15m) — cuerpo achatado verde + ojos saltones
# ══════════════════════════════════════════════════════
def crear_rana():
    limpiar()
    M_VERDE = mat("rana_verde", 0.35, 0.65, 0.25)
    M_VIENTRE = mat("rana_vientre", 0.85, 0.90, 0.70)
    M_OJOS = mat("rana_ojos", 0.95, 0.85, 0.15)  # amarillo saltones
    M_PUPILA = mat("rana_pupila", 0.05, 0.05, 0.03)
    M_BRILLO = mat("brillo_blanco", 0.98, 0.98, 0.98)
    M_PATA = mat("rana_patas", 0.28, 0.52, 0.18)

    # cuerpo achatado
    cubo("cuerpo", 0.14, 0.16, 0.08, 0, 0.0, 0.055, M_VERDE)
    # vientre claro
    cubo("vientre", 0.10, 0.12, 0.03, 0, -0.01, 0.02, M_VIENTRE)
    # cabeza (cubo frontal, un poco más ancho)
    cubo("cabeza", 0.12, 0.10, 0.06, 0, -0.11, 0.075, M_VERDE)
    # ojos SALTONES (2 esferas/cubos que sobresalen hacia arriba)
    cubo("ojo_izq", 0.045, 0.045, 0.045, -0.045, -0.13, 0.13, M_OJOS)
    cubo("ojo_der", 0.045, 0.045, 0.045, 0.045, -0.13, 0.13, M_OJOS)
    # pupilas (cubos negros al frente de los ojos)
    cubo("pupila_izq", 0.02, 0.02, 0.02, -0.045, -0.152, 0.13, M_PUPILA)
    cubo("pupila_der", 0.02, 0.02, 0.02, 0.045, -0.152, 0.13, M_PUPILA)
    # patas delanteras (2)
    cubo("pata_di", 0.03, 0.05, 0.03, -0.05, -0.09, 0.015, M_PATA)
    cubo("pata_dd", 0.03, 0.05, 0.03, 0.05, -0.09, 0.015, M_PATA)
    # patas traseras (2, más grandes, en zigzag)
    cubo("muslo_ti", 0.04, 0.08, 0.045, -0.085, 0.06, 0.025, M_PATA)
    cubo("muslo_td", 0.04, 0.08, 0.045, 0.085, 0.06, 0.025, M_PATA)
    cubo("pie_ti", 0.03, 0.07, 0.02, -0.07, -0.06, 0.01, M_PATA)
    cubo("pie_td", 0.03, 0.07, 0.02, 0.07, -0.06, 0.01, M_PATA)

    # cámara + luces
    bpy.ops.object.camera_add(location=(0.25, -0.30, 0.20), rotation=(1.134, 0, 0.611))
    sc = bpy.context.scene
    sc.camera = bpy.context.active_object
    bpy.ops.object.light_add(type="SUN", location=(0.5, -0.5, 0.8))
    bpy.context.active_object.data.energy = 3.0
    bpy.context.active_object.rotation_euler = (0.785, 0, -0.524)
    bpy.ops.object.light_add(type="AREA", location=(-0.3, -0.3, 0.3))
    l2 = bpy.context.active_object
    l2.data.energy = 30
    l2.data.size = 0.5
    l2.rotation_euler = (1.047, 0, 1.047)

    sc.render.engine = "CYCLES"
    sc.cycles.device = "CPU"
    sc.cycles.samples = 32
    sc.render.resolution_x = 640
    sc.render.resolution_y = 640
    sc.render.image_settings.file_format = "PNG"

    target = mathutils.Vector((0, 0, 0.05))
    for nombre, angulo in [("perfil_izq", 90), ("frente", 0)]:
        ang = math.radians(angulo)
        offset = mathutils.Vector((math.sin(ang) * 0.25, -math.cos(ang) * 0.25, 0.1))
        sc.camera.location = target + offset
        dirv = target - sc.camera.location
        sc.camera.rotation_euler = dirv.to_track_quat("-Z", "Y").to_euler()
        sc.render.filepath = os.path.join(OUT_BASE, "rana", f"rana_{nombre}.png")
        bpy.ops.render.render(write_still=True)
        print(f"RENDER: rana_{nombre}")

    OUT_BLEND = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\rana_cozy.blend"
    bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
    print("GUARDADO:", OUT_BLEND)


# ── Helpers ──
def limpiar():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for _ in range(3):
        for bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
            for item in list(bloque):
                if item.users == 0:
                    bloque.remove(item)

limpiar()
crear_erizo()
limpiar()
crear_rana()
print("=== ERIZO + RANA LISTOS ===")
