#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Audita enlaces markdown relativos en todo el repo ([texto](ruta)).

Motivo (Log 853, paso siguiente): las guias se partieron
(`07-GUIA-GODOT.md` -> `GUIA-GODOT/*.md`) y las referencias a `Logs/` se
repararon, pero nadie verifico el resto de los enlaces relativos. Un .md de
2000 archivos citando rutas que ya no existen es documentacion que miente.

Que NO se audita (evita ruido):
  - externos: http/https/mailto/data
  - anclas puras: `#seccion`
  - rutas de Godot: res:// user://
  - rutas que apuntan dentro de un directorio excluido (Obsoletos, .git, ...)

Salida: cuantos enlaces rotos hay, por archivo, y si el destino existe en OTRO
sitio del repo (sugerencia de reparacion).

Uso:
    python scripts/auditar_enlaces_md.py             # informe
    python scripts/auditar_enlaces_md.py -v          # con detalle de cada roto
    python scripts/auditar_enlaces_md.py --json out.json
"""
import io
import json
import os
import re
import sys
from collections import defaultdict
from urllib.parse import unquote

RAIZ = None

EXCLUIDOS = ('.git', 'node_modules', '.godot', '__pycache__', '.workbuddy-ai',
             'Obsoletos', 'OBSOLETOS', 'addons', 'bin', '.venv',
             # .claude/skills es cache de skills instalados: se regenera solo,
             # y sus enlaces cruzados apuntan a OTROS skills. No es documentacion
             # del proyecto -> auditarla solo genera ruido irreparable.
             '.claude')

# [texto](destino)  — destino puede llevar <...> y "titulo"
#
# El lookbehind evita comerse sintaxis de codigo que se parece a un enlace:
#   ns["color"]("PIEL")      ->  [^\]]*\]\(  casa con  ["color"](
#   Array[StringName]([..])  ->  idem
# Sin el lookbehind, los .md con snippets de Python/GDScript generan decenas
# de "enlaces rotos" que son indireccion de arreglos, no markdown.
LINK = re.compile(
    r'(?<![A-Za-z0-9_)\]"\'])!?\[[^\]]*\]\(\s*<?([^)\s>]+)>?'
    r'(?:\s+"[^"]*")?\s*\)')

ESQUEMAS = ('http://', 'https://', 'mailto:', 'data:', 'ftp://', 'tel:')
RUTAS_GODOT = ('res://', 'user://')

# --- Modo --rutas: rutas citadas como TEXTO PLANO entre backticks -----------
# En este proyecto la mayoria de las referencias NO son enlaces markdown sino
# `ruta/al/archivo.gd` entre backticks. Son las que rompieron al partir las
# guias, y el modo enlaces no las ve.
EXT_RUTA = ('.md', '.gd', '.py', '.json', '.tres', '.tscn', '.cs', '.png',
            '.txt', '.yml', '.bat', '.ps1', '.sh', '.csv', '.glb', '.blend',
            '.html')
BACKTICK = re.compile(r'`([^`\n]+)`')
# Raices desde las que se suele escribir una ruta. Sin DOCUMENTACION/ como
# raiz, las 39 citas de AGENTS.md a `GUIA-GODOT/*.md` salian todas "rotas"
# cuando en realidad existen (dentro de DOCUMENTACION/).
ROOTS_EXTRA = ('game/isla-ancestral', 'DOCUMENTACION')

# Bloques de codigo: ``` ... ```  (y ~~~). Sin quitarlos, el regex de enlaces
# mataquea cualquier [algo](algo) dentro de snippets de Godot (.tscn, &
#"SILLA", SubResource(...)) y de plantillas de prompts de Blender, y reporta
# decenas de "enlaces rotos" que son codigo, no documentacion.
CERCA = re.compile(r'^(```|~~~).*?$(?:.*?^\1.*?$)?', re.M | re.S)
CODIGO_INLINE = re.compile(r'`[^`\n]*`')


def limpiar_codigo(txt):
    """Devuelve el markdown sin bloques de codigo ni codigo inline.

    Se reemplaza por espacios (no se borra) para no desplazar nada y que los
    mensajes de error sigan apuntando al lugar correcto.
    """
    txt = CERCA.sub(lambda m: re.sub(r'[^\n]', ' ', m.group(0)), txt)
    txt = CODIGO_INLINE.sub(lambda m: ' ' * len(m.group(0)), txt)
    return txt


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


def leer(path):
    try:
        raw = open(path, 'rb').read()
    except OSError:
        return None
    for enc in ('utf-8-sig', 'utf-8', 'utf-16-le', 'utf-16-be'):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            continue
    return raw.decode('latin-1')   # nunca falla, nunca U+FFFD


def md_files():
    for dirpath, dirnames, filenames in os.walk(RAIZ):
        dirnames[:] = [d for d in dirnames if d not in EXCLUIDOS]
        for fn in filenames:
            if fn.lower().endswith(('.md', '.markdown')):
                yield os.path.join(dirpath, fn)


def auditar_rutas(verbose=False):
    """Rutas citadas entre backticks que no existen en disco.

    No se auto-reparan: si el destino no existe en ningun lado no hay nada a
    donde apuntar. El valor de este modo es el DIAGNOSTICO: dice que modulos
    describen codigo que nadie escribio.
    """
    from collections import Counter
    roots = [RAIZ] + [os.path.join(RAIZ, r) for r in ROOTS_EXTRA]
    idx = set()
    for dirpath, dirnames, filenames in os.walk(RAIZ):
        dirnames[:] = [d for d in dirnames if d not in EXCLUIDOS]
        for fn in filenames:
            idx.add(fn)

    rotos = defaultdict(list)
    sueltos = 0
    revisadas = 0
    for p in md_files():
        t = leer(p)
        if t is None:
            continue
        t = CERCA.sub(lambda m: re.sub(r'[^\n]', ' ', m.group(0)), t)
        d = os.path.dirname(p)
        for m in BACKTICK.finditer(t):
            s = m.group(1).strip()
            if not s or ' ' in s or '*' in s or '<' in s or s.startswith('.'):
                continue
            low = s.lower()
            if low.startswith(ESQUEMAS) or low.startswith(RUTAS_GODOT):
                continue
            if re.match(r'^[A-Za-z]:', s) or s.startswith('/'):
                continue
            if not low.endswith(EXT_RUTA):
                continue
            revisadas += 1
            if '/' not in s and '\\' not in s:
                # nombre suelto: no es una ruta, se cuenta aparte
                if os.path.basename(s) not in idx:
                    sueltos += 1
                continue
            cands = ([os.path.normpath(os.path.join(d, s))]
                     + [os.path.normpath(os.path.join(r, s)) for r in roots])
            if any(os.path.exists(c) for c in cands):
                continue
            rotos[os.path.relpath(p, RAIZ).replace('\\', '/')].append(s)

    n = sum(len(v) for v in rotos.values())
    ext = Counter()
    plan = Counter()
    for k, v in rotos.items():
        parte = ('plan-actual' if 'plan-actual' in k
                 else 'plan-inicial' if 'plan-inicial' in k else 'otro')
        for s in v:
            ext[os.path.splitext(s)[1]] += 1
            plan[parte] += 1

    print('=== Rutas citadas entre backticks ===')
    print('rutas revisadas: %d' % revisadas)
    print('nombres sueltos sin archivo en el repo: %d' % sueltos)
    print('')
    print('RUTAS INEXISTENTES: %d  (en %d archivos)' % (n, len(rotos)))
    print('')
    print('por extension:')
    for e, c in ext.most_common():
        print('  %-8s %d' % (e or '(sin ext)', c))
    print('')
    print('por tipo de plan:')
    for k, c in plan.most_common():
        print('  %-14s %d' % (k, c))
    print('')
    cs = ext.get('.cs', 0)
    act = sum(1 for k, v in rotos.items() if 'plan-actual' in k
              for s in v if not s.endswith('.cs'))
    print('  .cs en un proyecto que tiene 1 solo .cs: %d' % cs)
    print('  en plan-actual (vigente), sin contar .cs: %d' % act)
    print('')
    orden = sorted(rotos.items(), key=lambda kv: -len(kv[1]))
    for rel, items in orden[:20]:
        print('  %-64s %d' % (rel, len(items)))
    if verbose:
        print('')
        for rel, items in orden:
            for s in sorted(set(items)):
                print('  %s -> %s' % (rel, s))
    return rotos


def main():
    global RAIZ
    RAIZ = raiz_repo()
    os.chdir(RAIZ)
    if '--rutas' in sys.argv:
        auditar_rutas(verbose='-v' in sys.argv)
        return 0
    verbose = '-v' in sys.argv
    json_out = None
    if '--json' in sys.argv:
        i = sys.argv.index('--json')
        if i + 1 < len(sys.argv):
            json_out = sys.argv[i + 1]

    # indice: nombre de archivo -> rutas donde aparece (para sugerir)
    indice = defaultdict(list)
    for dirpath, dirnames, filenames in os.walk(RAIZ):
        dirnames[:] = [d for d in dirnames if d not in EXCLUIDOS]
        for fn in filenames:
            p = os.path.join(dirpath, fn)
            indice[fn].append(os.path.relpath(p, RAIZ).replace('\\', '/'))

    total = 0
    rotos_por_archivo = defaultdict(list)
    archivos = 0
    saltados = 0

    for path in md_files():
        rel = os.path.relpath(path, RAIZ).replace('\\', '/')
        txt = leer(path)
        if txt is None:
            continue
        txt = limpiar_codigo(txt)
        archivos += 1
        base = os.path.dirname(path)
        for m in LINK.finditer(txt):
            dest = m.group(1).strip()
            if not dest:
                continue
            low = dest.lower()
            if low.startswith(ESQUEMAS) or low.startswith(RUTAS_GODOT):
                saltados += 1
                continue
            dest = unquote(dest)
            if dest.startswith('#'):
                saltados += 1
                continue
            # separar ancla del path
            destino_sin_ancla = dest.split('#')[0]
            if not destino_sin_ancla:
                saltados += 1
                continue
            total += 1
            abs_dest = os.path.normpath(os.path.join(base, destino_sin_ancla))
            if os.path.exists(abs_dest):
                continue
            # roto: buscar por nombre en el resto del repo
            nombre = os.path.basename(destino_sin_ancla)
            cands = indice.get(nombre, [])
            rotos_por_archivo[rel].append((dest, cands))

    n_rotos = sum(len(v) for v in rotos_por_archivo.values())
    print('=== Auditoria de enlaces markdown relativos ===')
    print('archivos .md examinados: %d' % archivos)
    print('enlaces relativos revisados: %d' % total)
    print('enlaces externos/ancla ignorados: %d' % saltados)
    print('')
    print('ENLACES ROTOS: %d  (en %d archivos)' % (n_rotos,
                                                   len(rotos_por_archivo)))
    print('  de los cuales, con candidato unico por nombre: %d'
          % sum(1 for v in rotos_por_archivo.values()
                for _d, c in v if len(c) == 1))
    print('  sin candidato (destino inexistente en todo el repo): %d'
          % sum(1 for v in rotos_por_archivo.values()
                for _d, c in v if len(c) == 0))
    print('')
    orden = sorted(rotos_por_archivo.items(),
                   key=lambda kv: -len(kv[1]))
    for rel, items in orden[:25]:
        print('  %-70s %d' % (rel, len(items)))
    if len(orden) > 25:
        print('  ... y %d archivos mas' % (len(orden) - 25))

    if verbose:
        print('')
        print('--- detalle ---')
        for rel, items in orden:
            for dest, cands in items:
                if len(cands) == 1:
                    sug = '-> ' + cands[0]
                elif not cands:
                    sug = '(no existe en el repo)'
                else:
                    sug = '(ambiguo: %d)' % len(cands)
                print('  %s' % rel)
                print('      %s   %s' % (dest, sug))

    if json_out:
        data = {rel: [{'dest': d, 'candidatos': c} for d, c in items]
                for rel, items in rotos_por_archivo.items()}
        with io.open(json_out, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=1)
        print('')
        print('JSON: %s' % json_out)
    return 0


if __name__ == '__main__':
    sys.exit(main())
