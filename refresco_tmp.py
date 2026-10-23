# -*- coding: utf-8 -*-
import io, os, re

base = 'Mensajes entre modelos/G-5.3-Flash-Agente'

# 1) forzar refresco del cache del directorio: crear y borrar un archivo temporal
tmpf = os.path.join(base, '_refresh_tmp_.txt')
open(tmpf, 'wb').write(b'x')
os.remove(tmpf)

# 2) re-listar la raiz AHORA (con el cache invalidado)
raiz = []
for e in os.scandir(base):
    if e.name.endswith('.md') and re.match(r'\d{3}', e.name) and e.is_file():
        raiz.append((int(e.name[:3]), e.name))
raiz.sort()
print('RAIZ despues del refresco: %d archivos' % len(raiz))
nums = [n for n, _ in raiz]
print('rango:', min(nums) if nums else '-', 'a', max(nums) if nums else '-')
dups = {n: c for n, c in __import__('collections').Counter(nums).items() if c > 1}
print('duplicados reales:', dups if dups else 'NINGUNO')
# los 7 fantasma: existen fisicamente?
fantasmas = [f for n, f in raiz if f.startswith(('131-', '151-', '195-', '200-', '222-', '264-', '279-'))]
print('fantasma 131/151/195/200/222/264/279 fisicamente en raiz:', len(fantasmas), fantasmas[:3])
# total fisico real sobre disco
real = [n for n, f in raiz if os.path.isfile(os.path.join(base, f))]
print('fisicamente reales en raiz:', len(real))
