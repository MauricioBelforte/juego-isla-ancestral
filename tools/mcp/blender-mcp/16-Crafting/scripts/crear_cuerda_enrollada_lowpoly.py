# crear_cuerda_enrollada_lowpoly.py — Cuerda enrollada (M16-Crafting)
# Checklist Tier D: "Puentes de cuerda / cuerda enrollada (M25/M16)"
#
# Composición: rollo de cuerda (toroide acostado) con un cabo suelto asomando.
# Es el clásico rollo de soga de bodega, listo para cortar o usar. Apoyado en
# la arena, z_min = 0.045 (E-12).
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

MAT_cuerda_claro = crear_mat('MAT_Cuerda_Claro', (0.78, 0.66, 0.42), rough=0.95)
MAT_cuerda_oscuro = crear_mat('MAT_Cuerda_Oscuro', (0.58, 0.46, 0.28), rough=0.95)
MAT_arena = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena (set de captura, NO se exporta) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=2.0, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Rollo de cuerda: toroide acostado ----------
# El toroide de Blender por defecto ya está en el plano XY (acostado sobre el
# suelo). NO rotarlo: rotarlo 90° sobre X lo para como una rueda.
# 24 segmentos mayores, 8 segmentos del tubo → 192 tris (un solo rollo, dentro
# del budget). El tubo del toroide ES la soga vista de canto; un solo rollo
# apilado se lee como un coil de bodega. Poner dos rollos encima formaba un
# sándwich tipo UFO y rompía la lectura de "cuerda".
bpy.ops.mesh.primitive_torus_add(
    major_segments=24,
    minor_segments=8,
    major_radius=0.22,
    minor_radius=0.055,
    location=(0.0, 0.0, 0.045 + 0.055),  # centro a z=0.100: la base toca z=0.045
    rotation=(0.0, 0.0, 0.0),             # sin rotación: queda plano
)
rollo = bpy.context.object
rollo.name = 'SM_Cuerda_Rollo'
rollo.data.materials.append(MAT_cuerda_claro)
bpy.ops.object.select_all(action='DESELECT')
rollo.select_set(True)
bpy.context.view_layer.objects.active = rollo
bpy.ops.object.shade_flat()

# ---------- 5) Segundo rollo superpuesto (enrollado en sí mismo) ----------
# Un segundo toroide del mismo tamaño, ligeramente desplazado y rotado, sugiere
# que la cuerda está enrollada sobre sí misma (vueltas adicionales). Va al
# mismo nivel que el primero (no encima) — es el clásico detalle de las bobinas
# de soga de bodega.
bpy.ops.mesh.primitive_torus_add(
    major_segments=24,
    minor_segments=8,
    major_radius=0.20,
    minor_radius=0.045,
    location=(0.02, -0.03, 0.045 + 0.045),  # base a z=0.045, top a z=0.135
    rotation=(0.0, 0.0, math.radians(15)),   # offset angular
)
rollo2 = bpy.context.object
rollo2.name = 'SM_Cuerda_Rollo_2'
rollo2.data.materials.append(MAT_cuerda_oscuro)
bpy.ops.object.select_all(action='DESELECT')
rollo2.select_set(True)
bpy.context.view_layer.objects.active = rollo2
bpy.ops.object.shade_flat()

# ---------- 6) Cabo suelto: cilindro horizontal a ras del suelo ----------
# Sale del lateral del rollo y se apoya en la arena. Rotación 90° sobre X para
# dejarlo ACOSTADO (eje largo paralelo al suelo). Esto era el bug de la versión
# anterior: el cilindro sin rotar queda vertical y parece un poste.
bpy.ops.mesh.primitive_cylinder_add(
    vertices=8, radius=0.022, depth=0.34,
    location=(0.20, 0.18, 0.045 + 0.022),  # z=0.067: la base toca z=0.045
    rotation=(math.radians(90), 0.0, math.radians(35)),  # acostado + giro en planta
)
cabo = bpy.context.object
cabo.name = 'SM_Cuerda_Cabo'
cabo.data.materials.append(MAT_cuerda_claro)
bpy.ops.object.select_all(action='DESELECT')
cabo.select_set(True)
bpy.context.view_layer.objects.active = cabo
bpy.ops.object.shade_flat()

# ---------- 7) Punta deshilachada del cabo (cono chiquito) ----------
# El cono se PARA como hijo del cabo, hereda su rotación, y se coloca en el
# extremo +Z local del cabo. Esto garantiza que SIEMPRE queda alineado con el
# cabo sin importar la rotación que se le aplique — no hay que calcular a mano
# la posición en world space.
#
# IMPORTANTE: NO tocar matrix_parent_inverse. Blender, al asignar `parent`,
# la calcula automáticamente para preservar la posición world del hijo. Si
# la sobreescribo, se rompe la herencia y la posición local pasa a ser
# directamente la posición world (error que tuve en la versión previa: el cono
# aparecía en el origen en vez de en la punta del cabo).
bpy.ops.mesh.primitive_cone_add(
    vertices=6, radius1=0.022, radius2=0.0, depth=0.045,
    location=(0, 0, 0),  # se reposiciona abajo al parenteo
)
punta = bpy.context.object
punta.name = 'SM_Cuerda_Punta'
punta.data.materials.append(MAT_cuerda_oscuro)
# Parentar al cabo. Blender ajusta matrix_parent_inverse automáticamente.
punta.parent = cabo
# Ahora, en el frame local del cabo, mover al extremo +Z (fin del cabo)
# y sumar la mitad de la profundidad del cono para que la base del cono
# toque el final del cabo.
punta.location = (0, 0, 0.34 / 2 + 0.045 / 2)
bpy.ops.object.select_all(action='DESELECT')
punta.select_set(True)
bpy.context.view_layer.objects.active = punta
bpy.ops.object.shade_flat()

# ---------- 8) Asentado (E-12 + E-24 vértices reales) ----------
Z_APOYO = 0.045


def zmin_real(o):
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)


bpy.context.view_layer.update()
piezas = [o for o in escena.objects if o.type == 'MESH' and o.name.startswith('SM_Cuerda')]
z_min = min(zmin_real(o) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(zmin_real(o) for o in piezas)
print('CUERDA asentada: z_min %.3f -> %.3f (delta %+.3f)' % (z_min, z_fin, delta))

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
bpy.ops.object.camera_add(location=(-0.40, -0.55, 0.35))
cam = bpy.context.object
cam.name = 'CAM_Cuerda'
blanco = Vector((0.0, 0.0, 0.07))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 11) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '16-Crafting',
                          'cuerda_enrollada_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')  # E-21
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_sm = len([o for o in bpy.data.objects if o.name.startswith('SM_')])
print('CUERDA ENROLLADA OK — SM_: %d — blend: %s' % (n_sm, ruta_blend))