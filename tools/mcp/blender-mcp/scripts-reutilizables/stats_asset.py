#!/usr/bin/env python3
"""
stats_asset.py — Mide el coste REAL de un asset en la escena activa de Blender.

Motivo (M166 — Variantes de assets por perfil de rendimiento):
    hay DOS ejes de coste y hay que mirar los dos:
      1. TRIANGULOS  -> define la VARIANTE (ALTA / MEDIA / BAJA). Se ve.
      2. DRAW CALLS  -> define la VIABILIDAD (cantidad de mallas + materiales).
                        No se ve en una captura, se mide en FPS.
    El merge por material baja los draw calls sin tocar los triángulos: es una
    etapa de EXPORTACION, no una variante. Por eso el veredicto se corre con
    la malla ya mergeada.

    Si una ALTA da OK en MEDIA, la pasada artística no agregó suficiente
    detalle (03-Diseno.md §3.3).

Uso:
    python stats_asset.py [prefijo]

    prefijo   Prefijo de los objetos a medir (default 'SM_').

Ejemplo:
    python stats_asset.py SM_Cofre_
    python stats_asset.py            # todos los SM_*

Salida:
    objetos, triángulos, vértices, materiales usados, y el desglose por
    objeto ordenado de mayor a menor. También imprime el VEREDICTO contra
    el presupuesto de M166 (objetos <= 8 para perfil MEDIO).
"""
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

# Presupuestos de M166 (ver 02-Analisis.md §8).
# Ojo: la variante la define el NIVEL DE DETALLE (triángulos), no el merge.
# El merge es una etapa de exportación que se aplica a las 3 variantes, así
# que el límite de objetos se mide DESPUÉS del merge.
# Una ALTA que dé OK en MEDIA significa que la pasada artística no agregó
# suficiente detalle (03-Diseno.md §3.3).
PRESUPUESTO = {
    'ALTA':  {'objetos': 16, 'tris': 6000, 'materiales': 12},
    'MEDIA': {'objetos': 8,  'tris': 1500, 'materiales': 8},
    'BAJA':  {'objetos': 6,  'tris': 700,  'materiales': 4},
}


def medir(prefijo='SM_'):
    """Mide el asset de la escena activa y devuelve el dict de datos.

    Reutilizable: la expone para que `verificar_visual.py` la llame sin
    tener que pasar por `sys.argv` ni por subprocess.
    Devuelve None si hubo error (ya impreso).
    """
    code = """
import bpy, json
PREFIJO = @@PREF@@
escena = bpy.context.scene
obs = [o for o in escena.objects if o.type == 'MESH' and o.name.startswith(PREFIJO)]
if not obs:
    print(json.dumps({'error': 'sin objetos con prefijo ' + PREFIJO}))
else:
    tris = verts = 0
    mats = set()
    filas = []
    for o in sorted(obs, key=lambda x: -len(x.data.polygons)):
        me = o.data
        tris += len(me.polygons)
        verts += len(me.vertices)
        for m in me.materials:
            if m is not None:
                mats.add(m.name)
        filas.append([o.name, len(me.polygons), len(me.vertices), len(me.materials)])
    print(json.dumps({
        'objetos': len(obs),
        'tris': tris,
        'verts': verts,
        'materiales': sorted(mats),
        'filas': filas,
    }))
"""
    code = code.replace('@@PREF@@', repr(prefijo))
    r = blender_command('execute_code', {'code': code}, timeout=30)
    if r.get('status') != 'success':
        print('ERROR:', json.dumps(r, ensure_ascii=False)[:600])
        return None

    salida = r.get('result', {}).get('result', '').strip()
    try:
        datos = json.loads(salida)
    except Exception:
        print(salida)
        return None

    if 'error' in datos:
        print(datos['error'])
        return None

    return datos


def main():
    prefijo = sys.argv[1] if len(sys.argv) > 1 else 'SM_'
    datos = medir(prefijo)
    if datos is None:
        sys.exit(1)

    print('=== COSTE DEL ASSET (prefijo %r) ===' % prefijo)
    print('Objetos / draw calls : %d' % datos['objetos'])
    print('Triangulos           : %d' % datos['tris'])
    print('Vertices             : %d' % datos['verts'])
    print('Materiales usados    : %d -> %s' % (len(datos['materiales']),
                                               ', '.join(datos['materiales'])))
    print('')
    for nombre, t, v, m in datos['filas']:
        print('  %-30s tris=%-5d verts=%-5d mats=%d' % (nombre, t, v, m))

    print('')
    print('--- Verdicto contra presupuesto M166 ---')
    for perfil, p in PRESUPUESTO.items():
        ok_obj = datos['objetos'] <= p['objetos']
        ok_tri = datos['tris'] <= p['tris']
        ok_mat = len(datos['materiales']) <= p['materiales']
        estado = 'OK ' if (ok_obj and ok_tri and ok_mat) else 'NO '
        print('%s %-6s obj %3d/%-3d  tris %5d/%-5d  mats %d/%d'
              % (estado, perfil, datos['objetos'], p['objetos'],
                 datos['tris'], p['tris'],
                 len(datos['materiales']), p['materiales']))


if __name__ == '__main__':
    main()
