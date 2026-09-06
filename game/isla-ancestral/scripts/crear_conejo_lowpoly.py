# crear_conejo_lowpoly.py — Conejo (M36 Fauna)
# Metodología Hy4: bmesh lofting con anillos YZ variando X (como crear_jabali_lowpoly.py)
# Importa plantilla_asset.py para todos los helpers probados.
# Altura objetivo: 0.35m (tabla 2.5 de 09-GUIA-BLENDER).
# Referencia: personaje 1.8m, arbol_frutal 6m (aprobado por usuario).
import bpy, os, sys, bmesh, math
from math import radians, cos, sin, pi

RAIZ_FAUNA = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna"
sys.path.insert(0, os.path.join(RAIZ_FAUNA, '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar,
                             camara, shade_flat, guardar, RAIZ)

escena = limpiar()

# ── Paleta ──
MAT_pello = mat('MAT_Conejo_Pello', (0.55, 0.38, 0.24), rough=0.95)
MAT_crema = mat('MAT_Conejo_Crema', (0.92, 0.88, 0.80), rough=0.90)
MAT_ojos = mat('MAT_Conejo_Ojos', (0.03, 0.03, 0.03), rough=0.30, spec=0.60)
MAT_brillo = mat('MAT_Conejo_Brillo', (0.98, 0.98, 0.98))
MAT_nariz = mat('MAT_Conejo_Nariz', (0.85, 0.55, 0.55))
MAT_patas = mat('MAT_Conejo_Patas', (0.50, 0.35, 0.22), rough=0.95)


# ── bmesh helpers (E-32 v2: volumen firmado, E-01: una malla) ──
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

def loft(nombre, anillos, material):
    bm = bmesh.new()
    rings = [[bm.verts.new(v) for v in ring] for ring in anillos]
    N = len(rings[0])
    caras = []
    for k in range(len(rings) - 1):
        for a in range(N):
            b = (a + 1) % N
            caras.append(bm.faces.new((rings[k][a], rings[k][b],
                                       rings[k + 1][b], rings[k + 1][a])))
    for a in range(1, N - 1):
        caras.append(bm.faces.new((rings[0][0], rings[0][a], rings[0][a + 1])))
        caras.append(bm.faces.new((rings[-1][0], rings[-1][a + 1], rings[-1][a])))
    _isla(bm, caras)
    return _obj(nombre, bm, material)

def anillo_yz(cx, cz, ry, rz, N=8):
    """Anillo elíptico en plano YZ (perpendicular al eje X del cuerpo)."""
    return [(cx, ry * cos(2 * pi * a / N), cz + rz * sin(2 * pi * a / N))
            for a in range(N)]

def cubo(nombre, sx, sy, sz, x, y, z, material):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
    o = bpy.context.active_object
    o.name = nombre
    o.scale = (sx, sy, sz)
    bpy.ops.object.transform_apply(scale=True)
    o.data.materials.append(material)
    return o


# ═══════════ 1) CUERPO (loft YZ variando X: grupa→espalda→pecho→cuello) ═══════════
# El conejo se extiende a lo largo de X (grupa atrás x=-0.11, cabeza adelante x=+0.10)
# La silueta: grupa redondeada, espalda con leve hundimiento, pecho más ancho
AN_CUERPO = [
    anillo_yz(-0.11, 0.14, 0.030, 0.030),   # punta trasera (grupa)
    anillo_yz(-0.09, 0.14, 0.065, 0.060),   # grupa máxima
    anillo_yz(-0.05, 0.14, 0.080, 0.070),   # espalda (vientre cae)
    anillo_yz(0.00, 0.14, 0.085, 0.075),    # centro (más ancho)
    anillo_yz(0.05, 0.14, 0.080, 0.075),    # pecho
    anillo_yz(0.09, 0.14, 0.060, 0.060),    # cuello (contracción)
]
loft('SM_Conejo_Cuerpo', AN_CUERPO, MAT_pello)

# Vientre crema (misma técnica, radios más chicos, desplazado abajo)
AN_VIENTRE = [
    anillo_yz(-0.08, 0.11, 0.055, 0.050),
    anillo_yz(-0.04, 0.11, 0.070, 0.060),
    anillo_yz(0.02, 0.11, 0.070, 0.065),
    anillo_yz(0.06, 0.11, 0.055, 0.055),
]
loft('SM_Conejo_Vientre', AN_VIENTRE, MAT_crema)

# ═══════════ 2) CABEZA (loft YZ: esfera alargada hacia adelante) ═══════════
# La cabeza está en x=+0.12 a +0.22 (delante del cuello x=0.09)
AN_CABEZA = [
    anillo_yz(0.10, 0.18, 0.040, 0.040),   # nuca (se hunde en cuello)
    anillo_yz(0.14, 0.18, 0.065, 0.065),   # cráneo
    anillo_yz(0.18, 0.18, 0.075, 0.072),   # frente
    anillo_yz(0.22, 0.18, 0.065, 0.062),   # cara
    anillo_yz(0.25, 0.175, 0.045, 0.045),  # hocico base
]
loft('SM_Conejo_Cabeza', AN_CABEZA, MAT_pello)

# Hocico crema (pequeño cubo al frente de la cabeza)
cubo_hocico = cubo('SM_Conejo_Hocico', 0.06, 0.05, 0.05,
                   0.28, 0.175, 0.16, MAT_crema)

# Nariz rosa
cubo_nariz = cubo('SM_Conejo_Nariz', 0.025, 0.015, 0.02,
                  0.30, 0.175, 0.165, MAT_nariz)

# ═══════════ 3) OREJAS (cubos planos, conectadas a la cabeza) ═══════════
# cabeza top ≈ 0.26; orejas de 0.24 a 0.44 (conectadas a la cabeza)
oreja_i = cubo('SM_Conejo_Oreja_I', 0.03, 0.02, 0.20,
               -0.03, -0.20, 0.34, MAT_pello)
oreja_d = cubo('SM_Conejo_Oreja_D', 0.03, 0.02, 0.20,
               0.03, -0.20, 0.34, MAT_pello)
oreja_i_int = cubo('SM_Conejo_Oreja_I_Int', 0.015, 0.010, 0.15,
                   -0.03, -0.202, 0.34, MAT_crema)
oreja_d_int = cubo('SM_Conejo_Oreja_D_Int', 0.015, 0.010, 0.15,
                   0.03, -0.202, 0.34, MAT_crema)

# ═══════════ 4) OJOS (esferas + brillito, en lados de la cabeza) ═══════════
for lado in [-1, 1]:
    l = 'I' if lado < 0 else 'D'
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.014,
        location=(lado * 0.058, -0.26, 0.20), segments=8, ring_count=6)
    ojo = bpy.context.active_object
    ojo.name = f'SM_Conejo_Ojo_{l}'
    ojo.scale = (0.6, 1.0, 1.0)
    bpy.ops.object.transform_apply(scale=True)
    ojo.data.materials.append(MAT_ojos)
    bpy.ops.object.shade_smooth()
    # brillito: esfera blanca pequeña, pegada arriba-adelante del ojo
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.005,
        location=(lado * 0.052, -0.268, 0.212), segments=6, ring_count=4)
    brillo = bpy.context.active_object
    brillo.name = f'SM_Conejo_Brillo_{l}'
    brillo.data.materials.append(MAT_brillo)
    bpy.ops.object.shade_smooth()

# ═══════════ 5) PATAS (4 lofted cilíndricas + pies traseros losas) ═══════════
for lado in [-1, 1]:
    l = 'I' if lado < 0 else 'D'
    # delanteras
    AN_PD = [
        anillo_yz(lado * 0.050, 0.038, 0.020, 0.020),
        anillo_yz(lado * 0.050, 0.025, 0.018, 0.018),
        anillo_yz(lado * 0.050, 0.012, 0.014, 0.014),
    ]
    loft(f'SM_Conejo_Pata_D_{l}', AN_PD, MAT_patas)
    # traseras (más grandes — zanca del conejo)
    AN_PT = [
        anillo_yz(lado * 0.075, 0.038, 0.028, 0.028),
        anillo_yz(lado * 0.075, 0.025, 0.024, 0.024),
        anillo_yz(lado * 0.075, 0.012, 0.018, 0.018),
    ]
    loft(f'SM_Conejo_Pata_T_{l}', AN_PT, MAT_patas)
    # pies traseros (losas horizontales, tocando el suelo)
    cubo(f'SM_Conejo_Pie_T_{l}', 0.045, 0.13, 0.03,
         lado * 0.075, -0.04, 0.015, MAT_patas)

# ═══════════ 6) COLA (esfera crema) ═══════════
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.035, location=(-0.13, 0.14, 0.15),
                                     segments=10, ring_count=8)
cola = bpy.context.active_object
cola.name = 'SM_Conejo_Cola'
cola.data.materials.append(MAT_crema)
bpy.ops.object.shade_smooth()

# ═══════════ ARENA + ILUMINAR + ASENTAR (orden canónico plantilla) ═══════════
arena(radio=1.0)
iluminar(escena)
# Asentado manual (E-24: vertices reales, sin guard estricto)
bpy.context.view_layer.update()
_ps = [o for o in escena.objects if o.type == 'MESH' and o.name.startswith('SM_')]
_z_ini = min((o.matrix_world @ v.co).z for o in _ps for v in o.data.vertices)
_d = 0.045 - _z_ini
for _o in _ps:
    _o.location.z += _d
bpy.context.view_layer.update()
print('ASENTADO: z_min %.4f -> 0.0450 (delta %+.4f)' % (_z_ini, _d))
camara(escena, 'CAM_Conejo', loc=(0.75, -0.95, 0.55), mira=(0.05, 0, 0.2))
shade_flat(escena)
# re-smooth los esféricos
for ob in escena.objects:
    if ob.type == 'MESH' and any(k in ob.name for k in
            ['Ojo', 'Brillo', 'Cola', 'Cuerpo', 'Cabeza', 'Vientre', 'Pata']):
        bpy.ops.object.select_all(action='DESELECT')
        ob.select_set(True)
        bpy.context.view_layer.objects.active = ob
        bpy.ops.object.shade_smooth()

# ═══════════ Render orbital 7 vistas (E-13: capturar_angulos_headless) ═══════════
sc = escena
sc.render.engine = 'CYCLES'
sc.cycles.device = 'CPU'
sc.cycles.samples = 32
sc.render.resolution_x = 640
sc.render.resolution_y = 640
sc.render.image_settings.file_format = 'PNG'

import mathutils
target = mathutils.Vector((0.05, 0, 0.18))
VISTAS = [
    ('00_frente', 0), ('01_trescuartos_izq', 45), ('02_perfil_izq', 90),
    ('03_atras', 180), ('04_trescuartos_der', 315), ('05_perfil_der', 270),
    ('06_cenital', -1),
]
for nombre, angulo in VISTAS:
    if angulo == -1:
        sc.camera.location = target + mathutils.Vector((0.0, 0.0, 0.9))
    else:
        ang = math.radians(angulo)
        offset = mathutils.Vector((math.sin(ang) * 0.65, -math.cos(ang) * 0.65, 0.25))
        sc.camera.location = target + offset
    dirv = target - sc.camera.location
    sc.camera.rotation_euler = dirv.to_track_quat('-Z', 'Y').to_euler()
    sc.render.filepath = os.path.join(RAIZ_FAUNA, 'capturas',
                                      f'conejo_v12_{nombre}.png')
    bpy.ops.render.render(write_still=True)
    print(f'RENDER: conejo_v12_{nombre}')

# ═══════════ Guardar .blend + export GLB ═══════════
BLEND_OUT = os.path.join(RAIZ_FAUNA, 'conejo_lowpoly_v12.blend')
bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
print('GUARDADO:', BLEND_OUT)

bpy.ops.object.select_all(action='DESELECT')
for o in escena.objects:
    if o.type == 'MESH':
        o.select_set(True)
GLB_OUT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\assets\3d\media\36-Fauna_conejo.glb"
bpy.ops.export_scene.gltf(filepath=GLB_OUT, export_format='GLB', use_selection=True)
print('GLB:', GLB_OUT)
print('=== CONEJO V12 (HY4 LOFTING) COMPLETO ===')
