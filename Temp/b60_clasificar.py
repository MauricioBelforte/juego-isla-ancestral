# -*- coding: utf-8 -*-
"""Clasifica cada [?] de los 10 modulos segun el texto del propio item.
Categorias:
  known      -> etiqueta KnownIssue / DEGRADADO / fase posterior / post-release
  bloqueado  -> GATE-1 / AUDIT / deuda cross-modulo / PREGUNTA FUNDADOR / NO existe / 0 hits / sin artefacto
  candidato  -> sin etiqueta de bloqueo; requiere verificacion en disco
"""
import os, re, json, collections
ROOT = os.path.abspath('.')
DOC = os.path.join(ROOT, 'DOCUMENTACION')

TARGETS = {
    '75': 'Postgame', '156': 'Terrenos', '74': 'Eventos', '73': 'Coleccionables',
    '71': 'Progresion', '27': 'Islas', '159': 'Catalogo', '49': 'Iluminacion',
    '115': 'Hardware', '105': 'Telemetria',
}

KNOWN = re.compile(r'KnownIssue|DEGRADADO|fase posterior|post-release|post release|no bloqueante', re.I)
BLOCK = re.compile(
    r'GATE-1|AUDIT\b|deuda cross|dueño es M|PREGUNTA PARA EL FUNDADOR|sin artefacto|'
    r'NO existe|0 hits|sin evidencia|bloquead|requiere (?:datos|volumen|decision|aprobacion)|'
    r'fase (?:posterior|futura)|diferido|pendiente de', re.I)


def find_checklist(mid):
    pre = mid + '-'
    for d in sorted(os.listdir(DOC)):
        if d.startswith(pre):
            cp = os.path.join(DOC, d, 'plan-actual', '05-Checklist.md')
            if os.path.isfile(cp):
                return cp
    return None


result = {}
for mid in TARGETS:
    cp = find_checklist(mid)
    lines = open(cp, encoding='utf-8', errors='replace').read().splitlines()
    cats = collections.Counter()
    items = []
    for i, l in enumerate(lines, 1):
        if not re.match(r'^\s*-\s*\[\?\]', l):
            continue
        t = l.strip()
        if KNOWN.search(t):
            cat = 'known'
        elif BLOCK.search(t):
            cat = 'bloqueado'
        else:
            cat = 'candidato'
        cats[cat] += 1
        items.append({'line': i, 'cat': cat, 'text': t[:220]})
    result[mid] = {'path': os.path.relpath(cp, ROOT).replace('\\', '/'),
                   'total': sum(cats.values()), 'cats': dict(cats), 'items': items}

json.dump(result, open('Temp/b60_clasificacion.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print('MODULO        TOTAL  known  bloqueado  candidato')
for mid, v in result.items():
    c = v['cats']
    print('M%-4s %-10s %5d  %5d  %5d  %5d' % (
        mid, TARGETS[mid][:10], v['total'], c.get('known', 0),
        c.get('bloqueado', 0), c.get('candidato', 0)))
tot = collections.Counter()
for v in result.values():
    tot.update(v['cats'])
print('-' * 46)
print('TOTAL', sum(tot.values()), dict(tot))
