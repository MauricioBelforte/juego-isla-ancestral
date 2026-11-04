# crear_columna_rota_lowpoly.py — Kit "columna rota" (M25 Ruinas / Templos)
#
# Checklist: "Columna rota (2 variantes de altura)" — era de los pocos `[ ]`
# REALES del checklist de objetos Blender (medido 2026-11-04: 0 blends, 0 GLB
# con columna/dintel/bloque en M25). Diseno M25 03-Diseno.md:
#   pieza 17 `pilar_roto`  1x1x1.5  soporte, snap "arriba"
#   pieza 31 `fuste_columna`  fragmento horizontal de columna
# Este generador produce AMBAS alturas y el fragmento caido en un solo .blend
# por variante, para que las 6 capturas orbitales muestren el conjunto.
#
# Reglas aplicadas (ver GUIA-BLENDER / plantilla_asset.py):
#   E-12  Z_APOYO = 0.045 (arena top 0.05, E-67)
#   E-24  zmin_real() sobre VERTICES reales, nunca bound_box
#   E-50  >= 8 vertices tocando y huella > 0.30 m en X e Y
#   E-44  solo SM_* se exporta; Base_Arena / SOL / CAM_* se purgan
#   E-42  materiales contados POR CARAS (lo mide chk_asset.py)
#   E-68  caja()/scale = dimension FINAL, no la mitad
#   E-58  track_to_quat para orientar (no se usa aca: rotacion 1D exacta)
#
# Autoría 100 % headless: `blender -b --factory-startup --python <este>`.
# No requiere GUI ni socket 127.0.0.1:9876 (E-55 / E-56).
import bpy
import os
import sys
import math
from mathutils import Vector

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja, loft, piezas,
                             zmin_real, Z_APOYO)

MODULO = '25-Ruinas-Templos'
# (nombre del .blend, altura total H en metros)
VARIANTES = (
    ('columna_rota_baja', 1.50),   # pilar_roto 1x1x1.5 del diseno M25
    ('columna_rota_alta', 2.20),   # segunda altura pedida por el checklist
)
LADOS_FUSTE = 24
N_FLUTAS = 8
LADOS_CORONA = 16
R_FUSTE = 0.238
R_FRAGMENTO = R_FUSTE
ALTO_CORONA = 0.28   # corona de rotura: el diente mas profundo baja 0.24 m

# Perfil de rotura FIJO y determinista (16 valores, uno por vertice del anillo
# superior). Negativos = piedra arrancada. min=-0.24 > -ALTO_CORONA=-0.28,
# asi el corte NUNCA atraviesa el tope del fuste (z1 = H - ALTO_CORONA).
# Sin random a proposito: dos ejecuciones deben dar el mismo .blend (autoria
# headless reproducible). La primera version usaba una onda suave de +-0.07 m
# y el corte se leia como un cilindro limpio, no como piedra rota.
# v3: sin alternancia regular alto/bajo. La v2 producia una "corona"
# crenelada de aspecto demasiado simetrico; aca los desconchados van en
# racimos, que es como se lee una rotura de piedra.
DIENTES = (
    -0.02, -0.06, -0.21, -0.24, -0.11, -0.04, -0.17, -0.22,
    -0.09, -0.14, -0.01, -0.19, -0.23, -0.08, -0.05, -0.16,
)
assert len(DIENTES) == LADOS_CORONA
assert -ALTO_CORONA < min(DIENTES) < -0.20, 'corte demasiado superficial'

# Escombros en el suelo: (nombre, x, y, sx, sy, sz). sz es la altura FINAL;
# se centran en Z_APOYO + sz/2 y solo rotan sobre Z (no altera la cota minima).
ESCOMBROS = (
    ('SM_ColRota_Escombro_1', -0.46,  0.28, 0.15, 0.12, 0.10),
    ('SM_ColRota_Escombro_2', -0.30, -0.40, 0.11, 0.14, 0.08),
    ('SM_ColRota_Escombro_3',  0.36,  0.40, 0.13, 0.10, 0.12),
)

# Piezas que DEBEN apoyar en la arena (no vale el minimo del grupo: E-37/E-52).
APOYAN = ('SM_ColRota_Basa', 'SM_ColRota_Fragmento',
          'SM_ColRota_Fragmento_Banda') + tuple(e[0] for e in ESCOMBROS)


def cilindro(nombre, vertices, radio, profundo, loc, material, rot=None):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radio,
                                        depth=profundo, location=loc)
    o = bpy.context.object
    o.name = nombre
    if rot is not None:
        o.rotation_euler = rot
    o.data.materials.append(material)
    return o


def construir(nombre, H):
    escena = limpiar()

    MAT_piedra = mat('MAT_ColRota_Piedra',      (0.55, 0.53, 0.48))
    MAT_osc    = mat('MAT_ColRota_PiedraOsc',   (0.38, 0.36, 0.33))
    MAT_corte  = mat('MAT_ColRota_CorteFresco', (0.78, 0.75, 0.68))
    MAT_musgo  = mat('MAT_ColRota_Musgo',       (0.30, 0.44, 0.21))
    MAT_glifo  = mat('MAT_ColRota_Glifo',       (0.52, 0.47, 0.38))

    # --- 1) Basa circular: 12 vertices exactamente en Z_APOYO (guard E-50) ---
    cilindro('SM_ColRota_Basa', 12, 0.36, 0.16,
             (0.0, 0.0, Z_APOYO + 0.08), MAT_osc)

    # --- 2) Fuste con 8 flutas: `ondas` modula el radio, 0 objetos extra ---
    z0 = Z_APOYO + 0.16
    z1 = H - ALTO_CORONA
    assert z1 - z0 > 0.60, 'altura %.2f demasiado baja para el fuste' % H
    anillos = [
        (z0,        0.0, 0.0, 0.270, 0.270),
        (z0 + 0.05, 0.0, 0.0, 0.258, 0.258),
        (z1 - 0.08, 0.0, 0.0, R_FUSTE, R_FUSTE),
        (z1,        0.0, 0.0, R_FUSTE, R_FUSTE),
    ]
    loft('SM_ColRota_Fuste', anillos, MAT_piedra, lados=LADOS_FUSTE,
         ondas=(0.040, N_FLUTAS), tapar_abajo=False, tapar_arriba=True)

    # --- 3) Corona de rotura: anillo superior con vertices desplazados en Z ---
    # loft() deja: [0..15] anillo inferior, [16..31] anillo superior,
    # [32] centro de la tapa. Mover SOLO el anillo superior produce un corte
    # irregular de piedra (no un cilindro limpio) sin costo de objetos.
    corona = loft('SM_ColRota_Corona',
                  [(z1, 0.0, 0.0, 0.240, 0.240),
                   (H,  0.0, 0.0, 0.240, 0.240)],
                  MAT_corte, lados=LADOS_CORONA,
                  tapar_abajo=False, tapar_arriba=True)
    me = corona.data
    for i, d in enumerate(DIENTES):
        me.vertices[LADOS_CORONA + i].co.z = H + d
    # E-37 visual: el centro DEBE quedar por DEBAJO de TODOS los dientes.
    # En la v2 estaba en la media (H-0.12) y los triangulos de la tapa
    # asomaban por las muescas como esquirlas que parecian flotantes, con un
    # hueco oscuro. H-0.26 sigue 2 cm por encima de z1 = H-0.28.
    me.vertices[2 * LADOS_CORONA].co.z = H + min(DIENTES) - 0.02
    me.update()

    # --- 4) Fragmento caido (`fuste_columna`): eje en Y, apoya en la arena ---
    # Rot X = 90° pone un vertice exactamente abajo (a = -90°, i = 12 de 16).
    # El yaw de 18° es sobre Z: NO altera la cota minima.
    rot = (math.radians(90.0), 0.0, math.radians(18.0))
    cx, cy = 0.62, -0.30
    cilindro('SM_ColRota_Fragmento', 16, R_FRAGMENTO, 0.38,
             (cx, cy, Z_APOYO + R_FRAGMENTO), MAT_piedra, rot=rot)
    cilindro('SM_ColRota_Fragmento_Banda', 16, 0.240, 0.055,
             (cx, cy + 0.13, Z_APOYO + 0.240), MAT_osc, rot=rot)

    # --- 5) Detalles: musgo sobre la basa + glifos en el frente ---
    caja('SM_ColRota_Musgo_1', -0.20,  0.18, Z_APOYO + 0.165,
         0.13, 0.11, 0.02, MAT_musgo)
    caja('SM_ColRota_Musgo_2',  0.17, -0.14, Z_APOYO + 0.165,
         0.10, 0.09, 0.02, MAT_musgo)
    caja('SM_ColRota_Glifo_1', -0.10, -0.351, Z_APOYO + 0.085,
         0.075, 0.014, 0.075, MAT_glifo)
    caja('SM_ColRota_Glifo_2',  0.10, -0.351, Z_APOYO + 0.085,
         0.075, 0.014, 0.075, MAT_glifo)

    # --- 6) Escombros: 3 cantos sueltos, todos apoyados en Z_APOYO ---
    for nombre_e, x, y, sx, sy, sz in ESCOMBROS:
        caja(nombre_e, x, y, Z_APOYO + sz / 2.0, sx, sy, sz, MAT_corte,
             rot_euler=(0.0, 0.0, math.radians(17.0)))

    # --- Orden canonico: arena -> luz -> asentar -> camara -> flat -> guardar ---
    arena()
    iluminar(escena)
    bpy.context.view_layer.update()
    z_fin, toca, fp_x, fp_y = asentar(escena)

    ps = piezas(escena)
    assert len(ps) <= 16, 'excede presupuesto ALTA: %d SM_' % len(ps)
    # E-37/E-52: ademas del minimo del GRUPO, verificar CADA pieza que apoya.
    for o in ps:
        z = zmin_real(o)
        assert z >= Z_APOYO - 1e-4, '%s hunde %.4f < %.4f' % (o.name, z, Z_APOYO)
        if o.name in APOYAN:
            assert abs(z - Z_APOYO) < 1e-4, \
                '%s FLOTA: z_min %.4f (objetivo %.4f)' % (o.name, z, Z_APOYO)
        print('APOYO_PIEZA %-34s z_min=%.4f' % (o.name, z))

    # Guardia POSITIVA de altura: los dos .blend tienen EXACTAMENTE el mismo
    # tamanio en bytes (binario de floats de ancho fijo), asi que el tamanio
    # NO prueba que existan dos variantes. El vertice mas alto debe coincidir
    # con el diente menos profundo de ESTA altura H.
    z_max = max((o.matrix_world @ v.co).z for o in ps for v in o.data.vertices)
    esperado = H + max(DIENTES)
    assert abs(z_max - esperado) < 1e-4, \
        'altura no corresponde a la variante: z_max=%.4f esperado=%.4f' \
        % (z_max, esperado)
    print('ALTURA_REAL %s z_max=%.4f (H=%.2f)' % (nombre, z_max, H))

    # Guardia POSITIVA de la union fuste/corona. La corona NO apoya en el
    # suelo (su z_min es z1), asi que `z_min >= Z_APOYO` NO demuestra que no
    # flota: hay que medir que su anillo inferior coincide con el anillo
    # superior del fuste. Sin esto, un diente posterior visto por una muesca
    # puede confundirse con una esquirla suelta en la revision visual.
    fuste = next(o for o in ps if o.name == 'SM_ColRota_Fuste')
    corona_o = next(o for o in ps if o.name == 'SM_ColRota_Corona')
    tope_fuste = max((fuste.matrix_world @ v.co).z for v in fuste.data.vertices)
    base_corona = zmin_real(corona_o)
    assert abs(tope_fuste - z1) < 1e-4, 'tope del fuste no esta en z1'
    assert abs(base_corona - z1) < 1e-4, 'base de la corona no esta en z1'
    assert abs(tope_fuste - base_corona) < 1e-4, 'AIRE entre fuste y corona'
    print('UNION_FUSTE_CORONA z=%.4f sin aire' % z1)

    camara(escena, 'CAM_ColRota', loc=(2.30, -2.90, 1.55),
           mira=(0.15, -0.05, H * 0.46))
    shade_flat(escena)
    ruta = guardar(escena, MODULO, nombre)
    print('VARIANTE %s H=%.2f | SM_=%d | z_min=%.4f | toca=%d | fp=%.2fx%.2f'
          % (nombre, H, len(ps), z_fin, toca, fp_x, fp_y))
    return ruta


def main():
    for nombre, H in VARIANTES:
        construir(nombre, H)
    print('LISTO — %d variantes de columna rota' % len(VARIANTES))


if __name__ == '__main__':
    main()
