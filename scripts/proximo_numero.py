"""proximo_numero.py — helper OBLIGATORIO de numeración de mensajes (directiva del fundador 2026-10-17 08:39).

USO:
    python scripts/proximo_numero.py <canal>            # imprime el próximo número + estado del pool + auditoría
    python scripts/proximo_numero.py <canal> --consume  # además consume el próximo número del pool

Reglas que aplica (sin excepciones, NUNCA numerar a mano):
  1. próximo número = MÁXIMO prefijo existente en el canal + 1 (revisa .md con prefijo NNN-).
  2. valida el pool NUMEROS_DISPONIBLES.txt: números del pool que YA están usados en el canal
     se remueven automáticamente (colisión detectada = aviso).
  3. reporta huecos del hilo (informativo) y duplicados.
"""
import io, os, re, sys

RAIZ = 'Mensajes entre modelos'


def audit(canal, consumir=False):
    d = os.path.join(RAIZ, canal)
    if not os.path.isdir(d):
        print('CANAL NO EXISTE:', canal)
        return None
    usados = set()
    for root, _dirs, fs in os.walk(d):
        for f in fs:
            m = re.match(r'^(\d{3})-', f)
            if m:
                usados.add(int(m.group(1)))
    mx = max(usados) if usados else 0
    nxt = mx + 1

    pool_path = os.path.join(d, 'NUMEROS_DISPONIBLES.txt')
    pool = []
    if os.path.exists(pool_path):
        pool = [l.strip() for l in io.open(pool_path, encoding='utf-8-sig').read().splitlines() if l.strip()]
    colisiones = [l for l in pool if int(l) in usados]
    if colisiones:
        pool = [l for l in pool if int(l) not in usados]
        io.open(pool_path, 'w', encoding='utf-8', newline='\n').write('\n'.join(pool) + '\n')
        print('[FIX] pool de %s tenía números ya usados (%s) — removidos automáticamente' % (canal, ','.join(colisiones)))
    if nxt not in [int(l) for l in pool] and pool_path and os.path.exists(pool_path) and str(nxt) not in pool:
        print('[AVISO] el próximo (%d) NO está en el pool — agregarlo antes de escribir' % nxt)

    huecos = sorted(set(range(1, mx + 1)) - usados) if mx else []
    print('canal: %s | mensajes usados: %d | max: %d' % (canal, len(usados), mx))
    print('  PRÓXIMO NÚMERO: %d' % nxt)
    if huecos:
        print('  huecos (informativo, NO reutilizar):', huecos[:12], '...' if len(huecos) > 12 else '')
    print('  pool: %d nums | cabeza: %s | del próximo en adelante en pool: %s' % (
        len(pool), pool[0] if pool else '-', 'SÍ' if str(nxt) in pool else 'NO'))

    if consumir and os.path.exists(pool_path):
        if str(nxt) in pool:
            pool.remove(str(nxt))
            io.open(pool_path, 'w', encoding='utf-8', newline='\n').write('\n'.join(pool) + '\n')
            print('  consumido %d del pool. El archivo NUEVO debe llamarse: %03d-<AAAA-MM-DD_HH-MM-SS>-de-<emisor>-a-<receptor>-tema.md' % (nxt, nxt))
        else:
            print('  [AVISO] %d no estaba en el pool; agregalo al escribir' % nxt)
    return nxt


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    audit(sys.argv[1], consumir='--consume' in sys.argv)
