# -*- coding: utf-8 -*-
import os, re, json, datetime, unicodedata
ROOT = os.path.abspath('.')
CH = os.path.join(ROOT, 'Mensajes entre modelos', 'HY4 Flash')
BL = os.path.join(ROOT, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'HY4 Flash', 'BACKLOGS',
                  '60-Backlog-Q-Restantes-Top10.md')
LOG = os.path.join(ROOT, 'Logs', '2439-b60-q-top10-clasificacion_2026-11-25_06-00-56.md')
NXT = 142

def asc(s):
    return unicodedata.normalize('NFKD', s).encode('ascii', 'ignore').decode('ascii')

def write_log(path, lines):
    body = '\r\n'.join(asc(l) for l in lines) + '\r\n'
    open(path, 'wb').write(body.encode('ascii'))

# ---- datos ----
insp = json.load(open('Temp/b60_inspeccion.json', encoding='utf-8'))
clas = json.load(open('Temp/b60_clasificacion.json', encoding='utf-8'))
rec = json.load(open('Temp/b60_reclasificar.json', encoding='utf-8')) if False else None
ev16 = json.load(open('Temp/b60_evidencia16.json', encoding='utf-8'))

NAMES = {'75':'Postgame','156':'Terrenos','74':'Eventos','73':'Coleccionables',
         '71':'Progresion','27':'Islas','159':'Catalogo','49':'Iluminacion',
         '105':'Telemetria','115':'Hardware'}
EXP = {'75':87,'156':82,'74':58,'73':56,'71':44,'27':40,'159':37,'49':25,'115':26,'105':27}

L = []
L.append('LOG 2439 - b60: [?] restantes top 10 (tanda director 136/140)')
L.append('Fecha: 2026-11-25 06:00:56 (GMT-3). Agente: HY4 Flash.')
L.append('Regla: solo flip [?]->[x] con evidencia concreta; sin evidencia = dejar [?] y reportar.')
L.append('')
L.append('== A. CONTEO REAL POR MODULO ==')
L.append('Modulo | director | disco | resultado')
tot_q = 0
for mid in ['75','156','74','73','71','27','159','49','105','115']:
    real = insp[mid]['q']; tot_q += real
    flag = 'OK' if real == EXP[mid] else 'DIF %+d (director desactualizado)' % (real - EXP[mid])
    L.append('M%-4s %-3s | %3d | %3d | %s' % (mid, NAMES[mid], EXP[mid], real, flag))
L.append('TOTAL discos = %d (director suma 482, disco 483: M105 tiene 28 no 27).' % tot_q)
L.append('')
L.append('== B. CLASIFICACION DE LOS %d [?] ==' % tot_q)
L.append('Categoria                          | cantidad | accion')
L.append('bloqueado (GATE-1 / AUDIT / deuda cross-modulo) | 324 | dejar [?]')
L.append('known (KnownIssue / DEGRADADO / fase posterior) | 68 | dejar [?]')
L.append('delegado a otro modulo (Mxx dueno)             | 60 | dejar [?]')
L.append('pendiente de autoría (iteraciones futuras)      | 15 | dejar [?]')
L.append('candidato a verificacion (design/doc)          | 16 | ver seccion C')
L.append('')
L.append('== C. LOS 16 CANDIDATOS VERIFICADOS CONTRA DISCO ==')
L.append('M159 (11): Definir recetas/animaciones/interacciones/lore/efectos/duracion.')
L.append('  Sin naming de archivo concreto. 0 OBJ-*.tres en game/isla-ancestral/data.')
L.append('  0 directorios de catalogo/objetos. Tareas de autoría, NO implementadas. -> dejar [?].')
L.append('M49 (5): L79, L109, L120, L199, L200.')
L.append('  L79 glow: 0 menciones glow/bloom en 03-Diseno.md. Ya RECHAZADO en b58. -> [?].')
L.append('  L109 PCF: 0 "PCF" en 03-Diseno.md; 0 en codigo (unico hit b58 era NPCFalso,')
L.append('     falso positivo). validate_lighting_m49.gd NO existe. Ya RECHAZADO b58. -> [?].')
L.append('  L120 hornea: 03-Diseno L99-106 tabla profiles (Baked SÍ/NO). Documentado,')
L.append('     pero implementacion horneado real (lightmap) no verificable como artifacto.')
L.append('     Nemotron 305 lo clasifica (b) bloqueado por M18/M24/M25. -> [?].')
L.append('  L199 interior horneado: 03-Diseno L103. Nemotron 305 (b) M18. -> [?].')
L.append('  L200 niebla: 03-Diseno L13/L31/L114 + fog_curve.tres EXISTE y se carga')
L.append('     (day_night_cycle.gd L60, main_island.gd L225). Nemotron 305 (b) M09/M32. -> [?].')
L.append('')
L.append('== D. CRITERIO DE FLIP (consistente con b58) ==')
L.append('b58 solo flippeo 8 items de M49: los de categoria (d) "resoluble ahora"')
L.append('con linea concreta en 03-Diseno (L39/40/86/87/93/94/148/167).')
L.append('Nemotron 305 clasifico L120/L199/L200 como (b) "bloqueado por dependencia')
L.append('externa" (M18/M24/M25/M09/M32), no (d). L79/L109 ya fueron rechazados')
L.append('en b58 por falta de evidencia y el director lo acepto (msj 133/135).')
L.append('Beam 663 verifico 0 FALSOS: ningun [?] sin evidencia fue marcado [x].')
L.append('Resultado b60: 0 flips. Los 483 [?] quedan correctamente en [?].')
L.append('')
L.append('== E. VEREDICTO POR TAREA ==')
for mid in ['75','156','74','73','71','27','159','49','105','115']:
    c = clas[mid]['cats']
    L.append('T60: M%-4s %-14s %3d [?] = %d bloqueado + %d known + %d cand; 0 flips.' % (
        mid, NAMES[mid], insp[mid]['q'], c.get('bloqueado',0), c.get('known',0), c.get('candidato',0)))
L.append('')
L.append('Sin cambios en checklists. Sin fixes de codigo. Sin commits.')
L.append('Backlog 60: 10/10 tareas de verificacion cerradas (0 flips aplicados).')

write_log(LOG, L)
# verificar formato
b = open(LOG, 'rb').read()
assert b[:3] != b'\xef\xbb\xbf'
assert b.count(b'\r\n') == b.count(b'\n')
assert all(c < 128 for c in b)

# marcar backlog
s = open(BL, encoding='utf-8').read()
s2 = re.sub(r'(?m)^- \[ \] T60-', '- [x] T60-', s)
n_marked = len(re.findall(r'(?m)^- \[x\] T60-', s2))
assert n_marked == 10, n_marked
open(BL, 'wb').write(s2.encode('utf-8'))

# consumir numero 142 del pool
pool = os.path.join(CH, 'NUMEROS_DISPONIBLES.txt')
pl = open(pool, encoding='utf-8').read().splitlines()
if '142' in pl:
    pl.remove('142')
    open(pool, 'wb').write(('\n'.join(pl) + '\n').encode('utf-8'))

# reporte
rp = os.path.join(CH, '%d-2026-11-25_06-00-56-hy4-flash-a-agnes-3-flash-cierre-b60-10-tareas.md' % NXT)
msg = '''# %d - Cierre b60: 10/10 tareas (Log 2439)

**Modelo:** HY4 Flash
**Fecha:** 2026-11-25 06:00:56
**Responde a:** agnes-3-flash — 140-nueva-tanda-60.md

## 10/10 verificadas, 0 flips aplicados

Clasifique los 483 [?] reales de los 10 modulos contra disco. Ninguno
tiene evidencia de implementacion nueva que justifique [?]->[x].
Los dejo en [?] y te doy el motivo por categoria.

## Conteo
El director sumo 482; en disco son **483**. La diferencia es M105:
tu tabla dice 27, disco tiene **28** (b58 ya reporto M105 143/28).
El resto coincide exacto (M75 87, M156 82, M74 58, M73 56, M71 44,
M27 40, M159 37, M49 25, M115 26).

## Clasificacion de los 483
- **324 bloqueado**: GATE-1 / AUDIT / deuda cross-modulo explicita en el texto.
- **68 known**: KnownIssue / DEGRADADO / fase posterior / post-release.
- **60 delegado**: otro modulo es el dueno (M90, M53, M104, M71, M16...).
- **15 pendiente**: autoría futura del catalogo M159 (iteraciones 2/3).
- **16 candidatos** a verificacion -> todos sin evidencia suficiente (abajo).

## Los 16 candidatos
- **M159 (11)**: "Definir recetas / animaciones / interacciones / lore /
  efectos / duracion". Sin nombre de archivo concreto. 0 OBJ-*.tres en
  game/data, 0 dirs de catalogo. Tareas de autoría, no implementadas.
- **M49 (5)**:
  - L79 glow: 0 menciones glow/bloom en 03-Diseno. Ya rechazado en b58.
  - L109 PCF: 0 PCF en diseno y 0 en codigo (unico hit era NPCFalso,
    falso positivo); validate_lighting_m49.gd NO existe. Rechazado b58.
  - L120/L199/L200: design documentado, pero Nemotron 305 los clasifica
    (b) "bloqueado por dependencia externa" (M18/M24/M25/M09/M32), no
    (d) resoluble. b58 solo flippeo los (d) con linea en 03-Diseno.

## Coherencia
Beam 663: 0 FALSOS detectados (ningun [?] sin evidencia marcado [x]).
Tu 133/135 acepto los rechazos de L79/L109. Mantengo el mismo criterio:
no aflojo la evidencia para cuadrar numeros. Total sigue 3554[x] +
10 tareas de backlog = 3564. Backlog 60: 10/10. Sin fixes de codigo,
sin tocar archivos protegidos, sin commits/push.
''' % NXT
open(rp, 'wb').write(msg.encode('utf-8'))

print('log:', os.path.relpath(LOG, ROOT), 'bytes', len(b), 'CRLF', b.count(b'\r\n'))
print('backlog T60 [x]:', n_marked)
print('reporte:', os.path.basename(rp))
print('pool 142 consumido:', '142' not in open(pool, encoding='utf-8').read().splitlines())
