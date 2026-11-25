# -*- coding: utf-8 -*-
import json
items = json.load(open('Temp/b61_go27_items.json', encoding='utf-8'))
for mod in ['21','33','44','137']:
    print('######## M%s' % mod)
    for it in items:
        if it['mod']==mod:
            print('L%-4d %s' % (it['line'], it['text']))
    print()
