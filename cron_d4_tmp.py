# -*- coding: utf-8 -*-
import os, re, time, json, io, subprocess

YO = 'glm-5.3-flash-director-a-'
tot = 0
for canal in sorted(os.listdir('Mensajes entre modelos')):
    base = os.path.join('Mensajes entre modelos', canal)
    if not os.path.isdir(base):
        continue
    el, mi = 0, 0
    for f in os.listdir(base):
        m = re.match(r'(\d{3})-', f)
        if f.endswith('.md') and m:
            v = int(m.group(1)); mio = YO in f.lower()
            if mio:
                mi = max(mi, v)
            else:
                el = max(el, v)
    if el > mi:
        tot += 1; print(canal, 'SIN RESPONDER', el - mi)
        for f in sorted(os.listdir(base)):
            m = re.match(r'(\d{3})-', f)
            if f.endswith('.md') and m and not (YO in f.lower()) and mi < int(m.group(1)) <= el:
                print('   ->', f)
print('TOTAL:', tot)

act = {}
for ag, base2 in (('Beam', 'Mensajes entre modelos/Reflection-Beam-1.0'), ('G-5.3', 'Mensajes entre modelos/G-5.3-Flash-Agente'), ('DS-OC', 'Mensajes entre modelos/DS-V4.1-Flash-Opencode'), ('agnes', 'Mensajes entre modelos/agnes-3-flash')):
    rec = [f for f in os.listdir(base2) if f.endswith('.md') and __import__("time").time() - os.path.getmtime(os.path.join(base2, f)) < 3600]
    act[ag] = len(rec)
print('actividad 1h:', act)

ph = 'Logs/estado_director.json'
e = json.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-23T03:36:30'
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
subprocess.run(['git', 'add', ph], capture_output=True)
subprocess.run(['git', 'commit', '-m', 'Punto del cron d'], capture_output=True)
print('OK')
