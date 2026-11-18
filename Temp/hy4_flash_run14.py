"""Backlog 14: deteccion de huérfanos en 2791 assets/data. Solo lectura."""
from pathlib import Path
import os, re
from collections import Counter

R = Path('.')
BP = R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/14-Backlog-Asset-Data-Orphans.md'

archivos = []
for base in (os.path.join('game', 'isla-ancestral', 'assets'),
             os.path.join('game', 'isla-ancestral', 'data')):
    for root, _dirs, fs in os.walk(base):
        for f in fs:
            archivos.append(os.path.join(root, f))
archivos = sorted(archivos)
print('archivos:', len(archivos))

# Equivalente a grep -rlf: corpus de texto bajo game/ y DOCUMENTACION/, y busqueda literal
# de cada nombre de archivo presente en assets/data.
bloques = []
for base in ('game', 'DOCUMENTACION'):
    for root, _dirs, fs in os.walk(base):
        if '.git' in Path(root).parts:
            continue
        for f in fs:
            p = Path(root) / f
            if p.suffix.lower() in ('.png', '.jpg', '.jpeg', '.webp', '.gif', '.bmp', '.glb', '.gltf', '.ogg', '.mp3', '.wav', '.ttf', '.woff', '.woff2', '.blend', '.blend1'):
                continue
            try:
                bloques.append(p.read_text(encoding='utf-8', errors='replace'))
            except Exception:
                pass
corpus = '\n'.join(bloques)
print('corpus chars:', len(corpus))

nombres = sorted({os.path.basename(p) for p in archivos}, key=len, reverse=True)

# Aho-Corasick simple: una pasada sobre el corpus para los 2791 nombres literales.
nexts = [{}]
fall = [0]
outs = [[]]
for n in nombres:
    v = 0
    for ch in n:
        if ch not in nexts[v]:
            nexts.append({}); fall.append(0); outs.append([])
            nexts[v][ch] = len(nexts) - 1
        v = nexts[v][ch]
    outs[v].append(n)
from collections import deque
q = deque()
for ch, u in nexts[0].items():
    fall[u] = 0; q.append(u)
while q:
    v = q.popleft()
    for ch, u in nexts[v].items():
        q.append(u)
        f = fall[v]
        while f and ch not in nexts[f]:
            f = fall[f]
        fall[u] = nexts[f][ch] if ch in nexts[f] else 0
        outs[u].extend(outs[fall[u]])
citados = set()
v = 0
for ch in corpus:
    while v and ch not in nexts[v]:
        v = fall[v]
    v = nexts[v].get(ch, 0)
    if outs[v]:
        citados.update(outs[v])
print('nombres citados en texto:', len(citados))

estados = []
for p in archivos:
    name = os.path.basename(p)
    estados.append(name in citados)
print('referenciados:', sum(estados), '| huérfanos:', len(estados) - sum(estados))

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
res = []
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    m = re.match(r'^- \[[ x]\] (T14-\d+): Batch (\d+)-(\d+) - verificar referencias(?: —.*)?$', l)
    if not m:
        continue
    tag, ini, fin = m.group(1), int(m.group(2)) - 1, int(m.group(3)) - 1
    chunk = estados[ini:fin + 1]
    huerfanos = [archivos[ini + k] for k, ok in enumerate(chunk) if not ok]
    nota = 'OK %d/%d referenciados' % (len(chunk) - len(huerfanos), len(chunk)) if not huerfanos else \
           '%d/%d OK · %d huerfanos: %s' % (len(chunk) - len(huerfanos), len(chunk), len(huerfanos),
                                            ', '.join(os.path.basename(x) for x in huerfanos[:4]))
    base = re.sub(r' — .*$', '', l)
    lineas[i] = '- [x] ' + base[6:] + ' — ' + nota + '\n'
    res.append((tag, ini, fin, huerfanos))

exts = Counter(Path(p).suffix.lower() for p in archivos if p not in () and not estados[archivos.index(p)]) if False else Counter()
todos_huer = [archivos[k] for k, ok in enumerate(estados) if not ok]
exts = Counter(Path(p).suffix.lower() for p in todos_huer)

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:4x UTC)\n\n']
ev.append('Universo: %d assets + %d data = **%d archivos**, 140 batches. '
          'Se construyó un índice de nombres de archivo citados como texto en `game/` y `DOCUMENTACION/` '
          '(excluidos binarios) y se marcó como huérfano todo archivo cuyo `nombre.ext` no aparece en ese índice. '
          '**Solo detección: no se borró ni movió nada.**\n\n' % (1779, 1012, len(archivos)))
ev.append('| Resultado | Archivos |\n|---|---|\n')
ev.append('| Referenciados | %d |\n' % sum(estados))
ev.append('| Huérfanos detectados | %d |\n' % len(todos_huer))
ev.append('\nExtensiones de huérfanos: ')
ev.append('; '.join('%s=%d' % (k or 'sin-ext', v) for k, v in exts.most_common(12)) + '.\n\n')
ev.append('Batches con huérfanos: %d de %d.\n\n' % (sum(1 for r in res if r[3]), len(res)))
ev.append('Primeros 40 huérfanos:\n\n')
for p in todos_huer[:40]:
    ev.append('- %s\n' % p.replace('\\', '/'))
ev.append('\n**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:4x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
print('tareas marcadas:', sum(1 for l in lineas if l.startswith('- [x] T14-')))
print('referenciados:', sum(estados), '| huerfanos:', len(todos_huer))
print('extensiones:', exts.most_common(8))
print('batches con huerfanos:', sum(1 for r in res if r[3]))
