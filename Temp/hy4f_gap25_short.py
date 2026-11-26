import os, re, io

root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
rx = re.compile(r'^\s*-\s+\[x\]', re.M)

def cnt(paths):
    x = 0; n = 0
    for p in paths:
        if not os.path.isfile(p): continue
        n += 1
        with io.open(p, encoding='utf-8', errors='replace') as f:
            x += len(rx.findall(f.read()))
    return n, x

def mds(base):
    out = []
    for dp, dn, fn in os.walk(base):
        dn[:] = [d for d in dn if d not in ('.git', '.godot')]
        for f in fn:
            if f.endswith('.md'): out.append(os.path.join(dp, f))
    return out

blog = os.path.join(root, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'HY4 Flash', 'BACKLOGS')
print('A own BACKLOGS', cnt([os.path.join(blog, f) for f in os.listdir(blog)]), flush=True)
print('B own TAREAS folder', cnt(mds(os.path.dirname(blog))), flush=True)
print('C CHECKLIST-GLOBAL', cnt([os.path.join(root, 'CHECKLIST-GLOBAL.md')]), flush=True)
