# -*- coding: utf-8 -*-
"""Verifica los 4 [?] de M162 desbloqueados por los catalogos M160/M158.

Para cada NPC extrae todo el texto de sus grafos y contrasta con el catalogo:
  - 52  Pescador (NPC-RIZ-005)  vs peces de M160
  - 58  Herrero Coral (COR-001) vs forja de M158
  - 78  Herrero Avanzado (CEN-001) vs hierro de M158
  - 98  Encantador (AUR-001)    vs encantamientos de M158

Veredicto por item: OK (mencion coherente con el catalogo) o FALLA (con evidencia).
"""
import json, io, os, re, glob

BASE = 'game/isla-ancestral/data/'
DLG = BASE + 'dialogues/contextual/'

def leer(p):
    with io.open(p, encoding='utf-8') as fh:
        return json.load(fh)

def texto_npc(prefijo):
    """concatena todos los text_key de los grafos de un NPC."""
    trozos = []
    archivos = sorted(glob.glob(DLG + prefijo + '_*.json'))
    for a in archivos:
        try:
            d = leer(a)
        except Exception:
            continue
        for n in d.get('nodes', {}).values():
            t = n.get('text_key')
            if t and len(t) > 3:
                trozos.append(t)
    return archivos, ' || '.join(trozos)

catalogo_m160 = leer(BASE + 'm160/catalogo_ubicaciones.json')
catalogo_m158 = leer(BASE + 'm158/catalogo_herramientas.json')
peces = leer(BASE + 'balance/fishing.json')['peces']

# nombres comunes de peces derivados del id (pez_sardina -> sardina)
nombres_pez = sorted({p['id'].replace('pez_', '').replace('_', ' ') for p in peces})
# encantamientos con su nombre en espanol
encant = [(e['id'], e.get('display_name', ''), e.get('description', '')) for e in catalogo_m158['encantamientos']]
# herramientas de hierro
herr_hierro = [h['id'] for h in catalogo_m158['herramientas'] if 'hierro' in h['id']]
# forjas
forjas = [(f['isla'], f['tier'], f.get('profesional'), f.get('materiales')) for f in catalogo_m158['forjas']]

def buscar(texto, palabras, etiqueta):
    hits = []
    low = texto.lower()
    for p in palabras:
        if p and p.lower() in low:
            hits.append(p)
    return hits

resultados = []

# ---- 52: Pescador vs peces de M160
arch, txt = texto_npc('riz_005')
hits_pez = [p for p in ('pez', 'peces', 'pesca', 'pescar', 'sardina', 'anchoa', 'carpa',
                        'trucha', 'salmon', 'atun', 'mero', 'corvina', 'boquichica') if p in txt.lower()]
sardinas = [n for n in nombres_pez if n.split()[0] in txt.lower()]
resultados.append(('52', 'Pescador (NPC-RIZ-005) vs peces de M160', len(arch), hits_pez, nombres_pez))

# ---- 58: Herrero Coral vs forja de M158
arch, txt = texto_npc('cor_001')
hits_forja = [p for p in ('forja', 'forjar', 'fragua', 'yunque', 'herrar', 'martillo') if p in txt.lower()]
menciona_isla = [f for f in forjas if f[0].replace('isla_', '') in txt.lower()]
resultados.append(('58', 'Herrero de Coral (NPC-COR-001) vs forja de M158', len(arch), hits_forja, [str(f) for f in forjas]))

# ---- 78: Herrero Avanzado vs hierro de M158
arch, txt = texto_npc('cen_001')
hits_hierro = [p for p in ('hierro', 'forja', 'yunque', 'martillo', 'mineral', 'veta', 'pico') if p in txt.lower()]
resultados.append(('78', 'Herrero Avanzado (NPC-CEN-001) vs hierro de M158', len(arch), hits_hierro, herr_hierro))

# ---- 98: Encantador vs encantamientos de M158
arch, txt = texto_npc('aur_001')
hits_enc = [p for p in ('encantamiento', 'encantar', 'encantaciones', 'runas', 'runa', 'amuleto',
                        'talisman', 'incienso') if p in txt.lower()]
nombres_enc = [e[1] for e in encant if e[1].lower() in txt.lower()]
resultados.append(('98', 'Encantador (NPC-AUR-001) vs encantamientos de M158', len(arch), hits_enc, [e[1] for e in encant]))

print('=' * 78)
for num, titulo, narch, hits, universo in resultados:
    print()
    print('ITEM %s: %s' % (num, titulo))
    print('  grafos del NPC: %d' % narch)
    print('  palabras del catalogo mencionadas: %s' % (hits if hits else 'NINGUNA'))
    print('  universo disponible en catalogo: %d elementos' % len(universo))
    if hits:
        print('  --> VEREDICTO: mencion existe; ver a continuacion si es coherente')
    else:
        print('  --> VEREDICTO: FALLA - el NPC no menciona nada del catalogo')
