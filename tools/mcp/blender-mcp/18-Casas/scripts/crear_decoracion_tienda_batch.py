# crear_decoracion_tienda_batch.py — LOTE v2 de accesorios (M18-TER)
# v2 (feedback usuario: "algunos mal ensamblados con partes en el aire"):
# TODAS las pilas recalculadas pieza a pieza (cada z deriva del top real
# de la pieza de abajo), items de pared con Set_Pared detras (leer "colgado"),
# helecho con horca de set, mecedora con soportes de brazos.
# El validador soportes_decor.py VERIFICA que ninguna pieza flota.
import bpy
import math
import os
from mathutils import Vector

OUT_DIR = os.path.dirname(os.path.abspath(__file__)) + os.sep + '..'

# ============ FRAMEWORK ============
def limpiar():
    for _obj in list(bpy.data.objects):
        bpy.data.objects.remove(_obj, do_unlink=True)
    for _bloque in (bpy.data.meshes, bpy.data.materials, bpy.data.lights,
                    bpy.data.cameras, bpy.data.worlds):
        for _dato in list(_bloque):
            if _dato.users == 0:
                _bloque.remove(_dato)

def crear_mat(nombre, color, rough=0.88, alpha=1.0, emis=0.0, metal=0.0):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Metallic'].default_value = metal
    if alpha < 1.0:
        bsdf.inputs['Alpha'].default_value = alpha
        m.blend_method = 'BLEND'
        m.use_backface_culling = False
    if emis > 0.0:
        bsdf.inputs['Emission Color'].default_value = (*color, 1.0)
        bsdf.inputs['Emission Strength'].default_value = emis
    return m

MAT = {}
def mats():
    global MAT
    if MAT:
        return MAT
    MAT = {
        'madera_clara':  crear_mat('MAT_Decor_Madera_Clara', (0.62, 0.47, 0.30)),
        'madera_oscura': crear_mat('MAT_Decor_Madera_Oscura', (0.40, 0.28, 0.16)),
        'piedra':        crear_mat('MAT_Decor_Piedra', (0.52, 0.52, 0.50)),
        'piedra_oscura': crear_mat('MAT_Decor_Piedra_Oscura', (0.34, 0.34, 0.35)),
        'barro':         crear_mat('MAT_Decor_Barro', (0.72, 0.50, 0.34)),
        'barro_osc':     crear_mat('MAT_Decor_Barro_Osc', (0.58, 0.38, 0.24)),
        'tela_crema':    crear_mat('MAT_Decor_Tela_Crema', (0.92, 0.88, 0.76)),
        'tela_roja':     crear_mat('MAT_Decor_Tela_Roja', (0.72, 0.28, 0.22)),
        'tela_azul':     crear_mat('MAT_Decor_Tela_Azul', (0.30, 0.48, 0.62)),
        'flor_rosa':     crear_mat('MAT_Decor_Flor_Rosa', (0.94, 0.56, 0.62)),
        'flor_amar':     crear_mat('MAT_Decor_Flor_Amar', (0.96, 0.82, 0.30)),
        'hoja':          crear_mat('MAT_Decor_Hoja', (0.28, 0.56, 0.28)),
        'hoja_oscura':   crear_mat('MAT_Decor_Hoja_Osc', (0.18, 0.40, 0.20)),
        'bronce':        crear_mat('MAT_Decor_Bronce', (0.72, 0.55, 0.35), rough=0.4, metal=0.6),
        'vidrio':        crear_mat('MAT_Decor_Vidrio', (0.55, 0.75, 0.85), alpha=0.45),
        'llama':         crear_mat('MAT_Decor_Llama', (1.0, 0.72, 0.30), emis=2.5),
        'blanco_hueso':  crear_mat('MAT_Decor_Hueso', (0.90, 0.87, 0.78)),
        'perla':         crear_mat('MAT_Decor_Perla', (0.88, 0.88, 0.86), rough=0.15),
        'coral':         crear_mat('MAT_Decor_Coral', (0.85, 0.42, 0.35)),
        'arena':         crear_mat('MAT_Arena_Isla', (0.92, 0.84, 0.63), rough=1.0),
        'cuerda':        crear_mat('MAT_Decor_Cuerda', (0.78, 0.68, 0.48)),
    }
    return MAT

def caja(nombre, mat, sx, sy, sz, cx, cy, cz, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(cx, cy, cz), rotation=rot)
    o = bpy.context.object
    o.name = nombre
    o.scale = (sx, sy, sz)
    o.data.materials.append(mat)
    return o

def cilindro(nombre, mat, r, h, cx, cy, cz, verts=12, r2=None):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r, radius2=r2 if r2 is not None else r,
                                    depth=h, location=(cx, cy, cz))
    o = bpy.context.object
    o.name = nombre
    o.data.materials.append(mat)
    return o

def cono(nombre, mat, r, h, cx, cy, cz, verts=10):
    return cilindro(nombre, mat, r, h, cx, cy, cz, verts=verts, r2=0.001)

def esfera(nombre, mat, r, cx, cy, cz, sub=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub, radius=r, location=(cx, cy, cz))
    o = bpy.context.object
    o.name = nombre
    o.data.materials.append(mat)
    return o

def toro(nombre, mat, R, r, cx, cy, cz, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_torus_add(major_radius=R, minor_radius=r, location=(cx, cy, cz), rotation=rot)
    o = bpy.context.object
    o.name = nombre
    o.data.materials.append(mat)
    return o

def join(nombre_base, objs):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    r = bpy.context.object
    r.name = nombre_base
    return r

def base_arena(radio=1.4):
    cilindro('Base_Arena', mats()['arena'], radio, 0.24, 0.0, 0.0, -0.06, verts=24)

def pared_set(ancho=1.15, alto=1.35):
    """v2: pared del SET para items de pared (no SM_, no viaja al GLB).
    Panel vertical (plano XY, cara frontal z=0.58) + 2 postes al sand.
    Los items montados apoyan su cara trasera en z 0.595 (0.58 + holgura)."""
    m = mats()
    caja('Set_Pared_Panel', m['madera_oscura'], ancho, alto, 0.07, 0, 0, 0.58 - 0.035 + 0.5 * 0)
    # el panel debe elevarse desde los postes: centro z tal que bottom 0.51
    bpy.data.objects['Set_Pared_Panel'].location = (0, 0, 0.545)
    bpy.data.objects['Set_Pared_Panel'].scale = (ancho, alto, 0.07)
    for sx in (-ancho / 2 + 0.06, ancho / 2 - 0.06):
        caja('Set_Pared_Poste', m['madera_oscura'], 0.08, 0.08, 0.51, sx, 0, 0.045 + 0.51 / 2 - 0.045 + 0.045)

def horca_set():
    """v2: horca de set para el helecho colgante: 2 postes + travesano
    (no SM_). El gancho del helecho cuelga del travesano a z 0.765."""
    m = mats()
    for sx in (-0.40, 0.40):
        caja('Set_Horca_Poste', m['madera_oscura'], 0.07, 0.07, 0.80, sx, 0, 0.445)
    caja('Set_Horca_Viga', m['madera_clara'], 0.95, 0.08, 0.08, 0, 0, 0.80)

def asentar_y_guardar(nombre_item, comentarios='', montado=False):
    """Asenta el GRUPO a z_min=0.045 (E-12/E-24, depsgraph E-91) y guarda.
    montado=True: item de PARED/colgado — NO se asienta el grupo (cuelga
    del set); solo stats + save."""
    dg = bpy.context.evaluated_depsgraph_get()
    sm_objs = [o for o in bpy.data.objects if o.name.startswith('SM_')]
    def zmin_grupo():
        dg.update()
        return min((o.matrix_world @ v.co).z for o in sm_objs for v in o.data.vertices)
    if not montado:
        zmin = zmin_grupo()
        dz = 0.045 - zmin
        if abs(dz) > 1e-6:
            for o in sm_objs:
                o.location.z += dz
            bpy.context.view_layer.update()
            dg.update()
        zmin2 = zmin_grupo()
        assert 0.039 < zmin2 < 0.051, '%s: z_min grupo %.4f != 0.045' % (nombre_item, zmin2)
        tag = 'z_min %.4f' % zmin2
    else:
        tag = 'MONTADO (set pared/horca)'
    total_tris = sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in sm_objs)
    n_mats = len({m.name for o in sm_objs for m in o.data.materials})
    print('  %-22s %2d SM_ | %4d tris | %2d mats | %s %s' % (
        nombre_item, len(sm_objs), total_tris, n_mats, tag, comentarios))
    ruta = os.path.abspath(os.path.join(OUT_DIR, 'decor_%s_lowpoly.blend' % nombre_item))
    bpy.ops.wm.save_as_mainfile(filepath=ruta)
    return ruta

# ============ ITEMS (pilas recalculadas pieza a pieza) ============

def item_lampara_pie():
    """v2 FIX: poste iba de -0.55 a 0.75 (medio enterrado) y la pantalla
    flotaba 60 cm arriba. Ahora: base 0.045..0.10, poste 0.05..1.35
    (centro 0.70), pantalla 1.19..1.45 solapando el tope, bombilla dentro."""
    m = mats()
    base_arena(1.2)
    caja('SM_LampPie_Base', m['madera_oscura'], 0.30, 0.30, 0.05, 0, 0, 0.075)
    cilindro('SM_LampPie_Poste', m['madera_oscura'], 0.025, 1.30, 0, 0, 0.70, verts=8)
    pantalla = cono('SM_LampPie_Pantalla', m['tela_crema'], 0.20, 0.26, 0, 0, 1.32, verts=12)
    pantalla.rotation_euler = (math.pi, 0, 0)
    esfera('SM_LampPie_Bombilla', m['llama'], 0.05, 0, 0, 1.22, sub=1)
    asentar_y_guardar('lampara_pie', '(pila: base→poste→pantalla)')

def item_farol_mesa():
    """v3 FIX (validador): la campana flotaba 5.5 cm — pie 0.045..0.085,
    poste 0.085..0.385 (centro 0.235), campana 0.085..0.365 ABRANZANDO el
    pie y atravesada por el poste, vela DENTRO apoyada en el pie."""
    m = mats()
    base_arena(1.0)
    cilindro('SM_FarolMesa_Pie', m['bronce'], 0.10, 0.04, 0, 0, 0.065, verts=10)
    # pie 0.045..0.085
    cilindro('SM_FarolMesa_Poste', m['bronce'], 0.012, 0.30, 0, 0, 0.235, verts=8)
    # poste 0.085..0.385
    cilindro('SM_FarolMesa_Campana', m['vidrio'], 0.10, 0.28, 0, 0, 0.225, verts=14)
    # campana 0.085..0.365 (apoya en el pie, abraza el poste)
    # v8-DEFINITIVO (fix del USUARIO en el .blend: manija a 0.435, el
    # tope del poste 0.385 queda justo dentro del aro 0.385..0.485).
    toro('SM_FarolMesa_Aro', m['bronce'], 0.05, 0.010, 0, 0, 0.435, rot=(math.pi / 2, 0, 0))
    # v4 FIX (usuario): el aro era R 0.10 centrado a 0.375 — un aro gigante
    # ATRAVESANDO el farol. Ahora manija compacta (R 0.05) SOBRE el tope del
    # vidrio (0.365): ancla en el poste y sube como asa vertical.
    cilindro('SM_FarolMesa_Vela', m['tela_crema'], 0.035, 0.14, 0, 0, 0.155, verts=8)
    esfera('SM_FarolMesa_Llama', m['llama'], 0.03, 0, 0, 0.25, sub=1)
    asentar_y_guardar('farol_mesa', '(manija sobre el tope del vidrio)')

def item_vela_plato():
    m = mats()
    base_arena(0.9)
    cilindro('SM_VelaPlato_Plato', m['barro'], 0.16, 0.03, 0, 0, 0.06, verts=14)
    cilindro('SM_VelaPlato_Borde', m['barro_osc'], 0.17, 0.012, 0, 0, 0.075, verts=14)
    cilindro('SM_VelaPlato_Vela', m['tela_crema'], 0.045, 0.12, 0, 0, 0.14, verts=8)
    esfera('SM_VelaPlato_Llama', m['llama'], 0.028, 0, 0, 0.22, sub=1)
    for dx, dy in ((-0.10, 0.05), (0.09, -0.06)):
        caja('SM_VelaPlato_Petalo', m['flor_rosa'], 0.07, 0.04, 0.008, dx, dy, 0.082)
    asentar_y_guardar('vela_plato', '')

def item_cuadro_floral():
    """v2: MONTADO en Set_Pared — marco apoya su dorso (z 0.595) sobre la
    cara de la pared (0.58). Antes flotaba sin nada detras."""
    m = mats()
    base_arena(1.1)
    pared_set()
    W, H, ZC = 0.60, 0.48, 0.615
    fr = []
    fr.append(caja('MF', m['madera_oscura'], W + 0.08, 0.07, 0.05, 0, H / 2 - 0.035, ZC))
    fr.append(caja('MF', m['madera_oscura'], W + 0.08, 0.07, 0.05, 0, -H / 2 + 0.035, ZC))
    fr.append(caja('MF', m['madera_oscura'], 0.07, H, 0.05, -W / 2 + 0.035, 0, ZC))
    fr.append(caja('MF', m['madera_oscura'], 0.07, H, 0.05, W / 2 - 0.035, 0, ZC))
    join('SM_CuadroFl_Marco', fr)
    caja('SM_CuadroFl_Lienzo', m['tela_crema'], W - 0.02, H - 0.02, 0.02, 0, 0, ZC - 0.01)
    for dx, dy, col in ((-0.14, 0.06, 'flor_rosa'), (0.02, -0.04, 'flor_amar'), (0.15, 0.10, 'flor_rosa')):
        caja('SM_CuadroFl_Tallo', m['hoja'], 0.015, 0.15, 0.015, dx, dy - 0.07, ZC + 0.005)
        esfera('SM_CuadroFl_Flor', m[col], 0.045, dx, dy + 0.02, ZC + 0.015, sub=1)
    asentar_y_guardar('cuadro_floral', montado=True)

def item_mascara_ancestral():
    m = mats()
    base_arena(0.9)
    pared_set(ancho=0.80, alto=1.10)
    ZC = 0.615
    caja('SM_Mascara_Cara', m['madera_clara'], 0.30, 0.42, 0.06, 0, 0, ZC)
    for dy in (0.08, -0.02):
        caja('SM_Mascara_Ojo', m['madera_oscura'], 0.07, 0.03, 0.03, 0, dy, ZC + 0.04)
    caja('SM_Mascara_Boca', m['madera_oscura'], 0.10, 0.025, 0.03, 0, -0.14, ZC + 0.04)
    for dx in (-0.10, 0, 0.10):
        caja('SM_Mascara_Hoja', m['hoja'], 0.05, 0.10, 0.03, dx, 0.30, ZC + 0.03,
             rot=(0, 0, 0.2 * (dx * 10)))
    caja('SM_Mascara_Nariz', m['madera_oscura'], 0.05, 0.03, 0.05, 0, 0.03, ZC + 0.045)
    asentar_y_guardar('mascara_ancestral', montado=True)

def item_reloj_pared():
    """v2: MONTADO — caja apoyada en la pared (dorso z 0.58), esfera y
    manecillas en la cara +Z del reloj (antes miraban raro)."""
    m = mats()
    base_arena(0.9)
    pared_set(ancho=0.85, alto=1.05)
    ZB = 0.62                      # centro de la caja: dorso 0.58 = pared
    cilindro('SM_RelojP_Caja', m['madera_oscura'], 0.22, 0.08, 0, 0, ZB, verts=16)
    cilindro('SM_RelojP_Esfera', m['tela_crema'], 0.19, 0.02, 0, 0, ZB + 0.05, verts=16)
    caja('SM_RelojP_Hora', m['madera_oscura'], 0.015, 0.09, 0.01, 0, 0.035, ZB + 0.065)
    caja('SM_RelojP_Minuto', m['madera_oscura'], 0.015, 0.14, 0.01, 0.03, -0.02, ZB + 0.065,
         rot=(0, 0, math.radians(30)))
    esfera('SM_RelojP_Centro', m['bronce'], 0.02, 0, 0, ZB + 0.065, sub=1)
    asentar_y_guardar('reloj_pared', montado=True)

def item_espejo_marco():
    m = mats()
    base_arena(1.0)
    pared_set(ancho=0.95, alto=1.25)
    W, H, ZC = 0.50, 0.70, 0.615
    fr = []
    fr.append(caja('MF', m['madera_oscura'], W + 0.08, 0.06, 0.05, 0, H / 2 - 0.03, ZC))
    fr.append(caja('MF', m['madera_oscura'], W + 0.08, 0.06, 0.05, 0, -H / 2 + 0.03, ZC))
    fr.append(caja('MF', m['madera_oscura'], 0.06, H, 0.05, -W / 2 + 0.03, 0, ZC))
    fr.append(caja('MF', m['madera_oscura'], 0.06, H, 0.05, W / 2 - 0.03, 0, ZC))
    join('SM_Espejo_Marco', fr)
    caja('SM_Espejo_Cristal', m['vidrio'], W - 0.01, H - 0.01, 0.015, 0, 0, ZC - 0.012)
    asentar_y_guardar('espejo_marco', montado=True)

def item_repisa_pared():
    """v2: MONTADO — tabla saliendo de la pared (profundidad en Z), 2
    ménsulas contra pared+tabla, detallitos encima de la tabla."""
    m = mats()
    base_arena(1.2)
    pared_set(ancho=1.15, alto=1.35)
    ZT = 0.58 + 0.10              # tabla: z 0.58..0.78 saliendo de la pared
    caja('SM_Repisa_Tabla', m['madera_clara'], 0.70, 0.04, 0.20, 0, 0, ZT)
    for sx in (-0.25, 0.25):
        caja('SM_Repisa_Soporte', m['madera_oscura'], 0.05, 0.02, 0.14, sx, 0, ZT - 0.09,
             rot=(0, 0, 0))
    # detallitos SOBRE la tabla (cara superior y +0.02)
    cilindro('SM_Repisa_Vela', m['tela_crema'], 0.03, 0.08, -0.20, ZT + 0.06, 0.68, verts=8,
             )  # eje vertical: cilindro default eje Z — pero la tabla "arriba" es +Y
    bpy.data.objects['SM_Repisa_Vela'].rotation_euler = (math.pi / 2, 0, 0)
    bpy.data.objects['SM_Repisa_Vela'].location = (-0.20, 0.06, ZT)
    caja('SM_Repisa_Libro', m['tela_roja'], 0.10, 0.05, 0.07, 0.10, 0.045, ZT)
    esfera('SM_Repisa_Concha', m['blanco_hueso'], 0.03, 0.30, 0.035, ZT + 0.01, sub=1)
    asentar_y_guardar('repisa_pared', montado=True)

def fronda_doble(nombre, mat, base, dir1, L1, dir2, L2, ancho=0.05, grosor=0.014):
    """v7: fronda de DOS segmentos encadenados con to_track_quat — el
    peciolo sale en dir1 y la lamina CAE en dir2 (arco real, leible).
    Devuelve los 2 objetos (join quien quiera)."""
    o1 = caja(nombre + '_Pe', mat, L1, ancho, grosor,
              base.x + dir1.x * L1 / 2, base.y + dir1.y * L1 / 2, base.z + dir1.z * L1 / 2)
    o1.rotation_euler = dir1.to_track_quat('X', 'Y').to_euler()
    p2 = Vector((base.x + dir1.x * L1, base.y + dir1.y * L1, base.z + dir1.z * L1))
    o2 = caja(nombre + '_La', mat, L2, ancho * 0.8, grosor,
              p2.x + dir2.x * L2 / 2, p2.y + dir2.y * L2 / 2, p2.z + dir2.z * L2 / 2)
    o2.rotation_euler = dir2.to_track_quat('X', 'Y').to_euler()
    return o1, o2

def item_maceta_palmera():
    """v7 REDESÑO 2 (usuario: 'todavía no les encuentro forma'). Silueta
    ARQUETÍPICA de palmera: maceta troncocónica + TRONCO ALTO único con
    taper fuerte (0.035→0.018) ligeramente curvado (2 segmentos) + corona
    de 7 frondas DOBLES (peciolo 28° arriba-fuera + lámina cayendo 55°)
    + 3 cocos bajo la corona. El tronco alto es lo que lee 'palmera'."""
    m = mats()
    base_arena(1.3)
    # maceta troncocónica invertida: base r 0.13, boca r 0.17
    cilindro('SM_MacPal_Maceta', m['barro'], 0.13, 0.16, 0, 0, 0.125, verts=12, r2=0.17)
    caja('SM_MacPal_Tierra', m['piedra_oscura'], 0.30, 0.30, 0.02, 0, 0, 0.205)
    # tronco: 2 segmentos con drift (curva suave), taper 0.034→0.020
    t1 = cilindro('SM_MacPal_Tronco', m['madera_oscura'], 0.034, 0.26, 0, 0, 0.335, verts=7)
    t2 = cilindro('SM_MacPal_TroncoT', m['madera_oscura'], 0.026, 0.30, 0.025, 0, 0.60, verts=7, r2=0.018)
    TOP = Vector((0.055, 0.0, 0.755))   # tope de la corona
    # corona: 7 frondas dobles radiales
    for i in range(7):
        a = i * 2 * math.pi / 7
        radial = Vector((math.cos(a), math.sin(a), 0.0))
        dir1 = (radial * 0.88 + Vector((0, 0, 0.47))).normalized()   # sale 28° arriba
        dir2 = (radial * 0.83 - Vector((0, 0, 0.56))).normalized()   # cae 34° abajo
        fronda_doble('SM_MacPal_Fr_%d' % i, m['hoja'], TOP, dir1, 0.11, dir2, 0.26)
    # 3 cocos colgando bajo la corona
    for i in range(3):
        a = i * 2 * math.pi / 3 + 0.5
        esfera('SM_MacPal_Coco', m['madera_oscura'], 0.042,
               TOP.x + 0.07 * math.cos(a), 0.07 * math.sin(a), 0.695, sub=1)
    asentar_y_guardar('maceta_palmera', '(palmera: tronco alto + frondas dobles)')

def item_maceta_helecho():
    """v7 REDESÑO 2 (usuario: 'todavía no les encuentro forma'). Helecho
    colgante ARQUETÍPICO: matillo parado arriba (4 hojas) + FALDÓN denso
    de 12 frondas dobles que nacen del borde, arquean afuera y CAEN por
    fuera de la maceta (hasta z 0.06). Colgado de la horca."""
    m = mats()
    base_arena(1.3)
    horca_set()
    # maceta cónica: base 0.13, boca 0.10, top 0.175
    cilindro('SM_MacHel_Maceta', m['barro_osc'], 0.13, 0.13, 0, 0, 0.11, verts=10, r2=0.10)
    BORDE = 0.175
    # matillo central: 4 hojas paradas que arquean
    for i in range(4):
        a = i * math.pi / 2 + 0.4
        radial = Vector((math.cos(a), math.sin(a), 0.0))
        dir1 = (radial * 0.35 + Vector((0, 0, 0.94))).normalized()
        dir2 = (radial * 0.85 - Vector((0, 0, 0.53))).normalized()
        fronda_doble('SM_MacHel_Centro_%d' % i, m['hoja_oscura'],
                     Vector((0.03 * math.cos(a), 0.03 * math.sin(a), BORDE - 0.01)),
                     dir1, 0.10, dir2, 0.13, ancho=0.045)
    # faldón: 12 frondas desde el borde, arco afuera-abajo cruzando el borde
    for i in range(12):
        a = i * math.pi / 6
        radial = Vector((math.cos(a), math.sin(a), 0.0))
        base = Vector((radial.x * 0.095, radial.y * 0.095, BORDE + 0.005))
        dir1 = (radial * 0.80 + Vector((0, 0, 0.60))).normalized()   # sube saliendo
        dir2 = (radial * 0.45 - Vector((0, 0, 0.89))).normalized()   # cae casi vertical
        fronda_doble('SM_MacHel_Fr_%d' % i, m['hoja'], base, dir1, 0.09, dir2, 0.16, ancho=0.035)
    # cuerdas del borde al gancho + gancho de la viga
    for i in range(3):
        a = i * 2 * math.pi / 3 + math.pi / 6
        cilindro('SM_MacHel_Cuerda', m['cuerda'], 0.008, 0.585,
                 0.09 * math.cos(a), 0.09 * math.sin(a), BORDE + 0.293, verts=5)
    toro('SM_MacHel_Gancho', m['bronce'], 0.045, 0.010, 0, 0, 0.785)
    # v8: gancho a 0.785 — la viga de la horca (z 0.80, bottom 0.76) pasa
    # por dentro del aro (0.740..0.830): el gancho cuelga de la viga de
    # verdad (validador E-93 exigió el solape).
    asentar_y_guardar('maceta_helecho', '(matillo + faldón de 12 frondas)')

def item_maceta_flor():
    """v8 FIX (usuario: 'hojas separadas del tallo'): las hojas estaban a
    z fijo (0.20/0.24) flotando a media altura del tallo inclinado. Ahora
    ancladas AL TALLO con fronda_doble: nacen del tallo a z 0.25/0.32,
    horizontales-afuera con caida leve — hojas reales de maceta."""
    m = mats()
    base_arena(0.9)
    cilindro('SM_MacFlor_Maceta', m['blanco_hueso'], 0.11, 0.09, 0, 0, 0.09, verts=10, r2=0.08)
    # maceta 0.045..0.135
    caja('SM_MacFlor_Tierra', m['piedra_oscura'], 0.17, 0.17, 0.02, 0, 0, 0.13)
    # tallo leve curvado (2 segmentos, drift X)
    t1 = cilindro('SM_MacFlor_Tallo', m['hoja'], 0.012, 0.18, 0, 0, 0.225, verts=6)
    t2 = cilindro('SM_MacFlor_TalloT', m['hoja'], 0.010, 0.18, 0.016, 0, 0.40, verts=6)
    # 2 hojas ANCLADAS al tallo: z 0.25 y 0.32, lado ±X con caida
    for i, (z_n, sx) in enumerate(((0.25, -1), (0.33, 1))):
        base = Vector((0.008 * sx * z_n / 0.29, 0, z_n))   # sobre el tallo
        dir1 = Vector((0.85 * sx, 0, 0.53)).normalized()    # sale arriba-afuera
        dir2 = Vector((0.95 * sx, 0, -0.31)).normalized()   # cae al borde
        fronda_doble('SM_MacFlor_Hoja%d' % i, m['hoja'], base, dir1, 0.08, dir2, 0.10, ancho=0.045)
    # flor al tope del tallo (0.49): centro + 5 petalos radiales
    FLOR = Vector((0.032, 0, 0.50))
    esfera('SM_MacFlor_Centro', m['flor_amar'], 0.035, FLOR.x, FLOR.y, FLOR.z, sub=1)
    for i in range(5):
        a = i * 2 * math.pi / 5
        caja('SM_MacFlor_Petalo', m['flor_rosa'], 0.09, 0.05, 0.012,
             FLOR.x + 0.085 * math.cos(a), FLOR.y + 0.085 * math.sin(a), FLOR.z, rot=(0, 0, -a))
    asentar_y_guardar('maceta_flor', '(hojas ancladas al tallo)')

def item_alfombra_floral():
    """v4 FIX (usuario: "parece un modelo atómico con órbitas"): el anillo
    era un torus PARADO (rot X 90 → plano YZ) cortando la alfombra como
    órbita. Un anillo de alfombra es un aro plano sobre el piso: torus
    SIN rotar (plano XY nativo) apenas 1 cm sobre el disco."""
    m = mats()
    base_arena(1.6)
    cilindro('SM_AlfaFlor_Disco', m['tela_crema'], 0.80, 0.02, 0, 0, 0.055, verts=20)
    # anillo plano (sin rot: el torus de Blender ya es plano en XY)
    toro('SM_AlfaFlor_Anillo', m['tela_roja'], 0.66, 0.035, 0, 0, 0.065)
    for i in range(4):
        a = i * math.pi / 2
        caja('SM_AlfaFlor_Petalo', m['flor_rosa'], 0.28, 0.10, 0.012,
             0.40 * math.cos(a), 0.40 * math.sin(a), 0.068, rot=(0, 0, -a))
    esfera('SM_AlfaFlor_Centro', m['flor_amar'], 0.09, 0, 0, 0.065, sub=1)
    # centro = media esfera apenas hundida en el disco
    bpy.data.objects['SM_AlfaFlor_Centro'].location = (0, 0, 0.048)
    asentar_y_guardar('alfombra_floral', '(anillo plano, sin órbitas)')

def item_alfombra_tejida():
    """v2 FIX: los flecos colgaban 12 cm POR DEBAJO de la alfombra → el
    asentado levantaba todo y la alfombra flotaba. Flecos ahora horizontales
    (rot X 90), asomando del borde al mismo nivel de la trama."""
    m = mats()
    base_arena(1.6)
    caja('SM_AlfaTej_Base', m['tela_azul'], 1.60, 1.00, 0.02, 0, 0, 0.055)
    caja('SM_AlfaTej_Franja1', m['tela_crema'], 1.60, 0.12, 0.012, 0, 0.22, 0.07)
    caja('SM_AlfaTej_Franja2', m['tela_roja'], 1.60, 0.08, 0.012, 0, 0, 0.07)
    caja('SM_AlfaTej_Franja3', m['tela_crema'], 1.60, 0.12, 0.012, 0, -0.22, 0.07)
    for sx in (-1, 1):
        for i in range(6):
            y = -0.40 + i * 0.16
            f = cilindro('SM_AlfaTej_Fleco', m['cuerda'], 0.014, 0.10, sx * 0.85, y, 0.055, verts=5)
            f.rotation_euler = (math.pi / 2, 0, 0)   # horizontal, asoma del borde
    asentar_y_guardar('alfombra_tejida', '(flecos horizontales)')

def item_olla_barro():
    """v2 FIX: cuello flotaba 7.5 cm (0.24 vs cuerpo top 0.165). Pila:
    cuerpo 0.045..0.165 → cuello 0.165..0.225 → tapa esfera cubre → pomo."""
    m = mats()
    base_arena(1.0)
    cilindro('SM_Olla_Cuerpo', m['barro'], 0.20, 0.12, 0, 0, 0.105, verts=14, r2=0.10)
    # cuerpo: 0.045..0.165
    cilindro('SM_Olla_Cuello', m['barro_osc'], 0.12, 0.06, 0, 0, 0.195, verts=12)
    # cuello: 0.165..0.225
    esfera('SM_Olla_Tapa', m['barro_osc'], 0.13, 0, 0, 0.26, sub=2)
    # tapa esfera r 0.13: 0.13..0.39 — cubre cuello y asienta sobre el cuerpo
    cilindro('SM_Olla_Pomo', m['barro'], 0.035, 0.05, 0, 0, 0.395, verts=8)
    for sy in (-1, 1):
        toro('SM_Olla_Asa', m['barro_osc'], 0.05, 0.015, 0.20, sy * 0.20, 0.12,
             rot=(math.pi / 2, 0, 0))
    asentar_y_guardar('olla_barro', '(pila cuerpo→cuello→tapa→pomo)')

def item_plato_frutas():
    m = mats()
    base_arena(1.0)
    cilindro('SM_PlatoF_Plato', m['blanco_hueso'], 0.20, 0.03, 0, 0, 0.06, verts=16)
    cilindro('SM_PlatoF_Borde', m['blanco_hueso'], 0.22, 0.012, 0, 0, 0.078, verts=16)
    esfera('SM_PlatoF_Mango', m['flor_amar'], 0.06, -0.06, 0.02, 0.10, sub=2)
    esfera('SM_PlatoF_Coco', m['madera_oscura'], 0.055, 0.07, -0.05, 0.095, sub=2)
    esfera('SM_PlatoF_Pasion', m['flor_rosa'], 0.05, -0.02, -0.07, 0.088, sub=1)
    caja('SM_PlatoF_Hoja', m['hoja'], 0.14, 0.04, 0.008, 0.13, 0.08, 0.082, rot=(0, 0, 0.5))
    asentar_y_guardar('plato_frutas', '')

def item_jarron_agua():
    """v2 FIX: cuello flotaba 10 cm (0.30 vs cuerpo top 0.195). Pila:
    cuerpo 0.045..0.195 → cuello 0.195..0.275 → agua al ras 0.27."""
    m = mats()
    base_arena(0.9)
    cilindro('SM_Jarron_Cuerpo', m['barro'], 0.14, 0.15, 0, 0, 0.12, verts=12, r2=0.10)
    # cuerpo 0.045..0.195
    cilindro('SM_Jarron_Cuello', m['barro_osc'], 0.07, 0.08, 0, 0, 0.235, verts=10, r2=0.11)
    # cuello 0.195..0.275 (se ensancha a 0.11 arriba: hombro de jarron)
    # v7 FIX (usuario: "los aros en cualquier parte"): el asa estaba a
    # mitad de camino en diagonal (-0.13, 0.08) con plano YZ. Asa de jarra
    # real: arco vertical en el plano XZ pegado al costado -X, centrada
    # (-0.15, 0, 0.225) R 0.08 — extremo inferior embebido en el hombro
    # del cuerpo (z~0.17) y superior en el labio del cuello (z~0.28).
    toro('SM_Jarron_Asa', m['barro_osc'], 0.08, 0.018, -0.15, 0.0, 0.225,
         rot=(math.pi / 2, 0, 0))
    cilindro('SM_Jarron_Agua', m['vidrio'], 0.055, 0.015, 0, 0, 0.272, verts=10)
    asentar_y_guardar('jarron_agua', '(asa lateral XZ: hombro→labio)')

def item_totem_chico():
    """v2 FIX: las caras arrancaban 16 cm sobre la base (+0.16 fantasma) y
    el penacho flotaba 21 cm. Pila acumulada: base 0.045..0.105 → cara1
    0.105..0.265 → cara2 0.265..0.405 → cara3 0.405..0.525 → penacho."""
    m = mats()
    base_arena(0.9)
    caja('SM_Totem_Base', m['piedra'], 0.26, 0.26, 0.06, 0, 0, 0.075)
    z = 0.105
    for w, h, mat in ((0.20, 0.16, 'madera_oscura'),
                      (0.16, 0.14, 'madera_clara'),
                      (0.12, 0.12, 'madera_oscura')):
        caja('SM_Totem_Cara', m[mat], w, w, h, 0, 0, z + h / 2)
        caja('SM_Totem_Ojos', m['barro_osc'], w * 0.5, 0.02, 0.02, 0, w / 2 * 0.9, z + h * 0.62)
        caja('SM_Totem_Boca', m['barro_osc'], w * 0.3, 0.015, 0.02, 0, w / 2 * 0.9, z + h * 0.3)
        z += h
    for dx in (-0.05, 0, 0.05):
        caja('SM_Totem_Penacho', m['hoja'], 0.03, 0.03, 0.09, dx, 0, z + 0.045)
    asentar_y_guardar('totem_chico', '(pila acumulada cara a cara)')

def item_idol_piedra():
    """v2 FIX: la cabeza flotaba 4.5 cm sobre la base (0.15 vs 0.105)."""
    m = mats()
    base_arena(0.9)
    caja('SM_Idol_Base', m['piedra_oscura'], 0.24, 0.20, 0.06, 0, 0, 0.075)
    caja('SM_Idol_Cabeza', m['piedra'], 0.24, 0.20, 0.40, 0, 0, 0.305)
    # cabeza 0.105..0.505
    caja('SM_Idol_Nariz', m['piedra_oscura'], 0.05, 0.05, 0.20, 0, 0.10, 0.30)
    caja('SM_Idol_CejaI', m['piedra_oscura'], 0.09, 0.04, 0.05, -0.06, 0.08, 0.42)
    caja('SM_Idol_CejaD', m['piedra_oscura'], 0.09, 0.04, 0.05, 0.06, 0.08, 0.42)
    caja('SM_Idol_Boca', m['piedra_oscura'], 0.08, 0.04, 0.03, 0, 0.09, 0.20)
    esfera('SM_Idol_Musgo', m['hoja_oscura'], 0.05, 0.06, 0.05, 0.53, sub=1)
    asentar_y_guardar('idol_piedra', '(cabeza asentada en base)')

def item_vasija_ritual():
    """v4 FIX (mismo bug que alfombra/fuente, detectado por el agente): los
    3 glifos eran aros PARADOS cortando la vasija. Glifos = bandas PLANAS
    alrededor del cuerpo (torus sin rot, plano XY)."""
    m = mats()
    base_arena(0.9)
    cilindro('SM_Vasija_Cuerpo', m['barro'], 0.15, 0.15, 0, 0, 0.12, verts=12, r2=0.11)
    # cuerpo 0.045..0.195
    for z in (0.08, 0.135, 0.19):
        toro('SM_Vasija_Glifo', m['tela_azul'], 0.145, 0.012, 0, 0, z)
    cono('SM_Vasija_Tapa', m['barro_osc'], 0.09, 0.10, 0, 0, 0.245, verts=10)
    esfera('SM_Vasija_Pomo', m['blanco_hueso'], 0.025, 0, 0, 0.30, sub=1)
    asentar_y_guardar('vasija_ritual', '(glifos bandas planas)')

def item_concha_decor():
    """v6 REDESÑO (usuario: "no le encuentro forma alguna"). Concha de
    abanico (vieira) REAL: 9 costillas radiales que nacen de la bisagra
    (umbo) abriendose en abanico con curva — las centrales mas largas —
    inclinadas hacia atras (to_track_quat 'X'), 2 orejitas laterales en
    la bisagra, apoyada en un monticulo de arena."""
    m = mats()
    base_arena(1.0)
    # monticulo de arena (esfera achatada, top 0.135)
    mont = esfera('SM_Concha_Base', m['arena'], 0.15, 0, 0, 0.09, sub=2)
    mont.scale = (1.0, 1.0, 0.30)
    # bisagra (umbo) sobre el monticulo
    HINGE = Vector((0.0, 0.03, 0.115))
    caja('SM_Concha_Umbo', m['barro_osc'], 0.045, 0.05, 0.05,
         HINGE.x, HINGE.y, HINGE.z)
    # 9 costillas en abanico: ±49° desde la vertical, inclinadas atras
    for i in range(9):
        phi = -0.85 + i * (1.70 / 8.0)          # -0.85..+0.85 rad
        tilt = 0.30                              # lean back
        dirv = Vector((math.sin(phi), -math.cos(phi) * math.sin(tilt),
                      math.cos(phi) * math.cos(tilt)))
        L = 0.16 + 0.09 * math.cos(phi)         # curva del abanico
        rot = dirv.to_track_quat('X', 'Y').to_euler()
        col = 'blanco_hueso' if i % 2 == 0 else 'tela_crema'
        caja('SM_Concha_Costilla', m[col], L, 0.030, 0.018,
             HINGE.x + dirv.x * L / 2, HINGE.y + dirv.y * L / 2,
             HINGE.z + dirv.z * L / 2, rot=(rot.x, rot.y, rot.z))
    # 2 orejitas (auriculas) de vieira en la bisagra
    for sx in (-1, 1):
        caja('SM_Concha_Oreja', m['blanco_hueso'], 0.055, 0.028, 0.020,
             sx * 0.058, 0.02, 0.105)
    asentar_y_guardar('concha_decor', '(vieira: abanico radial curvo + umbo)')

def item_farol_coral():
    """v9 FIX (usuario: 'esferitas mal ubicadas'): las puntas estaban a
    offset fijo (0.10, 0.34) ignorando la inclinacion de las ramas —
    flotaban al costado. Ahora cada rama tiene DIRECCION calculada
    (radial 20°) y la esfera va en el EXTREMO REAL de esa direccion."""
    m = mats()
    base_arena(1.0)
    caja('SM_FarolCor_Base', m['piedra'], 0.24, 0.24, 0.06, 0, 0, 0.075)
    for i in range(5):
        a = i * 2 * math.pi / 5
        radial = Vector((math.cos(a), math.sin(a), 0.0))
        dirv = (radial * 0.34 + Vector((0, 0, 0.94))).normalized()  # 20° afuera
        H = 0.24
        base = Vector((radial.x * 0.05, radial.y * 0.05, 0.105))
        rama = cilindro('SM_FarolCor_Rama', m['coral'], 0.025, H,
                        base.x + dirv.x * H / 2, base.y + dirv.y * H / 2,
                        base.z + dirv.z * H / 2, verts=6, r2=0.012)
        rama.rotation_euler = dirv.to_track_quat('Z', 'Y').to_euler()
        punta = Vector((base.x + dirv.x * H, base.y + dirv.y * H, base.z + dirv.z * H))
        esfera('SM_FarolCor_Punta', m['coral'], 0.028, punta.x, punta.y, punta.z, sub=1)
    esfera('SM_FarolCor_Luz', m['llama'], 0.045, 0, 0, 0.18, sub=1)
    asentar_y_guardar('farol_coral', '(puntas en el extremo real de las ramas)')

def item_cofre_perlas():
    """v2 FIX: perla alta flotaba 5 cm sobre la tapa — las 3 ahora
    apoyadas sobre la tapa (top 0.245)."""
    m = mats()
    base_arena(0.9)
    cof = []
    cof.append(caja('Cf', m['madera_oscura'], 0.36, 0.24, 0.16, 0, 0, 0.125))
    cof.append(caja('Cf', m['madera_clara'], 0.38, 0.26, 0.04, 0, 0, 0.225))
    cof.append(caja('Cf', m['bronce'], 0.06, 0.05, 0.05, 0, 0.13, 0.20))
    join('SM_CofrePer_Cofre', cof)
    for (dx, dy) in ((-0.06, 0.02), (0.07, -0.02), (0.005, 0.05)):
        esfera('SM_CofrePer_Perla', m['perla'], 0.035, dx, dy, 0.272, sub=1)
    asentar_y_guardar('cofre_perlas', '(perlas sobre la tapa)')

def item_jarron_flores():
    """v2 FIX: boca flotaba 6.5 cm (0.26 vs cuerpo top 0.195); tallos y
    flores reencadenados: cuerpo 0.045..0.195 → boca 0.195..0.255 →
    tallos 0.255..0.535 → flores al tope."""
    m = mats()
    base_arena(0.9)
    cilindro('SM_JarronFl_Cuerpo', m['barro'], 0.09, 0.15, 0, 0, 0.12, verts=10, r2=0.06)
    # cuerpo 0.045..0.195
    cilindro('SM_JarronFl_Boca', m['barro_osc'], 0.06, 0.06, 0, 0, 0.225, verts=10, r2=0.085)
    # boca 0.195..0.255 (labio 0.085)
    for i, (dx, dy, col) in enumerate(((-0.05, 0.02, 'flor_rosa'), (0.0, -0.04, 'flor_amar'), (0.05, 0.02, 'flor_rosa'))):
        cilindro('SM_JarronFl_Tallo', m['hoja'], 0.008, 0.28, dx, dy, 0.395, verts=5)
        # tallo 0.255..0.535
        esfera('SM_JarronFl_Flor', m[col], 0.032, dx, dy, 0.545, sub=1)
    asentar_y_guardar('jarron_flores', '(pila cuerpo→boca→tallos→flores)')

def item_guirnalda():
    """v2 FIX: el lazo flotaba 32 cm sobre el aro, desconectado. Ahora
    MONTADA en Set_Pared: aro pegado a la pared, lazo tocando el tope del
    aro (donde se cuelga de verdad)."""
    m = mats()
    base_arena(1.0)
    pared_set(ancho=0.95, alto=1.20)
    ZG = 0.60                        # aro pegado a la pared (cara 0.58)
    toro('SM_Guirnalda_Cuerda', m['cuerda'], 0.30, 0.018, 0, 0, ZG, rot=(0, 0, 0))
    for i in range(8):
        a = i * math.pi / 4
        col = 'flor_rosa' if i % 2 == 0 else 'flor_amar'
        esfera('SM_Guirnalda_Flor', m[col], 0.035,
               0.30 * math.cos(a), 0.30 * math.sin(a), ZG + 0.01, sub=1)
    # lazo en el tope del aro (y +0.30): caja 0.07..0.38 solapa banda 0.282..0.318
    caja('SM_Guirnalda_Lazo', m['tela_roja'], 0.10, 0.07, 0.03, 0, 0.345, ZG)
    asentar_y_guardar('guirnalda', montado=True)

def item_baul_madera():
    m = mats()
    base_arena(1.0)
    ba = []
    ba.append(caja('B', m['madera_oscura'], 0.50, 0.30, 0.24, 0, 0, 0.165))
    ba.append(caja('B', m['madera_clara'], 0.52, 0.32, 0.06, 0, 0, 0.315))
    ba.append(caja('B', m['bronce'], 0.06, 0.33, 0.04, 0, 0, 0.30))
    join('SM_Baul_Cuerpo', ba)
    for sx in (-0.18, 0.18):
        caja('SM_Baul_Banda', m['bronce'], 0.05, 0.32, 0.26, sx, 0, 0.16)
    asentar_y_guardar('baul_madera', '')

def item_mecedora():
    """v2 FIX: los brazos flotaban (nada debajo en x ±0.28). Agregados 2
    postes verticales asiento→brazo. Cojin sobre el asiento."""
    m = mats()
    base_arena(1.6)
    sil = []
    sil.append(caja('Sa', m['madera_clara'], 0.50, 0.46, 0.05, 0, 0, 0.445))
    sil.append(caja('Sr', m['madera_clara'], 0.50, 0.06, 0.55, 0, 0.24, 0.72))
    for ddx, ddy in ((-0.20, -0.18), (0.20, -0.18), (-0.20, 0.18), (0.20, 0.18)):
        sil.append(caja('Sp', m['madera_oscura'], 0.05, 0.05, 0.40, ddx, ddy, 0.22))
    # v2: postes frontales de los brazos (asiento 0.47 → brazo 0.67)
    for sx in (-0.28, 0.28):
        sil.append(caja('Pb', m['madera_oscura'], 0.05, 0.05, 0.20, sx, -0.16, 0.57))
        sil.append(caja('Sb', m['madera_clara'], 0.06, 0.40, 0.06, sx, 0, 0.70))
    for sy in (-0.23, 0.23):
        sil.append(caja('Rk', m['madera_oscura'], 0.70, 0.05, 0.04, 0, sy, 0.05))
    join('SM_Mecedora', sil)
    caja('SM_Mecedora_Cojin', m['tela_roja'], 0.44, 0.40, 0.06, 0, 0, 0.50)
    asentar_y_guardar('mecedora', '(brazos con postes)')

def item_estatuilla_ave():
    """v11 REDESÑO (usuario: 'el pico apunta a cualquier parte, la cola es
    un cuadrado raro'). Ave mirando a -Y con to_track_quat: cabeza al
    frente, pico cono APUNTANDO a -Y (afuera de la cara), cola = abanico
    de 3 plumas escalonadas + 2 alas talladas al costado del cuerpo."""
    m = mats()
    base_arena(0.9)
    # base de madera
    caja('SM_Ave_Base', m['madera_oscura'], 0.20, 0.32, 0.05, 0, 0, 0.07)
    # cuerpo: esfera estirada en Y (eje del ave)
    cuerpo = esfera('SM_Ave_Cuerpo', m['madera_clara'], 0.10, 0, 0.02, 0.20, sub=2)
    cuerpo.scale = (0.85, 1.35, 0.95)
    # cabeza al frente-arriba del cuerpo
    cabeza = esfera('SM_Ave_Cabeza', m['madera_clara'], 0.055, 0, -0.115, 0.30, sub=2)
    # pico: cono con eje -Y apuntando hacia adelante-abajo (to_track_quat)
    dir_pico = Vector((0.0, -1.0, -0.25)).normalized()
    base_p = Vector((0, -0.16, 0.295))
    pico = cono('SM_Ave_Pico', m['flor_amar'], 0.022, 0.07,
                base_p.x + dir_pico.x * 0.035, base_p.y + dir_pico.y * 0.035,
                base_p.z + dir_pico.z * 0.035, verts=6)
    pico.rotation_euler = dir_pico.to_track_quat('Z', 'Y').to_euler()
    # cola: abanico de 3 plumas escalonadas hacia atras (+Y), zigzag
    for i, ang in enumerate((-0.45, 0.0, 0.45)):
        dir_c = Vector((math.sin(ang), math.cos(ang), 0.35)).normalized()
        L = 0.14
        bc = Vector((0, 0.10, 0.225))   # nace del lomo trasero del cuerpo
        pluma = caja('SM_Ave_Pluma', m['madera_oscura'], 0.030, L, 0.020,
                     bc.x + dir_c.x * L / 2, bc.y + dir_c.y * L / 2, bc.z + dir_c.z * L / 2)
        pluma.rotation_euler = dir_c.to_track_quat('Y', 'Z').to_euler()
    # alas talladas: 2 placas diagonales pegadas a los costados
    for sx in (-1, 1):
        ala = caja('SM_Ave_Ala', m['madera_oscura'], 0.018, 0.13, 0.06,
                   sx * 0.082, 0.02, 0.20)
        ala.rotation_euler = (0, 0, sx * 0.35)
    # ojos
    for sx in (-1, 1):
        esfera('SM_Ave_Ojo', m['madera_oscura'], 0.012, sx * 0.035, -0.135, 0.325, sub=1)
    asentar_y_guardar('estatuilla_ave', '(ave mira a -Y: pico dirigido, cola abanico)')

def item_lampara_techo():
    """v2: campana apoyada en el suelo como campana (el asentado natural);
    cadena articulada eslabon a eslabon hasta la campana."""
    m = mats()
    base_arena(1.0)
    for i in range(5):
        toro('SM_LampTecho_Cadena', m['bronce'], 0.03, 0.008,
             0, 0, 0.40 + i * 0.06, rot=(math.pi / 2, 0, 0))
    # cadena 0.37..0.67; campana tope 0.38 solapa el primer eslabon
    cilindro('SM_LampTecho_Campana', m['tela_crema'], 0.18, 0.16, 0, 0, 0.30, verts=12, r2=0.10)
    esfera('SM_LampTecho_Luz', m['llama'], 0.05, 0, 0, 0.26, sub=1)
    asentar_y_guardar('lampara_techo', '')

def item_banco_exterior():
    m = mats()
    base_arena(1.4)
    bn = []
    bn.append(caja('Ba', m['madera_clara'], 1.10, 0.36, 0.05, 0, 0, 0.425))
    for i in range(3):
        bn.append(caja('Br', m['madera_clara'], 1.10, 0.05, 0.35, 0, 0.18 - i * 0.06, 0.63))
    for sx in (-0.48, 0.48):
        bn.append(caja('Bp', m['madera_oscura'], 0.06, 0.34, 0.40, sx, 0, 0.21))
    join('SM_Banco_Jardin', bn)
    for dx in (-0.25, 0.25):
        caja('SM_Banco_Cojin', m['tela_azul'], 0.42, 0.32, 0.06, dx, 0, 0.48)
    asentar_y_guardar('banco_exterior', '')

def item_fuente_chica():
    """v4 FIX (usuario: "el aro es perpendicular al círculo"): el borde
    era torus PARADO (rot X 90 = plano vertical) cortando la pileta. Un
    borde de fuente es un anillo plano sobre el agua: torus SIN rotar."""
    m = mats()
    base_arena(1.3)
    cilindro('SM_Fuente_Base', m['piedra'], 0.40, 0.10, 0, 0, 0.095, verts=16)
    # borde plano (sin rot) al ras del tope de la base (0.145)
    toro('SM_Fuente_Borde', m['piedra_oscura'], 0.38, 0.045, 0, 0, 0.145)
    cilindro('SM_Fuente_Agua', m['vidrio'], 0.34, 0.02, 0, 0, 0.125, verts=16)
    cilindro('SM_Fuente_Columna', m['piedra'], 0.05, 0.30, 0, 0, 0.28, verts=8)
    # columna 0.13..0.43 (arranca dentro del borde/agua)
    cilindro('SM_Fuente_Taza', m['piedra_oscura'], 0.14, 0.04, 0, 0, 0.435, verts=10)
    # taza apoyada sobre el tope de la columna (0.43)
    cilindro('SM_Fuente_Chorro', m['vidrio'], 0.012, 0.10, 0, 0, 0.50, verts=6)
    asentar_y_guardar('fuente_chica', '(borde plano, no perpendicular)')

# ============ BATCH ============
ITEMS = [
    ('lampara_pie', item_lampara_pie),
    ('farol_mesa', item_farol_mesa),
    ('vela_plato', item_vela_plato),
    ('cuadro_floral', item_cuadro_floral),
    ('mascara_ancestral', item_mascara_ancestral),
    ('reloj_pared', item_reloj_pared),
    ('espejo_marco', item_espejo_marco),
    ('maceta_palmera', item_maceta_palmera),
    ('maceta_helecho', item_maceta_helecho),
    ('maceta_flor', item_maceta_flor),
    ('alfombra_floral', item_alfombra_floral),
    ('alfombra_tejida', item_alfombra_tejida),
    ('olla_barro', item_olla_barro),
    ('plato_frutas', item_plato_frutas),
    ('jarron_agua', item_jarron_agua),
    ('totem_chico', item_totem_chico),
    ('idol_piedra', item_idol_piedra),
    ('vasija_ritual', item_vasija_ritual),
    ('concha_decor', item_concha_decor),
    ('farol_coral', item_farol_coral),
    ('cofre_perlas', item_cofre_perlas),
    ('jarron_flores', item_jarron_flores),
    ('guirnalda', item_guirnalda),
    ('baul_madera', item_baul_madera),
    ('repisa_pared', item_repisa_pared),
    ('mecedora', item_mecedora),
    ('estatuilla_ave', item_estatuilla_ave),
    ('lampara_techo', item_lampara_techo),
    ('banco_exterior', item_banco_exterior),
    ('fuente_chica', item_fuente_chica),
]

print('\n=== LOTE DECORACION v2 (%d items) ===' % len(ITEMS))
for nombre, fn in ITEMS:
    limpiar()
    MAT.clear()
    mats()
    fn()
print('=== FIN v2: %d .blend regenerados ===' % len(ITEMS))
