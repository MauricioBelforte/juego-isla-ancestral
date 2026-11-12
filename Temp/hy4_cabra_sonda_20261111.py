# Sonda geometrica B24 (scratch, NO se versiona): caras axis-aligned en los
# 3 .blend de la cabra. chk_asset.py mide COSTE, no FORMA (acta 28).
import bpy
import os

RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
DIR = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '36-Fauna')
ARCHIVOS = ['cabra_lowpoly%s.blend' % s for s in ('', '_media', '_baja')]
TOL = 1e-4
total_def = 0

for nombre in ARCHIVOS:
    ruta = os.path.join(DIR, nombre)
    bpy.ops.wm.open_mainfile(filepath=ruta)
    obs = [o for o in bpy.context.scene.objects if o.name.startswith('SM_')]
    caras = tris = ngons = inclinadas = 0
    ejemplos = []
    zs = []
    for o in obs:
        vs = [o.matrix_world @ v.co for v in o.data.vertices]
        zs.extend(w.z for w in vs)
        for p in o.data.polygons:
            caras += 1
            if len(p.vertices) == 3:
                tris += 1
            elif len(p.vertices) > 4:
                ngons += 1
                ejemplos.append((o.name, p.index, 'ngon'))
            else:
                # quad: una cara de caja AXIS-ALIGNED tiene EXACTAMENTE 1
                # coordenada constante (el plano) y las otras 2 varian.
                pv = [vs[i] for i in p.vertices]
                constantes = 0
                for eje in range(3):
                    vals = [v[eje] for v in pv]
                    if max(vals) - min(vals) < TOL:
                        constantes += 1
                if constantes != 1:
                    inclinadas += 1
                    ejemplos.append((o.name, p.index, 'inclinada'))
    defectos = tris + ngons + inclinadas
    total_def += defectos
    print('SONDA %-38s obj=%2d caras=%3d z=[%.4f..%.4f] '
          'tris=%d ngons=%d inclinadas=%d DEFECTOS=%d %s'
          % (nombre, len(obs), caras, min(zs), max(zs),
             tris, ngons, inclinadas, defectos, ejemplos[:3]))

print('SONDA_B24 FIN total_defectos=%d (esperado 0)' % total_def)
assert total_def == 0, 'la sonda encontro geometria fuera de plano'
