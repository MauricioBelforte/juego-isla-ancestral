# crear_comoda_lowpoly.py — Comoda / baul de ropa (M18)
#
# Item del checklist: "Comoda / baul de ropa — interactivo: almacenar".
# Estaba [x] SIN existir (auditoria log 809). Se construye en el log 811.
#
# COTAS (metros): 0.94 (X) x 0.52 (Y) x 0.855 de alto.
#   patas    0.08, h 0.14        -> z 0.045..0.185   (x +-0.39, y +-0.19)
#   cuerpo   0.86 x 0.46 x 0.62  -> z 0.185..0.805
#   cajones  0.78 x 0.04 x 0.17  -> cz 0.285 / 0.475 / 0.665  (y +0.235)
#   tiradores 3 (join, bronce)   -> y +0.255
#   tablero  0.94 x 0.52 x 0.05  -> z 0.805..0.855
#
# E-96: los 3 tiradores son piezas chicas sueltas que el podador de BAJA
# eliminaria (y una comoda sin tiradores no se lee como comoda). Van en UN
# solo mesh SM_Comoda_Tiradores, asi la poda se los lleva todos o ninguno.
#
# PRESUPUESTO M166 §3.3: 10 SM_ / ~150 tris / 3 mats (ALTA <=16/<=6000/<=12).
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, caja, pata, join,
                             arena, iluminar, asentar, camara,
                             sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

PATA_LADO = 0.08
PATA_H = 0.14
Z_CUERPO_BASE = Z_APOYO + PATA_H                # 0.185
Z_CUERPO_TOP = Z_CUERPO_BASE + 0.62             # 0.805
Z_CAJONES = (0.285, 0.475, 0.665)
ALTO_CAJON = 0.17

# ---- 1) Patas ----
patas = []
for _sx in (-1, 1):
    for _sy in (-1, 1):
        patas.append(pata('SM_Comoda_Pata_%s%s' % ('P' if _sx < 0 else 'C',
                                                   'I' if _sy < 0 else 'D'),
                          M['madera_oscura'], PATA_LADO, PATA_H,
                          _sx * 0.39, _sy * 0.19))

# ---- 2) Cuerpo ----
cuerpo = caja('SM_Comoda_Cuerpo', M['madera_clara'], 0.86, 0.46, 0.62,
              0.0, 0.0, Z_CUERPO_BASE + 0.31)

# ---- 3) Cajones ----
cajones = [caja('SM_Comoda_Cajon_%d' % (i + 1), M['madera_clara'],
                0.78, 0.04, ALTO_CAJON, 0.0, +0.235, cz)
           for i, cz in enumerate(Z_CAJONES)]

# ---- 4) Tiradores: todos juntos (E-96) ----
tiradores = join('SM_Comoda_Tiradores', [
    caja('SM_Comoda_Tirador_%d' % (i + 1), M['bronce'], 0.20, 0.03, 0.03,
         0.0, +0.255, cz)
    for i, cz in enumerate(Z_CAJONES)
])

# ---- 5) Tablero ----
tablero = caja('SM_Comoda_Tablero', M['madera_oscura'], 0.94, 0.52, 0.05,
               0.0, 0.0, Z_CUERPO_TOP + 0.025)

todas = patas + [cuerpo] + cajones + [tiradores, tablero]
assert len(todas) == 10, 'esperaba 10 SM_, hay %d' % len(todas)

arena(radio=1.3)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(1.6, -1.5, 1.1), mira=(0.0, 0.0, 0.45))
sombrear_plano(todas)
guardar(escena, 'comoda')
