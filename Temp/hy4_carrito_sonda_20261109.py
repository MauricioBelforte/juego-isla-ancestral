# Sonda geometrica de autoría HY4 — B20/L40 carrito_vias (M35).
# Se ejecuta DENTRO de Blender 4.2 headless:
#   blender -b --factory-startup --python-exit-code 1 \
#     --python Temp/hy4_carrito_sonda_20261109.py -- <blend> <blend> <blend>
# Exige que TODA cara de TODO SM_ sea un quad AXIS-ALIGNED: exactamente
# 1 coordenada constante (el plano) y las otras 2 variables. Un DECIMATE
# sobre cajas disjuntas (trampa B18/acta 28) mete triangulos y quads
# inclinados invisibles en el render pero detectables aca.
# Scratch: se CONSERVA, no se borra, no se versiona.
import os
import sys
import bpy

TOL = 1e-5
argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
if not argv:
    print('FALTA: pasar las rutas de los .blend despues de --')
    sys.exit(2)

for path in argv:
    bpy.ops.wm.open_mainfile(filepath=path)
    obs = [o for o in bpy.context.scene.objects
           if o.type == 'MESH' and o.name.startswith('SM_')]
    bpy.context.view_layer.update()
    caras = 0
    defectos = []
    for o in obs:
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
    print('SONDA %s | obj=%d caras=%d defectos=%d | VEDICTO=%s'
          % (os.path.basename(path), len(obs), caras, len(defectos),
             'LIMPIA' if not defectos else 'DANADA'))
    for d in defectos[:8]:
        print('   DEFECTO', d)
print('SONDA_B20 FIN')
