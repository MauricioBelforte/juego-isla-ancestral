#!/usr/bin/env python3
# auditar_flotantes.py — Auditoria GENERAL de la regla "no floating" (AGENTS.md §24).
#
# DIFERENCIA CON auditar_apoyos.py
# --------------------------------
# auditar_apoyos.py trabaja sobre los scripts crear_*_lowpoly.py y necesita una
# tabla PREFIJOS_POR_SCRIPT hardcodeada: si un asset no esta en esa tabla, se
# saltea ("sin prefijos definidos, skip"). Sirve para medir mientras se generan.
#
# Este script es COMPLEMENTARIO y no necesita tabla ninguna: abre cada .blend
# ya generado y mide el z_min GLOBAL de todos los SM_ del archivo. Ese valor es
# la cota inferior del asset completo, asi que es la medida correcta de
# "el objeto toca la arena" incluso en assets multi-pieza (tronco + corona:
# el z_min global es la base del tronco, que es lo que debe apoyar).
#
# POR QUE HEADLESS (E-45)
# -----------------------
# - No toca la instancia GUI de Blender: no pisa el trabajo de otro agente ni
#   pierde .blend sin guardar.
# - bpy.context por socket NO tiene active_object; aca no hace falta.
#
# Criterio (Z_APOYO = 0.045, guia §E-12: 5 mm hundido bajo el tope de arena
# z=0.05). Con --tolerancia T:
#     z_min >  0.045 + T  -> FLOTA     (hay aire entre el asset y la arena)
#     z_min <  0.045 - T  -> HUNDIDO   (se mete de mas en la arena)
#     sino                -> ok
#
# AVISO (E-31): este chequeo es de COTA INFERIOR, no de contacto por pieza.
# Un asset cuyo cuerpo apoya pero tiene salientes colgando (cofres, aleros)
# pasa este test y aun asi puede leerse mal. E-13 (captura orbital) sigue
# siendo la fuente de verdad para la aprobacion final. Este script arma la
# lista corta para que quien tenga vision priorice.
#
# Uso:
#   blender -b --factory-startup --python auditar_flotantes.py
#   blender -b --factory-startup --python auditar_flotantes.py -- --modulo 50-Vegetacion
#   blender -b --factory-startup --python auditar_flotantes.py -- --tolerancia 0.03 --salida r.md
import sys
import os
import glob
import json

# blender -b --python no reenvia argv: se toma solo lo que venga despues de '--'
argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []

MODULO = None
TOLERANCIA = 0.02
Z_APOYO = 0.045
SALIDA = None
DETALLE = False
LISTAR = False

i = 0
while i < len(argv):
    if argv[i] == '--detalle':
        DETALLE = True
        i += 1
    elif argv[i] == '--listar':
        DETALLE = True
        LISTAR = True
        i += 1
    elif argv[i] == '--modulo' and i + 1 < len(argv):
        MODULO = argv[i + 1]
        i += 2
    elif argv[i] == '--tolerancia' and i + 1 < len(argv):
        TOLERANCIA = float(argv[i + 1])
        i += 2
    elif argv[i] == '--z-apoyo' and i + 1 < len(argv):
        Z_APOYO = float(argv[i + 1])
        i += 2
    elif argv[i] == '--salida' and i + 1 < len(argv):
        SALIDA = argv[i + 1]
        i += 2
    else:
        i += 1

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # .../blender-mcp

import bpy
from mathutils import Vector


def zmin_real(o):
    """E-24: medir sobre los VERTICES REALES, no sobre las 8 esquinas del AABB.

    Un objeto rotado tiene un AABB cuyas esquinas quedan por debajo de la
    geometria real (esquinas vacias). Medir con bound_box da minimos
    falsamente bajos -> el auditor reporta "HUNDIDO" en assets que estan
    perfectamente apoyados. Caso real documentado: palanca_madera, cuyo
    Brazo inclinado tiraba el AABB a -0.396.
    """
    if len(o.data.vertices) == 0:
        return min((o.matrix_world @ Vector(c)).z for c in o.bound_box)
    return min((o.matrix_world @ v.co).z for v in o.data.vertices)


def z_min_global():
    """Cota inferior en Z de todos los SM_ del archivo, y el objeto que la da."""
    obs = [o for o in bpy.data.objects if o.type == 'MESH' and o.name.startswith('SM_')]
    if not obs:
        return None, None, 0
    mejor = None
    quien = None
    for o in obs:
        z = zmin_real(o)
        if mejor is None or z < mejor:
            mejor = z
            quien = o.name
    return round(mejor, 4), quien, len(obs)


def main():
    if MODULO:
        patron = os.path.join(RAIZ, MODULO, '*.blend')
    else:
        patron = os.path.join(RAIZ, '*', '*.blend')
    archivos = sorted(glob.glob(patron))
    # los .blend1 son respaldos de Blender, no assets
    archivos = [a for a in archivos if not a.endswith('.blend1')]

    if not archivos:
        print('No se encontraron .blend en', patron)
        return 2

    print('Auditando %d archivos | Z_APOYO=%.3f tolerancia=%.3f'
          % (len(archivos), Z_APOYO, TOLERANCIA))
    print('-' * 96)
    print('%-34s %8s %-28s %5s  %s' % ('ARCHIVO', 'z_min', 'OBJETO MAS BAJO', 'n', 'ESTADO'))
    print('-' * 96)

    filas = []
    for a in archivos:
        try:
            bpy.ops.wm.open_mainfile(filepath=a)
        except Exception as e:
            print('%-34s ERROR AL ABRIR: %s' % (os.path.basename(a), str(e)[:60]))
            filas.append({'archivo': a, 'estado': 'ERROR_ABRIR'})
            continue
        bpy.context.view_layer.update()
        z, quien, n = z_min_global()
        modulo = os.path.basename(os.path.dirname(a))
        nombre = '%s/%s' % (modulo, os.path.basename(a))
        if z is None:
            print('%-34s %8s %-28s %5d  %s' % (nombre[:34], '-', '-', 0, 'SIN_SM_'))
            filas.append({'archivo': nombre, 'z_min': None, 'estado': 'SIN_SM_', 'n': 0})
            continue
        if z > Z_APOYO + TOLERANCIA:
            estado = 'FLOTA'
        elif z < Z_APOYO - TOLERANCIA:
            estado = 'HUNDIDO'
        else:
            estado = 'ok'
        print('%-34s %8.4f %-28s %5d  %s' % (nombre[:34], z, (quien or '')[:28], n, estado))
        if DETALLE and (estado != 'ok' or LISTAR):
            # Que pieza exacta rompe el apoyo: imprescindible para corregir el
            # script crear_* en vez de mover el asset entero a ciegas.
            for o in sorted(
                    [x for x in bpy.data.objects
                     if x.type == 'MESH' and x.name.startswith('SM_')],
                    key=zmin_real):
                zo = zmin_real(o)
                marca = '  <<<' if abs(zo - z) < 1e-6 else ''
                print('        %-46s z_min=%8.4f%s'
                      % (o.name[:46], zo, marca))
        filas.append({'archivo': nombre, 'z_min': z, 'objeto': quien,
                      'n': n, 'estado': estado})

    print('-' * 96)
    malos = [f for f in filas if f['estado'] in ('FLOTA', 'HUNDIDO')]
    sin_sm = [f for f in filas if f['estado'] == 'SIN_SM_']
    err = [f for f in filas if f['estado'] == 'ERROR_ABRIR']
    ok = [f for f in filas if f['estado'] == 'ok']

    print('TOTAL %d | ok %d | FLOTA/HUNDIDO %d | sin SM_ %d | error %d'
          % (len(filas), len(ok), len(malos), len(sin_sm), len(err)))
    if malos:
        print('')
        print('>>> REQUIEREN CORRECCION:')
        for f in malos:
            print('    %-8s %-46s z_min=%.4f (%s)'
                  % (f['estado'], f['archivo'], f['z_min'], f.get('objeto')))

    if SALIDA:
        with open(SALIDA, 'w', encoding='utf-8') as fh:
            fh.write('# Auditoria de flotado — %s\n\n' % (MODULO or 'todos los modulos'))
            fh.write('Z_APOYO=%.3f tolerancia=%.3f\n\n' % (Z_APOYO, TOLERANCIA))
            fh.write('| Archivo | z_min | Objeto mas bajo | n | Estado |\n')
            fh.write('|---|---|---|---|---|\n')
            for f in filas:
                fh.write('| %s | %s | %s | %s | %s |\n'
                         % (f['archivo'], f.get('z_min'), f.get('objeto'),
                            f.get('n'), f['estado']))
        print('')
        print('Reporte escrito en', SALIDA)

    return 1 if (malos or err) else 0


if __name__ == '__main__':
    sys.exit(main())
