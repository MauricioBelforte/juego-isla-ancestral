# -*- coding: utf-8 -*-
"""AGRUPADOR DE CANALES POR CENTENA COMPLETA — fundador 23oct 05:36
Regla: una centena (0001-0100, 0101-0200...) SOLO se archiva a subcarpeta cuando
esta COMPLETA (100 items). En la raiz queda SIEMPRE la centena EN CURSO (aunque
tenga 3 items). Uso: python -X utf8 scripts/agrupar_canal.py "Mensajes entre modelos/<canal>"
Idempotente: se puede correr en cada ciclo sin re-mover nada.
"""
import io, os, re, sys

base = sys.argv[1] if len(sys.argv) > 1 else '.'
if not os.path.isdir(base):
    raise SystemExit('no existe: %s' % base)

# 1) colectar .md numericos de primer nivel (tolerando fantasmas)
items = []
for e in os.scandir(base):
    m = re.match(r'(\d{3})-', e.name)
    if e.name.endswith('.md') and m and e.is_file():
        try:
            e.stat()
        except OSError:
            continue  # fantasma NTFS
        items.append((int(m.group(1)), e.name))

items.sort()
if not items:
    raise SystemExit('sin mensajes numerados')

max_num = items[-1][0]
centena_curso_lo = (max_num // 100) * 100 + 1

# 2) separar: centenas completas (para archivar) vs centena en curso (queda en raiz)
por_centena = {}
en_curso = []
for num, name in items:
    if num < centena_curso_lo:
        lo = ((num - 1) // 100) * 100 + 1
        hi = lo + 99
        por_centena.setdefault((lo, hi), []).append((num, name))
    else:
        en_curso.append((num, name))

# 3) verificar completitud: solo archivar centenas con 100 EXACTOS
archivables = {k: v for k, v in por_centena.items() if len(v) == 100}
incompletas = {k: v for k, v in por_centena.items() if len(v) != 100}

movidos = 0
subdirs = []
for (lo, hi), group in sorted(archivables.items()):
    dname = 'arch_%04d-%04d' % (lo, hi)
    dpath = os.path.join(base, dname)
    os.makedirs(dpath, exist_ok=True)
    for num, name in group:
        src = os.path.join(base, name)
        dst = os.path.join(dpath, name)
        if os.path.exists(src):
            try:
                os.rename(src, dst)
                movidos += 1
            except OSError:
                pass  # fantasma
    if any(os.path.isfile(os.path.join(dpath, n)) for _, n in group):
        subdirs.append(dname)

# 4) reporte
print('canal:', base)
print('centena en curso: %04d-%04d (%d en raiz)' % (centena_curso_lo, centena_curso_lo + 99, len(en_curso)))
print('centenas archivadas:', [('%04d-%04d' % k) for k in sorted(archivables.keys())])
print('centenas incompletas (no archivables, quedan en raiz):', [('%04d-%04d (%d/100)' % (k[0], k[1], len(v))) for k, v in sorted(incompletas.items())])
print('movidos este diario:', movidos, '| subcarpetas creadas:', len(subdirs))
print('estado: idempotente — correr de nuevo no re-mueve')
