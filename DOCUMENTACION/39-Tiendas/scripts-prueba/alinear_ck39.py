# -*- coding: utf-8 -*-
# Alinea por TEXTO el checklist personal (glm-5.3-flash / 39-Tiendas) con el
# 05-Checklist.md del modulo M39. Dry-run por defecto; aplicar con --apply.
import io, os, re, sys, difflib, unicodedata

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(AQUI)))
PERS = os.path.join(RAIZ, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'glm-5.3-flash', '39-Tiendas', 'checklist.md')
MOD = os.path.join(RAIZ, 'DOCUMENTACION', '39-Tiendas', 'plan-actual', '05-Checklist.md')
G08 = os.path.join(RAIZ, 'DOCUMENTACION', '08-GUIA-ORDEN-DE-IMPLEMENTACION.md')
BACK = os.path.join(RAIZ, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'glm-5.3-flash', 'BACKLOG-MASTER.md')
REP = os.path.join(RAIZ, 'Logs', '_alinear39.txt')

APPLY = '--apply' in sys.argv
UMBRAL = 0.80
ITEM = re.compile(r'^(\s*)- \[( |x|X|\?)\] (.*?)\s*$')
_PUNCT = "`*[]():,.;\u2013\u2014-/|\"'!?\u00bf\u00a1#<>"
TID = re.compile(r'\b(T-\d+)\b')
PAT = re.compile('\u00c3|\u00e2\u20ac|\u00f0\u0178|\u00c2[\u0080-\u00bf]')

def norm(s):
    s = unicodedata.normalize('NFKD', s)
    s = ''.join(c for c in s if not unicodedata.combining(c)).lower()
    s = TID.sub(' ', s)
    s = s.translate({ord(c): ' ' for c in _PUNCT})
    return re.sub(r'\s+', ' ', s).strip()

def leer(p):
    return io.open(p, encoding='utf-8', newline='').read()

def parse(raw):
    out = []
    for i, ln in enumerate(raw.split('\n'), 1):
        m = ITEM.match(ln.rstrip('\r'))
        if m:
            out.append({'ln': i, 'estado': m.group(2).lower(), 'texto': m.group(3), 'n': norm(m.group(3))})
    return out

def counts(items):
    x = sum(1 for i in items if i['estado'] == 'x')
    q = sum(1 for i in items if i['estado'] == '?')
    return x, len(items) - x - q, q

def p(s):
    try:
        print(s)
    except UnicodeEncodeError:
        print(s.encode('ascii', 'replace').decode('ascii'))

for ruta in (PERS, MOD, G08, BACK):
    if not os.path.exists(ruta):
        p('FALTA: ' + ruta)
        sys.exit(2)

pers_raw = leer(PERS)
mod_raw = leer(MOD)
pers = parse(pers_raw)
mod = parse(mod_raw)
px, po, pq = counts(pers)
mx, mo, mq = counts(mod)

cambios = []
sinmatch = []
buckets = [0, 0, 0, 0]
for item in pers:
    best = None
    ratio = -1.0
    for m in mod:
        r = difflib.SequenceMatcher(None, item['n'], m['n']).ratio()
        if r > ratio:
            ratio, best = r, m
    if ratio >= 0.9:
        buckets[0] += 1
    elif ratio >= 0.8:
        buckets[1] += 1
    elif ratio >= 0.6:
        buckets[2] += 1
    else:
        buckets[3] += 1
    mm = TID.search(item['texto'])
    tid = mm.group(1) if mm else item['texto'][:10]
    if best and ratio >= UMBRAL:
        if item['estado'] != best['estado']:
            cambios.append({'ln': item['ln'], 'tid': tid, 'viejo': item['estado'], 'nuevo': best['estado'], 'ratio': ratio, 'mod': best})
    else:
        sinmatch.append({'tid': tid, 'estado': item['estado'], 'ratio': ratio, 'best': best})

R = []
R.append('=== ALINEACION POR TEXTO: checklist personal glm-5.3-flash/39-Tiendas <-> modulo M39 ===')
R.append('modo=%s  umbral=%.2f  fecha=%s' % ('APPLY' if APPLY else 'dry-run', UMBRAL, __import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M')))
R.append('personal: %d items  [x]=%d  [ ]=%d  [?]=%d' % (len(pers), px, po, pq))
R.append('modulo  : %d items  [x]=%d  [ ]=%d  [?]=%d' % (len(mod), mx, mo, mq))
R.append('mejor-match: >=0.90:%d  0.80-0.90:%d  0.60-0.80:%d  <0.60:%d' % tuple(buckets))
R.append('')
R.append('--- CAMBIOS %s (%d) ---' % ('APLICADOS' if APPLY else 'PROPUESTOS', len(cambios)))
for c in cambios:
    R.append('%s [%s] -> [%s] ratio=%.2f  mod#L%d [%s] %s' % (c['tid'], c['viejo'], c['nuevo'], c['ratio'], c['mod']['ln'], c['mod']['estado'], c['mod']['texto'][:80]))
R.append('')
R.append('--- SIN MATCH (ratio<umbral, %d) ---' % len(sinmatch))
for s in sinmatch:
    if s['best']:
        R.append('%s [%s] best=%.2f mod#L%d [%s] %s' % (s['tid'], s['estado'], s['ratio'], s['best']['ln'], s['best']['estado'], s['best']['texto'][:70]))
    else:
        R.append('%s [%s] sin candidato' % (s['tid'], s['estado']))
R.append('')
R.append('--- GUIA 08: filas con 39-Tiendas (L<=120) ---')
for i, ln in enumerate(leer(G08).split('\n'), 1):
    if i <= 120 and '39-Tiendas' in ln:
        R.append('L%d cells=%d: %s' % (i, ln.count('|') - 1, ln[:220]))
R.append('')
R.append('--- SCAN MOJIBAKE ---')
for etiqueta, ruta, hi in (('guia08', G08, 120), ('backlog', BACK, 10 ** 9), ('personal', PERS, 10 ** 9)):
    hall = []
    for i, ln in enumerate(leer(ruta).split('\n'), 1):
        if i <= hi and (PAT.search(ln) or '\ufffd' in ln):
            hall.append('L%d:%s' % (i, ln[:90]))
    R.append('%s: %s' % (etiqueta, 'OK' if not hall else '%d hallazgos -> %s' % (len(hall), ' || '.join(hall[:6]))))
R.append('')

if APPLY and cambios:
    lineas = pers_raw.split('\n')
    for c in cambios:
        idx = c['ln'] - 1
        cr = lineas[idx].endswith('\r')
        m = ITEM.match(lineas[idx].rstrip('\r'))
        lineas[idx] = '%s- [%s] %s%s' % (m.group(1), c['nuevo'], m.group(3), '\r' if cr else '')
    io.open(PERS, 'w', encoding='utf-8', newline='').write('\n'.join(lineas))
    R.append('--- GUARDADO: %s (%d cambios) ---' % (os.path.relpath(PERS, RAIZ), len(cambios)))

io.open(REP, 'w', encoding='utf-8', newline='').write('\n'.join(R) + '\n')
p('reporte: ' + os.path.relpath(REP, RAIZ))
p('cambios=%d sin_match=%d buckets=%s' % (len(cambios), len(sinmatch), buckets))
if APPLY:
    pers2 = parse(leer(PERS))
    p('personal despues: [x]=%d [ ]=%d' % counts(pers2)[:2])
for c in cambios[:10]:
    p('  %s [%s]->[%s] %.2f' % (c['tid'], c['viejo'], c['nuevo'], c['ratio']))
for s in sinmatch[:10]:
    p('  SINMATCH %s [%s] %.2f' % (s['tid'], s['estado'], s['ratio']))
