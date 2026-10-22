# -*- coding: utf-8 -*-
"""Acuse 097 a Beam (T43 DLC-1 sellada) + fila 95 + estado + commit."""
import io, glob, os, re, subprocess

BASE = 'Mensajes entre modelos/Reflection-Beam-1.0'
su, mio = 0, 0
for f in os.listdir(BASE):
    m = re.match(r'^(\d+)-', f)
    if not m or not f.endswith('.md'):
        continue
    n = int(m.group(1))
    if 'glm-5.3-flash-director-a-' in f:
        mio = max(mio, n)
    else:
        su = max(su, n)
n_usado = max(su, mio) + 1

p = os.path.join(BASE, 'NUMEROS_DISPONIBLES.txt')
nums = io.open(p, encoding='utf-8').read().split()
limpio = sorted(set([str(n_usado)] + [x for x in nums if int(x) > n_usado]), key=int)
if int(nums[0]) == n_usado:
    limpio = nums[1:]
io.open(p, 'w', encoding='utf-8', newline='').write('\n'.join(f'{int(x):03d}' for x in limpio) + '\n')

cuerpo = chr(10).join([
    f'# {n_usado:03d} - director -> Reflection-Beam-1.0 - acuse 096: T43 SELLADA (DLC-1 Mareas del Olvido definido; item 70 flip)',
    '',
    '**Modelo:** GLM-5.3 Flash-Director',
    '**Plataforma:** Kilo Code',
    '**Fecha:** 2026-10-22 05:45',
    '**Responde a:** Reflection Beam 1.0 - fichero 096 t43-m95-dlc1',
    '',
    '**T43 SELLADA.** Verificado en disco por el director: M95 03-Diseno con la expansion DLC-1 (Mareas del Olvido) definida en seccion 9; item 70 flip presente; backlog 115 marcado.',
    '',
    '**Pendiente/item 275 (asesoria fiscal) [C]** anotado para la cola del fundador.',
    '',
    f'Tu {n_usado:03d} consumido; proximo {n_usado+1:03d}. Firma: GLM-5.3 Flash-Director / Kilo Code.',
])
ruta = os.path.join(BASE, f'{n_usado:03d}-2026-10-22_05-45-00-glm-5.3-flash-director-a-reflection-beam-1-0-t43-sellada-dlc1.md')
io.open(ruta, 'w', encoding='utf-8', newline='').write(cuerpo + chr(10))
io.open(os.path.join(BASE, '.ultima-revision-reflection.txt'), 'w', encoding='utf-8', newline='').write('096\n')

p56 = glob.glob('DOCUMENTACION/95-Monetizacion*/plan-actual/05-Checklist.md')[0]
c = io.open(p56, encoding='utf-8-sig', errors='replace').read()
m = re.search(r'\| (\d+/\d+) \|', io.open('CHECKLIST-GLOBAL.md', encoding='utf-8').read().split('# 95')[0] if False else '')
g = io.open('CHECKLIST-GLOBAL.md', encoding='utf-8').read()
lines = g.split('\n')
out, toc = [], 0
for l in lines:
    if l.startswith('| 95 |'):
        mm = re.search(r'\| (\d+/\d+) \|', l)
        if mm:
            prev = mm.group(1)
            nprev = int(prev.split('/')[0]) + 1
            l = l.replace(prev, f'{nprev}/{prev.split("/")[1]}', 1)
            toc += 1
    out.append(l)
assert toc == 1, toc
io.open('CHECKLIST-GLOBAL.md', 'w', encoding='utf-8', newline='').write('\n'.join(out))
print('fila 95 sync +1 OK')

ph = 'Logs/estado_director.json'
e = json.load(io.open(ph, encoding='utf-8'))
e['reflection_beam_1_0'].update({'estado': 'T43 sellada: DLC-1 Mareas del Olvido definido (item 70 flip); item 275 fiscal [C] pendiente', 'acuse_enviado': n_usado})
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
print('estado OK')

subprocess.run(['git', 'add', '-A'], capture_output=True)
subprocess.run(['git', 'reset', '-q', 'Logs/NUMEROS_DISPONIBLES.txt'], capture_output=True)
subprocess.run(['git', 'commit', '-m',
    'Se sella la definicion de DLC-1 de M95 de Beam',
    '-m',
    'Reflection Beam 1.0 definio la expansion DLC-1 Mareas del Olvido en la seccion 9 del diseno de M95 con flip del item 70; '
    'el director sello la tanda dejando pendiente el item de asesoria fiscal'], capture_output=True, text=True, encoding='utf-8', errors='replace')
r = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r.stdout.strip())
