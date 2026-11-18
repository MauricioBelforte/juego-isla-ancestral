"""Exploracion de claims numericos compartidos para cross-doc (backlog 19). Solo lectura."""
from pathlib import Path
import re
from collections import defaultdict

D = Path('DOCUMENTACION')
GRUPOS = {
1:['08','09','10','167','168'], 2:['11','12','16','07','04'], 3:['29','30','31','32','09'],
4:['33','34','35','15','16'], 5:['38','39','74','71','17'], 6:['108','169','68','27','28'],
7:['112','111','101','102','154'], 8:['03','06','21','22','23'], 9:['106','100','121','120','99'],
10:['90','91','88','47','52'],
}
CLAVE = re.compile(r'(radio|chunk|lod|d[ií]a|a[nñ]o|mes|estaci[oó]n|bioma|tier|nivel|cap[ií]tulo|final|isla|ruta|bus|FPS|ms|textura|fuente|font|vecino|hito|stock|precio|puerto|pasajero)', re.I)
NUM = re.compile(r'\d')

for g, ids in GRUPOS.items():
    print('=' * 90)
    print('GRUPO', g)
    por_clave = defaultdict(list)
    for mid in ids:
        ds = [d for d in D.iterdir() if d.is_dir() and d.name.startswith(mid + '-')]
        if not ds:
            continue
        d = ds[0]
        for doc in sorted((d / 'plan-actual').glob('0[1-5]-*.md')):
            for i, l in enumerate(doc.read_text(encoding='utf-8', errors='replace').splitlines(), 1):
                if not NUM.search(l):
                    continue
                ms = CLAVE.findall(l)
                if not ms:
                    continue
                clave = ms[0].lower()
                texto = re.sub(r'\s+', ' ', l.strip())[:150]
                por_clave[clave].append(('M' + mid, doc.name, i, texto))
    # mostrar claves compartidas por al menos 2 modulos distintos
    Shared = []
    for k, v in por_clave.items():
        mods = {x[0] for x in v}
        if len(mods) >= 2 and len(v) >= 3:
            Shared.append((len(mods), k, v))
    Shared.sort(key=lambda x: -x[0])
    for nmods, k, v in Shared[:5]:
        print(' CLAVE', k, '| modulos', nmods, '| lineas', len(v))
        for x in v[:6]:
            print('   ', x[0], x[1] + ':' + str(x[2]), x[3][:125])
