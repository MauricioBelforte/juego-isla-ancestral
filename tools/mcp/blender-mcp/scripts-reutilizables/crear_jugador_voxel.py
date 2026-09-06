# -*- coding: utf-8 -*-
"""
crear_jugador_voxel.py — M45: modelo voxel cozy del jugador (estilo Stardew).

Diseño (voxel = 0.1m, jugador = 1.8m = 18 voxels de alto, mirando -Y abajo):
    Cabeza:  6x6x6 voxels  (0.6m, y 12-18)  piel + pelo marrón (top/atrás)
    Torso:   8 ancho x 4 prof x 6 alto    (y 6-12)  camisa verde cozy
    Brazos:  2x2x6 a los lados del torso  (y 6-12)  camisa + manos piel
    Piernas: 3x3x6 cada una               (y 0-6)   pantalón azul
    Base total: 8x4 voxels en X/Z (0.8m x 0.4m) para reemplazar la cápsula 0.8m.

Convenciones E-68: cube(size) ya crea dimensiones FINALES (size = lados), no
se escala después. Origen del personaje en la BASE (z=0) para asentar.
E-45: headless con --factory-startup; export GLB directo.
Salida: game/isla-ancestral/assets/3d/media/45-Arte3D_jugador_voxel.glb
"""

import bpy  # noqa: E402
import os  # noqa: E402

V = 0.1  # tamaño del voxel en metros

# Paleta cozy Stardew-like
C_PIEL = (0.937, 0.784, 0.686, 1.0)
C_PELO = (0.310, 0.204, 0.122, 1.0)
C_CAMISA = (0.376, 0.573, 0.376, 1.0)   # verde pastel
C_PANTALON = (0.278, 0.365, 0.545, 1.0)  # azul
C_ZAPATOS = (0.216, 0.165, 0.125, 1.0)   # marrón oscuro

RUTA_SALIDA = os.path.abspath(os.path.join(
    os.path.dirname(__file__), "..", "..", "..", "..",
    "game", "isla-ancestral", "assets", "3d", "media", "45-Arte3D_jugador_voxel.glb"))


def limpiar():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def mat(nombre, color):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Roughness"].default_value = 0.9
    return m


def cubo(nombre, x0, y0, z0, nx, ny, nz, material):
    """Caja de nx x ny x nz voxels con esquina inferior en (x0, y0, z0).
    E-68: las dimensiones del cubo son FINALES (nx*V de lado)."""
    bpy.ops.mesh.primitive_cube_add(
        size=1.0,
        location=(x0 + nx * V / 2, y0 + ny * V / 2, z0 + nz * V / 2))
    obj = bpy.context.active_object
    obj.name = nombre
    obj.scale = (nx * V, ny * V, nz * V)  # size=1 -> scale = dimensiones finales
    obj.data.materials.append(material)
    return obj


def main():
    limpiar()
    m_piel = mat("M45_piel", C_PIEL)
    m_pelo = mat("M45_pelo", C_PELO)
    m_camisa = mat("M45_camisa", C_CAMISA)
    m_pantalon = mat("M45_pantalon", C_PANTALON)
    m_zapatos = mat("M45_zapatos", C_ZAPATOS)

    # ---- Piernas (y 0-6, z 0-6): dos columnas 3x3, con zapatos (z 0-1)
    cubo("pierna_izq", -0.4, -0.2, 0.1, 3, 3, 5, m_pantalon)   # x -0.4..-0.1
    cubo("pierna_der", 0.1, -0.2, 0.1, 3, 3, 5, m_pantalon)    # x 0.1..0.4
    cubo("zapato_izq", -0.4, -0.2, 0.0, 3, 3, 1, m_zapatos)
    cubo("zapato_der", 0.1, -0.2, 0.0, 3, 3, 1, m_zapatos)

    # ---- Torso (y 6-12): 8 ancho x 4 prof x 6 alto  (x -0.4..0.4)
    cubo("torso", -0.4, -0.2, 0.6, 8, 4, 6, m_camisa)

    # ---- Brazos (a los lados, x -0.6..-0.4 y 0.4..0.6, 2x2x5, z 0.6-1.1)
    cubo("brazo_izq", -0.6, -0.2, 0.6, 2, 2, 5, m_camisa)
    cubo("brazo_der", 0.4, -0.2, 0.6, 2, 2, 5, m_camisa)
    # manos (último voxel del brazo, en piel)
    cubo("mano_izq", -0.6, -0.2, 1.1, 2, 2, 1, m_piel)
    cubo("mano_der", 0.4, -0.2, 1.1, 2, 2, 1, m_piel)

    # ---- Cabeza (z 1.2-1.8): 6x6x6 (x -0.3..0.3), centrada sobre el torso
    cubo("cabeza", -0.3, -0.3, 1.2, 6, 6, 6, m_piel)
    # Pelo v2 (fix usuario): gorro FINO 7x7x1 una capa por ENCIMA (z 1.8-1.9),
    # sin solapar la cabeza (no z-fighting, no engorda la cara).
    # Nuca: 1 voxel de alto pegado atrás (y 0.3..0.4), fuera del volumen.
    cubo("pelo_top", -0.35, -0.35, 1.8, 7, 7, 1, m_pelo)
    cubo("pelo_nuca", -0.35, 0.3, 1.6, 7, 1, 2, m_pelo)
    # Patillas finas: 1x1x2 a los lados (x ±0.3..0.35), solo mitad superior,
    # sin tocar la cara (-y)
    cubo("patilla_izq", -0.35, 0.1, 1.6, 1, 1, 2, m_pelo)
    cubo("patilla_der", 0.3, 0.1, 1.6, 1, 1, 2, m_pelo)
    # ojos (2 voxels frontales, en la cara -Y)
    m_ojos = mat("M45_ojos", (0.13, 0.13, 0.16, 1.0))
    cubo("ojo_izq", -0.2, -0.31, 1.5, 1, 1, 1, m_ojos)
    cubo("ojo_der", 0.1, -0.31, 1.5, 1, 1, 1, m_ojos)

    # ---- Origen en la base + shade flat (estilo voxel)
    for o in bpy.context.scene.objects:
        if o.type == "MESH":
            for p in o.data.polygons:
                p.use_smooth = False

    # Origen del export: la base del personaje está en z=0 de las cajas;
    # glTF exporta +Y arriba (yup), Godot importa Z-up -> rotado por el importer.
    os.makedirs(os.path.dirname(RUTA_SALIDA), exist_ok=True)
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(
        filepath=RUTA_SALIDA,
        export_format="GLB",
        use_selection=True,
        export_yup=True,
    )
    print("[M45] Exportado:", RUTA_SALIDA)
    print("[M45] voxels totales: 18 de alto (1.8m), base 0.8x0.4m")


main()
