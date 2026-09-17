# crear_cama_basica_lowpoly.py — Cama básica de 1 plaza (M18 mobiliario interior)
#
# Item del checklist: "Cama básica (marco madera + colchón + almohada + manta)
# — interactivo: dormir". Estaba marcado [x] SIN existir (auditoría log 809);
# se construye de verdad en el log 810.
#
# COTAS (metros, X = largo de la cama, cabecera en -X):
#   patas        0.10 x 0.10, h 0.30  -> tope 0.345
#   largueros    1.86 x 0.08 x 0.12   -> z 0.225..0.345
#   travesaños   0.08 x 0.75 x 0.12   -> z 0.225..0.345
#   somier       1.86 x 0.71 x 0.05   -> z 0.345..0.395
#   colchón      1.94 x 0.88 x 0.18   -> z 0.395..0.575
#   almohada     0.50 x 0.56 x 0.13   -> z 0.575..0.705  (cx -0.60)
#   manta        1.20 x 0.94 x 0.09   -> z 0.545..0.635  (cx -0.30, cae 3 cm)
#   panel cabec. 0.07 x 0.90 x 0.60   -> z 0.300..0.900  (cx -1.005)
#   postes (2)   0.10 x 0.10, h 0.855 -> z 0.045..0.900  (cy +-0.42)
#
# PRESUPUESTO M166 §3.3: 15 SM_ / 180 tris / 5 mats (ALTA <=16 / <=6000 / <=12).
#
# E-100: en caja() el cz es el CENTRO. Una pata que apoya en Z_APOYO con altura h
# va en cz = Z_APOYO + h/2 (NO en cz = Z_APOYO).
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, caja, pata, arena, iluminar,
                             asentar, camara, sombrear_plano, guardar,
                             piezas, Z_APOYO)

escena = limpiar()
M = paleta()

# ---- cotas verticales (derivadas, no magic numbers sueltos) ----
PATA_LADO = 0.10
PATA_H = 0.30
RAIL_TOP = Z_APOYO + PATA_H          # 0.345
SOMIER_H = 0.05
COLCHON_H = 0.18
Z_COLCHON_TOP = RAIL_TOP + SOMIER_H + COLCHON_H   # 0.575
ALMOHADA_H = 0.13
MANTA_H = 0.09

LARGO_X = 1.86      # largo del bastidor (largueros / somier)
ANCHO_Y = 0.90      # ancho nominal de la cama
MEDIA_Y = ANCHO_Y / 2.0

# ---- 1) Patas (madera oscura) ----
PATA_X = 0.88
PATA_Y = 0.375
pies = []
for _i, _sx in enumerate((-1, 1)):
    for _j, _sy in enumerate((-1, 1)):
        pies.append(pata('SM_Cama_Pata_%s%s' % ('P' if _sx < 0 else 'C',
                                                'I' if _sy < 0 else 'D'),
                         M['madera_oscura'], PATA_LADO, PATA_H,
                         _sx * PATA_X, _sy * PATA_Y))

# ---- 2) Bastidor: 2 largueros + 2 travesaños (madera clara) ----
RAIL_Z = RAIL_TOP - 0.06             # cz 0.285 -> z 0.225..0.345
bastidor = [
    caja('SM_Cama_Larguero_I', M['madera_clara'], LARGO_X, 0.08, 0.12,
         0.0, +PATA_Y, RAIL_Z),
    caja('SM_Cama_Larguero_D', M['madera_clara'], LARGO_X, 0.08, 0.12,
         0.0, -PATA_Y, RAIL_Z),
    caja('SM_Cama_Travesano_Cabecera', M['madera_clara'], 0.08, 0.75, 0.12,
         +PATA_X, 0.0, RAIL_Z),
    caja('SM_Cama_Travesano_Pie', M['madera_clara'], 0.08, 0.75, 0.12,
         -PATA_X, 0.0, RAIL_Z),
]

# ---- 3) Somier (tablas) + colchón ----
somier = caja('SM_Cama_Somier', M['madera_clara'], LARGO_X, 0.71, SOMIER_H,
              0.0, 0.0, RAIL_TOP + SOMIER_H / 2.0)
colchon = caja('SM_Cama_Colchon', M['tela_crema'], 1.94, 0.88, COLCHON_H,
               0.0, 0.0, RAIL_TOP + SOMIER_H + COLCHON_H / 2.0)

# ---- 4) Ropa de cama: almohada + manta ----
almohada = caja('SM_Cama_Almohada', M['lino'], 0.50, 0.56, ALMOHADA_H,
                -0.60, 0.0, Z_COLCHON_TOP + ALMOHADA_H / 2.0)
# la manta ARRANCA 3 cm por debajo del tope del colchón y sobresale 3 cm en Y:
# así cae por los costados en vez de ser una tapa flotante (E-100).
manta = caja('SM_Cama_Manta', M['tela_roja'], 1.20, 0.94, MANTA_H,
             -0.30, 0.0, Z_COLCHON_TOP - 0.03 + MANTA_H / 2.0)

# ---- 5) Cabecera: panel + 2 postes que llegan al piso ----
CAB_X = -1.005
POSTE_H = 0.855                      # 0.045 -> 0.900
panel = caja('SM_Cama_Cabecera_Panel', M['madera_clara'], 0.07, 0.90, 0.60,
             CAB_X, 0.0, 0.60)
postes = [
    pata('SM_Cama_Cabecera_Poste_I', M['madera_oscura'], 0.10, POSTE_H, CAB_X, +0.42),
    pata('SM_Cama_Cabecera_Poste_D', M['madera_oscura'], 0.10, POSTE_H, CAB_X, -0.42),
]

todas = pies + bastidor + [somier, colchon, almohada, manta, panel] + postes
assert len(todas) == 15, 'esperaba 15 SM_, hay %d' % len(todas)

# ---- 6) Set de captura + cierre ----
arena(radio=1.8)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(2.6, -2.8, 1.5), mira=(-0.1, 0.0, 0.45))
sombrear_plano(todas)
guardar(escena, 'cama_basica')
