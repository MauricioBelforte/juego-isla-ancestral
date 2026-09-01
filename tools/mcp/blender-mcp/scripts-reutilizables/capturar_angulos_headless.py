#!/usr/bin/env python3
"""
capturar_angulos_headless.py — Mismo encuadre orbital que capturar_angulos.py,
pero corriendo DENTRO de Blender en modo background (sin socket MCP).

Motivo (E-55, 2026-08-31):
    `capturar_angulos.py` usa `bpy_cliente.blender_command`, así que exige el
    socket MCP en 127.0.0.1:9876 y por tanto Blender ABIERTO con la GUI. Si el
    usuario cierra Blender (o el socket muere), la verificación E-13 quedaba
    bloqueada y no se podía aprobar ningún asset nuevo.
    La autoría y el render NO necesitan socket: `blender -b --factory-startup
    --python` alcanza (mismo patrón que E-45 para exportar y E-54 para aplanar).

Uso (desde la raíz del repo):
    blender -b --factory-startup --python <este_script> -- \
        <ruta.blend> <prefijo_SM_> <ruta_base.png> [N] [altura] [dist_mult]

Ejemplo:
    blender -b --factory-startup --python capturar_angulos_headless.py -- \
        tools/mcp/blender-mcp/18-Casas/pared_madera_lowpoly.blend \
        SM_Pared_ salida/pared.png 6

Genera: <ruta_base>_az000.png, _az060.png, ... (N ángulos, azimuth repartido).
Después: leer TODAS y confirmar que en ninguna se ve aire entre objeto y base.

El encuadre es IDENTICO al del script por socket (centro del bbox, radio =
max semieje, dist = radio*3.0*dist_mult, camara a ALTURA + radio*0.55, lente 45,
1200x800, EEVEE con SSR) para que las capturas sean comparables entre sí.
"""
import sys
import os
import math
import bpy
from mathutils import Vector


def main():
    argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
    if len(argv) < 3:
        print(__doc__)
        sys.exit(1)

    blend = os.path.abspath(argv[0])
    prefijo = argv[1]
    ruta_base = os.path.abspath(argv[2])
    n = int(argv[3]) if len(argv) > 3 else 6
    altura = float(argv[4]) if len(argv) > 4 else -999.0
    dist_mult = float(argv[5]) if len(argv) > 5 else 1.6

    if not os.path.exists(blend):
        print('ERROR: el .blend no existe:\n  ' + blend)
        sys.exit(1)

    os.makedirs(os.path.dirname(ruta_base), exist_ok=True)
    raiz, ext = os.path.splitext(ruta_base)
    if not ext:
        ext = '.png'
    rutas = ['%s_az%03d%s' % (raiz, int(360 * i / n), ext) for i in range(n)]

    # --- E-26: abrir el archivo ANTES de medir nada ---
    bpy.ops.wm.open_mainfile(filepath=blend)
    bpy.context.view_layer.update()
    print('ARCHIVO_ABIERTO: ' + bpy.data.filepath)

    obs = [o for o in bpy.data.objects
           if o.type == 'MESH' and o.name.startswith(prefijo)]
    print('OBJETOS_ENCUADRADOS: %d (prefijo %r)' % (len(obs), prefijo))
    for _o in obs[:12]:
        print('  · ' + _o.name)

    if not obs:
        centro = Vector((0.0, 0.0, 0.0))
        radio = 1.0
    else:
        mins = []
        maxs = []
        for o in obs:
            bb = [o.matrix_world @ Vector(c) for c in o.bound_box]
            mins.append(Vector((min(v.x for v in bb), min(v.y for v in bb), min(v.z for v in bb))))
            maxs.append(Vector((max(v.x for v in bb), max(v.y for v in bb), max(v.z for v in bb))))
        cmin = Vector((min(m.x for m in mins), min(m.y for m in mins), min(m.z for m in mins)))
        cmax = Vector((max(m.x for m in maxs), max(m.y for m in maxs), max(m.z for m in maxs)))
        centro = (cmin + cmax) / 2.0
        radio = max((cmax - cmin).x, (cmax - cmin).y, (cmax - cmin).z) / 2.0
        radio = max(radio, 0.35)

    if altura < -900:
        altura = centro.z
    dist = radio * 3.0 * dist_mult

    cam_data = bpy.data.cameras.get('CAM_Orbital') or bpy.data.cameras.new('CAM_Orbital')
    cam_data.lens = 45
    cam = bpy.data.objects.get('CAM_Orbital')
    if cam is None:
        cam = bpy.data.objects.new('CAM_Orbital', cam_data)
        bpy.context.scene.collection.objects.link(cam)
    bpy.context.scene.camera = cam

    escena = bpy.context.scene
    escena.render.resolution_x = 1200
    escena.render.resolution_y = 800
    escena.render.image_settings.file_format = 'PNG'
    # E-20: SSR/raytracing en el script de captura, nunca guardado en el .blend.
    try:
        escena.eevee.use_ssr = True
        escena.eevee.use_ssr_refraction = True
        escena.eevee.use_raytracing = True
    except Exception:
        pass

    for i in range(n):
        az = 2 * math.pi * i / n
        cam.location = (centro.x + dist * math.cos(az),
                        centro.y + dist * math.sin(az),
                        altura + radio * 0.55)
        cam.rotation_euler = (centro - cam.location).to_track_quat('-Z', 'Y').to_euler()
        bpy.context.view_layer.update()
        escena.render.filepath = rutas[i]
        bpy.ops.render.render(write_still=True)
        print(('OK  ' if os.path.exists(rutas[i]) else 'FALLO ') + rutas[i])

    print('---')
    print('Revisa TODAS estas capturas: en ninguna debe verse luz/aire')
    print('entre el objeto y la base (E-13).')


if __name__ == '__main__':
    main()
