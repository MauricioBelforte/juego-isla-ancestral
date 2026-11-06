#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# sonda_v25_flota.py v2 — SONDA i18n de la movida de flota post-v24 (Ling-3.1-Flash, vuelta 25).
# Lista base = git status --porcelain (todo lo tocado por la flota en el WT, incluye ??).
# Metodo canonico vueltas 9-19: (1) acentos en codigo fuera de comentarios .gd;
# (2) literales ES con palabras funcionales sin consumo tr(/tr_key(/_t( = candidatos
# jugador-visible; print/push_error/push_warning/log_ = dev-side (0 deuda jugador).
import io, os, re, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = HERE
for _ in range(5):
    if os.path.isdir(os.path.join(ROOT, 'game')) and os.path.isdir(os.path.join(ROOT, 'DOCUMENTACION')):
        break
    ROOT = os.path.dirname(ROOT)

proc = subprocess.run(['git', 'status', '--porcelain'], cwd=ROOT,
                      capture_output=True, text=True, encoding='utf-8')
files = []
for line in proc.stdout.splitlines():
    if len(line) < 4:
        continue
    p = line[3:].strip()
    if p.startswith('"') and p.endswith('"'):
        p = p[1:-1]
    if not (p.endswith('.gd') or p.endswith('.json')):
        continue
    if not p.startswith('game/'):
        continue
    files.append(p)
files = sorted(set(files))

ACCENTOS = re.compile(r'[áéíóúñ¿¡ÁÉÍÓÚÑ]')
DEV_SIDE = re.compile(r'print\(|push_error|push_warning|push_log|\blog_|_log\(|console|#|assert\(|OS\.alert|print_debug', re.I)
LOCALIZADO = re.compile(r'tr\(|tr_key\(|_t\(|meta_texto\(|tr_str\(|translate\(', re.I)
SPANISH_WORDS = re.compile(
    r'\b(el|la|los|las|de|del|para|sin|con|una|uno|jugador|partida|guardar|cargar|'
    r'salir|volver|inventario|isla|islas|viaje|diario|pesca|objeto|objetos|nivel|'
    r'mensaje|error|correcto|incorrecto|completado|cancelar|confirmar|hora|horas|'
    r'minuto|minutos|segundo|segundos|moneda|monedas|tienda|dia|noche)\b', re.I)
STRING_LIT = re.compile(r'"([^"\\]|\\.)*"')

total_acentos = 0
total_dev = 0
total_candidatos = 0
print(f'ROOT detectado: {ROOT}')
print(f'Archivos .gd/.json movidos por la flota bajo game/: {len(files)}')
for rel in files:
    print(f'  - {rel}')
print('=' * 70)

for rel in files:
    p = os.path.join(ROOT, rel)
    if not os.path.isfile(p):
        print(f'[FALTA] {rel}')
        continue
    is_gd = rel.endswith('.gd')
    raw = io.open(p, encoding='utf-8', errors='strict').read()
    ls = raw.splitlines()
    hits_acc = []
    hits_cand = []
    for i, linea in enumerate(ls, 1):
        s = linea.strip()
        if not s:
            continue
        if is_gd and s.startswith('#'):
            continue
        if ACCENTOS.search(s):
            dev = bool(DEV_SIDE.search(s))
            hits_acc.append((i, 'DEV-SIDE' if dev else 'REVISAR', s[:150]))
            if dev:
                total_dev += 1
        if SPANISH_WORDS.search(s) and not LOCALIZADO.search(s):
            for m in STRING_LIT.finditer(s):
                txt = m.group(0)
                if SPANISH_WORDS.search(txt):
                    dev = bool(DEV_SIDE.search(s))
                    hits_cand.append((i, 'DEV-SIDE' if dev else 'CANDIDATO-JUGADOR', txt[:120]))
    n_acc = len(hits_acc)
    n_cand = len([h for h in hits_cand if h[1] == 'CANDIDATO-JUGADOR'])
    total_acentos += n_acc
    total_candidatos += n_cand
    print(f'===== {rel} =====')
    if not hits_acc and not hits_cand:
        print('  (0 hits acentos, 0 literales ES sin tr) — LIMPIO')
    for i, clase, txt in hits_acc:
        print(f'  [acento L{i} {clase}] {txt}')
    for i, clase, txt in hits_cand:
        print(f'  [literal L{i} {clase}] {txt}')
    print('')
print(f'TOTAL acentos en codigo: {total_acentos} (dev-side: {total_dev}) | TOTAL candidatos jugador-visible: {total_candidatos}')
