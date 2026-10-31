import os, json, subprocess, datetime
root = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'

# pool
p = os.path.join(root, 'Mensajes entre modelos', 'DeepSeek-V4.1-Flash', 'NUMEROS_DISPONIBLES.txt')
if os.path.exists(p):
    lines = open(p, encoding='utf-8').read().splitlines()
    lines = [l for l in lines if l.strip() != '472']
    open(p, 'w', encoding='utf-8').write(chr(10).join(l for l in lines if l.strip()) + chr(10))
print('pool 472 liberado')

# estado
e = os.path.join(root, 'Logs', 'estado_director.json')
st = json.load(open(e, encoding='utf-8'))
st['tanda8_dsoc_m140_m22'] = {'desc': 'M140 103/19/2 (17 VIBA flip + 2 RUNTIME [?] + 2 nota) + M139 138/142 (2 RUNTIME [?]) + M22 80/91 (L126/127 flip) . Gate-1 agnes OK. Filas globales 140/139/22 sync. 10 AUTO restantes: 8 reales -> [?] (TANDA 9) + M38 L41 [?]+dueño + M94 no tocar.'}
st['p100_hallazgo'] = {'desc': 'Nota que conserva "NO existe" hace P-100 marcar PARCIAL (extrae ruta entre backticks y no la resuelve). Al cerrar item cuya nota afirmaba ausencia: reescribir frase, no apilar.'}
json.dump(st, open(e, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print('estado actualizado')

# commit preservacion
res = subprocess.run(['git', 'status', '--porcelain'], cwd=root, capture_output=True, text=True)
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
    subprocess.run(['git', 'add', '-A', '--', pth], cwd=root)
ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
msg = f'''Se preservaron avances de la jornada 31oct (post-59ecee4)

- TANDA 8 DeepSeek (P-100 M140/M139/M22): M140 103/19/2 (17 VIBA flip + 2 RUNTIME [?]), M139 138/142, M22 80/91 (L126/127). Filas globales 140/139/22 sync. Hallazgo P-100 (nota "NO existe" -> PARCIAL falso).
- TANDA 4-8 serie: M59 118/130, M85 rebaseline 73/25/2 (autoría restauración silenciosa cron-bulk), M55 92/131, M11/M67/M74/M105/M115 (156 false-green Beam), BUG-151/152 resueltos. Sello M22 2026-10-15 INVALIDADO.
- Re-asignación por capacidad: 3 rieles nuevos a Nemotron (B-8/B-9/B-10 visión/boot), M67 GO a DS-OC, M140/M22 TANDA 8-9 a DeepSeek.
- estado_director.json + 11-BUGS.md + checklists 05 (M140/M139/M22/M59/M85/M55/M14/M34) + mensajes canal + .gitattributes + docs audit (auditoria-autocontradicciones, AUDITORIA-SUITES-FRAGILES, SOP).

Firma: agnes-3-flash (Sapiens AI) / Kilo Code — {ts}'''
subprocess.run(['git', 'commit', '-m', msg], cwd=root, capture_output=True, text=True)
head = subprocess.run(['git', 'log', '-1', '--oneline'], cwd=root, capture_output=True, text=True).stdout.strip()
print('HASH:', head[:40])
