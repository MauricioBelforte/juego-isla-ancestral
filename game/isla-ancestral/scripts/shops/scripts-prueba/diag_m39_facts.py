# -*- coding: utf-8 -*-
# M39 (iter. glm, Log 1017/cierre): diagnostico de facts para el cierre de la
# iteracion — ids de M15 (semillas/pescados/cebos), autoloads, M73 y hooks NPC.
# Solo LEE; escribe el informe en Logs/_m39_facts.txt
import io, glob, os, re

RAIZ = '.'
OUT = []
OUT.append('=== M15: ids de items (.tres) ===')
ids = []
for f in glob.glob(RAIZ + '/game/isla-ancestral/data/items/*.tres'):
    t = io.open(f, encoding='utf-8').read()
    m = re.search(r'id = "([^"]+)"', t)
    if m:
        ids.append(m.group(1))
OUT.append('total=%d' % len(ids))
OUT.append(', '.join(sorted(ids)))

def buscar(pals):
    return [i for i in ids if any(p in i.lower() for p in pals)]

OUT.append('semillas: %s' % (buscar(['semilla', 'seed']) or 'NINGUNO'))
OUT.append('pesca/cebos: %s' % (buscar(['pez', 'pesc', 'fish', 'cebo', 'bait']) or 'NINGUNO'))
OUT.append('herramienta: %s' % (buscar(['herramienta', 'tool']) or 'NINGUNO'))
OUT.append('pergamino: %s' % (buscar(['pergamino']) or 'NINGUNO'))

OUT.append('')
OUT.append('=== ids usados por los catalogos M39 (legacy) vs M15 ===')
cat = io.open(RAIZ + '/game/isla-ancestral/scripts/shops/catalogo_tiendas.gd', encoding='utf-8').read()
usados = re.findall(r'_entry\("([^"]+)"', cat) + re.findall(r'"(madera_roble|piedra_caliza|baya_roja|fibra_algodon|mineral_cobre|fragmento_ancestral|pergamino_rec_tela_lino|herramienta_basica)"', cat)
usados = sorted(set(usados))
for u in usados:
    OUT.append('%-28s en M15: %s' % (u, 'SI' if u in ids else 'NO'))

OUT.append('')
OUT.append('=== autoloads de project.godot ===')
pg = io.open(RAIZ + '/game/isla-ancestral/project.godot', encoding='utf-8').read()
als = re.findall(r'^([A-Za-z_][A-Za-z0-9_]*)=', pg, re.M)
OUT.append(', '.join(als))

OUT.append('')
OUT.append('=== scripts M73 (eventos) ===')
for f in sorted(glob.glob(RAIZ + '/game/isla-ancestral/scripts/**/*event*.gd', recursive=True)):
    t = io.open(f, encoding='utf-8').read()
    sigs = re.findall(r'^signal ([a-z_0-9]+)', t, re.M)
    funcs = re.findall(r'^func ([a-z_0-9]+)', t, re.M)
    OUT.append('%s' % f.replace('\\', '/'))
    OUT.append('   signals: %s' % (', '.join(sigs) or '-'))
    OUT.append('   funcs: %s' % (', '.join(funcs[:14]) or '-'))

OUT.append('')
OUT.append('=== consumo de eventos en tiendas/stock ===')
for f in ['game/isla-ancestral/scripts/shops/shop_manager.gd', 'game/isla-ancestral/scripts/shops/stock_generator.gd']:
    t = io.open(RAIZ + '/' + f, encoding='utf-8').read()
    hits = [(i, l.strip()[:110]) for i, l in enumerate(t.splitlines(), 1) if 'evento' in l.lower()]
    OUT.append('%s: %d menciones "evento"' % (f, len(hits)))
    for i, l in hits[:12]:
        OUT.append('   L%d %s' % (i, l))

OUT.append('')
OUT.append('=== NPCs de M19 (ids de poblacion) ===')
for f in sorted(glob.glob(RAIZ + '/game/isla-ancestral/scripts/**/*poblacion*.gd', recursive=True))[:3]:
    t = io.open(f, encoding='utf-8').read()
    OUT.append('%s (%d lineas)' % (f.replace('\\', '/'), t.count('\n') + 1))
    nids = sorted(set(re.findall(r'"(?:\w*:)?([a-z_]{4,20})"', t)))[:40]
    OUT.append('   candidatos: %s' % ', '.join(nids[:30]))
for f in sorted(glob.glob(RAIZ + '/game/isla-ancestral/data/**/*npc*', recursive=True))[:8]:
    OUT.append('data: ' + f.replace('\\', '/'))

io.open(RAIZ + '/Logs/_m39_facts.txt', 'w', encoding='utf-8', newline='').write('\n'.join(OUT) + '\n')
print('informe: Logs/_m39_facts.txt (%d lineas)' % len(OUT))
