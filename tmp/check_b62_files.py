import os, re

for mid, folder in [('01','01-Fundamentos-Del-Proyecto'),('20','20-Sistema-De-Amistad')]:
    fpath = os.path.join('DOCUMENTACION', folder, 'plan-actual', '05-Checklist.md')
    text = open(fpath, encoding='utf-8').read()
    lines = text.splitlines()
    file_refs = 0
    missing_files = 0
    missing_examples = []
    for line in lines:
        if re.search(r'^[-*]\s*\[x\]', line):
            paths = re.findall(r'`([^`]+\.(gd|tres|tscn|md|json|cfg|py))`', line)
            for p_tuple in paths:
                p = p_tuple[0]
                file_refs += 1
                candidates = [os.path.join('.', p), os.path.join('game', 'isla-ancestral', p), os.path.join('DOCUMENTACION', p)]
                if not any(os.path.exists(c) for c in candidates):
                    missing_files += 1
                    if len(missing_examples) < 3:
                        missing_examples.append(p)
    mid_clean = mid.lstrip('0') or '0'
    print('M' + mid_clean + ': [x] with file refs=' + str(file_refs) + ', missing=' + str(missing_files))
    if missing_examples:
        print('  Missing examples:', missing_examples)
PYEOF