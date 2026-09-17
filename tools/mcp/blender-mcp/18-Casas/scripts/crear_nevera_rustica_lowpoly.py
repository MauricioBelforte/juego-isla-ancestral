# crear_nevera_rustica_lowpoly.py — Nevera rustica / pozo de conserva (M18)
#
# Item del checklist: "Nevera rustica de piedra/madera (pozo de conserva — el
# mundo NO tiene electricidad, M147; 'heladera' del usuario = nevera cozy)".
# Estaba [x] SIN existir (auditoria log 809). Se construye en el log 811.
#
# DECISIVO: no hay electricidad en la isla (M147). Una heladera a compresor
# seria un error de mundo. Se modela un POZO DE CONSERVA: cajon de piedra que
# guarda el frio, con tapa de madera y un bloque de hielo/nieve arriba que es
# lo que el jugador repone. Por eso el material 'hielo' existe en la paleta.
#
# COTAS (metros): 1.00 (X) x 0.85 (Y) x 1.185 de alto total.
#   patas    r 0.11, h 0.08     -> z 0.045..0.125  (4, piedra, 16 verts)
#   zocalo   1.00 x 0.85 x 0.08 -> z 0.125..0.205  (piedra)
#   cuerpo   0.92 x 0.78 x 0.80 -> z 0.205..1.005  (piedra)
#   tapa     1.04 x 0.88 x 0.06 -> z 1.005..1.065  (madera clara)
#   hielo    0.70 x 0.60 x 0.12 -> z 1.065..1.185  (hielo)
#   puerta   0.80 x 0.04 x 0.60 -> z 0.205..0.805  (madera oscura, y +0.40)
#   refuerzo 0.06 x 0.06 x 0.80 -> z 0.205..1.005  (2, join)
#   herrajes tirador + 2 bisagras                  (bronce, join)
#
# POR QUE 4 PATAS CILINDRICAS (dos fallos reales, este log):
#  v1 apoyo el zocalo directo en el piso -> asentar() la rechazo con
#     "apoyo puntual: 4 verts (E-50)": una caja aporta solo sus 4 vertices
#     inferiores y 4 < 8.
#  v2 uso 4 patas CAJA (16 verts) y paso ALTA y MEDIA, pero FALLO en BAJA:
#     el auditor dio toca=5. El decimate de BAJA (ratio 0.7) se come primero
#     los apoyos, porque las 4 patitas de 0.16 m son una fraccion minuscula de
#     la malla 'piedra' fusionada (patas + zocalo + cuerpo) y el simplificador
#     las considera detalle prescindible.
#  v3 las patas pasan a CILINDRO de 16 verts: 64 vertices de apoyo, el 84 % de
#     la malla. El decimate ya no puede llevarselas sin llevarse el mueble.
#
# REGLA GENERAL QUE QUEDA DE ESTO: en un asset cuyas patas compartan material
# con un cuerpo mucho mas grande, las patas tienen que ser CILINDROS (o tener
# muchos vertices), no cajas. Una caja de apoyo sobrevive a ALTA/MEDIA pero es
# candidata a desaparecer en BAJA.
#
# E-96 APLICADO DE ENTRADA: tirador y bisagras son las piezas con MENOS caras;
# el podador de BAJA se las lleva primero. Van unidas en SM_Nevera_Herrajes.
#
# PRESUPUESTO M166 §3.3: 7 SM_ / ~110 tris / 5 mats (ALTA <=16/<=6000/<=12).
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from mobiliario_util import (limpiar, paleta, caja, cilindro, join,
                             arena, iluminar, asentar, camara,
                             sombrear_plano, guardar, Z_APOYO)

escena = limpiar()
M = paleta()

PATA_R = 0.11
PATA_H = 0.08
Z_ZOCALO_BASE = Z_APOYO + PATA_H                # 0.125
Z_CUERPO_BASE = Z_ZOCALO_BASE + 0.08            # 0.205
Z_CUERPO_TOP = Z_CUERPO_BASE + 0.80             # 1.005

# ---- 1) Tacos de piedra: son los que tocan el piso (16 verts, E-50) ----
patas = []
for _sx in (-1, 1):
    for _sy in (-1, 1):
        patas.append(cilindro('SM_Nevera_Pata_%s%s' % ('P' if _sx < 0 else 'C',
                                                       'I' if _sy < 0 else 'D'),
                              M['piedra'], PATA_R, PATA_H,
                              _sx * 0.40, _sy * 0.33,
                              Z_APOYO + PATA_H / 2.0, verts=16))

# ---- 2) Cajon de piedra ----
zocalo = caja('SM_Nevera_Zocalo', M['piedra'], 1.00, 0.85, 0.08,
              0.0, 0.0, Z_ZOCALO_BASE + 0.04)
cuerpo = caja('SM_Nevera_Cuerpo', M['piedra'], 0.92, 0.78, 0.80,
              0.0, 0.0, Z_CUERPO_BASE + 0.40)
tapa = caja('SM_Nevera_Tapa', M['madera_clara'], 1.04, 0.88, 0.06,
            0.0, 0.0, Z_CUERPO_TOP + 0.03)
hielo = caja('SM_Nevera_Hielo', M['hielo'], 0.70, 0.60, 0.12,
             0.0, 0.0, Z_CUERPO_TOP + 0.06 + 0.06)

# ---- 3) Puerta de madera al frente (+Y) ----
puerta = caja('SM_Nevera_Puerta', M['madera_oscura'], 0.80, 0.04, 0.60,
              0.0, +0.40, Z_CUERPO_BASE + 0.30)

# ---- 4) Refuerzos de esquina (join: son 2 listones identicos) ----
refuerzos = join('SM_Nevera_Refuerzos', [
    caja('SM_Nevera_Refuerzo_I', M['madera_clara'], 0.06, 0.06, 0.80,
         -0.43, +0.38, Z_CUERPO_BASE + 0.40),
    caja('SM_Nevera_Refuerzo_D', M['madera_clara'], 0.06, 0.06, 0.80,
         +0.43, +0.38, Z_CUERPO_BASE + 0.40),
])

# ---- 5) Herrajes: tirador + bisagras en UN solo mesh (E-96) ----
herrajes = join('SM_Nevera_Herrajes', [
    caja('SM_Nevera_Tirador', M['bronce'], 0.16, 0.04, 0.035,
         +0.28, +0.425, Z_CUERPO_BASE + 0.30),
    caja('SM_Nevera_Bisagra_A', M['bronce'], 0.05, 0.06, 0.14,
         -0.34, +0.415, Z_CUERPO_BASE + 0.475),
    caja('SM_Nevera_Bisagra_B', M['bronce'], 0.05, 0.06, 0.14,
         -0.34, +0.415, Z_CUERPO_BASE + 0.125),
])

todas = patas + [zocalo, cuerpo, tapa, hielo, puerta, refuerzos, herrajes]
assert len(todas) == 11, 'esperaba 11 SM_, hay %d' % len(todas)

arena(radio=1.5)
iluminar(escena)
asentar(escena)
camara(escena, 'Cam', loc=(1.8, -1.7, 1.2), mira=(0.0, 0.0, 0.55))
sombrear_plano(todas)
guardar(escena, 'nevera_rustica')
