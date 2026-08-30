# crear_cartel_indicador_lowpoly.py — Cartel indicador (M40-Infraestructura)
# Checklist Tier D: "Vallas de madera y carteles (M40)"
#
# Composición: poste de madera vertical con 2 tablas indicadoras apuntando en
# direcciones opuestas (el clásico poste de señalización de los pueblos costeros).
# Todo apoyado en la arena, z_min = 0.045 (E-12).
#
# NOTA E-24: el asentado mide sobre los VERTICES REALES, no sobre las 8 esquinas
# del bound_box. Las tablas están rotadas; su AABB incluiría esquinas vacías y
# el mínimo quedaría por debajo de la geometría real, levantando todo el cartel.
import bpy
import os
import math
from mathutils import Vector, Euler

# ---------- 1) Limpieza ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.85, spec=0.15, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_poste    = crear_mat('MAT_Madera_Poste',  (0.38, 0.26, 0.16), rough=0.90)
MAT_tabla    = crear_mat('MAT_Madera_Tabla',  (0.55, 0.40, 0.24), rough=0.88)
MAT_hierro   = crear_mat('MAT_Hierro_Clavo',  (0.30, 0.30, 0.33), rough=0.55, metal=0.7)
MAT_arena    = crear_mat('MAT_Arena_Isla',    (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena (set de captura, NO se exporta) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)


# ---------- 4) Helper: caja lowpoly con shade_flat ----------
def caja(nombre, dimensiones, ubicacion, rotacion=(0.0, 0.0, 0.0), mat=None):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=ubicacion)
    o = bpy.context.object
    o.name = nombre
    o.scale = dimensiones
    o.rotation_euler = Euler(rotacion, 'XYZ')
    if mat is not None:
        o.data.materials.append(mat)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()
    return o


# ---------- 5) Poste principal ----------
# Poste cuadrado de 0.09 x 0.09, altura 1.40. Apoya en z=0 y sube hasta 1.40.
POSTE_ALTO = 1.40
POSTE_LADO = 0.09
caja('SM_Cartel_Poste',
     (POSTE_LADO, POSTE_LADO, POSTE_ALTO),
     (0.0, 0.0, POSTE_ALTO / 2.0),
     (0.0, 0.0, 0.0),
     MAT_poste)

# ---------- 6) Tabla 1 — apunta a +X, arriba ----------
# La tabla cuelga del poste: su centro está desplazado en +X respecto al poste.
TABLA1_LARGO = 0.55
caja('SM_Cartel_Tabla_1',
     (TABLA1_LARGO, 0.030, 0.22),
     (0.24, 0.0, 1.12),
     (0.0, 0.0, math.radians(-4)),
     MAT_tabla)

# Clavo/tornillo que sujeta la tabla 1 al poste
caja('SM_Cartel_Clavo_1',
     (0.020, 0.050, 0.020),
     (0.045, 0.0, 1.12),
     (0.0, 0.0, 0.0),
     MAT_hierro)

# ---------- 7) Tabla 2 — apunta a -X, más abajo y girada ----------
TABLA2_LARGO = 0.44
caja('SM_Cartel_Tabla_2',
     (TABLA2_LARGO, 0.030, 0.20),
     (-0.20, 0.0, 0.86),
     (0.0, math.radians(12), math.radians(5)),
     MAT_tabla)

caja('SM_Cartel_Clavo_2',
     (0.020, 0.050, 0.020),
     (-0.040, 0.0, 0.86),
     (0.0, 0.0, 0.0),
     MAT_hierro)

# ---------- 8) Asentado (E-12 + fix E-24: vértices reales) ----------
Z_APOYO = 0.045


def zmin_real(o):
    """Mínimo Z mundial sobre vértices reales, no sobre el AABB."""
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)


bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Cartel')]
z_min = min(zmin_real(o) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(zmin_real(o) for o in piezas)
print('CARTEL asentado: z_min %.3f -> %.3f (delta %+.3f)' % (z_min, z_fin, delta))

# ---------- 9) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.2
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(6), math.radians(30)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 10) Cámara ----------
bpy.ops.object.camera_add(location=(-1.10, -1.30, 0.95))
cam = bpy.context.object
cam.name = 'CAM_Cartel'
blanco = Vector((0.0, 0.0, 0.80))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 11) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '40-Infraestructura',
                          'cartel_indicador_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')  # E-21
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_sm = len([o for o in bpy.data.objects if o.name.startswith('SM_')])
print('CARTEL INDICADOR OK — SM_: %d — blend: %s' % (n_sm, ruta_blend))
