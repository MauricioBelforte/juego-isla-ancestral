#!/usr/bin/env python3
"""
qa_lote.py — M166 · QA visual de todos los assets de un modulo (o de todos).

Motivo: `verificar_visual.py` hace el circuito de UNA variante (abrir -> medir ->
z_min -> 6 capturas -> hoja de contacto). Con 41 assets x 2 variantes = 82
corridas, lanzarlas a mano no escala. Este script recorre el catalogo con
`recolectar()` (el mismo que usa `auditar_optimizacion.py`) y encadena las
corridas, sin depender de Blender mas que para el socket.

Uso:
    python qa_lote.py                          # todos los modulos
    python qa_lote.py 15-Recursos              # un modulo
    python qa_lote.py 16-Crafting 45-Arte3D    # varios
    python qa_lote.py --variante baja          # solo un perfil (default: media+baja)
    python qa_lote.py --angulos 8              # mas tomas orbitales (default 6)

Notas:
- Usa prefijo generico `SM_`: cada .blend contiene un solo asset, asi que
  encuadra todo lo exportable. Con prefijos especificos (SM_Antorcha_) se
  pueden contar piezas que el generico no ve (ver log 228).
- Si una variante falla, NO aborta: la anota y sigue con la siguiente.
- Imprime un resumen final al estilo de los demas scripts de M166.
"""
import os
import sys
import time

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)

from auditar_optimizacion import recolectar
import verificar_visual


def main():
    args = sys.argv[1:]

    modulos = [a for a in args if not a.startswith('--')]
    variantes = ('media', 'baja')
    if '--variante' in args:
        variantes = (args[args.index('--variante') + 1],)
    angulos = '6'
    if '--angulos' in args:
        angulos = args[args.index('--angulos') + 1]

    assets = recolectar()
    if modulos:
        assets = [a for a in assets if a['modulo'] in modulos]
    if not assets:
        print('Nada que procesar con esos filtros.')
        return 1

    total = len(assets) * len(variantes)
    hechos = 0
    fallidos = []
    t0 = time.time()

    print('=' * 68)
    print('QA VISUAL POR LOTE · %d assets x %d variantes = %d corridas'
          % (len(assets), len(variantes), total))
    print('Modulos: %s' % ', '.join(sorted({a['modulo'] for a in assets})))
    print('=' * 68)

    for a in assets:
        for variante in variantes:
            hechos += 1
            blend = '%s_%s' % (a['base'], variante)
            print('')
            print('>>> [%d/%d] %s / %s'
                  % (hechos, total, a['modulo'], blend))
            argv_orig = sys.argv[:]
            sys.argv = ['verificar_visual.py', a['modulo'], blend,
                        'SM_', angulos]
            try:
                verificar_visual.main()
            except SystemExit as e:
                print('  !! FALLO: %s' % (e.code if e.code else 'aborto'))
                fallidos.append('%s/%s' % (a['modulo'], blend))
            except Exception as e:
                print('  !! EXCEPCION: %s' % e)
                fallidos.append('%s/%s' % (a['modulo'], blend))
            finally:
                sys.argv = argv_orig

    print('')
    print('=' * 68)
    print('--- RESULTADO DEL LOTE ---')
    print('Corridas   : %d' % total)
    print('Fallidas   : %d' % len(fallidos))
    for f in fallidos:
        print('  - %s' % f)
    print('Tiempo     : %.1f s (%.1f min)' % (time.time() - t0,
                                              (time.time() - t0) / 60))
    print('')
    print('Pendiente: revision VISUAL de las hojas de contacto (no automatica).')
    print('=' * 68)
    return 1 if fallidos else 0


if __name__ == '__main__':
    sys.exit(main())
