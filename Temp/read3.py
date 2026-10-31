import os, re, datetime
root = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
b = root + chr(92) + 'Mensajes entre modelos' + chr(92)
for c in ['DeepSeek-V4.1-Flash', 'Nemotron-3.5-Super-VL', 'Ling-3.1-Flash']:
    d = os.path.join(b, c)
    rows = sorted((os.path.getmtime(os.path.join(d, x)), x) for x in os.listdir(d)
                  if x.endswith('.md') and re.match(r'^\d{3,4}-', x))
    print('====', c, '====')
    for m, x in rows[-1:]:
        print(datetime.datetime.fromtimestamp(m).strftime('%H:%M'), x[:45])
        txt = open(os.path.join(d, x), encoding='utf-8', errors='replace').read()
        for l in txt.split(chr(10)):
            if l.startswith('#') or 'hecho=' in l or 'M1' in l[:15] or 'hecho' in l[:40]:
                print('   ', l[:95])
    print()
