import os, io, re
root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
game = os.path.join(root, 'game', 'isla-ancestral')
doc = os.path.join(root, 'DOCUMENTACION')

def scan(term, base=game, exts=('.gd','.tres','.json','.tscn','.csv','.md')):
    hits = []
    for dp, dn, fn in os.walk(base):
        dn[:] = [d for d in dn if d not in ('.godot', '.git')]
        for f in fn:
            if not f.endswith(exts): continue
            p = os.path.join(dp, f)
            try: t = io.open(p, encoding='utf-8', errors='replace').read()
            except Exception: continue
            n = len(re.findall(re.escape(term), t, re.I))
            if n: hits.append((os.path.relpath(p, root).replace('\\','/'), n))
    return hits

def show(label, term, base=game):
    h = scan(term, base)
    print(label, '|', term, '| hits=', len(h), 'files=', sum(x[1] for x in h), flush=True)
    for p,n in h[:6]: print('   ', p, n, flush=True)

print('=== M159 artifacts ===', flush=True)
for term in ['OBJ-COC-', 'OBJ-TAL-', 'OBJ-EXT-', 'OBJ-NAT-', 'OBJ-CON-', 'OBJ-HER-', 'OBJ-ITE-', 'OBJ-ROP-', 'OBJ-ART-', 'OBJ-EVE-', 'OBJ-SEC-']:
    show('M159', term)
print('tres named OBJ-* :', len([f for dp,dn,fn in os.walk(game) for f in fn if f.startswith('OBJ-') and f.endswith('.tres')]), flush=True)

print('=== M49 candidates ===', flush=True)
for term in ['glow', 'bloom', 'PCF', 'validate_lighting_m49', 'fog_curve.tres', 'lightmap']:
    show('M49-game', term)
p49 = os.path.join(doc, '49-Iluminacion', 'plan-actual', '03-Diseno.md')
t49 = io.open(p49, encoding='utf-8', errors='replace').read()
for term in ['glow','bloom','PCF','fog_curve','horne']:
    print('M49-03Diseno', term, len(re.findall(re.escape(term), t49, re.I)), flush=True)

print('=== changed game files since b60 ===', flush=True)
import subprocess
o = subprocess.check_output(['git','diff','--name-only','956215c..HEAD','--','game/isla-ancestral'], cwd=root).decode('utf-8','replace').splitlines()
for p in o: print('  ', p, flush=True)
