#!/usr/bin/env python3
"""
qa_variantes.py — QA completo de un módulo: abre cada variante, mide y captura.

Motivo (M166 + E-13): después de `procesar_lote.py` hay que verificar que las
variantes MEDIA y BAJA no rompieron nada. Este script hace el circuito entero
por asset: abrir -> medir (stats_asset) -> capturar 6 angulos orbitales.
Después queda la revisión VISUAL de los contact sheets (no automatizable).

Uso:
    python qa_variantes.py <modulo> [--solo media] [--solo baja] [--angulos 6]

El JSON de assets se define en ASSETS (prefijo -> nombre base del .blend).
Por ahora está cargado el módulo 13-Herramientas; agregar los demás acá.

Ejemplo:
    python qa_variantes.py 13-Herramientas
"""
import sys
import os
import subprocess
import datetime

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ_MOD = os.path.abspath(os.path.join(AQUI, '..'))
PY = sys.executable

# prefijo SM_ -> nombre base del .blend (sin _media / _baja)
ASSETS = {
    '13-Herramientas': [
        ('SM_Antorcha_',   'antorcha_mano_lowpoly'),
        ('SM_PicoHierro_', 'pico_hierro_lowpoly'),
        ('SM_PicoPiedra_', 'pico_piedra_lowpoly'),
    ],
}

VARIANTES = ('media', 'baja')


def correr(args, etiqueta):
    """Corre un subprocess y devuelve (ok, salida)."""
    r = subprocess.run([PY] + args, capture_output=True, text=True,
                       encoding='utf-8', errors='replace')
    salida = (r.stdout or '') + (r.stderr or '')
    if r.returncode != 0:
        print('  !! FALLO %s (exit %d)' % (etiqueta, r.returncode))
        print('     ' + salida.strip().replace('\n', '\n     ')[:800])
        return False, salida
    return True, salida


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    modulo = sys.argv[1]
    solo = None
    if '--solo' in sys.argv:
        solo = sys.argv[sys.argv.index('--solo') + 1]
    angulos = '6'
    if '--angulos' in sys.argv:
        angulos = sys.argv[sys.argv.index('--angulos') + 1]

    if modulo not in ASSETS:
        print('Módulo no cargado en ASSETS: %s' % modulo)
        print('Cargados: %s' % ', '.join(ASSETS))
        sys.exit(1)

    marca = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    dir_cap = os.path.join(RAIZ_MOD, modulo, 'capturas')
    os.makedirs(dir_cap, exist_ok=True)

    variantes = (solo,) if solo else VARIANTES
    total = len(ASSETS[modulo]) * len(variantes)
    hechos = 0
    fallos = 0

    for prefijo, base in ASSETS[modulo]:
        for variante in variantes:
            hechos += 1
            nombre = '%s_%s' % (base, variante)
            print('\n[%d/%d] %s' % (hechos, total, nombre))

            ok, _ = correr([os.path.join(AQUI, 'abrir_blend.py'), modulo, nombre],
                           'abrir ' + nombre)
            if not ok:
                fallos += 1
                continue

            print('  --- stats ---')
            ok, salida = correr([os.path.join(AQUI, 'stats_asset.py'), prefijo],
                                'stats ' + nombre)
            if ok:
                for linea in salida.strip().split('\n'):
                    print('  ' + linea)
            else:
                fallos += 1
                continue

            ruta_png = os.path.join(
                dir_cap, 'cap_13_%s_%s_%s.png' % (base, variante.upper(), marca))
            print('  --- capturas ---')
            ok, salida = correr(
                [os.path.join(AQUI, 'capturar_angulos.py'), prefijo,
                 ruta_png, angulos],
                'capturar ' + nombre)
            if ok:
                for linea in salida.strip().split('\n'):
                    if linea.startswith(('OK  ', 'FALLO ')):
                        print('  ' + linea)
            else:
                fallos += 1

    print('\n--- RESULTADO QA ---')
    print('Procesados : %d' % total)
    print('Fallidos   : %d' % fallos)
    print('Marca      : %s' % marca)
    print('Siguiente paso: generar contact sheets y revisarlos a ojo.')


if __name__ == '__main__':
    main()
