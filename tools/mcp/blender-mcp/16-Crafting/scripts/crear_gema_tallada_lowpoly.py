# crear_gema_tallada_lowpoly.py — Gema tallada (M16-Crafting / M14-Inventario)
# Checklist M16: "Gema tallada"
#
# DISENO: talla escalonada (step cut) de 6 anillos, seccion OCTOGONAL (lados=8).
#   - Pabellon (abajo): del culete truncado al filetin.
#   - Filetin (girdle): banda vertical de 2.3 cm, la "cintura" de la gema.
#   - Corona + tabla (arriba): escalon que se cierra en la tabla plana.
# El culete esta TRUNCADO a proposito: un pabellon que termina en punta
# apoyaria sobre un solo vertice y violaria la regla de no flotar (E-50/E-91).
# Con la truncada la gema apoya sobre una cara plana de 15 cm de diametro.
#
# MATERIAL POR ZONA (1 objeto, 3 materiales, 0 triangulos extra):
#   Se asigna `material_index` por la altura del centro de cada cara, no por
#   piezas separadas. Pabellon oscuro / filetin medio / corona clara: el
#   degradado de valor es lo que hace que una gema de 96 tris lea como tallada
#   y no como un octaedro de plastico.
#
# E-91: es un objeto PEQUEÑO (0.30 m). `plantilla_asset.asentar()` impone
# min(fp) > 0.30 y rechazaria una gema 2 veces mas chica que su propia huella
# minima. Se usa `asentar_herramienta()` (toca>=8, min(fp)>=0.02,
# max(fp) >= 0.45 * L), que es el guard correcto para piezas chicas.
import sys
import os

DIR_MOD = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
DIR_REU = os.path.join(DIR_MOD, 'scripts-reutilizables')
if DIR_REU not in sys.path:
    sys.path.insert(0, DIR_REU)

import bpy                                                     # noqa: E402
from plantilla_asset import limpiar, mat, arena, loft, piezas, zmin_real  # noqa: E402
from herramienta_util import cerrar_herramienta                # noqa: E402

escena = limpiar()

# ---------- Materiales ----------
# Tonos violeta/amatista. Emision suave (0.22) para que lea como gema
# "ancestral" sin llegar a ser una lampara.
MAT_pabellon = mat('MAT_Gema_Pabellon', (0.28, 0.13, 0.46), rough=0.10,
                   spec=0.90, emisivo=((0.42, 0.20, 0.70), 0.16))
MAT_filetin = mat('MAT_Gema_Filetin', (0.44, 0.24, 0.66), rough=0.08,
                  spec=0.95, emisivo=((0.58, 0.32, 0.88), 0.22))
MAT_corona = mat('MAT_Gema_Corona', (0.62, 0.42, 0.85), rough=0.06,
                 spec=1.00, emisivo=((0.76, 0.58, 0.98), 0.30))

arena(radio=1.2, profundo=0.22)

# ---------- Geometria ----------
# Anillos (z, cx, cy, rx, ry) de ABAJO hacia ARRIBA (E-77: Z primero).
ANILLOS = [
    (0.000, 0.0, 0.0, 0.075, 0.075),   # culete truncado -> cara de apoyo Ø 0.15
    (0.050, 0.0, 0.0, 0.113, 0.113),   # escalon del pabellon
    (0.095, 0.0, 0.0, 0.150, 0.150),   # filetin (base)
    (0.118, 0.0, 0.0, 0.150, 0.150),   # filetin (canto superior)
    (0.168, 0.0, 0.0, 0.118, 0.118),   # escalon de la corona
    (0.225, 0.0, 0.0, 0.098, 0.098),   # tabla
]
Z_FILETIN_LO = 0.095
Z_FILETIN_HI = 0.118

gema = loft('SM_Gema_Cuerpo', ANILLOS, material=MAT_pabellon, lados=8,
            tapar_arriba=True, tapar_abajo=True)

# Los otros 2 materiales: append, NUNCA clear() (E-83 resetea material_index).
gema.data.materials.append(MAT_filetin)
gema.data.materials.append(MAT_corona)

# Asignacion por altura del centro de la cara.
for p in gema.data.polygons:
    zc = p.center.z
    if zc < Z_FILETIN_LO:
        p.material_index = 0        # pabellon
    elif zc < Z_FILETIN_HI:
        p.material_index = 1        # filetin
    else:
        p.material_index = 2        # corona + tabla

hist = {}
for p in gema.data.polygons:
    hist[p.material_index] = hist.get(p.material_index, 0) + 1
print('GEMA materiales por zona: %r' % sorted(hist.items()))
assert len(hist) == 3, 'la gema no usa las 3 zonas de material: %r' % hist

# ---------- Cierre: asentar (E-91) + luz + camara + flat + auditar + guardar ----------
cerrar_herramienta(escena, '16-Crafting', 'gema_tallada',
                   loc_cam=(-0.55, -0.72, 0.30), mira_cam=(0.0, 0.0, 0.11))

for o in sorted(piezas(escena), key=lambda p: p.name):
    print('   %-22s z %.4f' % (o.name, zmin_real(o)))
print('GEMA TALLADA OK — %d SM_' % len(piezas(escena)))
