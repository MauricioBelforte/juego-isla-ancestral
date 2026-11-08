#!/usr/bin/env python3
"""Re-export de control: el ALTA de la carreta, con los parametros reales.

Si el GLB publicado es byte-identico, el .blend actual ES la fuente y la
diferencia de 88 tris es exclusivamente mesh.validate() del exportador.
"""
import hashlib
import os

import bpy

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
SRC = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp',
                   '157-Medios-De-Transporte', 'carreta_ancestral_lowpoly.blend')
DST = os.path.join(REPO, 'Temp', 'hy4_carreta_alta_reexport_20261107.glb')
PUB = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d', 'alta',
                   '157-Medios-De-Transporte_carreta_ancestral.glb')

bpy.ops.wm.open_mainfile(filepath=SRC)
for o in list(bpy.context.scene.objects):
    if not o.name.startswith('SM_'):
        bpy.data.objects.remove(o, do_unlink=True)
bpy.context.view_layer.update()
n = len([o for o in bpy.context.scene.objects if o.name.startswith('SM_')])
bpy.ops.export_scene.gltf(
    filepath=DST, export_format='GLB', export_materials='EXPORT',
    export_apply=True, export_yup=True, export_normals=True,
    export_animations=False, export_cameras=False, export_lights=False,
    export_extras=False,
)
a = open(DST, 'rb').read()
b = open(PUB, 'rb').read()
print('HY4_REEXPORT objets_SM=%d bytes=%d/%d sha=%s/%s IDENTICOS=%s' %
      (n, len(a), len(b), hashlib.sha256(a).hexdigest()[:12],
       hashlib.sha256(b).hexdigest()[:12], a == b))
