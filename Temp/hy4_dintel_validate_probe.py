#!/usr/bin/env python3
"""Sonda B12/B13 aplicada a B16/L29: explica 132 (.blend) vs 130 (GLB) en BAJA.

Corre DENTRO de Blender 4.2 headless. NO guarda ningun .blend: valida una
COPIA en memoria de cada malla SM_ y compara calc_loop_triangles() antes y
despues de mesh.validate(). Solo lectura del disco.
"""
import bpy
import os
import sys

RUTA = os.path.abspath(sys.argv[sys.argv.index('--') + 1])


def main():
    bpy.ops.wm.open_mainfile(filepath=RUTA)
    bpy.context.view_layer.update()
    obs = [o for o in bpy.context.scene.objects
           if o.type == 'MESH' and o.name.startswith('SM_')]
    antes = despues = 0
    print('BLEND %s' % os.path.basename(RUTA))
    for o in sorted(obs, key=lambda x: x.name):
        m = o.data
        m.calc_loop_triangles()
        a = len(m.loop_triangles)
        copia = m.copy()
        copia.validate(verbose=False, clean_customdata=False)
        copia.calc_loop_triangles()
        d = len(copia.loop_triangles)
        antes += a
        despues += d
        print('  %-42s antes=%-4d validado=%-4d delta=%-4d mods=%d'
              % (o.name, a, d, d - a, len(o.modifiers)))
        bpy.data.meshes.remove(copia)
    print('TOTAL antes=%d validado=%d delta=%d' % (antes, despues, despues - antes))
    print('GLB_PUBLICADO=130 (medido con verificar_dintel_caido.py)')


if __name__ == '__main__':
    main()
