#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Audita referencias a Logs/ dentro de la documentacion.

Dos tipos de problema:
  ROTA         la ruta apunta a un archivo que no existe
  AMBIGUA      no existe, pero hay mas de un log con ese numero

Reparacion automatica (--fix): si el log referenciado no existe pero hay
EXACTAMENTE UNO con ese numero, se reescribe la ruta con el nombre real.
Si hay varios o ninguno, NO se toca: se reporta para decision humana.

Tambien detecta menciones textuales "Log NNN" cuyo numero no existe en Logs/.

Uso:
    python scripts/auditar_referencias.py           # informe
    python scripts/auditar_referencias.py --fix     # repara las unambiguous
"""
import os
import re
import sys
import io

RAIZ = None
LOGS = None

# Referencia con ruta: Logs/123-algo.md  (o con backslash, o entre parentesis)
REF = re.compile(r'Logs[/\\]([0-9]{1,4})([^\\\s)"\'`,\]]*?)(\.md)?(?=[\s)"\'`,\]]|$)')
# Mencion textual: "Log 123", "Logs 123", "log 123"
MENCION = re.compile(r'\b[Ll]ogs?\s+(?:[Nn]?[°º]?\s*)?([0-9]{1,4})\b')

# TRAMPA: leer SIEMPRE con newline='' (texto plano convierte CRLF->LF
# al leer y luego se reescribe sin los CR -> cambio masivo de fin de
# linea camuflado de reparacion).
EXCLUIDOS = ('Obsoletos', '.git', 'node_modules', '.venv', '__pycache__',
             '.godot', 'addons', '.workbuddy-ai')


def raiz_repo():
    d = os.path.dirname(os.path.abspath(__file__))
    for _ in range(10):
        if os.path.isfile(os.path.join(d, 'AGENTS.md')):
            return d
        p = os.path.dirname(d)
        if p == d:
            break
        d = p
    raise SystemExit('No encontre AGENTS.md')


def indice_logs():
    """numero -> lista de nombres de archivo en Logs/"""
    idx = {}
    for fn in os.listdir(LOGS):
        m = re.match(r'^([0-9]{1,4})[-_]', fn)
        if m:
            idx.setdefault(m.group(1), []).append(fn)
    return idx


def main():
    global RAIZ, LOGS
    RAIZ = raiz_repo()
    LOGS = os.path.join(RAIZ, 'Logs')
    os.chdir(RAIZ)
    fix = '--fix' in sys.argv

    idx = indice_logs()
    todos = sorted(f for v in idx.values() for f in v)
    rotas, ambiguas, menciones = [], [], []
    reparadas = 0

    for dirpath, dirnames, filenames in os.walk('.'):
        dirnames[:] = [d for d in dirnames if d not in EXCLUIDOS]
        if os.path.abspath(dirpath) == os.path.abspath(LOGS):
            continue  # los logs se citan entre si; se auditan aparte
        for fn in filenames:
            if not fn.endswith('.md'):
                continue
            p = os.path.join(dirpath, fn).replace('\\', '/')
            try:
                s = io.open(p, encoding='utf-8', newline='').read()
            except (OSError, UnicodeDecodeError):
                continue

            orig = s
            for m in REF.finditer(s):
                num, resto, ext = m.group(1), m.group(2), m.group(3) or ''
                if not ext and not resto:
                    continue
                destino = 'Logs/' + num + resto + ext
                if os.path.exists(destino):
                    continue

                slug = resto.lstrip('-')
                # Caso A: referencia con comodin o sin descripcion
                # ("Logs/401-*"): el NUMERO es la clave. Si existe un unico
                # log con ese numero, la reparacion es fiable.
                if '*' in slug or slug == '':
                    cands = idx.get(num, [])
                    if len(cands) == 1:
                        nuevo = 'Logs/' + cands[0]
                        if fix:
                            s = s.replace(m.group(0), nuevo)
                            reparadas += 1
                        else:
                            rotas.append((p, m.group(0), nuevo))
                    elif len(cands) > 1:
                        ambiguas.append((p, m.group(0), cands))
                    else:
                        rotas.append((p, m.group(0), None))
                    continue

                # Caso B: referencia con nombre concreto que no existe.
                # OJO: no vale fiarse del numero — puede estar ocupado por un
                # log de OTRO tema (p. ej. 679-M16-3D vs 679-AGNES-M30).
                # Se busca por TOKENS del nombre entre TODOS los logs.
                tokens = [t for t in re.findall(r'[A-Za-z0-9]+', slug)
                          if len(t) >= 3 or re.match(r'^M?\d+$', t)]
                cands = [f for f in todos
                         if all(t.lower() in f.lower() for t in tokens)]
                if len(cands) > 1:
                    # Preferir la coincidencia EXACTA de nombre ignorando el
                    # numero: el numero puede haberse movido al renumerar.
                    exactos = [f for f in cands
                               if re.sub(r'^[0-9]{1,4}[-_]', '', f)
                               .lower().startswith(slug.lower())]
                    if len(exactos) == 1:
                        cands = exactos
                if len(cands) == 1:
                    nuevo = 'Logs/' + cands[0]
                    if fix:
                        s = s.replace(m.group(0), nuevo)
                        reparadas += 1
                    else:
                        rotas.append((p, m.group(0), nuevo))
                else:
                    ambiguas.append((p, m.group(0), cands or ['sin coincidencia']))

            for m in MENCION.finditer(orig):
                if m.group(1) not in idx:
                    menciones.append((p, m.group(0)))

            if fix and s != orig:
                io.open(p, 'w', encoding='utf-8', newline='').write(s)

    print('=== Auditoria de referencias a Logs/ ===')
    print('Logs indexados: %d' % sum(len(v) for v in idx.values()))
    print('')
    print('Rutas rotas (auto-reparables): %d' % len(rotas))
    for p, ref, nuevo in rotas[:25]:
        print('  %s' % p)
        print('      %s  ->  %s' % (ref, nuevo or 'SIN LOG CON ESE NUMERO'))
    if len(rotas) > 25:
        print('  ... y %d mas' % (len(rotas) - 25))
    print('')
    print('Ambiguas (varios logs con el mismo numero): %d' % len(ambiguas))
    for p, ref, cands in ambiguas[:15]:
        print('  %s  %s  ->  %s' % (p, ref, cands))
    print('')
    print('Menciones "Log NNN" sin log existente: %d' % len(menciones))
    for p, t in menciones[:15]:
        print('  %s  "%s"' % (p, t))
    if len(menciones) > 15:
        print('  ... y %d mas' % (len(menciones) - 15))

    if fix:
        print('')
        print('referencias reparadas: %d' % reparadas)
    else:
        print('')
        print('(modo informe; agregar --fix para reparar las unambiguous)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
