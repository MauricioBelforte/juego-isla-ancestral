#!/usr/bin/env python3
"""
verificar_visual.py — Circuito completo de QA de una variante en un solo comando.

Motivo: revisar un asset a mano son 4 comandos (abrir_blend, stats_asset,
capturar_angulos, contact_sheet). Con 41 assets x 2 variantes eso no escala.
Este script los encadena y deja todo listo para leer una sola imagen.

Uso:
    python verificar_visual.py <modulo> <blend> [prefijo] [N]

Argumentos:
    modulo    Carpeta del modulo (ej. 13-Herramientas)
    blend     Nombre del .blend sin extension (ej. antorcha_mano_lowpoly_baja)
    prefijo   Prefijo de los SM_* a medir/encuadrar (default SM_)
    N         Cantidad de angulos orbitales (default 6, minimo exigido por E-13)

Ejemplo:
    python verificar_visual.py 13-Herramientas antorcha_mano_lowpoly_baja SM_Antorcha_ 6

Salida:
    1. Stats numericos (objetos / triangulos / materiales) + veredicto M166
    2. z_min del grupo -> detecta flotacion o hundimiento (E-12)
    3. N capturas orbitales en <modulo>/capturas/
    4. Hoja de contacto JPG lista para leer con vision

Despues de ejecutar: LEER la hoja de contacto. Si en ALGUN angulo se ve
luz/aire entre el objeto y la base, el asset no se aprueba (E-13).
"""
import sys
import os
import json
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from bpy_cliente import blender_command
from stats_asset import medir, PRESUPUESTO
from contact_sheet import hoja
import capturar_angulos

RAIZ = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
CARPETA_MCP = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp')

Z_APOYO = 0.045   # cota de la arena; ver E-12


def abrir(modulo, nombre):
    """Abre el .blend en la escena activa."""
    if not nombre.endswith('.blend'):
        nombre += '.blend'
    ruta = os.path.join(CARPETA_MCP, modulo, nombre).replace('\\', '/')
    if not os.path.exists(ruta):
        raise SystemExit('No existe: %s' % ruta)
    code = ('import bpy, os\n'
            'bpy.ops.wm.open_mainfile(filepath="%s")\n'
            'print("abierto:", os.path.basename(bpy.data.filepath))\n' % ruta)
    r = blender_command('execute_code', {'code': code}, timeout=60)
    if r.get('status') != 'success':
        raise SystemExit('ERROR al abrir: %s' % json.dumps(r, ensure_ascii=False)[:400])
    print(r.get('result', {}).get('result', '').strip())


def medir_apoyo(prefijo):
    """Devuelve z_min y alto del grupo. Sirve para detectar flotacion (E-12).

    E-24: mide sobre VERTICES REALES, nunca sobre `bound_box`. Un objeto
    rotado tiene esquinas de AABB vacias que tiran el minimo para abajo y
    producen un falso "HUNDIDO". Caso real (log 303): `roca_comun`
    SM_Roca_Comun_Chica con rot (0.2, -0.2, 1.1) daba bbox_min=-0.1092
    cuando sus vertices reales solo bajan a 0.0450 -> 15 cm de falso hundido.
    """
    code = """
import bpy, json
PREF = @@PREF@@
obs = [o for o in bpy.context.scene.objects
       if o.type == 'MESH' and o.name.startswith(PREF)]
if not obs:
    print(json.dumps({'error': 'sin objetos'}))
else:
    # E-24: vertices reales en coordenadas de mundo.
    zs = [(o.matrix_world @ v.co).z for o in obs for v in o.data.vertices]
    zmin = min(zs)
    zmax = max(zs)
    print(json.dumps({'z_min': round(zmin, 4),
                      'z_max': round(zmax, 4),
                      'alto': round(zmax - zmin, 4)}))
""".replace('@@PREF@@', repr(prefijo))
    r = blender_command('execute_code', {'code': code}, timeout=30)
    if r.get('status') != 'success':
        return None
    try:
        return json.loads(r.get('result', {}).get('result', '').strip())
    except Exception:
        return None


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)

    modulo = sys.argv[1]
    blend = sys.argv[2]
    prefijo = sys.argv[3] if len(sys.argv) > 3 else 'SM_'
    n = int(sys.argv[4]) if len(sys.argv) > 4 else 6

    t0 = time.time()
    stamp = time.strftime('%H-%M-%S')
    base = blend.replace('.blend', '')

    print('=' * 68)
    print('QA VISUAL · %s / %s' % (modulo, base))
    print('=' * 68)

    # 1) Abrir
    abrir(modulo, blend)

    # 2) Stats numericos
    datos = medir(prefijo)
    if datos is None:
        raise SystemExit('No se pudo medir. Aborto.')
    print('')
    print('Objetos / draw calls : %d' % datos['objetos'])
    print('Triangulos           : %d' % datos['tris'])
    print('Materiales           : %d -> %s' % (len(datos['materiales']),
                                               ', '.join(datos['materiales'])))
    print('')
    for perfil, p in PRESUPUESTO.items():
        ok = (datos['objetos'] <= p['objetos'] and datos['tris'] <= p['tris']
              and len(datos['materiales']) <= p['materiales'])
        print('  %s %-6s obj %3d/%-3d  tris %5d/%-5d  mats %d/%d'
              % ('OK ' if ok else 'NO ', perfil, datos['objetos'], p['objetos'],
                 datos['tris'], p['tris'], len(datos['materiales']), p['materiales']))

    # 3) Apoyo
    apoyo = medir_apoyo(prefijo)
    if apoyo and 'z_min' in apoyo:
        delta = apoyo['z_min'] - Z_APOYO
        if delta > 0.020:
            veredicto = 'FLOTA %.3f m' % delta
        elif delta < -0.020:
            veredicto = 'HUNDIDO %.3f m' % abs(delta)
        else:
            veredicto = 'apoyo OK'
        print('')
        print('z_min %.4f  z_max %.4f  alto %.4f  -> %s'
              % (apoyo['z_min'], apoyo['z_max'], apoyo['alto'], veredicto))

    # 4) Capturas orbitales
    dir_cap = os.path.join(CARPETA_MCP, modulo, 'capturas')
    os.makedirs(dir_cap, exist_ok=True)
    ruta_base = os.path.join(dir_cap, 'cap_%s_%s_%s.png'
                             % (modulo.split('-')[0], base, stamp))

    print('')
    print('--- Capturando %d angulos ---' % n)
    argv_orig = sys.argv[:]
    sys.argv = ['capturar_angulos.py', prefijo, ruta_base, str(n)]
    try:
        capturar_angulos.main()
    finally:
        sys.argv = argv_orig

    # 5) Hoja de contacto
    import glob
    raiz, _ = os.path.splitext(ruta_base)
    pngs = sorted(glob.glob(raiz + '_az*.png'))
    if not pngs:
        raise SystemExit('No se generaron capturas. Aborto.')
    salida_jpg = os.path.join(dir_cap, '_hoja_%s.jpg'
                              % os.path.basename(raiz))
    hoja(pngs, salida_jpg)

    print('')
    print('=' * 68)
    print('Tiempo: %.1f s' % (time.time() - t0))
    print('HOJA PARA LEER: %s' % salida_jpg)
    print('=' * 68)


if __name__ == '__main__':
    main()
