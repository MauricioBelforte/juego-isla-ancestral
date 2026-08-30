#!/usr/bin/env python3
"""
generar_variante.py - M166 · Genera las variantes MEDIA y BAJA de un asset
a partir de su .blend de ALTA, SIN duplicar arte.

Por qué existe: la propuesta original era modelar dos versiones a mano. Eso
duplica el trabajo de 117 assets y garantiza que las versiones divergen. En su
lugar, ALTA es la única fuente de verdad y las otras dos se derivan con este
script.

Qué hace:
  --media   Merge por material.   33 objetos -> 6. Los triangulos NO cambian,
            la imagen es IDENTICA, los draw calls caen un 82 %. Coste visual: 0.
  --baja    Merge + decimate 0.5 + poda de piezas diminutas (remaches,
            glifos, costillas finas). Solo para el perfil mas bajo.

Uso:
    python generar_variante.py <modulo> <blend_alta> --media
    python generar_variante.py <modulo> <blend_alta> --baja
    python generar_variante.py <modulo> <blend_alta> --media --baja

Opciones:
    --ratio F           ratio de decimate (default 0.7, ver E-23)
    --decima-media      aplica el decimate TAMBIEN a MEDIA (no solo a BAJA).
                        Necesario en los heroes: el merge lossless de un ALTA
                        con bevel se pasa de los 1500 tris de MEDIA.
    --max-mats N        poda a N materiales distintos conservando los de MAS
                        caras y remapeando el resto al de color mas parecido.
                        Default: el techo del presupuesto (BAJA 4, MEDIA 8).

Ejemplo:
    python generar_variante.py 25-Ruinas-Templos cofre_ancestral_lowpoly --media --baja
    python generar_variante.py 45-Arte3D totem_isla_alta --media --decima-media --ratio 0.43

Después de generar:
    python stats_asset.py SM_Cofre_     # verificar presupuesto
    python capturar_angulos.py SM_ ... 6   # QA visual, E-13 obligatorio
"""
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

RAIZ = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))

# Piezas que NUNCA se podan aunque sean chicas: son estructurales o de apoyo.
PROTEGIDAS = ('Pie', 'Base', 'Soporte', 'Tronco', 'Poste', 'Cuerpo', 'Tapa')
# Piezas que tampoco se funden ni se decimatan: su detalle fino se pierde con
# el decimate. Costillas de un cofre, gemas, candados, ojos, leña con vetas, etc.
# Para cada asset nuevo, agregar aqui los sufijos que NO deben tocarse.
CRITICAS_NO_FUNDIR = ()
# Volumen de bounding box por debajo del cual una pieza se considera "detalle"
# prescindible y se poda en la variante BAJA. 1e-4 m3 ~= cubo de 4.6 cm de lado.
# Calibrado sobre el cofre: por debajo de ese umbral caen el tirador (anillo) y
# los remaches sueltos, pero NO la gema (foco visual) ni las asas.
UMBRAL_PODA = 1e-4
# Ratio de decimate para BAJA. 0.5 es demasiado agresivo sobre mallas planas
# (cajas de 6 caras): las rompe. 0.7 mantiene ~550-600 tris sin destruir la
# silueta, sobre todo en paneles del cuerpo y costillas que quedan en las
# mallas fundidas.
DECIMATE_RATIO = 0.7
# Techo de materiales DISTINTOS en la variante generada (None = sin limite).
# El presupuesto BAJA admite 4 y el MEDIA 8, pero el merge por material
# conserva todos los materiales del ALTA: `tablon_madera` funde 33 piezas en
# 6 objetos y sigue usando 6 materiales (Tablon_A/B/C + Veta_1/2/3). El decimate
# no baja esa cuenta, asi que hacia falta una poda explicita. Con --max-mats N
# se conservan los N materiales con MAS caras y los demas se remapean al
# conservado de color mas parecido (distancia RGB sobre diffuse_color).
MAX_MATS = None

CODE = r"""
import bpy, bmesh, os, math
from mathutils import Vector

RUTA_ALTA = @@RUTA_ALTA@@
RUTA_SALIDA = @@RUTA_SALIDA@@
MODO = @@MODO@@          # 'media' | 'baja'
PROTEGIDAS = @@PROTEGIDAS@@
CRITICAS = @@CRITICAS@@
UMBRAL = @@UMBRAL@@
DECIMATE_RATIO = @@DEC_RATIO@@
DECIMA_MEDIA = @@DECIMA_MEDIA@@
MAX_MATS = @@MAX_MATS@@

# E-14: NUNCA wm.read_factory_settings por el socket. Para empezar limpio,
# abrir el .blend de ALTA (que ya arranca de escena vacia por su propia limpieza).
bpy.ops.wm.open_mainfile(filepath=RUTA_ALTA)
escena = bpy.context.scene
bpy.context.view_layer.update()

def es_asset(o):
    return o.type == 'MESH' and o.name.startswith('SM_')

def protegida(o):
    return any(p.lower() in o.name.lower() for p in PROTEGIDAS)

def es_critica(o):
    # Las criticas no se funden NI se podan NI se decimatan: su geometria
    # detallada (costillas, cerradura, gemas) se preserva intacta.
    if o.name.endswith('_NOFUNDIR'):
        return True
    return any(c in o.name for c in CRITICAS)

def volumen_bbox(o):
    bb = [o.matrix_world @ Vector(c) for c in o.bound_box]
    xs = [v.x for v in bb]; ys = [v.y for v in bb]; zs = [v.z for v in bb]
    return (max(xs)-min(xs)) * (max(ys)-min(ys)) * (max(zs)-min(zs))

# --- Nombre del asset a partir de las piezas (SM_Cofre_X -> Cofre) ---
nombres = [o.name for o in escena.objects if es_asset(o)]
if not nombres:
    raise RuntimeError('No hay objetos SM_* en el blend')
ASSET = nombres[0].split('_')[1] if len(nombres[0].split('_')) > 1 else 'Asset'

# ============================================================
# FASE 0 - PODA de piezas diminutas (SOLO BAJA, y ANTES del merge)
# ============================================================
# Va antes del merge a proposito: una vez fusionadas, las piezas chicas ya no
# existen como objetos y no hay nada que podar. Poda primero, fusiona despues.
if MODO == 'baja':
    podadas = []
    for o in [x for x in escena.objects
              if es_asset(x) and not es_critica(x)]:
        if protegida(o):
            continue
        if volumen_bbox(o) < UMBRAL:
            podadas.append(o.name)
            bpy.data.objects.remove(o, do_unlink=True)
    bpy.context.view_layer.update()
    print('PODA BAJA: %d piezas eliminadas -> %s'
          % (len(podadas), ', '.join(podadas) if podadas else 'ninguna'))

# ============================================================
# FASE 1 - MERGE POR MATERIAL (comun a MEDIA y BAJA)
# ============================================================
# Las piezas CRITICAS (costillas, cerradura, gemas, etc.) NO se funden: se
# conservan como objetos separados con su geometria detallada intacta.
fusionables = [o for o in escena.objects
               if es_asset(o) and not es_critica(o)]

# Agrupar por la LISTA de materiales: los objetos con la misma lista comparten
# indices de material, asi que las caras se pueden copiar tal cual.
grupos = {}
for o in fusionables:
    clave = tuple(m.name if m is not None else '' for m in o.data.materials)
    grupos.setdefault(clave, []).append(o)

a_borrar = []
creados = []

for clave, objetos in grupos.items():
    bm = bmesh.new()
    for o in objetos:
        mw = o.matrix_world
        mapa = {}
        for v in o.data.vertices:
            mapa[v.index] = bm.verts.new(mw @ v.co)
        for p in o.data.polygons:
            try:
                f = bm.faces.new(tuple(mapa[i] for i in p.vertices))
                f.material_index = p.material_index
            except ValueError:
                pass      # cara duplicada o degenerada: se descarta
        a_borrar.append(o)

    bm.normal_update()
    if len(bm.faces) == 0:
        bm.free()
        continue

    # nombre: SM_{Asset}_M_{Materiales}
    if clave and clave[0]:
        corto = '_'.join(c.replace('MAT_', '') for c in clave if c)
    else:
        corto = 'SinMaterial'
    nombre = 'SM_%s_M_%s' % (ASSET, corto)

    me = bpy.data.meshes.new(nombre)
    bm.to_mesh(me)
    bm.free()

    nuevo = bpy.data.objects.new(nombre, me)
    escena.collection.objects.link(nuevo)
    # Baking a coords de mundo: location y scale identidad (E-18 a favor).
    nuevo.location = (0.0, 0.0, 0.0)
    nuevo.scale = (1.0, 1.0, 1.0)
    for c in clave:
        if c:
            me.materials.append(bpy.data.materials[c])
    creados.append(nuevo)

# --- Liberar hijos antes de borrar padres (si no, quedan huerfanos) ---
conjunto_borrar = set(id(o) for o in a_borrar)
for c in list(escena.objects):
    if c.parent is not None and id(c.parent) in conjunto_borrar:
        mw = c.matrix_world.copy()
        c.parent = None
        c.matrix_world = mw

for o in a_borrar:
    bpy.data.objects.remove(o, do_unlink=True)

bpy.context.view_layer.update()
print('MERGE: %d objetos -> %d mallas' % (len(fusionables), len(creados)))

# ============================================================
# FASE 2 - DECIMATE (BAJA siempre; MEDIA solo si --decima-media)
# ============================================================
# Para los assets "_alta_*" (ALTA-passed), el MEDIA lossless se pasa del
# presupuesto 1500. Con --decima-media se aplica el mismo decimate que a BAJA.
if MODO == 'baja' or (MODO == 'media' and DECIMA_MEDIA):
    bpy.context.view_layer.update()
    # bpy.ops.object.modifier_apply falla por contexto cuando se ejecuta por el
    # socket MCP ("poll() failed, context is incorrect"). Se aplica el modificador
    # evaluando el depsgraph y reasignando la malla resultante: mismo efecto,
    # sin depender de bpy.ops ni del objeto activo.
    n_decimate = 0
    for o in [x for x in escena.objects if es_asset(x) and not es_critica(x)]:
        mod = o.modifiers.new('Decimate', 'DECIMATE')
        mod.ratio = DECIMATE_RATIO
        mod.use_dissolve_boundaries = False   # preserva aristas duras (flat)
        bpy.context.view_layer.update()
        dg = bpy.context.evaluated_depsgraph_get()
        me_eval = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
        mats = [m for m in o.data.materials if m is not None]
        o.data = me_eval
        # E-34: `new_from_object()` YA copia los slots de material del objeto
        # evaluado. Si encima se vuelven a appendar, quedan duplicados
        # (3 -> 6) y el reporte infla el conteo de materiales por encima del
        # presupuesto BAJA (<= 4). Caso real 2026-08-29: puente_cuerda_baja
        # reportaba 6 materiales cuando solo usaba 3.
        #
        # E-35 - CUIDADO: `Mesh.materials.clear()` NO es la forma de deduplicar.
        # Resetea a 0 el `material_index` de TODAS las caras. Medido sobre
        # pozo_piedra_baja: 299 caras con hist {0:216, 1:57, 2:2, 3:24} pasaban
        # a {0:299} despues del clear(). Resultado: la BAJA se renderiza con un
        # UNICO material y el control de presupuesto da falso OK (mats_usados=1).
        # El primer intento de fix de E-34 cometio exactamente este error y
        # rompio puente_cuerda_baja y pozo_piedra_baja.
        #
        # Forma correcta: solo tocar los slots si realmente difieren, y en ese
        # caso respaldar los indices de cara y reasignarlos despues.
        # ojo: `material_slots` vive en el OBJECT, no en el Mesh (`o.data` no
        # tiene ese atributo). `o.data.materials` es la lista cruda de
        # materiales; los slots son la vista con link Object/Data.
        if [s.material for s in o.material_slots] != mats:
            idx_caras = [p.material_index for p in o.data.polygons]
            o.data.materials.clear()
            for m in mats:
                o.data.materials.append(m)
            for p, mi in zip(o.data.polygons, idx_caras):
                p.material_index = mi
        o.modifiers.clear()
        n_decimate += 1
    print('DECIMATE BAJA: ratio %.2f aplicado a %d mallas fundidas (criticas intactas)'
          % (DECIMATE_RATIO, n_decimate))

# ============================================================
# FASE 2.5 - PODA DE MATERIALES (solo si MAX_MATS no es None)
# ============================================================
# El merge por material junta objetos, no materiales: si el ALTA usa 6 y el
# presupuesto BAJA admite 4, hay que reducirlos. Se conservan los MAX_MATS
# materiales con MAS caras (los que realmente se ven) y los demas se remapean
# al conservado cuyo color difuso este mas cerca en RGB.
#
# E-41 - NO usar `Mesh.materials.clear()` para esto (E-35): resetea a 0 el
# material_index de TODAS las caras y la malla queda con un unico material.
# Aqui se reescribe el indice cara por cara, agregando el slot destino solo si
# el objeto todavia no lo tiene.
if MAX_MATS is not None:
    bpy.context.view_layer.update()
    piezas = [o for o in escena.objects if es_asset(o)]

    # 1) censo global de caras por material
    censo = {}
    for o in piezas:
        for p in o.data.polygons:
            if p.material_index < len(o.material_slots):
                sm = o.material_slots[p.material_index].material
                if sm:
                    censo[sm.name] = censo.get(sm.name, 0) + 1

    if len(censo) > MAX_MATS:
        ranking = sorted(censo.items(), key=lambda kv: -kv[1])
        conservar = [n for n, _ in ranking[:MAX_MATS]]
        descartar = [n for n, _ in ranking[MAX_MATS:]]
        mats_cons = [bpy.data.materials[n] for n in conservar]

        # 2) para cada material descartado, el conservado mas parecido en RGB
        remapeo = {}
        for nombre in descartar:
            md = bpy.data.materials[nombre]
            col = md.diffuse_color
            mejor, mejor_d = None, None
            for mc in mats_cons:
                c = mc.diffuse_color
                d = ((col[0]-c[0])**2 + (col[1]-c[1])**2 + (col[2]-c[2])**2)
                if mejor_d is None or d < mejor_d:
                    mejor, mejor_d = mc, d
            remapeo[nombre] = mejor.name
            print('  MAT %-28s (%4d caras) -> %s'
                  % (nombre, censo[nombre], mejor.name))

        # 3) reescribir el indice de material cara por cara
        for o in piezas:
            nombres_actuales = [m.name if m else '' for m in o.data.materials]
            idx_dest = {}
            for viejo, nuevo in remapeo.items():
                if nuevo not in idx_dest:
                    if nuevo in nombres_actuales:
                        idx_dest[nuevo] = nombres_actuales.index(nuevo)
                    else:
                        o.data.materials.append(bpy.data.materials[nuevo])
                        nombres_actuales.append(nuevo)
                        idx_dest[nuevo] = len(nombres_actuales) - 1
            for p in o.data.polygons:
                if p.material_index >= len(o.material_slots):
                    continue
                sm = o.material_slots[p.material_index].material
                if sm and sm.name in remapeo:
                    p.material_index = idx_dest[remapeo[sm.name]]

        # 4) purgar slots que quedaron sin ninguna cara. Si no se hace, el
        # objeto sigue declarando 6 slots aunque solo use 4 y el reporte final
        # (y cualquier export) infla la cuenta de materiales.
        # E-41: el respaldo de indices se hace por NOMBRE, no por numero, asi
        # el clear() + append() no puede desalinear las caras.
        for o in piezas:
            nombres_viejos = [m.name if m else '' for m in o.data.materials]
            idx_nombres = []
            for p in o.data.polygons:
                i = p.material_index
                idx_nombres.append(nombres_viejos[i]
                                   if i < len(nombres_viejos) else '')
            usados = []
            for nm in idx_nombres:
                if nm and nm not in usados:
                    usados.append(nm)
            if len(usados) == len(nombres_viejos):
                continue
            o.data.materials.clear()
            for nm in usados:
                o.data.materials.append(bpy.data.materials[nm])
            nuevo_idx = {nm: k for k, nm in enumerate(usados)}
            for p, nm in zip(o.data.polygons, idx_nombres):
                p.material_index = nuevo_idx.get(nm, 0)
        bpy.context.view_layer.update()
        print('PODA MATERIALES: %d -> %d (conservados: %s)'
              % (len(censo), MAX_MATS, ', '.join(conservar)))
    else:
        print('PODA MATERIALES: no hace falta (%d materiales <= %d)'
              % (len(censo), MAX_MATS))

# ============================================================
# FASE 3 - shade_flat + re-asentado (E-12)
# ============================================================
bpy.context.view_layer.update()
for o in escena.objects:
    if es_asset(o):
        o.select_set(True)
        bpy.context.view_layer.objects.active = o
bpy.ops.object.shade_flat()
bpy.ops.object.select_all(action='DESELECT')

Z_APOYO = 0.045
bpy.context.view_layer.update()
piezas = [o for o in escena.objects if es_asset(o)]

# E-24: medir sobre los VERTICES REALES, no sobre las 8 esquinas del bound_box.
# El AABB de un objeto rotado incluye esquinas vacias (donde no hay geometria),
# y su minimo puede quedar muy por debajo de la pieza mas baja real. Si se
# re-asienta compensando ese AABB, el conjunto entero se levanta y la pieza
# estructural (la base) queda flotando. Caso real: palanca_madera, cuyo Brazo
# inclinado tiraba el AABB a -0.396 y hacia flotar al Soporte a +0.486.
def zmin_real(o):
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)

z_min = min(zmin_real(o) for o in piezas)
delta = Z_APOYO - z_min
for o in piezas:
    if o.parent is None:
        o.location.z += delta
bpy.context.view_layer.update()
z_fin = min(zmin_real(o) for o in piezas)
print('RE-ASENTADO: z_min %.3f -> %.3f (delta %+.3f)' % (z_min, z_fin, delta))

# ============================================================
# FASE 4 - Guardar
# ============================================================
os.makedirs(os.path.dirname(RUTA_SALIDA), exist_ok=True)
if os.path.exists(RUTA_SALIDA + '@'):
    os.remove(RUTA_SALIDA + '@')      # E-21: si no, "Unable to make version backup"
bpy.ops.wm.save_as_mainfile(filepath=RUTA_SALIDA)

n_obj = len([o for o in escena.objects if es_asset(o)])
# E-33: la columna "tris" tiene que ser triangulos REALES (`loop_triangles`),
# no `polygons` (que cuenta quads como 1 y subestima ~2x para mallas con quads).
# Bug historico: los 43 assets aprobados antes del 2026-08-29 figuraban en
# el checklist con la mitad del tri-count real.
n_tris = 0
for o in escena.objects:
    if not es_asset(o): continue
    o.data.calc_loop_triangles()
    n_tris += len(o.data.loop_triangles)
# E-42: contar materiales EFECTIVAMENTE USADOS por las caras, no slots.
# El slot cuenta aunque ninguna cara lo referencie, asi que despues de podar
# materiales el reporte seguía diciendo 6 cuando la malla solo usaba 4 - el
# mismo numero que despues audita `auditar_presupuesto.py` (mats_usados).
n_mats = set()
for o in escena.objects:
    if not es_asset(o):
        continue
    for p in o.data.polygons:
        if p.material_index < len(o.material_slots):
            sm = o.material_slots[p.material_index].material
            if sm:
                n_mats.add(sm.name)
n_mats = len(n_mats)
print('VARIANTE %s OK -> %s' % (MODO.upper(), RUTA_SALIDA))
print('  objetos=%d  tris=%d  materiales=%d' % (n_obj, n_tris, n_mats))
"""


def generar(modulo, blend_alta, modo, ratio=None, decima_media=False,
            max_mats=None):
    # --ratio permite un decimate más agresivo para casos puntuales (ej. assets
    # de vegetación densa cuya BAJA supera el presupuesto de 700 tris). El 0.7
    # global sigue siendo el default calibrado; no lo cambies sin E-23 en mente.
    dec_ratio = DECIMATE_RATIO if ratio is None else ratio
    ruta_alta = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', modulo, blend_alta)
    if not ruta_alta.endswith('.blend'):
        ruta_alta += '.blend'
    if not os.path.exists(ruta_alta):
        print('No existe el blend de ALTA: %s' % ruta_alta)
        return False

    salida = ruta_alta.replace('.blend', '_%s.blend' % modo)
    code = (CODE.replace('@@RUTA_ALTA@@', repr(ruta_alta))
                .replace('@@RUTA_SALIDA@@', repr(salida))
                .replace('@@MODO@@', repr(modo))
                .replace('@@PROTEGIDAS@@', repr(list(PROTEGIDAS)))
                .replace('@@CRITICAS@@', repr(list(CRITICAS_NO_FUNDIR)))
                .replace('@@UMBRAL@@', repr(UMBRAL_PODA))
                .replace('@@DEC_RATIO@@', repr(dec_ratio))
                .replace('@@DECIMA_MEDIA@@', repr(decima_media))
                .replace('@@MAX_MATS@@', repr(max_mats)))

    r = blender_command('execute_code', {'code': code}, timeout=180)
    if r.get('status') != 'success':
        print('ERROR:', json.dumps(r, ensure_ascii=False)[:800])
        return False
    print(r.get('result', {}).get('result', '').strip())
    return True


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        sys.exit(1)
    modulo = sys.argv[1]
    blend = sys.argv[2]
    modos = [a.lstrip('-') for a in sys.argv[3:] if a.lstrip('-') in ('media', 'baja')]
    if not modos:
        print('Indicá --media y/o --baja')
        sys.exit(1)
    ratio = None
    if '--ratio' in sys.argv:
        i = sys.argv.index('--ratio')
        try:
            ratio = float(sys.argv[i + 1])
        except (IndexError, ValueError):
            print('--ratio requiere un número, ej: --ratio 0.5')
            sys.exit(1)
    decima_media = '--decima-media' in sys.argv
    max_mats = None
    if '--max-mats' in sys.argv:
        i = sys.argv.index('--max-mats')
        try:
            max_mats = int(sys.argv[i + 1])
        except (IndexError, ValueError):
            print('--max-mats requiere un entero, ej: --max-mats 4')
            sys.exit(1)
    for modo in modos:
        # Sin --max-mats se aplica el techo del presupuesto de la variante
        # (BAJA 4, MEDIA 8). Asi la variante NACE dentro del presupuesto en
        # lugar de nacer excedida y necesitar un saneo posterior.
        mm = max_mats if max_mats is not None else (4 if modo == 'baja' else 8)
        print('--- generando variante %s (ratio %s, decima_media=%s, max_mats=%s) ---'
              % (modo.upper(), ratio if ratio is not None else DECIMATE_RATIO,
                 decima_media, mm))
        if not generar(modulo, blend, modo, ratio, decima_media, mm):
            sys.exit(1)


if __name__ == '__main__':
    main()
