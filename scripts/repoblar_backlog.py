# -*- coding: utf-8 -*-
"""repoblar_backlog.py — repuebla el BACKLOG-MASTER de un agente con items REALES
de los 05-Checklist de sus modulos + escaneo de trabajo disponible en TODA la flota."""
import io, os, re
import glob as _globmod

SKIP_KW = ['arte', 'visual', 'vision', 'monetiza', 'lanzamie', 'postgame', 'prototipo', 'vertical-slice', 'fundamentos', 'creditos', 'islas']

def escanear_disponibles():
    resultado = []
    for g in sorted(_globmod.glob('DOCUMENTACION/*-*/plan-actual/05-Checklist.md')):
        mod = g.replace(os.sep, '/').split('/')[1]
        if any(kw.lower() in mod.lower() for kw in SKIP_KW):
            continue
        try:
            t = io.open(g, encoding='utf-8-sig', errors='replace').read()
            libres = len(re.findall(r'(?m)^- \[ \]', t))
            if libres > 0:
                resultado.append((mod, g, libres))
        except Exception:
            pass
    resultado.sort(key=lambda x: -x[2])
    return resultado

def asignar_mejor_match(carpeta, min_pend=100):
    blp = os.path.join('DOCUMENTACION', 'TAREAS-POR-MODELO', carpeta, 'BACKLOG-MASTER.md')
    usados = set()
    if os.path.isfile(blp):
        blt = io.open(blp, encoding='utf-8-sig').read()
        usados = set(re.findall(r'<!-- fuente: (\S+)/05-Checklist', blt))
    disponibles = [x for x in escanear_disponibles() if x[0].split('-')[0] not in usados]
    return [x[0] for x in disponibles[:10]]

# --- FLUJO PRINCIPAL ---
carpeta = os.sys.argv[1].strip()
mods_arg = os.sys.argv[2].split(',') if len(os.sys.argv) > 2 else []
cota = int(os.sys.argv[os.sys.argv.index('--cota') + 1]) if '--cota' in os.sys.argv else 100

BLP = os.path.join('DOCUMENTACION', 'TAREAS-POR-MODELO', carpeta, 'BACKLOG-MASTER.md')
bl = io.open(BLP, encoding='utf-8-sig', errors='replace').read()

tenidos = set(re.sub(r'\W+', '', l.lower())[:80] for l in bl.splitlines() if len(l.strip()) > 10)
pend_act = len(re.findall(r'(?m)^-?\s*\[ \]', bl))

lineas = []
no_encontrados = []
mods_limpios = []
for mod in mods_arg:
    g = (_globmod.glob('DOCUMENTACION/' + mod + '-*/plan-actual/05-Checklist.md') or
         _globmod.glob('DOCUMENTACION/' + mod + '-*/plan-actual/05-Checklist.md'))
    if not g:
        no_encontrados.append(mod)
        continue
    pp = g[0]
    tt = io.open(pp, encoding='utf-8-sig', errors='replace').read()
    found = 0
    for it in re.finditer(r'(?m)^- \[ \]\s*(.+)$', tt):
        txt = re.sub(r'\s+', ' ', it.group(1)).strip()[:150]
        clave = re.sub(r'\W+', '', txt.lower())[:80]
        if clave in tenidos:
            continue
        tenidos.add(clave)
        fuente = os.path.basename(os.path.dirname(os.path.dirname(pp)))
        lineas.append('- [ ] [%s] %s <!-- fuente: %s/05-Checklist.md -->' % (mod, txt, fuente))
        found += 1
    if found > 0:
        mods_limpios.append('%s(%d)' % (mod, found))

if not lineas:
    print('Sin items nuevos. no_encontrados:', no_encontrados)
else:
    pend_post = pend_act + len(lineas)
    if pend_post >= cota:
        print('OK: %s queda con %d pendientes (>= %d)' % (carpeta, pend_post, cota))
    else:
        print('AVISO: %s queda con %d pendientes (< %d)' % (carpeta, pend_post, cota))

    # Detectar si ya existe una seccion REPOBLACION V3 — anexar a la ultima
    m_ol = list(re.finditer(r'(?m)^## REPOBLACION V3[^\n]*$', bl))
    if m_ol:
        ancla = m_ol[-1]
        elemento_n = [str(i) + '. ' + l for i, l in enumerate(lineas, 1)]
        t = bl[:ancla.end()] + '\n' + '\n'.join(elemento_n) + bl[ancla.end():]
    else:
        sec_header = '\n\n## REPOBLACION V3 (' + __import__('datetime').datetime.now().isoformat(timespec='seconds') + ')'
        sec = [sec_header, '']
        for i, l in enumerate(lineas, 1):
            sec.append(str(i) + '. ' + l)
        sec.append('')
        t = bl.rstrip() + '\n' + '\n'.join(sec)

    io.open(BLP, 'w', encoding='utf-8', newline='\n').write(t)
    raw = io.open(BLP, 'rb').read()
    raw.decode('utf-8', errors='strict')
    print('%s: +%d items | mods: %s | no_encontrados: %s | sin BOM: %s' % (
        carpeta, len(lineas), set(l.split(']')[0] + ']' for l in lineas),
        no_encontrados, not raw.startswith(b'\xef\xbb\xbf')))
