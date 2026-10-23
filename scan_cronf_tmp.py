# -*- coding: utf-8 -*-
import io, re, glob

# scan de definibles sin dueño (excluye dueños activos/cerrados/gated/flags — canon de las tandas 329-336)
espec = re.compile(r'(?i)^\s-\s*\[ \]\s*(Definir|Documentar|Calcular|Especificar)')
excluded_prefixes = ('20-','73-','87-','17-','56-','107-','112-','133-','72-','77-','140-','99-','108-','23-','91-','147-','143-','104-','163-','162-','153-','119-','16-','46-','58-','75-','110-','28-','139-','24-','137-','138-','67-','72-','151-','95-','93-','144-','107','116-','118-','105-','107-','09-')
modulos_vistos = set()
cands = []
seen_items = set()
for f in glob.glob('DOCUMENTACION/*/plan-actual/05-Checklist.md'):
    mod = f.replace(chr(92), '/').split('/')[1]
    if mod.startswith(excluded_prefixes) or mod in modulos_vistos:
        continue
    t = io.open(f, encoding='utf-8-sig', errors='replace').read()
    its = [i.strip() for i in re.findall(r'(?m)^- \[ \].*$', t) if espec.match(i)]
    for i in its:
        k = (mod, i[:70])
        if k not in seen_items:
            seen_items.add(k)
            cands.append((mod, i[:120]))
print('candidatos frescos:', len(cands))
# los primeros 10 de este scan fresco (los previos M48/56/138/67 salieron en 328-336)
for i, (m, s) in enumerate(cands[:14], 1):
    print(i, '(%s)' % m, s[:90])
import json as J
J.dump(cands[:14], io.open('.cand_f_tmp.json', 'w', encoding='utf-8'), ensure_ascii=False)
