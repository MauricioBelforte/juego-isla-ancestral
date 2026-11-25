# -*- coding: utf-8 -*-
"""Verificacion de los 16 'verificables' contra disco.
M49: los 5 items citan 03-Diseno.md secciones y validate_lighting_m49.gd.
     En b58 L79/L109 ya fueron RECHAZADOS (0 evidencia real / falso positivo NPCFalso).
M159: 11 items son tareas de autoría ('Definir recetas/lore/interacciones')
     sin nombre de archivo concreto => no hay evidencia de implementacion.
"""
import os, re, json, collections
ROOT = os.path.abspath('.')
GAME = os.path.join(ROOT, 'game', 'isla-ancestral')

# --- M49: buscar evidencia real en diseno + codigo ---
DISENO = os.path.join(ROOT, 'DOCUMENTACION', '49-Iluminacion', 'plan-actual', '03-Diseno.md')
diseno = open(DISENO, encoding='utf-8', errors='replace').read() if os.path.isfile(DISENO) else ''

def grep_game(pattern, exts=('.gd','.tscn','.tres','.json')):
    rx = re.compile(pattern, re.I)
    hits = []
    for r, ds, fs in os.walk(GAME):
        ds[:] = [d for d in ds if d not in ('.godot','addons','Godot')]
        for f in fs:
            if not f.endswith(exts):
                continue
            p = os.path.join(r, f)
            try:
                txt = open(p, encoding='utf-8', errors='replace').read()
            except Exception:
                continue
            for n, l in enumerate(txt.splitlines(), 1):
                if rx.search(l):
                    hits.append((os.path.relpath(p, ROOT).replace('\\','/'), n, l.strip()[:120]))
    return hits

#-terminos concretos por linea M49
TERMS = {
    79:  r'glow|bloom',
    109: r'\bPCF\b|pcf_\d|shadow.*sample|sample.*shadow',
    120: r'hornea|bake.*interior|interior.*bake',
    199: r'interior_casa.*baked|baked.*interior_casa',
    200: r'fog_curve|niebla.*bioma|rain.*dimming',
}
m49 = {}
for ln, pat in TERMS.items():
    dhits = [(i+1, l.strip()[:120]) for i, l in enumerate(diseno.splitlines()) if re.search(pat, l, re.I)]
    ghits = grep_game(pat)
    m49[ln] = {'diseno_hits': len(dhits), 'diseno_ej': dhits[:3],
               'game_hits': len(ghits), 'game_ej': ghits[:3]}

# --- M159: buscar .tres de catalogo para ver si las tareas de autoría tienen archivos ---
CAT_DIRS = []
for r, ds, fs in os.walk(os.path.join(GAME, 'data')):
    if 'catalogo' in r.lower() or 'objeto' in r.lower():
        CAT_DIRS.append(r)
tres_all = []
for r, ds, fs in os.walk(os.path.join(GAME, 'data')):
    for f in fs:
        if f.endswith('.tres') and re.search(r'OBJ-(COC|TAL|EXT|NAT|CON|HER|ITE|ROP|ART|EVE|SEC)', f):
            tres_all.append(os.path.relpath(os.path.join(r,f), ROOT).replace('\\','/'))

out = {'M49': m49,
       'M159': {'catalog_dirs': [os.path.relpath(x, ROOT).replace('\\','/') for x in CAT_DIRS[:10]],
                'obj_tres_count': len(tres_all), 'obj_tres_ej': tres_all[:12]},
       'verify_script': os.path.isfile(os.path.join(GAME,'scripts','lighting','validate_lighting_m49.gd'))}
json.dump(out, open('Temp/b60_evidencia16.json','w',encoding='utf-8'), ensure_ascii=False, indent=1)

print('=== M49 (5 items) ===')
for ln, v in m49.items():
    print(' L%-4d diseno=%d game=%d' % (ln, v['diseno_hits'], v['game_hits']))
    for h in v['game_ej'][:2]: print('      game:', h)
print()
print('=== M159 ===')
print(' catalog dirs:', out['M159']['catalog_dirs'][:6])
print(' OBJ-*.tres encontrados:', out['M159']['obj_tres_count'])
for t in out['M159']['obj_tres_ej'][:8]: print('   ', t)
print()
print('validate_lighting_m49.gd existe:', out['verify_script'])
