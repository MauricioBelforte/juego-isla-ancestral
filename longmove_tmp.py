# -*- coding: utf-8 -*-
import os

base = os.path.abspath('Mensajes entre modelos/G-5.3-Flash-Agente')
prefijo = chr(92) * 4 + '?' + chr(92)  # \\?\ (4 backslashes: 2 de escape + separador)
objetos = [
 (131, 'arch_0101-0200'),
 (151, 'arch_0101-0200'),
 (195, 'arch_0101-0200'),
 (200, 'arch_0101-0200'),
 (222, 'arch_0201-0300'),
 (264, 'arch_0201-0300'),
 (279, 'arch_0201-0300'),
]
movidos = 0
for e in os.listdir(base):
    for num, sub in objetos:
        if e.startswith(str(num) + '-') and e.endswith('.md'):
            src_lp = prefijo + os.path.join(base, e)
            dst_dir = os.path.join(base, sub)
            if not os.path.isdir(dst_dir):
                os.makedirs(dst_dir, exist_ok=True)
            dst_lp = prefijo + os.path.join(dst_dir, e)
            try:
                datos = open(src_lp, 'rb').read()
                open(dst_lp, 'wb').write(datos)
                os.remove(src_lp)
                print('%03d movido (%d bytes)' % (num, len(datos)))
                movidos += 1
            except Exception as ex:
                print('%03d fallo: %s' % (num, ex))
print('total movidos:', movidos)
