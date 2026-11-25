import subprocess, re, os, json

out = subprocess.run(['git', 'diff', '-U0'], capture_output=True, text=True, encoding='utf-8').stdout
changed = [l for l in out.splitlines() if (l.startswith('+') or l.startswith('-'))
           and not l.startswith(('+++', '---'))]
bad = [l for l in changed if ('Totales' not in l and 'KnownIssue b59' not in l
       and not l.lstrip('+-').startswith('>') and not l.lstrip('+-').startswith('.'))]
print('lineas diff:', len(changed), '| fuera de Totales/KnownIssue:', len(bad))
for l in changed[:30]:
    print(' ', l[:150])

ids = ['18', '26', '28', '31', '35', '37', '63', '72', '104', '106', '160', '164']
print()
for mid in ids:
    paths = [os.path.join('DOCUMENTACION', d, 'plan-actual', '05-Checklist.md')
             for d in os.listdir('DOCUMENTACION') if d.startswith(mid + '-')]
    p = paths[0].replace('\\', '/')
    t = open(p, encoding='utf-8').read()
    old = subprocess.run(['git', 'show', 'HEAD:' + p], capture_output=True, text=True,
                         encoding='utf-8').stdout
    f = lambda s: tuple(len(re.findall(r'^\s*- \[%s\]' % k, s, re.M)) for k in ('x', ' ', '?'))
    print(' M%-4s marcas ANTES %s DESPUES %s %s' % (mid, f(old), f(t), 'OK' if f(old) == f(t) else 'CAMBIO'))

# drift post-check con criterio Beam
mods = json.load(open('Temp/b59_beam_replica.json', encoding='utf-8'))
post = []
for m in mods:
    paths = [os.path.join('DOCUMENTACION', d, 'plan-actual', '05-Checklist.md')
             for d in os.listdir('DOCUMENTACION') if d.startswith(m['id'] + '-')]
    if not paths or not os.path.isfile(paths[0]):
        continue
    t = open(paths[0], encoding='utf-8').read()
    rx = len(re.findall(r'^[-*]\s*\[x\]', t, re.M))
    tls = [l for l in t.splitlines() if 'Totales' in l]
    tl = tls[-1] if tls else None
    cm = re.search(r'Completados:\s*(\d+)', tl) if tl else None
    if cm and abs(rx - int(cm.group(1))) > 5:
        post.append((m['id'], rx, int(cm.group(1))))
print()
print('drift_totals>5 post-fix:', len(post), post)
