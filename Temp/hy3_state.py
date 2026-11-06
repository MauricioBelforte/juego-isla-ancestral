import os, re, datetime
root = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
b = root + chr(92) + 'Mensajes entre modelos' + chr(92)
# Hy3 channel last 4
d = os.path.join(b, 'Hy3')
rows = sorted((os.path.getmtime(os.path.join(d, x)), x) for x in os.listdir(d) if x.endswith('.md') and re.match(r'^\d{3,4}-', x))
print('=== Hy3 channel (ult 5) ===')
for m, x in rows[-5:]:
    txt = open(os.path.join(d, x), encoding='utf-8', errors='replace').read()
    print(datetime.datetime.fromtimestamp(m).strftime('%H:%M'), x[:40])
    print('    ->', txt.split(chr(10))[0][:30], '|', (txt[:200].split(chr(10))[4] if len(txt.split(chr(10)))>4 else '')[:80])
# Hy3 backlog
print()
print('=== Hy3 BACKLOG-MASTER [ ]/[->] (tareas) ===')
bp = os.path.join(root, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'Hy3', 'BACKLOG-MASTER.md')
if os.path.exists(bp):
    c = open(bp, encoding='utf-8', errors='replace').read()
    print('mtime:', datetime.datetime.fromtimestamp(os.path.getmtime(bp)).strftime('%H:%M'))
    for l in c.split(chr(10)):
        if re.match(r'^\s*- \[.\]', l):
            print('  ', l[:100])
else:
    print('Hy3 SIN BACKLOG-MASTER')
    # buscar rieles
    for f in glob.glob(root + r'\DOCUMENTACION\TAREAS-POR-MODELO\Hy3\*'):
        pass
