# crear_lampara_pie_lowpoly.py — Lampara de pie / farol de interior (M18)
#
# Item del checklist: "Lampara de pie / farol de interior — interactivo:
# encender". Estaba [x] SIN existir (auditoria log 809). Se construye en 811.
#
# COTAS (metros): base r 0.22; alto total 1.595.
#   base      r 0.22, h 0.05        -> z 0.045..0.095   (bronce)
#   mastil    r 0.035, h 1.10       -> z 0.095..1.195   (bronce)
#   aro       r 0.11, h 0.03        -> z 1.195..1.225   (bronce)
#   vela      r 0.045, h 0.14       -> z 1.225..1.365   (cera)
#   llama     r 0.022, h 0.07       -> z 1.365..1.435   (emisiva)
#   tulipa    cono r 0.17 -> 0.11, h 0.34 -> z 1.225..1.565  (vidrio)
#   tapa      r 0.125, h 0.03       -> z 1.565..1.595   (bronce)
#
# SIN ELECTRICIDAD (M147): no hay bombita ni cable. La luz la da una VELA
# dentro de la tulipa. Por eso la tulipa es mas alta que la llama: la encierra.
#
# E-96 (mismo caso que el velador, log 810): la llama es la pieza con menos
# caras y el podador de BAJA se la comia, dejando una lampara apagada. Vela y
# llama se unen en SM_Lampara_Luz con DOS slots de material (cera + llama).
#
# PRESUPUESTO M166 §3.3: 6 SM_ / ~150 tris / 4 mats (ALTA <=16/<=6000/<=12).
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, cilindro, cono, join,
                             arena, iluminar, asentar, camara,
                             sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

Z_BASE_TOP = Z_APOYO + 0.05                     # 0.095
Z_MASTIL_TOP = Z_BASE_TOP + 1.10                # 1.195
Z_ARO_TOP = Z_MASTIL_TOP + 0.03                 # 1.225
VELA_H = 0.14
LLAMA_H = 0.07

# ---- 1) Pie + mastil + aro portalamparas ----
base = cilindro('SM_Lampara_Base', M['bronce'], 0.22, 0.05,
                0.0, 0.0, Z_APOYO + 0.025, verts=16)
mastil = cilindro('SM_Lampara_Mastil', M['bronce'], 0.035, 1.10,
                  0.0, 0.0, Z_BASE_TOP + 0.55, verts=10)
aro = cilindro('SM_Lampara_Aro', M['bronce'], 0.11, 0.03,
               0.0, 0.0, Z_MASTIL_TOP + 0.015, verts=12)

# ---- 2) Vela + llama en UN mesh (E-96) ----
vela = cilindro('SM_Lampara_Vela', M['cera'], 0.045, VELA_H,
                0.0, 0.0, Z_ARO_TOP + VELA_H / 2.0, verts=10)
llama = cilindro('SM_Lampara_Llama', M['llama'], 0.022, LLAMA_H,
                 0.0, 0.0, Z_ARO_TOP + VELA_H + LLAMA_H / 2.0, verts=8)
luz = join('SM_Lampara_Luz', [vela, llama])

# ---- 3) Tulipa de vidrio + tapa ----
# cono(): cz es el CENTRO -> base en 1.225, punta en 1.565 (E-100).
tulipa = cono('SM_Lampara_Tulipa', M['vidrio'], 0.17, 0.11, 0.34,
              0.0, 0.0, Z_ARO_TOP + 0.17, verts=14)
tapa = cilindro('SM_Lampara_Tapa', M['bronce'], 0.125, 0.03,
                0.0, 0.0, Z_ARO_TOP + 0.34 + 0.015, verts=12)

todas = [base, mastil, aro, luz, tulipa, tapa]
assert len(todas) == 6, 'esperaba 6 SM_, hay %d' % len(todas)

arena(radio=1.2)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(1.5, -1.4, 1.6), mira=(0.0, 0.0, 0.85))
sombrear_plano(todas)
guardar(escena, 'lampara_pie')
