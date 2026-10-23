# -*- coding: utf-8 -*-
import io, os, re, json, subprocess

base = 'Mensajes entre modelos/G-5.3-Flash-Agente'

# === 1) mover extras <301 a subcarpetas arch (reciben extras de rango cerrado) ===
movidos, skip = 0, 0
for e in os.scandir(base):
    m = re.match(r'(\d{3})-', e.name)
    if m and e.is_file() and e.name.endswith('.md'):
        n = int(m.group(1))
        if n >= 301:
            continue
        lo = ((n - 1) // 100) * 100 + 1
        hi = lo + 99
        d = os.path.join(base, 'arch_%04d-%04d' % (lo, hi))
        os.makedirs(d, exist_ok=True)
        try:
            os.rename(e.path, os.path.join(d, e.name))
            movidos += 1
        except OSError:
            skip += 1
print('extras <301 movidos:', movidos, '| skip (fantasma):', skip)

# === 2) gemelos 301+: renombrar el SEGUNDO (cronologico) de cada par con sufijo -B ===
raiz = []
for e in os.scandir(base):
    m = re.match(r'(\d{3})-(\d{4}-\d{2}-\d{2})_(\d{2}-\d{2}-\d{2})-(.*)$', e.name)
    if e.is_file() and e.name.endswith('.md') and m:
        raiz.append((int(m.group(1)), m.group(2) + ' ' + m.group(3), e.name, m.group(4)))
raiz.sort(key=lambda x: (x[0], x[1]))
from collections import Counter, defaultdict
por_num = {}
for n, ts, f, r in raiz:
    por_num.setdefault(n, []).append((ts, f, r))
renombres = 0
for n, lista in sorted(por_num.items()):
    if len(lista) < 2:
        continue
    segundo = lista[1]  # el segundo cronologico se distingue con -B
    ts, f, r = segundo
    nuevo_f = '%03dB-%s' % (n, f[4:])
    nuevo_p = os.path.join(base, nuevo_f)
    try:
        os.rename(os.path.join(base, f), nuevo_p)
        renombres += 1
    except OSError as ex:
        print('rename fallo', f, ex)
print('gemelos 301+ renombrados -B:', renombres)

# === 3) verificar raiz final ===
raiz_final = sorted(int(f[0:3]) for f in os.listdir(base) if re.match(r'\d{3}', f) and f.endswith('.md') and os.path.isfile(os.path.join(base, f)))
print('raiz final:', len(raiz_final), '| min:', raiz_final[0] if raiz_final else '-', '| dups:', len(raiz_final) - len(set(raiz_final)))

# === 4) INDICE-CANAL.md regenerado ===
filas = []
for f in os.listdir(base):
    m = re.match(r'(\d{3}[B]?)-(\d{4}-\d{2}-\d{2})_(\d{2}-\d{2}-\d{2})-(.*)$', f)
    if f.endswith('.md') and m and os.path.isfile(os.path.join(base, f)):
        filas.append((m.group(1), m.group(2) + ' ' + m.group(3), m.group(4)))
orden = sorted(filas, key=lambda x: (x[1], x[0]))
IND_f = 'DOCUMENTACION/TAREAS-POR-MODELO/G-5.3-Flash-Agente/INDICE-CANAL.md'
IND = ['# INDICE-CANAL DE G-5.3-FLASH-AGENTE',
       '',
       'Canal saneado 23oct: extras <301 movidos a subcarpetas arch_XXXX-XXXX (recibieron extras); gemelos 301+ desambiguados con sufijo B (segundo cronologico). Numeros NO correlativos por los gemelos historicos — el orden de lectura es el cronologico de abajo.',
       '',
       '%d mensajes (raiz + arch).' % len(orden), '']
for num, ts, r in orden:
    autor = 'DIRECTOR' if 'glm-5.3-flash-director' in r.lower() else 'G-5.3'
    IND.append('%s [%s] %s | %s' % (num, autor, ts, r[:96]))
IND += ['', 'Firma: GLM-5.3 Flash-Director / Kilo Code - 23oct 05:00']
io.open(IND_f, 'w', encoding='utf-8', newline='').write(chr(10).join(IND) + chr(10))
print('INDICE regenerado')

ph = 'Logs/estado_director.json'
e = json.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-23T05:00:30'
e['g_5_3'].update({'canal': 'saneado 23oct: extras <301 en arch (subcarpetas con extras), gemelos 301+ con -B, raiz = solo 301+ unicos'})
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)

subprocess.run(['git', 'add', '-A', base, 'DOCUMENTACION/TAREAS-POR-MODELO/G-5.3-Flash-Agente', ph], capture_output=True)
r = subprocess.run(['git', 'commit', '-m', 'Se sanea el canal de g-5.3: extras a subcarpetas gemelos con sufijo b y indice regenerado'],
 capture_output=True, text=True, encoding='utf-8', errors='replace')
r2 = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r2.stdout.strip())
