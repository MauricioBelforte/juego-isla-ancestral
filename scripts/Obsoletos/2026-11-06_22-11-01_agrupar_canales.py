# -*- coding: utf-8 -*-
"""AGRUPADOR ESTANDAR DE CANALES — metodologia definitiva del proyecto (fundador 23oct 05:45)
uso:  python -X utf8 scripts/agrupar_canales.py                (TODOS los canales)
      python -X utf8 scripts/agrupar_canales.py "Mensajes entre modelos/<canal>"   (un canal)

Regla (orden del fundador): una CENTENA COMPLETA (100 mensajes de un mismo rango
0001-0100, 0101-0200...) se ARCHIVA a subcarpeta arch_XXXX-XXXX/.
En la RAIZ del canal queda SIEMPRE la CENTENA EN CURSO (los mensajes de la centena
actualAunque no este completa), NUMEROS_DISPONIBLES.txt y los punteros.

Idempotente: correrlo N veces no re-mueve nada.  Tolerante a fantasmas NTFS
(archivos con ruta >260 chars se saltan con aviso y quedan documentados).
"""
import os, re, sys, shutil

BASE = 'Mensajes entre modelos'

def procesar_canal(cpath):
    canal = os.path.basename(cpath)
    if canal.startswith('arch_'):
        return
    items = []
    for e in os.scandir(cpath):
        m = re.match(r'(\d{3})-', e.name)
        if e.name.endswith('.md') and m and e.is_file():
            try:
                e.stat()
                items.append((int(m.group(1)), e.name))
            except OSError:
                print('  [SKIP fantasma NTFS] %s' % e.name)
    items.sort()
    if not items:
        return
    max_num = items[-1][0]
    centena_curso_lo = (max_num // 100) * 100 + 1

    movidos, subdirs, skips = 0, set(), []
    for num, name in items:
        if num >= centena_curso_lo:
            continue  # centena en curso: queda en raiz
        lo = ((num - 1) // 100) * 100 + 1
        dname = 'arch_%04d-%04d' % (lo, lo + 99)
        dpath = os.path.join(cpath, dname)
        src = os.path.join(cpath, name)
        try:
            os.rename(src, os.path.join(dpath, name))
            movidos += 1
            subdirs.add(dname)
        except OSError as ex:
            skips.append(name)
            print('  [SKIP] %s: %s' % (name, ex))

    print('  [%s] total=%d | movidos=%d a %d subcarpeta(s) | skips=%d | raiz queda con la centena en curso' %
          (canal, len(items), movidos, len(subdirs), len(skips)))
    return movidos, len(subdirs)

def main():
    target = sys.argv[1] if len(sys.argv) > 1 else None
    total_m, total_s = 0, 0
    if target:
        r = procesar_canal(target)
        total_m += r[0] if r and r[0] else 0
        total_s += r[1] if r and r[1] else 0
    else:
        for canal in sorted(os.listdir(BASE)):
            cpath = os.path.join(BASE, canal)
            if os.path.isdir(cpath) and not canal.startswith('arch_'):
                r = procesar_canal(cpath)
                total_m += r[0] if r and r[0] else 0
                total_s += r[1] if r and r[1] else 0
    print('TOTAL movidos: %d subcarpetas: %d — idempotente, correr de nuevo es seguro' % (total_m, total_s))

if __name__ == '__main__':
    main()
