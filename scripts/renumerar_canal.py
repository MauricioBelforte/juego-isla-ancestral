# -*- coding: utf-8 -*-
r"""RENUMERADOR DE CANAL v2 — SOP del proyecto (fundador 23oct 04:30), parche recursivo

Uso:
    python -X utf8 scripts/renumerar_canal.py "Mensajes entre modelos/<canal>" [--dry-run]

Que arregla respecto de la v1:
  1. RECURSIVO: recorre arch_XXXX-XXXX/ con os.walk. La v1 usaba os.scandir(base) y solo
     veia la raiz: en un canal de 234 mensajes renumeraba 28 y creaba 28 gemelos.
  2. LONG-PATH: los mensajes con ruta > 260 chars (fantasmas NTFS) se leen con el prefijo
     \\?\ en vez de saltarse con OSError. La v1 los perdia en silencio.
  3. DETECTOR: acepta 1-4 digitos y horas HH-MM (sin segundos). La v1 exigia HH-MM-SS y
     descartaba mensajes validos sin avisar.
  4. NO RECONOCIDOS: los lista y avisa (la v1 los omitia y el INDICE mentia el total).
  5. REAGRUPADO: deja en la raiz la centena en curso y archiva las completas en
     arch_XXXX-XXXX/ (misma regla que scripts/agrupar_canales.py, sin depender de el).
  6. IDEMPOTENTE: correrlo dos veces no mueve nada la segunda vez.

No toca el contenido de los mensajes: solo nombres, ubicacion, INDICE-CANAL.md, pool y puntero.
"""
import io
import os
import re
import sys

RE_MSG = re.compile(r'^(\d{1,4}[A-Za-z]?)-(\d{4}-\d{2}-\d{2})_(\d{2}-\d{2}(?:-\d{2})?)-?(.*)\.md$')
RE_OLDNUM = re.compile(r'^(\d+)')


def lp(p):
    """Ruta absoluta con prefijo long-path en Windows (para > 260 chars)."""
    p = os.path.abspath(p)
    if os.name != 'nt' or p.startswith('\\\\?\\'):
        return p
    return '\\\\?\\' + p


def recolectar(base):
    filas, no_reconocidos = [], []
    for raiz, _dirs, files in os.walk(base):
        for nombre in files:
            if not nombre.endswith('.md'):
                continue
            m = RE_MSG.match(nombre)
            if not m:
                if nombre != 'INDICE-CANAL.md':
                    no_reconocidos.append((os.path.relpath(os.path.join(raiz, nombre), base),
                                           'patron no reconocido'))
                continue
            ruta = os.path.join(raiz, nombre)
            try:
                size = os.stat(lp(ruta)).st_size
            except OSError as ex:
                no_reconocidos.append((os.path.relpath(ruta, base), 'ilegible: %s' % ex))
                continue
            filas.append({
                'viejo_num': int(RE_OLDNUM.match(nombre).group(1)),
                'ts': '%s %s' % (m.group(2), m.group(3)),
                'resto': m.group(4),
                'nombre': nombre,
                'ruta': ruta,
                'size': size,
            })
    filas.sort(key=lambda r: (r['ts'], r['size']))
    return filas, no_reconocidos


def destino_de(i, n):
    """'' = raiz (centena en curso) | 'arch_XXXX-XXXX' = archivada."""
    if not n:
        return ''
    en_curso = ((n - 1) // 100) * 100 + 1
    if i >= en_curso:
        return ''
    lo = ((i - 1) // 100) * 100 + 1
    return 'arch_%04d-%04d' % (lo, lo + 99)


def main(argv):
    args = [a for a in argv[1:] if not a.startswith('--')]
    dry = '--dry-run' in argv
    if not args:
        print(__doc__)
        return 2
    base = args[0]
    if not os.path.isdir(base):
        print('no existe: %s' % base)
        return 2

    sobrantes = [f for f in os.listdir(base) if f.startswith('tmp__')]
    if sobrantes and not dry:
        print('!! hay %d archivo(s) tmp__ de una corrida interrumpida: %s' % (len(sobrantes), sobrantes[:5]))
        print('   revisalos a mano antes de volver a correr (no se toca nada).')
        return 3

    filas, no_reconocidos = recolectar(base)
    n = len(filas)
    if not n:
        print('sin mensajes reconocibles en %s' % base)
        return 2

    plan = []
    for i, r in enumerate(filas, 1):
        nuevo = '%03d-%s_%s-%s.md' % (i, r['ts'][:10], r['ts'][11:], r['resto'])
        plan.append((r, nuevo, destino_de(i, n)))

    cambios = [p for p in plan
               if os.path.basename(p[0]['ruta']) != p[1]
               or os.path.relpath(os.path.dirname(p[0]['ruta']), base) != (p[2] or '.')]

    por_carpeta = {}
    for _r, _n, d in plan:
        por_carpeta[d or '(raiz)'] = por_carpeta.get(d or '(raiz)', 0) + 1

    print('canal: %s' % base)
    print('mensajes reconocidos: %d | a renombrar/mover: %d' % (n, len(cambios)))
    print('destino: %s' % ', '.join('%s=%d' % (k, v) for k, v in sorted(por_carpeta.items())))
    if no_reconocidos:
        print('  AVISO: %d archivo(s) .md NO entran en la renumeracion (quedan como estan):'
              % len(no_reconocidos))
        for rel, motivo in no_reconocidos[:10]:
            print('    %-70s %s' % (rel[:70], motivo))
    for r, nuevo, d in plan[:5]:
        print('  %s  ->  %s%s' % (os.path.relpath(r['ruta'], base).replace(os.sep, '/'),
                                  (d + '/') if d else '', nuevo))
    if n > 5:
        print('  ... (%d mas)' % (n - 5))

    if dry:
        print('\nDRY-RUN: no se escribio nada.')
        return 0

    # staging plano: todo sale a tmp__NNNN (nombre corto) y despues entra a su destino final.
    # asi no hay colisiones aunque dos mensajes viejos compartan numero o nombre.
    for i, (r, _nuevo, _d) in enumerate(plan, 1):
        os.rename(lp(r['ruta']), lp(os.path.join(base, 'tmp__%04d' % i)))
    for i, (_r, nuevo, d) in enumerate(plan, 1):
        destino_dir = os.path.join(base, d) if d else base
        if d and not os.path.isdir(destino_dir):
            os.makedirs(destino_dir)
        os.replace(lp(os.path.join(base, 'tmp__%04d' % i)), lp(os.path.join(destino_dir, nuevo)))

    # INDICE-CANAL.md: mapping viejo -> nuevo (donde ya lo dejaba la v1)
    mapping = []
    for i, (r, _nuevo, _d) in enumerate(plan, 1):
        if r['viejo_num'] != i:
            mapping.append('%03d -> %03d | %s | %s' % (r['viejo_num'], i, r['ts'], r['resto'][:80]))
    indice = ['# INDICE-CANAL DE %s' % os.path.basename(base), '',
              'RENUMERACION SECUENCIAL (%03d mensajes, 001-%03d) por fecha cronologica real.' % (n, n),
              'Las citas historicas a numeros VIEJOS resuelven con este mapping:', '']
    indice.extend(mapping)
    indice += ['', 'Total: %d mensajes.' % n, '',
               'Firma: renumerador v2 recursivo (parche 2026-11-04, gate-1 DS-OC).']
    carpeta_doc = os.path.join('DOCUMENTACION/TAREAS-POR-MODELO', os.path.basename(base))
    destino_indice = carpeta_doc if os.path.isdir(carpeta_doc) else os.path.dirname(os.path.abspath(base))
    io.open(os.path.join(destino_indice, 'INDICE-CANAL.md'), 'w', encoding='utf-8', newline='').write(
        '\n'.join(indice) + '\n')

    # pool + puntero
    io.open(os.path.join(base, 'NUMEROS_DISPONIBLES.txt'), 'w', encoding='utf-8', newline='').write(
        '\n'.join(str(i) for i in range(n + 1, n + 41)) + '\n')
    punteros = [f for f in os.listdir(base) if f.startswith('.ultima-revision') and f.endswith('.txt')]
    for p in punteros:
        io.open(os.path.join(base, p), 'w', encoding='utf-8', newline='').write('%03d\n' % n)

    # verificacion final
    conteo, huerfanos = 0, []
    for raiz, _dirs, files in os.walk(base):
        for f in files:
            if RE_MSG.match(f):
                conteo += 1
            elif f.startswith('tmp__'):
                huerfanos.append(f)
    print('\nOK: %d mensajes renumerados 001-%03d | pool %d-%d | INDICE-CANAL.md en %s'
          % (n, n, n + 1, n + 40, destino_indice))
    print('verificacion: %d/%d mensajes en disco | tmp__ huerfanos: %d' % (conteo, n, len(huerfanos)))
    if conteo != n or huerfanos:
        print('!! INCONSISTENCIA: revisar antes de seguir.')
        return 4
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
