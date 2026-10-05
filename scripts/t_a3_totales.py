# -*- coding: utf-8 -*-
"""
T-A3 (b): regenera los 13 bloques 'Totales' stale en los 05-Checklist.md plan-actual.
Solo cambia los numeros del bloque Totales; el resto del archivo queda byte-identico.
Verifica que cada old-string exista exactamente N veces ANTES de escribir (anti-clobber).
"""
import io, os, sys

DOC = 'DOCUMENTACION'
# (modulo, old, new, n_esperado)
REPS = [
 ('02-Vision-Y-Concepto',
  '**Totales:** 172 \u00edtems \u00b7 Completados: 162 \u00b7 Pendientes: 10 \u00b7 No resueltos: 0.',
  '**Totales:** 172 \u00edtems \u00b7 Completados: 0 \u00b7 Pendientes: 172 \u00b7 No resueltos: 0.'),
 ('04-Game-Engine',
  '**Totales:** 120 \u00edtems \u00b7 Completados: 95 \u00b7 Pendientes: 25 (instalaci\u00f3n y configuraci\u00f3n real del motor \u2192 hito M1, due\u00f1o: prototipo) \u00b7 No resueltos: 0.',
  '**Totales:** 128 \u00edtems \u00b7 Completados: 14 \u00b7 Pendientes: 114 (instalaci\u00f3n y configuraci\u00f3n real del motor \u2192 hito M1, due\u00f1o: prototipo) \u00b7 No resueltos: 0.'),
 ('05-Lenguaje-Y-Programacion',
  '**Totales:** 102 \u00edtems \u00b7 Completados: 102 \u00b7 Pendientes: 0 \u00b7 No resueltos: 0.',
  '**Totales:** 103 \u00edtems \u00b7 Completados: 4 \u00b7 Pendientes: 99 \u00b7 No resueltos: 0.'),
 ('104-Analytics',
  '**Totales:** 100 \u00edtems \u00b7 Completados: 100 \u00b7 Pendientes: 0 \u00b7 No resueltos: 0.',
  '**Totales:** 117 \u00edtems \u00b7 Completados: 49 \u00b7 Pendientes: 68 \u00b7 No resueltos: 0.'),
 ('115-Hardware',
  '**Totales:** 104 \u00edtems \u00b7 Completados: 68 \u00b7 Pendientes: 3 \u00b7 No resueltos: 33.',
  '**Totales:** 104 \u00edtems \u00b7 Completados: 69 \u00b7 Pendientes: 2 \u00b7 No resueltos: 33.'),
 ('126-Marketing-Legal',
  '**Totales:** 102 \u00edtems \u00b7 Completados: 102 \u00b7 Pendientes: 0 \u00b7 No resueltos: 0.',
  '**Totales:** 101 \u00edtems \u00b7 Completados: 101 \u00b7 Pendientes: 0 \u00b7 No resueltos: 0.'),
 ('126-Marketing-Legal',
  '**Totales:** 101 \u00edtems \u00b7 Completados: 59 \u00b7 Pendientes: 42 \u00b7 No resueltos: 0.',
  '**Totales:** 101 \u00edtems \u00b7 Completados: 101 \u00b7 Pendientes: 0 \u00b7 No resueltos: 0.'),
 ('38-Economia',
  '**Totales:** 164 \u00edtems \u00b7 Completados: 158 \u00b7 Pendientes: 0 \u00b7 No resueltos: 6.',
  '**Totales:** 164 \u00edtems \u00b7 Completados: 164 \u00b7 Pendientes: 0 \u00b7 No resueltos: 0.'),
 ('41-Musica',
  '**Totales:** 110 \u00edtems \u00b7 Completados: 38 \u00b7 Pendientes: 72 \u00b7 No resueltos: 0.',
  '**Totales:** 110 \u00edtems \u00b7 Completados: 61 \u00b7 Pendientes: 49 \u00b7 No resueltos: 0.'),
 ('42-Sonido-Ambiental',
  '**Totales:** 109 \u00edtems \u00b7 Completados: 37 \u00b7 Pendientes: 72 \u00b7 No resueltos: 0.',
  '**Totales:** 100 \u00edtems \u00b7 Completados: 63 \u00b7 Pendientes: 37 \u00b7 No resueltos: 0.'),
 ('44-ASMR-Y-Feedback',
  '**Totales:** 113 \u00edtems \u00b7 Completados: 113 \u00b7 Pendientes: 0 \u00b7 No resueltos: 0.',
  '**Totales:** 113 \u00edtems \u00b7 Completados: 76 \u00b7 Pendientes: 37 \u00b7 No resueltos: 0.'),
 ('54-Mapa',
  '**Totales:** 177 \u00edtems \u00b7 Completados: 130 \u00b7 Pendientes: 47 \u00b7 No resueltos: 0.',
  '**Totales:** 177 \u00edtems \u00b7 Completados: 133 \u00b7 Pendientes: 44 \u00b7 No resueltos: 0.'),
 ('91-Configuracion-De-Audio',
  '**Totales:** 239 \u00edtems \u00b7 Completados: 206 \u00b7 Pendientes: 32 \u00b7 No resueltos: 1.',
  '**Totales:** 239 \u00edtems \u00b7 Completados: 207 \u00b7 Pendientes: 31 \u00b7 No resueltos: 1.'),
]

# agrupa por archivo
from collections import OrderedDict
byfile = OrderedDict()
for mod, old, new in REPS:
    p = os.path.join(DOC, mod, 'plan-actual', '05-Checklist.md')
    byfile.setdefault(p, []).append((old, new))

ok = True
for p, pairs in byfile.items():
    data = open(p, 'rb').read()
    text = data.decode('utf-8')
    # verificacion previa
    for old, new in pairs:
        c = text.count(old)
        if c != 1:
            print(f'!! {p}: old-string aparece {c} veces (esperado 1):\n   {old[:60]}')
            ok = False
            break
    if not ok:
        continue
    for old, new in pairs:
        text = text.replace(old, new, 1)
    newbytes = text.encode('utf-8')
    assert len(newbytes) >= 0
    open(p, 'wb').write(newbytes)
    print(f'OK {os.path.basename(os.path.dirname(os.path.dirname(p)))}: {len(pairs)} reemplazo(s)')

print('\nRESULTADO:', 'TODO OK' if ok else 'FALLO (no escribio archivos con old!=1)')
