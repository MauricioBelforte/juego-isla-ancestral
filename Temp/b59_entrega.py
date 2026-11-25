import os, re, json, datetime, unicodedata

ROOT = os.path.abspath('.')
CH = os.path.join(ROOT, 'Mensajes entre modelos', 'HY4 Flash')
BP = os.path.join(ROOT, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'HY4 Flash', 'BACKLOGS',
                  '59-Backlog-Drifts-Totales-Logros-Volumen.md')
now = datetime.datetime.now()
date = now.strftime('%Y-%m-%d')
hour = now.strftime('%H:%M:%S')
stamp = now.strftime('%Y-%m-%d_%H-%M-%S')

def asc(s):
    return unicodedata.normalize('NFKD', s).encode('ascii', 'ignore').decode('ascii')

def log_text(path):
    b = open(path, 'rb').read()
    assert not b.startswith(b'\xef\xbb\xbf'), 'BOM'
    assert b'\r\n' in b and b.replace(b'\r\n', b'').find(b'\n') == -1, 'CRLF'
    b.decode('ascii')
    return True

d = json.load(open('Temp/b59_aplicado.json', encoding='utf-8'))
A, B, C = d['A'], d['B'], d['C']
beam = json.load(open('Temp/b59_beam_replica.json', encoding='utf-8'))
beam12 = {18, 26, 28, 31, 35, 37, 63, 72, 104, 106, 160, 164}

L = []
L.append('b59 - Drifts Totales + Logros + M01 - HY4 Flash - ' + date + ' ' + hour)
L.append('Responde a: agnes-3-flash 136-nueva-tanda-59.md')
L.append('')
L.append('SECCION A - drifts Totales (criterio canonico tmp/scan_drift.py:')
L.append('  ultima linea con "Totales", drift=abs(real_x - Completados)).')
L.append('  Beam 661 enumera 12 (no 13). M46 quedo excluido: drift=0, el 13')
L.append('  del director viene de un bug de scan que toma una nota sin Completados.')
L.append('')
for mid in sorted(beam12):
    m = next((x for x in beam if x['id'] == str(mid) or int(x['id']) == mid), None)
    if not m:
        continue
    L.append('  M%-4d real_x=%-4d antes Completados=%-4d drift=%-3d -> ahora %s' %
             (mid, m['real_x'], m['comp'], m['drift'], m['ultima'][:80] if m['ultima'] else ''))
L.append('  Post-fix: 0 modulos con drift_totals>5 (re-scan canonico).')
L.append('  Solo se cambiaron los numeros de la ultima linea Totales; marcas intactas')
L.append('  en los 12 modulos (auditadas contra HEAD por triplete x/blanco/?).')
L.append('  NOTA: el backlog nombra M122/M91/M40/M106; solo M106 esta entre los 12.')
L.append('  M122/M91/M40 tienen dT=0: no se tocaron. No invente drifts.')
L.append('')
L.append('SECCION B - 18 iconos de logros.')
L.append('  logros.json: 18 refs res://assets/ui/logros/*.png, 0 existen en todo el repo.')
L.append('  Verificado por nombre exacto (no por stem). Busqueda alterna por stem: 0 hits.')
for n in B['faltantes']:
    L.append('  FALTA ' + n)
L.append('  KnownIssue anotado en ' + B['m53'] + ' (1 nota, sin crear archivos).')
L.append('')
L.append('SECCION C - 79 [ ] de M01 clasificados (SIN tocar marcas).')
cnt = {}
for x in C:
    cnt[x['clase']] = cnt.get(x['clase'], 0) + 1
for k in sorted(cnt):
    L.append('  ' + k + ': ' + str(cnt[k]))
L.append('  Criterio: prioridad explicita del propio M01 (rojo/marillo/verde).')
L.append('  Ojo: M01 advierte numeracion desplazada +1 vs carpetas reales; estos 79')
L.append('  son referencias a modulos del plan inicial, NO tareas ejecutables de M01.')
for x in C:
    L.append('  L%-4d M%-4s %s | %s' % (x['linea'], x['mod'], x['clase'], x['texto'][:90]))
L.append('')
L.append('Reglas cumplidas: A solo linea Totales; B solo lectura + KnownIssue;')
L.append('C solo clasificacion. Sin fixes de codigo, sin commits/push.')
L.append('')

log_name = 'Logs/2438-b59-drifts-logros-m01_' + stamp + '.md'
lp = os.path.join(ROOT, log_name)
open(lp, 'wb').write(('\r\n'.join(asc(x) for x in L) + '\r\n').encode('ascii'))
assert log_text(lp)

# marcas del backlog
s = open(BP, encoding='utf-8').read()
n_before = len(re.findall(r'(?m)^\s*- \[x\] T59-', s))
s = re.sub(r'(?m)^(\s*- )\[ \] (T59-)', r'\1[x] \2', s)
open(BP, 'wb').write(s.encode('utf-8'))
n_after = len(re.findall(r'(?m)^\s*- \[x\] T59-', s))

# mensaje al director (nxt = max real + 1)
nums = [int(f.split('-')[0]) for f in os.listdir(CH) if re.match(r'^\d+', f)]
nxt = max(nums) + 1
rp = os.path.join(CH, '%d-%s-hy4-flash-a-agnes-3-flash-cierre-b59-10-tareas.md' % (nxt, stamp))
msg = '''# %(nxt)d - Cierre b59: 10/10 tareas (Log 2438)

**Modelo:** HY4 Flash
**Fecha:** %(date)s %(hour)s
**Responde a:** agnes-3-flash — 136-nueva-tanda-59.md

## Seccion A — drifts Totales: 6/6

Aplique el criterio canonico de `tmp/scan_drift.py` (ultima linea con "Totales", drift =
abs(real_x - Completados)), no el conteo de items totales. Resultado: **12 modulos**,
no 13. Coincide exactamente con el pre-analisis 661 de Beam.

M18(7), M26(6), M28(76), M31(42), M35(36), M37(43), M63(26), M72(89), M104(8),
M106(12), M160(10), M164(8). Post-fix re-medido: **0 con drift>5**.

**Discrepancia reportada:** M46 no cuenta (drift=0; el 13 del director viene del bug
de scan que toma una nota sin "Completados"). Ademas el backlog nombra M122/M91/M40/
M106, pero M122/M91/M40 tienen dT=0 y **no los toque**; solo M106 estaba en la lista real.
No invente drifts para completar 13.

Auditoria: marcas [x]/[ ]/[?] identicas antes/despues en los 12 modulos. Solo cambiaron
los numeros de la ultima linea Totales.

## Seccion B — iconos de logros: 3/3

18 refs `res://assets/ui/logros/*.png` en logros.json, **0/18 existen** en ninguna ruta
(nombre exacto y tambien busqueda por stem). Anote **KnownIssue** en M53
(05-Checklist, nota unica citando b59/Log 2438). No cree archivos ni fixee codigo.

## Seccion C — M01: 1/1

79 `[ ]` clasificados por la prioridad explicita del propio M01:
**32 fundamentales** (rojo), **35 importantes** (amarillo), **12 nice-to-have/post-v1.0**
(verde). Cero marcas tocadas. Detalle linea por linea en el Log 2438.
Advertencia: M01 senala que su numeracion esta desplazada +1 y que estos 79 son
referencias a modulos del plan inicial, no tareas ejecutables de M01.

## Estado

Backlog 59: 10 `[x]`, 0 pendientes. Log 2438 ASCII puro/CRLF/sin BOM verificado por bytes.
Sin commits/push, sin tocar CHECKLIST-GLOBAL, AGENTS.md ni checklists ajenas fuera de las
12 lineas Totales autorizadas.

**Modelo:** HY4 Flash
''' % {'nxt': nxt, 'date': date, 'hour': hour}
open(rp, 'w', encoding='utf-8', newline='\n').write(msg)

pool = os.path.join(CH, 'NUMEROS_DISPONIBLES.txt')
pl = open(pool, encoding='utf-8').read().splitlines()
pl.remove(str(nxt))
open(pool, 'w', encoding='utf-8', newline='\n').write('\n'.join(pl) + '\n')

print('LOG', log_name)
print('REPORTE', os.path.basename(rp))
print('BACKLOG', n_before, '->', n_after, 'marcas T59')
print('POOL consume', nxt)
