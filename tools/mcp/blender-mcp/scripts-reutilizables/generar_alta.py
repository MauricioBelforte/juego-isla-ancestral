#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generar_alta.py — M166 · Genera la variante ALTA de un asset a partir de su
.blend fuente (el de autoría), agregando detalle geométrico SIN duplicar arte.

Por qué existe: D9 dice que los 15 assets "héroe" reciben una pasada ALTA
(interacción, mano o hito) y los 23 de relleno quedan en MEDIA. La pasada ALTA
es la única que agrega trabajo artístico; MEDIA y BAJA se derivan de ella con
`generar_variante.py`.

Qué agrega (en este orden, todos por modifier aplicado vía depsgraph, E-22):
  1. BEVEL — chaflán en los bordes duros. Es el mayor salto visual en lowpoly:
     los bordes vivos pasan a captar luz y el objeto deja de parecer una caja.
     Segmentos y ancho proporcionales al tamaño de la pieza.
  2. WELD — junta vértices duplicados que el bevel puede dejar.
  3. (opcional) SUBDIV — solo en piezas declaradas "redondas" (mango, pomo,
     punta, esfera). Un nivel, para suavizar sin perder la faceta.

El ancho del bevel se calcula como fracción de la menor dimensión de la pieza,
para que no se autointersecte en piezas chiquitas (ataduras, remaches).

Uso:
    python generar_alta.py <modulo> <asset_lowpoly> [opciones]

Opciones:
    --segmentos N     segmentos del bevel (default 2)
    --ancho F         fracción de la menor dimensión (default 0.06)
    --subdiv          aplicar Subdivision Surface (1 nivel) a las piezas
                      cuyo nombre contenga Mango|Pomo|Punta|Esfera|Bola|Cuerpo
    --min-tris N      no procesar piezas con menos de N tris (default 0, todas)
    --dry             muestra el plan y los números SIN guardar
    --forzar          regenerar aunque ya exista el _alta.blend

Ejemplo:
    python generar_alta.py 13-Herramientas pico_hierro_lowpoly
    python generar_alta.py 13-Herramientas pico_hierro_lowpoly --subdiv --dry

Presupuesto ALTA (M166): 16 objetos, 6000 tris, 12 materiales.
El script informa al final si el resultado cabe o se pasa.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command  # noqa: E402

DIR_BLEND = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))

# Piezas que se benefician de suavizado (nombres en minúsculas).
# NOTA: 'punta' se excluye deliberadamente — en picos/herramientas las
# puntas son HOJAS filosas, no deben redondearse con subdivisión.
PATRON_REDONDO = ('mango', 'pomo', 'esfera', 'bola', 'cuerpo',
                  'tronco', 'tallo', 'cuello')

PLANTILLA = r"""
import bpy

SEGMENTOS = @@SEG@@
ANCHO_FRAC = @@ANCHO@@
USAR_SUBDIV = @@SUBDIV@@
MIN_TRIS = @@MINTRIS@@
PATRON_REDONDO = @@PATRON@@

bpy.ops.object.select_all(action='DESELECT')
obs = [o for o in bpy.data.objects
       if o.type == 'MESH' and o.name.startswith('SM_')]
if not obs:
    print('SIN_SM')
else:
    def tris_de(lista):
        # E-33: contar TRIANGULOS REALES, no caras. Un quad vale 2 tris y un
        # n-gon vale n-2. Medir caras subestimaba ~2x y el veredicto contra el
        # presupuesto de 6000 daba falso OK. Caso real 2026-08-29: totem_isla
        # reportaba "OK" con 10507 caras cuando en realidad tenia 21014 tris.
        t = 0
        for o in lista:
            o.data.calc_loop_triangles()
            t += len(o.data.loop_triangles)
        return t

    tris_antes = tris_de(obs)

    for o in obs:
        # piezas diminutas: las salteo si el usuario pidio un minimo
        if len(o.data.polygons) < MIN_TRIS:
            continue

        d = o.dimensions
        menor = min(d.x, d.y, d.z)
        if menor <= 0.0001:
            continue
        # ancho del bevel: fraccion de la menor dimension, con piso y techo
        ancho = max(0.002, min(0.02, menor * ANCHO_FRAC))

        # limpiar modificadores previos para que sea idempotente
        for m in list(o.modifiers):
            o.modifiers.remove(m)

        md = o.modifiers.new('BevelM166', 'BEVEL')
        md.width = ancho
        md.segments = SEGMENTOS
        md.limit_method = 'ANGLE'
        md.angle_limit = 1.22173   # 70 grados: solo bordes marcados
        md.use_clamp_overlap = True

        nombre_min = o.name.lower()
        es_redonda = any(p in nombre_min for p in PATRON_REDONDO)
        if USAR_SUBDIV and es_redonda:
            # CATMULL_CLARK (no SIMPLE) — SIMPLE solo densifica sin
            # suavizar. CATMULL convierte una caja en un cilindro
            # suave, que es lo que queremos en mangos y pomos.
            sd = o.modifiers.new('SubdivM166', 'SUBSURF')
            sd.levels = 1
            sd.render_levels = 1
            sd.subdivision_type = 'CATMULL_CLARK'

        # weld para limpiar duplicados que el bevel pudo dejar
        wd = o.modifiers.new('WeldM166', 'WELD')
        wd.merge_threshold = 0.0005

    bpy.context.view_layer.update()

    # Aplicar todo por depsgraph (E-22: modifier_apply falla por socket)
    dg = bpy.context.evaluated_depsgraph_get()
    for o in obs:
        if len(o.data.polygons) < MIN_TRIS:
            continue
        nuevo = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
        viejo = o.data
        o.data = nuevo
        for m in list(o.modifiers):
            o.modifiers.remove(m)
        if viejo.users <= 1:
            bpy.data.meshes.remove(viejo)
    bpy.context.view_layer.update()

    tris_despues = tris_de(obs)
    mats = set()
    for o in obs:
        for m in (o.data.materials or []):
            if m:
                mats.add(m.name)

    # veredicto contra presupuesto ALTA
    techo_obj, techo_tris, techo_mat = 16, 6000, 12
    problemas = []
    if len(obs) > techo_obj:
        problemas.append('PASA %d objetos de ALTA' % (len(obs) - techo_obj))
    if tris_despues > techo_tris:
        problemas.append('PASA %d tris de ALTA' % (tris_despues - techo_tris))
    if len(mats) > techo_mat:
        problemas.append('PASA %d materiales de ALTA' % (len(mats) - techo_mat))
    veredicto = ' | '.join(problemas) if problemas else 'OK'

    print('RES|%s|obj=%d|tris %d -> %d (x%.1f)|mats=%d|%s'
          % (bpy.path.basename(bpy.data.filepath), len(obs),
             tris_antes, tris_despues,
             (tris_despues / tris_antes) if tris_antes else 0.0,
             len(mats), veredicto))
"""


def parse_args(argv):
    if len(argv) < 2:
        print(__doc__)
        sys.exit(1)
    modulo, asset = argv[0], argv[1]
    opts = {
        'segmentos': 2,
        'ancho': 0.06,
        'subdiv': False,
        'min_tris': 0,
        'dry': False,
        'forzar': False,
    }
    i = 2
    while i < len(argv):
        a = argv[i]
        if a == '--segmentos':
            opts['segmentos'] = int(argv[i + 1]); i += 2
        elif a == '--ancho':
            opts['ancho'] = float(argv[i + 1]); i += 2
        elif a == '--subdiv':
            opts['subdiv'] = True; i += 1
        elif a == '--min-tris':
            opts['min_tris'] = int(argv[i + 1]); i += 2
        elif a == '--dry':
            opts['dry'] = True; i += 1
        elif a == '--forzar':
            opts['forzar'] = True; i += 1
        else:
            print('Opción desconocida: %s' % a)
            sys.exit(1)
    return modulo, asset, opts


def generar(modulo, asset, o):
    # el asset puede venir con o sin el sufijo _lowpoly, y con o sin .blend
    nombre = asset
    for suf in ('.blend', '_lowpoly'):
        if nombre.endswith(suf):
            nombre = nombre[:-len(suf)]

    fuente = nombre + '_lowpoly.blend'
    destino = nombre + '_alta.blend'
    ruta_fuente = os.path.join(DIR_BLEND, modulo, fuente)
    ruta_destino = os.path.join(DIR_BLEND, modulo, destino)

    if not os.path.exists(ruta_fuente):
        print('ERROR: no existe %s' % ruta_fuente)
        return 1

    # --dry tiene que poder simular sobre un _alta.blend ya existente: si no,
    # el guard lo cortaba antes de medir y no se podia probar un ajuste de
    # parametros sin destruir el archivo aprobado.
    if os.path.exists(ruta_destino) and not o['forzar'] and not o['dry']:
        print('Ya existe %s (usar --forzar para regenerar)' % destino)
        return 0

    rf = ruta_fuente.replace('\\', '/')
    rd = ruta_destino.replace('\\', '/')

    code = ('import bpy\n'
            'bpy.ops.wm.open_mainfile(filepath="%s")\n' % rf)

    cuerpo = (PLANTILLA
              .replace('@@SEG@@', str(o['segmentos']))
              .replace('@@ANCHO@@', str(o['ancho']))
              .replace('@@SUBDIV@@', str(o['subdiv']))
              .replace('@@MINTRIS@@', str(o['min_tris']))
              .replace('@@PATRON@@', repr(PATRON_REDONDO)))
    code += cuerpo

    if o['dry']:
        code += "\nprint('*** MODO DRY: no se guarda nada ***')\n"
    else:
        code += ('\nbpy.ops.wm.save_as_mainfile(filepath="%s")\n'
                 'print("GUARDADO: %s")\n' % (rd, destino))

    resp = blender_command('execute_code', {'code': code}, timeout=180)
    if resp.get('status') != 'success':
        print('ERROR Blender: %s' % resp.get('message'))
        return 1

    resultado = resp.get('result', {}).get('result', '')
    for linea in resultado.splitlines():
        if linea.startswith('RES|') or linea.startswith('GUARDADO') \
                or linea.startswith('***') or linea.startswith('SIN_SM'):
            print('  ' + linea)
    return 0


def main():
    modulo, asset, opts = parse_args(sys.argv[1:])
    print('M166 · generar_alta — %s / %s' % (modulo, asset))
    print('  segmentos=%d ancho=%.3f subdiv=%s min_tris=%d dry=%s'
          % (opts['segmentos'], opts['ancho'], opts['subdiv'],
             opts['min_tris'], opts['dry']))
    return generar(modulo, asset, opts)


if __name__ == '__main__':
    sys.exit(main())
