import os, re

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
tscn_count = 0
ext_broken = 0
no_root = 0
for root, dirs, files in os.walk(os.path.join(ROOT, 'game')):
    for f in files:
        if f.endswith('.tscn'):
            tscn_count += 1
            fpath = os.path.join(root, f)
            text = open(fpath, encoding='utf-8', errors='ignore').read()
            for m in re.finditer(r'ext_resource path="([^"]+)"', text):
                ref = m.group(1)
                if ref.startswith('res://'):
                    rel = ref.replace('res://', '')
                    full = os.path.join(ROOT, 'game', 'isla-ancestral', rel)
                    if not os.path.exists(full):
                        ext_broken += 1
            if not re.search(r'^\[node name=', text, re.M):
                no_root += 1
print('TSCN count:', tscn_count)
print('Ext_resource broken:', ext_broken)
print('No root node:', no_root)
print('Claim b57-C: 73 .tscn, 0 ext_resource rotos, 0 sin nodo raiz')
PYEOF