# crear_antorcha_pared_lowpoly.py — Antorcha de pared (M25-Ruinas-Templos)
# Checklist Tier D: "Antorcha de pared (con soporte)"
#
# v2 (2026-08-29 18:11, fix por directiva del usuario):
#   - Bug detectado por el usuario: en la v1, el panel de pared del set de
#     captura (Set_Pared) estaba FLOTANDO — su base estaba en z=0.40, no en
#     el suelo. Y la placa estaba a 0.42 unidades separada de la pared.
#   - Fix v2:
#     (a) Set_Pared se asienta en el suelo: center z=0.65 con scale z=1.40
#         → base en z=-0.05 (enterrada apenas en la arena), tope en z=1.35.
#     (b) Placa FLUSH contra la pared: center y=-0.415 con espesor 0.020
#         → cara trasera en y=-0.425 (toca la cara frontal de la pared a
#         y=-0.425 exacto). Y_BRAZO y todos los elementos del brazo/copa/
#         mango/tela/brasa/remaches se recalculan en base a este nuevo Y.
#
# Composición: placa trasera de hierro FLUSH contra una pared (apoyada en el
# suelo), un brazo horizontal que sale de la placa hacia un costado (+X),
# una copa de hierro al final del brazo que sostiene un mango vertical corto
# de madera envuelto en tela carbonizada, y una brasa emisiva en la punta
# (la llama en sí es VFX de Godot, M52 — el emisor es la brasa).
#
# El set de captura lleva un panel de pared (Set_Pared) con prefijo Set_ para
# que NO se exporte a Godot. El asset exportable es autosuficiente: la placa
# puede apoyarse contra cualquier pared o contra la nada (queda de pie sola).
import bpy
import os
import math
from mathutils import Vector, Euler, Matrix

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


def hacer_emisivo(m, color, fuerza=2.2):
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Emission Color'].default_value = (*color, 1.0)
    bsdf.inputs['Emission Strength'].default_value = fuerza
    return m


# Hierro: rudo, gris oscuro. Specular medio para que tenga algo de brillo sin
# ser espejo (las paredes del templo están a media luz).
MAT_hierro = crear_mat('MAT_Hierro_AntorchaP', (0.40, 0.40, 0.43),
                       rough=0.55, spec=0.45, metal=0.70)
# Madera del mango: similar a la del cofre pero sin barniz (es un mango basto).
MAT_madera = crear_mat('MAT_Madera_AntorchaP', (0.42, 0.28, 0.17), rough=0.92)
# Tela carbonizada: negro/gris muy oscuro, mate.
MAT_tela = crear_mat('MAT_Tela_AntorchaP', (0.14, 0.12, 0.11), rough=0.98)
# Brasa: naranja emisivo (la llama en sí es VFX, acá queda el emisor).
MAT_brasa = hacer_emisivo(crear_mat('MAT_Brasa_AntorchaP',
                                    (0.95, 0.42, 0.10), rough=0.60),
                          (1.0, 0.45, 0.10), 2.4)
# Pared del set de captura (NO se exporta): ocre pálido como arenisca.
MAT_pared = crear_mat('MAT_Pared_Set', (0.72, 0.62, 0.45), rough=0.95)
# Arena: para la base.
MAT_arena = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena (set de captura) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.4, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 3bis) Pared del set de captura (NO se exporta) ----------
# v2: el centro está en z=0.65 con altura 1.40 → base en z=-0.05 (apenas
# enterrada en la arena), tope en z=1.35. Antes flotaba desde z=0.40.
PARED_W = 2.0    # ancho en X
PARED_ESP = 0.05  # espesor en Y
PARED_ALTO = 1.40 # alto en Z
PARED_Y_CENTER = -0.45          # cara frontal queda en y = -0.425
PARED_Z_CENTER = -0.05 + PARED_ALTO / 2  # base en z=-0.05
bpy.ops.mesh.primitive_cube_add(size=1.0,
                                location=(0.0, PARED_Y_CENTER, PARED_Z_CENTER))
pared = bpy.context.object
pared.name = 'Set_Pared'
pared.scale = (PARED_W, PARED_ESP, PARED_ALTO)
pared.data.materials.append(MAT_pared)
bpy.ops.object.select_all(action='DESELECT')
pared.select_set(True)
bpy.context.view_layer.objects.active = pared
bpy.ops.object.shade_flat()

# ---------- 4) Placa trasera de hierro (FLUSH contra la pared) ----------
# v2: la placa se monta al ras de la cara frontal de la pared.
#   - Cara frontal de la pared: y = PARED_Y_CENTER + PARED_ESP/2 = -0.425
#   - Cara trasera de la placa: y = -0.425 (tocando)
#   - Centro de la placa: y = -0.425 + PLACA_ESP/2 = -0.415
# Dimensiones: 0.16 ancho (X) x 0.32 alto (Z) x 0.020 espesor (Y).
# La placa se apoya en el suelo: bottom en z=0.045, centro z=0.205.
PLACA_ANCHO = 0.16
PLACA_ALTO = 0.32
PLACA_ESP = 0.020
PLACA_Y_CENTER = (PARED_Y_CENTER + PARED_ESP / 2) + PLACA_ESP / 2  # -0.415
bpy.ops.mesh.primitive_cube_add(size=1.0,
                                location=(0.0, PLACA_Y_CENTER,
                                          0.045 + PLACA_ALTO / 2))
placa = bpy.context.object
placa.name = 'SM_AntorchaP_Placa'
placa.scale = (PLACA_ANCHO, PLACA_ESP, PLACA_ALTO)
placa.data.materials.append(MAT_hierro)
bpy.ops.object.select_all(action='DESELECT')
placa.select_set(True)
bpy.context.view_layer.objects.active = placa
bpy.ops.object.shade_flat()

# Cara frontal de la placa: y = PLACA_Y_CENTER + PLACA_ESP/2 = -0.405
PLACA_FRONT_Y = PLACA_Y_CENTER + PLACA_ESP / 2

# ---------- 5) Brazo horizontal de hierro ----------
# Cilindro corto que sale de la placa hacia un costado (+X). Va a la altura
# de la copa (cerca del borde superior de la placa).
BRAZO_R = 0.020
BRAZO_L = 0.18
Z_BRAZO = 0.045 + PLACA_ALTO * 0.62  # ~0.243, algo más arriba que la mitad
Y_BRAZO = PLACA_FRONT_Y + BRAZO_R      # ~-0.385, apenas saliendo de la cara frontal
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=BRAZO_R, depth=BRAZO_L,
                                    location=(PLACA_ANCHO / 2 + BRAZO_L / 2,
                                              Y_BRAZO, Z_BRAZO),
                                    rotation=(0.0, math.radians(90.0), 0.0))
brazo = bpy.context.object
brazo.name = 'SM_AntorchaP_Brazo'
brazo.data.materials.append(MAT_hierro)
bpy.ops.object.select_all(action='DESELECT')
brazo.select_set(True)
bpy.context.view_layer.objects.active = brazo
bpy.ops.object.shade_flat()

# ---------- 6) Copa de hierro al final del brazo ----------
# Cilindro chato (eje Z) que recibe el mango de la antorcha.
COPA_R = 0.045
COPA_ALTO = 0.060
X_COPA = PLACA_ANCHO / 2 + BRAZO_L  # al final del brazo
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=COPA_R, depth=COPA_ALTO,
                                    location=(X_COPA, Y_BRAZO,
                                              Z_BRAZO - COPA_ALTO / 2 + 0.005))
copa = bpy.context.object
copa.name = 'SM_AntorchaP_Copa'
copa.data.materials.append(MAT_hierro)
bpy.ops.object.select_all(action='DESELECT')
copa.select_set(True)
bpy.context.view_layer.objects.active = copa
bpy.ops.object.shade_flat()

# ---------- 7) Mango de madera (vertical, dentro de la copa) ----------
MANGO_R = 0.020
MANGO_ALTO = 0.20
Z_MANGO_BASE = Z_BRAZO - COPA_ALTO / 2 + 0.020  # apenas sobre el fondo de la copa
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=MANGO_R, depth=MANGO_ALTO,
                                    location=(X_COPA, Y_BRAZO,
                                              Z_MANGO_BASE + MANGO_ALTO / 2))
mango = bpy.context.object
mango.name = 'SM_AntorchaP_Mango'
mango.data.materials.append(MAT_madera)
bpy.ops.object.select_all(action='DESELECT')
mango.select_set(True)
bpy.context.view_layer.objects.active = mango
bpy.ops.object.shade_flat()

# ---------- 8) Tela carbonizada envolviendo la parte superior del mango ----------
TELA_R = 0.040
TELA_ALTO = 0.10
Z_TELA = Z_MANGO_BASE + MANGO_ALTO * 0.65  # tercio superior
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=TELA_R, depth=TELA_ALTO,
                                    location=(X_COPA, Y_BRAZO,
                                              Z_TELA))
tela = bpy.context.object
tela.name = 'SM_AntorchaP_Tela'
tela.data.materials.append(MAT_tela)
bpy.ops.object.select_all(action='DESELECT')
tela.select_set(True)
bpy.context.view_layer.objects.active = tela
bpy.ops.object.shade_flat()

# ---------- 9) Brasa emisiva (encima de la tela) ----------
BRASA_R = 0.034
Z_BRASA = Z_TELA + TELA_ALTO / 2 + BRASA_R * 0.6
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=BRASA_R,
                                      location=(X_COPA, Y_BRAZO, Z_BRASA))
brasa = bpy.context.object
brasa.name = 'SM_AntorchaP_Brasa'
brasa.data.materials.append(MAT_brasa)
bpy.ops.object.select_all(action='DESELECT')
brasa.select_set(True)
bpy.context.view_layer.objects.active = brasa
bpy.ops.object.shade_flat()

# ---------- 10) Remaches en la placa (4 esquinas, una sola malla) ----------
# v2: cy alineado con el nuevo Y_BRAZO (parte frontal de la placa).
import bmesh
R_REM = 0.011
bm = bmesh.new()
for (sx, sz) in [(-1, -1), (1, -1), (-1, 1), (1, 1)]:
    cx = sx * (PLACA_ANCHO / 2 - 0.020)
    cz = 0.045 + (PLACA_ALTO / 2) + sz * (PLACA_ALTO / 2 - 0.030)
    cy = PLACA_FRONT_Y + 0.002  # apenas salidos de la cara frontal
    tmp = bmesh.new()
    bmesh.ops.create_cube(tmp, size=1.0)
    m = (Matrix.Translation((cx, cy, cz))
         @ Matrix.Diagonal((R_REM * 2, R_REM * 1.3, R_REM * 2, 1.0)))
    mapa = {}
    for v in tmp.verts:
        mapa[v.index] = bm.verts.new(m @ v.co)
    for f in tmp.faces:
        bm.faces.new(tuple(mapa[vi] for vi in (
            [list(tmp.verts).index(v) for v in f.verts]
        )))
    tmp.free()
bm.normal_update()
me_rem = bpy.data.meshes.new('SM_AntorchaP_Remaches')
bm.to_mesh(me_rem)
bm.free()
remaches = bpy.data.objects.new('SM_AntorchaP_Remaches', me_rem)
escena.collection.objects.link(remaches)
remaches.data.materials.append(MAT_hierro)
bpy.ops.object.select_all(action='DESELECT')
remaches.select_set(True)
bpy.context.view_layer.objects.active = remaches
bpy.ops.object.shade_flat()

# ---------- 11) Asentado (E-12 + E-24) ----------
Z_APOYO = 0.045


def zmin_real(o):
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)


bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_AntorchaP')]
z_min = min(zmin_real(o) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(zmin_real(o) for o in piezas)
print('ANTORCHA PARED v2 asentada: z_min %.3f -> %.3f (delta %+.3f)'
      % (z_min, z_fin, delta))

# ---------- 12) Iluminación + mundo ----------
sol_data = bpy.data.lights.new('SOL', type='SUN')
sol_data.energy = 3.4
sol = bpy.data.objects.new('SOL', sol_data)
escena.collection.objects.link(sol)
sol.rotation_euler = Euler((math.radians(50), math.radians(8),
                            math.radians(35)), 'XYZ')

mundo = bpy.data.worlds.get('Mundo') or bpy.data.worlds.new('Mundo')
escena.world = mundo
mundo.use_nodes = True
bg = mundo.node_tree.nodes.get('Background')
bg.inputs[0].default_value = (0.58, 0.79, 0.95, 1.0)
bg.inputs[1].default_value = 0.55

# ---------- 13) Cámara ----------
# Vista 3/4 frontal-derecha. Mirando a la placa desde un costado para ver
# el brazo extendiéndose.
bpy.ops.object.camera_add(location=(0.65, 0.80, 0.50))
cam = bpy.context.object
cam.name = 'CAM_AntorchaPared'
blanco = Vector((0.05, -0.10, 0.25))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 42
escena.camera = cam

# ---------- 14) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '25-Ruinas-Templos',
                          'antorcha_pared_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')  # E-21
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_sm = len([o for o in bpy.data.objects if o.name.startswith('SM_')])
print('ANTORCHA PARED v2 OK — SM_: %d — blend: %s' % (n_sm, ruta_blend))
