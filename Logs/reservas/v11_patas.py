# -*- coding: utf-8 -*-
# Fix v11: patas como cubos simples (probado), solo cuerpo/cabeza con loft.
import io, sys
sys.stdout.reconfigure(encoding='utf-8')
path = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral\scripts\conejo_v11.py'
with io.open(path, 'r', encoding='utf-8') as f:
    c = f.read()

viejo = """# ═══════════ 5) PATAS (4, lofted cilíndricas a lo largo de Z) ═══════════
for lado in [-1, 1]:
    l = 'I' if lado < 0 else 'D'
    # delanteras (y=-0.10)
    AN_PD = [
        [(lado * 0.055, -0.10, 0.055 + 0.032 * cos(2 * pi * a / 6)),
         0 + 0.032 * sin(2 * pi * a / 6)] for a in range(6)]
    # fix: anillo vertical (eje Z)
    AN_PD = [
        [(lado * 0.055 + 0.032 * cos(2 * pi * a / 6), -0.10,
          0.055 + 0.032 * sin(2 * pi * a / 6))] for a in range(6)]
    # la lista de anillos para loft: cada anillo es un nivel Z
    AN_PD = []
    for nivel_z in [0.055, 0.035, 0.020]:
        ring = [(lado * 0.055 + 0.030 * cos(2 * pi * a / 6), -0.10,
                 nivel_z + 0.030 * sin(2 * pi * a / 6)) for a in range(6)]
        AN_PD.append(ring[0])  # anillo_y espera (x,y,z) — usar ring directo
    # Simplificar: usar loft con anillos en plano XY a distintas Z
    AN_PD = []
    for nivel_z in [0.055, 0.035, 0.020]:
        AN_PD.append([(lado * 0.055 + 0.030 * cos(2 * pi * a / 6),
                       -0.10 + 0.030 * sin(2 * pi * a / 6),
                       nivel_z) for a in range(6)])
    loft(f'SM_Conejo_Pata_D_{l}', AN_PD, MAT_patas)
    # traseras
    AN_PT = []
    for nivel_z in [0.075, 0.050, 0.030]:
        AN_PT.append([(lado * 0.075 + 0.038 * cos(2 * pi * a / 6),
                       0.10 + 0.038 * sin(2 * pi * a / 6),
                       nivel_z) for a in range(6)])
    loft(f'SM_Conejo_Pata_T_{l}', AN_PT, MAT_patas)
    # pies traseros (losas horizontales)
    cubo(f'SM_Conejo_Pie_T_{l}', 0.055, 0.14, 0.035, lado * 0.075, 0.04, 0.02, MAT_patas)"""

nuevo = """# ═══════════ 5) PATAS (cubos simples — probado, se ven bien) ═══════════
for lado in [-1, 1]:
    l = 'I' if lado < 0 else 'D'
    cubo(f'SM_Conejo_Pata_D_{l}', 0.06, 0.06, 0.10, lado * 0.055, -0.10, 0.05, MAT_patas)
    cubo(f'SM_Conejo_Pata_T_{l}', 0.07, 0.07, 0.10, lado * 0.075, 0.10, 0.05, MAT_patas)
    cubo(f'SM_Conejo_Pie_T_{l}', 0.055, 0.14, 0.035, lado * 0.075, 0.04, 0.02, MAT_patas)"""

c = c.replace(viejo, nuevo, 1)
with io.open(path, 'w', encoding='utf-8') as f:
    f.write(c)
print('v11: patas simplificadas a cubos')
