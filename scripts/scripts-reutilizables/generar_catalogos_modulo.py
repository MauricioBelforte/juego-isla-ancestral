# -*- coding: utf-8 -*-
"""Genera los catalogos por modulo M160 y M158 (encargo del director, mensaje 371).

No duplica datos: cada catalogo es un INDICE que referencia por id las fuentes
existentes por dominio (data/balance/fishing.json, data/mining/ores.json,
data/ubicaciones/ubicaciones.json, data/islas/islas.json,
data/balance/tools.json, data/herramientas/tiers_config.json,
data/enchantments/*.tres).

Incluye validacion basica: todo id referenciado debe existir en su fuente.
"""
import json, io, os, re, sys

BASE = 'game/isla-ancestral/data/'

def leer(rel):
    with io.open(BASE + rel, encoding='utf-8') as fh:
        return json.load(fh)

def leer_tres(rel):
    txt = io.open(BASE + rel, encoding='utf-8').read()
    d = {}
    for line in txt.splitlines():
        m = re.match(r'^([a-z_]+)\s*=\s*(.+)$', line.strip())
        if m and m.group(1) not in ('script', 'icon'):
            d[m.group(1)] = m.group(2)
    return d

ubicaciones = leer('ubicaciones/ubicaciones.json')['ubicaciones']
islas = leer('islas/islas.json')['islas']
peces = leer('balance/fishing.json')['peces']
ores = leer('mining/ores.json')
tools = leer('balance/tools.json')['herramientas']
tiers = leer('herramientas/tiers_config.json')
crafting = leer('balance/crafting.json')['recetas']

encantamientos = {}
for f in sorted(os.listdir(BASE + 'enchantments')):
    if f.endswith('.tres'):
        raw = leer_tres('enchantments/' + f)
        enc = {
            'id': raw['id'].strip('"'),
            'display_name': raw['display_name'].strip('"'),
            'description': raw['description'].strip('"'),
            'tool_tier': int(raw['tool_tier']),
            'ability_type': raw['ability_type'].strip('"'),
            'ability_value': float(raw['ability_value']),
            'incense_cost': int(raw['incense_cost']),
            'coin_cost': int(raw['coin_cost']),
            'fuente': 'data/enchantments/' + f,
        }
        encantamientos[enc['id']] = enc

# biomas con agua (deducido de data/islas/islas.json: campo biomas)
BIOMAS_AGUA = ('playa', 'arrecife', 'laguna', 'lago', 'rio')

errores = []

def check(cond, msg):
    if not cond:
        errores.append(msg)

# ---------------------------------------------------------------- M160
minerales_por_region = {}
for o in ores:
    minerales_por_region.setdefault(o['region'], []).append(o['id'])

# peces por bioma especifico (solo los que lo declaran)
peces_bioma = {}
for p in peces:
    for b in p.get('biomas', []):
        peces_bioma.setdefault(b, []).append(p['id'])

ubic_m160 = []
for u in ubicaciones:
    cod = u['isla']
    check(cod in islas, 'ubicacion %s referencia isla inexistente %s' % (u['id'], cod))
    biomas_isla = islas.get(cod, {}).get('biomas', [])
    pesca = any(b in BIOMAS_AGUA for b in biomas_isla)
    # minerales: solo region templo mapea directo a ubicaciones tipo templo
    minerales = []
    if u['tipo'] == 'templo':
        minerales = list(minerales_por_region.get('templo', []))
    ubic_m160.append({
        'id': u['id'],
        'nombre': u['nombre'],
        'isla': cod,
        'tipo': u['tipo'],
        'sello': u.get('sello', ''),
        'coords': [u['x'], u['z']],
        'biomas_isla': biomas_isla,
        'pesca_disponible': pesca,
        'minerales': minerales,
        'templos_relacionados': [u['id']] if u['tipo'] == 'templo' else [],
    })

m160 = {
    'schema_version': 1,
    'modulo': 'M160',
    'titulo': 'Catalogo de ubicaciones del mundo (indice por modulo)',
    'generado': '2026-10-15',
    'nota': (
        'Indice que cruza las fuentes por dominio ya existentes; NO duplica datos, '
        'referencia por id. Fuentes: data/ubicaciones/ubicaciones.json, '
        'data/islas/islas.json, data/balance/fishing.json, data/mining/ores.json, '
        'data/herramientas/tiers_config.json.'
    ),
    'islas': [
        {'codigo': c, 'nombre': v['nombre'], 'biomas': v['biomas'],
         'centro': v['centro'], 'radio': v['radio'], 'pesca': any(b in BIOMAS_AGUA for b in v['biomas'])}
        for c, v in islas.items()
    ],
    'ubicaciones': ubic_m160,
    'minerales_por_region': minerales_por_region,
    'zonas_por_gate': [
        {'gate_id': g['gate_id'], 'zone_id': g['zone_id'], 'tipo': g['tipo'],
         'required_tier': g['required_tier'], 'required_tool': g['required_tool'],
         'blocks_story': g['blocks_story']}
        for g in tiers['gates']
    ],
    'peces': {
        'fuente': 'data/balance/fishing.json',
        'total': len(peces),
        'por_bioma_declarado': peces_bioma,
        'resto': 'sin campo de ubicacion/isla en datos: aplican por temporada, hora y clima',
    },
    'huecos_de_mapeo': [
        'Las regiones de mining ("cantera", "cueva") no tienen ubicacion en data/ubicaciones/ubicaciones.json.',
        'Los zone_id de los gates (zona_cantera, zona_cueva_cristal, zona_raices, ...) no mapean a ningun id ubic_* de ubicaciones.json.',
        '23 de 25 peces no tienen campo de ubicacion: el mapeo pez->ubicacion no existe en datos.',
        'veta_oro y veta_polvo_estrellas comparten item_id "ancient_crystal" en data/mining/ores.json.',
    ],
}

# ---------------------------------------------------------------- M158
tier_por_nombre = {t['nombre'].lower(): t['id'] for t in tiers['tiers']}

herramientas = []
MATERIALES_TIER = ('cobre', 'hierro', 'oro', 'cristal')
for hid, h in tools.items():
    material = hid.split('_')[-1]
    tier_id = tier_por_nombre.get(material) if material in MATERIALES_TIER else None
    receta = None
    for rid, r in crafting.items():
        if r.get('resultado') == hid:
            receta = rid
            break
    check(tier_id is not None or material not in MATERIALES_TIER,
          'herramienta %s con material %s pero sin tier en tiers_config' % (hid, material))
    herramientas.append({
        'id': hid,
        'material': material if material in MATERIALES_TIER else None,
        'nivel_en_tools_json': h['nivel'],
        'nivel_en_tiers_config': next((t['nivel'] for t in tiers['tiers'] if t['id'] == tier_id), None),
        'tier': tier_id,
        'durabilidad': h['durabilidad'],
        'coste_mejora': h['coste_mejora'],
        'receta': receta,
    })

# drift nivel vs tier (hallazgo de datos, no se corrige aqui)
drift_niveles = [h['id'] for h in herramientas if h['nivel_en_tools_json'] != h['nivel_en_tiers_config']]

# recetas declaradas para herramientas de hierro (no existen)
sin_receta = [h['id'] for h in herramientas if h['receta'] is None]

m158 = {
    'schema_version': 1,
    'modulo': 'M158',
    'titulo': 'Catalogo de herramientas, forja y encantamientos (indice por modulo)',
    'generado': '2026-10-15',
    'nota': (
        'Indice que cruza las fuentes por dominio ya existentes; NO duplica datos, '
        'referencia por id. Fuentes: data/balance/tools.json, '
        'data/herramientas/tiers_config.json, data/balance/crafting.json, '
        'data/enchantments/*.tres.'
    ),
    'tiers': tiers['tiers'],
    'herramientas': herramientas,
    'desbloqueo_de_zonas': tiers['gates'],
    'forjas': tiers['forjas'],
    'profesiones': tiers['cursos'],
    'encantamientos': list(encantamientos.values()),
    'huecos_de_datos': [
        'Las herramientas de hierro (pico_hierro, hacha_hierro) existen en data/balance/tools.json pero NO tienen receta en data/balance/crafting.json.',
        'Drift de nivel: tools.json y tiers_config.json no coinciden en el nivel de las herramientas (%s).' % ', '.join(drift_niveles),
        'Las forjas usan ids de isla (isla_raiz) distintos a los codigos de data/islas/islas.json (RIZ, COR, CEN, AUR).',
        'No hay encantamiento de tier para hacha/pala/martillo: los encantamientos declaran tool_tier pero no tool_id.',
    ],
}

# ---------------------------------------------------------------- escritura + validacion
os.makedirs(BASE + 'm160', exist_ok=True)
os.makedirs(BASE + 'm158', exist_ok=True)

for rel, data in (('m160/catalogo_ubicaciones.json', m160),
                  ('m158/catalogo_herramientas.json', m158)):
    with io.open(BASE + rel, 'w', encoding='utf-8', newline='\n') as fh:
        json.dump(data, fh, ensure_ascii=False, indent=2)
        fh.write('\n')
    # relectura: valida que el JSON es parseable
    json.loads(io.open(BASE + rel, encoding='utf-8').read())
    print('escrito y validado:', BASE + rel)

# validacion de integridad referencial
for u in ubic_m160:
    for mid in u['minerales']:
        check(mid in [o['id'] for o in ores], 'mineral inexistente referenciado: ' + mid)
for h in herramientas:
    if h['receta']:
        check(h['receta'] in crafting, 'receta inexistente: ' + h['receta'])

if errores:
    print('\nERRORES DE VALIDACION:')
    for e in errores:
        print('  -', e)
    sys.exit(1)
print('\nValidacion de integridad referencial: OK (0 errores)')
print('M160: %d ubicaciones, %d islas, %d minerales por region, %d peces referenciados'
      % (len(ubic_m160), len(m160['islas']), len(minerales_por_region), len(peces)))
print('M158: %d herramientas, %d tiers, %d gates, %d forjas, %d encantamientos'
      % (len(herramientas), len(m158['tiers']), len(m158['desbloqueo_de_zonas']),
         len(m158['forjas']), len(m158['encantamientos'])))
