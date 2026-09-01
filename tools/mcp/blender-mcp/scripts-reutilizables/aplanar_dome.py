#!/usr/bin/env python3
"""
aplanar_dome.py — M166 · fix de **E-50 (apoyo puntual en domo/huso)**.

Problema: una roca con forma de huso apoya en el vertice del extremo
inferior. `z_min == 0.045` pasa el test numerico, pero solo UN vertice
toca la arena y la parte ancha (el ecuador) queda suspendida a medio
metro: visualmente flota.

Solucion: seleccionar el vertice mas bajo mas K anillos de su
vecindario y bajarlos todos a Z_OBJ, conservando su X/Y. El resultado
es una cara poligonal plana en la base.

**E-51**: el vecindario se elige por TOPOLOGIA (BFS sobre aristas), NO
por distancia XY. En un huso el vertice superior comparte X/Y con el
inferior, asi que con distancia XY se seleccionaban vertices del TECHO
y aplanarlos colapsaba el modelo entero.

**E-45**: no usa `bpy.ops.object.mode_set` (por socket no hay
`active_object`). Aplanar vertices no cambia el winding, asi que las
normales sobreviven sin recalcularlas con operadores.

Uso:
    python aplanar_dome.py <modulo> <asset> <patron> <z> <K> [opciones]

    modulo   15-Recursos, 50-Vegetacion, ...
    asset    veta_hierro_lowpoly  (sin sufijo de variante)
    patron   submuestra del nombre de objeto, p.ej. 'SM_Veta_Roca'
    z        altura objetivo de la base (0.045 = Z_APOYO)
    K        anillos BFS a aplanar (2 suele bastar)

Opciones:
    --variantes source,media,baja   (default: las tres)
    --dry                            no guarda, solo muestra el "antes"

Ejemplo real (log 302):
    python aplanar_dome.py 15-Recursos veta_hierro_lowpoly SM_Veta_Roca 0.045 2
    python aplanar_dome.py 15-Recursos veta_oro_lowpoly SM_Veta_Roca 0.045 2 --dry
"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

RAIZ = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
DIR_BLEND = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp')

PLANTILLA = r"""
import bpy
from mathutils import Vector

bpy.ops.wm.open_mainfile(filepath="@@RUTA@@")
bpy.context.view_layer.update()

PATRON = '@@PATRON@@'
Z_OBJ = @@ZOBJ@@
K = @@K@@

obs = [o for o in bpy.context.scene.objects
       if o.type == 'MESH' and PATRON.lower() in o.name.lower()]
if not obs:
    print('SIN_OBJ')
    raise SystemExit

o = obs[0]

world = [o.matrix_world @ v.co for v in o.data.vertices]
imin = min(range(len(world)), key=lambda i: world[i].z)
zmin = world[imin].z
pmin = world[imin]

# E-51: vecindario por TOPOLOGIA (BFS sobre aristas), NO por distancia XY.
# Con distancia XY se elegian vertices del TECHO del domo (mismo x,y, z=1.12)
# y aplanarlos colapsaba todo el modelo.
ady = {}
for e in o.data.edges:
    a, b = e.vertices[0], e.vertices[1]
    ady.setdefault(a, set()).add(b)
    ady.setdefault(b, set()).add(a)

seleccion = set([imin])
frontera = [imin]
for _ in range(K):
    siguiente = []
    for n in frontera:
        for v in ady.get(n, ()):
            if v not in seleccion:
                seleccion.add(v)
                siguiente.append(v)
    frontera = siguiente
    if not frontera:
        break
seleccion = sorted(seleccion)

print('ROC|%s|min_idx=%d|zmin=%.4f|anillos=%d' % (o.name, imin, zmin, K))
for i in seleccion:
    print('  pre|i=%d|xy=(%.3f,%.3f)|z=%.4f|dz=%.4f' % (
        i, world[i].x, world[i].y, world[i].z, world[i].z - zmin))

inv = o.matrix_world.inverted()
for i in seleccion:
    target = Vector((world[i].x, world[i].y, Z_OBJ))
    local = inv @ target
    o.data.vertices[i].co = local

bpy.context.view_layer.update()

world2 = [o.matrix_world @ v.co for v in o.data.vertices]
zmin2 = min(p.z for p in world2)
toc = sum(1 for p in world2 if p.z <= zmin2 + 0.005)
fp_pts = [p for p in world2 if p.z <= zmin2 + 0.005]
fx = max(p.x for p in fp_pts) - min(p.x for p in fp_pts) if fp_pts else 0.0
fy = max(p.y for p in fp_pts) - min(p.y for p in fp_pts) if fp_pts else 0.0
print('POST|zmin=%.4f|toca=%d|fp=%.3fx%.3f' % (zmin2, toc, fx, fy))

# E-45: NO usar bpy.ops.object.mode_set por socket (Context missing active object).
# Aplanar vertices no cambia el winding de las caras, asi que no hace falta
# recalcular normales con operadores. Solo refrescamos el mesh.
o.data.update()
bpy.context.view_layer.update()

@@GUARDAR@@
"""


def main():
    args = sys.argv[1:]
    if len(args) < 5:
        print(__doc__)
        sys.exit(1)
    modulo = args[0]
    asset = args[1]
    patron = args[2]
    z = float(args[3])
    k = int(args[4])
    variantes = ['source', 'media', 'baja']
    dry = False
    if '--variantes' in args:
        i = args.index('--variantes')
        variantes = args[i + 1].split(',')
    if '--dry' in args:
        dry = True
    for variante in variantes:
        suf = '' if variante == 'source' else '_' + variante
        nombre = asset + suf
        ruta = os.path.join(DIR_BLEND, modulo, nombre + '.blend')
        if not os.path.exists(ruta):
            print('  %-34s (no existe, salteado)' % nombre)
            continue
        rf = ruta.replace('\\', '/')
        if dry:
            guardar = "print('DRY')"
        else:
            guardar = 'bpy.ops.wm.save_mainfile(filepath="%s")\nprint("GUARDADO")' % rf
        code = (PLANTILLA
                .replace('@@RUTA@@', rf)
                .replace('@@PATRON@@', patron)
                .replace('@@ZOBJ@@', repr(z))
                .replace('@@K@@', repr(k))
                .replace('@@GUARDAR@@', guardar))
        r = blender_command('execute_code', {'code': code}, timeout=120)
        if r.get('status') != 'success':
            print('  %-34s ERROR: %s' % (nombre, str(r)[:200]))
            continue
        salida = r.get('result', {}).get('result', '') or ''
        print('--- %s ---' % nombre)
        for l in salida.splitlines():
            if l.strip():
                print('  %s' % l)


if __name__ == '__main__':
    main()
