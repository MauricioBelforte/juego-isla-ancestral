#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Errata autorizada en msj 127: etiquetas de logs 2432/2434 y backlogs 36/41."""
import os, re, glob

ROOT = os.path.abspath('.')
OLD = 'claim de ausencia inexacto: archivo citado SI existe'
NEW = 'causa imprecisa (retractada en 118, corregida por directora en 120)'
NOTE_LOG = (
    'NOTA DE ERRATA (msj 118 retractacion / msj 120 correccion / msj 127 GO): las etiquetas '
    '"archivo SI existe / falsos negativos resueltos" eran imprecisas. El archivo citado puede '
    'existir, pero la funcionalidad pedida NO fue verificada. Solo cambian etiquetas: marcas, '
    'conteos y evidencia original quedan intactos.\n'
)
NOTE_MD = (
    '> **Errata (GO director msj 127):** las etiquetas "archivo citado SI existe / falsos '
    'negativos resueltos" se reclasifican como **causa imprecisa** (retractacion msj 118, '
    'correccion msj 120). El archivo citado puede existir; la funcionalidad pedida no fue '
    'verificada. Marcas y conteos NO se modifican.\n\n'
)

def log_path(n):
    return glob.glob(os.path.join(ROOT, 'Logs', '%d-*.md' % n))[0]

def read_bytes(p):
    return open(p, 'rb').read()

def write_log_ascii(p, text):
    text = text.replace('\r\n', '\n')
    lines = text.split('\n')
    out = '\r\n'.join(lines) + '\r\n'
    open(p, 'wb').write(out.encode('ascii'))

for n in (2432, 2434):
    p = log_path(n)
    b = read_bytes(p)
    assert all(c < 128 for c in b), p
    assert b.count(b'\r\n') == b.count(b'\n'), p
    txt = b.decode('ascii').replace('\r\n', '\n')
    if 'NOTA DE ERRATA (msj 118' not in txt:
        lines = txt.split('\n')
        lines.insert(1, NOTE_LOG.rstrip('\n'))
        txt = '\n'.join(lines)
    reps = {
        "10 items decian 'no existe tal archivo' pero el archivo SI existe en disco":
            '10 items con causa imprecisa: el archivo citado puede existir; la funcionalidad pedida no fue verificada',
        "(island_generator.gd, audio_config_service.gd, validate_vehicles.gd...).":
            'Ejemplos citados: island_generator.gd, audio_config_service.gd, validate_vehicles.gd (no verificados como archivo pedido).',
        "Se corrigio la causa a 'claim de ausencia inexacto: archivo existe, falta la\nfuncionalidad'. Sin esta verificacion se habrian consignado 10 falsedades.":
            "Causa corregida a 'causa imprecisa: funcionalidad pedida no verificada' (errata msj 118/120/127).",
        "24 items con 'no existe' citaban archivos que SI existen: corregidos\na 'claim de ausencia inexacto, falta la funcionalidad'.":
            "24 items con 'no existe': causa imprecisa; el archivo citado puede existir, la funcionalidad pedida no fue verificada (errata 118/120/127).",
        '10  claim de ausencia inexacto: archivo citado SI existe, la funcionalidad/claim es lo que falta':
            '10  causa imprecisa: el archivo citado puede existir, la funcionalidad pedida no fue verificada',
        '24  claim de ausencia inexacto: archivo citado SI existe, falta funcionalidad':
            '24  causa imprecisa: el archivo citado puede existir, la funcionalidad pedida no fue verificada',
    }
    for a, c in reps.items():
        txt = txt.replace(a, c)
    txt = txt.replace(OLD, NEW)
    write_log_ascii(p, txt)
    print(n, 'restantes OLD:', txt.count(OLD))

for fn in ['36-Backlog-RootCause-Q-Markas.md', '41-Backlog-RootCause-Q-Remaining.md']:
    p = os.path.join(ROOT, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'HY4 Flash', 'BACKLOGS', fn)
    s = open(p, encoding='utf-8').read()
    x_before = len(re.findall(r'(?m)^\s*- \[x\]', s))
    if '> **Errata (GO director msj 127):**' not in s:
        lines = s.split('\n')
        # tras titulo y cabecera, antes del primer contenido
        lines.insert(2, NOTE_MD.rstrip('\n'))
        s = '\n'.join(lines)
    s = s.replace(OLD + ', f', NEW).replace(OLD, NEW)
    x_after = len(re.findall(r'(?m)^\s*- \[x\]', s))
    assert x_before == x_after, (fn, x_before, x_after)
    open(p, 'wb').write(s.replace('\r\n', '\n').encode('utf-8'))
    print(fn, 'x', x_before, '->', x_after, 'restantes OLD:', s.count(OLD))

# verificacion final de formatos
for n in (2432, 2434):
    b = read_bytes(log_path(n))
    print('log', n, 'ASCII', all(c < 128 for c in b),
          'CRLF', b.count(b'\r\n'), 'LF suelto', b.count(b'\n') - b.count(b'\r\n'),
          'BOM', b[:3] == b'\xef\xbb\xbf')
