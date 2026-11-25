# -*- coding: utf-8 -*-
import os, re, json
ROOT = os.path.abspath('.')
d = json.load(open('Temp/b60_inspeccion.json', encoding='utf-8'))
print('Conteo [?] real por modulo (director vs disco):')
esp = {'75':87,'156':82,'74':58,'73':56,'71':44,'27':40,'159':37,'49':25,'115':26,'105':27}
tot = 0
for mid in ['75','156','74','73','71','27','159','49','105','115']:
    real = d[mid]['q']; e = esp[mid]; tot += real
    print(' M%-4s director=%-3d disco=%-3d %s' % (mid, e, real, 'OK' if e==real else 'DIF %+d'%(real-e)))
print('TOTAL disco:', tot, '| director suma:', sum(esp.values()))

# pool de canal
p = os.path.join(ROOT, 'Mensajes entre modelos', 'HY4 Flash')
nums = [int(f.split('-')[0]) for f in os.listdir(p) if re.match(r'^\d+', f)]
print('max real canal:', max(nums))
