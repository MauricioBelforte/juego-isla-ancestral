# crear_columna_entera_lowpoly.py — Columna entera con capitel (M25 Ruinas)
#
# Checklist `CHECKLIST-OBJETOS-BLENDER.md` L175 y `02-Backlog-Pendientes-Assets.md`
# L27: "Columna entera con capitel" seguia `[ ]`. Medido 2026-11-06: 0 `.blend`
# y 0 GLB con `columna_entera`/`capitel` en M25.
#
# SPEC (medida, no inventada): `DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md`
# L40, pieza 16: `columna` = 1x1x3, soporte vertical, snap "arriba/abajo".
# Por eso H = 3.00 m y la huella del plinto es exactamente 1.00 x 1.00 m.
# Es la pieza COMPLETA que complementa a `pilar_roto` (pieza 17, 1x1x1.5),
# ya cerrada en B10 con `crear_columna_rota_lowpoly.py`.
#
# Reglas aplicadas (GUIA-BLENDER / plantilla_asset.py):
#   E-12  Z_APOYO = 0.045 (arena top 0.05, E-67)
#   E-24  zmin_real() sobre VERTICES reales, nunca bound_box
#   E-50  >= 8 vertices tocando y huella > 0.30 m en X e Y
#   E-44  solo SM_* se exporta; Base_Arena / SOL / CAM_* se purgan
#   E-42  materiales contados POR CARAS (lo mide chk_asset.py)
#   E-68  caja()/scale = dimension FINAL, no la mitad
#   E-77  anillos de loft en orden (z, cx, cy, rx, ry) con z crecientes
#
# DECISION DE 4 MATERIALES: `generar_variante.py` agrupa por LISTA de
# materiales y en BAJA poda a 4. Con exactamente 4 la poda es un NO-OP:
# ninguna pieza de identidad se blanquea y el merge da 4 objetos (<= 6 BAJA).
# Mismo criterio que T-01c/T-01d/T-02.
#
# DEFECTO MEDIDO 2026-11-06 (decimate BAJA sobre losas delgadas):
#   con el ratio 0.70 por defecto, el ABACO (caja 0.90x0.90x0.14) se
#   colapsaba: sus 4 caras laterales completas (base 2.78 -> tope 2.92)
#   desaparecian y aparecian vertices a 2.8267/2.8733. En la hoja de capturas
#   se veia un diamante plano con aire debajo de la losa. `chk_asset.py` daba
#   OK BAJA (342/700 tris, 4/6 obj, 4/4 mats): el presupuesto NO detecta la
#   geometria rota. Barrido medido de ratios:
#     ratio 1.00 -> 4 caras / 492 tris   (intacto, pero sin LOD real)
#     ratio 0.95 -> 2 caras / 464 tris
#     ratio 0.90 -> 1 cara  / 438 tris
#     ratio 0.85 -> 1 cara  / 416 tris
#     ratio 0.80 -> 0 caras / 388 tris
#     ratio 0.70 -> 0 caras / 342 tris
#   Ningun decimate < 1.0 conserva la losa. SOLUCION 1 (parcial): marcar el
#   abaco con el sufijo `_NOFUNDIR` (mecanismo DOCUMENTADO de
#   `generar_variante.py`, `es_critica()`), que lo excluye de poda/merge/
#   decimate. BAJA quedo 5 obj / 346 tris / 4 mats con 4 caras en abaco Y
#   remate... pero la GUARDIA C4 encontro UN SEGUNDO DANIO que chk_asset no ve:
#   la huella de apoyo paso de 1.0000x1.0000 (16 vertices) a 1.0000x0.8800
#   (14 vertices): el decimate se comio 2 esquinas del PLINTO en Z_APOYO.
#   SOLUCION FINAL: `_NOFUNDIR` en ABACO **y** PLINTO. Resultado medido con el
#   ratio 0.70 estandar: BAJA 5 obj / 350 tris / 4 mats, guardia 27/0 verde.
#   No se toca el script compartido: la proteccion vive en los nombres de las
#   piezas de ESTE generador. Guardia positiva: `verificar_columna_entera.py`.
#
# GUARDAS POSITIVAS DE UNION: una columna es una PILA de piezas que NO tocan
# el suelo. Que `z_min >= Z_APOYO` NO demuestra que el capitel este pegado al
# fuste (trampa de la pieza no portante). Por eso se mide, tramo por tramo,
# que el tope de la pieza inferior coincide con la base de la superior.
# Tambien se mide que glifos y musgo estan EMPOTRADOS en el plinto, no flotando.
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
                             shade_flat, guardar, caja, loft, piezas,
                             zmin_real, Z_APOYO)

MODULO = '25-Ruinas-Templos'
ASSET = 'columna_entera'

# --- Cotas absolutas (H = 3.00 m segun M25 03-Diseno.md L40) ---
H = 3.00
LADO = 1.00                       # huella 1x1 del plinto
Z = Z_APOYO                       # 0.045

PLINTO_H = 0.14
PLINTO_TOP = Z + PLINTO_H         # 0.185
BASA_R = 0.38
BASA_H = 0.30
BASA_TOP = Z + BASA_H             # 0.345 -> arranca el fuste
Z_CUELLO = 2.48                   # tope del fuste / base del collar
COLLAR_H = 0.06
COLLAR_TOP = Z_CUELLO + COLLAR_H  # 2.54
EQUINO_TOP = 2.78
ABACO_H = 0.14
ABACO_TOP = EQUINO_TOP + ABACO_H  # 2.92
REMATE_H = 0.08
REMATE_TOP = ABACO_TOP + REMATE_H # 3.00 == H
assert abs(REMATE_TOP - H) < 1e-9, 'la cota superior debe cerrar en H=3.00'
assert BASA_TOP < Z_CUELLO - 1.0, 'fuste demasiado corto'

LADOS_FUSTE = 24
N_FLUTAS = 8
LADOS_EQUINO = 16

# 4 glifos tallados en la cara FRONTAL del plinto (y = -LADO/2).
# El centro esta 4 mm por detras de la cara: la caja la ATRAVIESA 6 mm y
# sobresale 14 mm. Sin esa interseccion el glifo seria una pieza flotante.
GLIFOS = (-0.30, -0.10, 0.10, 0.30)
Y_CARA = -LADO / 2.0
GLIFO_Y = -0.504
GLIFO_SY = 0.020

# 2 manchas de musgo sobre el plinto, FUERA del radio de la basa para que
# no queden tapadas por el tambor circular.
MUSGO = (
    ('SM_ColEnt_Musgo_1', -0.40,  0.36, 0.14, 0.10),
    ('SM_ColEnt_Musgo_2',  0.38, -0.36, 0.12, 0.10),
)
MUSGO_SZ = 0.018

# Solo estas dos piezas apoyan en la arena; el resto vive apilado.
APOYAN = ('SM_ColEnt_Plinto_NOFUNDIR', 'SM_ColEnt_Basa')


def cilindro(nombre, vertices, radio, profundo, loc, material):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radio,
                                        depth=profundo, location=loc)
    o = bpy.context.object
    o.name = nombre
    o.data.materials.append(material)
    return o


def cotas(o):
    """(z_min, z_max) medidos en VERTICES REALES de mundo (E-24)."""
    zs = [(o.matrix_world @ v.co).z for v in o.data.vertices]
    return min(zs), max(zs)


def construir():
    escena = limpiar()

    MAT_piedra = mat('MAT_ColEnt_Piedra',     (0.56, 0.54, 0.49))
    MAT_osc    = mat('MAT_ColEnt_PiedraOsc',  (0.38, 0.36, 0.33))
    MAT_talla  = mat('MAT_ColEnt_Tallado',    (0.72, 0.68, 0.58))
    MAT_musgo  = mat('MAT_ColEnt_Musgo',      (0.30, 0.44, 0.21))

    # --- 1) Plinto cuadrado: 4 vertices en Z_APOYO, huella 1.00 x 1.00 ---
    caja('SM_ColEnt_Plinto_NOFUNDIR', 0.0, 0.0, Z + PLINTO_H / 2.0,
         LADO, LADO, PLINTO_H, MAT_osc)

    # --- 2) Basa circular: 12 vertices TAMBIEN en Z_APOYO (E-50: 16 tocando) ---
    cilindro('SM_ColEnt_Basa', 12, BASA_R, BASA_H,
             (0.0, 0.0, Z + BASA_H / 2.0), MAT_piedra)

    # --- 3) Fuste acanalado (8 flutas, 24 lados) con ligero entasis ---
    anillos = [
        (BASA_TOP,        0.0, 0.0, 0.270, 0.270),
        (BASA_TOP + 0.05, 0.0, 0.0, 0.258, 0.258),
        (Z_CUELLO - 0.08, 0.0, 0.0, 0.238, 0.238),
        (Z_CUELLO,        0.0, 0.0, 0.238, 0.238),
    ]
    loft('SM_ColEnt_Fuste', anillos, MAT_piedra, lados=LADOS_FUSTE,
         ondas=(0.040, N_FLUTAS), tapar_abajo=False, tapar_arriba=True)

    # --- 4) Collar / astragalo: remate del fuste ---
    cilindro('SM_ColEnt_Collar', 24, 0.262, COLLAR_H,
             (0.0, 0.0, Z_CUELLO + COLLAR_H / 2.0), MAT_talla)

    # --- 5) Equino: capitel que ABRE desde el fuste hasta el abaco ---
    loft('SM_ColEnt_Equino',
         [(COLLAR_TOP,       0.0, 0.0, 0.245, 0.245),
          (COLLAR_TOP + 0.08, 0.0, 0.0, 0.305, 0.305),
          (EQUINO_TOP,       0.0, 0.0, 0.400, 0.400)],
         MAT_piedra, lados=LADOS_EQUINO,
         tapar_abajo=False, tapar_arriba=True)

    # --- 6) Abaco + remate: la coronacion cuadrada, cota final H = 3.00 ---
    caja('SM_ColEnt_Abaco_NOFUNDIR', 0.0, 0.0, EQUINO_TOP + ABACO_H / 2.0,
         0.90, 0.90, ABACO_H, MAT_osc)
    caja('SM_ColEnt_Remate', 0.0, 0.0, ABACO_TOP + REMATE_H / 2.0,
         0.96, 0.96, REMATE_H, MAT_talla)

    # --- 7) Glifos tallados en la cara frontal del plinto ---
    glifos = []
    for i, x in enumerate(GLIFOS):
        g = caja('SM_ColEnt_Glifo_%d' % (i + 1), x, GLIFO_Y,
                 Z + PLINTO_H / 2.0, 0.075, GLIFO_SY, 0.075, MAT_talla)
        glifos.append(g)

    # --- 8) Musgo sobre el plinto ---
    musgos = []
    for nombre, x, y, sx, sy in MUSGO:
        m = caja(nombre, x, y, PLINTO_TOP + 0.004,
                 sx, sy, MUSGO_SZ, MAT_musgo)
        musgos.append(m)

    # --- Orden canonico: arena -> luz -> asentar -> camara -> flat -> guardar ---
    arena()
    iluminar(escena)
    bpy.context.view_layer.update()
    z_fin, toca, fp_x, fp_y = asentar(escena)

    ps = piezas(escena)
    assert len(ps) <= 16, 'excede presupuesto ALTA: %d SM_' % len(ps)
    by_name = {o.name: o for o in ps}
    assert len(by_name) == len(ps), 'nombres SM_ duplicados'

    for o in ps:
        z = zmin_real(o)
        assert z >= Z - 1e-4, '%s hunde %.4f < %.4f' % (o.name, z, Z)
        if o.name in APOYAN:
            assert abs(z - Z) < 1e-4, \
                '%s FLOTA: z_min %.4f (objetivo %.4f)' % (o.name, z, Z)
        print('APOYO_PIEZA %-28s z_min=%.4f' % (o.name, z))

    # --- Guardia POSITIVA de altura y de huella (spec 1x1x3) ---
    z_max = max((o.matrix_world @ v.co).z for o in ps for v in o.data.vertices)
    assert abs(z_max - H) < 1e-4, \
        'altura real %.4f != H=%.2f (spec M25)' % (z_max, H)
    assert abs(fp_x - LADO) < 1e-4 and abs(fp_y - LADO) < 1e-4, \
        'huella %.4f x %.4f != 1.00 x 1.00' % (fp_x, fp_y)
    print('ALTURA_REAL z_max=%.4f (H=%.2f) HUELLA=%.4fx%.4f'
          % (z_max, H, fp_x, fp_y))

    # --- Cadena de uniones: el tope de ABAJO debe ser la base de ARRIBA ---
    CADENA = (
        ('SM_ColEnt_Basa',   'SM_ColEnt_Fuste',  BASA_TOP),
        ('SM_ColEnt_Fuste',  'SM_ColEnt_Collar', Z_CUELLO),
        ('SM_ColEnt_Collar', 'SM_ColEnt_Equino', COLLAR_TOP),
        ('SM_ColEnt_Equino', 'SM_ColEnt_Abaco_NOFUNDIR',  EQUINO_TOP),
        ('SM_ColEnt_Abaco_NOFUNDIR',  'SM_ColEnt_Remate', ABACO_TOP),
    )
    for abajo, arriba, cota in CADENA:
        _, top_abajo = cotas(by_name[abajo])
        base_arriba, _ = cotas(by_name[arriba])
        assert abs(top_abajo - cota) < 1e-4, \
            '%s: tope %.4f != cota %.4f' % (abajo, top_abajo, cota)
        assert abs(base_arriba - cota) < 1e-4, \
            '%s: base %.4f != cota %.4f' % (arriba, base_arriba, cota)
        assert abs(top_abajo - base_arriba) < 1e-4, \
            'AIRE entre %s y %s' % (abajo, arriba)
        print('UNION %-20s -> %-20s z=%.4f sin aire'
              % (abajo.replace('SM_ColEnt_', ''),
                 arriba.replace('SM_ColEnt_', ''), cota))

    # --- Glifos EMPOTRADOS en la cara del plinto (no flotando) ---
    plinto = by_name['SM_ColEnt_Plinto_NOFUNDIR']
    p_min, p_max = cotas(plinto)
    for g in glifos:
        g_min, g_max = cotas(g)
        ys = [(g.matrix_world @ v.co).y for v in g.data.vertices]
        assert g_min >= p_min - 1e-4 and g_max <= p_max + 1e-4, \
            '%s fuera del rango Z del plinto' % g.name
        assert min(ys) < Y_CARA and max(ys) > Y_CARA, \
            '%s NO atraviesa la cara y=%.3f (flotaria)' % (g.name, Y_CARA)
        print('UNION %-20s empotrado en plinto (y %.4f..%.4f vs cara %.4f)'
              % (g.name, min(ys), max(ys), Y_CARA))

    # --- Musgo APOYADO sobre el plinto y FUERA de la basa ---
    for m in musgos:
        m_min, m_max = cotas(m)
        assert m_min < PLINTO_TOP and m_max > PLINTO_TOP, \
            '%s no atraviesa el tope del plinto (flotaria)' % m.name
        rs = [math.hypot((m.matrix_world @ v.co).x,
                         (m.matrix_world @ v.co).y)
              for v in m.data.vertices]
        assert min(rs) > BASA_R + 0.02, \
            '%s queda tapado por la basa (r_min %.4f)' % (m.name, min(rs))
        print('UNION %-20s sobre plinto (r_min=%.4f > %.4f)'
              % (m.name, min(rs), BASA_R))

    camara(escena, 'CAM_ColEnt', loc=(3.40, -4.00, 2.20),
           mira=(0.0, 0.0, H * 0.50))
    shade_flat(escena)
    ruta = guardar(escena, MODULO, ASSET)
    print('VARIANTE %s | SM_=%d | H=%.2f | z_min=%.4f | toca=%d | fp=%.2fx%.2f'
          % (ASSET, len(ps), H, z_fin, toca, fp_x, fp_y))
    return ruta


def main():
    construir()
    print('LISTO — columna entera con capitel (1 asset, spec 1x1x3)')


if __name__ == '__main__':
    main()
