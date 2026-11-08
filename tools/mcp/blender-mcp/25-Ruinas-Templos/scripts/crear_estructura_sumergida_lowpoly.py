# crear_estructura_sumergida_lowpoly.py — Estructura sumergida parcial / marea (M25)
#
# Checklist `CHECKLIST-OBJETOS-BLENDER.md` L187, `02-Backlog-Pendientes-Assets.md`
#   L31 y `DOCUMENTACION/TAREAS-POR-MODELO/HY4/25-Ruinas/checklist.md` L20:
#   "Estructura sumergida parcial (marea)" seguia `[ ]`.
# Medido 2026-11-08 02:05 -0300: 0 `.blend`, 0 generador y 0 GLB con
#   `sumerg`/`marea` en `25-Ruinas-Templos` / `assets/3d`.
#
# SPEC: `DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md` tiene un catalogo
#   de 40 piezas y una tabla de 13 ensamblajes. NO contiene `estructura
#   sumergida`, ni `sumergida`, ni `marea`. Igual que en B16/L29, TODAS las
#   cotas de abajo son DECISION DE AUTORIA derivada y documentada, NUNCA una
#   cita de spec:
#
#   1 voxel = 1.00 m (pieza 16 `columna` 1x1x3 de la MISMA tabla; ya usado
#     en B15/L28 y B16/L29).
#   ANCHO_PORTICO = 2.00 m (2 voxels). Derivado de la pieza 12 `arco`
#     ("Arco semicircular, 2x2 voxel") y de la pieza 9 `muro_vano` (1x2).
#   FONDO = 1.00 m (1 voxel, pieza 1 `suelo_losa` 1x1 voxel).
#   ALTO_EMERGIDO = 2.00 m (pieza 6 `muro_recto` 1x2 voxel).
#   MAREA = 0.50 m sobre el apoyo. Derivado de la pieza 3
#     `suelo_losa_intermedia` ("1x0.5 voxel, transicion de altura"): la
#     marea sube exactamente MEDIA LOSA. No se inventa una tercera cota.
#   ALTURA_PLATAFORMA = 0.20 m y 3 peldaños de 0.10/0.20/0.30 m (pieza 22
#     `escalera_recta`: "3 peldaños, sube 1 voxel"). Los 3 quedan BAJO la
#     marea: eso es lo que hace "parcialmente sumergida".
#
# LECTURA DE "SUMERGIDA PARCIAL" (4 señales positivas, todas medibles en el
#   BIN del GLB, ninguna es un plano de agua transparente que el exportador
#   podria convertir en un alpha-sort roto):
#   (1) PLATAFORMA + 3 PELDAÑOS + FRAGMENTO con material PIEDRA HUMEDA
#       (mas oscura) y todos por DEBAJO de la cota de marea 0.545;
#   (2) BANDA DE ALGAS horizontal a la MISMA cota en AMBAS columnas, que
#       ENVUELVE la seccion (0.36 m > 0.30 m de columna) y la cruza
#       (0.515..0.575) => la linea de agua es GEOMETRIA REAL, no pintura;
#   (3) DOS COLUMNAS DE ALTURA DISTINTA que EMERGEN por encima de la marea:
#       izquierda 2.10 m (con capitel) y derecha 1.30 m (rota), mas un
#       DINTEL HUNDIDO apoyado en la columna corta y empotrado en la larga;
#   (4) ALGAS COLGANTES que bajan desde la banda hacia la zona sumergida.
#
# Reglas aplicadas (GUIA-BLENDER / plantilla_asset.py):
#   E-12  Z_APOYO = 0.045 (arena top 0.05, E-67)
#   E-24  zmin_real() sobre VERTICES reales, nunca bound_box
#   E-50  huella > 0.30 m en X e Y; min_toca=8 (DEFAULT, no relajado:
#         plataforma 4 + 3 peldaños x4 + fragmento 4 = 20 vertices apoyados)
#   E-44  solo SM_* se exporta; Base_Arena / SOL / CAM_* se purgan
#   E-42  materiales contados POR CARAS (lo mide chk_asset.py)
#   E-68  caja()/scale = dimension FINAL, no la mitad
#   E-27  SIN parents: todas las piezas son objetos raiz, para que
#         asentar() las mueva a todas por igual.
#
# DECISION DE 4 MATERIALES + 4 CRITICAS:
#   `generar_variante.py` agrupa los NO criticos por LISTA de materiales y en
#   BAJA poda a 4. Con exactamente 4 la poda es un NO-OP: ninguna pieza de
#   identidad se blanquea. Las 4 criticas `_NOFUNDIR` son:
#     Portico_Izq (Piedra), Portico_Der (Piedra), Base (Humedo),
#     Bandas (Algas, 2 bandas unidas).
#   Quedan 2 grupos NO criticos: Algas colgantes (2 cajas -> 1 malla) y
#   Tallado (2 glifos -> 1 malla).
#   => MEDIA/BAJA = 4 + 2 = 6 objetos, exactamente el techo BAJA (<= 6).
#   El decimate 0.70 actua SOLO sobre detalles, NUNCA sobre la silueta
#   portante ni sobre la banda de marea (B15: un BAJA "OK" con el panel
#   colapsado en cunia paso DOS veces; chk_asset.py mide COSTE, no FORMA).
#
# GUARDA POSITIVA DE AUTORIA: se mide que la banda ATRAVIESA la cota de
#   marea, que ambas columnas la cruzan, que hay geometria con masa REAL
#   por debajo Y por encima, y que las 4 esquinas de la plataforma estan
#   apoyadas en z=Z_APOYO (no flota).
#
# Autoria 100 % headless: blender -b --factory-startup --python <este>.
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
ASSET = 'estructura_sumergida'

# --- Cotas (DECISION DE AUTORIA derivada de la spec M25, ver cabecera) ---
Z = Z_APOYO                         # 0.045
ANCHO = 2.00                        # pórtico de 2 voxels
FONDO = 1.00                        # 1 voxel
H_PLAT = 0.20                       # plataforma sumergida
MAREA = Z + 0.50                    # 0.545 : media losa (pieza 3)
Y1 = FONDO / 2.0                    # 0.50
X_COL = 0.70                        # separacion de columnas
SEC_COL = 0.30                      # seccion de columna
H_COL_IZQ = 1.80                    # 0.245 .. 2.045
H_COL_DER = 1.00                    # 0.245 .. 1.245 (rota, mas baja)
H_CAP = 0.10                        # capitel
Z_BASE_COL = Z + H_PLAT             # 0.245
Z_DINTEL = Z_BASE_COL + H_COL_DER + H_CAP   # 1.345 : tope capitel derecho
H_DINTEL = 0.22
L_DINTEL = 1.70
F_DINTEL = 0.30
Z_ALTO_IZQ = Z_BASE_COL + H_COL_IZQ + H_CAP  # 2.145 : cota maxima

BANDA_LADO = 0.36                   # > SEC_COL: ENVUELVE la columna
BANDA_ESP = 0.06                    # 0.515 .. 0.575, CRUZA la marea
ALGA_SX, ALGA_SY, ALGA_SZ = 0.06, 0.04, 0.22
ALGA_Y = BANDA_LADO / 2.0 + 0.01   # 0.19 : cuelga por fuera de la banda
GLI_SX, GLI_SY, GLI_SZ = 0.14, 0.02, 0.14
GLI_X = (-0.30, 0.30)
GLI_Z = Z_DINTEL + H_DINTEL / 2.0
CARAS_Y = -F_DINTEL / 2.0          # -0.15 : cara frontal del dintel

PELDANOS = ((-0.575, 0.10), (-0.725, 0.20), (-0.875, 0.30))
FRAG_X, FRAG_Y = 1.20, 0.30
FRAG_SX, FRAG_SY, FRAG_SZ = 0.18, 0.14, 0.12

assert 0 < Z < MAREA < Z_DINTEL < Z_ALTO_IZQ, 'cotas de marea incoherentes'
assert MAREA > Z_BASE_COL and MAREA < Z_BASE_COL + H_COL_DER, \
    'la marea debe cortar AMBAS columnas'
assert max(h for _, h in PELDANOS) < MAREA - Z, \
    'los peldaños deben quedar bajo la marea'
assert BANDA_LADO > SEC_COL, 'la banda no envuelve la columna'


def vertices(o):
    """Vertices REALES de mundo (E-24)."""
    return [o.matrix_world @ v.co for v in o.data.vertices]


def cotas_z(o):
    zs = [w.z for w in vertices(o)]
    return min(zs), max(zs)


def unir(nombre_activo, objetos):
    """Une cajas en UN solo objeto (sin caras internas visibles).

    Igual que B16: las piezas de identidad se agrupan en una sola malla
    critica para no exceder el techo de 6 objetos en BAJA.
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

    MAT_piedra = mat('MAT_Sumerg_Piedra',  (0.57, 0.55, 0.49))
    MAT_humedo = mat('MAT_Sumerg_Humedo',  (0.28, 0.36, 0.35))
    MAT_algas  = mat('MAT_Sumerg_Algas',   (0.24, 0.46, 0.24))
    MAT_talla  = mat('MAT_Sumerg_Tallado', (0.74, 0.70, 0.60))

    # --- 1) BASE SUMERGIDA: plataforma + 3 peldaños + fragmento (1 critica) ---
    plataforma = caja('SM_Sumerg_Base_NOFUNDIR', 0.0, 0.0, Z + H_PLAT / 2.0,
                      ANCHO, FONDO, H_PLAT, MAT_humedo)
    pelds = [caja('SM_Sumerg_Peldano_%d' % (i + 1), 0.0, y, Z + h / 2.0,
                  ANCHO, 0.15, h, MAT_humedo)
             for i, (y, h) in enumerate(PELDANOS)]
    frag = caja('SM_Sumerg_Fragmento', FRAG_X, FRAG_Y, Z + FRAG_SZ / 2.0,
                FRAG_SX, FRAG_SY, FRAG_SZ, MAT_humedo)
    base = unir('SM_Sumerg_Base_NOFUNDIR', [plataforma] + pelds + [frag])

    # --- 2) PORTICO IZQUIERDO: columna alta + capitel + DINTEL HUNDIDO ---
    col_izq = caja('SM_Sumerg_Portico_Izq_NOFUNDIR', -X_COL, 0.0,
                   Z_BASE_COL + H_COL_IZQ / 2.0,
                   SEC_COL, SEC_COL, H_COL_IZQ, MAT_piedra)
    cap_izq = caja('SM_Sumerg_Capitel_Izq', -X_COL, 0.0,
                   Z_BASE_COL + H_COL_IZQ + H_CAP / 2.0,
                   0.40, 0.40, H_CAP, MAT_piedra)
    dintel = caja('SM_Sumerg_Dintel', 0.0, 0.0,
                  Z_DINTEL + H_DINTEL / 2.0,
                  L_DINTEL, F_DINTEL, H_DINTEL, MAT_piedra)
    portico_izq = unir('SM_Sumerg_Portico_Izq_NOFUNDIR',
                       [col_izq, cap_izq, dintel])

    # --- 3) PORTICO DERECHO: columna ROTA (mas baja) + capitel ---
    col_der = caja('SM_Sumerg_Portico_Der_NOFUNDIR', X_COL, 0.0,
                   Z_BASE_COL + H_COL_DER / 2.0,
                   SEC_COL, SEC_COL, H_COL_DER, MAT_piedra)
    cap_der = caja('SM_Sumerg_Capitel_Der', X_COL, 0.0,
                   Z_BASE_COL + H_COL_DER + H_CAP / 2.0,
                   0.40, 0.40, H_CAP, MAT_piedra)
    portico_der = unir('SM_Sumerg_Portico_Der_NOFUNDIR', [col_der, cap_der])

    # --- 4) BANDA DE MAREA en AMBAS columnas (1 critica, 2 islas) ---
    bandas = [caja('SM_Sumerg_Banda_%d' % (i + 1), x, 0.0, MAREA,
                   BANDA_LADO, BANDA_LADO, BANDA_ESP, MAT_algas)
              for i, x in enumerate((-X_COL, X_COL))]
    bandas_obj = unir('SM_Sumerg_Banda_1', bandas)
    bandas_obj.name = 'SM_Sumerg_Bandas_NOFUNDIR'

    # --- 5) ALGAS COLGANTES (NO criticas -> 1 malla fusionada) ---
    algas = [caja('SM_Sumerg_Alga_%d' % (i + 1), x, ALGA_Y,
                  MAREA - ALGA_SZ / 2.0,
                  ALGA_SX, ALGA_SY, ALGA_SZ, MAT_algas)
             for i, x in enumerate((-X_COL, X_COL))]

    # --- 6) 2 GLIFOS en la cara frontal del dintel (NO criticos -> 1 malla) ---
    glifos = [caja('SM_Sumerg_Glifo_%d' % (i + 1), x, CARAS_Y, GLI_Z,
                   GLI_SX, GLI_SY, GLI_SZ, MAT_talla)
              for i, x in enumerate(GLI_X)]

    # --- Orden canonico: arena -> luz -> asentar -> camara -> flat -> guardar ---
    arena(radio=2.6)
    iluminar(escena)
    bpy.context.view_layer.update()
    z_fin, toca, fp_x, fp_y = asentar(escena, min_toca=8, min_fp=0.30)

    ps = piezas(escena)
    assert len(ps) <= 16, 'excede presupuesto ALTA: %d SM_' % len(ps)
    assert len({o.name for o in ps}) == len(ps), 'nombres SM_ duplicados'
    criticas = [o for o in ps if o.name.endswith('_NOFUNDIR')]
    assert len(criticas) == 4, 'deben ser 4 criticas, hay %d' % len(criticas)
    grupos = {}
    for o in ps:
        if o not in criticas:
            clave = tuple(m.name for m in o.data.materials)
            grupos.setdefault(clave, []).append(o)
    assert len(grupos) == 2, \
        'deben ser 2 grupos fusionables, hay %d' % len(grupos)
    print('MERGE_PREVISTO criticas=%d grupos=%d -> %d objetos MEDIA/BAJA'
          % (len(criticas), len(grupos), len(criticas) + len(grupos)))

    for o in ps:
        z = zmin_real(o)
        assert z >= Z - 1e-4, '%s hunde %.4f < %.4f' % (o.name, z, Z)
        print('APOYO_PIEZA %-34s z_min=%.4f' % (o.name, z))

    # --- Guardia POSITIVA de apoyo y altura ---
    vs_base = vertices(base)
    for sx, sy in ((-ANCHO / 2.0, -Y1), (-ANCHO / 2.0, Y1),
                   (ANCHO / 2.0, -Y1), (ANCHO / 2.0, Y1)):
        assert any(abs(w.x - sx) < 1e-4 and abs(w.y - sy) < 1e-4
                   and abs(w.z - Z) < 1e-4 for w in vs_base), \
            'falta esquina apoyada (%.2f, %.2f): la plataforma flota' % (sx, sy)
    print('PLATAFORMA 4/4 esquinas apoyadas en z=%.4f' % Z)

    z0_i, z1_i = cotas_z(portico_izq)
    z0_d, z1_d = cotas_z(portico_der)
    assert abs(z1_i - Z_ALTO_IZQ) < 1e-4, \
        'cota maxima %.4f != %.4f' % (z1_i, Z_ALTO_IZQ)
    assert abs(z1_d - Z_DINTEL) < 1e-4, \
        'la columna rota no sostiene el dintel: %.4f != %.4f' % (z1_d, Z_DINTEL)
    assert z1_i - z1_d > 0.50, 'las dos columnas no tienen altura DISTINTA'
    print('EMERGIDO izq z=[%.4f..%.4f] der z=[%.4f..%.4f] delta=%.4f'
          % (z0_i, z1_i, z0_d, z1_d, z1_i - z1_d))

    z_max = max(w.z for o in ps for w in vertices(o))
    assert abs(z_max - Z_ALTO_IZQ) < 1e-4, \
        'algo sobrevuela la columna alta: z_max=%.4f' % z_max
    assert min(fp_x, fp_y) > 0.30, 'huella %.3f x %.3f (E-50)' % (fp_x, fp_y)
    print('ALTURA_REAL z=[%.4f..%.4f] alto=%.4f | HUELLA=%.3fx%.3f'
          % (Z, z_max, z_max - Z, fp_x, fp_y))

    # --- Guardia POSITIVA de MAREA: la banda ATRAVIESA la cota y ENVUELVE ---
    z0_b, z1_b = cotas_z(bandas_obj)
    assert z0_b < MAREA < z1_b, \
        'la banda NO cruza la marea (%.4f..%.4f)' % (z0_b, z1_b)
    xs_b = sorted({round(w.x, 4) for w in vertices(bandas_obj)})
    for x in (-X_COL, X_COL):
        for dx in (-BANDA_LADO / 2.0, BANDA_LADO / 2.0):
            assert any(abs(v - (x + dx)) < 1e-4 for v in xs_b), \
                'falta borde de banda en x=%.3f' % (x + dx)
    print('MAREA cota=%.4f | banda z=[%.4f..%.4f] | niveles_x=%d'
          % (MAREA, z0_b, z1_b, len(xs_b)))

    # Ambas columnas cruzan la marea (geometria real, no solo la banda)
    for o, nom in ((portico_izq, 'izq'), (portico_der, 'der')):
        z0, z1 = cotas_z(o)
        assert z0 < MAREA < z1, \
            'la columna %s no atraviesa la marea (%.4f..%.4f)' % (nom, z0, z1)

    # Masa real POR DEBAJO y POR ENCIMA de la marea (sumergida PARCIAL)
    todos = [w for o in ps for w in vertices(o)]
    abajo = sum(1 for w in todos if w.z < MAREA - 1e-4)
    arriba = sum(1 for w in todos if w.z > MAREA + 1e-4)
    assert abajo >= 20 and arriba >= 20, \
        'no hay geometria a ambos lados de la marea: abajo=%d arriba=%d' % (
            abajo, arriba)
    print('SUMERGIDA_PARCIAL vertices bajo marea=%d sobre marea=%d'
          % (abajo, arriba))

    # --- DINTEL: 4 esquinas en su base y 4 en su cara superior ---
    vs_d = vertices(portico_izq)
    for zc in (Z_DINTEL, Z_DINTEL + H_DINTEL):
        for sx in (-L_DINTEL / 2.0, L_DINTEL / 2.0):
            for sy in (-F_DINTEL / 2.0, F_DINTEL / 2.0):
                assert any(abs(w.x - sx) < 1e-4 and abs(w.y - sy) < 1e-4
                           and abs(w.z - zc) < 1e-4 for w in vs_d), \
                    'falta esquina del dintel (%.2f, %.2f, %.4f)' % (
                        sx, sy, zc)
    print('DINTEL_HUNDIDO z=[%.4f..%.4f] x=[%.2f..%.2f] 8/8 esquinas'
          % (Z_DINTEL, Z_DINTEL + H_DINTEL,
             -L_DINTEL / 2.0, L_DINTEL / 2.0))

    # --- Relieve EMPOTRADO: cada glifo ATRAVIESA la cara frontal ---
    for o in glifos:
        ys = [w.y for w in vertices(o)]
        assert min(ys) < CARAS_Y < max(ys), \
            '%s NO atraviesa la cara del dintel: pintura/flotante' % o.name
    print('GLIFOS 2/2 empotrados cruzando y=%.4f' % CARAS_Y)

    # --- Algas colgantes: nacen en la marea y bajan a la zona sumergida ---
    for o in algas:
        z0, z1 = cotas_z(o)
        assert abs(z1 - MAREA) < 1e-4 and z0 < MAREA - 0.10, \
            '%s no cuelga desde la marea (%.4f..%.4f)' % (o.name, z0, z1)

    camara(escena, 'CAM_Sumerg', loc=(3.10, -3.40, 2.30),
           mira=(0.0, -0.15, 0.95))
    shade_flat(escena)
    ruta = guardar(escena, MODULO, ASSET)
    print('VARIANTE %s | SM_=%d | criticas=%d | marea=%.4f | z_max=%.4f '
          '| z_min=%.4f | toca=%d | fp=%.2fx%.2f'
          % (ASSET, len(ps), len(criticas), MAREA, z_max, z_fin,
             toca, fp_x, fp_y))
    return ruta


def main():
    construir()
    print('LISTO — estructura sumergida parcial (1 asset M25, cota derivada '
          'de suelo_losa_intermedia 0.5 voxel)')


if __name__ == '__main__':
    main()
