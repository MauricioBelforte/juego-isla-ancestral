# -*- coding: utf-8 -*-
"""Clasifica las notas de los 49 [?] de M31 para la reverificacion."""
import io

items = [l.rstrip('\n') for l in io.open('m31_items.txt', encoding='utf-8').read().splitlines() if l.strip()]
res = []
for it in items:
    n, txt = it.split('\t', 1)
    titulo = txt.split('|')[0].replace('- [?]', '').strip()
    nota = txt.split('|')[1].strip() if '|' in txt else ''
    res.append((int(n), titulo, nota))

MARCA_NEG = ['no existe', 'sin implementar', '0 hits', 'no esta', 'no verificable',
             'parcial', 'inexistente', 'no se ve', 'no implementado', 'sin datos']

correctas = []
revisar = []
for n, t, nota in res:
    tlow = (t + ' ' + nota).lower()
    if any(m in tlow for m in MARCA_NEG):
        correctas.append((n, t, nota))
    else:
        revisar.append((n, t, nota))

out = io.open('m31_clasif.txt', 'w', encoding='utf-8', newline='\n')
out.write('Notas que YA declaran no-existencia/parcialidad (mantienen [?]): %d\n' % len(correctas))
out.write('Notas sin marca negativa, a revisar manualmente: %d\n\n' % len(revisar))
for n, t, nota in revisar:
    out.write('L%d %s\n' % (n, t[:110]))
    out.write('    %s\n\n' % (nota[:210] if nota else '(sin nota)'))
out.close()
print('correctas: %d | a revisar: %d' % (len(correctas), len(revisar)))
