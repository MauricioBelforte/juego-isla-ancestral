# -*- coding: utf-8 -*-
"""RENUMERADOR DE CANAL — SOP del proyecto (fundador 23oct 04:30)
Uso: python -X utf8 scripts/renumerar_canal.py "Mensajes entre modelos/<canal>"
Renumeracion secuencial 001..N por fecha cronologica real (estrategia del proyecto,
misma que el canal DS-OC). Genera INDICE-CANAL.md con mapping viejo->nuevo,
re-seembra el pool y resetea el puntero .ultima-revision.
"""
import io, os, re, sys, glob

base = sys.argv[1] if len(sys.argv) > 1 else '.'
if not os.path.isdir(base):
    raise SystemExit('no existe: %s' % base)

# 1) colectar (nombre real via scandir — tolera fantasmas con skip)
filas = []
for e in os.scandir(base):
    m = re.match(r'(\d{3}[B]?)-(\d{4}-\d{2}-\d{2})_(\d{2}-\d{2}-\d{2})-(.*)$', e.name)
    if e.name.endswith('.md') and m:
        try:
            size = e.stat().st_size
        except OSError:
            continue  # fantasma NTFS: fuera del sweep
        filas.append((m.group(2) + ' ' + m.group(3), m.group(4), e.name, size))

filas.sort(key=lambda x: (x[0], x[3]))
N = len(filas)

# 2) calcular nuevos nombres
plan = []
for i, (ts, resto, viejo, size) in enumerate(filas, 1):
    nuevo = '%03d-%s_%s-%s' % (i, ts[0:10], ts[11:19], resto)
    if nuevo != viejo:
        plan.append((viejo, nuevo, int(viejo[0:3]), i))
    else:
        plan.append((viejo, nuevo, int(viejo[0:3]), i))

# 3) renombrado en 2 pasadas (tmp evita colisiones)
for viejo, nuevo, o, nn in plan:
    if viejo != nuevo:
        os.rename(os.path.join(base, viejo), os.path.join(base, 'tmp__' + nuevo))
for viejo, nuevo, o, nn in plan:
    if viejo != nuevo:
        os.rename(os.path.join(base, 'tmp__' + nuevo), os.path.join(base, nuevo))

# 4) INDICE-CANAL.md con mapping
mapping = [l for l in ('%03d -> %03d | %s | %s' % (o, nn, ts, r[:80])
           for (viejo, nuevo, o, nn), (ts, r, vv, s) in
           [(p, f) for p, f in zip(plan, filas)] if str(o) != '%03d' % nn)]
indice = [
 '# INDICE-CANAL DE %s' % os.path.basename(base),
 '',
 'RENUMERACION SECUENCIAL (estrategia del proyecto: 001-%03d por fecha cronologica real).' % N,
 'Las citas historicas a numeros VIEJOS resuelven con este mapping:',
 '']
indice.extend(mapping)
indice += ['', 'Total: %d mensajes.', '', 'Firma: GLM-5.3 Flash-Director / Kilo Code.']
io.open(os.path.join('DOCUMENTACION/TAREAS-POR-MODELO/' + os.path.basename(base) if os.path.isdir('DOCUMENTACION/TAREAS-POR-MODELO/' + os.path.basename(base)) else os.path.dirname(base), 'INDICE-CANAL.md'), 'w', encoding='utf-8', newline='').write(chr(10).join(indice) + chr(10))

# 5) pool re-semebrado + puntero
io.open(os.path.join(base, 'NUMEROS_DISPONIBLES.txt'), 'w', encoding='utf-8', newline='').write(chr(10).join(str(i) for i in range(N + 1, N + 41)) + chr(10))
io.open(os.path.join(base, '.ultima-revision.txt') if not glob.glob(os.path.join(base, '.ultima-revision*.txt')) else glob.glob(os.path.join(base, '.ultima-revision*.txt'))[0], 'w', encoding='utf-8', newline='').write('%03d\n' % N)

print('OK: %d mensajes renumerados 001-%03d | pool %d-%d | INDICE-CANAL.md generado' % (N, N, N + 1, N + 40))
