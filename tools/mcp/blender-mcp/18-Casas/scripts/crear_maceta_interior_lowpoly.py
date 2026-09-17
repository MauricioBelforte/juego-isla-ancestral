# crear_maceta_interior_lowpoly.py — Maceta con planta de interior (M18)
#
# Item del checklist: "Maceta con planta interior — interactivo: regar".
# Estaba [x] SIN existir (auditoria log 809). Se construye en el log 811.
#
# COTAS (metros): base r 0.18 -> borde r 0.27; alto total ~0.95.
#   maceta  cono r 0.18 -> 0.25, h 0.32 -> z 0.045..0.365  (barro)
#   borde   r 0.27, h 0.04                -> z 0.365..0.405  (barro)
#   tierra  r 0.235, h 0.03               -> z 0.335..0.365  (tierra)
#   tallo   r 0.022, h 0.20               -> z 0.365..0.565  (verde)
#   follaje 5 hojas arqueadas (join)      -> base z 0.48
#
# POR QUE EL RADIO DE BASE ES 0.18 Y NO MAS CHICO: el auditor de apoyo exige
# huella > 0.30 en forma estricta. Con r 0.15 daba 0.30 justo y FALLABA.
#
# HOJAS: no son cajas planas. Se usa hoja_util.hoja_plana_arqueada(), que
# barre un perfil a lo largo de X con arco y caida, y devuelve un solido
# CERRADO (volumen > 0, E-92) para no ensuciar el diagnostico de normales.
# Ese modulo no existia en disco aunque la memoria del proyecto lo daba por
# creado; se creo en este mismo log (ver hoja_util.py).
#
# E-96: las 5 hojas sueltas serian presa facil del podador de BAJA. Se unen en
# SM_Maceta_Follaje: la poda se lleva el follaje entero o nada.
#
# PRESUPUESTO M166 §3.3: 5 SM_ / ~400 tris / 3 mats (ALTA <=16/<=6000/<=12).
import sys
import os
import math
_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _HERE)
# hoja_util vive en scripts-reutilizables, un nivel arriba de 18-Casas/scripts
sys.path.insert(0, os.path.join(_HERE, '..', '..', 'scripts-reutilizables'))

from mobiliario_util import (limpiar, paleta, cilindro, cono, join,
                             arena, iluminar, asentar, camara,
                             sombrear_plano, guardar, Z_APOYO)
from hoja_util import hoja_plana_arqueada, vol_firmado

escena = limpiar()
M = paleta()

R_BASE = 0.18
H_MACETA = 0.32
Z_MACETA_TOP = Z_APOYO + H_MACETA                # 0.365
H_TALLO = 0.20
Z_TALLO_TOP = Z_MACETA_TOP + H_TALLO             # 0.565

# ---- 1) Maceta: tronco de cono (base mas chica que la boca) + borde ----
maceta = cono('SM_Maceta_Cuerpo', M['barro'], R_BASE, 0.25, H_MACETA,
              0.0, 0.0, Z_APOYO + H_MACETA / 2.0, verts=14)
borde = cilindro('SM_Maceta_Borde', M['barro'], 0.27, 0.04,
                 0.0, 0.0, Z_MACETA_TOP + 0.02, verts=14)
# La tierra va HUNDIDA respecto del borde: es lo que se ve al mirar de arriba.
tierra = cilindro('SM_Maceta_Tierra', M['tierra'], 0.235, 0.03,
                  0.0, 0.0, Z_MACETA_TOP - 0.015, verts=12)

# ---- 2) Tallo ----
tallo = cilindro('SM_Maceta_Tallo', M['verde_hoja'], 0.022, H_TALLO,
                 0.0, 0.0, Z_MACETA_TOP + H_TALLO / 2.0, verts=8)

# ---- 3) Follaje: 5 hojas repartidas en 360°, inclinadas hacia arriba ----
# rot = (0, -0.60, azimut): primero Ry(-0.60) inclina la hoja 34° hacia ARRIBA
# (Ry negativo manda +X a +Z), despues Rz reparte en radial. Orden XYZ.
HOJAS = 5
hojas = []
for i in range(HOJAS):
    az = 2.0 * math.pi * i / HOJAS
    largo = 0.30 + 0.03 * (i % 2)
    h = hoja_plana_arqueada('SM_Maceta_Hoja_%d' % i, M['verde_hoja'],
                            largo=largo, ancho=0.11, arco=0.15,
                            grosor=0.006, seg=7,
                            loc=(0.0, 0.0, 0.48),
                            rot=(0.0, -0.60, az))
    hojas.append(h)
follaje = join('SM_Maceta_Follaje', hojas)
# Una hoja suelta daria volumen propio; el join debe conservarlo (E-92).
assert vol_firmado(follaje) > 0, 'follaje con normales invertidas'

todas = [maceta, borde, tierra, tallo, follaje]
assert len(todas) == 5, 'esperaba 5 SM_, hay %d' % len(todas)

arena(radio=1.1)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(1.1, -1.1, 1.0), mira=(0.0, 0.0, 0.45))
sombrear_plano(todas)
guardar(escena, 'maceta_interior')
