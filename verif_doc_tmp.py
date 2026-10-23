# -*- coding: utf-8 -*-
import io, os, re

BASE = 'Mensajes entre modelos'

# ============ VERIFICACION FINAL ============
print('===== VERIFICACION DE CANALES CONVERTIDOS =====')
for canal in ('DeepSeek-V4.1-Flash', 'Hy3'):
    cpath = os.path.join(BASE, canal)
    raiz = sum(1 for f in os.listdir(cpath) if re.match(r'\d{3}-', f) and f.endswith('.md') and os.path.isfile(os.path.join(cpath, f)))
    subs = sorted([d for d in os.listdir(cpath) if os.path.isdir(os.path.join(cpath, d)) and re.match(r'arch_\d{4}', d)])
    total_subs = {}
    for s in subs:
        total_subs[s] = sum(1 for _ in os.scandir(os.path.join(cpath, s)))
    print('[%s] raiz=%d | subcarpetas: %s' % (canal, raiz, total_subs))

# ============ GUÍA con el MÉTODO documentado ============
pg = 'Mensajes entre modelos/GUIA-NUMERACION-CANALES.md'
t = io.open(pg, encoding='utf-8', newline='').read()
if 'METODO ESTANDAR DE EJECUCION' not in t:
    t = t.rstrip() + chr(10) + chr(10) + chr(10).join([
     '## MÉTODO ESTÁNDAR DE EJECUCIÓN (fundador 23oct 05:55: "revisa bien todo y documenta el metodo")',
     '',
     'Casos probados en los canales reales esta noche (Beam renumerado 001-276, DeepSeek e Hy3 convertidos de 2-digit a arch, 251 sueltos migrados con long-path):',
     '',
     '1. **Convertir carpetas 2-digit al estándar**: `0-99` → `arch_0001-0100`, `100-199` → `arch_0101-0200` (renombro de carpeta entera con os.rename — path corto a nivel carpeta).',
     '2. **Migrar sueltos en raíz con rutas > MAX_PATH**: `open()` con el prefijo long-path de Windows: `chr(92)*2 + ?? + chr(92)` + os.path.abspath(path). El prefijo cancela la limitación de 260 chars.',
     '3. **CRÍTICO: nunca escribir estos scripts con -c inline de PowerShell** — el doble escape de backslashes corrompe el prefijo long-path (8 barritas en vez de 4). SIEMPRE escribir el script a archivo con write-tool y ejecutarlo con `python -X utf8 archivo.py`.',
     '4. **Regla de centena completa del fundador (23oct 05:36)**: una centena se archiva SOLO cuando tiene sus 100 EXACTOS; en la raíz queda SIEMPRE la centena en curso (aunque tenga 3).',
     '5. **Verificación post-migración**: raíz debe quedar con la centena en curso (0-100 items), subcarpetas con 100 EXACTOS cada una, y isfile/waitdog limpio.',
     '',
     '**Caso especial — entrada fantasma persistente del canal DS-OC** (015-2026-10-16 con ruta 268 chars): `scandir` la lista pero open/rename dan ENOENT aunque use el prefijo. El contenido está versionado en git. Queda como una anomalia documentada hasta que se acorte la ruta del repo o se habiliten las rutas largas a nivel Windows (registro LongPathsEnabled=1 + reinicio).', '', ''])
    io.open(pg, 'w', encoding='utf-8', newline='').write(t)
    print('GUIA documentada con el metodo')

# ============ canal G-5.3: limpiar el analisis-estrategia del message 276 del listing viejo? ya está en arch ============
# ============ commit todo ============
subprocess.run(['git', 'add', '-A', BASE, pg], capture_output=True)
r = subprocess.run(['git', 'commit', '-m', 'Se documenta el metodo estandar de conversion y migracion en la sop de numeracion'], capture_output=True, text=True, encoding='utf-8', errors='replace')
r2 = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit final:', r2.stdout.strip())
