# Baseline sha256 de TODOS los GLB de runtime antes / despues del export B21.
# Modo --guardar: snapshot. Sin flags: verifica mutados / faltantes / nuevos.
# Scratch de autoria: se conserva, NO se versiona, NO se borra.
# Motivo: el exportador es global por modulo (36-Fauna); hay que MEDIR que
#   solo aparecen los 3 GLB nuevos y que ningun GLB ajeno fue reescrito.
import glob
import hashlib
import json
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
ROOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
OUT = os.path.join(REPO, 'Temp', 'hy4_cangrejo_baseline_glb_20261109.json')

paths = sorted(glob.glob(os.path.join(ROOT, '*', '*.glb')))
actual = {}
for p in paths:
    clave = os.path.relpath(p, REPO).replace('\\', '/')
    actual[clave] = hashlib.sha256(open(p, 'rb').read()).hexdigest()

if '--guardar' in sys.argv:
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(actual, f, indent=1, sort_keys=True)
    print('BASELINE %d GLB -> %s' % (len(actual), OUT))
else:
    base = json.load(open(OUT, encoding='utf-8'))
    mutados = sorted(k for k, v in base.items() if actual.get(k) != v)
    faltantes = sorted(k for k in base if k not in actual)
    nuevos = sorted(k for k in actual if k not in base)
    print('VERIFICACION base=%d mutados=%d faltantes=%d nuevos=%d'
          % (len(base), len(mutados), len(faltantes), len(nuevos)))
    if mutados:
        print('  MUTADOS', mutados[:8])
    if faltantes:
        print('  FALTANTES', faltantes[:8])
    for k in nuevos:
        print('  NUEVO %s %s' % (k, actual[k][:12]))
    sys.exit(0 if not mutados and not faltantes else 1)
