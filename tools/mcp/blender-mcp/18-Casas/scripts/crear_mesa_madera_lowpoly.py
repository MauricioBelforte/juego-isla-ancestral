# crear_mesa_madera_lowpoly.py — Mesa de madera (M18 mobiliario interior)
#
# Item del checklist: "Mesa de madera (tablero + 4 patas)
# — interactivo: colocar items". Estaba marcado [x] SIN existir (log 809).
#
# COTAS (metros): tablero 1.30 x 0.90, alto 0.825 (mesa de comedor cozy).
#   patas      0.09 x 0.09, h 0.72      -> z 0.045..0.765
#   tablero    1.30 x 0.90 x 0.06       -> z 0.765..0.825
#   largueros  1.10 x 0.06 x 0.08       -> z 0.160..0.240 (cy +-0.33)
#   travesaños 0.06 x 0.66 x 0.08       -> z 0.160..0.240 (cx +-0.53)
#
# PRESUPUESTO M166 §3.3: 9 SM_ / 108 tris / 2 mats (ALTA <=16/<=6000/<=12).
# El tablero vuela 5 cm sobre las patas en cada lado (tablero 1.30 vs patas
# separadas 1.10): es el voladizo tipico de una mesa de comedor y ademas agranda
# la huella (E-50) sin costo de triangulos.
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, caja, pata, arena, iluminar,
                             asentar, camara, sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

LARGO_X = 1.30
FONDO_Y = 0.90
PATA_LADO = 0.09
PATA_H = 0.72
TABLERO_H = 0.06
Z_TABLERO_TOP = Z_APOYO + PATA_H + TABLERO_H      # 0.825
PX = 0.53          # separacion de patas en X (tablero vuela 0.12 por lado)
PY = 0.33          # separacion en Y (tablero vuela 0.12 por lado)

# ---- 1) Patas ----
pies = []
for _sx in (-1, 1):
    for _sy in (-1, 1):
        pies.append(pata('SM_Mesa_Pata_%s%s' % ('P' if _sx < 0 else 'C',
                                                'I' if _sy < 0 else 'D'),
                         M['madera_oscura'], PATA_LADO, PATA_H,
                         _sx * PX, _sy * PY))

# ---- 2) Tablero ----
tablero = caja('SM_Mesa_Tablero', M['madera_clara'], LARGO_X, FONDO_Y,
               TABLERO_H, 0.0, 0.0, Z_APOYO + PATA_H + TABLERO_H / 2.0)

# ---- 3) Bastidor (2 largueros en X + 2 travesaños en Y) ----
bastidor = [
    caja('SM_Mesa_Larguero_I', M['madera_oscura'], 1.10, 0.06, 0.08, 0.0, +PY, 0.20),
    caja('SM_Mesa_Larguero_D', M['madera_oscura'], 1.10, 0.06, 0.08, 0.0, -PY, 0.20),
    caja('SM_Mesa_Travesano_C', M['madera_oscura'], 0.06, 0.66, 0.08, +PX, 0.0, 0.20),
    caja('SM_Mesa_Travesano_P', M['madera_oscura'], 0.06, 0.66, 0.08, -PX, 0.0, 0.20),
]

todas = pies + [tablero] + bastidor
assert len(todas) == 9, 'esperaba 9 SM_, hay %d' % len(todas)

arena(radio=1.8)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(2.0, -2.2, 1.3), mira=(0.0, 0.0, 0.45))
sombrear_plano(todas)
guardar(escena, 'mesa_madera')
