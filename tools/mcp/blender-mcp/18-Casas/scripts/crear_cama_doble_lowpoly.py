# crear_cama_doble_lowpoly.py — Cama de dos plazas (M18 mobiliario interior)
#
# Item del checklist: "Cama doble — interactivo: dormir". Estaba marcado [x] SIN
# existir (auditoria log 809). Se construye de verdad en el log 811.
#
# COTAS (metros): 2.00 de largo (X) x 1.40 de ancho (Y).
#   patas delanteras 0.10, h 0.30   -> z 0.045..0.345   (x +0.95, y +-0.66)
#   postes  traseros  0.10, h 0.90  -> z 0.045..0.945   (x -0.95, y +-0.66)
#   largueros 1.90 x 0.08 x 0.10    -> z 0.345..0.445   (eje X, y +-0.66)
#   travesanos 0.08 x 1.32 x 0.10   -> z 0.345..0.445   (eje Y, x +-0.95)
#   somier    1.90 x 1.32 x 0.03    -> z 0.445..0.475
#   colchon   1.96 x 1.38 x 0.20    -> z 0.475..0.675
#   almohadas 0.34 x 0.60 x 0.12    -> z 0.675..0.795   (x -0.62, y +-0.32)
#   manta     1.20 x 1.42 x 0.05    -> z 0.675..0.725   (x +0.34)
#   cabecera  0.06 x 1.40 x 0.80    -> z 0.045..0.845   (x -1.02)
#
# DIFERENCIA CON cama_basica: alla los 4 postes bajos sostienen un panel bajo;
# aca los dos TRASEROS se estiran hasta 0.945 y ellos mismos son las columnas
# de la cabecera, asi la cabecera no queda colgando del colchon.
#
# PRESUPUESTO M166 §3.3: 14 SM_ / ~230 tris / 5 mats (ALTA <=16/<=6000/<=12).
# E-100: cz es el CENTRO, no la base.
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, caja, pata, join,
                             arena, iluminar, asentar, camara,
                             sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

LARGO = 2.00
ANCHO = 1.40
PATA_LADO = 0.10
PATA_H = 0.30
POSTE_H = 0.90
Z_BASTIDOR = 0.10
RAIL_TOP = Z_APOYO + PATA_H + Z_BASTIDOR      # 0.445
SOMIER_H = 0.03
COLCHON_H = 0.20
Z_COLCHON_TOP = RAIL_TOP + SOMIER_H + COLCHON_H   # 0.675

# ---- 1) Apoyo: 2 patas delante + 2 postes detras (sostienen la cabecera) ----
PX = LARGO / 2.0 - PATA_LADO / 2.0 - 0.00     # 0.95
PY = ANCHO / 2.0 - PATA_LADO / 2.0 - 0.04     # 0.66
apoyos = []
for _sy in (-1, 1):
    apoyos.append(pata('SM_CamaDoble_Pata_%s' % ('I' if _sy < 0 else 'D'),
                       M['madera_oscura'], PATA_LADO, PATA_H, +PX, _sy * PY))
    apoyos.append(caja('SM_CamaDoble_Poste_%s' % ('I' if _sy < 0 else 'D'),
                       M['madera_oscura'], PATA_LADO, PATA_LADO, POSTE_H,
                       -PX, _sy * PY, Z_APOYO + POSTE_H / 2.0))

# ---- 2) Bastidor: largueros (eje X) + travesanos (eje Y) ----
largueros = [caja('SM_CamaDoble_Larguero_%s' % ('I' if s < 0 else 'D'),
                  M['madera_oscura'], LARGO - 0.10, 0.08, Z_BASTIDOR,
                  0.0, s * PY, RAIL_TOP - Z_BASTIDOR / 2.0)
             for s in (-1, 1)]
travesanos = [caja('SM_CamaDoble_Travesano_%s' % ('P' if s < 0 else 'C'),
                   M['madera_oscura'], 0.08, ANCHO - 0.08, Z_BASTIDOR,
                   s * PX, 0.0, RAIL_TOP - Z_BASTIDOR / 2.0)
              for s in (-1, 1)]

# ---- 3) Somier + colchon ----
somier = caja('SM_CamaDoble_Somier', M['madera_clara'],
              LARGO - 0.10, ANCHO - 0.08, SOMIER_H,
              0.0, 0.0, RAIL_TOP + SOMIER_H / 2.0)
colchon = caja('SM_CamaDoble_Colchon', M['lino'],
               LARGO - 0.04, ANCHO - 0.02, COLCHON_H,
               0.0, 0.0, RAIL_TOP + SOMIER_H + COLCHON_H / 2.0)

# ---- 4) Ropa de cama ----
almohadas = [caja('SM_CamaDoble_Almohada_%s' % ('I' if s < 0 else 'D'),
                  M['tela_crema'], 0.34, 0.60, 0.12,
                  -0.62, s * 0.32, Z_COLCHON_TOP + 0.06)
             for s in (-1, 1)]
manta = caja('SM_CamaDoble_Manta', M['tela_roja'],
             1.20, ANCHO + 0.02, 0.05,
             +0.34, 0.0, Z_COLCHON_TOP + 0.025)

# ---- 5) Cabecera: apoya en el piso, no cuelga ----
cabecera = caja('SM_CamaDoble_Cabecera', M['madera_oscura'],
                0.06, ANCHO, 0.80,
                -(LARGO / 2.0 + 0.02), 0.0, Z_APOYO + 0.40)

todas = apoyos + largueros + travesanos + [somier, colchon] + almohadas \
    + [manta, cabecera]
assert len(todas) == 14, 'esperaba 14 SM_, hay %d' % len(todas)

arena(radio=2.0)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(2.6, -2.4, 1.7), mira=(0.0, 0.0, 0.5))
sombrear_plano(todas)
guardar(escena, 'cama_doble')
