import os

def sync_totales(path, old_frag, new_frag, expect):
    raw = open(path, 'rb').read()
    lines = raw.splitlines(keepends=True)  # split por bytes: solo \r, \n, \r\n
    hits = [i for i, l in enumerate(lines) if expect in l.decode('utf-8', errors='replace')]
    assert len(hits) == 1, (path, expect, hits)
    idx = hits[0]
    old = lines[idx].decode('utf-8')
    assert old.count(old_frag) == 1, (path, old_frag)
    new = old.replace(old_frag, new_frag)
    eol = '\r\n' if lines[idx].endswith(b'\r\n') else '\n'
    new = new.rstrip('\r\n') + eol
    lines[idx] = new.encode('utf-8')
    open(path, 'wb').write(b''.join(lines))
    chk = open(path, 'rb').read()
    print('%s: bytes %d -> %d | CR %d | LF %d | linea %d' % (os.path.basename(os.path.dirname(os.path.dirname(path))), len(raw), len(chk), chk.count(b'\r'), chk.count(b'\n'), idx + 1))

# M90: 245/0/4 -> 249/0/0
sync_totales(
    'DOCUMENTACION/90-Configuracion-Grafica/plan-actual/05-Checklist.md',
    'Completados: 245 - Pendientes: 0 - No resueltos: 4.',
    'Completados: 249 - Pendientes: 0 - No resueltos: 0. (Sync final 2026-10-20: el director aplico los ultimos 4 flips [?]->[x] de la tanda Log 2040 -> 249 [x] / 0 [?] / 0 [ ] = 249, medido por prefijo de linea HOY 2026-10-20 Log 2049; linea vigente aca.)',
    'Completados: 245')

# M11: 75/0/48 -> 78/0/45
sync_totales(
    'DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md',
    'Completados: 75 - Pendientes: 0 - No resueltos: 48.',
    'Completados: 78 - Pendientes: 0 - No resueltos: 45. (Sync 2026-10-20: 3 flips [?]->[x] de L45/L98/L71 aplicados por el director (tanda Log 2040) -> 78 [x] / 45 [?] / 0 [ ] = 123, medido por prefijo de linea HOY 2026-10-20 Log 2049.)',
    'Completados: 75')
