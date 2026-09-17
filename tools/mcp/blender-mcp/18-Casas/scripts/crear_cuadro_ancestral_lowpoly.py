# crear_cuadro_ancestral_lowpoly.py — Cuadro / mascara ancestral de pared (M18)
#
# Item del checklist: "Cuadro / mascara ancestral de pared — interactivo:
# mirar". Estaba [x] SIN existir (auditoria log 809). Se construye en el 811.
#
# COTAS (metros): 0.70 (X) x 0.34 (Y) x 1.23 de alto.
#   peanas    r 0.17, h 0.05     -> z 0.045..0.095  (2, x +-0.21, 16 verts)
#   marco     0.70 x 0.06 x 0.90 -> z 0.095..0.995   (plano XY, mira +Y)
#   lamina    0.58 x 0.02 x 0.78 -> y +0.02, z 0.185..0.965
#   cara      0.30 x 0.04 x 0.38 -> y +0.045, cz 0.62
#   rostro    ojos + nariz + boca (join, 2 materiales)
#   penacho   3 plumas (join, tela roja) -> z 0.95..1.23
#
# ES UN OBJETO DE PARED: en el juego va colgado, pero para las capturas
# orbitales (§24 anti-flotantes) necesita apoyar en el piso, asi que lleva
# peanas. Ellas garantizan huella 0.64 x 0.36 (> 0.30, E-50): sin ellas el
# marco de 0.06 de canto daria huella 0.06 y el auditor lo rechazaria.
#
# POR QUE DOS PEANAS CILINDRICAS (dos fallos reales, este log):
#  v1 apoyo una sola base caja -> asentar() la rechazo: "apoyo puntual: 4
#     verts (E-50)". Una caja aporta unicamente sus 4 vertices inferiores.
#  v2 uso 2 peanas CAJA (8 verts) y paso ALTA y MEDIA, pero FALLO en BAJA con
#     toca=2 y huella 0.24: el decimate se comio las peanas. Mismo mecanismo
#     que en la nevera de este log — ver alla la regla general.
#  v3 las peanas pasan a CILINDRO de 16 verts: 32 vertices de apoyo.
#
# El radio 0.17 no es estetico: con r 0.15 la huella en Y daba 0.30 justo y el
# guard exige > 0.30 ESTRICTO. Con 0.17 da 0.34 y deja margen para el decimate.
#
# E-96: ojos, nariz y boca son las piezas mas chicas -> SM_Cuadro_Rostro las
# agrupa. Van con DOS slots (barro la nariz, madera oscura ojos y boca).
#
# PRESUPUESTO M166 §3.3: 6 SM_ / ~90 tris / 4 mats (ALTA <=16/<=6000/<=12).
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, caja, cilindro, join,
                             arena, iluminar, asentar, camara,
                             sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

Z_PIE_TOP = Z_APOYO + 0.05                      # 0.095
Z_MARCO_TOP = Z_PIE_TOP + 0.90                  # 0.995

# ---- 1) Peanas: dan la huella y evitan que el cuadro "flote" en la captura.
# Dos (no una) porque una sola caja aporta solo 4 vertices de apoyo (E-50).
peanas = [cilindro('SM_Cuadro_Peana_%s' % ('I' if s < 0 else 'D'),
                   M['madera_oscura'], 0.17, 0.05,
                   s * 0.21, 0.0, Z_APOYO + 0.025, verts=16)
          for s in (-1, 1)]

# ---- 2) Marco + lamina del fondo ----
marco = caja('SM_Cuadro_Marco', M['madera_oscura'], 0.70, 0.06, 0.90,
             0.0, 0.0, Z_PIE_TOP + 0.45)
lamina = caja('SM_Cuadro_Lamina', M['paja'], 0.58, 0.02, 0.78,
              0.0, +0.02, Z_PIE_TOP + 0.45)

# ---- 3) Mascara: cara + rasgos ----
cara = caja('SM_Cuadro_Cara', M['barro'], 0.30, 0.04, 0.38,
            0.0, +0.045, 0.62)
rostro = join('SM_Cuadro_Rostro', [
    caja('SM_Cuadro_Ojo_I', M['madera_oscura'], 0.08, 0.03, 0.05,
         -0.07, +0.075, 0.70),
    caja('SM_Cuadro_Ojo_D', M['madera_oscura'], 0.08, 0.03, 0.05,
         +0.07, +0.075, 0.70),
    caja('SM_Cuadro_Nariz', M['barro'], 0.05, 0.04, 0.12,
         0.0, +0.080, 0.635),
    caja('SM_Cuadro_Boca', M['madera_oscura'], 0.16, 0.03, 0.05,
         0.0, +0.075, 0.545),
])

# ---- 4) Penacho de plumas (join) ----
# Las plumas arrancan en 0.95, por DEBAJO del tope del marco (0.995), para que
# no quede aire entre penacho y marco.
penacho = join('SM_Cuadro_Penacho', [
    caja('SM_Cuadro_Pluma_I', M['tela_roja'], 0.05, 0.03, 0.22,
         -0.10, 0.0, 1.06),
    caja('SM_Cuadro_Pluma_C', M['tela_roja'], 0.05, 0.03, 0.26,
         0.00, 0.0, 1.10),
    caja('SM_Cuadro_Pluma_D', M['tela_roja'], 0.05, 0.03, 0.22,
         +0.10, 0.0, 1.06),
])

todas = peanas + [marco, lamina, cara, rostro, penacho]
assert len(todas) == 7, 'esperaba 7 SM_, hay %d' % len(todas)

arena(radio=1.2)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(1.3, -1.3, 1.2), mira=(0.0, 0.0, 0.60))
sombrear_plano(todas)
guardar(escena, 'cuadro_ancestral')
