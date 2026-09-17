# crear_estufa_lena_lowpoly.py — Cocina / estufa de lena (M18)
#
# Item del checklist: "Cocina/estufa de lena (base + hornallas + chimenea) —
# interactivo: cocinar". Estaba [x] SIN existir (auditoria log 809).
# Se construye de verdad en el log 811.
#
# COTAS (metros): 0.94 (X) x 0.62 (Y); alto 0.945 + chimenea hasta 1.875.
#   patas    0.08, h 0.14        -> z 0.045..0.185   (x +-0.39, y +-0.24)
#   leniero  0.70 x 0.44 x 0.12  -> z 0.045..0.165   (bajo el cuerpo)
#   cuerpo   0.86 x 0.56 x 0.70  -> z 0.185..0.885
#   encimera 0.94 x 0.62 x 0.06  -> z 0.885..0.945
#   hornallas r 0.13, h 0.03     -> z 0.945..0.975   (2, join)
#   puerta   0.50 x 0.04 x 0.36  -> z 0.255..0.615   (y +0.30)
#   tirador  0.30 x 0.035 x .035 -> y +0.325, z 0.560
#   tubo     r 0.09, h 0.90      -> z 0.945..1.845   (x +0.22, y -0.12)
#   sombrete r 0.13, h 0.06      -> z 1.845..1.875
#
# El leniero no es decoracion: es el unico indicio visual de que la estufa se
# alimenta de lena (sin electricidad, M147) y ademas rellena el hueco entre las
# patas para que no se vea aire debajo del cuerpo.
#
# E-96: las dos hornallas son los discos con menos caras -> van unidas.
#
# PRESUPUESTO M166 §3.3: 12 SM_ / ~200 tris / 3 mats (ALTA <=16/<=6000/<=12).
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, caja, pata, cilindro, join,
                             arena, iluminar, asentar, camara,
                             sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

PATA_LADO = 0.08
PATA_H = 0.14
Z_CUERPO_BASE = Z_APOYO + PATA_H                # 0.185
Z_CUERPO_TOP = Z_CUERPO_BASE + 0.70             # 0.885
Z_ENCIMERA_TOP = Z_CUERPO_TOP + 0.06            # 0.945

# ---- 1) Patas + leniero ----
patas = []
for _sx in (-1, 1):
    for _sy in (-1, 1):
        patas.append(pata('SM_Estufa_Pata_%s%s' % ('P' if _sx < 0 else 'C',
                                                   'I' if _sy < 0 else 'D'),
                          M['hierro'], PATA_LADO, PATA_H,
                          _sx * 0.39, _sy * 0.24))
leniero = caja('SM_Estufa_Leniero', M['madera_oscura'], 0.70, 0.44, 0.12,
               0.0, 0.0, Z_APOYO + 0.06)

# ---- 2) Cuerpo + encimera ----
cuerpo = caja('SM_Estufa_Cuerpo', M['hierro'], 0.86, 0.56, 0.70,
              0.0, 0.0, Z_CUERPO_BASE + 0.35)
encimera = caja('SM_Estufa_Encimera', M['hierro'], 0.94, 0.62, 0.06,
                0.0, 0.0, Z_CUERPO_TOP + 0.03)

# ---- 3) Hornallas (join, E-96) ----
hornallas = join('SM_Estufa_Hornallas', [
    cilindro('SM_Estufa_Hornalla_I', M['hierro'], 0.13, 0.03,
             -0.20, -0.04, Z_ENCIMERA_TOP + 0.015, verts=12),
    cilindro('SM_Estufa_Hornalla_D', M['hierro'], 0.13, 0.03,
             +0.20, -0.04, Z_ENCIMERA_TOP + 0.015, verts=12),
])

# ---- 4) Puerta del horno + tirador ----
puerta = caja('SM_Estufa_Puerta', M['hierro'], 0.50, 0.04, 0.36,
              0.0, +0.30, Z_CUERPO_BASE + 0.25)
tirador = caja('SM_Estufa_Tirador', M['bronce'], 0.30, 0.035, 0.035,
               0.0, +0.325, 0.560)

# ---- 5) Chimenea: tubo + sombrerete ----
tubo = cilindro('SM_Estufa_Tubo', M['hierro'], 0.09, 0.90,
                +0.22, -0.12, Z_ENCIMERA_TOP + 0.45, verts=10)
sombrete = cilindro('SM_Estufa_Sombrerete', M['hierro'], 0.13, 0.06,
                    +0.22, -0.12, Z_ENCIMERA_TOP + 0.90 + 0.03, verts=10)

todas = patas + [leniero, cuerpo, encimera, hornallas, puerta, tirador,
                 tubo, sombrete]
assert len(todas) == 12, 'esperaba 12 SM_, hay %d' % len(todas)

arena(radio=1.5)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(2.0, -1.9, 1.6), mira=(0.0, 0.0, 0.85))
sombrear_plano(todas)
guardar(escena, 'estufa_lena')
