#!/usr/bin/env python3
"""
auditar_optimizacion.py — M166 · Audita el estado de optimización de los assets.

Motivo (directiva del usuario 2026-08-28):
    "si lo optimizamos no vamos a dejar los objetos sin optimizar solo para
    que ocupen recursos".

    El merge por material es OBLIGATORIO para todo asset aprobado:
      - el .blend SOURCE (33 objetos, editable) es el archivo de AUTORIA,
        nunca se exporta al juego;
      - el .blend MERGEADO (_media, 6 objetos) es el que se EXPORTA.
    Ninguna versión sin mergear debería llegar a Godot.

    Este script escanea los módulos y dice qué assets ya tienen su versión
    mergeada y cuáles no. NO necesita Blender: trabaja sobre el filesystem.

Uso:
    python auditar_optimizacion.py             # reporte completo
    python auditar_optimizacion.py --falta     # solo los que faltan

Códigos de salida:
    0  todos los assets tienen su versión mergeada
    1  hay assets sin mergear (no deberían exportarse todavía)
"""
import os
import sys

RAIZ = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
DIR_BLENDER = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp')

# Sufijos de variantes derivadas. Un .blend con estos sufijos NO es source.
SUFIJOS_VARIANTE = ('_media', '_baja', '_alta')


def es_source(nombre):
    """Un .blend es source si no termina en sufijo de variante."""
    if not nombre.endswith('.blend'):
        return False
    base = nombre[:-len('.blend')]
    return not any(base.endswith(s) for s in SUFIJOS_VARIANTE)


def recolectar():
    """Devuelve la lista de assets source con el estado de sus variantes."""
    assets = []
    if not os.path.isdir(DIR_BLENDER):
        return assets
    for modulo in sorted(os.listdir(DIR_BLENDER)):
        ruta_mod = os.path.join(DIR_BLENDER, modulo)
        if not os.path.isdir(ruta_mod):
            continue
        try:
            nombres = sorted(os.listdir(ruta_mod))
        except OSError:
            continue
        for nombre in nombres:
            if not es_source(nombre):
                continue
            ruta = os.path.join(ruta_mod, nombre)
            if not os.path.isfile(ruta):
                continue
            base = nombre[:-len('.blend')]
            assets.append({
                'modulo': modulo,
                'base': base,
                'media': os.path.isfile(os.path.join(ruta_mod, base + '_media.blend')),
                'baja': os.path.isfile(os.path.join(ruta_mod, base + '_baja.blend')),
            })
    return assets


def main():
    solo_falta = '--falta' in sys.argv
    assets = recolectar()

    if not assets:
        print('No se encontraron assets .blend en %s' % DIR_BLENDER)
        return 0

    print('=== AUDITORIA DE OPTIMIZACION M166 ===')
    print('')
    print('%-26s %-34s %-8s %-8s' % ('MODULO', 'ASSET', 'MEDIA', 'BAJA'))
    print('-' * 80)

    pendientes = 0
    for a in assets:
        if solo_falta and a['media']:
            continue
        if not a['media']:
            pendientes += 1
        print('%-26s %-34s %-8s %-8s' % (
            a['modulo'][:26],
            a['base'][:34],
            'OK' if a['media'] else 'FALTA',
            'OK' if a['baja'] else '-',
        ))

    con_media = sum(1 for a in assets if a['media'])
    con_baja = sum(1 for a in assets if a['baja'])

    print('')
    print('--- RESUMEN ---')
    print('Assets source (autoria)   : %d' % len(assets))
    print('Con version mergeada      : %d   <- obligatorio para exportar' % con_media)
    print('SIN version mergeada      : %d   <- correr generar_variante.py --media' % pendientes)
    print('Con variante BAJA         : %d   (opcional, solo perfil bajo)' % con_baja)
    print('')
    if pendientes:
        print('Hay %d asset(s) sin optimizar. No exportarlos a Godot todavia.' % pendientes)
        print('Comando:')
        for a in assets:
            if not a['media']:
                print('  python generar_variante.py %s %s --media --baja'
                      % (a['modulo'], a['base']))
        return 1

    print('Todos los assets tienen su version optimizada.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
