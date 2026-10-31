import os, re, datetime, glob
root = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
base = root + chr(92) + 'Mensajes entre modelos' + chr(92)

for chan in ['Nemotron-3.5-Super-VL', 'DS-V4.1-Flash-Opencode']:
    d = os.path.join(base, chan)
    ns = [int(x.split('-', 1)[0]) for x in os.listdir(d) if x.endswith('.md') and re.match(r'^\d', x) and int(x.split('-',1)[0]) < 1000]
    print(chan, '| next =', max(ns) + 1, '| last 4:', sorted(ns)[-4:])
    # leer 225-229 de DS-OC (los que no acuse)
    if chan == 'DS-V4.1-Flash-Opencode':
        for n in [225, 226, 227, 228]:
            for f in glob.glob(d + chr(92) + str(n) + '-*'):
                c = open(f, encoding='utf-8', errors='replace').read()
                print('  #', n, ':', c.split(chr(10))[0][:20], '->', c.split('**Responde a:**')[-1][:60] if '**Responde a:**' in c else '(sin responde-a)')
                # resumen
                for l in c.split(chr(10)):
                    if l.strip().startswith('- **') or 'M1' in l[:20] and 'DEGRAD' in l.upper():
                        print('      ', l.strip()[:90])
                break
