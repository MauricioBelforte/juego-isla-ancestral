# crear_cana_pescar_lowpoly.py — Caña de pescar en soporte de playa (M35 / L37)
#
# Checklist `CHECKLIST-OBJETOS-BLENDER.md` L224,
#   `02-Backlog-Pendientes-Assets.md` L37 y
#   `DOCUMENTACION/TAREAS-POR-MODELO/HY4/35-Mineria/checklist.md`:
#   "Cana de pescar" seguia `[ ]`.
# Medido 2026-11-08 22:32 -0300: 0 GLB, 0 generador y 0 `.blend` con
#   `cana_pescar`. Los 6 GLB que matchean `cana` son `33-Agricultura_canaveral`
#   y `50-Vegetacion_canas_bambu` (azucar / bambu), NO una cana de pescar.
#
# ===========================================================================
# HUECO DE SPEC (publicado en el canal 48, NO rellenado en silencio)
# ===========================================================================
# `grep -rni "cania|cana de pescar|caña|fishing" DOCUMENTACION/35-Mineria/`
#   da 0 resultados: M35 documenta mineria, NO define este prop. TODAS las
#   cotas, silueta y materiales de abajo son DECISION DE AUTORIA documentada,
#   NUNCA una cita de spec inexistente.
#
#   1 voxel = 1.00 m ........ convencion del proyecto (M25, actas 19/25/26/27).
#   Z_APOYO = 0.045 ......... E-12 (arena top 0.05, E-67).
#   SOPORTE DE PLAYA ........ decision de AUTORIA: una cana suelta tumbada
#                              tendria huella ~1.60 x 0.06 y FALLARIA E-50
#                              (min(fp_x, fp_y) > 0.30, min_toca >= 8).
#                              Se modela la cana HINCADA en un soporte de 3
#                              rieles de 0.36 x 0.08: huella 0.36 x 0.34 y
#                              12 vertices apoyados. Es un prop de punto de
#                              pesca, coherente con una isla cozy, NO un item
#                              de inventario ni una escena integrada.
#   ALTURA TOTAL = 1.695 m .. mango 0.24 + 3 tramos telescopicos
#                              (0.50 + 0.45 + 0.40) sobre la basa.
#   SECCION CUADRADA ........ 0.060 / 0.044 / 0.028 m: estetica voxel del
#                              juego y, sobre todo, TODA la geometria queda
#                              en PLANOS AXIS-ALIGNED. Eso permite una guardia
#                              positiva por NIVELES DE COORDENADA en el BIN
#                              del GLB (misma familia que B18).
#
# ===========================================================================
# PRESUPUESTO M166 Y DISENO DE LOS 3 LOD (MEDIDO ANTES DE PUBLICAR)
# ===========================================================================
#   ALTA  = 10 objetos / 6 materiales: 4 criticas `_NOFUNDIR` + 6 detalles.
#   MEDIA =  7 objetos / 6 materiales: los 6 detalles se fusionan por lista
#            de material en 3 grupos (merge LOSSLESS, mismos tris).
#   BAJA  =  4 objetos / 4 materiales: la FASE 0 de `generar_variante.py`
#            PODA los 6 detalles porque CADA UNO tiene volumen_bbox < 1e-4,
#            y al no quedar NINGUN objeto no-critico el DECIMATE actua sobre
#            0 mallas. LOD REAL por poda deliberada, SIN deformacion.
#
# LECCION APLICADA DE B18 (acta 28): el DECIMATE sobre cajas disjuntas mueve
#   vertices FUERA de los planos autorizados (12 defectos en recto, 10 en
#   esquina), invisible en el render y NO detectado por `chk_asset.py`, que
#   mide COSTE, no FORMA. Aca se evita por disenio: 0 mallas decimadas.
#   Los 6 detalles se dejan como objetos SUELTOS y pequenos a proposito para
#   que la poda sea el LOD. No se unen en ALTA.
#
# ZONA VACIA (guardia anti-cunia): entre la tapa de la basa / arranque del
#   mango (z=0.105) y el carrete (z=0.33) NO hay niveles de vertices en
#   (0.12, 0.30). Un colapso de aristas introduciria niveles espurios ahi.
#
# Reglas aplicadas (GUIA-BLENDER / plantilla_asset.py):
#   E-12 Z_APOYO = 0.045 · E-24 zmin_real() sobre VERTICES reales ·
#   E-50 huella > 0.30 m en X e Y con min_toca=8 (DEFAULT, no relajado) ·
#   E-44 solo SM_* se exporta · E-42 materiales por CARAS ·
#   E-68 caja() recibe la DIMENSION FINAL · E-27 SIN parents.
#
# Autoria 100 % headless: blender -b --factory-startup
#   --python-exit-code 1 --python <este>. El `--python-exit-code 1` es
#   OBLIGATORIO: sin el, un AssertionError dentro del script devuelve RC=0
#   (falso verde ya medido en M18-BIS).
import bpy
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja, piezas, zmin_real,
                             Z_APOYO)

MODULO = '35-Mineria'
ASSET = 'cana_pescar'

# --- Cotas (DECISION DE AUTORIA, ver cabecera) ---
Z = Z_APOYO                       # 0.045
BASA_SX, BASA_SY, BASA_SZ = 0.36, 0.08, 0.06
BASA_YS = (-0.13, 0.0, 0.13)
BASA_Z = Z + BASA_SZ / 2.0       # 0.075 -> 0.045..0.105
MANGO_SX, MANGO_SY, MANGO_SZ = 0.09, 0.09, 0.24
MANGO_Z = Z + BASA_SZ + MANGO_SZ / 2.0   # 0.225 -> 0.105..0.345

VARA = ((0.060, 0.50), (0.044, 0.45), (0.028, 0.40))  # (lado, alto)
Z_VARA = MANGO_Z + MANGO_SZ / 2.0        # 0.345
Y_CIMA = Z_VARA + sum(h for _s, h in VARA)   # 1.695

CAR_X, CAR_Z = -0.10, 0.40
CAR_SX, CAR_SY, CAR_SZ = 0.14, 0.06, 0.14
CRANK_X, CRANK_Y = -0.195, 0.05
CRANK_SX, CRANK_SY, CRANK_SZ = 0.05, 0.02, 0.02

ANILLA_X = 0.055
ANILLA_SX, ANILLA_SY, ANILLA_SZ = 0.05, 0.02, 0.02
ANILLAS_Z = (0.60, 1.05, 1.45)
LINEA_X = 0.075
LINEA_S = 0.008
LINEA_LO = 0.60
LINEA_HI = Y_CIMA
FLOT_SX, FLOT_SY, FLOT_SZ = 0.04, 0.04, 0.05
FLOT_Z = 0.62
ANZ_SX, ANZ_SY, ANZ_SZ = 0.03, 0.02, 0.02
ANZ_Z = 0.56

VACIA_LO, VACIA_HI = 0.12, 0.30   # zona anti-cunia
UMBRAL_PODA = 1e-4                # FASE 0 de generar_variante.py

assert abs(Y_CIMA - 1.695) < 1e-9, 'cota superior incoherente'
assert BASA_SX > 0.30 and (BASA_YS[-1] + BASA_SY / 2.0) * 2.0 > 0.30, \
    'la basa no satisface E-50 (min_fp=0.30)'
assert len(BASA_YS) * 4 >= 8, 'la basa no aporta 8 vertices de apoyo'
assert Z + BASA_SZ < VACIA_LO < VACIA_HI < CAR_Z - CAR_SZ / 2.0, \
    'la zona vacia no queda entre la basa y el carrete'
assert ANZ_SX * ANZ_SY * ANZ_SZ < UMBRAL_PODA, 'anzuelo debe ser podable'
assert FLOT_SX * FLOT_SY * FLOT_SZ < UMBRAL_PODA, 'flotador debe ser podable'
assert ANILLA_SX * ANILLA_SY * ANILLA_SZ < UMBRAL_PODA, \
    'anillas deben ser podables'
assert LINEA_S * LINEA_S * (LINEA_HI - LINEA_LO) < UMBRAL_PODA, \
    'la linea debe ser podable en BAJA'


def vertices(o):
    """Vertices REALES de mundo (E-24)."""
    return [o.matrix_world @ v.co for v in o.data.vertices]


def niveles_z(objetos):
    return sorted({round(w.z, 4) for o in objetos for w in vertices(o)})


def unir(nombre_activo, objetos):
    """Une cajas en UN solo objeto conservando el nombre del activo."""
    bpy.ops.object.select_all(action='DESELECT')
    for o in objetos:
        o.select_set(True)
    activo = next(o for o in objetos if o.name == nombre_activo)
    bpy.context.view_layer.objects.active = activo
    bpy.ops.object.join()
    res = bpy.context.view_layer.objects.active
    assert res is not None and res.name == nombre_activo, \
        'join cambio el nombre: %r' % (res.name if res else None)
    return res


def construir():
    escena = limpiar()

    MAT_madera = mat('MAT_Cana_Madera',     (0.55, 0.38, 0.22))
    MAT_oscura = mat('MAT_Cana_Madera_Osc', (0.34, 0.23, 0.14))
    MAT_vara = mat('MAT_Cana_Vara',        (0.78, 0.66, 0.38))
    MAT_herraje = mat('MAT_Cana_Herraje',  (0.32, 0.33, 0.36),
                      rough=0.55, spec=0.30)
    MAT_hilo = mat('MAT_Cana_Hilo',        (0.86, 0.88, 0.85))
    MAT_corcho = mat('MAT_Cana_Corcho',    (0.82, 0.34, 0.22))

    # --- CRITICA 1: basa de 3 rieles (12 verts apoyados, huella 0.36x0.34) ---
    rieles = [caja('SM_Cana_Basa_%d_NOFUNDIR' % (i + 1)
                   if i == 0 else 'SM_Cana_Basa_%d' % (i + 1),
                   0.0, y, BASA_Z, BASA_SX, BASA_SY, BASA_SZ, MAT_madera)
              for i, y in enumerate(BASA_YS)]
    basa = unir('SM_Cana_Basa_1_NOFUNDIR', rieles)
    basa.name = 'SM_Cana_Basa_NOFUNDIR'

    # --- CRITICA 2: mango / portacaña ---
    mango = caja('SM_Cana_Mango_NOFUNDIR', 0.0, 0.0, MANGO_Z,
                 MANGO_SX, MANGO_SY, MANGO_SZ, MAT_oscura)

    # --- CRITICA 3: 3 tramos telescopicos de seccion cuadrada ---
    tramos = []
    z = Z_VARA
    for i, (lado, alto) in enumerate(VARA):
        tramos.append(caja('SM_Cana_Vara_%d_NOFUNDIR' % (i + 1)
                           if i == 0 else 'SM_Cana_Vara_%d' % (i + 1),
                           0.0, 0.0, z + alto / 2.0,
                           lado, lado, alto, MAT_vara))
        z += alto
    vara = unir('SM_Cana_Vara_1_NOFUNDIR', tramos)
    vara.name = 'SM_Cana_Vara_NOFUNDIR'

    # --- CRITICA 4: carrete + manivela ---
    carrete = caja('SM_Cana_Carrete_NOFUNDIR', CAR_X, 0.0, CAR_Z,
                   CAR_SX, CAR_SY, CAR_SZ, MAT_herraje)
    crank = caja('SM_Cana_Manivela', CRANK_X, CRANK_Y, CAR_Z,
                 CRANK_SX, CRANK_SY, CRANK_SZ, MAT_herraje)
    carrete = unir('SM_Cana_Carrete_NOFUNDIR', [carrete, crank])
    carrete.name = 'SM_Cana_Carrete_NOFUNDIR'

    # --- NO CRITICOS (6), TODOS podables en BAJA por volumen < 1e-4 ---
    anillas = [caja('SM_Cana_Anilla_%d' % (i + 1), ANILLA_X, 0.0, z,
                    ANILLA_SX, ANILLA_SY, ANILLA_SZ, MAT_herraje)
               for i, z in enumerate(ANILLAS_Z)]
    linea = caja('SM_Cana_Linea', LINEA_X, 0.0,
                 (LINEA_LO + LINEA_HI) / 2.0,
                 LINEA_S, LINEA_S, LINEA_HI - LINEA_LO, MAT_hilo)
    flotador = caja('SM_Cana_Flotador', LINEA_X, 0.0, FLOT_Z,
                    FLOT_SX, FLOT_SY, FLOT_SZ, MAT_corcho)
    anzuelo = caja('SM_Cana_Anzuelo', LINEA_X, 0.0, ANZ_Z,
                   ANZ_SX, ANZ_SY, ANZ_SZ, MAT_herraje)
    detalles = anillas + [linea, flotador, anzuelo]

    # --- Orden canonico: arena -> luz -> asentar -> camara -> flat -> guardar ---
    arena(radio=2.2)
    iluminar(escena)
    bpy.context.view_layer.update()
    z_fin, toca, fp_x, fp_y = asentar(escena, min_toca=8, min_fp=0.30)

    ps = piezas(escena)
    assert len(ps) == 10, 'ALTA debe tener 10 SM_, hay %d' % len(ps)
    assert len({o.name for o in ps}) == len(ps), 'nombres SM_ duplicados'
    criticas = [o for o in ps if o.name.endswith('_NOFUNDIR')]
    assert len(criticas) == 4, 'deben ser 4 criticas, hay %d' % len(criticas)
    assert all(d in ps for d in detalles), 'falta algun detalle suelto'
    for d in detalles:
        bb = d.dimensions
        assert bb.x * bb.y * bb.z < UMBRAL_PODA, \
            '%s NO es podable (vol=%.2g)' % (d.name, bb.x * bb.y * bb.z)
    mats = {m.name for o in ps for m in o.data.materials if m}
    assert len(mats) == 6, 'ALTA debe tener 6 materiales, hay %d' % len(mats)
    print('LOD_PREVISTO ALTA=%d obj/%d mats | criticas=%d | detalles=%d '
          '-> MEDIA=7 | BAJA(poda 6)=4, DECIMATE=0 mallas'
          % (len(ps), len(mats), len(criticas), len(detalles)))

    for o in ps:
        zz = zmin_real(o)
        assert zz >= Z - 1e-4, '%s hunde %.4f < %.4f' % (o.name, zz, Z)

    # --- Guardia POSITIVA de apoyo: 12 esquinas de riel en z=Z ---
    vs_basa = vertices(basa)
    n_apoyo = 0
    for y in BASA_YS:
        for dx in (-BASA_SX / 2.0, BASA_SX / 2.0):
            for dy in (-BASA_SY / 2.0, BASA_SY / 2.0):
                ok = any(abs(w.x - dx) < 1e-4
                         and abs(w.y - (y + dy)) < 1e-4
                         and abs(w.z - Z) < 1e-4 for w in vs_basa)
                assert ok, 'falta esquina de riel en (%.2f, %.2f)' % (
                    dx, y + dy)
                n_apoyo += 1
    print('BASA APOYADA %d/12 esquinas en z=%.4f' % (n_apoyo, Z))

    # --- Guardia POSITIVA de altura, telescopio y zona vacia ---
    z_max = max(w.z for o in ps for w in vertices(o))
    assert abs(z_max - Y_CIMA) < 1e-4, \
        'algo sobrevuela la punta: z_max=%.4f' % z_max
    lados = sorted({round(w.x, 4) for w in vertices(vara)})
    assert len(lados) == 6, \
        'la vara debe tener 3 secciones cuadradas (6 planos X): %s' % lados
    niv = niveles_z(ps)
    espurios = [v for v in niv if VACIA_LO < v < VACIA_HI]
    assert not espurios, 'niveles espurios en zona vacia: %s' % espurios[:5]
    print('ALTURA_REAL z=[%.4f..%.4f] alto=%.4f | HUELLA=%.3fx%.3f '
          '| toca=%d | secciones=%s'
          % (Z, z_max, z_max - Z, fp_x, fp_y, toca, lados))
    print('ZONA_VACIA (%.2f, %.2f): 0 niveles | niveles_z=%d'
          % (VACIA_LO, VACIA_HI, len(niv)))

    # --- Guardia POSITIVA de carrete y linea (senales de silueta) ---
    xs = [w.x for o in ps for w in vertices(o)]
    assert min(xs) < -0.20, 'falta la manivela del carrete a la izquierda'
    assert max(xs) > 0.09, 'falta el flotador / linea a la derecha'
    print('SILUETA x=[%.3f..%.3f] carrete=%s linea=%s'
          % (min(xs), max(xs), min(xs) < -0.20,
             any(abs(w.z - LINEA_HI) < 1e-4 and w.x > 0.06
                 for w in vertices(linea))))

    camara(escena, 'CAM_Cana_Pescar', (2.20, -2.40, 1.55), (0.0, 0.0, 0.85))
    shade_flat(escena)
    ruta = guardar(escena, MODULO, ASSET)
    print('VARIANTE %-16s | SM_=%d | mats=%d | tris~%d | z_min=%.4f '
          '| z_max=%.4f | toca=%d | fp=%.2fx%.2f'
          % (ASSET, len(ps), len(mats),
             sum(len(o.data.loop_triangles) for o in ps), z_fin, z_max,
             toca, fp_x, fp_y))
    return ruta


if __name__ == '__main__':
    construir()
    print('LISTO — cana de pescar en soporte de playa (M35 / L37)')
