# -*- coding: utf-8 -*-
import json, io

e = json.load(open('Logs/estado_director.json', encoding='utf-8'))
out = io.open(r'game\isla-ancestral\scripts\saving\_paso0.txt', 'w', encoding='utf-8')
for k in ['ultimo_update', 'fundador_ultimo_mensaje', 'g_5_3', 'deepseek', 'derivaciones_pendientes', 'trampas_registradas']:
    v = e.get(k)
    if isinstance(v, list):
        out.write(k + ': ' + ' | '.join(str(x)[:140] for x in v) + '\n')
    elif isinstance(v, dict):
        out.write(k + ': ' + json.dumps(v, ensure_ascii=False)[:400] + '\n')
    else:
        out.write(k + ': ' + str(v)[:300] + '\n')
out.close()
print('ok')
