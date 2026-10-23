# -*- coding: utf-8 -*-
import io, os, shutil

base = 'Mensajes entre modelos/G-5.3-Flash-Agente'
objetos = [
 (131, 'arch_0101-0200'),
 (151, 'arch_0101-0200'),
 (195, 'arch_0101-0200'),
 (200, 'arch_0101-0200'),
 (222, 'arch_0201-0300'),
 (264, 'arch_0201-0300'),
 (279, 'arch_0201-0300'),
]
movidos, fallos = 0, []
for e in os.scandir(base):
    m = re.match(r'(\d{3})-', e.name)
    if not (e.name.endswith('.md') and m and e.is_file()):
        continue
    n = int(m.group(1))
    destino = next((d for num, d in objetos if num == n), None)
    if not destino:
        continue
    dpath = os.path.join(base, destino)
    os.makedirs(dpath, exist_ok=True)
    try:
        shutil.move(e.path, os.path.join(dpath, e.name))
        movidos += 1
    except Exception as ex:
        fallos.append((n, str(ex)))
print('movidos definitivamente:', movidos, '| fallos:', fallos)

# verificacion final de raiz
raiz = sorted(int(f[:3]) for f in os.listdir(base) if f.endswith('.md') and re.match(r'\d{3}', f))
print('raiz final:', len(raiz), '| numeros:', raiz[:6], '...', raiz[-3:] if len(raiz) > 6 else '')
print('todos >= 301:', all(n >= 301 for n in raiz))
