# Sonda geometrica B22 (scratch, NO se versiona): caras axis-aligned en los
# 6 .blend de pez tropical. chk_asset.py mide COSTE, no FORMA (acta 28).
import bpy
import os

RAIZ = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral'
DIR = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '36-Fauna')
ARCHIVOS = [
    'pez_tropical_%s_lowpoly%s.blend' % (v, s)
    for v in ('azul', 'naranja')
    for s in ('', '_media', '_baja')
]
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
            pts = [vs[i] for i in p.vertices]
            constantes = 0
            for eje in range(3):
                vals = [w[eje] for w in pts]
                if max(vals) - min(vals) < TOL:
                    constantes += 1
            if constantes != 1:
                inclinadas += 1
                if len(ejemplos) < 3:
                    ejemplos.append((o.name, p.index, len(p.vertices), constantes))
    defectos = tris + ngons + inclinadas
    total_def += defectos
    print('SONDA %-42s obj=%2d caras=%3d z=[%.4f..%.4f] '
          'tris=%d ngons=%d inclinadas=%d DEFECTOS=%d %s'
          % (nombre, len(obs), caras, min(zs), max(zs),
             tris, ngons, inclinadas, defectos, ejemplos))

print('SONDA_B22 FIN total_defectos=%d (esperado 0)' % total_def)
