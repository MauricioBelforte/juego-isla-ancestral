# crear_alfombra_lowpoly.py — Alfombra redonda (M18)
#
# Item del checklist: "Alfombra redonda". Estaba [x] SIN existir
# (auditoria log 809). Se construye de verdad en el log 811.
#
# COTAS (metros): radio 1.60, espesor total 0.038.
#   disco 0  r 1.60, h 0.02 -> z 0.045..0.065  (tela roja)
#   disco 1  r 1.24, h 0.02 -> z 0.051..0.071  (tela crema)
#   disco 2  r 0.86, h 0.02 -> z 0.057..0.077  (paja)
#   disco 3  r 0.46, h 0.02 -> z 0.063..0.083  (lino)
#
# POR QUE DISCOS APILADOS Y NO UN SOLO CILINDRO: una alfombra de un color solo
# es un disco sin gracia; los anillos concentricos la leen como alfombra
# tejida. Cada anillo sube 0.006 respecto del anterior para que las caras
# superiores NO sean coplanarias (si lo fueran, hay z-fighting y ademas el
# clasificador por normal de E-99 las confunde).
#
# OJO CON EL APOYO: solo el disco 0 toca el piso (los demas arrancan en 0.051,
# 0.057 y 0.063). El auditor de apoyo filtra con tolerancia 0.005, asi que el
# salto de 0.006 esta elegido justamente para que NO cuenten como apoyo los de
# arriba: el apoyo real es el disco 0, que da 32 vertices y huella 3.20 m.
#
# PRESUPUESTO M166 §3.3: 4 SM_ / ~500 tris / 4 mats (ALTA <=16/<=6000/<=12;
# BAJA <=6 objetos y <=4 materiales -> entra justo).
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, cilindro,
                             arena, iluminar, asentar, camara,
                             sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

RADIOS = (1.60, 1.24, 0.86, 0.46)
COLORES = ('tela_roja', 'tela_crema', 'paja', 'lino')
SALTO = 0.006
ALTO = 0.02

discos = []
for i, (r, c) in enumerate(zip(RADIOS, COLORES)):
    # cz = Z_APOYO + i*SALTO + ALTO/2  -> base en Z_APOYO + i*SALTO
    discos.append(cilindro('SM_Alfombra_Anillo_%d' % i, M[c], r, ALTO,
                           0.0, 0.0, Z_APOYO + i * SALTO + ALTO / 2.0,
                           verts=32))

assert len(discos) == 4

arena(radio=2.4)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(2.6, -2.4, 1.8), mira=(0.0, 0.0, 0.10))
sombrear_plano(discos)
guardar(escena, 'alfombra')
