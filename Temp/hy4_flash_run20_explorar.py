"""Backlog 20: pistas de root-cause para 30 bugs. Solo lectura."""
from pathlib import Path
import re
from collections import Counter

R = Path('.')
BUG = (R / 'DOCUMENTACION/11-BUGS.md').read_text(encoding='utf-8').splitlines()
BLOCKS = []
for i, l in enumerate(BUG):
    if re.match(r'^#{2,4}\s', l):
        m = re.search(r'BUG-(\d+)', l)
        if m:
            BLOCKS.append((i, m.group(1)))
SEG = {}
for k,(pos,bid) in enumerate(BLOCKS):
    fin = BLOCKS[k+1][0] if k+1 < len(BLOCKS) else len(BUG)
    SEG.setdefault(bid, []).append('\n'.join(BUG[pos:fin]))

BP = R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/20-Backlog-Bug-RootCause-PRUEBA.md'
ids = [m.group(1) for l in BP.read_text(encoding='utf-8').splitlines()
       if (m := re.match(r'^- \[ \] T20-\d+: BUG-(\d+) - diagnosticar causa$', l))]
print('bugs objetivo:', len(ids))

GD = list((R / 'game/isla-ancestral').rglob('*.gd'))
for bid in ids:
    txt = '\n'.join(SEG.get(bid, []))
    if not txt:
        print('BUG-'+bid, 'SIN BLOQUE'); continue
    titulo = next((l for l in txt.splitlines() if l.startswith('#')), '')[:110]
    # rutas .gd citadas en el bloque
    citadas = set()
    for m in re.finditer(r'(res://)?([\w/\-]+\.gd)', txt):
        name = Path(m.group(2)).name
        citadas.add(name)
    candidatos = [p for p in GD if p.name in citadas]
    # palabras clave del titulo y de causas/sintomas
    kw = set(re.findall(r'\b[a-zA-Z_]\w{4,}\b', titulo))
    kw |= set(re.findall(r'\b[a-zA-Z_]\w{6,}\b', '\n'.join(
        l for l in txt.splitlines() if re.search(r'(?i)(causa|error|falla|symptom|síntoma|script)', l))[:4000]))
    stop = {'error','script','causa','probable','documentacion','implementacion','relacion','sistema','proyecto','headless','checks','tests'}
    kw = {k.lower() for k in kw if k.lower() not in stop}
    mejores = []
    for p in candidatos[:8]:
        try:
            lines = p.read_text(encoding='utf-8', errors='replace').splitlines()
        except Exception:
            continue
        scored = []
        for i,l in enumerate(lines,1):
            hits = sum(1 for k in kw if k in l.lower())
            if hits:
                scored.append((hits, i, l.strip()[:130]))
        scored.sort(reverse=True)
        if scored:
            mejores.append((p, scored[:3]))
    print('\nBUG-'+bid, titulo)
    print('  .gd citados:', len(citadas), '| encontrados:', len(candidatos), '| kw:', ','.join(sorted(kw)[:10]))
    for p, sc in mejores[:3]:
        for hits, i, l in sc:
            print('   ', p.relative_to(R).as_posix()+':'+str(i), '[hits=%d]'%hits, l)
