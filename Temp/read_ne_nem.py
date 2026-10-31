import os, re, datetime, glob
root = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
base = root + chr(92) + 'Mensajes entre modelos' + chr(92)

def last_msg(chan, n=2):
    d = os.path.join(base, chan)
    rows = sorted((os.path.getmtime(os.path.join(d, x)), x) for x in os.listdir(d)
                  if x.endswith('.md') and re.match(r'^\d', x))
    out = []
    for m, x in rows[-n:]:
        txt = open(os.path.join(d, x), encoding='utf-8', errors='replace').read()
        out.append((x, txt))
    return out

for chan in ['Nemotron-3.5-Super-VL', 'DS-V4.1-Flash-Opencode']:
    print('==========', chan, '==========')
    for x, txt in last_msg(chan, 2):
        print('---', x[:55], '---')
        print(txt[:1500])
        print()
