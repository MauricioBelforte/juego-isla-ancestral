# crear_valla_madera_lowpoly.py — Valla de madera, modulo RECTO + ESQUINA (M40)
#
# Checklist `CHECKLIST-OBJETOS-BLENDER.md` L194,
#   `02-Backlog-Pendientes-Assets.md` L34 y
#   `DOCUMENTACION/TAREAS-POR-MODELO/HY4/40-Infraestructura/checklist.md` L14:
#   "Valla de madera (modulo recto + esquina)" seguia `[ ]`.
# Medido 2026-11-08 20:37 -0300: 0 GLB, 0 generador y 0 `.blend` con `valla`
#   en `40-Infraestructura` / `assets/3d`.
#
# ===========================================================================
# HUECO DE SPEC (publicado, NO rellenado en silencio)
# ===========================================================================
# `grep -rn valla DOCUMENTACION/40-Infraestructura/` da 0 resultados en los
#   5 documentos de `plan-actual/`: M40 es un modulo de SOFTWARE (autoloads,
#   ServiceRegistry, EventBus, Bootstrap), NO un catalogo de props 3D. La
#   unica definicion existente es el rotulo del backlog "modulo recto +
#   esquina". En consecuencia TODAS las cotas, materiales y silueta de abajo
#   son DECISION DE AUTORIA derivada y documentada, NUNCA una cita de spec:
#
#   1 voxel = 1.00 m ........ convencion del proyecto ya usada en M25
#                              (actas 19/25/26/27: pieza 16 `columna` 1x1x3).
#   LARGO_RECTO = 2.00 m .... 2 voxels, mismo modulo que `muro_recto` 1x2.
#   BRAZO_ESQUINA = 1.00 m .. 1 voxel por brazo; la L une dos tramos de 1 m.
#   ALTO = 1.00 m ........... 1 voxel (valla de media altura, cozy).
#   ESPESOR = 0.12 m ........ poste/travesano de seccion 0.12 (E-68: caja()
#                              recibe la DIMENSION FINAL, no la mitad).
#   BASA = 0.36 x 0.36 m .... decision de AUTORIA para satisfacer E-50: sin
#                              basa, la huella del modulo recto seria
#                              2.00 x 0.12 y `min_fp=0.30` FALLARIA. Un dado
#                              de madera tratada en la base de cada poste es
#                              coherente con una valla y da huella real 0.36.
#   Z_APOYO = 0.045 ......... E-12 (arena top 0.05, E-67).
#
# DOS MODULOS, NO UNO: el precedente medido de "2 variantes" es
#   `crear_columna_rota_lowpoly.py` (B10-bis): un generador, sufijos
#   `_alta`/`_baja` y 6 GLB (2 assets x 3 LOD). Aca se replica con
#   `valla_madera_recto` y `valla_madera_esquina`. El exportador ya tiene
#   `40-Infraestructura` en su whitelist (linea 71), no hay que tocarlo.
#
# LECTURA DE "ESQUINA" (senal geometrica POSITIVA, medible en el BIN):
#   el modulo esquina tiene 3 postes (0,0), (0.94,0), (0,0.94), 4 travesanos
#   (2 por brazo) y tablas en AMBOS ejes. En glTF (Y-up, z = -y_Blender) eso
#   produce una L con masa en x>0.8/z~0 (brazo X) y en x~0/z<-0.8 (brazo Y).
#   El recto, en cambio, tiene range_x >= 1.9 y range_z <= 0.5. La guardia
#   verifica AMBAS cosas y que el nombre del GLB coincide con la forma.
#
# ===========================================================================
# PRESUPUESTO M166 Y DISENO FINAL DE LOS 3 LOD (REVISADO EN ESTE CICLO)
# ===========================================================================
#   BAJA: <= 6 objetos / <= 700 tris / <= 4 materiales.
#   `generar_variante.py` agrupa los NO criticos por LISTA de materiales.
#   Las 4 criticas estructurales `_NOFUNDIR` son:
#     1) Basas+Postes (Madera)   2) Travesanos (Madera)
#     3) Tablas (Tablas)         4) Remates (Madera)
#
# TRAMPA 1 MEDIDA (2026-11-08): la FASE 0 de `generar_variante.py` poda en
#   BAJA todo objeto NO critico con `volumen_bbox` < UMBRAL_PODA (1e-4).
#   Con clavos de 0.03x0.02x0.03 como objetos INDIVIDUALES desaparecian los
#   4 clavos del recto y los 6 de la esquina, y el BAJA perdia el Herraje
#   (3 materiales). FIX: los clavos se UNEN en UNA malla en ALTA y ademas se
#   marcan `_NOFUNDIR`, para que NUNCA se poden, fundan ni decimaten.
#
# TRAMPA 2 MEDIDA (2026-11-08, la que motivo este rediseno): el DECIMATE
#   sobre mallas de CAJAS DISJUNTAS siempre rompe la geometria. Barrido
#   medido sobre `valla_madera_recto` con la sonda por objeto:
#     ratio 1.00 -> 0 defectos | 0.95 -> 8 | 0.90 -> 8 | 0.85 -> 6
#     ratio 0.80 -> 10         | 0.70 -> 12
#   El colapso de aristas mueve vertices FUERA de los planos autoriados
#   (p. ej. y=-0.0617 donde solo debia haber -0.055/-0.075), generando
#   quads inclinados y triangulos en AMBOS grupos de detalle (Herraje y
#   Musgo). `chk_asset.py` daba BAJA OK porque mide COSTE, no FORMA: es la
#   misma familia del panel colapsado de B15, aca en sub-centimetros y por
#   eso INVISIBLE en las capturas. Solo una sonda geometrica lo detecta.
#   CONCLUSION: para este asset NO hay ratio < 1.0 valido. Se elimina el
#   decimate por completo (0 mallas decimadas) en lugar de publicar un
#   BAJA deformado.
#
# LOD REAL SIN DECIMATE (decision de autoria, MEDIDA antes de publicar):
#   ALTA  = 7 objetos / 4 materiales: 4 criticas + Clavos `_NOFUNDIR` +
#           2 manchas de musgo SUELTAS de 0.08x0.02x0.05 (8e-5 m3).
#   MEDIA = 6 objetos / 4 materiales: las 2 manchas se funden en
#           `SM_Valla_M_Valla_Musgo` (merge lossless, mismos tris).
#   BAJA  = 5 objetos / 3 materiales: la FASE 0 PODA las 2 manchas por
#           volumen < 1e-4, no queda NINGUN objeto fusionable y el
#           DECIMATE actua sobre 0 mallas. Menos draw calls, menos tris y
#           CERO caras inclinadas. La perdida del musgo en BAJA es un LOD
#           deliberado y documentado, NO un accidente de poda.
#   Desviacion respecto del plan del mensaje 45 (que preveia 4/4/4
#   materiales): se publica en el canal y en el acta 28, no en silencio.
#
# ZONA VACIA (guardia anti-cunia): entre la tapa de la basa (z=0.145) y el
#   primer travesano (z=0.30) NO hay ningun vertice de ninguna caja. Un
#   colapso que generara una cunia introduciria niveles en (0.16, 0.26).
#   La guardia nueva verifica ademas, en el BIN del GLB, que TODOS los
#   niveles de coordenada de BAJA son SUBCONJUNTO de los de ALTA: eso
#   detecta cualquier vertice fuera de plano aunque no cambie la altura.
#
# Reglas aplicadas (GUIA-BLENDER / plantilla_asset.py):
#   E-12 Z_APOYO = 0.045 · E-24 zmin_real() sobre VERTICES reales ·
#   E-50 huella > 0.30 m en X e Y con min_toca=8 (DEFAULT, no relajado) ·
#   E-44 solo SM_* se exporta · E-42 materiales por CARAS ·
#   E-68 caja()/scale = dimension FINAL · E-27 SIN parents.
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

MODULO = '40-Infraestructura'

# --- Cotas (DECISION DE AUTORIA, ver cabecera) ---
Z = Z_APOYO                       # 0.045
LARGO = 2.00                     # modulo recto, 2 voxels
BRAZO = 1.00                     # cada brazo de la esquina, 1 voxel
PX = 0.94                        # x del poste (borde exterior en 1.00)
PY = 0.94                        # y del poste del brazo Y en la esquina
SEC = 0.12                       # seccion del poste
BASA_L = 0.36                    # dado de madera: da huella 0.36 > 0.30 (E-50)
BASA_H = 0.10                    # 0.045 .. 0.145
H_POSTE = 0.94                   # 0.045 .. 0.985
Z_REMATE = 0.985
H_REMATE = 0.06                  # 0.985 .. 1.045
REM_L = 0.18
Y_CIMA = Z_REMATE + H_REMATE     # 1.045
TRAV_Z = (0.35, 0.80)           # centros de los 2 travesanos
TRAV_SX, TRAV_SY, TRAV_SZ = 2.00, 0.08, 0.10
TAB_Z = 0.575                    # 0.275 .. 0.875
TAB_SZ = 0.60
TAB_Y = -0.055                   # por DELANTE de los travesanos
CLAVO_SX, CLAVO_SY, CLAVO_SZ = 0.03, 0.02, 0.03
CLAVO_Y = -0.065
# 0.08 x 0.02 x 0.05 = 8e-5 m3 < UMBRAL_PODA (1e-4): en BAJA la FASE 0
# poda estas 2 manchas y el LOD baja de coste SIN ningun decimate.
MUSGO_SX, MUSGO_SY, MUSGO_SZ = 0.08, 0.02, 0.05
MUSGO_Z = 0.09                   # 0.065 .. 0.115
assert MUSGO_SX * MUSGO_SY * MUSGO_SZ < 1e-4, \
    'el musgo debe ser podable en BAJA (UMBRAL_PODA=1e-4)'
VACIA_LO, VACIA_HI = 0.16, 0.26 # zona anti-cunia

assert abs(Y_CIMA - 1.045) < 1e-9, 'cota superior incoherente'
assert BASA_L > 0.30, 'la basa no satisface E-50 (min_fp=0.30)'
assert Z + BASA_H < VACIA_LO < VACIA_HI < TRAV_Z[0] - TRAV_SZ / 2.0, \
    'la zona vacia no queda entre basa y travesano'
assert TRAV_Z[0] - TRAV_SZ / 2.0 > TAB_Z - TAB_SZ / 2.0, \
    'el travesano inferior debe quedar dentro del rango de las tablas'


def vertices(o):
    """Vertices REALES de mundo (E-24)."""
    return [o.matrix_world @ v.co for v in o.data.vertices]


def niveles_y(objetos):
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


def construir(nombre, esquina):
    escena = limpiar()

    MAT_madera = mat('MAT_Valla_Madera',  (0.55, 0.38, 0.22))
    MAT_tablas = mat('MAT_Valla_Tablas',  (0.72, 0.55, 0.34))
    MAT_herraje = mat('MAT_Valla_Herraje', (0.30, 0.30, 0.32))
    MAT_musgo = mat('MAT_Valla_Musgo',   (0.26, 0.44, 0.24))

    # Posiciones de los postes: 2 en el recto, 3 en la esquina (L real).
    postes_xy = [(0.0, 0.0), (PX, 0.0), (0.0, PY)] if esquina \
        else [(-PX, 0.0), (PX, 0.0)]

    # --- CRITICA 1: basas + postes (un solo material, una sola malla) ---
    piezas_bp = []
    for i, (x, y) in enumerate(postes_xy):
        piezas_bp.append(caja('SM_Valla_Basa_%d_NOFUNDIR' % (i + 1)
                              if i == 0 else 'SM_Valla_Basa_%d' % (i + 1),
                              x, y, Z + BASA_H / 2.0,
                              BASA_L, BASA_L, BASA_H, MAT_madera))
        piezas_bp.append(caja('SM_Valla_Poste_%d' % (i + 1),
                              x, y, Z + H_POSTE / 2.0,
                              SEC, SEC, H_POSTE, MAT_madera))
    base_postes = unir('SM_Valla_Basa_1_NOFUNDIR', piezas_bp)
    base_postes.name = 'SM_Valla_Basas_Postes_NOFUNDIR'

    # --- CRITICA 2: travesanos (2 en recto, 4 en esquina) ---
    travs = []
    if esquina:
        for k, z in enumerate(TRAV_Z):
            travs.append(caja('SM_Valla_Trav_X_%d_NOFUNDIR' % (k + 1)
                              if k == 0 else 'SM_Valla_Trav_X_%d' % (k + 1),
                              BRAZO / 2.0, 0.0, z,
                              BRAZO, TRAV_SY, TRAV_SZ, MAT_madera))
            travs.append(caja('SM_Valla_Trav_Y_%d' % (k + 1),
                              0.0, BRAZO / 2.0, z,
                              TRAV_SY, BRAZO, TRAV_SZ, MAT_madera))
    else:
        for k, z in enumerate(TRAV_Z):
            travs.append(caja('SM_Valla_Trav_%d_NOFUNDIR' % (k + 1)
                              if k == 0 else 'SM_Valla_Trav_%d' % (k + 1),
                              0.0, 0.0, z,
                              TRAV_SX, TRAV_SY, TRAV_SZ, MAT_madera))
    travs_obj = unir(travs[0].name, travs)
    travs_obj.name = 'SM_Valla_Travesanos_NOFUNDIR'

    # --- CRITICA 3: tablas verticales (5 en recto, 2+2 en esquina) ---
    tabs = []
    if esquina:
        for i, x in enumerate((0.30, 0.60)):
            tabs.append(caja('SM_Valla_Tabla_X_%d' % (i + 1), x, TAB_Y, TAB_Z,
                             0.16, 0.05, TAB_SZ, MAT_tablas))
        for i, y in enumerate((0.30, 0.60)):
            tabs.append(caja('SM_Valla_Tabla_Y_%d' % (i + 1), TAB_Y, y, TAB_Z,
                             0.05, 0.16, TAB_SZ, MAT_tablas))
    else:
        for i, x in enumerate((-0.60, -0.30, 0.0, 0.30, 0.60)):
            tabs.append(caja('SM_Valla_Tabla_%d' % (i + 1), x, TAB_Y, TAB_Z,
                             0.16, 0.05, TAB_SZ, MAT_tablas))
    tabs_obj = unir(tabs[0].name, tabs)
    tabs_obj.name = 'SM_Valla_Tablas_NOFUNDIR'

    # --- CRITICA 4: remates / capitel de cada poste ---
    rems = [caja('SM_Valla_Remate_%d_NOFUNDIR' % (i + 1)
                 if i == 0 else 'SM_Valla_Remate_%d' % (i + 1),
                 x, y, Z_REMATE + H_REMATE / 2.0,
                 REM_L, REM_L, H_REMATE, MAT_madera)
            for i, (x, y) in enumerate(postes_xy)]
    rems_obj = unir('SM_Valla_Remate_1_NOFUNDIR', rems)
    rems_obj.name = 'SM_Valla_Remates_NOFUNDIR'

    # --- NO CRITICOS: clavos (Herraje) y musgo (Musgo) -> 2 grupos ---
    clavos = []
    for i, (x, y) in enumerate(postes_xy):
        for k, z in enumerate(TRAV_Z):
            clavos.append(caja('SM_Valla_Clavo_%d_%d' % (i + 1, k + 1),
                               x, CLAVO_Y if not esquina else y + CLAVO_Y,
                               z, CLAVO_SX, CLAVO_SY, CLAVO_SZ,
                               MAT_herraje))
    musgos = [caja('SM_Valla_Musgo_%d' % (i + 1), x, y - BASA_L / 2.0 - 0.01,
                   MUSGO_Z, MUSGO_SX, MUSGO_SY, MUSGO_SZ, MAT_musgo)
              for i, (x, y) in enumerate(postes_xy[:2])]

    # Clavos: UNA malla y ademas `_NOFUNDIR`. Ni poda, ni merge, ni
    # DECIMATE (Trampa 2 de la cabecera: el decimate deforma las cajas).
    # Musgo: se deja en 2 cajitas SUELTAS y pequenas a proposito; en BAJA
    # la FASE 0 las poda y ese es el LOD real. En MEDIA se funden en 1.
    clavos_obj = unir(clavos[0].name, clavos)
    clavos_obj.name = 'SM_Valla_Clavos_NOFUNDIR'
    # `musgos` ya son 2 objetos `SM_Valla_Musgo_1/2`; NO se unen aqui.

    # --- Orden canonico: arena -> luz -> asentar -> camara -> flat -> guardar ---
    arena(radio=2.6)
    iluminar(escena)
    bpy.context.view_layer.update()
    z_fin, toca, fp_x, fp_y = asentar(escena, min_toca=8, min_fp=0.30)

    ps = piezas(escena)
    assert len(ps) == 7, 'ALTA debe tener 7 SM_, hay %d' % len(ps)
    assert len({o.name for o in ps}) == len(ps), 'nombres SM_ duplicados'
    criticas = [o for o in ps if o.name.endswith('_NOFUNDIR')]
    assert len(criticas) == 5, 'deben ser 5 criticas, hay %d' % len(criticas)
    grupos = {}
    for o in ps:
        if o not in criticas:
            grupos.setdefault(tuple(m.name for m in o.data.materials),
                              []).append(o)
    assert len(grupos) == 1 and len(next(iter(grupos.values()))) == 2, \
        'debe quedar 1 grupo fusionable con las 2 manchas de musgo'
    print('LOD_PREVISTO ALTA=%d obj | criticas=%d | grupos=%d -> MEDIA=%d '
          '| BAJA(poda 2)=%d, DECIMATE=0 mallas'
          % (len(ps), len(criticas), len(grupos),
             len(criticas) + len(grupos), len(criticas)))

    for o in ps:
        z = zmin_real(o)
        assert z >= Z - 1e-4, '%s hunde %.4f < %.4f' % (o.name, z, Z)

    # --- Guardia POSITIVA de apoyo: cada basa tiene sus 4 esquinas en z=Z ---
    vs_bp = vertices(base_postes)
    n_apoyo = 0
    for x, y in postes_xy:
        for dx in (-BASA_L / 2.0, BASA_L / 2.0):
            for dy in (-BASA_L / 2.0, BASA_L / 2.0):
                ok = any(abs(w.x - (x + dx)) < 1e-4
                         and abs(w.y - (y + dy)) < 1e-4
                         and abs(w.z - Z) < 1e-4 for w in vs_bp)
                assert ok, 'falta esquina de basa en (%.2f, %.2f)' % (
                    x + dx, y + dy)
                n_apoyo += 1
    print('BASAS APOYADAS %d/%d esquinas en z=%.4f'
          % (n_apoyo, 4 * len(postes_xy), Z))

    # --- Guardia POSITIVA de altura y zona vacia (anti-cunia) ---
    z_max = max(w.z for o in ps for w in vertices(o))
    assert abs(z_max - Y_CIMA) < 1e-4, \
        'algo sobrevuela los remates: z_max=%.4f' % z_max
    niv = niveles_y(ps)
    espurios = [v for v in niv if VACIA_LO < v < VACIA_HI]
    assert not espurios, 'niveles espurios en zona vacia: %s' % espurios[:5]
    print('ALTURA_REAL z=[%.4f..%.4f] alto=%.4f | HUELLA=%.3fx%.3f'
          % (Z, z_max, z_max - Z, fp_x, fp_y))
    print('ZONA_VACIA (%.2f, %.2f): 0 niveles | niveles_y=%d'
          % (VACIA_LO, VACIA_HI, len(niv)))

    # --- Guardia POSITIVA de la L (solo esquina) ---
    if esquina:
        xs = [w.x for o in ps for w in vertices(o)]
        ys = [w.y for o in ps for w in vertices(o)]
        assert max(xs) - min(xs) > 1.0 and max(ys) - min(ys) > 1.0, \
            'la esquina no tiene dos brazos: %.2f x %.2f' % (
                max(xs) - min(xs), max(ys) - min(ys))
        brazo_x = any(w.x > 0.8 and abs(w.y) < 0.20
                      for o in ps for w in vertices(o))
        brazo_y = any(w.y > 0.8 and abs(w.x) < 0.20
                      for o in ps for w in vertices(o))
        assert brazo_x and brazo_y, \
            'falta uno de los dos brazos de la L (x=%s y=%s)' % (
                brazo_x, brazo_y)
        print('ESQUINA_EN_L 2/2 brazos | x=[%.2f..%.2f] y=[%.2f..%.2f]'
              % (min(xs), max(xs), min(ys), max(ys)))
    else:
        ys = [w.y for o in ps for w in vertices(o)]
        assert max(ys) - min(ys) < 0.50, \
            'el recto no debe tener profundidad de esquina: %.2f' % (
                max(ys) - min(ys))
        print('RECTO profundidad=%.3f (< 0.50, sin brazo Y)'
              % (max(ys) - min(ys)))

    camara(escena, 'CAM_Valla',
           loc=(2.90, -3.20, 1.90) if esquina else (3.10, -2.70, 1.60),
           mira=(0.30, 0.20, 0.55) if esquina else (0.0, 0.0, 0.55))
    shade_flat(escena)
    ruta = guardar(escena, MODULO, nombre)
    print('VARIANTE %-22s | SM_=%d | criticas=%d | tris~%d | z_min=%.4f '
          '| z_max=%.4f | toca=%d | fp=%.2fx%.2f'
          % (nombre, len(ps), len(criticas),
             sum(len(o.data.loop_triangles) for o in ps), z_fin, z_max,
             toca, fp_x, fp_y))
    return ruta


def main():
    for nombre, esquina in (('valla_madera_recto', False),
                            ('valla_madera_esquina', True)):
        construir(nombre, esquina)
    print('LISTO — 2 modulos de valla de madera')


if __name__ == '__main__':
    main()
