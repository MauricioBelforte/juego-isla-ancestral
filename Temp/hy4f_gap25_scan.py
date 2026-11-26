import os, re, io

root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
rx = re.compile(r'^\s*-\s+\[x\]', re.M)

def count_paths(paths):
    x = 0
    files = 0
    for p in paths:
        if not os.path.isfile(p):
            continue
        files += 1
        with io.open(p, encoding='utf-8', errors='replace') as f:
            x += len(rx.findall(f.read()))
    return files, x

def walk(base, only=None):
    out = []
    for dp, dn, fn in os.walk(base):
        if '.godot' in dp or '.git' in dp:
            continue
        for n in fn:
            if not n.endswith('.md'):
                continue
            if only and only not in os.path.join(dp, n):
                continue
            out.append(os.path.join(dp, n))
    return out

blog = os.path.join(root, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'HY4 Flash', 'BACKLOGS')
allmodels = os.path.join(root, 'DOCUMENTACION', 'TAREAS-POR-MODELO')
doc = os.path.join(root, 'DOCUMENTACION')

print('A own BACKLOGS           ', count_paths([os.path.join(blog, n) for n in os.listdir(blog)]))
print('B own folder all md      ', count_paths(walk(os.path.dirname(blog))))
print('C all models TAREAS      ', count_paths(walk(allmodels)))
print('D all DOCUMENTACION md   ', count_paths(walk(doc)))
print('E CHECKLIST-GLOBAL       ', count_paths([os.path.join(root, 'CHECKLIST-GLOBAL.md')]))

# per-model backlog subtrees, to see if some combination explains 3564
tpm = os.path.join(allmodels)
for name in sorted(os.listdir(tpm)):
    d = os.path.join(tpm, name)
    if not os.path.isdir(d):
        continue
    f, x = count_paths(walk(d, only='BACKLOG'))
    if x:
        print('  model %-40s files=%-4d x=%d' % (name[:40], f, x))

# Search all markdown under repo for the literal 3564 / 3577 as a stated total
print('--- literal mentions of 3564 / 3577 in repo md ---')
pat = re.compile(r'35(?:64|77)')
for p in walk(root):
    try:
        with io.open(p, encoding='utf-8', errors='replace') as f:
            for i, line in enumerate(f, 1):
                if pat.search(line):
                    print(os.path.relpath(p, root)[:70], i, line.strip()[:120])
    except Exception:
        pass
