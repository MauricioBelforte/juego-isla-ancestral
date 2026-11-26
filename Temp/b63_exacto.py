import os, re, io, subprocess
root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
game = os.path.join(root, 'game', 'isla-ancestral')
items = os.path.join(game, 'data', 'items')

ids = set()
for f in os.listdir(items):
    if not f.endswith('.tres'): continue
    t = io.open(os.path.join(items, f), encoding='utf-8', errors='replace').read()
    ids.update(re.findall(r'OBJ-[A-Z]{3}-\d{3}', t))

ranges = [
 ('OBJ-COC', 1, 20, 1, 10), ('OBJ-TAL', 1, 10, 1, 5),
 ('OBJ-EXT', 1, 20, 1, 5), ('OBJ-NAT', 1, 10, 1, 5),
 ('OBJ-NAT', 11, 17, 0, 0), ('OBJ-NAT', 18, 28, 0, 0),
 ('OBJ-CON', 1, 15, 1, 5), ('OBJ-HER', 1, 20, 1, 5),
 ('OBJ-ITE', 1, 15, 1, 5), ('OBJ-ITE', 20, 39, 20, 24),
 ('OBJ-ITE', 50, 57, 0, 0), ('OBJ-ROP', 1, 20, 1, 5),
 ('OBJ-ART', 1, 12, 1, 5), ('OBJ-EVE', 1, 12, 1, 5),
 ('OBJ-SEC', 1, 12, 1, 5),
]
print('=== M159: IDs exactos en data/items ===')
for pre, a, b, ia, ib in ranges:
    want = ['%s-%03d' % (pre, n) for n in range(a, b+1)]
    have = [w for w in want if w in ids]
    iterwant = ['%s-%03d' % (pre, n) for n in range(ia, ib+1)] if ib else []
    iterhave = [w for w in iterwant if w in ids]
    print('%s %03d-%03d: %d/%d presentes; iter1 %d/%d %s' % (
        pre, a, b, len(have), len(want), len(iterhave), len(iterwant),
        'COMPLETO' if iterwant and len(iterhave)==len(iterwant) else ''))

print('=== validate_lighting_m49.gd en b60 ===')
p='game/isla-ancestral/scripts/world/validate_lighting_m49.gd'
for c in ['956215c','HEAD']:
    try:
        out=subprocess.check_output(['git','show',c+':'+p],cwd=root).decode('utf-8','replace')
        print(c,'EXISTE','PCF' if re.search('PCF',out,re.I) else 'sin PCF','bytes',len(out))
    except subprocess.CalledProcessError:
        print(c,'NO EXISTE')
t=io.open(os.path.join(root,p),encoding='utf-8',errors='replace').read()
for m in re.finditer(r'.*(?:PCF|glow|bloom|fog|lightmap).*', t, re.I):
    print('  ', m.group(0).strip()[:150])
