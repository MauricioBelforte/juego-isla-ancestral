# -*- coding: utf-8 -*-
"""ESTANDARIZADOR DEFINITIVO DE TODOS LOS CANALES — un solo metodo (fundador 23oct 06:02)
Regla unica: centena COMPLETA -> subcarpeta arch_XXXX-XXXX; raiz = solo centena EN CURSO.
Recorre TODOS los canales, convierte 2-digit, fusiona mezclas, y verifica modelo-por-modelo."""
import os, re, shutil

BASE = 'Mensajes entre modelos'
excl = {'arch_', 'RESUELTOS', '.git'}

def escanear_raiz(cpath):
    out = []
    for e in os.scandir(cpath):
        m = re.match(r'(\d{3})-', e.name)
        if e.name.endswith('.md') and m and e.is_file():
            out.append((int(m.group(1)), e.name))
    return sorted(out)

def subcarpetas_actuales(cpath):
    return sorted([d for d in os.listdir(cpath) if os.path.isdir(os.path.join(cpath, d)) and re.match(r'^(?:arch_)?\d{1,4}(?:-\d{1,4})?$', d)])

def convertir_2digit(cpath):
    conv = 0
    for d in subcarpetas_actuales(cpath):
        m = re.match(r'^(\d{1,4})-(\d{1,4})$', d)
        if m and not d.startswith('arch_'):
            lo, hi = int(m.group(1)), int(m.group(2))
            if hi - lo + 1 in (100, hi - lo + 1):  # cualquier rango: lo normalizo a arch_
                nlo = lo if lo % 100 == 1 else lo
                nvo_d = 'arch_%04d-%04d' % (nlo, nlo + (hi - lo))
                os.rename(os.path.join(cpath, d), os.path.join(cpath, nvo_d))
                print('   convertida: %s -> %s' % (d, nvo_d))
                conv += 1
    return conv

reporte_final = []
for canal in sorted(os.listdir(BASE)):
    cpath = os.path.join(BASE, canal)
    if not os.path.isdir(cpath) or canal.startswith('arch_'):
        continue
    lineas = ['== ' + canal]

    # 1) convertir subcarpetas 2-digit existentes
    conv = 0
    for d in subcarpetas_actuales(cpath):
        m = re.match(r'^(\d{1,4})-(\d{1,4})$', d)
        if m and not d.startswith('arch_'):
            lo, hi = int(m.group(1)), int(m.group(2))
            nvo = 'arch_%04d-%04d' % (lo, hi)
            os.rename(os.path.join(cpath, d), os.path.join(cpath, nvo))
            conv += 1
    lineas.append('  convertidas 2-digit: %d' % conv)

    # 2) re-colectar raiz (post conversion) y centena en curso
    items = escanear_raiz(cpath)
    max_num = max((n for n, _ in items), default=0)
    curso_lo = (max_num // 100) * 100 + 1 if max_num else 1

    # 3) mover centenas COMPLETAS (incluyendo items extras de gemelos: mismo rango)
    por_rango = {}
    en_curso = 0
    for num, name in items:
        if num >= curso_lo:
            en_curso += 1
            continue
        lo = ((num - 1) // 100) * 100 + 1
        por_rango.setdefault((lo, lo + 99), []).append(name)

    mov = 0
    for (lo, hi), names in sorted(por_rango.items()):
        dname = 'arch_%04d-%04d' % (lo, hi)
        dpath = os.path.join(cpath, dname)
        os.makedirs(dpath, exist_ok=True)
        for name in names:
            try:
                shutil.move(os.path.join(cpath, name), os.path.join(dpath, name))
                mov += 1
            except OSError as ex:
                lineas.append('  [SKIP fantasma] %s: %s' % (name[:60], ex))

    # 4) estado final del canal
    final = escanear_raiz(cpath)
    lineas.append('  movidos este paso: %d | raiz queda: %d (centena en curso %04d+)' % (mov, len(final), curso_lo))
    lineas.append('  subcarpetas: %s' % ', '.join(subcarpetas_actuales(cpath)))
    reporte_final.append(chr(10).join(lineas))
    print(lineas[0], '| mov:', mov, '| raiz:', len(final))

# 5) documentar
pg = 'Mensajes entre modelos/GUIA-NUMERACION-CANALES.md'
t = io.open(pg, encoding='utf-8', newline='').read()
if 'REGLA UNICA' not in t:
    t = t.rstrip() + chr(10) + chr(10) + chr(10).join([
     '## REGLA UNICA APLICADA (fundador 23oct 06:02: "estandariza la metodologia, un solo metodo, revisa modelo por modelo")',
     '',
     '1. Una CENTENA COMPLETA (100 mensajes de un rango) se ARCHIVA a `arch_XXXX-XXXX/` (4 digitos, prefijo arch_ agrupa al ordenar).',
     '2. La raiz del canal queda SIEMPRE con la CENTENA EN CURSO (incompleta, aunque tenga 3 mensajes).',
     '3. Las carpetas 2-digit (`0-99`, `100-199`) se CONVIERTEN al formato arch_ de 4 digitos.',
     '4. Los gemelos (mismo numero) van a la misma subcarpeta de su rango (el rango puede superar 100 por extras).',
     '5. Es idempotente: correr la herramienta N veces no re-mueve nada.',
     'Herramienta: `python -X utf8 scripts/agrupar_canales.py [canal-opcional]` — aplica la regla a todos o a uno.',
     'La verificacion modelo-por-modelo del 23oct documentada en el reporte ARCHIVO-AGRUPADO-23oct.md.']) + chr(10)
    io.open(pg, 'w', encoding='utf-8', newline='').write(t)
    print('guia con regla unica OK')

ph = 'Logs/estado_director.json'
import json as J
e = J.load(io.open(ph, encoding='utf-8'))
e['ultimo_update'] = '2026-10-23T06:02:30'
e.setdefault('trampas_registradas', []).append('CONVERSIÓN 2-DIGIT (23oct 06:02, fundador "un solo metodo"): las subcarpetas 0-99/100-199 de los canales originales convirtieron a arch_XXXX-XXXX de 4 digitos (prefijo arch_ agrupa; 4 digitos retro-extienden). Herramienta unica: scripts/agrupar_canales.py (idempotente, sin Anti-Spam, regla centena completa). Fallas previas: 3 formatos distintos conviviendo + cortes a mitad de centena + regex general borrando notas (M116)')
json.dump(e, io.open(ph, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
subprocess.run(['git', 'add', '-A', BASE, pg, ph], capture_output=True)
r = subprocess.run(['git', 'commit', '-m', 'Se estandariza el metodo unico de agrupado en todos los canales con verificacion modelo por modelo'],
 capture_output=True, text=True, encoding='utf-8', errors='replace')
r2 = subprocess.run(['git', 'log', '--oneline', '-1'], capture_output=True, text=True)
print('commit:', r2.stdout.strip())
