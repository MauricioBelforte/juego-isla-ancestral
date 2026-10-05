# -*- coding: utf-8 -*-
import re
p = r'DOCUMENTACION/152-Principios-Innegociables/plan-actual/05-Checklist.md'
t = open(p, 'rb').read().decode('utf-8')

old1 = '- [?] No ampliar el mapa solamente para hacerlo grande'
new1 = ('- [x] No ampliar el mapa solamente para hacerlo grande '
        '- **D-R2 APROBADA por el fundador 2026-10-05** (ampliacion parcial 2/3 patas; '
        'ver `desviaciones_justificadas.md`). Registro cerrado por decision del fundador '
        '(canal agnes-3-flash arch. 38), no por analisis propio.')
assert t.count(old1) == 1, ('old1', t.count(old1))
t = t.replace(old1, new1)

old2 = 'No ampliar el mapa por hacerlo grande** | `[?]`'
new2 = 'No ampliar el mapa por hacerlo grande** | `[x]` (D-R2 aprobada por el fundador 2026-10-05)'
assert t.count(old2) == 1, ('old2', t.count(old2))
t = t.replace(old2, new2)

old3 = '**Totales:** 202 ítems · Completados: 201 · No resueltos: 1 (D-R2 — fundador) · Pendientes: 0.'
new3 = ('**Totales:** 202 ítems · Completados: 202 · No resueltos: 0 · Pendientes: 0. '
        '(D-R2 aprobada por el fundador 2026-10-05; M152 en 🟡 hasta QA §21.8 de Hy3 T-H5).')
assert t.count(old3) == 1, ('old3', t.count(old3))
t = t.replace(old3, new3)

open(p, 'wb').write(t.encode('utf-8'))
marks = re.findall(r'(?m)^\s*[-*]\s*\[(x| |X|\?)\]', t)
print('[x]=', sum(1 for m in marks if m in ('x','X')),
      '[?]=', sum(1 for m in marks if m == '?'),
      '[ ]=', sum(1 for m in marks if m == ' '))
print('OK checklist M152 cerrado [?]')
