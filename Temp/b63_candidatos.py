import os, re, io
root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
doc = os.path.join(root, 'DOCUMENTACION')

def qitems(mid, folder):
    p = os.path.join(doc, folder, 'plan-actual', '05-Checklist.md')
    out = []
    for i, line in enumerate(io.open(p, encoding='utf-8', errors='replace'), 1):
        if re.match(r'^\s*-\s+\[\?\]', line):
            out.append((i, line.strip()))
    return out

for mid, folder in [('M159', '159-Catalogo-De-Objetos'), ('M49', '49-Iluminacion')]:
    print('===', mid, '===')
    for i, line in qitems(mid, folder):
        print(i, line[:180])
