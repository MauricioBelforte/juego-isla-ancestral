#!/usr/bin/env python3
"""
abrir_blend.py — Abre un .blend en la escena activa de Blender (vía socket MCP).

Necesario porque `capturar_angulos.py` y `stats_asset.py` operan sobre la
escena ACTUAL: para medir o capturar una variante hay que abrirla primero.

Uso:
    python abrir_blend.py <modulo> <nombre_blend>

Ejemplo:
    python abrir_blend.py 25-Ruinas-Templos cofre_ancestral_lowpoly_media
    python abrir_blend.py 25-Ruinas-Templos cofre_ancestral_lowpoly_media.blend
"""
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

RAIZ = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    modulo = sys.argv[1]
    nombre = sys.argv[2]
    if not nombre.endswith('.blend'):
        nombre += '.blend'

    ruta = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', modulo, nombre)
    if not os.path.exists(ruta):
        print('No existe: %s' % ruta)
        sys.exit(1)

    ruta_fw = ruta.replace('\\', '/')
    code = (
        'import bpy\n'
        'bpy.ops.wm.open_mainfile(filepath="%s")\n'
        'import os as _os\n'
        'print("abierto:", _os.path.basename(bpy.data.filepath))\n'
        'print("objetos SM_:", len([o for o in bpy.context.scene.objects'
        ' if o.name.startswith("SM_")]))\n'
        % ruta_fw
    )
    r = blender_command('execute_code', {'code': code}, timeout=30)
    if r.get('status') != 'success':
        print('ERROR:', json.dumps(r, ensure_ascii=False)[:600])
        sys.exit(1)
    print(r.get('result', {}).get('result', '').strip())


if __name__ == '__main__':
    main()
