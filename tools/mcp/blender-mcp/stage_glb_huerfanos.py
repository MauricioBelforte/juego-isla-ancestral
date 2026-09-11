#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Stagea SOLO los .glb untracked de game/isla-ancestral/assets/3d (+ su sidecar
.glb.import). No toca ningun otro archivo: los cambios de otros agentes quedan
fuera del index.

Motivo: E-103. Un `git clean -fd` / `git stash -u` borra los binarios untracked
y deja los sidecars huerfanos. `git checkout` NO los recupera. Ya paso una vez
con 56 GLB (log 809).

Uso:
    python tools/mcp/blender-mcp/stage_glb_huerfanos.py          # lista
    python tools/mcp/blender-mcp/stage_glb_huerfanos.py --add    # stagea
"""
import os
import subprocess
import sys

G = 'game/isla-ancestral/assets/3d'
VARIANTES = ('alta', 'media', 'baja')


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
    adds = []
    for v in VARIANTES:
        d = os.path.join(G, v)
        if not os.path.isdir(d):
            continue
        for f in sorted(os.listdir(d)):
            if not f.endswith('.glb'):
                continue
            p = os.path.join(d, f).replace(os.sep, '/')
            r = subprocess.run(['git', 'ls-files', '--error-unmatch', p],
                               capture_output=True)
            if r.returncode != 0:
                adds.append(p)
                sid = p + '.import'
                if os.path.exists(sid):
                    adds.append(sid)
    print('GLB untracked + sidecars a stagear: %d' % len(adds))
    for p in adds:
        print('  ', p)
    if '--add' in sys.argv and adds:
        r = subprocess.run(['git', 'add', '--'] + adds, capture_output=True,
                           text=True)
        print('git add rc=%d %s' % (r.returncode, (r.stderr or '').strip()[:200]))
        n = subprocess.run(['git', 'diff', '--cached', '--name-only'],
                           capture_output=True, text=True).stdout.split()
        print('staged ahora: %d archivos' % len(n))
    return 0


if __name__ == '__main__':
    sys.exit(main())
