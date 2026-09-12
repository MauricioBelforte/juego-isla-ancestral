#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Verificador ESTRICTO de mojibake UTF-8 -> cp1252 en el repo.

Responsabilidad: SOLO diagnosticar/verificar. El que repara es
scripts/fix_encoding.py. Separados a proposito: si una sola herramienta
detecta y repara, un falso positivo en la deteccion se convierte en una
escritura destructiva silenciosa.

Que es el mojibake: bytes UTF-8 (p. ej. C3 BA = 'u con acento') fueron leidos
como Latin-1/cp1252 y re-grabados como UTF-8. El resultado es un ARCHIVO
corrupto, no un problema de visualizacion: cualquier busqueda por la palabra
acentuada falla.

Patron ESTRICTO (a diferencia del detector laxo de fix_encoding.py, que salta
con la sola presencia de 'a' con acento circunflejo y por eso marca como
corruptos archivos de localizacion en portugues que estan perfectos): aqui se
exige que el caracter sospechoso vaya SEGUIDO de su byte de continuacion.

Categorias:
  SUCIO        marcadores reales -> hay que reparar
  IRREVERSIBLE contiene U+FFFD (una conversion previa uso errors='replace';
               los bytes originales ya no existen, solo re-escribiendo a mano)
  EXCLUIDO     mojibake INTENCIONAL (AGENTS.md documenta el sintoma en su
               seccion de codificacion) o archivo/archivo de respaldo

IMPORTANTE: todo el patron va en escapes Unicode. Si se escribieran los
caracteres literales, este archivo seria el primer archivo corrupto (ya paso
una vez y el propio scanner se autodetecto).

Uso:
    python scripts/diagnosticar_mojibake.py
    echo $?   # 0 = limpio, 1 = queda mojibake
"""
import os
import re
import sys
import io

PAT = re.compile(
    '\u00c3[\u0080-\u00bf]'      # A-tilde + 0x80..0xBF
    '|\u00c2[\u00a0-\u00bf]'     # A-circunflejo + 0xA0..0xBF
    '|\u00e2\u20ac'              # prefijo de raya/comillas tipograficas
    '|\u00e2[\u0080-\u0093]'     # prefijo de flechas y comillas bajas
    '|\u00f0'                    # prefijo de emoji
    '|\ufffd'                    # caracter de reemplazo
)

FFFD = '\ufffd'

# AGENTS.md documenta el sintoma con ejemplos: "repararlo" destruiria la guia.
# Literales mojibake INTENCIONALES: tablas de busqueda/reemplazo de los
# reparadores y la guia que documenta el sintoma. "Repararlos" los romperia.
EXCLUIDOS_ARCH = ('./AGENTS.md', './scripts/verify_final.py',
                  './scripts/fix_coordinacion.py', './scripts/fix_emoji3.py',
                  './scripts/fix_emoji2.py', './scripts/fix_encoding.py')
EXCLUIDOS_DIR = ('./Obsoletos', './scripts/backups', './out',
                 './.workbuddy-ai', './.git', './node_modules', './.godot',
                 './addons', './bin', './Logs')
EXCLUIDOS_SUELTOS = ('.venv',)   # dependencias de terceros, fuera de alcance

EXT = ('.md', '.gd', '.txt', '.json', '.cfg', '.py')


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


def main():
    os.chdir(raiz_repo())
    cats = {'SUCIO': [], 'IRREVERSIBLE': [], 'EXCLUIDO': []}

    for dirpath, dirnames, filenames in os.walk('.'):
        dirnames[:] = [d for d in dirnames
                       if d not in ('bin', '.git', '__pycache__')]
        for fn in filenames:
            if not fn.endswith(EXT):
                continue
            p = os.path.join(dirpath, fn).replace('\\', '/')
            try:
                raw = open(p, 'rb').read()
            except OSError:
                continue
            if b'\x00' in raw:
                continue
            try:
                s = raw.decode('utf-8')
            except UnicodeDecodeError:
                continue
            if not PAT.search(s):
                continue
            if (p in EXCLUIDOS_ARCH
                    or p.startswith(tuple(d + '/' for d in EXCLUIDOS_DIR))
                    or p.startswith(tuple(d[2:] for d in EXCLUIDOS_DIR))
                    or any('/' + s + '/' in '/' + p for s in EXCLUIDOS_SUELTOS)):
                cats['EXCLUIDO'].append((p, len(PAT.findall(s))))
            elif FFFD in s:
                cats['IRREVERSIBLE'].append((p, len(PAT.findall(s))))
            else:
                cats['SUCIO'].append((p, len(PAT.findall(s))))

    for c in cats:
        cats[c].sort(key=lambda x: -x[1])
    tot = sum(len(v) for v in cats.values())
    print('=== Verificador de mojibake ===')
    print('Archivos con marcadores: %d' % tot)
    for c in ('SUCIO', 'IRREVERSIBLE', 'EXCLUIDO'):
        print('  %-13s %3d' % (c, len(cats[c])))
    print('')
    for c in ('SUCIO', 'IRREVERSIBLE'):
        if not cats[c]:
            continue
        print('--- %s (%d) ---' % (c, len(cats[c])))
        for p, n in cats[c][:30]:
            print('  %6d  %s' % (n, p))
        if len(cats[c]) > 30:
            print('  ... y %d mas' % (len(cats[c]) - 30))
        print('')

    if cats['SUCIO']:
        print('ACCION: correr  python scripts/fix_encoding.py')
        return 1
    print('LIMPIO: no queda mojibake reparable.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
