# crear_velador_lowpoly.py — Mesa chica / velador (M18 mobiliario interior)
#
# Item del checklist: "Mesa chica / velador" — estaba marcado [x] SIN existir
# (auditoría log 809). Se construye de verdad en el log 810.
#
# COTAS (metros): 0.45 x 0.45 de planta, 0.59 de alto.
#   patas  0.07 x 0.07, h 0.50        -> z 0.045..0.545
#   repisa 0.40 x 0.40 x 0.03         -> z 0.185..0.215 (entre patas)
#   cajón  frente 0.38 x 0.04 x 0.16  -> z 0.310..0.470 (cy -0.205)
#   tirador 0.12 x 0.03 x 0.03        -> bronce, cy -0.235
#   tablero 0.48 x 0.48 x 0.045       -> z 0.545..0.590
#   vela   r 0.035 h 0.12             -> z 0.590..0.710
#   llama  r 0.016 h 0.05             -> z 0.710..0.760 (emisiva)
#
# PRESUPUESTO M166 §3.3: 10 SM_ / ~120 tris / 5 mats (ALTA <=16/<=6000/<=12).
# E-100: cz es el CENTRO — la vela apoya sobre el tablero, asi que su base es
# cz - h/2 = 0.590 (tope del tablero), no cz.
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, caja, pata, cilindro, join,
                             arena, iluminar, asentar, camara,
                             sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

LADO = 0.45
MEDIO = LADO / 2.0
PATA_LADO = 0.07
PATA_H = 0.50
TABLERO_H = 0.045
Z_TABLERO_TOP = Z_APOYO + PATA_H + TABLERO_H      # 0.590
VELA_H = 0.12
LLAMA_H = 0.05

# ---- 1) Patas ----
PX = MEDIO - PATA_LADO / 2.0 - 0.01               # 0.185
pies = []
for _sx in (-1, 1):
    for _sy in (-1, 1):
        pies.append(pata('SM_Velador_Pata_%s%s' % ('P' if _sx < 0 else 'C',
                                                   'I' if _sy < 0 else 'D'),
                         M['madera_oscura'], PATA_LADO, PATA_H,
                         _sx * PX, _sy * PX))

# ---- 2) Repisa inferior + cajón + tirador ----
repisa = caja('SM_Velador_Repisa', M['madera_clara'], 0.40, 0.40, 0.03,
              0.0, 0.0, 0.20)
cajon = caja('SM_Velador_Cajon', M['madera_clara'], 0.38, 0.04, 0.16,
             0.0, -0.205, 0.39)
tirador = caja('SM_Velador_Tirador', M['bronce'], 0.12, 0.03, 0.03,
               0.0, -0.235, 0.39)

# ---- 3) Tablero ----
tablero = caja('SM_Velador_Tablero', M['madera_clara'], 0.48, 0.48, TABLERO_H,
               0.0, 0.0, Z_APOYO + PATA_H + TABLERO_H / 2.0)

# ---- 4) Vela + llama (el farolito cozy que lo hace "velador") ----
vela = cilindro('SM_Velador_Vela', M['cera'], 0.035, VELA_H,
                0.10, 0.0, Z_TABLERO_TOP + VELA_H / 2.0, verts=10)
llama = cilindro('SM_Velador_Llama', M['llama'], 0.016, LLAMA_H,
                 0.10, 0.0, Z_TABLERO_TOP + VELA_H + LLAMA_H / 2.0, verts=8)
# La llama NO queda como objeto suelto: el podador de BAJA (E-96) elimina la
# pieza con menos caras, y la llama es justamente la mas chica -> el velador
# perdia su unica razon de ser en el LOD lejano. Uniendolas, la "unidad vela"
# pasa a ser UN objeto con DOS slots de material (cera + llama), asi que la poda
# no puede llevarsela sin llevarse la vela entera.
vela = join('SM_Velador_VelaLlama', [vela, llama])

todas = pies + [repisa, cajon, tirador, tablero, vela]
assert len(todas) == 9, 'esperaba 9 SM_, hay %d' % len(todas)

arena(radio=1.4)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(1.3, -1.4, 0.9), mira=(0.0, 0.0, 0.35))
sombrear_plano(todas)
guardar(escena, 'velador')
