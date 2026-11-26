import os, re, subprocess

root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
rel = 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS'
rx = re.compile(r'^\s*-\s+\[x\]', re.M)

def measured(commit):
    out = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', commit, '--', rel], cwd=root)
    paths = [p for p in out.decode('utf-8', 'replace').splitlines() if p.endswith('.md')]
    x = 0
    for p in paths:
        try:
            t = subprocess.check_output(['git', 'show', '%s:%s' % (commit, p)], cwd=root)
        except subprocess.CalledProcessError:
            continue
        x += len(rx.findall(t.decode('utf-8', 'replace')))
    return len(paths), x

for c in ['47eb7c5', '1968195', '956215c', 'HEAD']:
    try:
        print(c, measured(c), flush=True)
    except Exception as e:
        print(c, 'ERR', e, flush=True)
