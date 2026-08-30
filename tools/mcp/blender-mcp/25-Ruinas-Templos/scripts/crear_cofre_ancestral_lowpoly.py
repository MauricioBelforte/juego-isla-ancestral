# crear_cofre_ancestral_lowpoly.py — Cofre ancestral (M25-Ruinas-Templos)
# Checklist: "Cofre ancestral (recompensa)"
#
# Composición: cuerpo de madera lacada con bandas de hierro + remaches de bronce +
# tapa arqueada con costillas + glifos dorados + gema ancestral emisiva +
# cerradura con marco + bisagras + asas laterales + 4 pies.
#
# v2 (2026-08-28 20:20, directiva del usuario: "le veo muy simple / algo mas
# brillante no se lo veo opaco"):
#   - Materiales con COAT (capa de barniz) + roughness bajo + emision en oro/gema.
#     Antes: madera rough 0.85, hierro 0.55 -> se veia mate.
#   - Detalles nuevos: 22 remaches de bronce, 2 costillas curvas en la tapa,
#     3 glifos dorados, gema emisiva en la cerradura, marco de cerradura,
#     2 bisagras, 2 asas laterales.
#   - Los grupos de piezas chicas (remaches, costillas, glifos) se construyen
#     como UNA sola malla con bmesh para no explotar el contador de objetos.
#
# v3 (2026-08-29 19:55) — corrige E-27 (tirador y asas 5 cm de su padre):
#   La v2 hacía `o.matrix_parent_inverse = padre.matrix_world.inverted()` en 3
#   lugares (agregar() L176, costillas L339, post-parenting L404). Cuando el
#   asentado movía el cuerpo (root) en L415, los hijos no lo seguían porque
#   la inversa quedó congelada. La auditoría geométrica midió 5 cm de
#   separación entre SM_Cofre_Tirador y el cuerpo, 1.8 cm en las asas.
#   La v3 deja que Blender calcule la inversa automáticamente y agrega un
#   assert anti-regresión al final.
import bpy
import bmesh
import os
import random
import math
from mathutils import Vector, Euler, Matrix

# ---------- 1) Limpieza (E-14: NUNCA wm.read_factory_settings por el socket) ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
# E-17: limpieza UNICA vez, al inicio. No repetir a mitad del script.
escena = bpy.context.scene

# ---------- 2) Materiales ----------
# Clave del look "brillante": sin HDRI, un metal con metallic=1.0 se ve NEGRO
# (refleja un entorno plano y oscuro). El brillo real se logra combinando:
#   1) Coat Weight alto + Coat Roughness bajisimo -> reflejo especular nítido
#      del SOL encima de la base, funciona aunque el entorno sea pobre.
#   2) Metallic medio-alto (0.85-0.90) para que conserve el tinte del metal.
#   3) Emission suave en oro/bronce -> garantiza que el color se lea siempre.
# El set de luces (SOL 3.4 / mundo 0.55) NO se toca: es el mismo de todos los
# assets (§7.3 regla 3 de 09-GUIA-BLENDER.md). El brillo sale de los materiales.
def set_input(bsdf, nombre, valor):
    """Escribe un input del Principled tolerando cambios de nombre entre
    versiones de Blender (Coat Weight vs Clearcoat, Specular IOR Level vs Specular)."""
    try:
        bsdf.inputs[nombre].default_value = valor
        return True
    except Exception:
        return False


def crear_mat(nombre, color, rough=0.8, spec=0.1, metal=0.0,
              emis=None, emis_f=0.0, coat=0.0, coat_rough=0.05, transm=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Metallic'].default_value = metal
    if not set_input(bsdf, 'Specular IOR Level', spec):
        set_input(bsdf, 'Specular', spec)
    if emis is not None and emis_f > 0.0:
        if not set_input(bsdf, 'Emission Color', (*emis, 1.0)):
            set_input(bsdf, 'Emission', (*emis, 1.0))
        set_input(bsdf, 'Emission Strength', emis_f)
    if coat > 0.0:
        if not set_input(bsdf, 'Coat Weight', coat):
            set_input(bsdf, 'Clearcoat', coat)
        if not set_input(bsdf, 'Coat Roughness', coat_rough):
            set_input(bsdf, 'Clearcoat Roughness', coat_rough)
    if transm > 0.0:
        if not set_input(bsdf, 'Transmission Weight', transm):
            set_input(bsdf, 'Transmission', transm)
    return m


# Madera LACADA: barniz fuerte + un poco de emis para que no se vea opaca bajo
# un SOL a 45 grados sin HDRI. La emision es sutil (color de la madera) y solo
# garantiza que las caras en sombra no se hundan a negro.
MAT_madera = crear_mat('MAT_Madera_Cofre', (0.55, 0.34, 0.18),
                       rough=0.32, spec=0.85, coat=1.00, coat_rough=0.04,
                       emis=(0.42, 0.24, 0.10), emis_f=0.08)
MAT_madera_osc = crear_mat('MAT_Madera_Cofre_Osc', (0.38, 0.24, 0.12),
                           rough=0.40, spec=0.70, coat=0.85, coat_rough=0.06,
                           emis=(0.26, 0.14, 0.05), emis_f=0.08)
# Hierro pulido: emis gris claro para que no se vea negro en sombra
MAT_hierro = crear_mat('MAT_Hierro_Cofre', (0.55, 0.55, 0.58),
                       rough=0.22, spec=0.80, metal=0.85,
                       coat=0.90, coat_rough=0.06,
                       emis=(0.30, 0.30, 0.32), emis_f=0.06)
# Bronce: emision fuerte para que brille aunque el entorno sea pobre
MAT_bronce = crear_mat('MAT_Bronce_Cofre', (1.00, 0.74, 0.30),
                       rough=0.14, spec=0.95, metal=0.85,
                       emis=(1.00, 0.78, 0.32), emis_f=0.45,
                       coat=1.00, coat_rough=0.03)
# Oro: emision AUN mas fuerte -> es el material "joya"
MAT_oro = crear_mat('MAT_Oro_Cofre', (1.00, 0.83, 0.30),
                    rough=0.10, spec=1.00, metal=0.80,
                    emis=(1.00, 0.78, 0.25), emis_f=0.80,
                    coat=1.00, coat_rough=0.02)
# Gema: emision alta + transmission. Sera el punto mas brillante.
MAT_gema = crear_mat('MAT_Gema_Cofre', (0.40, 0.98, 1.00),
                     rough=0.02, spec=1.00, metal=0.0,
                     emis=(0.40, 0.98, 1.00), emis_f=4.50,
                     coat=1.00, coat_rough=0.02, transm=0.50)
# Gema ancestral: el punto focal. Emision fuerte + transmision + coat.
MAT_gema = crear_mat('MAT_Gema_Cofre', (0.35, 0.95, 1.00),
                     rough=0.02, spec=1.00, metal=0.0,
                     emis=(0.35, 0.95, 1.00), emis_f=2.20,
                     coat=1.00, coat_rough=0.02, transm=0.50)
MAT_arena = crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.00)

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.4, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Helpers ----------
def nueva_caja(nombre, cx, cy, cz, sx, sy, sz):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x = v.co.x * sx + cx
        v.co.y = v.co.y * sy + cy
        v.co.z = v.co.z * sz + cz
    bm.normal_update()
    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    return me


def anadir_caja_a(bm_objetivo, centro, size, rot=None):
    """Añade un cubo ya transformado a un bmesh existente.
    Usamos create_cube en un bmesh temporal y copiamos verts/caras para
    HEREDAR el winding correcto (evita caras con la normal al reves)."""
    tmp = bmesh.new()
    bmesh.ops.create_cube(tmp, size=1.0)
    m = Matrix.Translation(centro)
    if rot is not None:
        m = m @ rot.to_matrix().to_4x4()
    m = m @ Matrix.Diagonal((size[0], size[1], size[2], 1.0))
    mapa = {}
    for v in tmp.verts:
        mapa[v.index] = bm_objetivo.verts.new(m @ v.co)
    for f in tmp.faces:
        bm_objetivo.faces.new(tuple(mapa[v.index] for v in f.verts))
    tmp.free()


def cerrar_bmesh(bm, nombre):
    bm.normal_update()
    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()
    return me


def agregar(nombre, me, material, padre=None):
    o = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(o)
    o.data.materials.append(material)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()
    if padre is not None:
        # E-27 v3: NO tocar matrix_parent_inverse. La inversa "asignada a
        # mano" congela la pose del padre: si después se mueve (asentado,
        # L415), los hijos no lo siguen. Dejar que Blender la calcule
        # automáticamente basta: la location se interpreta en local del
        # padre y los hijos siguen cualquier traslación posterior.
        bpy.context.view_layer.update()
        o.parent = padre
    return o


# ---------- 5) Cuerpo del cofre ----------
W, D, H = 0.70, 0.40, 0.36
cuerpo = agregar('SM_Cofre_Cuerpo',
                 nueva_caja('SM_Cofre_Cuerpo', 0.0, 0.0, H / 2 + 0.06, W, D, H),
                 MAT_madera)

# 4 pies
for sx in (-1, 1):
    for sy in (-1, 1):
        agregar('SM_Cofre_Pie_%s%s' % ('I' if sx < 0 else 'D', 'F' if sy < 0 else 'T'),
                nueva_caja('SM_Cofre_Pie_%s%s' % ('I' if sx < 0 else 'D', 'F' if sy < 0 else 'T'),
                           sx * (W / 2 - 0.04), sy * (D / 2 - 0.04), 0.03,
                           0.08, 0.08, 0.06),
                MAT_madera_osc, padre=cuerpo)

# ---------- 6) Bandas de hierro del cuerpo ----------
# Ojo: una banda que sólo sobresale 0.005 del cuerpo es INVISIBLE en el render.
# Cada banda debe sobresalir >= 0.015 por cara para leerse como hierro.
SALIENTE = 0.030
BANDAS_H_Z = (H * 0.18 + 0.06, H * 0.50 + 0.06, H * 0.82 + 0.06)

for k, z in enumerate(BANDAS_H_Z):
    agregar('SM_Cofre_BandaH_%d' % (k + 1),
            nueva_caja('SM_Cofre_BandaH_%d' % (k + 1), 0.0, 0.0, z,
                       W + SALIENTE, D + SALIENTE, 0.045),
            MAT_hierro, padre=cuerpo)

for sx in (-1, 1):
    agregar('SM_Cofre_BandaV_%s' % ('I' if sx < 0 else 'D'),
            nueva_caja('SM_Cofre_BandaV_%s' % ('I' if sx < 0 else 'D'),
                       sx * (W / 2), 0.0, H / 2 + 0.06,
                       0.045, D + SALIENTE, H * 0.98),
            MAT_hierro, padre=cuerpo)

# Esquinas de hierro
for sx in (-1, 1):
    for sy in (-1, 1):
        agregar('SM_Cofre_Esquina_%s%s' % ('I' if sx < 0 else 'D', 'F' if sy < 0 else 'T'),
                nueva_caja('SM_Cofre_Esquina_%s%s' % ('I' if sx < 0 else 'D', 'F' if sy < 0 else 'T'),
                           sx * (W / 2 - 0.012), sy * (D / 2 - 0.012), H + 0.03,
                           0.06, 0.06, 0.06),
                MAT_hierro, padre=cuerpo)

# ---------- 7) Remaches de bronce (22 en UNA sola malla) ----------
# Los remaches sueltos serian 22 objetos; en una sola malla bmesh es 1.
# Regla §4 del checklist: "mínima cantidad de mallas posible".
bm = bmesh.new()
R_REM = 0.011
# Caras delantera y trasera de las 3 bandas horizontales
for z in BANDAS_H_Z:
    for x in (-0.25, 0.0, 0.25):
        for sy in (-1, 1):
            anadir_caja_a(bm, (x, sy * 0.2205, z), (R_REM * 2, R_REM * 1.3, R_REM * 2))
# Caras exteriores de las 2 bandas verticales
for sx in (-1, 1):
    for z in (0.16, 0.32):
        anadir_caja_a(bm, (sx * 0.3780, 0.0, z), (R_REM * 1.3, R_REM * 2, R_REM * 2))
remaches = agregar('SM_Cofre_Remaches', cerrar_bmesh(bm, 'SM_Cofre_Remaches'),
                   MAT_bronce, padre=cuerpo)

# ---------- 8) Bisagras (2, en la trasera) ----------
for sx in (-1, 1):
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.022, depth=0.06,
                                        location=(sx * 0.22, -(D / 2) - 0.010, H + 0.06))
    o = bpy.context.object
    o.name = 'SM_Cofre_Bisagra_%s' % ('I' if sx < 0 else 'D')
    o.rotation_euler = (0.0, math.radians(90.0), 0.0)   # eje del cilindro -> X
    o.data.materials.append(MAT_hierro)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()
    agregar_padre = o

# ---------- 9) Asas laterales (2 anillos) ----------
for sx in (-1, 1):
    bpy.ops.mesh.primitive_torus_add(major_radius=0.045, minor_radius=0.010,
                                     location=(sx * 0.378, 0.0, H / 2 + 0.06),
                                     rotation=(0.0, math.radians(90.0), 0.0),
                                     major_segments=10, minor_segments=4)
    o = bpy.context.object
    o.name = 'SM_Cofre_Asa_%s' % ('I' if sx < 0 else 'D')
    o.data.materials.append(MAT_oro)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()

# ---------- 10) Tapa arqueada ----------
# Medio cilindro con el EJE EN X (largo W) y el arco en el plano Y-Z.
# La versión anterior ponía el arco a lo largo de X desplazado -W/2, y por eso
# la tapa se veía como una "C" de costado.
Z_TAPA = H + 0.06          # base plana de la tapa = techo del cuerpo
ALTO_TAPA = 0.20
R_TAPA = D / 2             # 0.20 -> el arco es un SEMICIRCULO de radio 0.20
SEG_X = 10                 # divisiones a lo largo de X
LADOS = 13                 # puntos del arco (0..180 grados)

bm = bmesh.new()
rejilla = []
for i in range(SEG_X + 1):
    x = -W / 2 + (i / SEG_X) * W
    fila = []
    for kk in range(LADOS):
        ang = math.pi * kk / (LADOS - 1)
        fila.append(bm.verts.new((x,
                                  R_TAPA * math.cos(ang),
                                  Z_TAPA + ALTO_TAPA * math.sin(ang))))
    rejilla.append(fila)

# cascarón exterior (normal hacia fuera/arriba)
for i in range(SEG_X):
    for kk in range(LADOS - 1):
        bm.faces.new((rejilla[i][kk], rejilla[i][kk + 1],
                      rejilla[i + 1][kk + 1], rejilla[i + 1][kk]))
# fondo plano, normal -Z
for i in range(SEG_X):
    bm.faces.new((rejilla[i][0], rejilla[i + 1][0],
                  rejilla[i + 1][LADOS - 1], rejilla[i][LADOS - 1]))
# casquete del extremo +X
for kk in range(1, LADOS - 1):
    bm.faces.new((rejilla[SEG_X][0], rejilla[SEG_X][kk],
                  rejilla[SEG_X][kk + 1]))
# casquete del extremo -X: winding INVERTIDO (E-16), si no salta
# "faces.new(verts): face already exists" o queda la normal al revés
for kk in range(1, LADOS - 1):
    bm.faces.new((rejilla[0][0], rejilla[0][kk + 1], rejilla[0][kk]))
tapa = agregar('SM_Cofre_Tapa', cerrar_bmesh(bm, 'SM_Cofre_Tapa'), MAT_madera)

# Cantoneras de hierro en las 4 esquinas de la tapa
for sx in (-1, 1):
    for sy in (-1, 1):
        etiqueta = '%s%s' % ('I' if sx < 0 else 'D', 'F' if sy < 0 else 'T')
        agregar('SM_Cofre_TapaEsquina_%s' % etiqueta,
                nueva_caja('SM_Cofre_TapaEsquina_%s' % etiqueta,
                           sx * (W / 2 - 0.025), sy * (D / 2 - 0.020),
                           Z_TAPA + 0.022, 0.05, 0.05, 0.045),
                MAT_hierro, padre=tapa)

# ---------- 11) Costillas anulares de la tapa (3 anillos perpendiculares a X) ----------
# La tapa es un medio cilindro con EJE EN X (largo W). Las costillas son
# anillos que CIÑEN la tapa, perpendiculares a X. Cada anillo es un torus
# con eje en X, posicionado a una x fija, con el mismo radio/alto que la tapa.
N_COST = 3
for k, x in enumerate((-W / 2 + 0.14, 0.0, W / 2 - 0.14)):
    bpy.ops.mesh.primitive_torus_add(major_radius=R_TAPA, minor_radius=0.008,
                                     location=(x, 0.0, Z_TAPA),
                                     rotation=(0.0, math.radians(90.0), 0.0),
                                     major_segments=12, minor_segments=4)
    o = bpy.context.object
    o.name = 'SM_Cofre_Costilla_%d' % (k + 1)
    o.data.materials.append(MAT_bronce)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_flat()
    # Parentar a la tapa para que siga al asentado (E-11/E-18). NO asignar
    # matrix_parent_inverse a mano (E-27 v3): ver doc en agregar().
    bpy.context.view_layer.update()
    o.parent = tapa

# ---------- 12) Glifos en relieve en la cara frontal de la tapa ----------
# Placas planas en el frente de la tapa, no en la curva. Se leen siempre,
# sin importar el angulo de la camara. 3 glifos finos en una sola malla.
bm = bmesh.new()
for x in (-0.16, 0.0, 0.16):
    # placa delgada apoyada sobre la cara delantera de la tapa (y = +R_TAPA)
    # ligeramente embutida en la tapa para no parecer que flota
    anadir_caja_a(bm, (x, R_TAPA + 0.002, Z_TAPA + ALTO_TAPA * 0.55),
                  (0.040, 0.005, 0.040))
agregar('SM_Cofre_Glifos', cerrar_bmesh(bm, 'SM_Cofre_Glifos'),
        MAT_oro, padre=tapa)

# ---------- 13) Cerradura + marco + gema + falleba ----------
# Marco oscuro detras de la placa dorada: da profundidad.
agregar('SM_Cofre_CerraduraMarco',
        nueva_caja('SM_Cofre_CerraduraMarco', 0.0, D / 2 + 0.008, H * 0.55 + 0.06,
                   0.16, 0.030, 0.23),
        MAT_hierro, padre=cuerpo)
# Placa dorada
agregar('SM_Cofre_Cerradura',
        nueva_caja('SM_Cofre_Cerradura', 0.0, D / 2 + 0.015, H * 0.55 + 0.06,
                   0.13, 0.045, 0.20),
        MAT_oro, padre=cuerpo)
# Gema ancestral: el centro brillante. Icoesfera con emision fuerte.
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.028,
                                      location=(0.0, D / 2 + 0.038, H * 0.55 + 0.06))
gema = bpy.context.object
gema.name = 'SM_Cofre_Gema'
gema.data.materials.append(MAT_gema)
bpy.ops.object.select_all(action='DESELECT')
gema.select_set(True)
bpy.context.view_layer.objects.active = gema
bpy.ops.object.shade_flat()

# Falleba dorada en la tapa: placa corta apoyada en el borde delantero.
agregar('SM_Cofre_Falleba',
        nueva_caja('SM_Cofre_Falleba', 0.0, D / 2 - 0.020, Z_TAPA + 0.030,
                   0.11, 0.040, 0.080),
        MAT_oro, padre=tapa)
# Tirador (anillo)
bpy.ops.mesh.primitive_torus_add(major_radius=0.025, minor_radius=0.005,
                                 location=(0.0, D / 2 + 0.055, H * 0.35 + 0.06),
                                 rotation=(math.radians(90), 0, 0),
                                 major_segments=8, minor_segments=4)
tirador = bpy.context.object
tirador.name = 'SM_Cofre_Tirador'
tirador.data.materials.append(MAT_oro)
bpy.ops.object.select_all(action='DESELECT')
tirador.select_set(True)
bpy.context.view_layer.objects.active = tirador
bpy.ops.object.shade_flat()

# ---------- 14) Parentar las piezas sueltas creadas con bpy.ops ----------
# Bisagras, asas, gema y tirador nacen sin padre. Se parentan al cuerpo para que
# acompañen al asentado (E-11/E-18). NO tocar matrix_parent_inverse (E-27 v3).
for nombre in ('SM_Cofre_Bisagra_I', 'SM_Cofre_Bisagra_D',
               'SM_Cofre_Asa_I', 'SM_Cofre_Asa_D',
               'SM_Cofre_Gema', 'SM_Cofre_Tirador'):
    o = escena.objects.get(nombre)
    if o is None:
        continue
    bpy.context.view_layer.update()
    o.parent = cuerpo

# ---------- 15) Asentado (E-12) ----------
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Cofre')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
print('COFRE asento: z_min %.3f -> %.3f (delta %+.3f, piezas=%d)'
      % (z_min, z_fin, delta, len(piezas)))

# NOTA sobre auditoría E-27: el cofre tiene piezas que SOBRESALEN del
# cuerpo por diseño (tirador +5 cm, asas +1.8 cm, bisagras +1.2 cm).
# El AABB-gap geométrico que detectó el bug en helecho_gigante NO
# aplica acá: una métrica que sirviera para cofres tendría que ser
# "el centroide del hijo cae sobre la SUPERFICIE del padre" o algo
# equivalente, no separación AABB. Por eso este script NO agrega un
# assert anti-regresión AABB-gap. El fix E-27 v3 (no tocar
# matrix_parent_inverse) sigue siendo correcto: si alguien lo rompe,
# las costillas del techo y el tirador se van a notar a simple vista
# en el render E-13.

# ---------- 16) Iluminación + mundo (set IDENTICO al resto de los assets) ----------
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

# ---------- 17) Cámara ----------
bpy.ops.object.camera_add(location=(1.2, 1.2, 0.6))
cam = bpy.context.object
cam.name = 'CAM_Cofre'
blanco = Vector((0.0, 0.0, 0.30))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 45
escena.camera = cam

# ---------- 18) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '25-Ruinas-Templos',
                          'cofre_ancestral_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

print('COFRE ANCESTRAL v2 OK — objetos: %d — blend: %s'
      % (len(bpy.data.objects), ruta_blend))
