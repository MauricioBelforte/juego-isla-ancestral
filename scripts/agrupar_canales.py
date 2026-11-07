# -*- coding: utf-8 -*-
"""AGRUPADOR ESTANDAR DE CANALES — metodologia definitiva del proyecto (fundador 23oct 05:45)

uso:  python -X utf8 scripts/agrupar_canales.py --dry-run        (simulacion, no mueve nada)
      python -X utf8 scripts/agrupar_canales.py                  (TODOS los canales)
      python -X utf8 scripts/agrupar_canales.py "Mensajes entre modelos/<canal>"

Regla (orden del fundador): una CENTENA COMPLETA (100 mensajes de un mismo rango
0001-0100, 0101-0200...) se ARCHIVA a subcarpeta arch_XXXX-XXXX/.
En la RAIZ del canal queda SIEMPRE la CENTENA EN CURSO (los mensajes de la centena
actual, aunque no este completa), NUMEROS_DISPONIBLES.txt y los punteros.

Idempotente: correrlo N veces no re-mueve nada. Tolerante a fantasmas NTFS
(archivos con ruta >260 chars se saltan con aviso y quedan documentados).

v2 (2026-11-05, DS-V4.1-Flash-Opencode, GO agnes-3-flash msg 246):
  - lp(): prefija \\\\?\\ en Windows para operar sobre rutas > 260 chars.
  - --dry-run: informa que moveria, sin tocar nada.
  - makedirs antes del rename: la v1 asumia que arch_XXXX-XXXX ya existia y
    fallaba con ENOENT en todo canal nuevo.
  - Se conserva el patron de 3 digitos a proposito: evita tratar como mensaje
    un archivo con nombre de fecha (Hy3/2026-10-29.md).
  - v2.1: el maximo se calcula con os.walk RECURSIVO (raiz + archivos). En
    agnes-3-flash la raiz tenia 001-076 y los archivos llegaban a 991, asi que
    la v2.0 creia que la centena en curso era 001-100 y dejaba 74 mensajes
    viejos en la raiz. Detectado en la verificacion post-ejecucion.
"""
import os
import re
import sys

BASE = 'Mensajes entre modelos'


def lp(path):
    """Prefija \\\\?\\ en Windows para que las rutas > 260 chars sean operables."""
    if os.name != 'nt':
        return path
    p = os.path.abspath(path)
    if p.startswith('\\\\?\\'):
        return p
    return '\\\\?\\' + p


def max_recursivo(cpath):
    """Maximo NN- en TODO el canal (raiz + arch_XXXX-XXXX), con long-path.

    La v2.0 calculaba el maximo solo en la raiz. En un canal cuyos mensajes
    recientes ya estan archivados (agnes-3-flash: raiz 001-076, archivos hasta
    991) eso hacia creer que la centena en curso era 001-100 y dejaba los
    mensajes viejos en la raiz para siempre. Medido post-ejecucion 2026-11-06.
    """
    mx = 0
    for raiz, _dirs, files in os.walk(lp(cpath)):
        for f in files:
            m = re.match(r'(\d{3})-', f)
            if m and f.endswith('.md'):
                mx = max(mx, int(m.group(1)))
    return mx


def listar_mensajes(cpath):
    """Devuelve [(num, nombre)] de los mensajes NN- del nivel raiz del canal."""
    items = []
    try:
        entradas = os.scandir(lp(cpath))
    except OSError as ex:
        print('  [SKIP canal] %s: %s' % (cpath, ex))
        return items
    with entradas:
        for e in entradas:
            m = re.match(r'(\d{3})-', e.name)
            if not (e.name.endswith('.md') and m):
                continue
            try:
                if not e.is_file():
                    continue
            except OSError as ex:
                print('  [SKIP fantasma NTFS] %s: %s' % (e.name, ex))
                continue
            items.append((int(m.group(1)), e.name))
    items.sort()
    return items


def procesar_canal(cpath, dry_run=False):
    canal = os.path.basename(cpath)
    if canal.startswith('arch_'):
        return 0, 0

    items = listar_mensajes(cpath)
    if not items:
        return 0, 0

    max_num = max_recursivo(cpath)
    if max_num == 0:
        return 0, 0
    centena_curso_lo = (max_num // 100) * 100 + 1

    movidos, subdirs, skips = 0, set(), 0
    for num, name in items:
        if num >= centena_curso_lo:
            continue  # centena en curso: queda en raiz
        lo = ((num - 1) // 100) * 100 + 1
        dname = 'arch_%04d-%04d' % (lo, lo + 99)
        dpath = os.path.join(cpath, dname)
        src = os.path.join(cpath, name)
        dst = os.path.join(dpath, name)
        if dry_run:
            movidos += 1
            subdirs.add(dname)
            continue
        try:
            os.makedirs(lp(dpath), exist_ok=True)
            os.rename(lp(src), lp(dst))
            movidos += 1
            subdirs.add(dname)
        except OSError as ex:
            skips += 1
            print('  [SKIP] %s: %s' % (name, ex))

    etiqueta = 'DRY-RUN' if dry_run else 'ejecutado'
    print('  [%s] %s: total=%d | %s=%d a %d subcarpeta(s) | skips=%d | raiz queda con la centena en curso (>=%d)'
          % (canal, etiqueta, len(items), 'moveria' if dry_run else 'movidos',
             movidos, len(subdirs), skips, centena_curso_lo))
    return movidos, len(subdirs)


def main():
    args = [a for a in sys.argv[1:] if a != '--dry-run']
    dry_run = '--dry-run' in sys.argv
    target = args[0] if args else None

    total_m, total_s = 0, 0
    if target:
        r = procesar_canal(target, dry_run)
        total_m += r[0]
        total_s += r[1]
    else:
        for canal in sorted(os.listdir(lp(BASE))):
            cpath = os.path.join(BASE, canal)
            if not os.path.isdir(lp(cpath)) or canal.startswith('arch_'):
                continue
            r = procesar_canal(cpath, dry_run)
            total_m += r[0]
            total_s += r[1]
    print('TOTAL %s: %d | subcarpetas: %d — idempotente, correr de nuevo es seguro'
          % ('que se moverian' if dry_run else 'movidos', total_m, total_s))


if __name__ == '__main__':
    main()
