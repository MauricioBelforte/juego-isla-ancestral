# -*- coding: utf-8 -*-
import json
d = json.load(open('Temp/b60_clasificacion.json', encoding='utf-8'))
for mid in ['159', '49', '105', '115']:
    v = d[mid]
    print('################ M%s %s (%d candidatos)' % (mid, v['path'], v['cats'].get('candidato', 0)))
    for it in v['items']:
        if it['cat'] == 'candidato':
            print('L%-4d %s' % (it['line'], it['text']))
    print()
