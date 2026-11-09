# Sonda geometrica de autoria HY4 — B21/L39 cangrejo_ermitano (M36).
# Se ejecuta DENTRO de Blender 4.2 headless:
#   blender -b --factory-startup --python-exit-code 1 \
#     --python Temp/hy4_cangrejo_sonda_20261109.py -- <blend> <blend> <blend>
# Exige que TODA cara de TODO SM_ sea un quad AXIS-ALIGNED: exactamente
# 1 coordenada constante (el plano) y las otras 2 variables. Un DECIMATE
# sobre cajas disjuntas (trampa B18/acta 28) mete triangulos y quads
# inclinados invisibles en el render pero detectables aca.
# `chk_asset.py` mide COSTE, no FORMA: por eso esta sonda es complementaria.
# Scratch: se CONSERVA, no se borra, no se versiona.
import os
import sys
import bpy

TOL = 1e-5
argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
if not argv:
    print('FALTA: pasar las rutas de los .blend despues de --')
    sys.exit(2)

total_defectos = 0
for path in argv:
    bpy.ops.wm.open_mainfile(filepath=path)
    obs = [o for o in bpy.context.scene.objects
           if o.type == 'MESH' and o.name.startswith('SM_')]
    bpy.context.view_layer.update()
    caras = 0
    defectos = []
    niveles_z = set()
    for o in obs:
        for v in o.data.vertices:
            niveles_z.add(round((o.matrix_world @ v.co).z, 4))
        for p in o.data.polygons:
            caras += 1
            vs = [o.matrix_world @ o.data.vertices[i].co for i in p.vertices]
            if len(vs) != 4:
                defectos.append((o.name, p.index, 'nverts=%d' % len(vs)))
                continue
            constantes = 0
            for eje in range(3):
                vals = [v[eje] for v in vs]
                if max(vals) - min(vals) < TOL:
                    constantes += 1
            if constantes != 1:
                defectos.append((o.name, p.index,
                                 'constantes=%d' % constantes))
    espurios = sorted(v for v in niveles_z if 0.29 < v < 0.35)
    total_defectos += len(defectos) + len(espurios)
    print('SONDA %s | obj=%d caras=%d defectos=%d niveles_z=%d '
          'zona_vacia_espurios=%s | VEDICTO=%s'
          % (os.path.basename(path), len(obs), caras, len(defectos),
             len(niveles_z), espurios,
             'LIMPIA' if not defectos and not espurios else 'DANADA'))
    for d in defectos[:8]:
        print('   DEFECTO', d)
print('SONDA_B21 FIN total_defectos=%d' % total_defectos)
if total_defectos:
    sys.exit(1)
