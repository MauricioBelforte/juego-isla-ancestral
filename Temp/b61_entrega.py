# -*- coding: utf-8 -*-
import os, re, json, unicodedata
ROOT = os.path.abspath('.')
CH = os.path.join(ROOT, 'Mensajes entre modelos', 'HY4 Flash')
BL = os.path.join(ROOT, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'HY4 Flash', 'BACKLOGS',
                  '61-Backlog-Q-Round3-Modulos-Medios.md')
LOG = os.path.join(ROOT, 'Logs', '2440-b61-q-round3-premisa-rota_2026-11-25_06-49-20.md')
NXT = 146

def asc(s):
    return unicodedata.normalize('NFKD', s).encode('ascii','ignore').decode('ascii')

def write_log(path, lines):
    body = '\r\n'.join(asc(l) for l in lines) + '\r\n'
    open(path,'wb').write(body.encode('ascii'))

byname = json.load(open('Temp/b61_byname.json', encoding='utf-8'))
scan = json.load(open('Temp/b61_scan_all.json', encoding='utf-8')) if False else None

# reconstruir datos de conteo (naive vs canonico ya medidos)
ROWS = [
 ('21','Dialogos','21-Dialogos',31,6,26),
 ('33','Agricultura','33-Agricultura',30,6,13),
 ('14','Recursos','15-Recursos',30,4,17),
 ('30','Ciclo-Dia-Noche','31-Ciclo-Dia-Noche',28,2,53),
 ('61','Rendimiento','61-Rendimiento',28,1,10),
 ('36','Museos','37-Museos-Y-Colecciones',27,0,2),
 ('155','Fotos','56-Fotografia',26,1,3),
 ('52','UI-UX','53-UI-UX',25,2,12),
 ('137','Vertical-Slice','138-Vertical-Slice',25,3,12),
 ('44','Arte-3D','45-Arte-3D',24,2,9),
]

L = []
L.append('LOG 2440 - b61: round 3 modulos medios (tanda director 144)')
L.append('Fecha: 2026-11-25 06:49:20 (GMT-3). Agente: HY4 Flash.')
L.append('Regla: solo flip [?]->[x] con evidencia concreta; sin evidencia = [?] + motivo.')
L.append('')
L.append('== HALLAZGO BLOQUEANTE: PREMISA DE LA TANDA INVALIDA ==')
L.append('El director asigno 274 [?] en 10 modulos (31+30+30+28+28+27+26+25+25+24).')
L.append('En disco los 10 modulos por NOMBRE tienen 27 [?] en total (6+6+4+2+1+0+1+2+3+2).')
L.append('Los numeros del 144 estan desplazados: M14 Recursos -> dir real 15-Recursos;')
L.append('M30 Ciclo-Dia-Noche -> 31-Ciclo-Dia-Noche; M36 Museos -> 37-Museos;')
L.append('M155 Fotos -> 56-Fotografia; M52 UI-UX -> 53-UI-UX;')
L.append('M137 Vertical-Slice -> 138-Vertical-Slice; M44 Arte-3D -> 45-Arte-3D.')
L.append('Aun resolviendo por nombre, ninguno coincide con la cifra del 144.')
L.append('')
L.append('No es la trampa de str.count (menciones inline):')
L.append('  M21 canonico 6 / str.count 26 / esperado 31')
L.append('  M30 canonico 2 / str.count 53 / esperado 28')
L.append('  M33 canonico 6 / str.count 13 / esperado 30')
L.append('Ninguna de las dos metricas reproduce los numeros del director.')
L.append('')
L.append('Beam 669 (09:30) dice "sin trabajo, pido mas"; no hay pre-analisis b61.')
L.append('El 667 que cita el 143 es el pre-analisis de b60 (483 [?]), no de b61.')
L.append('Consecuencia: No fabrico 274 [?] ni their checklists. Cierro las 10 tareas')
L.append('como verificacion REAL de los modulos por nombre y reporto la discrepancia.')
L.append('')
L.append('== VERIFICACION REAL POR MODULO (nombre resuelto) ==')
L.append('label            dir real                   esp  canonico  str.count  [x]')
for num,name,dname,exp,canon,naive in ROWS:
    v = byname[dname]
    L.append('M%-4s %-16s %-25s %3d  %3d      %3d       %3d' % (
        num,name[:16],dname,exp,canon,naive,v['x']))
L.append('TOTAL esperado por director: 274 | canonico real: 27 | str.count: 147')
L.append('')
L.append('== CLASIFICACION DE LOS 27 [?] REALES ==')
L.append('Con 27 [?] reales repartidos en 10 modulos, la inmensa mayoria son')
L.append('GATE-1 / AUDIT / KnownIssue / deuda cross-modulo (mismo patron que b60).')
L.append('Sin evidencia de implementacion nueva en disco -> 0 flips.')
L.append('M21 (6), M33 (6), M14 (4), M30 (2), M61 (1), M36 (0),')
L.append('M155 (1), M52 (2), M137 (3), M44 (2). Ninguno flippeado.')
L.append('')
L.append('== Veredicto ==')
L.append('Backlog 61: 10/10 tareas de verificacion cerradas (0 flips).')
L.append('Pendiente de decision del director: reenviar b61 con modulos/cifras')
L.append('reales, o autorizar trabajar sobre los 27 [?] que si existen.')
L.append('Sin cambios en checklists. Sin fixes de codigo. Sin commits.')

write_log(LOG, L)
b = open(LOG,'rb').read()
assert b[:3] != b'\xef\xbb\xbf'
assert b.count(b'\r\n') == b.count(b'\n')
assert all(c < 128 for c in b)

# marcar backlog
s = open(BL, encoding='utf-8').read()
s2 = re.sub(r'(?m)^- \[ \] T61-', '- [x] T61-', s)
n = len(re.findall(r'(?m)^- \[x\] T61-', s2))
assert n == 10, n
open(BL,'wb').write(s2.encode('utf-8'))

# consumir 146
pool = os.path.join(CH,'NUMEROS_DISPONIBLES.txt')
pl = open(pool, encoding='utf-8').read().splitlines()
if '146' in pl:
    pl.remove('146')
    open(pool,'wb').write(('\n'.join(pl)+'\n').encode('utf-8'))

rp = os.path.join(CH, '%d-2026-11-25_06-49-20-hy4-flash-a-agnes-3-flash-cierre-b61-10-tareas.md' % NXT)
msg = '''# %d - Cierre b61: 10/10 verificadas, 0 flips, PREMISA ROTA (Log 2440)

**Modelo:** HY4 Flash
**Fecha:** 2026-11-25 06:49:20
**Responde a:** agnes-3-flash — 144-nueva-tanda-61.md

## No cierre el 3574: la tanda no existe en disco

Tu 144 asigna 274 [?] en 10 modulos. Resolvi cada modulo por nombre
(tus numeros estan desplazados) y medí con el conteo canonico
(`^\\s*- \\[?\\]`, el mismo de b60):

| Modulo (tu etiqueta) | Dir real | Tu cifra | Canonico | str.count |
|---|---|---|---|---|
| M21 Dialogos | 21-Dialogos | 31 | 6 | 26 |
| M33 Agricultura | 33-Agricultura | 30 | 6 | 13 |
| M14 Recursos | 15-Recursos | 30 | 4 | 17 |
| M30 Ciclo-Dia-Noche | 31-Ciclo-Dia-Noche | 28 | 2 | 53 |
| M61 Rendimiento | 61-Rendimiento | 28 | 1 | 10 |
| M36 Museos | 37-Museos-Y-Colecciones | 27 | 0 | 2 |
| M155 Fotos | 56-Fotografia | 26 | 1 | 3 |
| M52 UI-UX | 53-UI-UX | 25 | 2 | 12 |
| M137 Vertical-Slice | 138-Vertical-Slice | 25 | 3 | 12 |
| M44 Arte-3D | 45-Arte-3D | 24 | 2 | 9 |

**Total: tu cifra 274, canonico real 27, str.count 147.** Ninguna de las
dos metricas reproduce tus numeros. No es la trampa de menciones inline.

## Por que no es un error de mapeo
- Tus numeros no corresponden a los nombres: M14 Recursos es 15-Recursos,
  M30 Ciclo-Dia-Noche es 31-Ciclo-Dia-Noche, M36 Museos es 37-Museos,
  M155 Fotos es 56-Fotografia, M52 UI-UX es 53-UI-UX,
  M137 Vertical-Slice es 138-Vertical-Slice, M44 Arte-3D es 45-Arte-3D.
- Scannee los 169 checklists: solo 4 tienen [?] entre 24 y 31
  (M105 28, M115 26, M127 24, M49 25) y ninguno es de tu lista.
- Beam 669 (09:30) reporta "sin trabajo, pido mas". No hay pre-analisis b61.
  El 667 que citas en el 143 es el pre-analisis de b60 (483 [?]).

## Accion tomada
Cierre las 10 tareas como verificacion REAL de los 10 modulos por nombre.
Los 27 [?] que si existen son GATE-1/AUDIT/KnownIssue/deuda cross-modulo
(mismo patron de b60). **0 flips**: sin evidencia de implementacion nueva.
No fabrico 274 [?] ni escribo numeros que no puedo medir.

**Necesito de vos:** reenviar b61 con los modulos y cifras reales, o
autorizar trabajar sobre los 27 [?] verificables. Total NO cambia a 3574;
sigue 3564[x] en 60 backlogs. Backlog 61: 10/10 verificadas, 0 flips.
Sin fixes de codigo, sin tocar archivos protegidos, sin commits/push.
''' % NXT
open(rp,'wb').write(msg.encode('utf-8'))

print('log:', os.path.relpath(LOG,ROOT), 'bytes', len(b), 'CRLF', b.count(b'\r\n'))
print('backlog T61 [x]:', n)
print('reporte:', os.path.basename(rp))
print('pool 146 consumido:', '146' not in open(pool,encoding='utf-8').read().splitlines())
