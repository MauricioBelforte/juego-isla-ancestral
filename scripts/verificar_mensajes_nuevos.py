# -*- coding: utf-8 -*-
"""verificar_mensajes_nuevos.py — Detección SIN filro de los mensajes nuevos en los canales.

El fundador 2026-10-19 02:10: "creas un script que lanzás en el cronómetro que revise
si hay archivos nuevos en las carpetas, ahí los tenés que detectar sí o sí".

Uso:
    python scripts/verificar_mensajes_nuevos.py                        # los 7 canales por punteros
    python scripts/verificar_mensajes_nuevos.py --full                 # barrido FULL sin punteros (los últimos 3 por canal)
    python scripts/verificar_mensajes_nuevos.py <canal> --full         # un canal específico sin punteros

La lógica:
1. Para cada canal de 'Mensajes entre modelos/', leer el puntero `.ultima-revision-<agente>.txt`.
2. Listar TODO archivo `.md` con prefijo NNN (1-3 dígitos, sin padding en algunos).
3. Si el número del archivo > puntero → es un mensaje NUEVO → reportarlo con: número, fecha del nombre, asunto.
4. Sin filtrar por el nombre del receptor (el caso Hy3 259 con slug 'hy3-a-hy3' era para mí).
5. El modo --full: listar los últimos 5 archivos de cada canal (el riel del hilo activo).
"""
import io, os, re, sys

RAIZ = 'Mensajes entre modelos'
SUFIX = {
    'agnes-3-flash': 'agnes',
    'DS-V4.1-Flash-Opencode': 'ds',
    'Ling-3.1-Flash': 'ling',
    'Hy3': 'hy3',
    'DeepSeek-V4.1-Flash': 'deepseek',
    'Step-5-WorkBuddy': 'step-5',
    'G-5.3-Flash-Agente': 'agente',
}

def leer_puntero(canal, sufijo):
    p = os.path.join(RAIZ, canal, '.ultima-revision-%s.txt' % sufijo)
    if os.path.exists(p):
        try:
            return int(io.open(p, encoding='utf-8', errors='strict').read().strip())
        except (ValueError, FileNotFoundError):
            return 0
    return 0

def escanear_canal(canal, puntero):
    d = os.path.join(RAIZ, canal)
    if not os.path.isdir(d):
        return []
    archivos = []
    for f in sorted(os.listdir(d)):
        m = re.match(r'^(\d{1,3})-(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})-(.+?)\.md$', f)
        if m:
            n = int(m.group(1))
            if n > puntero:
                # leer las primeras 3 líneas para el asunto
                try:
                    t = io.open(os.path.join(d, f), encoding='utf-8', errors='strict').read()
                    asunto = ''
                    for l in t.splitlines():
                        if l.strip().startswith('# '):
                            asunto = l.strip()
                            break
                    archivos.append((n, m.group(2), m.group(3), asunto[:120]))
                except Exception:
                    archivos.append((n, m.group(2), m.group(3), '(sin leer)'))
    return archivos

def barrido_full(canal):
    d = os.path.join(RAIZ, canal)
    fs = sorted(os.listdir(d))
    mds = [f for f in fs if f.endswith('.md') and not f.startswith('__tmp__')]
    seq = sorted((int(m.group(1)), f) for f in mds for m in [re.match(r'^(\d{1,3})-(\S+)$', f)] if m)
    return seq[-5:]  # los últimos 5 por canal

def main():
    modo_full = '--full' in sys.argv
    canal_unico = None
    for a in sys.argv[1:]:
        if not a.startswith('--') and os.path.isdir(os.path.join(RAIZ, a)):
            canal_unico = a
    canales = [canal_unico] if canal_unico else sorted(SUFIX.keys())

    print('=== VERIFICAR MENSAJES NUEVOS (sin filtro de receptor) ===')
    total_nuevos = 0
    for canal in canales:
        if not os.path.isdir(os.path.join(RAIZ, canal)):
            continue
        puntero = leer_puntero(canal, SUFIX[canal])
        nuevos = escanear_canal(canal, puntero)
        total_nuevos += len(nuevos)
        if nuevos:
            print('\n%s | puntero=%d | NUEVOS=%d' % (canal, puntero, len(nuevos)))
            for n, ts, nombre, asunto in nuevos:
                print('  [%d] (%s) %s' % (n, ts, asunto if asunto else nombre[:110]))
        if modo_full:
            d_full = os.path.join(RAIZ, canal)
            if os.path.isdir(d_full):
                fs = sorted(f for f in os.listdir(d_full) if f.endswith('.md') and not f.startswith('__tmp__'))
                ult = fs[-5:]
                print('  (los últimos %d del canal:)' % len(ult))
                for u in ult:
                    print('    ', u[:75])
    if total_nuevos == 0:
        print('\nSin mensajes nuevos en los %d canales.' % len(canales))
    else:
        print('\nTOTAL: %d mensajes nuevos pendientes de procesar.' % total_nuevos)

if __name__ == '__main__':
    main()
