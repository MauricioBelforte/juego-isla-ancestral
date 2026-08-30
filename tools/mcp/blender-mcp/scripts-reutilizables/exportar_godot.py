#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
exportar_godot.py - Exporta los .blend del proyecto a .glb para Godot 4.x.

POR QUE EXISTE: el proyecto tiene ~120 .blend repartidos en 8 modulos. Godot
4.x importa .glb de forma nativa y respeta los materiales del Principled BSDF
de Blender. Sin este script los assets quedan atrapados en Blender y el juego
no puede consumirlos.

COMO SE EJECUTA (IMPORTANTE - E-45):
    "<ruta a blender.exe>" -b --factory-startup --python exportar_godot.py

  Se corre en Blender HEADLESS y NO por el socket del MCP. Motivo: cuando el
  codigo se ejecuta por el socket, `bpy.context` es un contexto restringido que
  NO tiene el atributo `active_object`, y el exportador glTF de Blender 4.2 lo
  lee en la primera linea de `gltf2_blender_export.save()`:

      AttributeError: 'Context' object has no attribute 'active_object'

  Es la misma familia que E-22 (`bpy.ops.object.modifier_apply` falla por
  contexto). Los 51 primeros intentos por socket fallaron todos con ese error.
  En headless `bpy.context` es el contexto real y el exportador funciona.
  Con `--factory-startup` no se carga el addon del MCP (que ademas fallaria al
  intentar abrir el puerto 9876 ya en uso), asi que el script habilita a mano
  `io_scene_gltf2`.

CONVENCION DE DESTINO (decision D8):
    game/isla-ancestral/assets/3d/<alta|media|baja>/<modulo>_<base>.glb

E-43 - COLISION DE NOMBRES: un heroe tiene DOS fuentes de ALTA
(`totem_isla_alta.blend` con bevel y `totem_isla_lowpoly.blend` pre-bevel) y
DOS de MEDIA (`_alta_media` y `_lowpoly_media`). Ambas caian en el mismo
destino y una pisaba a la otra segun el orden del listado. Se resuelve con una
prioridad explicita por variante: siempre gana la rama del ALTA-passed.

E-44 - PURGA PREVIA: los .blend incluyen ayudas de escena que NO son parte del
asset (Base_Arena = el disco de arena, SOL, CAM_*). Exportarlos tal cual metia
un disco de arena y una camara dentro de cada .glb. Se borra todo lo que no
empiece con SM_ antes de exportar.

El script es IDEMPOTENTE: si el .glb ya existe y es mas nuevo que el .blend,
lo saltea.
"""

import bpy          # noqa: E402
import os           # noqa: E402
import json         # noqa: E402

# --- OPCIONES (se pasan por variables de entorno para no editar el archivo) --
# Blender no reenvia argv comodamente con -b --python, asi que se usa env:
#   EXPORT_DRY=1                      solo imprime el plan
#   EXPORT_ONLY=alta|media|baja       una sola variante
#   EXPORT_MODULOS=70-Interacciones;45-Arte3D    recorte por modulo
DRY_RUN = os.environ.get('EXPORT_DRY', '0') == '1'
ONLY = os.environ.get('EXPORT_ONLY') or None
_fm = os.environ.get('EXPORT_MODULOS')
FILTRO_MODULOS = _fm.split(';') if _fm else None
# ---------------------------------------------------------------------------

RAIZ = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
SRC_ROOT = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp')
DEST_ROOT = os.path.join(RAIZ, 'game', 'isla-ancestral', 'assets', '3d')

MODULOS = ('13-Herramientas', '15-Recursos', '16-Crafting', '25-Ruinas-Templos',
           '40-Infraestructura', '45-Arte3D', '50-Vegetacion', '70-Interacciones')

# Por variante, que sufijo gana (primero = mayor prioridad). Ver E-43.
PRIORIDAD = {
    'alta':  ('_alta', '_lowpoly'),
    'media': ('_alta_media', '_lowpoly_media'),
    'baja':  ('_alta_baja', '_lowpoly_baja'),
}


def planificar():
    """{modulo: {base: {variante: (src, dest, sufijo)}}} con prioridades
    resueltas, de modo que un destino nunca se pise."""
    plan = {}
    for modulo in MODULOS:
        if FILTRO_MODULOS and modulo not in FILTRO_MODULOS:
            continue
        dir_mod = os.path.join(SRC_ROOT, modulo)
        if not os.path.isdir(dir_mod):
            continue
        plan[modulo] = {}
        for entry in sorted(os.listdir(dir_mod)):
            if not entry.endswith('.blend') or entry.endswith('.blend@'):
                continue
            stem = entry[:-len('.blend')]
            for variante, sufijos in PRIORIDAD.items():
                for suf in sufijos:
                    if not stem.endswith(suf):
                        continue
                    base = stem[:-len(suf)]
                    ruta = os.path.join(dir_mod, entry)
                    dest = os.path.join(DEST_ROOT, variante,
                                        '%s_%s.glb' % (modulo, base))
                    slot = plan[modulo].setdefault(base, {})
                    if variante in slot:
                        # gana el sufijo de mayor prioridad (indice mas bajo)
                        if sufijos.index(suf) >= sufijos.index(slot[variante][2]):
                            continue
                    slot[variante] = (ruta, dest, suf)
                    break
    return plan


def main():
    # --factory-startup no carga addons: hay que habilitar el exportador.
    try:
        bpy.ops.preferences.addon_enable(module='io_scene_gltf2')
    except Exception as e:
        print('AVISO addon_enable: %s' % e)

    for variante in ('alta', 'media', 'baja'):
        os.makedirs(os.path.join(DEST_ROOT, variante), exist_ok=True)

    plan = planificar()
    exportados, saltados, errores = [], [], []

    for modulo in sorted(plan):
        for base in sorted(plan[modulo]):
            for variante in ('alta', 'media', 'baja'):
                if ONLY and ONLY != variante:
                    continue
                if variante not in plan[modulo][base]:
                    continue
                ruta_src, dest, suf = plan[modulo][base][variante]

                if os.path.exists(dest) and \
                        os.path.getmtime(dest) >= os.path.getmtime(ruta_src):
                    saltados.append([modulo, base, variante, 'up-to-date'])
                    continue
                if DRY_RUN:
                    exportados.append([modulo, base, variante, 'planned'])
                    continue
                try:
                    bpy.ops.wm.open_mainfile(filepath=ruta_src)
                    # E-44: fuera todo lo que no sea parte del asset.
                    for o in list(bpy.context.scene.objects):
                        if not o.name.startswith('SM_'):
                            bpy.data.objects.remove(o, do_unlink=True)
                    bpy.context.view_layer.update()
                    n_sm = len([o for o in bpy.context.scene.objects
                                if o.name.startswith('SM_')])
                    if n_sm == 0:
                        raise RuntimeError('sin objetos SM_ tras la purga')
                    bpy.ops.export_scene.gltf(
                        filepath=dest,
                        export_format='GLB',
                        export_materials='EXPORT',
                        export_apply=True,
                        export_yup=True,
                        export_normals=True,
                        export_animations=False,
                        export_cameras=False,
                        export_lights=False,
                        export_extras=False,
                    )
                    kb = os.path.getsize(dest) // 1024
                    exportados.append([modulo, base, variante,
                                       'ok %dKB %dobjs' % (kb, n_sm)])
                except Exception as e:
                    errores.append([modulo, base, variante, str(e)[:200]])

    print('RESUMEN_EXPORT __%s__' % json.dumps({
        'exportados': len(exportados),
        'saltados': len(saltados),
        'errores': len(errores),
        'detalle': {'exportados': exportados, 'errores': errores},
    }, ensure_ascii=False))


main()
