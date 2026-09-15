#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Verificador/reparador de BOM UTF-8 (AGENTS.md §28: UTF-8 SIN BOM).

Por que existe separado de scripts/fix_encoding.py: este ultimo DETECTA el BOM
(lineas 195-196: hace s = s[1:]) pero despues devuelve ("ok", None) y su
llamador solo reescribe los archivos clasificados cp1252/mojibake (linea 260).
Resultado: el BOM se descarta en memoria y el archivo nunca se toca. Por eso
sobrevivian cientos de BOMs. Mientras ese bug no se corrija, esta es la
herramienta que si reescribe.

Igual que con el mojibake, diagnosticar y reparar estan separados: por defecto
solo informa y sale con codigo 1 si hay BOM. La reparacion exige --fix.

Uso:
    python scripts/verificar_bom.py                  # informar
    python scripts/verificar_bom.py --fix            # quitar BOM
    python scripts/verificar_bom.py --fix Logs       # solo bajo Logs/
    echo $?   # 0 = sin BOM, 1 = habia BOM (antes de --fix)
"""
import os
import sys

BOM = b'\xef\xbb\xbf'
EXT = ('.md', '.gd', '.txt', '.json', '.cfg', '.py', '.tres', '.tscn',
       '.yml', '.yaml', '.po', '.iss', '.godot', '.shader', '.import')
# Respaldos y dependencias: no son texto versionado "vivo", no se tocan.
EXCLUIDOS_DIR = ('.git', 'node_modules', '__pycache__', '.godot', 'bin',
                 'out', 'Obsoletos', 'addons', '.workbuddy-ai')


def raiz_repo():
    d = os.path.dirname(os.path.abspath(__file__))
    for _ in range(10):
        if os.path.isfile(os.path.join(d, 'AGENTS.md')):
            return d
        p = os.path.dirname(d)
        if p == d:
            break
        d = p
    raise SystemExit('No encontre AGENTS.md subiendo desde %s' % __file__)


def escanear(raiz, prefijos):
    hallados = []
    for dirpath, dirnames, filenames in os.walk(raiz):
        dirnames[:] = [d for d in dirnames if d not in EXCLUIDOS_DIR]
        for fn in filenames:
            if not fn.endswith(EXT):
                continue
            p = os.path.join(dirpath, fn)
            rel = os.path.relpath(p, raiz).replace('\\', '/')
            if prefijos and not any(rel.startswith(x) for x in prefijos):
                continue
            try:
                with open(p, 'rb') as fh:
                    inicio = fh.read(3)
            except OSError:
                continue
            if inicio == BOM:
                hallados.append(rel)
    return sorted(hallados)


def main():
    args = [a for a in sys.argv[1:]]
    fix = '--fix' in args
    args = [a for a in args if a != '--fix']
    prefijos = [a.strip('/').replace('\\', '/') for a in args if not a.startswith('-')]

    os.chdir(raiz_repo())
    hallados = escanear('.', prefijos)

    if not hallados:
        print('Sin BOM: ningun archivo empieza con EF BB BF.')
        return 0

    # Recuento por carpeta de primer nivel para dimensionar el problema.
    por_carpeta = {}
    for r in hallados:
        cabeza = r.split('/')[0] if '/' in r else '(raiz)'
        por_carpeta[cabeza] = por_carpeta.get(cabeza, 0) + 1

    print('Archivos con BOM: %d' % len(hallados))
    for k, v in sorted(por_carpeta.items(), key=lambda x: -x[1]):
        print('  %-24s %4d' % (k, v))
    print('')

    if not fix:
        for r in hallados[:40]:
            print('  %s' % r)
        if len(hallados) > 40:
            print('  ... y %d mas' % (len(hallados) - 40))
        print('\nACCION: python scripts/verificar_bom.py --fix [carpeta]')
        return 1

    ok = 0
    for r in hallados:
        try:
            with open(r, 'rb') as fh:
                raw = fh.read()
        except OSError as e:
            print('  [ERR lectura] %s -> %s' % (r, e))
            continue
        if not raw.startswith(BOM):
            continue
        # Se preserva el resto del archivo byte a byte: solo se quitan 3 bytes.
        with open(r, 'wb') as fh:
            fh.write(raw[3:])
        ok += 1
    print('BOM quitado en %d archivo(s).' % ok)
    return 0


if __name__ == '__main__':
    sys.exit(main())
