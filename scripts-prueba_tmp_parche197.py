# -*- coding: utf-8 -*-
"""Parchea el backtick colado en acuse197.py (evitando escapes problematicos)."""
import io

p = 'scripts-prueba_tmp_acuse197.py'
t = io.open(p, encoding='utf-8').read()
bad = 'fundador.' + chr(96) + chr(39)
good = 'fundador.' + chr(39)
assert bad in t, 'patron no hallado'
t = t.replace(bad, good, 1)
io.open(p, 'w', encoding='utf-8', newline='').write(t)
print('backtick eliminado OK')
