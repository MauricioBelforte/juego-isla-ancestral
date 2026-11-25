import os, re

for mid, folder in [('01','01-Fundamentos-Del-Proyecto'),('20','20-Sistema-De-Amistad')]:
    fpath = os.path.join('DOCUMENTACION', folder, 'plan-actual', '05-Checklist.md')
    text = open(fpath, encoding='utf-8').read()
    lines = text.splitlines()
    x_items = [l.strip() for l in lines if re.search(r'^[-*]\s*\[x\]', l)]
    with_ev = 0
    without_ev = 0
    no_ev_examples = []
    for item in x_items:
        low = item.lower()
        has_ev = any(kw in low for kw in ['03-diseno', 'log ', 'captura', '§', '.gd', '.tres', '.tscn', 'archivo', 'existe', 'verificado', 'implementado', 'creado', 'codigo', 'script', 'funcion', 'módulo', 'modulo'])
        if has_ev:
            with_ev += 1
        else:
            without_ev += 1
            if len(no_ev_examples) < 3:
                no_ev_examples.append(item[:80])
    mid_clean = mid.lstrip('0') or '0'
    print('M' + mid_clean + ': [x]=' + str(len(x_items)) + ' con evidencia=' + str(with_ev) + ' sin evidencia=' + str(without_ev))
    if no_ev_examples:
        print('  Sin evidencia (ejemplos):')
        for e in no_ev_examples:
            print('    ' + e)
PYEOF