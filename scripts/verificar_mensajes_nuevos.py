# -*- coding: utf-8 -*-
"""verificar_mensajes_nuevos.py — detección de mensajes sin responder (fundador 2026-10-19 02:38).

Para cada canal de `Mensajes entre modelos/`:
  - MIS = el slug del archivo contiene `glm-5.3-flash-director-a-` (emisor soy yo = mi acuse).
    El emisor va DESPUÉS de la fecha en el nombre (NN-fecha_hora-EMISOR-a-RECEPTOR-tema.md).
  - DE_EL = mi slug NO está en el nombre (emisor != yo); SIN filtro de receptor.
  - Sin responder = archivos de él con NN > mi último acuse.

No confía en .ultima-revision (el puntero prueba lectura, no respuesta).
Salida: por canal, la lista de pendientes. Exit 0 = todo respondido, 1 = hay pendientes.
UTF-8 estricto (§28). Sin BOM.
"""
import io, os, re, sys

RAIZ = 'Mensajes entre modelos'
CANALES = ['agnes-3-flash', 'DS-V4.1-Flash-Opencode', 'Hy3', 'DeepSeek-V4.1-Flash',
           'Step-5-WorkBuddy', 'Ling-3.1-Flash', 'G-5.3-Flash-Agente', 'MiniMax-M3.1-Flash', 'Reflection-Beam-1.0']
MIO = 'glm-5.3-flash-director-a-'

def es_mio(f):
    nom = f.lower().replace('glm-53-flash-director-a-', MIO)
    return MIO in nom

pend_total = 0
for c in CANALES:
    D = os.path.join(RAIZ, c)
    if not os.path.isdir(D):
        print('%s: SIN CARPETA' % c)
        continue
    max_mio = 0
    de_el = []
    for f in os.listdir(D):
        m = re.match(r'^(\d{1,3})-', f)
        if not m:
            continue
        nn = int(m.group(1))
        if es_mio(f):
            max_mio = max(max_mio, nn)
        else:
            de_el.append((nn, f))
    pend = sorted((nn, f) for nn, f in de_el if nn > max_mio)
    pend_total += len(pend)
    if pend:
        print('%s: %d SIN RESPONDER (mi ultimo acuse: %03d)' % (c, len(pend), max_mio))
        for nn, f in pend:
            print('   %03d%s' % (nn, f[3:105]))
    else:
        max_el = max((nn for nn, _ in de_el), default=0)
        print('%s: al dia (el %03d | mi acuse %03d)' % (c, max_el, max_mio))

print('TOTAL sin responder: %d' % pend_total)
sys.exit(1 if pend_total else 0)
