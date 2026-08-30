# crear_pozo_piedra_lowpoly.py — Pozo de piedra (M40-Infraestructura)
# Checklist: "Pozo de piedra (M40)"
#
# Pozo de aldea: brocal circular de bloques de piedra (3 hiladas trabadas, con
# relieve irregular), dos postes de madera a los costados, techo a dos aguas,
# eje horizontal con manivela, soga y balde colgando sobre la boca.
#
# Todo en UNA sola malla bmesh y UN solo objeto (E-01): minima cantidad de
# draw calls y cero parenting, con lo que E-27 queda fuera de juego por
# construccion.
#
# Lecciones aplicadas:
#   E-01  una sola malla y un solo objeto, no primitivas apiladas
#   E-12  asentado MEDIDO en caliente (no calculado de la altura nominal)
#   E-16  winding invertido en tapas/cierres (superado por E-32 v2)
#   E-21  borrar el .blend@ antes de save_as_mainfile
#   E-23  DECIMATE 0.7 por defecto (0.5 destruye las mallas flat lowpoly)
#   E-32  winding: no deducirlo a mano, MEDIRLO (v2 = volumen con signo)
#   E-33  el presupuesto se mide en triangulos reales, no en caras
#
# ---------------------------------------------------------------------------
# E-32 v2 — el test de orientacion correcto es el VOLUMEN CON SIGNO
# ---------------------------------------------------------------------------
# El test de centroide documentado en la vieira (log 244) solo sirve para
# islas CONVEXAS. Aca hay islas que no lo son (el balde es una revolucion
# concava, el brocal son cajas interpenetradas). El test universal es el
# volumen con signo, por el teorema de la divergencia:
#
#     V = (1/6) * sum_caras sum_k (v0 . (vk x vk+1))
#
# V > 0 -> las normales miran hacia afuera. V < 0 -> la isla esta dada vuelta.
# Solo requiere que la isla sea watertight. Encapsulado en `cerrar_isla()`.
#
# NUEVO en este asset: helper `revolucion()` para superficies de revolucion
# (balde, disco de agua). Si el perfil arranca y termina sobre el eje (r == 0),
# la superficie cierra sola en ambos extremos y queda watertight.
# ---------------------------------------------------------------------------
import bpy
import bmesh
import os
import math
from mathutils import Vector, Euler

# ---------- 1) Limpieza (E-14: NUNCA wm.read_factory_settings por socket) ----------
for _obj in list(bpy.data.objects):
    bpy.data.objects.remove(_obj, do_unlink=True)
for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                bpy.data.cameras, bpy.data.worlds):
    for _dato in list(_bloque):
        if _dato.users == 0:
            _bloque.remove(_dato)
escena = bpy.context.scene

# ---------- 2) Materiales ----------
def crear_mat(nombre, color, rough=0.85, spec=0.20, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Specular IOR Level'].default_value = spec
    bsdf.inputs['Metallic'].default_value = metal
    return m

MAT_piedra = crear_mat('MAT_Piedra_Pozo', (0.55, 0.54, 0.51), rough=0.94)
MAT_madera = crear_mat('MAT_Madera_Pozo', (0.42, 0.29, 0.17), rough=0.88)
MAT_cuerda = crear_mat('MAT_Cuerda_Pozo', (0.74, 0.61, 0.38), rough=0.96)
MAT_agua   = crear_mat('MAT_Agua_Pozo',   (0.20, 0.42, 0.52), rough=0.25, spec=0.60)
MAT_arena  = crear_mat('MAT_Arena_Isla',  (0.92, 0.84, 0.63), rough=1.00)

# slot 0 = piedra | 1 = madera | 2 = cuerda | 3 = agua
I_PIEDRA, I_MADERA, I_CUERDA, I_AGUA = 0, 1, 2, 3

# ---------- 3) Disco de arena ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=1.5, depth=0.24,
                                    location=(0.0, 0.0, -0.06))
base = bpy.context.object
base.name = 'Base_Arena'
base.data.materials.append(MAT_arena)

# ---------- 4) Parametros ----------
# --- brocal ---
R_INT      = 0.340          # radio interior (boca del pozo)
R_EXT      = 0.470          # radio exterior nominal
LIP        = 0.018          # vuelo extra de la hilada superior
N_BLOQ     = 12             # bloques por hilada
N_CURSOS   = 3
H_CURSOS   = (0.26, 0.22, 0.24)   # suma 0.72 = altura del brocal
MORTERO    = 0.94           # factor de ancho tangencial (hueco de junta)

# --- postes ---
X_POSTE    = 0.520          # fuera del brocal (R_EXT = 0.47)
Z_POSTE    = 1.660          # altura de los postes
SEC_POSTE  = 0.045          # semiseccion cuadrada

# --- techo a dos aguas ---
ALERO_Y    = 0.500
ALERO_Z    = 1.660          # coincide con la cabeza del poste
CUMBRERA_Z = 2.000
MEDIO_X_T  = 0.720          # vuelo en X, mas ancho que los postes
GROS_TECH  = 0.017

# --- eje y manivela ---
Z_EJE      = 1.420
R_EJE      = 0.042
LAD_EJE    = 8
X_EJE      = 0.600          # sobresale de los postes (0.52 + 0.045 = 0.565)

# --- soga y balde ---
Z_SOGA_ALTO = 1.378         # cara inferior del eje
Z_SOGA_BAJO = 1.062         # apex del asa del balde
R_SOGA      = 0.011
LAD_SOGA    = 5

Z_BALDE_RIM = 0.950
PERFIL_BALDE = (            # (radio, z) — arranca y termina sobre el eje
    (0.000, Z_BALDE_RIM - 0.165),
    (0.090, Z_BALDE_RIM - 0.165),
    (0.112, Z_BALDE_RIM),
    (0.100, Z_BALDE_RIM),
    (0.000, Z_BALDE_RIM - 0.105),
)
LAD_BALDE = 8

R_ASA      = 0.112          # radio del arco del asa
R_TUBO_ASA = 0.010
LAD_ASA    = 4
N_ASA      = 5              # puntos del semiarco

# --- agua ---
Z_AGUA     = 0.320
ESP_AGUA   = 0.020
R_AGUA     = 0.335          # < R_INT (0.340) para no atravesar el brocal
LAD_AGUA   = 12

# ---------- 5) Helpers de geometria ----------
bm = bmesh.new()

def volumen_firmado(caras):
    """Volumen con signo de una isla CERRADA (teorema de la divergencia).

    > 0 -> las normales miran hacia afuera. < 0 -> esta dada vuelta.
    Vale para CUALQUIER isla cerrada, convexa o no (E-32 v2).
    """
    v = 0.0
    for f in caras:
        co = [vert.co for vert in f.verts]
        for k in range(1, len(co) - 1):
            v += co[0].dot(co[k].cross(co[k + 1]))
    return v / 6.0

def cerrar_isla(caras):
    """Unifica el winding de una isla y la deja mirando hacia afuera.

    Se llama UNA vez por isla. Cada bloque del brocal es su propia isla.
    """
    bmesh.ops.recalc_face_normals(bm, faces=caras)
    if volumen_firmado(caras) < 0.0:
        bmesh.ops.reverse_faces(bm, faces=caras)
    return caras

def caja_vec(centro, ex, ey, ez, mat):
    """Caja con semiejes arbitrarios (sirve para bloques girados y techos
    inclinados). `caja()` es el caso particular alineado a los ejes."""
    v = []
    for sz in (-1, 1):
        for sy in (-1, 1):
            for sx in (-1, 1):
                v.append(bm.verts.new(centro + sx * ex + sy * ey + sz * ez))
    # indice = (sz+1)/2*4 + (sy+1)/2*2 + (sx+1)/2
    caras = [
        bm.faces.new((v[0], v[1], v[3], v[2])),   # -ez
        bm.faces.new((v[4], v[6], v[7], v[5])),   # +ez
        bm.faces.new((v[0], v[4], v[5], v[1])),   # -ey
        bm.faces.new((v[2], v[3], v[7], v[6])),   # +ey
        bm.faces.new((v[0], v[2], v[6], v[4])),   # -ex
        bm.faces.new((v[1], v[5], v[7], v[3])),   # +ex
    ]
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

def caja(cx, cy, cz, sx, sy, sz, mat):
    """Caja alineada a los ejes: (centro, semilados, material)."""
    return caja_vec(Vector((cx, cy, cz)),
                    Vector((sx, 0.0, 0.0)),
                    Vector((0.0, sy, 0.0)),
                    Vector((0.0, 0.0, sz)), mat)

def tubo(centros, radio, lados, mat, radios=None):
    """Barre un poligono de `lados` lados por la polilinea `centros`.

    El marco de cada anillo se arma con la tangente local, asi que sirve
    igual para una soga vertical que para un eje recto. `radios` permite
    variar el radio por anillo (cono / tronco de cono).
    """
    if radios is None:
        radios = [radio] * len(centros)
    anillos = []
    n = len(centros)
    for i in range(n):
        c = Vector(centros[i])
        if n < 2:
            t = Vector((1.0, 0.0, 0.0))
        elif i == 0:
            t = Vector(centros[1]) - c
        elif i == n - 1:
            t = c - Vector(centros[n - 2])
        else:
            t = Vector(centros[i + 1]) - Vector(centros[i - 1])
        if t.length < 1e-9:
            t = Vector((1.0, 0.0, 0.0))
        t.normalize()
        ref = Vector((0.0, 0.0, 1.0)) if abs(t.z) < 0.9 else Vector((1.0, 0.0, 0.0))
        e1 = t.cross(ref).normalized()
        e2 = t.cross(e1).normalized()
        anillo = []
        for k in range(lados):
            a = 2.0 * math.pi * k / lados
            anillo.append(bm.verts.new(c + radios[i] * (math.cos(a) * e1 +
                                                        math.sin(a) * e2)))
        anillos.append(anillo)
    caras = [bm.faces.new(anillos[0]),
             bm.faces.new(list(reversed(anillos[-1])))]
    for i in range(n - 1):
        a0, a1 = anillos[i], anillos[i + 1]
        for k in range(lados):
            k2 = (k + 1) % lados
            caras.append(bm.faces.new((a0[k], a0[k2], a1[k2], a1[k])))
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

def revolucion(perfil, lados, mat):
    """Revoluciona un perfil 2D (radio, z) alrededor del eje Z.

    Si el primer y/o ultimo punto del perfil estan sobre el eje (r == 0), la
    superficie cierra ahi con triangulos. Con ambos extremos sobre el eje el
    resultado es watertight y `cerrar_isla` lo orienta sin ambiguedad.
    Es el caso del balde y del disco de agua.
    """
    anillos = []
    for (r, z) in perfil:
        anillo = []
        for k in range(lados):
            a = 2.0 * math.pi * k / lados
            anillo.append(bm.verts.new((r * math.cos(a), r * math.sin(a), z)))
        anillos.append(anillo)
    caras = []
    for j in range(len(anillos) - 1):
        a0, a1 = anillos[j], anillos[j + 1]
        r0, r1 = perfil[j][0], perfil[j + 1][0]
        for k in range(lados):
            k2 = (k + 1) % lados
            if r0 < 1e-9:            # a0 degenera en el eje -> triangulo
                caras.append(bm.faces.new((a0[k], a1[k], a1[k2])))
            elif r1 < 1e-9:          # a1 degenera en el eje -> triangulo
                caras.append(bm.faces.new((a0[k], a0[k2], a1[k])))
            else:
                caras.append(bm.faces.new((a0[k], a0[k2], a1[k2], a1[k])))
    for f in caras:
        f.material_index = mat
    return cerrar_isla(caras)

# ---------- 6) Brocal: anillo de bloques de piedra ----------
# Cada bloque es una caja orientada: eje radial `er`, tangencial `et`, vertical.
# El relieve se aplica sobre la cara EXTERIOR solamente (variando el radio
# exterior del bloque), de modo que la pared interior queda un cilindro limpio
# y la exterior queda rustica.
def radio_ext_bloque(i, c):
    """Radio exterior del bloque `i` de la hilada `c`. Determinista: misma
    entrada, mismo resultado en cada ejecucion."""
    v = 0.011 * math.sin(i * 2.7 + c * 1.9) + 0.007 * math.cos(i * 5.1 - c * 0.7)
    return R_EXT + v + (LIP if c == N_CURSOS - 1 else 0.0)

z_cursor = 0.0
for c in range(N_CURSOS):
    h = H_CURSOS[c]
    zc = z_cursor + h / 2.0
    for i in range(N_BLOQ):
        # trabado: las hiladas impares rotan medio bloque
        ang = (i + 0.5 * (c % 2)) * 2.0 * math.pi / N_BLOQ
        er = Vector((math.cos(ang), math.sin(ang), 0.0))
        et = Vector((-math.sin(ang), math.cos(ang), 0.0))
        r_ext = radio_ext_bloque(i, c)
        r_mid = (R_INT + r_ext) / 2.0
        hr = (r_ext - R_INT) / 2.0                  # semiprofundidad radial
        ht = (math.pi * r_mid / N_BLOQ) * MORTERO   # semiancho tangencial
        hv = h / 2.0
        caja_vec(er * r_mid + Vector((0.0, 0.0, zc)),
                 er * hr, et * ht, Vector((0.0, 0.0, hv)),
                 I_PIEDRA)
    z_cursor += h

# ---------- 7) Agua al fondo ----------
revolucion(((0.000, Z_AGUA),
            (R_AGUA, Z_AGUA),
            (R_AGUA, Z_AGUA + ESP_AGUA),
            (0.000, Z_AGUA + ESP_AGUA)), LAD_AGUA, I_AGUA)

# ---------- 8) Postes de madera (2) ----------
for sx in (-1, +1):
    caja(sx * X_POSTE, 0.0, Z_POSTE / 2.0,
         SEC_POSTE, SEC_POSTE, Z_POSTE / 2.0, I_MADERA)

# ---------- 9) Techo a dos aguas ----------
# OJO con un error clasico: NO se puede tomar un unico vector de pendiente y
# "espejarlo" invirtiendo solo la componente Y (`ey.y *= -1`). Eso no es
# negar el vector (que dejaria la caja invariante, porque la caja es
# {c +- ex +- ey +- ez}), sino REFLEJARLO, y la reflexion SI cambia el
# solido: invierte la pendiente y deja el alero arriba de la cumbrera.
#
# Cada faldon se arma explicito desde su propio alero hacia la cumbrera:
#   centro            = punto medio del alero -> cumbrera
#   ey (semipendiente)= mitad de (alero -> cumbrera); en Y va HACIA el centro
#   ez (semiespesor)  = perpendicular a ey en el plano YZ, hacia arriba/afuera
# Se verifica en caliente que ey . ez == 0 y que centro +- ey caen sobre la
# cumbrera y el alero (ver asserts debajo del bucle).
DESNIVEL = CUMBRERA_Z - ALERO_Z          # 0.34

for sy in (-1, +1):
    centro = Vector((0.0, sy * ALERO_Y / 2.0, (ALERO_Z + CUMBRERA_Z) / 2.0))
    ex = Vector((MEDIO_X_T, 0.0, 0.0))
    # del alero (y = sy*ALERO_Y, z = ALERO_Z) a la cumbrera (y = 0, z = CUMBRERA_Z)
    ey = Vector((0.0, -sy * ALERO_Y, DESNIVEL)) / 2.0
    # perpendicular a ey en el plano YZ, apuntando arriba y hacia el exterior
    ez = Vector((0.0, sy * DESNIVEL, ALERO_Y)).normalized() * GROS_TECH
    caja_vec(centro, ex, ey, ez, I_MADERA)

# Comprobacion en caliente para UN faldon (sy = +1, el mismo calculo del bucle).
#
# TOLERANCIA 1e-4, no 1e-9: `mathutils.Vector` guarda sus componentes en
# float32, asi que el error de redondeo sobre una coordenada de ~1.7 m es del
# orden de 2e-7. Con 1e-9 el assert falla SIEMPRE por puro ruido numerico
# (medido: dz = 2.2e-16 en float64 puro, ~2e-7 dentro de Blender).
# 1e-4 son 0.1 mm a esta escala: mas que suficiente para geometria de asset.
TOL = 1e-4

_centro = Vector((0.0, +ALERO_Y / 2.0, (ALERO_Z + CUMBRERA_Z) / 2.0))
_ey = Vector((0.0, -ALERO_Y, DESNIVEL)) / 2.0          # -sy * ALERO_Y, con sy = +1
_ez = Vector((0.0, +DESNIVEL, ALERO_Y)).normalized()   #  sy * DESNIVEL, con sy = +1
assert abs(_ey.dot(_ez)) < TOL, \
    'TECHO: ey y ez no son perpendiculares (dot = %.6f)' % _ey.dot(_ez)
_p_ridge = _centro + _ey      # hacia arriba y hacia el centro -> cumbrera
_p_eave = _centro - _ey       # hacia abajo y hacia afuera    -> alero
assert abs(_p_ridge.y) < TOL and abs(_p_ridge.z - CUMBRERA_Z) < TOL, \
    'TECHO: centro + ey no cae en la cumbrera %s' % (_p_ridge,)
assert abs(_p_eave.y - ALERO_Y) < TOL and abs(_p_eave.z - ALERO_Z) < TOL, \
    'TECHO: centro - ey no cae en el alero %s' % (_p_eave,)
print('TECHO ok: pendiente %.4f m, perpendicularidad |ey.ez| = %.2e'
      % (_ey.length * 2.0, abs(_ey.dot(_ez))))

# Caballete que tapa la junta de la cumbrera.
caja(0.0, 0.0, CUMBRERA_Z + 0.008, MEDIO_X_T + 0.025, 0.030, 0.028, I_MADERA)

# ---------- 10) Eje horizontal ----------
tubo([(-X_EJE, 0.0, Z_EJE), (X_EJE, 0.0, Z_EJE)], R_EJE, LAD_EJE, I_MADERA)

# ---------- 11) Manivela (L: brazo radial + mango paralelo al eje) ----------
X_BRAZO = X_EJE + 0.032
Z_MANGO = Z_EJE + 0.140
caja(X_BRAZO, 0.0, (Z_EJE + Z_MANGO) / 2.0,
     0.028, 0.020, (Z_MANGO - Z_EJE) / 2.0, I_MADERA)          # brazo
caja(X_BRAZO + 0.070, 0.0, Z_MANGO, 0.070, 0.017, 0.017, I_MADERA)  # mango

# ---------- 12) Soga ----------
tubo([(0.0, 0.0, Z_SOGA_ALTO), (0.0, 0.0, Z_SOGA_BAJO)], R_SOGA, LAD_SOGA, I_CUERDA)

# ---------- 13) Balde ----------
revolucion(PERFIL_BALDE, LAD_BALDE, I_MADERA)

# Asa: semiarco en el plano YZ, desde un borde del balde hasta el otro.
centros_asa = []
for k in range(N_ASA):
    a = math.pi * k / (N_ASA - 1)              # 180 grados -> 0 grados
    centros_asa.append((0.0, -R_ASA * math.cos(a), Z_BALDE_RIM + R_ASA * math.sin(a)))
tubo(centros_asa, R_TUBO_ASA, LAD_ASA, I_MADERA)

# ---------- 14) Cerrar y crear el objeto ----------
bm.normal_update()
n_tris = sum(len(f.verts) - 2 for f in bm.faces)
me = bpy.data.meshes.new('SM_Pozo_Piedra')
bm.to_mesh(me)
bm.free()

pozo = bpy.data.objects.new('SM_Pozo_Piedra', me)
escena.collection.objects.link(pozo)
pozo.data.materials.append(MAT_piedra)   # slot 0
pozo.data.materials.append(MAT_madera)   # slot 1
pozo.data.materials.append(MAT_cuerda)   # slot 2
pozo.data.materials.append(MAT_agua)     # slot 3

bpy.ops.object.select_all(action='DESELECT')
pozo.select_set(True)
bpy.context.view_layer.objects.active = pozo
bpy.ops.object.shade_flat()

# ---------- 15) Asentado (E-12) — medido en caliente ----------
# Lo mas bajo son las bases de los postes y la hilada inferior del brocal.
# Se mide el z_min real y se traslada hasta Z_APOYO (enterrado en la arena).
Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects
          if o.type == 'MESH' and o.name.startswith('SM_Pozo')]
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:      # solo la raiz; los hijos la siguen solos
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
print('POZO asentado: z_min %.4f -> %.4f (delta %+.4f, piezas=%d)'
      % (z_min, z_fin, delta, len(piezas)))

# ---------- 16) Iluminacion + mundo (set IDENTICO al resto de los assets) ----------
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

# ---------- 17) Camara ----------
# El pozo mide ~2.04 m de alto (el puente era mas bajo y alcanzaba con 45 mm
# a 2.1 m). Aca uso 40 mm y me corro un poco mas para que entre completo.
bpy.ops.object.camera_add(location=(2.00, -2.00, 1.35))
cam = bpy.context.object
cam.name = 'CAM_Pozo'
blanco = Vector((0.0, 0.0, 0.85))
cam.rotation_euler = (blanco - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam.data.lens = 40
escena.camera = cam

# ---------- 18) Guardar .blend ----------
RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
ruta_blend = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '40-Infraestructura',
                          'pozo_piedra_lowpoly.blend')
os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
# E-21: si quedo un .blend@ de un crash, save_as_mainfile falla.
if os.path.exists(ruta_blend + '@'):
    os.remove(ruta_blend + '@')
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

n_obj = len([o for o in escena.objects if o.name.startswith('SM_')])
print('POZO PIEDRA OK — objetos SM_: %d — tris: %d — materiales: %d — blend: %s'
      % (n_obj, n_tris, len(pozo.data.materials), ruta_blend))
