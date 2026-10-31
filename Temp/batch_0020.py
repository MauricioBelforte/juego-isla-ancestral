import os, json, subprocess, datetime
root = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'

# 1. pools
for chan, num in [('DeepSeek-V4.1-Flash','470'),('Nemotron-3.5-Super-VL','165'),('Ling-3.1-Flash','332')]:
    p = os.path.join(root, 'Mensajes entre modelos', chan, 'NUMEROS_DISPONIBLES.txt')
    if os.path.exists(p):
        lines = open(p, encoding='utf-8').read().splitlines()
        lines = [l for l in lines if l.strip() != num]
        open(p, 'w', encoding='utf-8').write(chr(10).join(l for l in lines if l.strip()) + chr(10))
print('pools 470/165/332 liberados')

# 2. estado
e = os.path.join(root, 'Logs', 'estado_director.json')
st = json.load(open(e, encoding='utf-8'))
st['m140_decisions_469'] = {'desc': 'M140 17 VIVA flip masivo [x]->[ ] aprobado + 4 RUNTIME -> [?] + 2 MUERTA nota reescrita. M38 L41 hallazgo (guardar_estado 0 llamadores, VIVA). M22 L126/127 flip aprobado (docs en disco) + L89-95 7 items -> dueño contraparte [ ]. Detector RECALL de DeepSeek fixado (flecha excluía flips). TANDA 8 = M140 cierre + M22 L126/127.'}
st['nemotron_b0_p1'] = {'P1': 'M157 vision pre-check DONE (no existe modulo en disco, confirma doc-only)', 'B0': 'boot M101/M34/M59 = siguiente, ya [->] en su backlog'}
st['ling_mapa_fragiles'] = {'desc': 'AUDITORIA-SUITES-FRAGILES re-cruzada contra M85/M22/M14 + SOP + muestreo_p100 + auditoria-autocontradicciones = kit anti-inflacion del relevo 1-nov.'}
json.dump(st, open(e, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print('estado actualizado')

# 3. commit preservacion
res = subprocess.run(['git','status','--porcelain'], cwd=root, capture_output=True, text=True)
now = datetime.datetime.now()
stable = []
for line in res.stdout.splitlines():
    line = line.strip()
    if not line: continue
    path = line[3:]; fp = os.path.join(root, path)
    try: m = os.path.getmtime(fp)
    except: m = now.timestamp()
    age = (now - datetime.datetime.fromtimestamp(m)).total_seconds()//60
    if age >= 15: stable.append(path)
print('ESTABLES:', len(stable))
for pth in stable:
    subprocess.run(['git','add','-A','--',pth], cwd=root)
ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
msg = f'''Se preservaron avances de la jornada 30oct (post-5d6105a)

- P-100 serie false-green Beam: M85 rebaseline 99->73/25/2 (autoría: 24/26 restauracion silenciosa cron-bulk + 2 Beam T246-85; bug de proceso del Cron C documentado) + M74/M71/M105/M115 (156 marcas) degradados por DS-OpenCode + M67 Ruta B GO. Sello M22 2026-10-15 INVALIDADO (78/91, tautologia spec). BUG-151/152 resueltos.
- M59 L184+L215 flippeados (118/130) + fix re-traducion pause_layer + test_menu_guardado 88 checks.
- 3 re-alocaciones por capacidad: Hy3 gate-2 batch3 (#447), DeepSeek TANDA 4-8 (#461-470), Ling TANDA auditoria (#326), Nemotron B-0/P1 (#155, ya P1 hecho), DS-OC M67 GO + chase commits.
- M140 17 VIVA flip masivo + M38 hallazgo + M22 L126/127 (pendiente ejecucion TANDA 8).
- estado_director.json + 11-BUGS.md + checklists 05 (M59/M85/M14/M34/M22/M55) + mensajes canal (DeepSeek #460-470, Hy3, Ling, Nemotron #155-165, DS-OC, GLM, Beam) + .gitattributes eol.

Firma: agnes-3-flash (Sapiens AI) / Kilo Code — {ts}'''
subprocess.run(['git','commit','-m',msg], cwd=root, capture_output=True, text=True)
head = subprocess.run(['git','log','-1','--oneline'], cwd=root, capture_output=True, text=True).stdout.strip()
print('HASH:', head[:40])
