#!/usr/bin/env python3
"""Sonda: en los 8 .blend con deriva, mide tris antes/despues de mesh.validate().

Trabaja sobre COPIAS en memoria; nunca guarda el .blend. Marcador positivo
obligatorio al final para no confiar en el RC=0 silencioso de Blender.
"""
import json
import os

import bpy

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
MCP = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp')

CASOS = [
    ('67-Vehiculos/barquita_aurora_lowpoly_baja.blend', 3),
    ('67-Vehiculos/globo_del_viento_lowpoly_baja.blend', 6),
    ('67-Vehiculos/perla_ancestral_lowpoly_baja.blend', 2),
    ('67-Vehiculos/gran_vapor_lowpoly_baja.blend', 20),
    ('157-Medios-De-Transporte/carreta_ancestral_lowpoly.blend', 88),
    ('157-Medios-De-Transporte/carreta_ancestral_lowpoly_baja.blend', 12),
    ('25-Ruinas-Templos/columna_entera_lowpoly_baja.blend', 2),
    ('18-Casas/casa_mansion_lowpoly_baja.blend', 146),
]

salida = []
for rel, esperado in CASOS:
    path = os.path.join(MCP, rel.replace('/', os.sep))
    bpy.ops.wm.open_mainfile(filepath=path)
    bpy.context.view_layer.update()
    obs = [o for o in bpy.context.scene.objects
           if o.type == 'MESH' and o.name.startswith('SM_')]
    antes = despues = 0
    mods = 0
    filas = []
    for o in obs:
        copia = o.data.copy()
        copia.calc_loop_triangles()
        a = len(copia.loop_triangles)
        cambio = copia.validate(verbose=False, clean_customdata=False)
        copia.calc_loop_triangles()
        d = len(copia.loop_triangles)
        antes += a
        despues += d
        mods += len(o.modifiers)
        if a != d:
            filas.append((o.name, a, d, a - d, bool(cambio)))
        bpy.data.meshes.remove(copia)
    delta = antes - despues
    salida.append({'rel': rel, 'antes': antes, 'despues': despues,
                   'delta': delta, 'esperado': esperado,
                   'cierra': delta == esperado, 'modificadores': mods,
                   'piezas': filas})
    print('VALIDATE %-58s %4d -> %4d  delta=%-4d esperado=%-4d %s mods=%d' %
          (rel, antes, despues, delta, esperado,
           'CIERRA' if delta == esperado else 'NO_CIERRA', mods))
    for nombre, a, d, dd, cambio in filas:
        print('    %-46s %4d -> %4d (%+d) validate=%s' %
              (nombre, a, d, -dd, cambio))

dst = os.path.join(REPO, 'Temp', 'hy4_corpus_validate_20261107.json')
json.dump(salida, open(dst, 'w', encoding='utf-8'), indent=1)
print('HY4_CORPUS_VALIDATE_OK=%d' % len(salida))
