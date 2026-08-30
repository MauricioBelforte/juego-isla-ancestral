#!/usr/bin/env python3
"""
auditar_desincronizados.py — M166 · Detecta variantes derivadas mas viejas que su fuente.

Motivo (hallazgo 2026-08-29, log 252 / E-43):
    En la corrida de saneo de presupuesto aparecio un asset exportado con el
    diseno EQUIVOCADO: `palanca_madera_alta.blend` (v2, rechazada por el usuario
    el 2026-08-29 14:13) seguia existiendo mientras su `_lowpoly` v3 (aprobada)
    era de las 22:54. Como ambos sufijos compiten por el mismo destino en Godot,
    y el planificador de `exportar_godot.py` gana por orden de prioridad de
    SUFIJO (E-43, no por mtime), el archivo VIEJO quedo adentro del GLB.

    Causa raiz: cuando se rediseña un asset, la variante derivada (el `_alta`
    regenerado) puede quedar CON EL MISMO mtime que su archivo de autoría viejo,
    o peor, el autor regenera el source pero olvida regenerar el `_alta`. El
    resultado es una variante mas vieja que su fuente: un bug silencioso que el
    render E-13 no siempre detecta (el diseno viejo "se ve bien", solo es el
    equivocado).

    Este script escanea el filesystem y reporta toda variante cuya mtime sea
    MENOR que la de su archivo fuente. NO necesita Blender.

Regla de oro (E-46, deducida de este bug):
    "una variante derivada NUNCA puede ser mas vieja que su fuente. Si lo es,
     se regenera antes de exportar." El cross-check es barato y previene que un
    diseno rechazado llegue a Godot.

Uso:
    python auditar_desincronizados.py           # reporte completo
    python auditar_desincronizados.py --arreglar # regenera los _alta/_media/_baja
                                              # desde el source con generar_variante.py
    python auditar_desincronizados.py --tolerancia 60   # margen en segundos
                                                       # (default 0: cualquier
                                                       # diferencia cuenta)

Codigos de salida:
    0  ninguna variante desincronizada
    1  hay variantes mas viejas que su fuente (regenerar antes de exportar)
"""
import os
import sys
import subprocess

RAIZ = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
DIR_BLENDER = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp')

# Sufijos derivados, en orden de prioridad de destino (E-43).
SUFIJOS_VARIANTE = ('_alta', '_media', '_baja',
                    '_alta_media', '_alta_baja',
                    '_lowpoly', '_lowpoly_media', '_lowpoly_baja')


def mtime(ruta):
    """mtime en segundos (float). None si no existe."""
    if not os.path.isfile(ruta):
        return None
    return os.path.getmtime(ruta)


def encontrar_source(modulo, base):
    """Devuelve la ruta del .blend fuente para un `base` dado.

    El fuente es el .blend que NO lleva sufijo de variante. Buscamos todos los
    .blend del modulo que empiecen con `base` y queden como fuente.
    """
    ruta_mod = os.path.join(DIR_BLENDER, modulo)
    if not os.path.isdir(ruta_mod):
        return None
    # El nombre fuente es exactamente base.blend (sin sufijo).
    fuente = os.path.join(ruta_mod, base + '.blend')
    if os.path.isfile(fuente):
        return fuente
    return None


def recolectar():
    """Devuelve lista de {modulo, base, fuente, variantes:[{sufijo,ruta,m}]}."""
    items = []
    if not os.path.isdir(DIR_BLENDER):
        return items
    for modulo in sorted(os.listdir(DIR_BLENDER)):
        ruta_mod = os.path.join(DIR_BLENDER, modulo)
        if not os.path.isdir(ruta_mod):
            continue
        try:
            nombres = sorted(os.listdir(ruta_mod))
        except OSError:
            continue
        # Agrupar por base (prefijo antes del primer sufijo conocido).
        bases = {}
        for nombre in nombres:
            if not nombre.endswith('.blend'):
                continue
            stem = nombre[:-len('.blend')]
            base = stem
            for s in SUFIJOS_VARIANTE:
                if stem.endswith(s) and stem[: -len(s)]:
                    base = stem[: -len(s)]
                    break
            bases.setdefault(base, []).append(nombre)
        for base, archivos in sorted(bases.items()):
            fuente = os.path.join(ruta_mod, base + '.blend')
            if not os.path.isfile(fuente):
                continue  # no hay fuente: no es un asset de autoría, lo salteamos
            variantes = []
            for nombre in archivos:
                stem = nombre[:-len('.blend')]
                sufijo = ''
                for s in SUFIJOS_VARIANTE:
                    if stem.endswith(s) and stem[: -len(s)] == base:
                        sufijo = s
                        break
                if not sufijo:
                    continue  # es el fuente mismo
                variantes.append({
                    'sufijo': sufijo,
                    'ruta': os.path.join(ruta_mod, nombre),
                    'm': mtime(os.path.join(ruta_mod, nombre)),
                })
            if variantes:
                items.append({
                    'modulo': modulo,
                    'base': base,
                    'fuente': fuente,
                    'fuente_m': mtime(fuente),
                    'variantes': variantes,
                })
    return items


def main():
    arreglar = '--arreglar' in sys.argv
    tol = 0
    for a in sys.argv[1:]:
        if a.startswith('--tolerancia'):
            try:
                tol = int(a.split('=')[1]) if '=' in a else int(sys.argv[sys.argv.index(a) + 1])
            except (ValueError, IndexError):
                pass

    items = recolectar()
    if not items:
        print('No se encontraron assets .blend en %s' % DIR_BLENDER)
        return 0

    print('=== AUDITORIA DE DESINCRONIZACION M166 (E-46) ===')
    print('')
    print('%-26s %-30s %-12s %s' % ('MODULO', 'VARIANTE', 'DELTA(s)', 'ESTADO'))
    print('-' * 84)

    desinc = []
    for it in items:
        fm = it['fuente_m']
        if fm is None:
            continue
        for v in it['variantes']:
            if v['m'] is None:
                continue
            delta = fm - v['m']  # >0: la fuente es MAS nueva que la variante
            if delta > tol:
                desinc.append((it, v, delta))
                print('%-26s %-30s %+12.0f %s' % (
                    it['modulo'][:26],
                    (it['base'] + v['sufijo'])[:30],
                    delta,
                    'DESINCRONIZADA (fuente %d s mas nueva)' % int(delta),
                ))
            else:
                print('%-26s %-30s %+12.0f %s' % (
                    it['modulo'][:26],
                    (it['base'] + v['sufijo'])[:30],
                    delta,
                    'OK',
                ))

    print('')
    print('--- RESUMEN ---')
    print('Assets auditados          : %d' % len(items))
    print('Variantes desincronizadas : %d' % len(desinc))
    if not desinc:
        print('Ninguna variante es mas vieja que su fuente. Pipeline limpio.')
        return 0

    print('')
    print('ATENCION: %d variante(s) mas vieja(s) que su fuente.' % len(desinc))
    print('Regenerar desde el source antes de exportar (E-43 / E-46).')
    if arreglar:
        print('')
        print('Regenerando...')
        for it, v, _ in desinc:
            if v['sufijo'] in ('_alta', '_lowpoly'):
                variantes = '--media --baja'
            elif v['sufijo'] in ('_media', '_lowpoly_media'):
                variantes = '--media'
            elif v['sufijo'] in ('_baja', '_lowpoly_baja'):
                variantes = '--baja'
            else:
                variantes = '--media --baja'
            cmd = 'python generar_variante.py %s %s %s' % (
                it['modulo'], it['base'], variantes)
            print('  $ %s' % cmd)
            try:
                subprocess.run(cmd, shell=True, cwd=DIR_BLENDER, check=False)
            except Exception as e:  # noqa
                print('    ERROR: %s' % e)
        print('Regeneracion completa. Volver a correr sin --arreglar para confirmar.')
    else:
        print('Para regenerarlas automaticamente: python auditar_desincronizados.py --arreglar')
    return 1


if __name__ == '__main__':
    sys.exit(main())
