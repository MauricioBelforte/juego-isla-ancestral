#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Separa, de los archivos reparados por fix_encoding.py, aquellos cuyo unico
cambio respecto a HEAD es la codificacion.

Criterio: si a la version de HEAD se le aplica la misma reparacion y el
resultado es IDENTICO al archivo actual, entonces el unico cambio fue el
nuestro y se puede commitear sin mezclar trabajo ajeno. Si no coincide, el
archivo llevaba ediciones previas de otro agente y NO se toca.

Uso:
    python scripts/stage_solo_encoding.py            # lista
    python scripts/stage_solo_encoding.py --add      # agrega al indice
"""
import os
import sys
import glob
import subprocess
import importlib.util

spec = importlib.util.spec_from_file_location(
    'fx', os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       'fix_encoding.py'))
fx = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fx)


def norm(b):
    """Unifica CRLF->LF: HEAD puede estar normalizado por .gitattributes y el
    working tree no (o al reves). Sin esto todo parece 'mezclado'."""
    return b.replace(b'\r\n', b'\n')


def head_bytes(rel):
    try:
        return subprocess.check_output(['git', 'show', 'HEAD:' + rel])
    except subprocess.CalledProcessError:
        return None


def main():
    add = '--add' in sys.argv
    puros, mezclados = [], []
    for d in sorted(glob.glob('Obsoletos/encoding-backup-*')):
        for dirpath, _, files in os.walk(d):
            for fn in files:
                full = os.path.join(dirpath, fn)
                rel = os.path.relpath(full, d).replace('\\', '/')
                if not os.path.exists(rel):
                    continue
                h = head_bytes(rel)
                if h is None:
                    mezclados.append((rel, 'sin version en HEAD'))
                    continue
                kind, new, _ = fx.classify(h)
                if new is not None and norm(new) == norm(open(rel, "rb").read()):
                    puros.append(rel)
                else:
                    mezclados.append((rel, 'lleva ediciones de otro agente'))

    print('Cambio PURO de codificacion: %d' % len(puros))
    for r in puros:
        print('  +', r)
    print('')
    print('Mezclados con trabajo ajeno (NO se tocan): %d' % len(mezclados))
    for r, why in mezclados[:25]:
        print('  -', r, '->', why)
    if len(mezclados) > 25:
        print('  ... y %d mas' % (len(mezclados) - 25))

    if add and puros:
        subprocess.check_call(['git', 'add', '--'] + puros)
        print('')
        print('agregados al indice: %d' % len(puros))
    return 0


if __name__ == '__main__':
    sys.exit(main())
