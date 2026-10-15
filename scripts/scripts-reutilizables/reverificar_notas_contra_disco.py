# -*- coding: utf-8 -*-
"""Reverifica las notas de los 49 [?] de M31 contra disco.

Para cada nota extrae las afirmaciones verificables (existe/no existe, hits=0,
numeros de linea) y las contrasta con el contenido real de scripts/ y data/.
Clasifica cada item en:
  OK        -> la nota es correcta
  INFLADA   -> la nota afirma existencia/consumo que no existe (degradar)
  SIN_DATOS -> no se pudo verificar automaticamente
"""
import io, os, re, glob, json, sys

BASE = 'game/isla-ancestral/'
# cargar todos los .gd y .json una vez
gd_text = {}
for p in glob.glob(BASE + 'scripts/**/*.gd', recursive=True):
    try:
        gd_text[p.replace(os.sep, '/')] = io.open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        pass
tscn_text = {}
for p in glob.glob(BASE + 'scenes/**/*.tscn', recursive=True):
    try:
        tscn_text[p.replace(os.sep, '/')] = io.open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        pass
json_text = {}
for p in glob.glob(BASE + 'data/**/*.json', recursive=True):
    try:
        json_text[p.replace(os.sep, '/')] = io.open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        pass

TODO_GD = '\n'.join(gd_text.values())
TODO_TSCN = '\n'.join(tscn_text.values())
TODO_JSON = '\n'.join(json_text.values())

def hits(pat, todo):
    return len(re.findall(pat, todo, re.I))

# --- afirmaciones a verificar: (regex del item, descripcion, funcion de chequeo)
CHECKS = []

def check(nlinea, desc, fn):
    CHECKS.append((nlinea, desc, fn))

def c_estrellas_consumo():
    """Alguien lee la clave estrellas fuera de tests?"""
    consumidores = []
    for p, t in gd_text.items():
        if 'test_' in p:
            continue
        if re.search(r'\[.estrellas.\]|get\(.estrellas', t):
            consumidores.append(p)
    return consumidores

def c_fogvolume():
    return [p for p, t in tscn_text.items() if 'FogVolume' in t]

def c_fog_curve_consumo():
    """Alguien carga fog_curve.tres fuera de generadores/validadores?"""
    return [p for p, t in gd_text.items()
            if 'fog_curve' in t and 'gen_' not in p and 'validate' not in p]

def c_nubes():
    return [p for p, t in gd_text.items()
            if re.search(r'\b(nubes|velo|drift)\b', t) and 'test_' not in p]

def c_canvas_estrellas():
    return [p for p, t in gd_text.items()
            if re.search(r'estrella', t, re.I) and 'test_' not in p]

def c_farol_prefab():
    return [p for p, t in tscn_text.items()
            if 'farol' in t.lower() and 'OmniLight' in t]

def c_es_de_dia():
    return [p for p, t in gd_text.items() if 'func es_de_dia' in t]

def c_hora_cambio_m19():
    return [p for p, t in gd_text.items() if 'hora_cambio' in t and 'villager' in p]

def c_moon_curve():
    return [p for p, t in gd_text.items() if 'moon_curve' in t]

def c_estrellas_json():
    return [p for p, t in json_text.items() if '"estrellas"' in t or 'alpha_inicio' in t]

def c_lluvia_estrellas_vfx():
    return [p for p, t in json_text.items()
            if 'vfx' in p and re.search(r'estrella', t, re.I)]

def c_luna_mesh():
    """Hay mesh de luna en escenas?"""
    return [p for p, t in tscn_text.items()
            if re.search(r'luna', t, re.I) and 'MeshInstance' in t]

def c_flora_brillante():
    return [p for p, t in gd_text.items()
            if re.search(r'flora.{0,12}brill|brillante.{0,12}flora|flor_luminica|luminica', t, re.I)]

def c_duracion_gradiente():
    return [p for p, t in gd_text.items() if 'duracion_gradiente' in t]

def c_fase_cambio():
    return [p for p, t in gd_text.items() if 'fase_cambio' in t]

def c_faroles_puzzle():
    return [p for p, t in gd_text.items() if re.search(r'farol', t, re.I)]

def c_minimapa():
    return [p for p, t in gd_text.items() if re.search(r'minimapa', t, re.I)]

def c_linterna():
    return [p for p, t in gd_text.items() if re.search(r'linterna', t, re.I)]

def c_murales():
    return [p for p, t in gd_text.items() if re.search(r'mural', t, re.I)]

def c_estrellas_alpha_param():
    return [p for p, t in json_text.items()
            if 'alpha_inicio' in t and 'alpha_fin' in t]

# --- ejecutar y reportar
res = []
res.append(('consumidores de clave "estrellas" fuera de tests', c_estrellas_consumo()))
res.append(('nodos FogVolume en escenas', c_fogvolume()))
res.append(('carga de fog_curve.tres fuera de gen/validate', c_fog_curve_consumo()))
res.append(('nubes/velo/drift en scripts', c_nubes()))
res.append(('"estrella" en scripts fuera de tests', c_canvas_estrellas()))
res.append(('prefab farol con OmniLight en escenas', c_farol_prefab()))
res.append(('func es_de_dia', c_es_de_dia()))
res.append(('hora_cambio en villager (M19)', c_hora_cambio_m19()))
res.append(('moon_curve en scripts', c_moon_curve()))
res.append(('parametros alpha_inicio/fin en JSON', c_estrellas_alpha_param()))
res.append(('lluvia de estrellas en catalogo vfx', c_lluvia_estrellas_vfx()))
res.append(('mesh de luna en escenas', c_luna_mesh()))
res.append(('flora brillante / flor luminica', c_flora_brillante()))
res.append(('duracion_gradiente en scripts', c_duracion_gradiente()))
res.append(('fase_cambio en scripts', c_fase_cambio()))
res.append(('farol en scripts', c_faroles_puzzle()))
res.append(('minimapa en scripts', c_minimapa()))
res.append(('linterna en scripts', c_linterna()))
res.append(('murales en scripts', c_murales()))

out = io.open('m31_verif.txt', 'w', encoding='utf-8', newline='\n')
out.write('total .gd indexados: %d | .tscn: %d | .json: %d\n\n' % (len(gd_text), len(tscn_text), len(json_text)))
for desc, lista in res:
    out.write('%-52s %3d hits' % (desc, len(lista)))
    if lista:
        out.write('  -> ' + ', '.join(p.replace(BASE, '')[:34] for p in lista[:4]))
    out.write('\n')
out.close()
print('ok')
