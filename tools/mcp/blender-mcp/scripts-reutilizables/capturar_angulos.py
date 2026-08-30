#!/usr/bin/env python3
"""
capturar_angulos.py — Orbita la cámara alrededor del asset y genera una
captura por ángulo. ES LA HERRAMIENTA QUE VERIFICA QUE NADA FLOTE.

Motivo (regla E-13, directiva del usuario 2026-08-28):
    una sola captura frontal puede ocultar por completo que un objeto está
    flotando. El hueco de aire suele quedar DETRÁS o en el lado opuesto a la
    cámara por defecto. Hay que mirar el asset desde varios azimuths.

Uso:
    python capturar_angulos.py <prefijo_objetos> <ruta_base_salida.png> [N] [altura] [dist_mult] [--blend RUTA]

Argumentos:
    prefijo_objetos   Prefijo de los SM_* a encuadrar (ej. SM_Coco_). Si se
                      pasa '-', se usa el centro de la escena (0,0).
    ruta_base_salida  Ruta del PNG. Se le inserta el ángulo antes de la
                      extensión: base.png -> base_az000.png, base_az090.png...
    N                 Cantidad de ángulos (default 4). Recomendado 4, 6 u 8.
    altura            Altura de la cámara (default: se calcula del bbox).
    dist_mult         Multiplicador de distancia (default 1.6).
    --blend RUTA      MUY RECOMENDADO. Abre ese .blend antes de capturar.

Ejemplo:
    python capturar_angulos.py SM_Coco_ salida/nido.png 6
    python capturar_angulos.py SM_Tronco_Caido salida/tronco.png 4 1.2 1.8
    python capturar_angulos.py SM_ salida/pico.png 6 --blend ../13-Herramientas/pico_piedra_lowpoly_media.blend

Después de ejecutar: leer TODAS las capturas generadas y confirmar que en
ninguna se ve luz/aire entre el objeto y la base.

ERROR E-26 (corregido aquí, 2026-08-29):
    Este script NO abría ningún archivo: renderizaba lo que Blender tuviera
    cargado en ese momento. Si venías de inspeccionar otro .blend, las
    capturas salían del asset EQUIVOCADO y pasaban la revisión E-13 por
    falso positivo. Caso real: se auditó concha_mar mientras Blender tenía
    cargado otro archivo, y el veredicto fue "correcto" sobre la escena
    incorrecta.
    Por eso ahora existe --blend, y además el script SIEMPRE imprime el
    archivo abierto y cuántos objetos matchean el prefijo. Si esa línea no
    corresponde al asset que querés auditar, las capturas no sirven.
"""
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)

    # --blend se extrae aparte para no correrse de posición con los posicionales.
    blend = None
    argv = []
    i = 1
    while i < len(sys.argv):
        a = sys.argv[i]
        if a == '--blend' and i + 1 < len(sys.argv):
            blend = os.path.abspath(sys.argv[i + 1])
            i += 2
            continue
        argv.append(a)
        i += 1

    prefijo = argv[0]
    ruta_base = os.path.abspath(argv[1])
    n = int(argv[2]) if len(argv) > 2 else 4
    altura = float(argv[3]) if len(argv) > 3 else -999.0  # -999 = auto
    dist_mult = float(argv[4]) if len(argv) > 4 else 1.6

    if blend is not None and not os.path.exists(blend):
        print('ERROR: --blend apunta a un archivo inexistente:\n  ' + blend)
        sys.exit(1)

    os.makedirs(os.path.dirname(ruta_base), exist_ok=True)
    raiz, ext = os.path.splitext(ruta_base)
    if not ext:
        ext = '.png'

    # 1) Colocar una cámara orbital y renderizar cada ángulo
    code = """
import bpy, math, os
from mathutils import Vector

PREFIJO = @@PREF@@
N = @@N@@
ALTURA = @@ALT@@
DIST_MULT = @@DIST@@
RUTAS = @@RUTAS@@
BLEND = @@BLEND@@

# --- E-26: abrir el archivo indicado ANTES de medir nada ---
# Sin esto se renderiza la escena que Blender tenga cargada, que puede ser
# otro asset: la auditoría E-13 daría un falso positivo.
if BLEND is not None:
    bpy.ops.wm.open_mainfile(filepath=BLEND)
bpy.context.view_layer.update()
print('ARCHIVO_ABIERTO: ' + bpy.data.filepath)

# --- Centro y radio del objeto a encuadrar ---
obs = [o for o in bpy.data.objects
       if o.type == 'MESH' and o.name.startswith(PREFIJO)]
# Trazas de auditoría: si el prefijo no matchea nada, las capturas son
# inútiles y hay que enterarse antes de mirarlas, no después.
print('OBJETOS_ENCUADRADOS: %d (prefijo %r)' % (len(obs), PREFIJO))
for _o in obs[:12]:
    print('  · ' + _o.name)
if not obs:
    centro = Vector((0.0, 0.0, 0.0)); radio = 1.0
else:
    minimos = []; maximos = []
    for o in obs:
        bb = [o.matrix_world @ Vector(c) for c in o.bound_box]
        minimos.append(Vector((min(v.x for v in bb), min(v.y for v in bb), min(v.z for v in bb))))
        maximos.append(Vector((max(v.x for v in bb), max(v.y for v in bb), max(v.z for v in bb))))
    cmin = Vector((min(m.x for m in minimos), min(m.y for m in minimos), min(m.z for m in minimos)))
    cmax = Vector((max(m.x for m in maximos), max(m.y for m in maximos), max(m.z for m in maximos)))
    centro = (cmin + cmax) / 2.0
    radio = max((cmax - cmin).x, (cmax - cmin).y, (cmax - cmin).z) / 2.0
    radio = max(radio, 0.35)

# La cámara apunta al CENTRO EN ALTURA del objeto, no al suelo: si apuntamos al
# suelo se ve demasiado disco de arena y demasiado poco asset.
if ALTURA < -900:
    ALTURA = centro.z

dist = radio * 3.0 * DIST_MULT

# --- Cámara orbital ---
cam_data = bpy.data.cameras.get('CAM_Orbital') or bpy.data.cameras.new('CAM_Orbital')
cam_data.lens = 45
cam = bpy.data.objects.get('CAM_Orbital')
if cam is None:
    cam = bpy.data.objects.new('CAM_Orbital', cam_data)
    bpy.context.scene.collection.objects.link(cam)
bpy.context.scene.camera = cam

hechas = []
for i in range(N):
    az = 2 * math.pi * i / N
    # azimuth + una altura baja para ver el contacto con el suelo
    cam.location = (centro.x + dist * math.cos(az),
                    centro.y + dist * math.sin(az),
                    ALTURA + radio * 0.55)
    dir_mira = centro - cam.location
    cam.rotation_euler = dir_mira.to_track_quat('-Z', 'Y').to_euler()
    bpy.context.view_layer.update()

    escena = bpy.context.scene
    escena.render.resolution_x = 1200
    escena.render.resolution_y = 800
    escena.render.filepath = RUTAS[i]
    escena.render.image_settings.file_format = 'PNG'
    # Activar SSR + raytracing para que los materiales con metallic/coat
    # se vean pulidos (E-20). Se hace en el script de captura y no se
    # guarda en el .blend, así no se contamina el asset.
    try:
        escena.eevee.use_ssr = True
        escena.eevee.use_ssr_refraction = True
        escena.eevee.use_raytracing = True
    except Exception:
        pass
    bpy.ops.render.render(write_still=True)
    hechas.append((RUTAS[i], os.path.exists(RUTAS[i])))

for r, ok in hechas:
    print(('OK  ' if ok else 'FALLO ') + r)
"""

    rutas = ['%s_az%03d%s' % (raiz, int(360 * i / n), ext) for i in range(n)]
    code = (code.replace('@@PREF@@', repr(prefijo))
                .replace('@@N@@', repr(n))
                .replace('@@ALT@@', repr(altura))
                .replace('@@DIST@@', repr(dist_mult))
                .replace('@@RUTAS@@', repr(rutas))
                .replace('@@BLEND@@', repr(blend)))

    r = blender_command('execute_code', {'code': code}, timeout=180)
    if r.get('status') != 'success':
        print('ERROR:', json.dumps(r, ensure_ascii=False)[:600])
        sys.exit(1)

    salida = r.get('result', {}).get('result', '')
    print(salida)
    print('---')
    print('Revisá TODAS estas capturas: en ninguna debe verse luz/aire')
    print('entre el objeto y la base. Si la hay, corregí y volvé a correr.')


if __name__ == '__main__':
    main()
