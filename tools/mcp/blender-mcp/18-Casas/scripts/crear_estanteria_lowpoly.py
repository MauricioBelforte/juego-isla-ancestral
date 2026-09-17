# crear_estanteria_lowpoly.py — Estanteria de pared con libros (M18)
#
# Item del checklist: "Estanteria de pared (con libros) — interactivo:
# almacenar". Estaba [x] SIN existir (auditoria log 809). Se construye en 811.
#
# COTAS (metros): 1.00 (X) x 0.34 (Y) x 1.645 de alto.
#   montantes 0.06 x 0.34 x 1.60 -> z 0.045..1.645  (x +-0.47)
#   trasera   0.94 x 0.02 x 1.52 -> z 0.085..1.605  (y -0.15)
#   baldas    0.94 x 0.32 x 0.04 -> cz 0.15 / 0.55 / 0.95 / 1.35  (y +0.01)
#   libros    lotes sobre las baldas 2, 3 y 4
#
# POR QUE 0.34 DE FONDO Y NO 0.30: el auditor de apoyo (auditar_mobiliario.py)
# exige min(huella) > 0.30 en forma ESTRICTA. Con 0.30 daba exacto y fallaba.
# Se deja 0.34 para que la huella sea 0.34 y no quede al borde.
#
# E-96: cada lote de libros es un join de 4 cajas de colores distintos. Sueltos
# serian 12 piezas minusculas que el podador de BAJA se lleva de a una.
#
# PRESUPUESTO M166 §3.3: 10 SM_ / ~200 tris / 5 mats (ALTA <=16/<=6000/<=12).
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, caja, join,
                             arena, iluminar, asentar, camara,
                             sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

FONDO = 0.34
ALTO = 1.60
Z_MONTANTE = Z_APOYO + ALTO / 2.0                # 0.845

# ---- 1) Estructura: montantes + trasera + baldas ----
montantes = [caja('SM_Estanteria_Montante_%s' % ('I' if s < 0 else 'D'),
                  M['madera_oscura'], 0.06, FONDO, ALTO,
                  s * 0.47, 0.0, Z_MONTANTE)
             for s in (-1, 1)]
trasera = caja('SM_Estanteria_Trasera', M['madera_clara'], 0.94, 0.02, 1.52,
               0.0, -0.15, Z_MONTANTE)
Z_BALDAS = (0.15, 0.55, 0.95, 1.35)
baldas = [caja('SM_Estanteria_Balda_%d' % (i + 1), M['madera_oscura'],
               0.94, 0.32, 0.04, 0.0, +0.01, cz)
          for i, cz in enumerate(Z_BALDAS)]

# ---- 2) Lotes de libros: 3 baldas ocupadas, 4 volumenes cada una ----
def lote(idx, cz_balda, colores):
    """4 libros parados + 1 apilado, apoyados sobre el tope de la balda."""
    top = cz_balda + 0.02
    mats = [M[c] for c in colores]
    piezas = []
    xs = (-0.30, -0.22, -0.14, +0.10)
    for i, x in enumerate(xs):
        h = 0.26 if i % 2 == 0 else 0.23
        piezas.append(caja('L_%d_%d' % (idx, i), mats[i % len(mats)],
                           0.07, 0.24, h, x, +0.05, top + h / 2.0))
    # Uno apoyado de plano, para que el lote no parezca un peine perfecto
    piezas.append(caja('L_%d_apo' % idx, mats[0], 0.22, 0.20, 0.05,
                       +0.26, +0.05, top + 0.025))
    return join('SM_Estanteria_Libros_%d' % idx, piezas)


libros = [
    lote(1, Z_BALDAS[1], ('tela_roja', 'lino', 'paja')),
    lote(2, Z_BALDAS[2], ('paja', 'tela_roja', 'madera_clara')),
    lote(3, Z_BALDAS[3], ('lino', 'madera_clara', 'tela_roja')),
]

todas = montantes + [trasera] + baldas + libros
assert len(todas) == 10, 'esperaba 10 SM_, hay %d' % len(todas)

arena(radio=1.4)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(1.8, -1.7, 1.5), mira=(0.0, 0.0, 0.80))
sombrear_plano(todas)
guardar(escena, 'estanteria')
