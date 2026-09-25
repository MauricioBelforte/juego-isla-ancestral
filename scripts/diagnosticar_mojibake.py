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
    echo $?   # 0 = limpio, 1 = queda mojibake (SUCIO)
    python scripts/diagnosticar_mojibake.py --selftest   # 21 casos, 2 direcciones

Codigos de salida: 0 limpio | 1 queda mojibake reparable | 2 uso.
IRREVERSIBLE y EXCLUIDO se informan pero NO bloquean (no son reparables por
herramienta: el primero necesita reescritura a mano, el segundo es intencional).
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

# Una linea puede contener literales corruptos A PROPOSITO: el banner de
# advertencia de los BACKLOG-MASTER, las tablas de busqueda/reemplazo de los
# reparadores, las guias que citan el sintoma. "Repararlas" destruiria la
# documentacion. Se filtran POR CONTENIDO y no por archivo para que siga
# funcionando con backlogs y guias nuevos (Hy4, Log 903).
PAT_LINEA_DOC = re.compile(
    'caracteres rotos'                 # banner de los BACKLOG-MASTER
    '|doble (encoding|codificacion)'   # banner de CHECKLIST-GLOBAL y guias
    '|mojibake'
    '|U\\+00F0|U\\+0178|U\\+FFFD'      # tablas de los reparadores
    '|F0 9F 9F|F0 9F 94|0x94'          # ejemplos de bytes de emoji corruptos
    '|C3 B0|C5 B8|C2 A1|Bytes crudos'  # volcados de bytes en las guias
    '|interpretado como UTF-8'
    , re.IGNORECASE)

# AGENTS.md documenta el sintoma con ejemplos: "repararlo" destruiria la guia.
# Literales mojibake INTENCIONALES: tablas de busqueda/reemplazo de los
# reparadores y la guia que documenta el sintoma. "Repararlos" los romperia.
EXCLUIDOS_ARCH = ('./AGENTS.md', './scripts/verify_final.py',
                  './scripts/fix_coordinacion.py', './scripts/fix_emoji3.py',
                  './scripts/fix_emoji2.py', './scripts/fix_encoding.py',
                  './scripts/fix_emoji.py', './scripts/saneamiento_utf8.py',
                  './scripts/fix_final3.py', './scripts/fix_final4.py',
                  # Script de PRUEBA de atria-dawn-s2 (untracked: no existe en
                  # CI). Contiene literales mojibake A PROPOSITO en su tabla de
                  # deteccion, igual que fix_encoding.py. Medido el 2026-09-24.
                  './DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/scripts-prueba/verificar_cierre.py')
EXCLUIDOS_DIR = ('./Obsoletos', './scripts/backups', './out',
                 './.workbuddy-ai', './.git', './node_modules', './.godot',
                 './addons', './bin', './Logs',
                 # `.kilo/` esta en .gitignore:69 -> no existe en un checkout de
                 # CI. Medido el 2026-09-24 (P-20): de 88 SUCIO + 6 IRREVERSIBLE
                 # del working tree, 87+6 eran de .kilo/worktrees/ (worktrees de
                 # otros agentes con su propio Obsoletos/ y Logs/, que las
                 # exclusiones prefijadas con './' NO atrapaban). Excluirlo hace
                 # que la corrida local coincida con la de CI.
                 './.kilo')
# Dependencias de terceros: no son codigo del proyecto y no se deben "reparar".
EXCLUIDOS_SUELTOS = ('.venv', 'node_modules', 'site-packages')

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


def es_excluido(p):
    """¿La ruta esta en alguna lista de exclusion? (p con '/' y prefijo './')."""
    return (p in EXCLUIDOS_ARCH
            or p.startswith(tuple(d + '/' for d in EXCLUIDOS_DIR))
            or p.startswith(tuple(d[2:] for d in EXCLUIDOS_DIR))
            or any('/' + x + '/' in '/' + p for x in EXCLUIDOS_SUELTOS))


def clasificar(p, raw):
    """Veredicto para UN archivo. None = no aplica (NUL, encoding, o limpio).

    Extraido de main() para poder ejercitarlo con fixtures: un detector que no
    se puede correr sobre contenido sintetico no se puede probar en las DOS
    direcciones, y un gate que no se probo en rojo no sirve.
    """
    if b'\x00' in raw:
        return None
    try:
        s = raw.decode('utf-8')
    except UnicodeDecodeError:
        return None
    if not PAT.search(s):
        return None
    # Se descartan las lineas que DOCUMENTAN el mojibake; el resto es
    # contenido real del archivo y lo que se debe reparar.
    util = '\n'.join(l for l in s.split('\n') if not PAT_LINEA_DOC.search(l))
    n = len(PAT.findall(util))
    if n == 0:
        return None
    if es_excluido(p):
        return ('EXCLUIDO', n)
    if FFFD in util:
        return ('IRREVERSIBLE', n)
    return ('SUCIO', n)


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    if '--selftest' in argv:
        return selftest()
    if argv:
        print('Uso: python scripts/diagnosticar_mojibake.py [--selftest]')
        return 2

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
            r = clasificar(p, raw)
            if r is not None:
                cats[r[0]].append((p, r[1]))

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


def selftest():
    """Prueba el detector en LAS DOS DIRECCIONES antes de confiar en el gate.

    La mitad que importa es la de "NO debe marcar": un detector de substrings
    reporta mojibake en cualquier archivo con acentos validos. El primer byte de
    TODO acento UTF-8 es A-tilde, y A-circunfleja + euro es el prefijo de la raya
    larga: por eso el patron exige el byte de continuacion. Si esta mitad del
    selftest no existiera, el gate nace con falsos positivos y alguien lo
    desactiva (leccion del 2026-09-20: "un selftest que solo prueba el rojo es
    medio selftest").

    TODO literal sospechoso va en escapes \\uXXXX: si se escribiera crudo, este
    archivo seria el primer archivo corrupto (ya paso una vez, ver docstring).
    """
    P = './game/isla-ancestral/scripts/ejemplo.gd'

    # A) UTF-8 VALIDO -> no debe marcar NADA
    limpios = [
        ('acentos validos', '\u00e1 \u00e9 \u00ed \u00f3 \u00fa \u00f1 \u00fc'),
        ('mayusculas acentuadas', '\u00c1 \u00c9 \u00cd \u00d3 \u00da \u00d1'),
        ('rayas y comillas tipograficas', '\u2014 \u2013 \u201ccomillas\u201d'),
        ('seccion y flecha', '\u00a7 21.8 \u2192'),
        ('emoji valido', '\U0001f7e2 \U0001f3ae \u2705'),
        ('A-tilde SUELTA (sin byte de continuacion)', '\u00c3'),
        ('A-circunfleja SUELTA (sin continuacion)', '\u00c2'),
        ('prosa que menciona la palabra', 'esto no es mojibake, es una palabra'),
    ]

    # B) MOJIBAKE REAL -> SUCIO
    sucios = [
        ('acento (C3 xx)', 'configuraci\u00c3\u00b3n'),
        ('enie (C3 B1)', 'a\u00c3\u00b1o'),
        ('raya (E2 80 xx)', 'hola \u00e2\u20ac\u201d chau'),
        ('seccion (C2 A7)', '\u00c2\u00a721.8'),
        ('emoji (F0 9F)', 'estado \u00f0\u0178\u0178\u00a2'),
    ]

    # C) CONVERSION PREVIA con errors=replace -> IRREVERSIBLE
    irreversibles = [('caracter de reemplazo U+FFFD', 'texto \ufffd roto')]

    # D) RUTA EXCLUIDA -> EXCLUIDO (se ve en el informe, no bloquea)
    excluidos = [
        ('./AGENTS.md', '\u00c2\u00a7'),
        ('./Obsoletos/respaldo.md', 'a\u00c3\u00b1o'),
        ('./Logs/900-viejo.md', 'a\u00c3\u00b1o'),
        ('.kilo/worktrees/x/Obsoletos/y.md', 'a\u00c3\u00b1o'),
        ('./.workbuddy-ai/tmp/z.md', 'a\u00c3\u00b1o'),
    ]

    # E) LINEAS QUE DOCUMENTAN el sintoma -> no deben contar
    documentados = [
        ('banner de BACKLOG', 'caracteres rotos (\u00c3\u00b3, \u00e2\u20ac)'),
        ('tabla de reparador', 'U+00F0 -> \u00f0'),
    ]

    print('=' * 60)
    print('SELFTEST - diagnosticar_mojibake.py (las DOS direcciones)')
    print('=' * 60)
    print()
    fallos = [0]
    total = [0]

    def chk(nombre, contenido, esperado, ruta=P):
        total[0] += 1
        r = clasificar(ruta, contenido.encode('utf-8'))
        obtenido = r[0] if r else 'limpio'
        if obtenido == esperado:
            print('  OK    %-46s -> %s' % (nombre, obtenido))
        else:
            fallos[0] += 1
            print('  FALLO %-46s -> esperaba %s, obtuvo %s'
                  % (nombre, esperado, obtenido))

    print('A) UTF-8 valido -> NO debe marcar (aqui se pescan los falsos positivos)')
    for n, c in limpios:
        chk(n, c, 'limpio')
    print()
    print('B) mojibake real -> SUCIO')
    for n, c in sucios:
        chk(n, c, 'SUCIO')
    print()
    print('C) conversion previa con errors=replace -> IRREVERSIBLE')
    for n, c in irreversibles:
        chk(n, c, 'IRREVERSIBLE')
    print()
    print('D) ruta excluida -> EXCLUIDO')
    for r, c in excluidos:
        chk(r, c, 'EXCLUIDO', ruta=r)
    print()
    print('E) lineas que documentan el sintoma -> no cuentan')
    for n, c in documentados:
        chk(n, c, 'limpio')
    print()
    print('=' * 60)
    if fallos[0]:
        print('SELFTEST FALLIDO: %d de %d casos mal.' % (fallos[0], total[0]))
        return 1
    print('SELFTEST OK: %d/%d casos.' % (total[0], total[0]))
    return 0


if __name__ == '__main__':
    sys.exit(main())
