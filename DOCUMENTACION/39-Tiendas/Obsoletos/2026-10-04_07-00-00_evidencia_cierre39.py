# -*- coding: utf-8 -*-
# Evidencia de cierre M39 (reconciliacion del 05-Checklist) - glm-5.3-flash / Cline
# Recolecta, sin escribir nada del proyecto, los hechos verificables que sostienen
# o niegan los items marcados [ ] en el 05-Checklist.md del modulo 39.
# Uso: python DOCUMENTACION/39-Tiendas/scripts-prueba/evidencia_cierre39.py
import io, os, re, hashlib, datetime

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(AQUI)))
OUT = os.path.join(RAIZ, 'Logs', '_ev39.txt')

B = os.path.join(RAIZ, 'DOCUMENTACION', '39-Tiendas')
PA = os.path.join(B, 'plan-actual')
PI = os.path.join(B, 'plan-inicial')
J = os.path.join(RAIZ, 'game', 'isla-ancestral')
O = []


def read(p):
    with io.open(p, encoding='utf-8', newline='') as fh:
        return fh.read()


def md5(p):
    if not os.path.exists(p):
        return 'FALTA'
    with open(p, 'rb') as fh:
        return hashlib.md5(fh.read()).hexdigest()


O.append('=== EVIDENCIA DE CIERRE M39 — %s ===' % datetime.datetime.now().strftime('%Y-%m-%d %H:%M'))
O.append('raiz: ' + os.path.basename(RAIZ))

O.append('')
O.append('--- 1. FIRMAS (2 primeras lineas de cada archivo) ---')
for nombre in ('01-Requerimientos.md', '02-Analisis.md', '03-Diseno.md', '04-Codigo.md', '05-Checklist.md'):
    for carpeta, tag in ((PA, 'actual'), (PI, 'inicial')):
        L = read(os.path.join(carpeta, nombre)).splitlines()
        O.append('%s [%s] L1=%s | L2=%s' % (nombre, tag, L[0][:60], L[1][:60] if len(L) > 1 else ''))

O.append('')
O.append('--- 2. HASH plan-inicial vs plan-actual ---')
for nombre in ('01-Requerimientos.md', '02-Analisis.md', '03-Diseno.md', '04-Codigo.md', '05-Checklist.md'):
    h1, h2 = md5(os.path.join(PI, nombre)), md5(os.path.join(PA, nombre))
    O.append('%s ini=%s act=%s %s' % (nombre, h1[:8], h2[:8], 'IDENTICO' if h1 == h2 else 'DIVERGE'))

O.append('')
O.append('--- 3. SECCIONES QUE SOSTIENEN ITEMS DOCUMENTALES ---')
d3 = read(os.path.join(PA, '03-Diseno.md'))
O.append('03-Diseno headings:')
for l in d3.splitlines():
    if l.startswith('## '):
        O.append('   ' + l.strip()[:90])
O.append('03-Diseno: bloques mermaid=%d | tablas de flujo=%s' % (
    d3.count('```mermaid'),
    [l.strip()[:70] for l in d3.splitlines() if l.startswith('### ') or l.startswith('#### ')][:14]))
d4 = read(os.path.join(PA, '04-Codigo.md'))
O.append('04-Codigo Notas del Agente=%s' % ('## Notas del Agente' in d4))
d1 = read(os.path.join(PA, '01-Requerimientos.md'))
O.append('01-Requerimientos RF presentes=%d | criterios de aceptacion=%s' % (
    len(set(re.findall(r'RF(\d+)', d1))),
    len(re.findall(r'^\|\s*\d+\.', d1, re.M))))

O.append('')
O.append('--- 4. 05-CHECKLIST: conteo ---')
t = read(os.path.join(PA, '05-Checklist.md'))
it = re.findall(r'^- \[\s*(x|X| |\?)\s*\]', t, re.M)
O.append('items=%d [x]=%d [ ]=%d [?]=%d | marcadores S=%d M=%d C=%d' % (
    len(it), it.count('x') + it.count('X'), it.count(' '), it.count('?'),
    len(re.findall(r'\[S\]', t, re.M)), len(re.findall(r'\[M\]', t, re.M)), len(re.findall(r'\[C\]', t, re.M))))

O.append('')
O.append('--- 5. CODIGO: estado abierto/cerrado (items L206/L250) ---')
shop = read(os.path.join(J, 'scripts', 'shops', 'shop.gd')).splitlines()
en = False
for i, l in enumerate(shop, 1):
    if 'func esta_abierta' in l:
        en = True
    if en:
        O.append('shop.gd L%d: %s' % (i, l.rstrip()[:110]))
        if en and l.strip() == '' or (en and l.startswith('func ') and 'esta_abierta' not in l):
            break
sm = read(os.path.join(J, 'scripts', 'shops', 'shop_manager.gd'))
O.append('manager: asignaciones de abierta_ahora ->')
for i, l in enumerate(sm.splitlines(), 1):
    if 'abierta_ahora' in l:
        O.append('   L%d: %s' % (i, l.strip()[:110]))
for pat in ('forzar', 'set_abierta', 'abierta_manual'):
    hall = [i for i, l in enumerate(read(os.path.join(J, 'scripts', 'shops', 'shop_manager.gd')).splitlines(), 1) if pat in l]
    O.append('manager: "%s" -> %s' % (pat, hall if hall else 'no existe'))

O.append('')
O.append('--- 6. CODIGO: instanciacion de nodos en transacciones (item L252) ---')
for i, l in enumerate(sm.splitlines(), 1):
    if re.search(r'\.instantiate\(|Node\.new\(|add_child\(', l):
        O.append('manager L%d: %s' % (i, l.strip()[:110]))
O.append('(vacio = sin instanciacion de nodos en el manager)')

O.append('')
O.append('--- 7. TESTS: cobertura de motivos y venta sin fondos (item L234) ---')
for f in sorted(os.listdir(os.path.join(J, 'scripts', 'shops'))):
    if not f.startswith('test_') or not f.endswith('.gd'):
        continue
    c = read(os.path.join(J, 'scripts', 'shops', f))
    O.append('%s: SIN_FONDOS=%d INVENTARIO_LLENO=%d CANTIDAD_INVALIDA=%d SIN_STOCK=%d saldo0=%d' % (
        f, c.count('SIN_FONDOS'), c.count('INVENTARIO_LLENO'), c.count('CANTIDAD_INVALIDA'), c.count('SIN_STOCK'),
        len(re.findall(r'saldo\s*=\s*0\b', c))))

O.append('')
O.append('--- 8. UI M53 (items L222-L224) ---')
u = read(os.path.join(J, 'scripts', 'shops', 'shop_ui.gd'))
O.append('shop_ui.gd lineas=%d | .connect(=%d | funciones=%d' % (
    len(u.splitlines()), u.count('.connect('),
    len(re.findall(r'^func ', u, re.M))))
O.append('conecta: %s' % str(re.findall(r'\.connect\(\s*([A-Za-z_]+)', u)))

O.append('')
O.append('--- 9. NUMERACION DE LOGS ---')
disp = os.path.join(RAIZ, 'Logs', 'NUMEROS_DISPONIBLES.txt')
if os.path.exists(disp):
    prim = read(disp).splitlines()
    O.append('NUMEROS_DISPONIBLES primera=%s total=%d' % (prim[0] if prim else 'VACIO', len(prim)))
res = os.path.join(RAIZ, 'Logs', 'reservas')
O.append('reservas: %s' % (sorted(os.listdir(res)) if os.path.exists(res) else 'sin carpeta'))
O.append('logs 1017+: %s' % sorted([n[:4] for n in os.listdir(os.path.join(RAIZ, 'Logs')) if re.match(r'^10(1[7-9]|[2-9]\d)-', n)])[:20])

with io.open(OUT, 'w', encoding='utf-8', newline='') as fh:
    fh.write('\n'.join(O) + '\n')
print('evidencia: ' + os.path.relpath(OUT, RAIZ))
