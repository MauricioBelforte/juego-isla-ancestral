#!/usr/bin/env python3
"""
cap_blender.py — Captura el viewport de Blender vía socket BlenderMCP (V5)
y lo guarda con historial en capturas/. También puede re-guardar el .blend
del proyecto en la ruta correcta (el CWD de Blender puede diferir del proyecto).

Uso:
  python cap_blender.py <ruta_salida.png> [--blend <ruta.blend>]

La ruta de salida se resuelve ABSOLUTA respecto al CWD actual (raíz del proyecto),
evitando el bug del CWD de Blender. Nunca sobrescribe: el llamador debe pasar
nombre con timestamp (convención AGENTS.md §24).
"""
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('-')]
    if not args:
        print(__doc__)
        sys.exit(1)

    ruta_cap = os.path.abspath(args[0])
    os.makedirs(os.path.dirname(ruta_cap), exist_ok=True)

    # Opcional: re-guardar el .blend en ruta absoluta correcta
    if '--blend' in sys.argv:
        idx = sys.argv.index('--blend')
        ruta_blend = os.path.abspath(sys.argv[idx + 1])
        os.makedirs(os.path.dirname(ruta_blend), exist_ok=True)
        code = "import bpy; bpy.ops.wm.save_as_mainfile(filepath=r'%s'); print('BLEND GUARDADO:', bpy.data.filepath)" % ruta_blend
        r = blender_command('execute_code', {'code': code})
        print('blend:', json.dumps(r, ensure_ascii=False)[:300])

    r = blender_command('get_viewport_screenshot',
                        {'filepath': ruta_cap, 'max_size': 1200, 'format': 'png'})
    print('captura:', json.dumps(r, ensure_ascii=False)[:500])
    print('archivo:', ruta_cap, '-> existe:', os.path.exists(ruta_cap))


if __name__ == '__main__':
    main()
