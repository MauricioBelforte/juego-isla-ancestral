#!/usr/bin/env python3
"""
auditar_stats.py — M166 · Volcado numérico de TODAS las variantes (sin imágenes).

Motivo: en una sesión sin visión (el modelo no lee JPG), la puerta NUMÉRICA sí
es verificable. Este script abre cada variante y vuelca objetos / triángulos /
materiales / z_min a un .txt plano, para dejar tabulado lo que se puede validar
sin ojos. No genera capturas ni hojas.

Uso:
    python auditar_stats.py                      # todas las variantes
    python auditar_stats.py 13-Herramientas      # un módulo
    python auditar_stats.py --out stats_lote.txt # archivo de salida (default en Logs)

Salida: tabla + resumen de presupuesto (ALTA/MEDIA/BAJA) y apoyo.
"""
import os
import sys
import time

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)

from auditar_optimizacion import recolectar
import verificar_visual

Z_APOYO = 0.045
PRESUPUESTO = verificar_visual.PRESUPUESTO


def ok_presupuesto(datos):
    """Devuelve la lista de perfiles cumplidos."""
    res = []
    for perfil, p in PRESUPUESTO.items():
        if (datos['objetos'] <= p['objetos']
                and datos['tris'] <= p['tris']
                and len(datos['materiales']) <= p['materiales']):
            res.append(perfil)
    return res


def main():
    args = sys.argv[1:]
    modulos = []
    out = 'stats_lote.txt'
    i = 0
    while i < len(args):
        if args[i] == '--out':
            out = args[i + 1]
            i += 2
            continue
        if not args[i].startswith('--'):
            modulos.append(args[i])
        i += 1

    assets = recolectar()
    if modulos:
        assets = [a for a in assets if a['modulo'] in modulos]

    variantes = ('media', 'baja')
    total = len(assets) * len(variantes)
    hechos = 0
    fallidos = []
    filas = []
    t0 = time.time()

    for a in assets:
        for variante in variantes:
            hechos += 1
            blend = '%s_%s' % (a['base'], variante)
            try:
                verificar_visual.abrir(a['modulo'], blend)
                datos = verificar_visual.medir('SM_')
                apoyo = verificar_visual.medir_apoyo('SM_')
                zmin = apoyo.get('z_min') if apoyo else None
                if zmin is not None:
                    delta = zmin - Z_APOYO
                    if delta > 0.020:
                        apoyo_v = 'FLOTA %.3f' % delta
                    elif delta < -0.020:
                        apoyo_v = 'HUNDIDO %.3f' % abs(delta)
                    else:
                        apoyo_v = 'OK'
                else:
                    apoyo_v = '?'
                cumplidos = '/'.join(ok_presupuesto(datos))
                filas.append('%s\t%s\tobj=%d\ttris=%d\tmats=%d\tz_min=%.4f\t%s\t%s'
                             % (a['modulo'], blend, datos['objetos'], datos['tris'],
                                len(datos['materiales']), zmin if zmin is not None else -1,
                                apoyo_v, cumplidos))
                print('  OK  %s/%s' % (a['modulo'], blend))
            except Exception as e:
                fallidos.append('%s/%s' % (a['modulo'], blend))
                print('  !! %s/%s : %s' % (a['modulo'], blend, e))

    out_path = out
    if not os.path.isabs(out_path):
        out_path = os.path.join(
            os.path.abspath(os.path.join(AQUI, '..', '..', '..', '..')), 'Logs', out)
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write('# M166 · Volcado numérico de variantes (sin imágenes)\n')
        f.write('# Generado: %s\n'
                % time.strftime('%Y-%m-%d %H:%M:%S'))
        f.write('# Perfiles: ALTA <=16/6000/12 · MEDIA <=8/1500/8 · BAJA <=6/700/4\n')
        f.write('# Apoyo objetivo z_min=0.045 (rango 0.025..0.065)\n')
        f.write('# modulo\tvariante\tobj\ttris\tmats\tz_min\tapoyo\tcumple\n')
        f.write('\n'.join(filas) + '\n')
        f.write('\n# RESUMEN: %d variantes, %d fallidas\n'
                % (total, len(fallidos)))
        for fal in fallidos:
            f.write('#  - %s\n' % fal)

    print('')
    print('Escrito: %s' % out_path)
    print('Tiempo: %.1f s' % (time.time() - t0))


if __name__ == '__main__':
    main()
