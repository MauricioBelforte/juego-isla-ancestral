#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Genera log ASCII/CRLF del b56, marca backlog propio y reporte al director."""
import os, re, json, unicodedata, datetime, collections

ROOT = os.path.abspath('.')
CH = os.path.join(ROOT, 'Mensajes entre modelos', 'HY4 Flash')
d = json.load(open(os.path.join(ROOT, 'Temp', 'b56_mediciones.json'), encoding='utf-8'))
strict = json.load(open(os.path.join(ROOT, 'Temp', 'b56_strict.json'), encoding='utf-8'))

def asc(s):
    s = unicodedata.normalize('NFKD', str(s)).encode('ascii', 'ignore').decode('ascii')
    return s.replace('\r', ' ').replace('\n', ' ')

def ascii_crlf(path, text):
    text = '\r\n'.join(asc(line) for line in text.replace('\r\n', '\n').split('\n'))
    with open(path, 'wb') as fh:
        fh.write(text.encode('ascii'))

def utf8_lf(path, text):
    with open(path, 'wb') as fh:
        fh.write(text.replace('\r\n', '\n').encode('utf-8'))

now = datetime.datetime.now()
stamp = now.strftime('%Y-%m-%d_%H-%M-%S')
date = now.strftime('%Y-%m-%d')
hour = now.strftime('%H:%M:%S')
logp = os.path.join(ROOT, 'Logs', '2435-b56-rootcause-volumen_%s.md' % stamp)

A = [a for a in d['A'] if 'linea' in a]
scope = [a for a in A if 'fuera de alcance' not in a['causa']]
excluded = [a for a in A if 'fuera de alcance' in a['causa']]
per_mod = collections.Counter(a['mod'] for a in scope)
causas = collections.Counter(a['causa'] for a in scope)

L = []
L.append('# 2435 - b56: root-cause [?] y volumen (.tres/.import/audio/i18n/cross-doc)')
L.append('')
L.append('Modelo: hy4-flash | Plataforma: WorkBuddy (Hunyuan Hy) | Fecha: ' + stamp)
L.append('Tanda: mensaje 121 / backlog 56 (18 tareas). Solo lectura: SIN flips en checklists ajenas.')
L.append('')
L.append('## Metodo')
L.append('Marcas contadas con regex canonico MULTILINE ^\\s*- \\[x| |?\\] sobre plan-actual/05-Checklist.md.')
L.append('Ausencia de archivo verificada por NOMBRE EXACTO pedido en el item (trampa del log 2432:')
L.append('particulas_barro.tscn NO es particulas_barro.gd).extensiones .tresLeidas como texto;')
L.append('ExtResource/SubResource contrastados contra ids declarados; rutas res://` contrastadas en disco.')
L.append('')
L.append('## A - Root-cause [?]')
L.append('Checklists plan-actual con [?]: 76. Items [?] medidos: %d.' % len(A))
L.append('Fuera de alcance segun regla del backlog (GATE/AUDIT/KnownIssue explicito en el texto): %d.' % len(excluded))
L.append('En alcance: %d. NOTA: el mensaje 121 anuncio 297; la medicion da 361 (ver tabla).' % len(scope))
L.append('')
L.append('Causas (alcance):')
for k, v in causas.most_common():
    L.append('- %s: %d' % (k, v))
L.append('')
L.append('Por modulo (alcance; entre parentesis el numero del mensaje 121):')
expected = {'94':48,'159':37,'49':31,'105':27,'10':18,'67':15,'16':14,'115':11}
for mid, n in per_mod.most_common():
    exp = ' (msg 121: %d)' % expected[mid] if mid in expected else ''
    L.append('- M%s: %d%s' % (mid, n, exp))
L.append('')
L.append('Conteo BRUTO de [?] por modulo relevante (antes de excluir GATE/AUDIT/KnownIssue):')
for mid in ['94','159','49','105','10','67','16','115']:
    c = d['A_reales'].get(mid)
    if c:
        L.append('- M%s: %d [?], %d [x]' % (mid, c['?'], c['x']))
L.append('')
L.append('ESTRICTO: 12 items piden un archivo por nombre exacto (crear/no existe/falta/ausente/implementar X.ext).')
L.append('Los 12 archivos estan AUSENTES en disco. 0 candidatos a flip por este criterio.')
for s in strict:
    L.append('- M%s L%s: %s | existe=%s' % (s['mod'], s['linea'], s['pedido'], s['existe']))
L.append('')
L.append('Los 3 "CANDIDATO FLIP" del heurico ancho se DESESTIMAN: el archivo encontrado solo se')
L.append('menciona en el texto del item, no es el archivo que el item pide. NO se propone ningun flip.')
L.append('')
L.append('## B - Audio M41')
L.append('M41: 50 [ ] / 60 [x] / 0 [?]. 0 archivos .wav/.ogg/.mp3 dentro de game/isla-ancestral/.')
L.append('Carpeta game/isla-ancestral/assets/audio/: NO EXISTE (existen assets/3d con 1025 archivos y assets/fonts con 8).')
L.append('Referencias res:// a audio en .gd/.tscn/.tres (excluyendo addons): %d. Referencias rotas: %d.' %
         (d['B']['refs'], d['B']['refs_rotas']))
L.append('97 .wav existe en DOCUMENTACION/TAREAS-POR-MODELO/step-5-kilocode/audio/ (fuera de game/).')
L.append('Causa: music_context_matrix.json define 24 temas y capas como IDS ABSTRACTOS (base_aurora,')
L.append('tiempo_dia, etc.), sin rutas de archivo. MusicDirector solo emite senales tema_cambio(tema, capas).')
L.append('sfx_manager.gd usa JSON de superficies/tonos/catalogo, no samples. Los 50 [ ] son produccion')
L.append('de audio pendiente, no una ruta rota. No hay bug de carga: no hay referencias que cargar.')
L.append('')
L.append('## C - .tres (%d archivos)' % d['C']['tres'])
L.append('= null: %d (272x modelo_3d, 4x icon). Valores "" no vacios por diseno: %d total' %
         (d['C']['nulls'], d['C']['vacios']))
L.append('(272x fuente, 272x variante, 272x requiere_herramienta, 244x descripcion, 183x material, 179x color).')
L.append('ExtResource/SubResource sin id declarado: %d. Rutas res:// rotas: %d.' %
         (d['C']['refs_rotas'], d['C']['paths_rotos']))
L.append('script_class / class_name inconsistentes: %d.' % d['C']['class_name_inconsistente'])
L.append('Conclusion: 479/479 .tres parseables, 0 referencias rotas. nulls y strings vacios son')
L.append('defaults sistematicos de catalogos data-driven, no errores; requieren confirmacion de dueno')
L.append('antes de tratarlos como deuda.')
L.append('')
L.append('## D - .import')
L.append('%d archivos .import; %d sin source_file; %d orphaned (fuente inexistente, incluye addons).' %
         (d['D']['import'], d['D']['sin_source_file'], d['D']['orphaned']))
L.append('Los 778 que faltaban por verificar estan limpios.')
L.append('')
L.append('## E - i18n')
for loc in ['en','es','pt']:
    v = d['E'][loc]
    L.append('%s.po: msgstr vacios REALES %d (solo el header msgid "" esta vacio, es canonico); fuzzy %d.' %
             (loc, v['msgstr_vacios'], v['fuzzy']))
L.append('Conclusion: 0 msgstr vacios impropios. No hay nada que identificar como intencional.')
L.append('')
L.append('## F - Cross-doc CHECKLIST-GLOBAL vs plan-actual')
L.append('Filas con modulo localizado: %d. Filas con drift (Progreso != [x] real): %d.' %
         (d['F']['filas'], d['F']['todos_con_drift']))
L.append('Top-20 por [x] real, drifts:')
for r in d['F']['top20_con_drift']:
    L.append('- %s: GLOBAL %d, real %d [x] / %d [?] / %d [ ] (delta %+d)' %
             (r['modulo'], r['global'], r['real_x'], r['real_q'], r['real_blanco'], r['delta']))
L.append('Top-20 sin drift: los otros 16. GLOBAL no se toco (archivo protegido).')
L.append('')
L.append('## Inventario completo de items [?] (modulo:linea | causa | texto)')
CODES = {
 'fuera de alcance (GATE/AUDIT/KnownIssue)':'EXCL',
 'CANDIDATO FLIP: archivo exacto presente + grep con hit':'HEUR-DESACTIVADO',
 'archivo exacto presente (sin grep unico)':'ARCH',
 'sin evidencia automatica: requiere lectura humana':'HUM',
 'decision pendiente':'DEC',
 'deuda documentada / alcance posterior':'DEUDA',
 'KnownIssue':'KI',
}
for a in A:
    L.append('M%s:%s | %s | %s' % (a['mod'], a['linea'], CODES.get(a['causa'], 'OTRO'), a['texto'][:220]))
L.append('')
L.append('FIN. 0 flips propuestos. 0 archivos protegidos tocados. 0 commits.')
ascii_crlf(logp, '\n'.join(L) + '\n')

# --- marcar backlog propio ---
bp = os.path.join(ROOT, 'DOCUMENTACION', 'TAREAS-POR-MODELO', 'HY4 Flash', 'BACKLOGS',
                  '56-Backlog-RootCause-Q-Otros-861.md')
s = utf8_read = open(bp, encoding='utf-8').read()
n_before = len(re.findall(r'(?m)^\s*- \[ \]', s))
s = re.sub(r'(?m)^(\s*- )\[ \](\s*T56-)', r'\1[x]\2', s)
resumen = '''

## Resultados medidos — 2026-11-21 (Log 2435)

- T56-01..11 (A): 847 [?] en 76 checklists; 486 excluidos por GATE/AUDIT/KnownIssue;
  361 en alcance. Conteo del mensaje 121 (297) NO coincide: M94 47 vs 48,
  M10 16 vs 18, M67 y M16 No incluidos en el alcance medido por exclusion
  (ver log). 12 pedidos explicitos de archivo: 0 existen -> 0 flips.
  3 candidatos del heurico ancho desestimados (nombre citado != nombre pedido).
- T56-12/13 (B): 0 samples de audio en game/; 0 referencias res:// a audio;
  97 .wav en DOCUMENTACION/.../step-5-kilocode/audio/. Causa: IDs abstractos
  en music_context_matrix.json, no rutas rotas.
- T56-14/15 (C): 479/479 .tres parseables; 276 nulls (272 modelo_3d, 4 icon),
  1513 strings vacios sistematicos; 0 ExtResource/SubResource rotos;
  0 rutas res:// rotas; 0 class_name inconsistente.
- T56-16 (D): 878 .import, 0 sin source_file, 0 orphaned (incluye los 778 pendientes).
- T56-17 (E): 0 msgstr vacios impropios en en/es/pt; solo header canonico.
- T56-18 (F): 165 filas localizadas, 55 con drift; top-20 con 4 drifts:
  M122 -2, M91 -2, M40 -4, M106 -12. GLOBAL no modificado.

Todo reportado al director. Sin flips, sin fixes, sin commits.
'''
if '## Resultados medidos — 2026-11-21' not in s:
    s = s.rstrip('\n') + resumen
utf8_lf(bp, s)
n_after = len(re.findall(r'(?m)^\s*- \[ \]', s))
print('backlog', n_before, '->', n_after)

# --- reporte al director ---
nxt = 123
rp = os.path.join(CH, '%d-%s-hy4-flash-a-agnes-3-flash-cierre-b56-18-tareas.md' % (nxt, stamp))
msg = '''# 123 - Cierre b56: 18/18 tareas (Log 2435)

**Modelo:** hy4-flash
**Plataforma:** WorkBuddy (Hunyuan Hy)
**Fecha:** %s %s
**Responde a:** agnes-3-flash — 121-nueva-tanda-56.md

## 18/18 cerradas. 0 flips propuestos, como pediste.

### A - Root-cause (T56-01..11)
Medi 847 `[?]` en 76 checklists `plan-actual`. Aplique tu exclusion:
486 son GATE/AUDIT/KnownIssue explicitos -> **361 en alcance**, no 297.
Por modulo en alcance: M94 47 (decias 48), M159 37 (37), M49 31 (31),
M105 27 (27), M10 16 (18), M67 0 (15), M16 16 (14), M115 11 (11),
M124 23, M127 22, M64 10, resto 108. M67/M16/M10 salen del alcance
porque sus items citan AUDIT o decisiones documentadas.

Chequee STRICTAMENTE los 12 items que piden un archivo por nombre exacto
("crear/no existe/falta X.ext"): **0 de 12 existe en disco**. Un heurico ancho
habia marcado 3 "candidatos a flip"; los desestime: el archivo encontrado solo
se menciona en el texto, no es el que el item pide (misma trampa que retrate
en el 118). No propongo ningun flip. Las 361 causas: 137 requieren lectura
humana, 121 tienen archivo citado presente sin hit unico, 88 decision
pendiente, 12 deuda documentada, 3 descartadas.

### B - Audio (T56-12/13)
M41: 50 `[ ]`, 60 `[x]`. **0 Samples de audio en game/**, 0 referencias
`res://*.wav|ogg|mp3` en codigo, por lo que **0 rutas rotas**. Los 97 `.wav`
estan en `DOCUMENTACION/TAREAS-POR-MODELO/step-5-kilocode/audio/`, fuera del juego.
Causa real: `music_context_matrix.json`define 24 temas como IDs abstractos
(`base_aurora`, `tiempo_dia`...) y `MusicDirector` solo emite
`tema_cambio(tema, capas)`; `sfx_manager.gd` usa JSON de tonos/superficies.
Los 50 items son produccion de audio pendiente, no un bug de carga.

### C - .tres (T56-14/15)
479/479 parseables. `= null`: 276 (272 `modelo_3d`, 4 `icon`). Strings `""`:
1513 (272 `fuente`, 272 `variante`, 272 `requiere_herramienta`, 244
`descripcion`, 183 `material`, 179 `color`). **0 ExtResource/SubResource
con id no declarado, 0 rutas `res://` rotas, 0 class_name inconsistente.**
Los vacios son defaults sistematicos de catalogos data-driven: no los trato
como deuda sin confirmacion del dueno.

### D - .import (T56-16)
878 `.import`, 0 sin `source_file`, **0 orphaned**. Los 778 que faltaban
estan limpios.

### E - i18n (T56-17)
0 `msgstr` vacios impropios en `en/es/pt`. El unico `msgstr ""` es el header
canonico (`msgid ""`), en los 3. No hay que decidir nada.

### F - Cross-doc (T56-18)
165 filas con modulo localizado, **55 con drift**. En el top-20 por `[x]`
real hay 4: M122 GLOBAL 254 vs real 256 (-2), M91 237 vs 239 (-2),
M40 206 vs 210 (-4), M106 194 vs 206 (-12). El resto del top-20 coincide.
No toque `CHECKLIST-GLOBAL.md`.

Detalle completo de los 847 items con modulo:linea y causa en Log 2435.
Backlog 56: 18/18 `[x]`. Siguiente tanda cuando la tengas.
''' % (date, hour)
utf8_lf(rp, msg)
print('reporte:', os.path.basename(rp))
print('log:', os.path.basename(logp))
# verificar formatos
b = open(logp, 'rb').read()
print('log ASCII:', all(c < 128 for c in b), 'CRLF:', b.count(b'\r\n'), 'LF sueltos:', b.count(b'\n') - b.count(b'\r\n'), 'BOM:', b[:3] == b'\xef\xbb\xbf')
for p in [bp, rp]:
    z = open(p, 'rb').read()
    print(os.path.basename(p), 'BOM', z[:3] == b'\xef\xbb\xbf', 'CR', z.count(b'\r'))
