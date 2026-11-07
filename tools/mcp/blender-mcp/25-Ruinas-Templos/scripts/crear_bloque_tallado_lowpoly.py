# crear_bloque_tallado_lowpoly.py — Bloque de piedra tallada (módulo de muro, M25)
#
# Checklist `CHECKLIST-OBJETOS-BLENDER.md` L176 y
# `02-Backlog-Pendientes-Assets.md` L28: "Bloque de piedra tallada (modulo de
# muro)" seguia `[ ]`. Medido 2026-11-07 19:40: 0 `.blend`, 0 generador y 0 GLB
# con `bloque`/`tallad` en `25-Ruinas-Templos` (448 GLB trackeados en el juego).
#
# SPEC (medida, NO inventada): `DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md`
#   L30, pieza 6: `muro_recto` = "1x2 voxel, pared estandar", snaps "2 caras
#   (lados)". La convencion 1 voxel = 1.00 m esta medida en la pieza 16 de la
#   MISMA tabla (L40: `columna` = 1x1x3) y aplicada en `columna_entera_lowpoly`
#   (H = 3.00 m, huella 1.00 x 1.00 m, log 2338).
#   => ANCHO = 1.00 m, ALTO = 2.00 m.
#
# DECISION DE AUTORIA (documentada, no tomada de la spec): FONDO = 0.40 m.
#   La spec no fija el espesor del muro; 0.40 m es el minimo que deja la huella
#   de apoyo por encima del umbral E-50 (`min_fp = 0.30` en AMBOS ejes) sin
#   inventar un muro de 1 voxel de profundidad. La cornisa vuela 4 cm por lado
#   (1.08 x 0.46 m): es una moldura, NO parte de la huella de apoyo.
#
# DIFERENCIA EXPLICITA CON `columna_entera`: alla H = 3.00 era la COTA ABSOLUTA
#   (z_max = 3.00 con z_min = 0.045 -> alto fisico 2.955 m). ACA se mide el
#   ALTO FISICO del modulo desde su propia base: z_min = 0.045,
#   z_max = 2.045, `chk_asset.py` imprime `alto = 2.000`. Se documenta la
#   diferencia para que no se herede en silencio una cota distinta.
#
# Reglas aplicadas (GUIA-BLENDER / plantilla_asset.py):
#   E-12  Z_APOYO = 0.045 (arena top 0.05, E-67)
#   E-24  zmin_real() sobre VERTICES reales, nunca bound_box
#   E-50  huella > 0.30 m en X e Y; `min_toca=4` (ver nota abajo)
#   E-44  solo SM_* se exporta; Base_Arena / SOL / CAM_* se purgan
#   E-42  materiales contados POR CARAS (lo mide chk_asset.py)
#   E-68  caja()/scale = dimension FINAL, no la mitad
#
# NOTA SOBRE `min_toca = 4`: el default 8 de `asentar()` fue calibrado para un
#   plinto CUADRADO (4 vertices) + una basa CIRCULAR (12 vertices), caso real de
#   `columna_entera`. Un sillar rectangular tiene EXACTAMENTE 4 vertices en su
#   cara inferior y 0.40 m2 de apoyo: no es "apoyo puntual" (E-50). Se baja el
#   conteo de vertices, NO el guard de huella (min_fp = 0.30 se mantiene) y se
#   verifica ademas que las 4 esquinas esten presentes. La guardia externa
#   `verificar_bloque_tallado.py` vuelve a medirlo en los 3 LOD.
#
# DECISION DE 4 MATERIALES: `generar_variante.py` agrupa por LISTA de
#   materiales y en BAJA poda a 4. Con exactamente 4 la poda es un NO-OP:
#   ninguna pieza de identidad se blanquea. El merge deja 4 mallas + las 2
#   piezas `_NOFUNDIR` = 6 objetos, exactamente el techo BAJA (<= 6).
#   Mismo criterio que T-01c/T-01d/T-02/columna_entera/M18-BIS.
#
# `_NOFUNDIR` (mecanismo DOCUMENTADO de `generar_variante.py::es_critica()`):
#   protege ZOCALO, CUERPO, CORNISA y PANEL de poda/merge/decimate. Lección
#   medida en `columna_entera` (log 2338): el decimate a 0.70 colapsa las
#   piezas delgadas y `chk_asset.py` sigue dando OK porque mide COSTE, no FORMA.
#
# DEFECTOS MEDIDOS 2026-11-07 EN LAS DOS PRIMERAS BAJAS (ratio 0.70):
#   v1 (sin proteger panel): `chk_asset.py` OK BAJA (6 obj / 136 tris / 4 mats,
#     alto 2.000, z_min 0.0450) pero la hoja de contacto mostraba el PANEL
#     COLAPSADO en una cuña triangular (az000/az240/az300) y aire bajo cornisa.
#   v2 (panel protegido): OK BAJA (6 obj / 140 tris / 4 mats) y PERSISTIA una
#     cuña diagonal bajo la cornisa + franja oscura en az060/az240. Causa
#     medida: el merge de `MAT_Bloque_Piedra` quedaba con UN SOLO cubo;
#     decimate 0.70 sobre un cubo de 12 tris lo convierte en una cuña.
#   v3 (solucion): 4 criticas (zocalo/cuerpo/cornisa/panel) + 2 mallas
#     fusionadas (Tallado, Musgo) = 6 objetos, exactamente el techo BAJA. El
#     decimate solo actua sobre el RELIEVE, nunca sobre la silueta portante.
#   No se toca el script compartido: la proteccion vive en los nombres de las
#   piezas de ESTE generador.
#
# GUARDA POSITIVA DE RELIEVE: un bloque "tallado" no puede ser una caja con un
#   color distinto. Se mide que panel, medallon, glifos, pilastras y musgo
#   ATRAVIESAN el plano de la cara del muro (y = -0.20) o del panel
#   (y = -0.216): si no lo cruzan, son piezas FLOTANTES pintadas.
#
# Autoría 100 % headless: blender -b --factory-startup --python <este>.
# No requiere GUI ni socket 127.0.0.1:9876 (E-55 / E-56).
import bpy
import os
import sys
import math

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja, piezas, zmin_real,
                             Z_APOYO)

MODULO = '25-Ruinas-Templos'
ASSET = 'bloque_tallado'

# --- Cotas (spec 1x2 voxel; ALTO es la ALTURA FISICA desde Z_APOYO) ---
ANCHO = 1.00
FONDO = 0.40
ALTO = 2.00
Z = Z_APOYO                         # 0.045
Z_TOP = Z + ALTO                    # 2.045

ZOC_H = 0.18
ZOC_TOP = Z + ZOC_H                 # 0.225
CUE_H = 1.62
CUE_TOP = ZOC_TOP + CUE_H           # 1.845
COR_H = ALTO - ZOC_H - CUE_H        # 0.20
COR_TOP = CUE_TOP + COR_H           # 2.045 == Z_TOP
assert abs(COR_TOP - Z_TOP) < 1e-9, 'la cota superior debe cerrar en Z_TOP'
assert COR_H >= 0.15, 'cornisa demasiado delgada para sobrevivir al LOD'

Y_CARA = -FONDO / 2.0               # -0.200 : cara frontal del muro
COR_ANCHO, COR_FONDO = 1.08, 0.46    # moldura que vuela 4 cm por lado

# Panel tallado empotrado en la cara frontal
PAN_W, PAN_H, PAN_SY = 0.72, 1.18, 0.030
PAN_Y = -0.201                       # -0.216 .. -0.186 (atraviesa Y_CARA)
PAN_FRONT = PAN_Y - PAN_SY / 2.0     # -0.216
PAN_Z = ZOC_TOP + CUE_H / 2.0        # 1.035
PAN_Z0, PAN_Z1 = PAN_Z - PAN_H / 2.0, PAN_Z + PAN_H / 2.0

# Medallon circular + 4 glifos: el relieve que justifica "piedra tallada"
MED_R, MED_SY, MED_LADOS = 0.17, 0.030, 12
MED_Y = -0.220                       # -0.235 .. -0.205 (atraviesa PAN_FRONT)
GLIFO_SX, GLIFO_SY, GLIFO_SZ = 0.10, 0.024, 0.10
GLIFOS = ((-0.28, -0.38), (0.28, -0.38), (-0.28, 0.38), (0.28, 0.38))
GLIFO_Y = -0.220

# Pilastras laterales (dos fajas verticales) y musgo en el zocalo
PIL_SX, PIL_SY, PIL_SZ = 0.07, 0.024, 1.26
PIL_Y = -0.202                       # -0.214 .. -0.190 (atraviesa Y_CARA)
MUS_SX, MUS_SY, MUS_SZ = 0.16, 0.020, 0.06
MUS_Y = -0.204                       # -0.214 .. -0.194 (atraviesa Y_CARA)
MUS_Z = Z + 0.10


def cotas(o):
    """(z_min, z_max) medidos en VERTICES REALES de mundo (E-24)."""
    zs = [(o.matrix_world @ v.co).z for v in o.data.vertices]
    return min(zs), max(zs)


def ys(o):
    """(y_min, y_max) medidos en VERTICES REALES de mundo."""
    yy = [(o.matrix_world @ v.co).y for v in o.data.vertices]
    return min(yy), max(yy)


def cilindro_y(nombre, lados, radio, profundo, loc, material):
    """Cilindro con eje en Y (disco frontal), para el medallon tallado."""
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=lados, radius=radio, depth=profundo,
        location=loc, rotation=(math.pi / 2.0, 0.0, 0.0))
    o = bpy.context.object
    o.name = nombre
    o.data.materials.append(material)
    return o


def construir():
    escena = limpiar()

    MAT_piedra = mat('MAT_Bloque_Piedra',   (0.56, 0.54, 0.49))
    MAT_osc    = mat('MAT_Bloque_Oscuro',   (0.38, 0.36, 0.33))
    MAT_talla  = mat('MAT_Bloque_Tallado',  (0.72, 0.68, 0.58))
    MAT_musgo  = mat('MAT_Bloque_Musgo',    (0.30, 0.44, 0.21))

    # --- 1) Zocalo: 4 esquinas en Z_APOYO, huella 1.00 x 0.40 ---
    zocalo = caja('SM_Bloque_Zocalo_NOFUNDIR', 0.0, 0.0, Z + ZOC_H / 2.0,
                  ANCHO, FONDO, ZOC_H, MAT_osc)

    # --- 2) Cuerpo del muro (sillar central) ---
    cuerpo = caja('SM_Bloque_Cuerpo_NOFUNDIR', 0.0, 0.0, ZOC_TOP + CUE_H / 2.0,
                  ANCHO, FONDO, CUE_H, MAT_piedra)

    # --- 3) Cornisa / remate moldurado, vuela 4 cm por lado ---
    cornisa = caja('SM_Bloque_Cornisa_NOFUNDIR', 0.0, 0.0, CUE_TOP + COR_H / 2.0,
                   COR_ANCHO, COR_FONDO, COR_H, MAT_piedra)

    # --- 4) Panel rebajado: ATRAVIESA la cara frontal del muro ---
    panel = caja('SM_Bloque_Panel_NOFUNDIR', 0.0, PAN_Y, PAN_Z,
                 PAN_W, PAN_SY, PAN_H, MAT_osc)

    # --- 5) Medallon circular tallado, empotrado en el panel ---
    medallon = cilindro_y('SM_Bloque_Medallon', MED_LADOS, MED_R, MED_SY,
                          (0.0, MED_Y, PAN_Z), MAT_talla)

    # --- 6) 4 glifos en relieve alrededor del medallon ---
    glifos = []
    for i, (dx, dz) in enumerate(GLIFOS):
        glifos.append(caja('SM_Bloque_Glifo_%d' % (i + 1), dx, GLIFO_Y,
                           PAN_Z + dz, GLIFO_SX, GLIFO_SY, GLIFO_SZ, MAT_talla))

    # --- 7) 2 pilastras flanqueando el panel ---
    pilastras = []
    for i, x in enumerate((-0.43, 0.43)):
        pilastras.append(caja('SM_Bloque_Pilastra_%d' % (i + 1), x, PIL_Y,
                              PAN_Z, PIL_SX, PIL_SY, PIL_SZ, MAT_talla))

    # --- 8) 2 manchas de musgo en la cara frontal del zocalo ---
    musgos = []
    for i, x in enumerate((-0.34, 0.34)):
        musgos.append(caja('SM_Bloque_Musgo_%d' % (i + 1), x, MUS_Y, MUS_Z,
                           MUS_SX, MUS_SY, MUS_SZ, MAT_musgo))

    # --- Orden canonico: arena -> luz -> asentar -> camara -> flat -> guardar ---
    arena()
    iluminar(escena)
    bpy.context.view_layer.update()
    z_fin, toca, fp_x, fp_y = asentar(escena, min_toca=4, min_fp=0.30)

    ps = piezas(escena)
    assert len(ps) <= 16, 'excede presupuesto ALTA: %d SM_' % len(ps)
    assert len({o.name for o in ps}) == len(ps), 'nombres SM_ duplicados'

    for o in ps:
        z = zmin_real(o)
        assert z >= Z - 1e-4, '%s hunde %.4f < %.4f' % (o.name, z, Z)
        print('APOYO_PIEZA %-28s z_min=%.4f' % (o.name, z))

    # --- Guardia POSITIVA de altura y huella (spec 1x2 voxel) ---
    z_max = max((o.matrix_world @ v.co).z for o in ps for v in o.data.vertices)
    assert abs(z_max - z_fin - ALTO) < 1e-4, \
        'alto fisico %.4f != %.2f (spec M25)' % (z_max - z_fin, ALTO)
    assert abs(fp_x - ANCHO) < 1e-4 and abs(fp_y - FONDO) < 1e-4, \
        'huella %.4f x %.4f != %.2f x %.2f' % (fp_x, fp_y, ANCHO, FONDO)
    print('ALTURA_REAL z=[%.4f..%.4f] alto=%.4f HUELLA=%.4fx%.4f'
          % (z_fin, z_max, z_max - z_fin, fp_x, fp_y))

    # --- Cadena de uniones: sin AIRE entre sillar, cuerpo y cornisa ---
    CADENA = (
        (zocalo, cuerpo, ZOC_TOP),
        (cuerpo, cornisa, CUE_TOP),
    )
    for abajo, arriba, cota in CADENA:
        _, top_abajo = cotas(abajo)
        base_arriba, _ = cotas(arriba)
        assert abs(top_abajo - cota) < 1e-4 and abs(base_arriba - cota) < 1e-4, \
            'AIRE o desalineacion entre %s y %s (cota %.4f)' % (
                abajo.name, arriba.name, cota)
        print('UNION %-24s -> %-24s z=%.4f sin aire'
              % (abajo.name, arriba.name, cota))

    # --- Relieve EMPOTRADO: cada pieza decorativa cruza su plano de apoyo ---
    y_panel = ys(panel)
    assert y_panel[0] < Y_CARA < y_panel[1], \
        'el panel NO atraviesa la cara y=%.3f (flotaria)' % Y_CARA
    for g in [medallon] + glifos + pilastras + musgos:
        y0, y1 = ys(g)
        plano = PAN_FRONT if (g is medallon or g in glifos) else Y_CARA
        assert y0 < plano < y1, \
            '%s NO atraviesa y=%.4f (y=%.4f..%.4f): pieza pintada/flotante' % (
                g.name, plano, y0, y1)
        z0, z1 = cotas(g)
        assert z0 >= Z - 1e-4 and z1 <= Z_TOP + 1e-4, \
            '%s fuera del rango Z del modulo' % g.name
        print('UNION %-28s empotrado (y %.4f..%.4f vs plano %.4f)'
              % (g.name, y0, y1, plano))

    # --- Musgo confinado al zocalo (no tapa el panel) ---
    for m in musgos:
        z0, z1 = cotas(m)
        assert z1 <= ZOC_TOP + 1e-4, '%s invade el cuerpo del muro' % m.name

    # --- Glifos y medallon dentro del panel (no cuelgan fuera) ---
    for g in glifos:
        xs = [(g.matrix_world @ v.co).x for v in g.data.vertices]
        assert min(xs) > -PAN_W / 2.0 and max(xs) < PAN_W / 2.0, \
            '%s se sale del panel' % g.name

    camara(escena, 'CAM_Bloque', loc=(2.60, -3.10, 1.55),
           mira=(0.0, 0.0, Z + ALTO * 0.50))
    shade_flat(escena)
    ruta = guardar(escena, MODULO, ASSET)
    print('VARIANTE %s | SM_=%d | ALTO=%.2f | z_min=%.4f | toca=%d | fp=%.2fx%.2f'
          % (ASSET, len(ps), ALTO, z_fin, toca, fp_x, fp_y))
    return ruta


def main():
    construir()
    print('LISTO — bloque de piedra tallada (1 asset, spec muro_recto 1x2 voxel)')


if __name__ == '__main__':
    main()
