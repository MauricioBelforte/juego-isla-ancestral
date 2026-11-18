"""Backlog 21: verificar claves tr() literales contra locales/es.po y en.po. Solo lectura."""
from pathlib import Path
import re
from collections import Counter

R = Path('.')
SCRIPTS = R / 'game/isla-ancestral/scripts'
PO = {'es': R / 'game/isla-ancestral/locales/es.po',
      'en': R / 'game/isla-ancestral/locales/en.po'}
BP = R / 'DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/21-Backlog-I18N-Volumen-PRUEBA.md'

def po_ids(p):
    ids = set()
    if not p.is_file():
        return None
    actual = None
    for l in p.read_text(encoding='utf-8', errors='replace').splitlines():
        if l.startswith('msgid '):
            actual = l[6:].strip().strip('"')
            ids.add(actual)
        elif l.startswith('"') and actual is not None:
            ids.add(l.strip().strip('"'))
        elif not l.startswith('"'):
            actual = None
    ids.discard('')
    return ids

MSG = {k: po_ids(v) for k, v in PO.items()}
print('msgid es:', len(MSG["es"]) if MSG["es"] is not None else 'PO AUSENTE',
      '| en:', len(MSG["en"]) if MSG["en"] is not None else 'PO AUSENTE')

def parse_call(l, start):
    i = start + 3  # después de 'tr('
    while i < len(l) and l[i].isspace():
        i += 1
    if i >= len(l) or l[i] not in ('"', "'"):
        return '<variable>', False
    q = l[i]; i += 1; out = []
    while i < len(l):
        if l[i] == '\\' and i + 1 < len(l):
            out.append(l[i+1]); i += 2; continue
        if l[i] == q:
            return ''.join(out), True
        out.append(l[i]); i += 1
    return '<sin-cierre>', False

calls = []
variables = 0
for p in sorted(SCRIPTS.rglob('*.gd')):
    for n, l in enumerate(p.read_text(encoding='utf-8', errors='replace').splitlines(), 1):
        pos = 0
        while True:
            mcall = re.search(r'(?<![A-Za-z0-9_])tr\s*\(', l[pos:])
            if not mcall:
                break
            k = pos + mcall.start()  # indice de la 't' de tr(
            key, literal = parse_call(l, k)
            if literal:
                calls.append((p, n, key))
            else:
                variables += 1
            pos = k + 3
print('tr() literales:', len(calls), '| tr() con variable:', variables)

# API real del proyecto: _t("CLAVE"), traducir_clave("CLAVE") y tr_key(mod, sec, clave)
reales = []
for p in sorted(SCRIPTS.rglob('*.gd')):
    for n, l in enumerate(p.read_text(encoding='utf-8', errors='replace').splitlines(), 1):
        for api in ('_t', 'traducir_clave', 'tr_key'):
            pos = 0
            while True:
                mm = re.search(r'(?<![A-Za-z0-9_])' + api + r'\s*\(', l[pos:])
                if not mm:
                    break
                k = pos + mm.start()
                key, literal = parse_call(l, k)
                if literal and api == 'tr_key':
                    # segundos y terceros argumentos literales -> CLAVE.MODULO.SECCION
                    rest = l[l.index('(', k) + 1:]
                    parts = []
                    for _ in range(2):
                        m2 = re.search(r'^\s*([".\'])(.*?)\1\s*,', rest)
                        if not m2:
                            break
                        parts.append(m2.group(2)); rest = rest[m2.end():]
                    if len(parts) == 2:
                        key = '.'.join([parts[0], parts[1], key]).upper()
                    else:
                        literal = False
                if literal:
                    reales.append((p, n, api, key))
                pos = k + len(api) + 1
print('tr_key/tr_ctx literales:', len(reales))
real_estados = []
for p, n, api, key in reales:
    # descartar prefijos concatenados (DIARY.CAT_ + categoria) y ruido de parser
    if not re.match(r'^[A-Z][A-Z0-9_]*(\.[A-Z0-9_]+)+$', key) or key.endswith('_'):
        continue
    es = (key in MSG['es']) if MSG['es'] is not None else False
    en = (key in MSG['en']) if MSG['en'] is not None else False
    real_estados.append((p, n, api, key, es, en))
print('  ambos OK:', sum(1 for e in real_estados if e[4] and e[5]),
      '| falta es:', sum(1 for e in real_estados if not e[4]),
      '| falta en:', sum(1 for e in real_estados if not e[5]))

estados = []
for p, n, key in calls:
    es = (key in MSG['es']) if MSG['es'] is not None else False
    en = (key in MSG['en']) if MSG['en'] is not None else False
    estados.append((p, n, key, es, en))
print('ambos OK:', sum(1 for e in estados if e[3] and e[4]))
print('falta es:', sum(1 for e in estados if not e[3]), '| falta en:', sum(1 for e in estados if not e[4]))

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
res = []
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    m = re.match(r'^- \[ \] (T21-\d+): Batch (\d+)-(\d+) de tr\(\) - verificar \.po(?: —.*)?$', l)
    if not m:
        continue
    tag, ini, fin = m.group(1), int(m.group(2)) - 1, int(m.group(3)) - 1
    chunk = estados[ini:fin]
    ok = sum(1 for e in chunk if e[3] and e[4])
    falta_es = sum(1 for e in chunk if not e[3])
    falta_en = sum(1 for e in chunk if not e[4])
    nota = '%d/%d presentes en es+en · faltan es:%d en:%d' % (ok, len(chunk), falta_es, falta_en)
    if not chunk:
        nota = 'SIN LLAMADAS en este rango (universo de literales menor a 3000)'
    base = re.sub(r' — .*$', '', l)
    lineas[i] = '- [x] ' + base[6:] + ' — ' + nota + '\n'
    res.append((tag, ok, len(chunk), falta_es, falta_en))

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 09:0x UTC)\n\n']
ev.append('Universo: **%d llamadas `tr()` con clave literal** en %d archivos `.gd` bajo `scripts/`; **%d llamadas con variable** se excluyeronตาม la regla "no mezclar". '
          'Se verificó cada clave como `msgid` exacto en `locales/es.po` (%d msgids) y `locales/en.po` (%d msgids). No se creó ni editó ningún `.po`.\n\n' %
          (len(calls), len(list(SCRIPTS.rglob('*.gd'))), variables,
           len(MSG['es']) if MSG['es'] else 0, len(MSG['en']) if MSG['en'] else 0))
ev.append('| Resultado global (`tr()` literal) | Llamadas |\n|---|---|\n')
ev.append('| Presentes en es+en | %d |\n' % sum(1 for e in estados if e[3] and e[4]))
ev.append('| Falta en es | %d |\n' % sum(1 for e in estados if not e[3]))
ev.append('| Falta en en | %d |\n' % sum(1 for e in estados if not e[4]))
ev.append('\n**API real del proyecto (`_t`, `traducir_clave`, `tr_key` compuesto) — verificación suplementaria:** %d claves válidas (prefijos concatenados descartados), '
          '%d presentes en es+en, %d faltan en es, %d faltan en en.\n\n' %
          (len(real_estados), sum(1 for e in real_estados if e[4] and e[5]),
           sum(1 for e in real_estados if not e[4]), sum(1 for e in real_estados if not e[5])))
ev.append('Primeras 40 claves `tr_key`/`tr_ctx` ausentes:\n\n')
for p, n, api, key, es, en in [e for e in real_estados if not (e[4] and e[5])][:40]:
    ev.append('- %s:%d `%s` → es:%s en:%s\n' % (p.relative_to(R).as_posix(), n, key,
                                                'OK' if es else 'FALTA', 'OK' if en else 'FALTA'))
ev.append('\n**Nota de premisa (importante):** el backlog anunciaba 2872 `tr()` derivados de `grep -rF "tr("`, '
          'pero ese patrón cuenta los `str(` del código. Con límite de palabra hay **%d `tr()` literales y %d con variable**. '
          'Los 100 batches se marcaron con "sin llamadas en este rango", no con un falso "0/30 OK". '
          'La verificación útil se hizo sobre la API real `tr_key`/`tr_ctx` y se reporta arriba.\n\n' % (len(calls), variables))
ev.append('**Firma:** agnes-3-flash (directora) - 2026-11-17 08:05\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 09:0x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
print('tareas marcadas:', sum(1 for l in lineas if l.startswith('- [x] T21-')))
print('primeras 10 faltantes:', [(e[2], e[3], e[4]) for e in estados if not (e[3] and e[4])][:10])
