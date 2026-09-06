# crear_bowl_barro_lowpoly.py — Bowl / plato de barro (M16-Crafting / M14)
# Checklist M16: "Bowl/plato de barro"
#
# DISENO: cuenco de barro de boca ancha (Ø 0.208) y poca altura (0.094), con
# pie marcado, dos franjas pintadas en la pared exterior e interior vidriado.
#
# LA DIFICULTAD REAL DE UN BOWL: es una pieza HUECA. El perfil SUBE por la
# pared exterior y VUELVE A BAJAR por la interior, asi que `loft()` no sirve
# (su guard de E-77 exige z crecientes). La otra salida — dos lofts, exterior e
# interior, mas un disco tapando el borde — deja un bloque macizo: el disco tapa
# la boca y se pierde el cuenco. De ahi `revolucion()` en plantilla_asset:
# acepta perfiles no monotonos y, como el winding de las caras se invierte solo
# cuando el perfil baja, la pared exterior mira hacia afuera y la interior hacia
# la cavidad con la misma linea de codigo y sin flip_normals.
#
# UNA SOLA PIEZA CON 3 MATERIALES (barro / vidriado / franja) asignados por
# TRAMO del perfil: las franjas pintadas no cuestan ni un triangulo.
#
# E-91: objeto PEQUEÑO (0.208 m). `asentar()` exigiria min(fp) > 0.30. Se usa
# `asentar_herramienta()`.
import sys
import os

DIR_MOD = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
DIR_REU = os.path.join(DIR_MOD, 'scripts-reutilizables')
if DIR_REU not in sys.path:
    sys.path.insert(0, DIR_REU)

import bpy                                                     # noqa: E402
import bmesh                                                   # noqa: E402
from plantilla_asset import (limpiar, mat, arena, revolucion, piezas,  # noqa: E402
                             zmin_real)
from herramienta_util import cerrar_herramienta                # noqa: E402

escena = limpiar()

# ---------- Materiales ----------
MAT_barro = mat('MAT_Bowl_Barro', (0.66, 0.34, 0.20), rough=0.92)
MAT_vidrio = mat('MAT_Bowl_Vidriado', (0.82, 0.62, 0.44), rough=0.22, spec=0.55)
MAT_franja = mat('MAT_Bowl_Franja', (0.30, 0.16, 0.12), rough=0.85)

arena(radio=1.2, profundo=0.22)

# ---------- Perfil (r, z): fondo -> pie -> pared EXT -> labio -> pared INT -> ----------
PERFIL = [
    (0.000, 0.000),   # 0  apice: centro del fondo exterior
    (0.055, 0.000),   # 1  borde del pie (ESTE es el apoyo: Ø 0.11)
    (0.064, 0.014),   # 2  pie
    (0.072, 0.028),   # 3
    (0.082, 0.042),   # 4
    (0.092, 0.058),   # 5
    (0.098, 0.070),   # 6
    (0.104, 0.088),   # 7  borde exterior del labio (maximo radio)
    (0.099, 0.094),   # 8  canto superior
    (0.086, 0.055),   # 9  pared interior alta
    (0.058, 0.022),   # 10 pared interior baja
    (0.000, 0.018),   # 11 apice: centro del fondo interior (cierra la cavidad)
]
# Material de CADA TRAMO (0=barro, 1=vidriado interior, 2=franja pintada).
IDX_MAT = [0, 0, 2, 0, 2, 0, 0, 0, 1, 1, 1]

bowl = revolucion('SM_Bowl_Cuerpo', PERFIL,
                  materiales=[MAT_barro, MAT_vidrio, MAT_franja],
                  lados=14, idx_mat=IDX_MAT)

# ---------- Verificacion de orientacion por VOLUMEN FIRMADO ----------
# El perfil arranca y termina en el eje (r=0), asi que la superficie revolucionada
# es CERRADA: encierra el volumen de barro. Por el teorema de la divergencia,
# V = (1/6) * suma( (v0 x v1) . v2 ) sobre los triangulos da > 0 si y solo si
# las normales apuntan hacia AFUERA. Es la unica forma barata de detectar un
# winding invertido (bowl "del reves": se ve el interior y no el exterior)
# sin mirar una captura. Si este assert salta, el perfil esta recorrido al reves.
bm = bmesh.new()
bm.from_mesh(bowl.data)
bm.faces.ensure_lookup_table()
vol = 0.0
for f in bm.faces:
    vs = [v.co for v in f.verts]
    for k in range(1, len(vs) - 1):
        a, b, c = vs[0], vs[k], vs[k + 1]
        vol += (a.x * (b.y * c.z - b.z * c.y)
                - a.y * (b.x * c.z - b.z * c.x)
                + a.z * (b.x * c.y - b.y * c.x))
vol /= 6.0
bm.free()
print('BOWL volumen firmado: %+.6f m3 (%.1f cm3) — debe ser POSITIVO'
      % (vol, vol * 1e6))
assert vol > 0, ('volumen firmado %.6f <= 0: las normales apuntan hacia ADENTRO. '
                 'El perfil esta recorrido al reves (invertir PERFIL/IDX_MAT).' % vol)

hist = {}
for p in bowl.data.polygons:
    hist[p.material_index] = hist.get(p.material_index, 0) + 1
print('BOWL caras por material: %r' % sorted(hist.items()))
assert len(hist) == 3, 'el bowl no usa las 3 zonas de material: %r' % hist

# ---------- Cierre ----------
cerrar_herramienta(escena, '16-Crafting', 'bowl_barro',
                   loc_cam=(-0.42, -0.54, 0.24), mira_cam=(0.0, 0.0, 0.05))

for o in sorted(piezas(escena), key=lambda p: p.name):
    print('   %-22s z %.4f' % (o.name, zmin_real(o)))
print('BOWL DE BARRO OK — %d SM_' % len(piezas(escena)))
