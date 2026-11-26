import os, io, re
root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
game = os.path.join(root, 'game', 'isla-ancestral')
terms = [
 'OBJ-COC','receta','recetas','animacion','animaciones','cocina','taller','exterior',
 'OBJ-HER','herramienta','OBJ-ITE','energia','comida','inventario','inventario_service',
 'economia','precio','OBJ-ART','lore','OBJ-EVE','festival','OBJ-SEC','secreto',
 'ItemData','items_abm','INTERACCIONES','DROP_TABLE','REGENERACION_HORAS',
 'get_item','item_catalog','catalogo','test_integracion'
]
hits = {t: [] for t in terms}
for dp, dn, fn in os.walk(game):
    dn[:] = [d for d in dn if d not in ('.godot', '.git')]
    for f in fn:
        if not f.endswith(('.gd','.json','.tres','.tscn')): continue
        p = os.path.join(dp, f)
        try: t = io.open(p, encoding='utf-8', errors='replace').read()
        except Exception: continue
        for term in terms:
            n = len(re.findall(re.escape(term), t, re.I))
            if n: hits[term].append((os.path.relpath(p, root).replace('\\','/'), n))
for term in terms:
    h = hits[term]
    print('%-24s files=%-4d hits=%-5d %s' % (term, len(h), sum(x[1] for x in h), ', '.join('%s(%d)'%(p.split('/')[-1],n) for p,n in h[:3])))
