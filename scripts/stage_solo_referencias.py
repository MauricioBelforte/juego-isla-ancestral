#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Separa, entre los archivos modificados, los que cambiaron SOLAMENTE por la
reparacion de referencias a Logs/ (Log 853).

El problema: el working tree tiene 300+ cambios de otros agentes. No se puede
hacer `git add` de todo. Y comparar "heads vs ahora" tampoco sirve: un archivo
puede tener a la vez la reparacion de referencias Y la edicion de otro agente.

Criterio exacto:
    T(HEAD) == working_tree   ->   cambio PURO (solo lo mio)
    T(HEAD) != working_tree   ->   MEZCLADO (otro agente tambien toco)

donde T es la composicion de MIS transformaciones, en el orden en que las
ejecute: primero la reparacion de codificacion (Log 852) y despues la de
referencias (Log 853).

    T = ref  o  enc  o  ref(enc)

Se prueba cada variante porque no todos los archivos necesitaban las dos.
Si ninguna coincide, es que otro agente metio mano: NO se stagea.

Es la misma idea que scripts/stage_solo_encoding.py pero encadenando las dos
transformaciones. Se reutilizan importando los modulos, para que una divergencia
entre el script y el staged salte sola.

Uso:
    python scripts/stage_solo_referencias.py          # informe
    python scripts/stage_solo_referencias.py --add    # git add de los puros
"""
import io
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import auditar_referencias as A  # noqa: E402
import fix_encoding as F  # noqa: E402

RAIZ = A.raiz_repo()


def git(*args):
    r = subprocess.run(['git'] + list(args), cwd=RAIZ,
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return r.returncode, r.stdout, r.stderr


def head_bytes(rel):
    """Contenido del archivo en HEAD. Devuelve None si no esta versionado."""
    code, out, _ = git('show', 'HEAD:' + rel)
    if code != 0:
        return None
    return out


def reparar(texto, idx, todos):
    """Aplica EXACTAMENTE la misma reparacion que auditar_referencias.py --fix.

    OJO: se hace sobre el texto, no sobre el archivo, para poder comparar
    contra el working tree sin escribir nada.
    """
    s = texto
    for m in A.REF.finditer(texto):
        num, resto, ext = m.group(1), m.group(2), m.group(3) or ''
        if not ext and not resto:
            continue
        destino = 'Logs/' + num + resto + ext
        if os.path.exists(os.path.join(RAIZ, destino)):
            continue

        slug = resto.lstrip('-')
        if '*' in slug or slug == '':
            cands = idx.get(num, [])
            if len(cands) == 1:
                s = s.replace(m.group(0), 'Logs/' + cands[0])
            continue

        tokens = [t for t in re.findall(r'[A-Za-z0-9]+', slug)
                  if len(t) >= 3 or re.match(r'^M?\d+$', t)]
        cands = [f for f in todos
                 if all(t.lower() in f.lower() for t in tokens)]
        if len(cands) > 1:
            exactos = [f for f in cands
                       if re.sub(r'^[0-9]{1,4}[-_]', '', f)
                       .lower().startswith(slug.lower())]
            if len(exactos) == 1:
                cands = exactos
        if len(cands) == 1:
            s = s.replace(m.group(0), 'Logs/' + cands[0])
    return s


def norm(b):
    """Unifica CRLF->LF: HEAD puede estar normalizado por .gitattributes y el
    working tree no (o al reves). Sin esto TODO parece mezclado."""
    return b.replace(b'\r\n', b'\n')


def fix_enc(raw):
    """Misma decision que fix_encoding.py main(): classify() y escribir new.
    Devuelve None si el archivo no necesitaba reparacion (o classify fallo).
    No replica la guarda de U+FFFD de main(): si esa guarda habia abortado el
    archivo, aqui simplemente no coincide y queda como MEZCLADO, que es la
    direccion conservadora."""
    kind, new, _note = F.classify(raw)
    if kind in ('cp1252', 'mojibake', 'mojibake-fail') and new is not None:
        return new
    return None


def main():
    os.chdir(RAIZ)
    A.LOGS = os.path.join(RAIZ, 'Logs')
    idx = A.indice_logs()
    todos = sorted(f for v in idx.values() for f in v)

    add = '--add' in sys.argv

    code, out, _ = git('diff', '--name-only', 'HEAD')
    if code != 0:
        raise SystemExit('git diff fallo')
    modificados = [l.strip() for l in out.decode('utf-8', 'replace').splitlines()
                   if l.strip()]

    puros, mezclados, sin_head = [], [], []
    como = {}

    for rel in modificados:
        if not rel.endswith('.md'):
            continue
        hb = head_bytes(rel)
        if hb is None:
            sin_head.append(rel)
            continue
        try:
            actual = open(rel, 'rb').read()
        except OSError:
            continue

        variantes = []          # (etiqueta, bytes_candidatos)

        # 1) solo referencias
        try:
            variantes.append(('ref', reparar(hb.decode('utf-8'), idx, todos)
                              .encode('utf-8')))
        except UnicodeDecodeError:
            pass

        # 2) solo codificacion
        solo_enc = fix_enc(hb)
        if solo_enc is not None:
            variantes.append(('enc', solo_enc))

        # 3) codificacion y despues referencias (el orden real de ejecucion)
        if solo_enc is not None:
            try:
                variantes.append(
                    ('enc+ref',
                     reparar(solo_enc.decode('utf-8'), idx, todos)
                     .encode('utf-8')))
            except UnicodeDecodeError:
                pass

        hit = None
        for etiqueta, cand in variantes:
            if norm(cand) == norm(actual):
                hit = etiqueta
                break

        if hit:
            puros.append(rel)
            como[rel] = hit
        else:
            mezclados.append(rel)

    print('=== stage_solo_referencias (Log 853) ===')
    print('modificados .md examinados: %d' % (len(puros) + len(mezclados) + len(sin_head)))
    print('PUROS (solo transformaciones mias): %d' % len(puros))
    for p in puros:
        print('  + %s  [%s]' % (p, como[p]))
    print('')
    print('MEZCLADOS (otro agente tambien edito): %d' % len(mezclados))
    for p in mezclados[:40]:
        print('  ! %s' % p)
    if len(mezclados) > 40:
        print('  ... y %d mas' % (len(mezclados) - 40))
    if sin_head:
        print('')
        print('sin version en HEAD (nuevos): %d' % len(sin_head))
        for p in sin_head:
            print('  ? %s' % p)

    if add and puros:
        git('add', '--', *puros)
        print('')
        print('staged: %d' % len(puros))
    return 0


if __name__ == '__main__':
    sys.exit(main())
