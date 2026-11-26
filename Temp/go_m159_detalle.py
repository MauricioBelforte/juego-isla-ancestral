import os, re, io
root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
game = os.path.join(root, 'game', 'isla-ancestral')
items = os.path.join(game, 'data', 'items')

def pat(term, exts=('.gd','.json','.tres','.tscn')):
    out=[]
    for dp,dn,fn in os.walk(game):
        dn[:] = [d for d in dn if d not in ('.godot','.git')]
        for f in fn:
            if not f.endswith(exts): continue
            p=os.path.join(dp,f)
            try: t=io.open(p,encoding='utf-8',errors='replace').read()
            except Exception: continue
            n=len(re.findall(re.escape(term),t,re.I))
            if n: out.append((os.path.relpath(p,root).replace('\\','/'),n))
    return out

print('=== patron de [x] hermanos: alfombras (CAT-05) ===')
for f in ['item_obj_alf_001.tres','item_obj_alf_002.tres']:
    p=os.path.join(items,f)
    if os.path.isfile(p):
        t=io.open(p,encoding='utf-8',errors='replace').read()
        print(f, 'descripcion=', re.search(r'^descripcion\s*=\s*(.*)$',t,re.M).group(1))
    else: print(f,'AUSENTE')

print('=== arte: interacciones en .tres ===')
for f in ['item_obj_art_001.tres','item_obj_art_005.tres']:
    p=os.path.join(items,f)
    t=io.open(p,encoding='utf-8',errors='replace').read()
    m=re.search(r'^interacciones\s*=\s*(.*)$',t,re.M)
    print(f, m.group(1) if m else 'NA')

print('=== secretos en quests ===')
for term in ['OBJ-SEC-001','OBJ-SEC-002','OBJ-SEC-003','OBJ-SEC-004','OBJ-SEC-005']:
    h=pat(term)
    print(term, [(p,n) for p,n in h if 'secundarias' in p or 'quest' in p.lower()])

print('=== test integracion inventario M159 ===')
for term in ['OBJ-','ItemsABM','item_obj_']:
    h=[(p,n) for p,n in pat(term) if 'inventario' in p.lower() and p.endswith('.gd')]
    print(term, h[:8])

print('=== recetas con IDs OBJ-COC ===')
d=io.open(os.path.join(game,'data','balance','crafting.json'),encoding='utf-8').read()
print('OBJ-COC en crafting.json', len(re.findall('OBJ-COC',d)))
print('recetas total', len(re.findall('"nombre"',d)))

print('=== animaciones item-use ===')
for term in ['item_use','usar_item','anim_item','recoger','cocinar']:
    print(term, len(pat(term)))
