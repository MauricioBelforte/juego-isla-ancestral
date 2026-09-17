# crear_silla_madera_lowpoly.py — Silla de madera (M18 mobiliario interior)
#
# Item del checklist: "Silla de madera (asiento + respaldo + 4 patas)
# — interactivo: sentarse". Estaba marcado [x] SIN existir (auditoría log 809).
#
# COTAS (metros): planta 0.44 x 0.44, asiento a 0.545, respaldo hasta 0.965.
#   patas     0.06 x 0.06, h 0.45     -> z 0.045..0.495
#   asiento   0.44 x 0.44 x 0.05      -> z 0.495..0.545
#   montantes 0.05 x 0.05, h 0.42     -> z 0.545..0.965 (cy -0.19)
#   listones  0.38 x 0.04 x 0.07      -> z 0.685..0.755 y 0.845..0.915
#   travesaños 0.04 x 0.36 x 0.04     -> z 0.180..0.220 (cx +-0.18)
#
# PRESUPUESTO M166 §3.3: 11 SM_ / 132 tris / 2 mats (ALTA <=16/<=6000/<=12).
# E-100: cz es el CENTRO. Los montantes arrancan en el tope del asiento
# (0.545), asi que cz = 0.545 + 0.42/2 = 0.755.
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, caja, pata, arena, iluminar,
                             asentar, camara, sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

LADO = 0.44
PX = LADO / 2.0 - 0.04                 # 0.18
PATA_LADO = 0.06
PATA_H = 0.45
ASIENTO_H = 0.05
Z_ASIENTO_TOP = Z_APOYO + PATA_H + ASIENTO_H     # 0.545
MONTANTE_H = 0.42
Z_RESPALDO_TOP = Z_ASIENTO_TOP + MONTANTE_H      # 0.965
RESP_Y = -0.19                          # respaldo en el borde trasero (-Y)

# ---- 1) Patas ----
pies = []
for _sx in (-1, 1):
    for _sy in (-1, 1):
        pies.append(pata('SM_Silla_Pata_%s%s' % ('P' if _sx < 0 else 'C',
                                                 'I' if _sy < 0 else 'D'),
                         M['madera_oscura'], PATA_LADO, PATA_H,
                         _sx * PX, _sy * PX))

# ---- 2) Asiento ----
asiento = caja('SM_Silla_Asiento', M['madera_clara'], LADO, LADO, ASIENTO_H,
               0.0, 0.0, Z_APOYO + PATA_H + ASIENTO_H / 2.0)

# ---- 3) Travesaños entre patas (rigidez visual) ----
trav = [
    caja('SM_Silla_Travesano_I', M['madera_oscura'], 0.04, 0.36, 0.04,
         +PX, 0.0, 0.20),
    caja('SM_Silla_Travesano_D', M['madera_oscura'], 0.04, 0.36, 0.04,
         -PX, 0.0, 0.20),
]

# ---- 4) Respaldo: 2 montantes + 2 listones ----
mont = [
    caja('SM_Silla_Montante_I', M['madera_oscura'], 0.05, 0.05, MONTANTE_H,
         +PX, RESP_Y, Z_ASIENTO_TOP + MONTANTE_H / 2.0),
    caja('SM_Silla_Montante_D', M['madera_oscura'], 0.05, 0.05, MONTANTE_H,
         -PX, RESP_Y, Z_ASIENTO_TOP + MONTANTE_H / 2.0),
]
listones = [
    caja('SM_Silla_Liston_Bajo', M['madera_clara'], 0.38, 0.04, 0.07,
         0.0, RESP_Y - 0.005, Z_ASIENTO_TOP + 0.17),
    caja('SM_Silla_Liston_Alto', M['madera_clara'], 0.38, 0.04, 0.07,
         0.0, RESP_Y - 0.005, Z_RESPALDO_TOP - 0.12),
]

todas = pies + [asiento] + trav + mont + listones
assert len(todas) == 11, 'esperaba 11 SM_, hay %d' % len(todas)

arena(radio=1.2)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(1.2, -1.3, 0.85), mira=(0.0, 0.0, 0.45))
sombrear_plano(todas)
guardar(escena, 'silla_madera')
