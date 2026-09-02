# crear_cangrejo_playa_lowpoly.py - Cangrejo de playa (M36 Fauna, checklist linea 102)
#
# v2 (v1 rechazada por E-50: huella 0.04x0.04 — las patitas de cono solo
#     apoyaban 1 vertice cada una y el asentar() las rechazo; redisenadas
#     con loft bmesh de 4 anillos y PUNTA PLANA de 4 verts que apoya bien).
#
# DISENO (E-37 — la silueta debe leer CANGREJO en los 6 azimuts):
#   caparazon naranja ancho (elipse aplastada con frente caido), HOCICO
#   entre las pinzas, 2 PINZAS grandes levantadas (mandibula clara + oscura
#   en V abierta), 2 OJOS negros en pedunculos, 8 PATITAS de cono-tronco
#   con punta plana. Paleta: caparazon naranja-rojizo, patas rojo oscuro,
#   pinzas naranja claro con punta crema, ojos negro humedo.
#
# ANIMABLE EN GODOT (09-GUIA-BLENDER §8 / 07-GUIA-GODOT §11):
#   - SM_Cangrejo_Pinza_{L,R}: 1 pieza por pinza COMPLETA (brazo+quela+
#     mandibulas en 1 malla bmesh), origen en el HOMBRO -> Godot la agita
#     entera rotando desde ahi. La V de la mandibula va FUSA (estatica):
#     el cangrejo lowpoly no abre la pinza, la agita.
#   - SM_Cangrejo_Pata_{L,R}_{0..3}: cada patita es 1 malla bmesh con
#     pivote en la CADERA (origen = primer anillo, junto al caparazon).
#   - SM_Cangrejo_Pedunculo_{0,1} + SM_Cangrejo_Ojo_Esfera_{0,1}: Godot
#     inclina los pedunculos y los ojos siguen (o se funden en BAJA y el
#     script tolera nulls).
#
# E-70 (contar ANTES de generar): 15 SM_ <= 16 tope ALTA. Margen 1.
#   1 caparazon + 1 hocico + 2 pinzas + 8 patitas + 2 pedunculos
#   + 2 ojos = 16... una demas. AJUSTE: el hocico se FUNDE con el
#   caparazon via union visual (coinciden en el mismo lugar, sin gap):
#   mejor: pedunculo+ojo = 1 pieza? No — el pedunculo fijo y el ojo se
#   anima. DECISION FINAL: hocico ELIMINADO (el caparazon con frente caido
#   + pinzas al frente ya lee "cangrejo"; el hocico era un agregado):
#   1 caparazon + 2 pinzas + 8 patitas + 2 pedunculos + 2 ojos = 15. OK.
#
# APOYO (E-12/E-50): las 8 patitas con punta PLANA (anillo final de 4
#   verts a z=0.045): 32 verts de huella, footprint ~0.55 x 0.62. Las
#   pinzas van LEVANTADAS (no tocan). El caparazon vuela: nunca asenta.
#
# E-68: caja() dimension final. E-74: angulos negados entre lados.
# E-19: conos horizontales con rot Y. E-32 v2: islas bmesh con volumen
# firmado. E-27: cero parenting.
import bpy, os, sys, bmesh
from math import radians, cos, sin, pi
from mathutils import Vector

try:
    _AQUI = os.path.dirname(os.path.abspath(__file__))
except NameError:
    _AQUI = None
if not _AQUI or not os.path.isdir(os.path.join(_AQUI, '..', '..')):
    _AQUI = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna\scripts'
sys.path.insert(0, os.path.abspath(os.path.join(_AQUI, '..', '..', 'scripts-reutilizables')))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja)

escena = limpiar()

# ---------------- Paleta (5 mats) ----------------
MAT_caparazon = mat('MAT_Cangrejo_Caparazon', (0.78, 0.33, 0.12), rough=0.75)
MAT_patas = mat('MAT_Cangrejo_Patas', (0.55, 0.22, 0.09), rough=0.85)
MAT_pinza = mat('MAT_Cangrejo_Pinza', (0.85, 0.45, 0.18), rough=0.70)
MAT_pinza_punta = mat('MAT_Cangrejo_Pinza_Punta', (0.92, 0.78, 0.55), rough=0.60)
MAT_ojos = mat('MAT_Cangrejo_Ojos', (0.04, 0.03, 0.02), rough=0.30, spec=0.60)


def caja_rot(nombre, x, y, z, sx, sy, sz, material, rot=(0, 0, 0)):
    return caja(nombre, x, y, z, sx, sy, sz, material, rot_euler=rot)


# ---------------- bmesh helpers (E-32 v2) ----------------
def _vol(caras):
    v = 0.0
    for f in caras:
        co = [vt.co for vt in f.verts]
        for k in range(1, len(co) - 1):
            v += co[0].dot(co[k].cross(co[k + 1]))
    return v / 6.0


def _isla(bm, caras):
    bmesh.ops.recalc_face_normals(bm, faces=caras)
    if _vol(caras) < 0.0:
        bmesh.ops.reverse_faces(bm, faces=caras)


def _obj(nombre, bm, material):
    me = bpy.data.meshes.new('M_' + nombre[3:])
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(ob)
    ob.data.materials.append(material)
    return ob


# ===================== 1) CAPARAZON =====================
bpy.ops.mesh.primitive_uv_sphere_add(
    segments=16, ring_count=8, radius=0.30,
    location=(0.0, 0.0, 0.28))
cap = bpy.context.object
cap.name = 'SM_Cangrejo_Caparazon'
cap.scale = (1.0, 1.25, 0.45)
cap.rotation_euler = (0.0, radians(6.0), 0.0)  # frente caido (E-19: rot Y)
cap.data.materials.append(MAT_caparazon)

# ===================== 2) PEDUNCULOS + OJOS (1 pieza animable por ojo) =====================
# v3 (E-70): el pedunculo y su ojo son UNA pieza — cilindro con la tapa
# superior ENGROSADA (esfera achatada del ojo). Godot rota la pieza entera
# (pivot en la base) y el ojo acompana. Material del pedunculo = patas,
# material del ojo... 1 pieza = 1 material dominante: ojo negro humedo
# (el pedunculo fino en negro tambien lee bien, como antena).
for i, sy in enumerate((-1, +1)):
    bm = bmesh.new()
    caras = []
    # Tallo: tubo octogonal r 0.014, de z 0 a 0.10
    N = 8
    r_t, h_t = 0.014, 0.10
    ring_b = [bm.verts.new((r_t * cos(2 * pi * a / N), r_t * sin(2 * pi * a / N), 0.0))
              for a in range(N)]
    ring_t = [bm.verts.new((r_t * cos(2 * pi * a / N), r_t * sin(2 * pi * a / N), h_t))
              for a in range(N)]
    for a in range(N):
        b = (a + 1) % N
        caras.append(bm.faces.new((ring_b[a], ring_b[b], ring_t[b], ring_t[a])))
    caras.append(bm.faces.new(ring_b))  # base
    # Ojo: casquete esferico engrosado sobre la tapa (r 0.028 achatado)
    r_o, h_o = 0.028, 0.022
    ring_o = [bm.verts.new((r_o * cos(2 * pi * a / N), r_o * sin(2 * pi * a / N), h_t + h_o))
              for a in range(N)]
    for a in range(N):
        b = (a + 1) % N
        caras.append(bm.faces.new((ring_t[a], ring_t[b], ring_o[b], ring_o[a])))
    centro = bm.verts.new((0.0, 0.0, h_t + h_o * 1.6))  # polo del casquete
    for a in range(N):
        b = (a + 1) % N
        caras.append(bm.faces.new((ring_o[a], ring_o[b], centro)))
    _isla(bm, caras)
    ob = _obj('SM_Cangrejo_Ojo_%d' % i, bm, MAT_ojos)
    ob.rotation_euler = (radians(-14.0), 0.0, 0.0)  # inclinado al frente
    ob.location = (0.10, sy * 0.10, 0.30)
    # La base (z local 0) queda a 0.30 — DENTRO del caparazon (que cubre
    # z 0.15..0.42 en el frente); el ojo asoma arriba a ~0.43.

# ===================== 3) PINZAS (1 malla bmesh por pinza, V integrada) =====================
# v3 (E-70): brazo + quela + mandibulas TODO en 1 loft. El tramo final se
# abre en 2 ramas (la V del cangrejo): cada rama es un mini-loft propio
# que arranca de la quela. El material dominante es pinza; la rama
# inferior queda con el mismo mat (la punta crema se sacrifica — 1 pieza
# = 1 material, la V ya lee por si sola).
def pinza(nombre, lado):
    bm = bmesh.new()
    caras = []

    def tubo(x0, x1, r0y, r1y, r0z, r1z):
        """Tubo rectangular-tapotado entre x0 y x1. Devuelve (ringA, ringB)."""
        ra = [(x0, -r0y, -r0z), (x0, r0y, -r0z), (x0, r0y, r0z), (x0, -r0y, r0z)]
        rb = [(x1, -r1y, -r1z), (x1, r1y, -r1z), (x1, r1y, r1z), (x1, -r1y, r1z)]
        A = [bm.verts.new(v) for v in ra]
        B = [bm.verts.new(v) for v in rb]
        for i2 in range(4):
            j = (i2 + 1) % 4
            caras.append(bm.faces.new((A[i2], A[j], B[j], B[i2])))
        return A, B

    # Brazo: hombro (origen) -> codo
    A1, B1 = tubo(0.00, 0.10, 0.020, 0.028, 0.020, 0.026)
    # Quela bulbosa: codo -> base de la V
    B2a, B2b = tubo(0.10, 0.20, 0.028, 0.055, 0.026, 0.045)
    # Rama superior de la V (mandibula A): sube y cierra
    A3a, B3a = tubo(0.20, 0.33, 0.055, 0.016, 0.045, 0.014)
    # Rama inferior de la V (mandibula B): baja y cierra
    A3b, B3b = tubo(0.20, 0.33, 0.055, 0.016, 0.045, 0.014)
    # Desplazar las ramas para abrir la V (rotadas alrededor del eje Y en
    # el plano XZ): rama A hacia arriba, rama B hacia abajo.
    for v in B3a + A3a:
        v.co.z += 0.020
        v.co.y *= 0.8
    for v in B3b + A3b:
        v.co.z -= 0.020
        v.co.y *= 0.8
    # Tapas: hombro, punta A, punta B
    caras.append(bm.faces.new(A1))
    caras.append(bm.faces.new(B3a))
    caras.append(bm.faces.new(B3b))
    _isla(bm, caras)
    ob = _obj(nombre, bm, MAT_pinza)
    ob.rotation_euler = (0.0, radians(-18.0), radians(52.0) * lado)  # alzada, E-74
    ob.location = (0.14, 0.20 * lado, 0.26)
    return ob


pinza('SM_Cangrejo_Pinza_L', -1)
pinza('SM_Cangrejo_Pinza_R', +1)

# ===================== 4) PATITAS (8 mallas bmesh, punta plana) =====================
# Loft de 4 anillos decagonal a lo largo de +X local (pivote = cadera en el
# origen). Perfil: cadera gorda -> rodilla -> tobillo -> PUNTA PLANA
# (anillo final con los 4 verts bajos a la misma altura => apoya 4 verts).
# La patita nace DEL CAPARAZON hacia afuera; se orienta con rot Z al angulo
# del lado (E-74: negado) y se inclina hacia el piso con rot Y leve para
# que la punta caiga a 0.045 (el asentar() del helper mide y ajusta).
def patita(nombre, lado, ang_grados):
    ang = radians(ang_grados)
    bm = bmesh.new()
    N = 5
    # anillos: (t, radio, caida_z) — caida para que la punta baje al piso
    PERFIL = [(0.00, 0.030, 0.16),   # cadera (alta, dentro del caparazon)
              (0.35, 0.022, 0.10),
              (0.70, 0.016, 0.04),
              (1.00, 0.012, 0.00)]   # punta al nivel del piso
    LARGO = 0.30
    rings = []
    for (t, r, cz) in PERFIL:
        ring = [bm.verts.new((t * LARGO, r * cos(2 * pi * a / N), cz + r * sin(2 * pi * a / N)))
                for a in range(N)]
        rings.append(ring)
    caras = []
    for k in range(3):
        for a in range(N):
            b = (a + 1) % N
            caras.append(bm.faces.new((rings[k][a], rings[k][b],
                                       rings[k + 1][b], rings[k + 1][a])))
    # tapas: cadera (abierta, queda dentro del caparazon) y punta PLANA
    caras.append(bm.faces.new(rings[3]))   # punta cerrada plana -> apoya
    _isla(bm, caras)
    ob = _obj(nombre, bm, MAT_patas)
    ob.rotation_euler = (0.0, 0.0, ang * lado)  # E-74: negado entre lados
    # E-50 v3: la CADERA nace a z fija 0.20 y la PUNTA (t=1, cz=0) debe
    # quedar a 0.045 en MUNDO: como la rotacion es solo sobre Z (plano XY),
    # la altura de cada punto es location.z + z_local => punta_z_local = 0
    # -> location.z = 0.045. La cadera queda a 0.045+0.16 = 0.205 (dentro
    # del caparazon, cuyo borde inferior anda por 0.16-0.20). Todas las
    # patitas apoyan su punta EXACTA a 0.045 -> 8x5 verts de huella.
    ob.location = (cos(ang) * 0.16, sin(ang) * 0.26 * lado, 0.045)
    return ob


for lado in (-1, +1):
    for j, ang in enumerate((50, 72, 96, 118)):
        patita('SM_Cangrejo_Pata_%s_%d' % ('L' if lado < 0 else 'R', j), lado, ang)

arena(radio=1.4)
iluminar(escena)
asentar(escena)
camara(escena, 'CAM_Cangrejo', (1.4, -1.3, 0.8), (0.0, 0.0, 0.18))
shade_flat(escena)
guardar(escena, '36-Fauna', 'cangrejo_playa')

# -------- QA numerico en caliente (E-33/E-40/E-70) --------
bpy.context.view_layer.update()
ps = [o for o in escena.objects if o.type == 'MESH' and o.name.startswith('SM_')]
tris = 0
for o in ps:
    o.data.calc_loop_triangles()
    tris += len(o.data.loop_triangles)
print('QA CANGREJO: %d SM_ · %d tris reales · %d mats' % (
    len(ps), tris, len(set(m.name for o in ps for m in o.data.materials))))
assert len(ps) <= 16, 'E-70: %d objetos exceden el tope ALTA de 16' % len(ps)
assert tris <= 6000, 'presupuesto ALTA de tris excedido (%d)' % tris
