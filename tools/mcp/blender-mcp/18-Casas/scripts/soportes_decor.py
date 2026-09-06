# soportes_decor.py — VALIDADOR de ensamblaje del lote de decoración.
# Regla: cada pieza SM_ debe estar SOPORTADA — su AABB inferior debe
# solapar (en XY) con el suelo, otra pieza cuyo top alcance su base, o el
# set (pared/horca). Piezas "en el aire" = falla. Headless.
import bpy
import os
import glob
import math
from mathutils import Vector

RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\18-Casas'
TOL = 0.03          # 3 cm de tolerancia de "contacto"
MIN_SOBRE = 0.045   # umbral: si la base esta por encima del top del candidato + TOL, flota

def aabb(o):
    pts = [o.matrix_world @ Vector(c) for c in o.bound_box]
    return (Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts))),
            Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts))))

def solapa_xy(a0, a1, b0, b1, margen=0.01):
    return (a0.x - margen < b1.x and b0.x - margen < a1.x and
            a0.y - margen < b1.y and b0.y - margen < a1.y)

blends = sorted(glob.glob(os.path.join(RAIZ, 'decor_*_lowpoly.blend')))
print('=== VALIDADOR SOPORTES: %d items ===' % len(blends))
fallas_totales = 0
for ruta in blends:
    bpy.ops.wm.open_mainfile(filepath=ruta)
    bpy.context.view_layer.update()
    sm = [o for o in bpy.data.objects if o.name.startswith('SM_')]
    set_objs = [o for o in bpy.data.objects if o.name.startswith('Set_')]
    suelo = 0.045
    fallas = []
    for o in sm:
        a0, a1 = aabb(o)
        # 1) toca el suelo
        if a0.z <= suelo + TOL:
            continue
        # 2) soporte CLASICO: otra pieza cuyo top alcanza nuestra base y
        #    solapa en planta
        soportada = False
        for b in sm + set_objs:
            if b == o:
                continue
            b0, b1 = aabb(b)
            if b1.z <= a0.z + 0.02 and b1.z >= a0.z - 0.05 and solapa_xy(a0, a1, b0, b1):
                soportada = True
                break
            # v2: EMBEBIDA/ATRAVESADA — solapan verticalmente y en planta
            # (tapas que abrazan cuellos, asas, musgo, frondas al ras, ganchos
            # de viga): el ensamblaje lowpoly usa interpenetracion controlada.
            if (b0.z < a1.z - 0.01 and b1.z > a0.z + 0.01 and
                    solapa_xy(a0, a1, b0, b1)):
                soportada = True
                break
            # pared: set con cara frontal bajo la pieza
            if b.name.startswith('Set_Pared') and a0.z < b1.z and solapa_xy(a0, a1, b0, b1):
                soportada = True
                break
        if not soportada:
            fallas.append((o.name, round(a0.z, 3)))
    nombre = os.path.basename(ruta)
    if fallas:
        fallas_totales += len(fallas)
        print('  %-38s FALLA: %s' % (nombre, ', '.join('%s@%.2f' % f for f in fallas)))
    else:
        print('  %-38s OK' % nombre)
print('=== FIN: %d piezas en el aire ===' % fallas_totales)
