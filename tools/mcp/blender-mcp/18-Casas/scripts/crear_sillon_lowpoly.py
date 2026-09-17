# crear_sillon_lowpoly.py — Sillon / sofa de una plaza y media (M18)
#
# Item del checklist: "Sillon / sofa — interactivo: sentarse". Estaba [x] SIN
# existir (auditoria log 809). Se construye de verdad en el log 811.
#
# COTAS (metros): 1.20 de ancho (X) x 0.80 de fondo (Y).
#   patas     0.09, h 0.16      -> z 0.045..0.205  (x +-0.52, y +-0.30)
#   base      1.16 x 0.76 x .14 -> z 0.205..0.345
#   asiento   1.00 x 0.66 x .14 -> z 0.345..0.485
#   respaldo  1.16 x 0.16 x .58 -> z 0.345..0.925  (y -0.32)
#   brazos    0.16 x 0.76 x .28 -> z 0.345..0.625  (x +-0.52)
#   cojin     0.34 x 0.14 x .30 -> z 0.485..0.785  (x -0.28, y -0.16)
#
# El respaldo y los brazos ARRANCAN en 0.345 (tope de la base), no en el piso:
# asi se lee como tapizado apoyado sobre el bastidor, no como cajas flotando.
#
# PRESUPUESTO M166 §3.3: 10 SM_ / ~140 tris / 3 mats (ALTA <=16/<=6000/<=12).
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, caja, pata,
                             arena, iluminar, asentar, camara,
                             sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

ANCHO = 1.20
FONDO = 0.80
PATA_LADO = 0.09
PATA_H = 0.16
Z_BASE_TOP = Z_APOYO + PATA_H + 0.14            # 0.345
Z_ASIENTO_TOP = Z_BASE_TOP + 0.14               # 0.485

# ---- 1) Patas ----
PX = ANCHO / 2.0 - 0.08                          # 0.52
PY = FONDO / 2.0 - 0.10                          # 0.30
patas = []
for _sx in (-1, 1):
    for _sy in (-1, 1):
        patas.append(pata('SM_Sillon_Pata_%s%s' % ('P' if _sx < 0 else 'C',
                                                   'I' if _sy < 0 else 'D'),
                          M['madera_oscura'], PATA_LADO, PATA_H,
                          _sx * PX, _sy * PY))

# ---- 2) Bastidor tapizado + asiento ----
base = caja('SM_Sillon_Base', M['tela_roja'], 1.16, 0.76, 0.14,
            0.0, 0.0, Z_APOYO + PATA_H + 0.07)
asiento = caja('SM_Sillon_Asiento', M['tela_roja'], 1.00, 0.66, 0.14,
               0.0, 0.0, Z_BASE_TOP + 0.07)

# ---- 3) Respaldo + brazos (nacen del tope de la base) ----
respaldo = caja('SM_Sillon_Respaldo', M['tela_roja'], 1.16, 0.16, 0.58,
                0.0, -0.32, Z_BASE_TOP + 0.29)
brazos = [caja('SM_Sillon_Brazo_%s' % ('I' if s < 0 else 'D'),
               M['madera_oscura'], 0.16, 0.76, 0.28,
               s * PX, 0.0, Z_BASE_TOP + 0.14)
          for s in (-1, 1)]

# ---- 4) Cojin decorativo ----
cojin = caja('SM_Sillon_Cojin', M['tela_crema'], 0.34, 0.14, 0.30,
             -0.28, -0.16, Z_ASIENTO_TOP + 0.15)

todas = patas + [base, asiento, respaldo] + brazos + [cojin]
assert len(todas) == 10, 'esperaba 10 SM_, hay %d' % len(todas)

arena(radio=1.5)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(1.9, -1.8, 1.1), mira=(0.0, 0.0, 0.45))
sombrear_plano(todas)
guardar(escena, 'sillon')
