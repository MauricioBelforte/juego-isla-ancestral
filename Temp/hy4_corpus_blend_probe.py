#!/usr/bin/env python3
"""Sonda Blender headless de SOLO LECTURA: tris de .blend con el metodo de chk_asset.py.

Abre cada .blend, cuenta len(loop_triangles) sobre objetos SM_ (SIN validar la
malla, exactamente como chk_asset.py) y escribe un JSON. Nunca guarda un .blend.
Marcador positivo obligatorio al final: HY4_CORPUS_BLEND_OK=<n>.
"""
import json
import os
import sys

import bpy

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
MCP = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp')

FUENTES = {
    '67-Vehiculos_barquita_aurora': '67-Vehiculos/barquita_aurora_lowpoly%s.blend',
    '67-Vehiculos_globo_del_viento': '67-Vehiculos/globo_del_viento_lowpoly%s.blend',
    '67-Vehiculos_perla_ancestral': '67-Vehiculos/perla_ancestral_lowpoly%s.blend',
    '67-Vehiculos_gran_vapor': '67-Vehiculos/gran_vapor_lowpoly%s.blend',
    '157-Medios-De-Transporte_carreta_ancestral':
        '157-Medios-De-Transporte/carreta_ancestral_lowpoly%s.blend',
    '25-Ruinas-Templos_columna_rota_alta':
        '25-Ruinas-Templos/columna_rota_alta_lowpoly%s.blend',
    '25-Ruinas-Templos_columna_rota_baja':
        '25-Ruinas-Templos/columna_rota_baja_lowpoly%s.blend',
    '25-Ruinas-Templos_columna_entera':
        '25-Ruinas-Templos/columna_entera_lowpoly%s.blend',
    '18-Casas_casa_mansion': '18-Casas/casa_mansion_lowpoly%s.blend',
    '18-Casas_casa_vecino':
        '18-BIS-Casas-Grandes/CASA_05_CASA_VECINO/%s/SM_CASA_05_CASA_VECINO_%s.blend',
}
SUFIJO = {'alta': '', 'media': '_media', 'baja': '_baja'}

salida = []
for base, patron in FUENTES.items():
    for lod, suf in SUFIJO.items():
        if base == '18-Casas_casa_vecino':
            rel = patron % (lod.upper(), lod.upper())
        else:
            rel = patron % suf
        path = os.path.join(MCP, rel.replace('/', os.sep))
        if not os.path.isfile(path):
            print('FALTA_BLEND %s %s %s' % (base, lod, rel))
            continue
        bpy.ops.wm.open_mainfile(filepath=path)
        bpy.context.view_layer.update()
        obs = [o for o in bpy.context.scene.objects
               if o.type == 'MESH' and o.name.startswith('SM_')]
        tris = 0
        for o in obs:
            o.data.calc_loop_triangles()
            tris += len(o.data.loop_triangles)
        mats = set()
        for o in obs:
            for f in o.data.polygons:
                if f.material_index < len(o.data.materials):
                    mats.add(o.data.materials[f.material_index].name)
        salida.append({'base': base, 'lod': lod, 'tris_blend': tris,
                       'objetos': len(obs), 'mats': len(mats), 'rel': rel})
        print('BLEND %-42s %-5s tris=%-5d obj=%-2d mats=%d' %
              (base, lod, tris, len(obs), len(mats)))

dst = os.path.join(REPO, 'Temp', 'hy4_corpus_blend_20261107.json')
json.dump(salida, open(dst, 'w', encoding='utf-8'), indent=1)
print('HY4_CORPUS_BLEND_OK=%d' % len(salida))
