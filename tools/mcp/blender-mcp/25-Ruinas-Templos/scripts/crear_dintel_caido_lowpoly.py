# crear_dintel_caido_lowpoly.py — Dintel caido (M25, ruinas)
#
# Checklist `CHECKLIST-OBJETOS-BLENDER.md` L177 y
# `02-Backlog-Pendientes-Assets.md` L29: "Dintel caido" seguia `[ ]`.
# Medido 2026-11-08 00:12 -0300: 0 `.blend`, 0 generador y 0 GLB con
# `dintel` en `25-Ruinas-Templos` / `assets/3d` (451 GLB trackeados).
#
# SPEC: `DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md` tiene una tabla de
#   24 piezas y **NO define `dintel`**. E-28 (GUIA-BLENDER/02) lo menciona
#   unicamente como ejemplo de asset "de pared" para el SET DE CAPTURA, no
#   como pieza del catalogo. Por lo tanto TODAS las cotas de abajo son
#   DECISION DE AUTORIA documentada y derivada, NUNCA valor de spec:
#
#   LARGO = 1.40 m. Derivado de la pieza 9 de la MISMA tabla
#     (`muro_vano` = "Recto con hueco de puerta 1x2"): luz de 1.00 m
#     (1 voxel = 1.00 m, medido en la pieza 16 `columna` 1x1x3) mas 0.20 m
#     de apoyo sobre cada montante = 1.40 m.
#   FONDO = 0.40 m. REUTILIZA el espesor ya documentado en B15/L28 para
#     `muro_recto` (acta 25 §3). No se inventa un segundo espesor para M25.
#   CANTO = 0.30 m. Perfil del dintel; al caer "de plano" queda como ALTURA
#     sobre el suelo (z_min=0.045, z_max=0.345, alto fisico 0.300).
#
# LECTURA DE "CAIDO" (4 señales positivas, ninguna es una rotacion que
#   romperia el apoyo): (1) la pieza esta TUMBADA a 0.30 m del suelo en vez
#   de coronar un vano a 2 m; (2) el RELIEVE TALLADO, que en un dintel
#   montado miraria al frente, ahora mira al CIELO (+Z); (3) el extremo
#   derecho esta ASTILLADO en 3 dientes de largo distinto; (4) hay un
#   FRAGMENTO DESPRENDIDO y un ESCOMBRO apoyados, separados del cuerpo.
#
# Reglas aplicadas (GUIA-BLENDER / plantilla_asset.py):
#   E-12  Z_APOYO = 0.045 (arena top 0.05, E-67)
#   E-24  zmin_real() sobre VERTICES reales, nunca bound_box
#   E-50  huella > 0.30 m en X e Y; `min_toca=8` (DEFAULT, no relajado:
#         cuerpo 4 + dientes + fragmento 4 + escombro 4 tocan el suelo)
#   E-44  solo SM_* se exporta; Base_Arena / SOL / CAM_* se purgan
#   E-42  materiales contados POR CARAS (lo mide chk_asset.py)
#   E-68  caja()/scale = dimension FINAL, no la mitad
#   E-27  SIN parents: todas las piezas son objetos raiz, para que
#         `asentar()` las mueva a todas por igual.
#
# HUELLA DEL CONJUNTO: es MAYOR que 1.40 x 0.40 porque el fragmento y el
#   escombro estan separados del cuerpo (eso ES una ruina caida). Por eso la
#   guardia de abajo NO exige `fp == LARGO x FONDO` (eso seria consagrar una
#   mentira): exige las DOS esquinas izquierdas del cuerpo en (X0, +/-Y1)
#   y `min(fp_x, fp_y) > 0.30`.
#
# DECISION DE 4 MATERIALES + 4 CRITICAS:
#   `generar_variante.py` agrupa por LISTA de materiales y en BAJA poda a 4.
#   Con exactamente 4 la poda es un NO-OP: ninguna pieza de identidad se
#   blanquea. Las 4 criticas `_NOFUNDIR` (cuerpo, fragmento, escombro,
#   grieta) agotan los grupos Piedra y Oscuro; los grupos Tallado y Musgo
#   quedan con piezas NO criticas que se fusionan en 2 mallas.
#   => MEDIA/BAJA = 4 + 2 = 6 objetos, exactamente el techo BAJA (<= 6).
#   Mismo patron MEDIDO en B15/L28 (acta 25 §4) y en columna_entera (2338):
#   el decimate actua SOLO sobre el relieve, nunca sobre la silueta portante.
#   Leccion: `chk_asset.py` mide COSTE, no FORMA; una BAJA "OK" con el
#   panel colapsado en cunia ya paso dos veces en B15.
#
# GUARDA POSITIVA DE RELIEVE: un glifo/grieta/musgo "pintado" es una pieza
#   que NO atraviesa el plano superior z=Z_TOP. Se mide que CADA pieza de
#   relieve tenga z_min < Z_TOP < z_max: si no lo cruza, flota o es falsa.
#
# Autoría 100 % headless: blender -b --factory-startup --python <este>.
# No requiere GUI ni socket 127.0.0.1:9876 (E-55 / E-56).
import bpy
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja, piezas, zmin_real,
                             Z_APOYO)

MODULO = '25-Ruinas-Templos'
ASSET = 'dintel_caido'

# --- Cotas (DECISION DE AUTORIA derivada de la spec M25, ver cabecera) ---
LARGO = 1.40
FONDO = 0.40
CANTO = 0.30
Z = Z_APOYO                          # 0.045
Z_TOP = Z + CANTO                    # 0.345
X0, X1 = -LARGO / 2.0, LARGO / 2.0  # -0.70 .. 0.70
Y1 = FONDO / 2.0                     # 0.20

L_CUERPO = 1.10
X_CORTE = X0 + L_CUERPO              # 0.40 : donde empieza el astillado
BANDAS = 3
ANCHO_BANDA = FONDO / BANDAS         # 0.13333
DIENTES = (0.30, 0.20, 0.26)        # largos DISTINTOS -> extremo astillado
assert abs((X_CORTE + DIENTES[0]) - X1) < 1e-9, \
    'el diente mas largo debe cerrar la cota nominal X1'
assert len(set(DIENTES)) == 3, 'sin 3 largos distintos no hay astillado'

# Fragmento desprendido y escombro: APOYADOS y SEPARADOS del cuerpo
FRAG_SX, FRAG_SY, FRAG_SZ = 0.18, 0.16, 0.12
FRAG_X, FRAG_Y = X1 + 0.14, 0.02
ESC_SX, ESC_SY, ESC_SZ = 0.14, 0.12, 0.09
ESC_X, ESC_Y = X0 - 0.20, 0.30

# Relieve sobre la cara SUPERIOR (antiguo frente del dintel, ahora al cielo)
REL_SY = 0.016                       # espesor que ATRAVIESA z=Z_TOP
GRI_SX, GRI_SY, GRI_SZ = 0.030, 0.34, REL_SY
GRI_X, GRI_Y = -0.28, 0.0
GLI_SX, GLI_SY, GLI_SZ = 0.10, 0.14, REL_SY
GLIFOS = ((-0.50, -0.10), (-0.05, 0.08), (0.22, -0.08))
FAJ_SX, FAJ_SY, FAJ_SZ = 0.90, 0.030, REL_SY
FAJ_X, FAJ_Y = -0.15, -0.165
MUS_SX, MUS_SY, MUS_SZ = 0.16, 0.10, 0.014
MUSGOS = ((-0.58, 0.13), (0.30, 0.10))


def vertices(o):
    """Vértices REALES de mundo (E-24)."""
    return [o.matrix_world @ v.co for v in o.data.vertices]


def cotas_z(o):
    zs = [w.z for w in vertices(o)]
    return min(zs), max(zs)


def unir(nombre_activo, objetos):
    """Une cajas adyacentes en UN solo objeto (sin caras internas visibles).

    El cuerpo + los 3 dientes deben ser UNA sola pieza critica: si fueran 4
    criticas, BAJA tendria 4 criticas + 1 cuerpo extra > 6 objetos.
    """
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

    MAT_piedra = mat('MAT_Dintel_Piedra',  (0.56, 0.54, 0.49))
    MAT_osc    = mat('MAT_Dintel_Oscuro',  (0.34, 0.32, 0.30))
    MAT_talla  = mat('MAT_Dintel_Tallado', (0.72, 0.68, 0.58))
    MAT_musgo  = mat('MAT_Dintel_Musgo',   (0.30, 0.44, 0.21))

    zc = Z + CANTO / 2.0              # 0.195 : centro en altura

    # --- 1) CUERPO + extremo ASTILLADO, en UNA sola malla critica ---
    cuerpo = caja('SM_Dintel_Cuerpo_NOFUNDIR',
                  X0 + L_CUERPO / 2.0, 0.0, zc,
                  L_CUERPO, FONDO, CANTO, MAT_piedra)
    dientes = []
    for i, largo in enumerate(DIENTES):
        y_banda = -Y1 + ANCHO_BANDA * (i + 0.5)
        dientes.append(caja('SM_Dintel_Diente_%d' % (i + 1),
                            X_CORTE + largo / 2.0, y_banda, zc,
                            largo, ANCHO_BANDA, CANTO, MAT_piedra))
    cuerpo = unir('SM_Dintel_Cuerpo_NOFUNDIR', [cuerpo] + dientes)

    # --- 2) Fragmento desprendido (critico, apoyado) ---
    fragmento = caja('SM_Dintel_Fragmento_NOFUNDIR', FRAG_X, FRAG_Y,
                     Z + FRAG_SZ / 2.0,
                     FRAG_SX, FRAG_SY, FRAG_SZ, MAT_piedra)

    # --- 3) Escombro (critico, apoyado) ---
    escombro = caja('SM_Dintel_Escombro_NOFUNDIR', ESC_X, ESC_Y,
                    Z + ESC_SZ / 2.0,
                    ESC_SX, ESC_SY, ESC_SZ, MAT_piedra)

    # --- 4) Grieta transversal (critica) ---
    grieta = caja('SM_Dintel_Grieta_NOFUNDIR', GRI_X, GRI_Y, Z_TOP,
                  GRI_SX, GRI_SY, GRI_SZ, MAT_osc)

    # --- 5) 3 glifos + faja moldurada (Tallado, NO criticos -> 1 malla) ---
    glifos = [caja('SM_Dintel_Glifo_%d' % (i + 1), x, y, Z_TOP,
                   GLI_SX, GLI_SY, GLI_SZ, MAT_talla)
              for i, (x, y) in enumerate(GLIFOS)]
    faja = caja('SM_Dintel_Faja', FAJ_X, FAJ_Y, Z_TOP,
                FAJ_SX, FAJ_SY, FAJ_SZ, MAT_talla)

    # --- 6) 2 manchas de musgo (Musgo, NO criticos -> 1 malla) ---
    musgos = [caja('SM_Dintel_Musgo_%d' % (i + 1), x, y, Z_TOP,
                   MUS_SX, MUS_SY, MUS_SZ, MAT_musgo)
              for i, (x, y) in enumerate(MUSGOS)]

    # --- Orden canonico: arena -> luz -> asentar -> camara -> flat -> guardar ---
    arena()
    iluminar(escena)
    bpy.context.view_layer.update()
    z_fin, toca, fp_x, fp_y = asentar(escena, min_toca=8, min_fp=0.30)

    ps = piezas(escena)
    assert len(ps) <= 16, 'excede presupuesto ALTA: %d SM_' % len(ps)
    assert len({o.name for o in ps}) == len(ps), 'nombres SM_ duplicados'
    criticas = [o for o in ps if o.name.endswith('_NOFUNDIR')]
    assert len(criticas) == 4, 'deben ser 4 criticas, hay %d' % len(criticas)

    for o in ps:
        z = zmin_real(o)
        assert z >= Z - 1e-4, '%s hunde %.4f < %.4f' % (o.name, z, Z)
        print('APOYO_PIEZA %-32s z_min=%.4f' % (o.name, z))

    # --- Guardia POSITIVA de altura y huella ---
    # MEDICION REAL 2026-11-08: el primer intento media el alto sobre el
    # CONJUNTO y daba 0.3080: el relieve EMPOTRADO sobresale 8 mm por encima
    # de Z_TOP (0.337..0.353) y ESO ES CORRECTO (si no cruzara el plano seria
    # una pieza pintada/flotante). La cota CANTO es de la SILUETA PORTANTE,
    # no del bounding box global. Se mide el alto en `cuerpo` y se ACOTA el
    # exceso del relieve, en vez de consagrar un 0.308 como si fuera el dintel.
    z0_c, z1_c = cotas_z(cuerpo)
    assert abs(z0_c - Z) < 1e-4, 'el cuerpo no arranca en Z_APOYO'
    assert abs(z1_c - z0_c - CANTO) < 1e-4, \
        'alto del cuerpo %.4f != %.2f (decision de autoria)' % (
            z1_c - z0_c, CANTO)
    z_max = max(w.z for o in ps for w in vertices(o))
    exceso = max(GRI_SZ, GLI_SZ, FAJ_SZ, MUS_SZ) / 2.0
    assert Z_TOP < z_max <= Z_TOP + exceso + 1e-4, \
        'relieve z_max=%.4f fuera de [%.4f, %.4f]' % (
            z_max, Z_TOP, Z_TOP + exceso)
    assert min(fp_x, fp_y) > 0.30, 'huella %.3f x %.3f (E-50)' % (fp_x, fp_y)
    print('ALTURA_REAL cuerpo z=[%.4f..%.4f] alto=%.4f | relieve z_max=%.4f '
          '(+%.4f) | HUELLA_CONJUNTO=%.3fx%.3f'
          % (z0_c, z1_c, z1_c - z0_c, z_max, z_max - Z_TOP, fp_x, fp_y))

    # --- 2 esquinas izquierdas del cuerpo APOYADAS (no flota) ---
    vs = vertices(cuerpo)
    for sx, sy in ((X0, -Y1), (X0, Y1)):
        assert any(abs(w.x - sx) < 1e-4 and abs(w.y - sy) < 1e-4
                   and abs(w.z - Z) < 1e-4 for w in vs), \
            'falta esquina apoyada (%.2f, %.2f): el dintel flota' % (sx, sy)
        print('ESQUINA_APOYADA x=%.2f y=%.2f z=%.4f' % (sx, sy, Z))

    # --- Extremo ASTILLADO: 3 largos distintos medidos en VERTICES ---
    xs = sorted({round(w.x, 4) for w in vs})
    for largo in DIENTES:
        assert any(abs(x - (X_CORTE + largo)) < 1e-4 for x in xs), \
            'falta diente de largo %.2f (x=%.2f)' % (largo, X_CORTE + largo)
    assert abs(max(xs) - X1) < 1e-4, 'el extremo no cierra en X1=%.2f' % X1
    print('ASTILLADO x_max=%.2f | dientes=%s | niveles_x=%d'
          % (max(xs), [round(X_CORTE + d, 2) for d in DIENTES], len(xs)))

    # --- Fragmento y escombro: APOYADOS y SEPARADOS del cuerpo ---
    for o in (fragmento, escombro):
        z0, z1 = cotas_z(o)
        assert abs(z0 - Z) < 1e-4, '%s NO esta apoyado (z=%.4f)' % (o.name, z0)
        x0 = min(w.x for w in vertices(o))
        x1 = max(w.x for w in vertices(o))
        assert x0 > X1 or x1 < X0, '%s no esta separado del cuerpo' % o.name
        print('DESPRENDIDO %-32s x=[%.3f..%.3f] z0=%.4f'
              % (o.name, x0, x1, z0))

    # --- Relieve EMPOTRADO: cada pieza ATRAVIESA el plano superior ---
    for o in [grieta] + glifos + [faja] + musgos:
        z0, z1 = cotas_z(o)
        assert z0 < Z_TOP < z1, \
            '%s NO atraviesa z=%.4f (%.4f..%.4f): pieza pintada/flotante' % (
                o.name, Z_TOP, z0, z1)
        print('RELIEVE %-32s z=[%.4f..%.4f] cruza %.4f'
              % (o.name, z0, z1, Z_TOP))

    # --- Glifos y faja confinados a la cara superior del cuerpo ---
    for o in glifos + [faja]:
        ws = vertices(o)
        assert min(w.x for w in ws) > X0 and max(w.x for w in ws) < X_CORTE, \
            '%s se sale del cuerpo (invade el astillado)' % o.name
        assert min(w.y for w in ws) > -Y1 and max(w.y for w in ws) < Y1, \
            '%s se sale del ancho del dintel' % o.name

    camara(escena, 'CAM_Dintel', loc=(2.10, -2.30, 1.55),
           mira=(0.0, 0.0, Z + CANTO * 0.50))
    shade_flat(escena)
    ruta = guardar(escena, MODULO, ASSET)
    print('VARIANTE %s | SM_=%d | criticas=%d | alto=%.2f | z_min=%.4f '
          '| toca=%d | fp=%.2fx%.2f'
          % (ASSET, len(ps), len(criticas), CANTO, z_fin, toca, fp_x, fp_y))
    return ruta


def main():
    construir()
    print('LISTO — dintel caido (1 asset M25, cota derivada de muro_vano 1x2)')


if __name__ == '__main__':
    main()
