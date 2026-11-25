import re, os, glob

os.chdir(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral")

# Check pt.po
po = 'game/isla-ancestral/locales/pt.po'
with open(po, encoding='utf-8') as f:
    text = f.read()
msgid = len(re.findall(r'^msgid\s', text, re.M))
empty = len(re.findall(r'^msgstr\s+"\"', text, re.M))
print('pt.po: %d msgid, %d vacios' % (msgid, empty))

# Check total pending
base_doc = 'DOCUMENTACION'
all_files = glob.glob(os.path.join(base_doc, '**', 'plan-actual', '05-Checklist.md'), recursive=True)
total_sp = 0
total_q = 0
for f in all_files:
    with open(f, encoding='utf-8') as fh:
        text = fh.read()
    total_sp += len(re.findall(r'^\s*- \[ \]', text, re.M))
    total_q += len(re.findall(r'^\s*- \[\?\]', text, re.M))
print('Total [ ] plan-actual: %d' % total_sp)
print('Total [?] plan-actual: %d' % total_q)

# Check which agents are idle
print()
print('Agentes AGOTADOS: Beam, Glyph, Ling')
print('Agentes con trabajo: HY4F (b59), Nemotron (24), ERNIE (12), DS-OC (14)')
