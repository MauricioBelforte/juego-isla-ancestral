"""auditar_presupuesto.py — E-33 + E-34: medir tris reales y slots en todas las variantes.

Recorre todos los *_baja.blend y *_media.blend, abre cada uno y mide:
- objetos con prefijo SM_ (excluye Base_Arena, SOL, CAM_*, Mundo)
- triangulos REALES (mesh.calc_loop_triangles())
- slots de material del mesh
- materiales distintos USADOS por las caras
- z_min del conjunto

Imprime una tabla y al final un resumen de quien excede el presupuesto.
"""
import bpy, os, mathutils
BM = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp'
PRESUPUESTO = {'media': (8, 1500, 8),
               'baja':  (6, 700,  4)}
filas = []
for raiz, dirs, files in os.walk(BM):
    for f in sorted(files):
        if not (f.endswith('_baja.blend') or f.endswith('_media.blend')):
            continue
        path = os.path.join(raiz, f)
        try:
            bpy.ops.wm.open_mainfile(filepath=path)
        except Exception as e:
            print('NO SE PUDO ABRIR: %s' % path)
            continue
        sufijo = 'baja' if f.endswith('_baja.blend') else 'media'
        objs = [o for o in bpy.context.scene.objects if o.name.startswith('SM_')]
        if not objs:
            continue
        caras = tris = 0
        total_slots = 0
        # E-36: el script original (y todos los reportes previos) solo
        # inspeccionaba `objs[0]` para materiales, ignorando los demas
        # objetos SM_ de la escena. Caso real: tablon_madera tiene 6 SM_ y
        # `objs[0].material_slots` es 1, asi que el reporte decia slots=1,
        # mats_usados=1 y la BAJA con 6 materiales quedaba oculta. El conteo
        # de TRIS ya estaba bien porque si itera todos los objs; los slots y
        # mats tienen que agregarse igual.
        mats_usados = set()
        for o in objs:
            m = o.data
            m.calc_loop_triangles()
            caras += len(m.polygons)
            tris  += len(m.loop_triangles)
            total_slots += len(o.material_slots)
            for cara in m.polygons:
                if cara.material_index < len(o.material_slots):
                    sm = o.material_slots[cara.material_index].material
                    if sm:
                        mats_usados.add(sm.name)
        zmin = min(min((o.matrix_world @ mathutils.Vector(c)).z
                       for c in o.bound_box) for o in objs)
        rel = os.path.relpath(path, BM)
        lim = PRESUPUESTO[sufijo]
        flag = ''
        if len(objs) > lim[0]:
            flag += ' obj+'
        if tris > lim[1]:
            flag += ' tris+'
        if len(mats_usados) > lim[2]:
            flag += ' mats+'
        filas.append((rel, sufijo, len(objs), caras, tris, total_slots,
                     len(mats_usados), zmin, flag))

filas.sort()
print('%-55s %-6s  obj  car   TRIS  slots  mats  zmin   flag' % ('ruta', 'tipo'))
print('-' * 100)
for rel, sufijo, nobj, caras, tris, nslots, nmu, zmin, flag in filas:
    print('%-55s %-6s  %2d  %4d  %4d  %3d    %3d   %.3f  %s'
          % (rel[:55], sufijo, nobj, caras, tris, nslots, nmu, zmin, flag))
print('---')
excede = [f for f in filas if f[8]]
print('TOTAL: %d variantes, %d exceden el presupuesto' % (len(filas), len(excede)))
for f in excede:
    print('  %-55s %-6s %s' % (f[0][:55], f[1], f[8]))
