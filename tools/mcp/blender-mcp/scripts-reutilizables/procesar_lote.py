#!/usr/bin/env python3
"""
procesar_lote.py — M166 · Procesa en lote todos los assets pendientes.

Motivo (directiva del usuario 2026-08-28):
    "ahora te pido que crees las 2 versiones de cada objeto".
    En vez de correr `generar_variante.py` 80 veces a mano, este script
    recorre los modulos y genera las variantes de todos los assets que
    figuren como pendientes en `auditar_optimizacion.py`.

Uso:
    python procesar_lote.py                      # todos, --media y --baja
    python procesar_lote.py --media              # solo la version mergeada
    python procesar_lote.py 15-Recursos          # solo ese modulo
    python procesar_lote.py 15-Recursos --media  # combinado

Notas:
    - Solo procesa assets que NO tengan ya su version mergeada (idempotente:
      se puede re-correr y saltea los que estan listos).
    - Requiere Blender abierto con el addon escuchando en 127.0.0.1:9876.
    - El merge (--media) es LOSSLESS: la geometria es identica, solo bajan
      los draw calls. El decimate (--baja) SI cambia la geometria y por tanto
      requiere QA visual de las 6 capturas orbitales (E-13) antes de exportar.
"""
import sys
import os
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from auditar_optimizacion import recolectar
from generar_variante import generar


def main():
    modulos = [a for a in sys.argv[1:] if not a.startswith('--')]
    modos = [a.lstrip('-') for a in sys.argv[1:]
             if a.startswith('--') and a.lstrip('-') in ('media', 'baja')]
    if not modos:
        modos = ['media', 'baja']

    todos = recolectar()
    if modulos:
        todos = [a for a in todos if a['modulo'] in modulos]

    pendientes = [a for a in todos if not a['media']]

    if not pendientes:
        print('No hay assets pendientes%s.' % (' en ' + ', '.join(modulos) if modulos else ''))
        return 0

    print('=== PROCESANDO LOTE M166 ===')
    print('Modos           : %s' % ', '.join(modos))
    print('Assets(total)   : %d' % len(todos))
    print('Pendientes      : %d' % len(pendientes))
    print('')

    ok = []
    fallo = []
    t0 = time.time()

    for i, a in enumerate(pendientes, 1):
        etiqueta = '%s/%s' % (a['modulo'], a['base'])
        print('[%2d/%d] %s' % (i, len(pendientes), etiqueta))
        bien = True
        for modo in modos:
            try:
                if not generar(a['modulo'], a['base'], modo):
                    bien = False
                    print('   FALLO en modo %s' % modo)
            except Exception as e:
                bien = False
                print('   EXCEPCION en modo %s: %s' % (modo, e))
        (ok if bien else fallo).append(etiqueta)

    print('')
    print('--- RESULTADO ---')
    print('Exitosos : %d' % len(ok))
    print('Fallidos : %d' % len(fallo))
    for f in fallo:
        print('  FALLO: %s' % f)
    print('Tiempo   : %.1f s' % (time.time() - t0))
    print('')
    print('Siguiente paso: python auditar_optimizacion.py')
    return 1 if fallo else 0


if __name__ == '__main__':
    sys.exit(main())
