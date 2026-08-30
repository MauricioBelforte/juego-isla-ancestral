# crear_pico_piedra_lowpoly.py — Pico de piedra (M13-Herramientas)
# Checklist Tier C: "Pico de piedra"
#
# v2 (2026-08-29) — CORRECCIÓN DEL BUG DE SEPARACIÓN (E-27)
#
# QUÉ ESTABA MAL EN v1:
#   hijo() hacía `objeto.matrix_parent_inverse = padre.matrix_world.inverted()`.
#   Eso ANULA la herencia: child.matrix_world pasa a valer child.matrix_local.
#   El paso 7 movía el mango (`mango.location.z += delta`) para asentarlo y los
#   hijos NO lo seguían -> cabeza, puntas, ataduras y pomo quedaban 9.7 cm
#   separados del mango. Estado medido en el .blend v1:
#     SM_PicoPiedra_Mango  X[-0.127..-0.067]   (x centro -0.097)
#     todo lo demás        X ≈ 0              (x centro  0.000)
#   Además el z_min global quedó en -0.4629: el source estaba hundido 46 cm.
#
# QUÉ CAMBIA EN v2:
#   1. hijo() NO toca matrix_parent_inverse (E-27). Blender lo calcula solo al
#      asignar .parent, y así el hijo SÍ sigue al padre.
#   2. El mango nace a lo largo de Z y NO se rota -> matrix_world identidad.
#      Con eso el offset local del hijo == offset de mundo y el script sigue
#      siendo legible (no hay que hacer cuentas en el frame girado del padre).
#   3. Pose VERTICAL nativa (cabeza arriba), la que definió el log 237 para las
#      herramientas de mano. El script la produce directo: ya no hace falta
#      rotar el .blend después (esa rotación post-hoc fue la que dejó las
#      piezas separadas).
#
# Composición: mango de madera cilíndrico VERTICAL (eje Z) con cabeza de piedra
# de doble punta perpendicular (eje Y) cerca del extremo +Z, sujeta con dos
# vueltas de cuero. Pomo esférico en el extremo -Z (el que apoya en la arena).
#
# Convenciones aplicadas:
#   - E-08: piezas afinadas con primitive_cone_add(radius1=, radius2=).
#   - E-11/E-27: hijos del mango, SIN tocar matrix_parent_inverse.
#   - E-12: asentado medido al final (z_min -> 0.045).
import bpy
import os
import math
from mathutils import Vector, Euler

# ---------- 1) Limpieza (idempotencia) ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 1bis) Parenting correcto (E-27) ----------
# Al asignar .parent, Blender calcula matrix_parent_inverse =
# padre.matrix_world.inverted(). NO lo sobreescribas: si lo hacés,
# child.matrix_world se reduce a child.matrix_local y el hijo deja de seguir
# al padre en movimientos posteriores. Acá el paso 7 mueve el mango para
# asentarlo, así que la herencia tiene que quedar intacta.
def hijo(objeto, padre):
    bpy.context.view_layer.update()
    objeto.parent = padre
    return objeto

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.85, spec=0.12, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_madera = crear_mat('MAT_Madera_Mango', (0.45, 0.30, 0.18), rough=0.88)
MAT_piedra = crear_mat('MAT_Piedra_Pico',  (0.42, 0.42, 0.44), rough=0.93)
MAT_cuero  = crear_mat('MAT_Cuero_Atadura', (0.33, 0.21, 0.12), rough=0.96)
MAT_arena  = crear_mat('MAT_Arena_Isla',    (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena (NO exportar) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.6, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Mango (eje Z, VERTICAL) ----------
# El cilindro nace en Z: no lo rotamos. Así matrix_world queda identidad y el
# offset local de los hijos coincide con el offset de mundo.
LARGO_MANGO = 0.86
R_MANGO = 0.032
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=R_MANGO,
                                    depth=LARGO_MANGO,
                                    location=(0.0, 0.0, 0.0))
mango = bpy.context.object
mango.name = 'SM_PicoPiedra_Mango'
mango.data.materials.append(MAT_madera)
bpy.ops.object.select_all(action='DESELECT')
mango.select_set(True)
bpy.context.view_layer.objects.active = mango
bpy.ops.object.shade_flat()

# ---------- 5) Cabeza: bloque central + 2 puntas (hijas del mango) ----------
Z_CABEZA = 0.34   # un poco antes del extremo +Z del mango

# 5a) bloque central de la cabeza
# v1 tenía scale (0.085, 0.105, 0.065) con el mango a lo largo de X. Con el
# mango a lo largo de Z, la dimensión "a lo largo del mango" pasa a ser Z.
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, 0.0, Z_CABEZA))
bloque = bpy.context.object
bloque.name = 'SM_PicoPiedra_BloqueCabeza'
bloque.scale = (0.065, 0.105, 0.085)
bloque.data.materials.append(MAT_piedra)
hijo(bloque, mango)
bpy.ops.object.select_all(action='DESELECT')
bloque.select_set(True)
bpy.context.view_layer.objects.active = bloque
bpy.ops.object.shade_flat()

# 5b) dos puntas cónicas a lo largo de Y (perpendiculares al mango)
# Rotando -90° en X el cono apunta a +Y; rotando +90° apunta a -Y.
# La base ancha (radius1) queda del lado del bloque, la aguja hacia fuera.
LARGO_PUNTA = 0.30
for signo, sufijo in ((1, 'A'), (-1, 'B')):
    bpy.ops.mesh.primitive_cone_add(vertices=8,
                                    radius1=0.052, radius2=0.008,
                                    depth=LARGO_PUNTA,
                                    location=(0.0,
                                              signo * (0.050 + LARGO_PUNTA / 2),
                                              Z_CABEZA))
    punta = bpy.context.object
    punta.name = 'SM_PicoPiedra_Punta_%s' % sufijo
    punta.rotation_euler = (math.radians(-90.0) * signo, 0.0, 0.0)
    punta.data.materials.append(MAT_piedra)
    hijo(punta, mango)
    bpy.ops.object.select_all(action='DESELECT')
    punta.select_set(True)
    bpy.context.view_layer.objects.active = punta
    bpy.ops.object.shade_flat()

# ---------- 6) Ataduras de cuero (2 vueltas, hijas del mango) ----------
# Van coaxiales al mango (lo envuelven): mismo eje Z, sin rotación.
# Ubicadas justo debajo de la cabeza para que se vea que la sujetan.
for i, z_off in enumerate((Z_CABEZA - 0.055, Z_CABEZA - 0.115)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.044, depth=0.030,
                                        location=(0.0, 0.0, z_off))
    vuelta = bpy.context.object
    vuelta.name = 'SM_PicoPiedra_Atadura_%d' % (i + 1)
    vuelta.data.materials.append(MAT_cuero)
    hijo(vuelta, mango)

# ---------- 7) Pomo: abultamiento en el extremo -Z (el que apoya) ----------
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=R_MANGO * 1.15,
                                      location=(0.0, 0.0, -LARGO_MANGO / 2))
pomo = bpy.context.object
pomo.name = 'SM_PicoPiedra_Pomo'
pomo.data.materials.append(MAT_madera)
hijo(pomo, mango)
bpy.ops.object.select_all(action='DESELECT')
pomo.select_set(True)
bpy.context.view_layer.objects.active = pomo
bpy.ops.object.shade_flat()

# ---------- 8) Asentado medido (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_PicoPiedra')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
mango.location.z += (Z_APOYO - z_min)
bpy.context.view_layer.update()
z_final = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
# Control anti-regresión: si z_final no cambió, los hijos no siguieron al mango
# (E-27) y el pico quedó separado. Fallar fuerte en vez de guardar roto.
assert abs(z_final - Z_APOYO) < 1e-4, (
    'E-27: el asentado no movió el conjunto (z_min %.4f -> %.4f). '
    'Revisá hijo(): no debe tocar matrix_parent_inverse.' % (z_min, z_final))
print('PICO PIEDRA asentado: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_final, Z_APOYO - z_min, len(piezas)))

# ---------- 9) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.4
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(8), math.radians(35)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 10) Cámara (encuadre para objeto vertical ~0.90 m) ----------
bpy.ops.object.camera_add(location=(1.55, -1.75, 0.95))
cam = bpy.context.object
cam.name = 'CAM_PicoPiedra'
blanco = Vector((0.0, 0.0, 0.47))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 11) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '13-Herramientas',
                          'pico_piedra_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('PICO PIEDRA v2 OK — objetos SM_: %d — blend: %s'
      % (len(piezas), ruta_blend))
