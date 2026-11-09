# crear_carrito_vias_lowpoly.py — Carrito de vías sobre tramo corto de riel (M35 / L40)
#
# Checklist `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` L230,
#   `HY4/BACKLOGS/02-Backlog-Pendientes-Assets.md` L40 y
#   `DOCUMENTACION/TAREAS-POR-MODELO/HY4/35-Mineria/checklist.md` L13:
#   "Carrito de vias" seguia `[ ]`.
# Medido 2026-11-09 00:10 -0300: 0 GLB `carrito_vias`, 0 generador y 0 `.blend`
#   con ese nombre. El unico parecido es `35-Mineria_carretilla_minero.glb`
#   (carretilla de MANO, rueda de 14 lados + 2 mangos), NO un carrito sobre
#   rieles. L40 sigue abierta.
#
# ===========================================================================
# HUECO DE SPEC (publicado en el canal 51, NO rellenado en silencio)
# ===========================================================================
# Primer grep SIN tildes (`carrito|vagon|vias|riel|minecart`) sobre
#   `DOCUMENTACION/26-Templo-Subterraneo/` y `DOCUMENTACION/35-Mineria/`
#   dio 0. Repetido CON tildes (`v[ií]as`, `vag[oó]n`) da 7 coincidencias, y
#   las 7 son la misma cosa: `m26_spec.md` y los `02/03/05-Checklist` hablan
#   de las **"3 vias de orientacion" del vestibulo** (nucleo / Guarda de la
#   Brisa / Artesano), es decir CORREDORES, no rieles. Ningun documento define
#   el carrito, sus cotas, sus ruedas ni sus rieles. Se publica la distincion
#   en vez de declarar un "0 resultados" enganoso.
#   TODAS las cotas, silueta y materiales de abajo son DECISION DE AUTORIA
#   documentada, NUNCA una cita de spec inexistente.
#
#   1 voxel = 1.00 m ........ convencion del proyecto (M25, actas 19/25/26/27).
#   Z_APOYO = 0.045 ......... E-12 (arena top 0.05, E-67).
#   AMBITO "26 subterraneo" . es el encuadre NARRATIVO, no el modulo de assets:
#                              las 3 fuentes encuadran el item en M35 Mineria.
#                              Destino `35-Mineria_carrito_vias.glb`, que YA
#                              esta en `MODULOS` de `exportar_godot.py` L70:
#                              NO se crea modulo ni se toca el exportador
#                              (fallo silencioso E-63 / T-02).
#   TRAMO DE VIA INCLUIDO ... decision de AUTORIA: un carrito suelto tendria
#                              huella de contacto 0.60 x 0.64 y FALLARIA E-50
#                              por apoyo puntual. Se modela SOBRE un tramo
#                              corto de via de 1.40 x 0.69 m con 5 traviesas:
#                              huella de CONTACTO 1.24 x 0.69 y 20 vertices
#                              apoyados. Es un prop de galeria minera, NO una
#                              escena integrada ni un sistema de railes.
#   GEOMETRIA AXIS-ALIGNED .. TODAS las piezas son cajas en planos ortogonales.
#                              Ademas de la estetica voxel, eso permite una
#                              guardia POSITIVA por NIVELES DE COORDENADA en
#                              el BIN del GLB (misma familia que B18/B19).
#
# ===========================================================================
# PRESUPUESTO M166 Y DISENO DE LOS 3 LOD (MEDIDO ANTES DE PUBLICAR)
# ===========================================================================
#   ALTA  = 10 objetos / 7 materiales: 4 criticas `_NOFUNDIR` + 6 detalles.
#           22 cajas x 12 tris = 264 tris.
#   MEDIA =  7 objetos / 7 materiales: FASE 1 funde los 6 detalles en 3 grupos
#            por lista de material (merge LOSSLESS, mismos 264 tris).
#   BAJA  =  4 objetos / 4 materiales: la FASE 0 de `generar_variante.py`
#            PODA los 6 detalles porque CADA UNO tiene volumen_bbox < 1e-4,
#            y al no quedar NINGUN objeto no-critico el DECIMATE actua sobre
#            0 mallas. 16 cajas x 12 tris = 192 tris.
#            LOD REAL por poda deliberada, SIN deformacion.
#
# LECCION APLICADA DE B18 (acta 28) Y B19 (acta 29): el DECIMATE sobre cajas
#   disjuntas mueve vertices FUERA de los planos autorizados (12 defectos en
#   valla recto, 10 en esquina), invisible en el render y NO detectado por
#   `chk_asset.py`, que mide COSTE, no FORMA. Aca se evita POR DISENIO:
#   0 mallas decimadas. Los 6 detalles se dejan SUELTOS y pequenos a proposito
#   para que la poda sea el LOD. No se unen en ALTA. Ademas ningun nombre de
#   detalle contiene un sufijo de `PROTEGIDAS` ('Pie','Base','Soporte',
#   'Tronco','Poste','Cuerpo','Tapa'), que inhibiria la poda en silencio.
#
# ZONA VACIA (guardia anti-cunia): entre el tope del riel (z=0.135) y el tope
#   de las ruedas / piso de la batea (z=0.295) NO hay NIVELES de vertices en
#   (0.15, 0.28). Un colapso de aristas introduciria niveles espurios ahi.
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
ASSET = 'carrito_vias'

# --- Cotas (DECISION DE AUTORIA, ver cabecera) ---
Z = Z_APOYO                       # 0.045

# VIA: 2 rieles de 1.40 m sobre 5 traviesas de 0.69 m de ancho.
RIEL_SX, RIEL_SY, RIEL_SZ = 1.40, 0.06, 0.05
RIEL_YS = (-0.30, 0.30)
TRAV_SX, TRAV_SY, TRAV_SZ = 0.12, 0.69, 0.04
TRAV_XS = (-0.56, -0.28, 0.0, 0.28, 0.56)
TRAV_Z = Z + TRAV_SZ / 2.0                   # 0.065 -> 0.045..0.085
RIEL_Z = Z + TRAV_SZ + RIEL_SZ / 2.0        # 0.110 -> 0.085..0.135
Z_RIEL_TOPE = Z + TRAV_SZ + RIEL_SZ         # 0.135

# RUEDAS: 4 cajas apoyadas SOBRE el riel, en x=+-0.30 / y=+-0.30.
RUED_SX, RUED_SY, RUED_SZ = 0.16, 0.04, 0.16
RUED_XS = (-0.30, 0.30)
RUED_YS = (-0.30, 0.30)
RUED_Z = Z_RIEL_TOPE + RUED_SZ / 2.0        # 0.215 -> 0.135..0.295
Z_RUED_TOPE = Z_RIEL_TOPE + RUED_SZ         # 0.295

# BATEA: piso + 2 paredes largas + 2 testeros, abierta arriba.
BAT_SX, BAT_SY = 0.84, 0.48
PISO_SZ = 0.05
PISO_Z = Z_RUED_TOPE + PISO_SZ / 2.0        # 0.320 -> 0.295..0.345
Z_PISO_TOPE = Z_RUED_TOPE + PISO_SZ         # 0.345
PARED_ALTO, PARED_ESP = 0.28, 0.05
PARED_Z = Z_PISO_TOPE + PARED_ALTO / 2.0    # 0.485 -> 0.345..0.625
Y_CIMA = Z_PISO_TOPE + PARED_ALTO           # 0.625
LADO_Y = BAT_SY / 2.0 - PARED_ESP / 2.0     # 0.215
LADO_X = BAT_SX / 2.0 - PARED_ESP / 2.0     # 0.395

# DETALLES (6), TODOS podables en BAJA por volumen_bbox < UMBRAL_PODA.
TOP_SX, TOP_SY, TOP_SZ = 0.05, 0.05, 0.03   # 7.50e-5 m3
TOP_XS = (-0.45, 0.45)
TOP_Z = 0.515                                # 0.500..0.530
ASA_SX, ASA_SY, ASA_SZ = 0.04, 0.04, 0.06   # 9.60e-5 m3
ASA_YS = (-0.26, 0.26)
ASA_Z = 0.55                                 # 0.520..0.580
MIN_SX, MIN_SY, MIN_SZ = 0.05, 0.05, 0.035  # 8.75e-5 m3
MIN_XS = (-0.12, 0.12)
MIN_Z = 0.40                                 # 0.3825..0.4175

VACIA_LO, VACIA_HI = 0.15, 0.28   # zona anti-cunia
UMBRAL_PODA = 1e-4                # FASE 0 de generar_variante.py
PROTEGIDAS = ('pie', 'base', 'soporte', 'tronco', 'poste', 'cuerpo', 'tapa')

assert abs(Y_CIMA - 0.625) < 1e-9, 'cota superior incoherente'
assert TRAV_SY > 0.30 and (TRAV_XS[-1] + TRAV_SX / 2.0) * 2.0 > 0.30, \
    'las traviesas no satisfacen E-50 (min_fp=0.30)'
assert len(TRAV_XS) * 4 >= 8, 'las traviesas no aportan 8 vertices de apoyo'
assert Z_RIEL_TOPE < VACIA_LO < VACIA_HI < Z_RUED_TOPE, \
    'la zona vacia no queda entre el riel y el piso de la batea'
assert TOP_SX * TOP_SY * TOP_SZ < UMBRAL_PODA, 'topes deben ser podables'
assert ASA_SX * ASA_SY * ASA_SZ < UMBRAL_PODA, 'asas deben ser podables'
assert MIN_SX * MIN_SY * MIN_SZ < UMBRAL_PODA, 'mineral debe ser podable'
for _n in ('SM_Carrito_Tope_1', 'SM_Carrito_Asa_1', 'SM_Carrito_Mineral_1'):
    assert not any(p in _n.lower() for p in PROTEGIDAS), \
        '%s contiene un sufijo PROTEGIDAS: la FASE 0 no lo podaria' % _n


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

    MADERA_OSC = mat('MAT_Carrito_MaderaOsc', (0.34, 0.23, 0.14))
    HIERRO = mat('MAT_Carrito_Hierro',       (0.42, 0.44, 0.47),
                 rough=0.55, spec=0.30)
    MADERA = mat('MAT_Carrito_Madera',       (0.58, 0.40, 0.23))
    HIERRO_OSC = mat('MAT_Carrito_HierroOsc', (0.22, 0.24, 0.27),
                     rough=0.60, spec=0.25)
    HERRAJE = mat('MAT_Carrito_Herraje',     (0.70, 0.58, 0.30),
                  rough=0.55, spec=0.30)
    CUERDA = mat('MAT_Carrito_Cuerda',       (0.76, 0.68, 0.48))
    MINERAL = mat('MAT_Carrito_Mineral',     (0.28, 0.62, 0.60),
                  rough=0.40, spec=0.45)

    # --- CRITICA 1: 5 traviesas (20 verts apoyados, huella 1.24 x 0.69) ---
    travs = [caja('SM_Carrito_Traviesa_1_NOFUNDIR' if i == 0
                  else 'SM_Carrito_Traviesa_%d' % (i + 1),
                  x, 0.0, TRAV_Z, TRAV_SX, TRAV_SY, TRAV_SZ, MADERA_OSC)
             for i, x in enumerate(TRAV_XS)]
    traviesas = unir('SM_Carrito_Traviesa_1_NOFUNDIR', travs)
    traviesas.name = 'SM_Carrito_Traviesas_NOFUNDIR'

    # --- CRITICA 2: 2 rieles de 1.40 m ---
    riels = [caja('SM_Carrito_Riel_1_NOFUNDIR' if i == 0
                  else 'SM_Carrito_Riel_%d' % (i + 1),
                  0.0, y, RIEL_Z, RIEL_SX, RIEL_SY, RIEL_SZ, HIERRO)
             for i, y in enumerate(RIEL_YS)]
    rieles = unir('SM_Carrito_Riel_1_NOFUNDIR', riels)
    rieles.name = 'SM_Carrito_Rieles_NOFUNDIR'

    # --- CRITICA 3: 4 ruedas ---
    rueds = [caja('SM_Carrito_Rueda_1_NOFUNDIR' if k == 0
                  else 'SM_Carrito_Rueda_%d' % (k + 1),
                  x, y, RUED_Z, RUED_SX, RUED_SY, RUED_SZ, HIERRO_OSC)
             for k, (x, y) in enumerate((x, y) for x in RUED_XS
                                        for y in RUED_YS)]
    ruedas = unir('SM_Carrito_Rueda_1_NOFUNDIR', rueds)
    ruedas.name = 'SM_Carrito_Ruedas_NOFUNDIR'

    # --- CRITICA 4: batea abierta (piso + 2 lados + 2 testeros) ---
    bp = [caja('SM_Carrito_Batea_Piso_NOFUNDIR', 0.0, 0.0, PISO_Z,
               BAT_SX, BAT_SY, PISO_SZ, MADERA)]
    for i, y in enumerate((-LADO_Y, LADO_Y)):
        bp.append(caja('SM_Carrito_Batea_Lado_%d' % (i + 1), 0.0, y,
                       PARED_Z, BAT_SX, PARED_ESP, PARED_ALTO, MADERA))
    for i, x in enumerate((-LADO_X, LADO_X)):
        bp.append(caja('SM_Carrito_Batea_Testero_%d' % (i + 1), x, 0.0,
                       PARED_Z, PARED_ESP, BAT_SY, PARED_ALTO, MADERA))
    batea = unir('SM_Carrito_Batea_Piso_NOFUNDIR', bp)
    batea.name = 'SM_Carrito_Batea_NOFUNDIR'

    # --- NO CRITICOS (6), TODOS podables en BAJA por volumen < 1e-4 ---
    topes = [caja('SM_Carrito_Tope_%d' % (i + 1), x, 0.0, TOP_Z,
                  TOP_SX, TOP_SY, TOP_SZ, HERRAJE)
             for i, x in enumerate(TOP_XS)]
    asas = [caja('SM_Carrito_Asa_%d' % (i + 1), 0.0, y, ASA_Z,
                 ASA_SX, ASA_SY, ASA_SZ, CUERDA)
            for i, y in enumerate(ASA_YS)]
    minerales = [caja('SM_Carrito_Mineral_%d' % (i + 1), x, 0.0, MIN_Z,
                      MIN_SX, MIN_SY, MIN_SZ, MINERAL)
                 for i, x in enumerate(MIN_XS)]
    detalles = topes + asas + minerales

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
        vol = bb.x * bb.y * bb.z
        assert vol < UMBRAL_PODA, \
            '%s NO es podable (vol=%.2g)' % (d.name, vol)
    mats = {m.name for o in ps for m in o.data.materials if m}
    assert len(mats) == 7, 'ALTA debe tener 7 materiales, hay %d' % len(mats)
    print('LOD_PREVISTO ALTA=%d obj/%d mats | criticas=%d | detalles=%d '
          '-> MEDIA=7 | BAJA(poda 6)=4, DECIMATE=0 mallas'
          % (len(ps), len(mats), len(criticas), len(detalles)))

    # --- Procedencia POSITIVA de las 4 criticas (5/2/4/5 cajas) ---
    for o, n in ((traviesas, 40), (rieles, 16), (ruedas, 32), (batea, 40)):
        assert len(vertices(o)) == n, \
            '%s deberia tener %d vertices (cajas sin colapsar), hay %d' \
            % (o.name, n, len(vertices(o)))

    for o in ps:
        zz = zmin_real(o)
        assert zz >= Z - 1e-4, '%s hunde %.4f < %.4f' % (o.name, zz, Z)

    # --- Guardia POSITIVA de apoyo: 20 esquinas de traviesa en z=Z ---
    vs_trav = vertices(traviesas)
    n_apoyo = 0
    for x in TRAV_XS:
        for dx in (-TRAV_SX / 2.0, TRAV_SX / 2.0):
            for dy in (-TRAV_SY / 2.0, TRAV_SY / 2.0):
                ok = any(abs(w.x - (x + dx)) < 1e-4
                         and abs(w.y - dy) < 1e-4
                         and abs(w.z - Z) < 1e-4 for w in vs_trav)
                assert ok, 'falta esquina de traviesa en (%.2f, %.2f)' % (
                    x + dx, dy)
                n_apoyo += 1
    print('TRAVIESAS APOYADAS %d/20 esquinas en z=%.4f' % (n_apoyo, Z))

    # --- Guardia POSITIVA de altura, rieles y zona vacia ---
    z_max = max(w.z for o in ps for w in vertices(o))
    assert abs(z_max - Y_CIMA) < 1e-4, \
        'algo sobrevuela el borde de la batea: z_max=%.4f' % z_max
    xs = [w.x for o in ps for w in vertices(o)]
    assert abs(min(xs) + 0.70) < 1e-4 and abs(max(xs) - 0.70) < 1e-4, \
        'los rieles no alcanzan el tramo de 1.40 m: x=[%.3f..%.3f]' \
        % (min(xs), max(xs))
    niv = niveles_z(ps)
    espurios = [v for v in niv if VACIA_LO < v < VACIA_HI]
    assert not espurios, 'niveles espurios en zona vacia: %s' % espurios[:5]
    print('ALTURA_REAL z=[%.4f..%.4f] alto=%.4f | HUELLA_CONTACTO=%.2fx%.2f '
          '| BBOX=1.40x0.69 | toca=%d'
          % (Z, z_max, z_max - Z, fp_x, fp_y, toca))
    print('ZONA_VACIA (%.2f, %.2f): 0 niveles | niveles_z=%d'
          % (VACIA_LO, VACIA_HI, len(niv)))

    # --- Guardia POSITIVA de silueta: ruedas SOBRE el riel, batea ARRIBA ---
    vr = vertices(ruedas)
    vb = vertices(batea)
    assert any(abs(w.z - Z_RIEL_TOPE) < 1e-4 for w in vr), \
        'las ruedas no apoyan sobre el tope del riel'
    assert any(abs(w.z - Z_RUED_TOPE) < 1e-4 for w in vb), \
        'la batea no apoya sobre el tope de las ruedas'
    assert all(w.z >= Z_RIEL_TOPE - 1e-4 for w in vr), \
        'una rueda atraviesa el riel'
    print('ENSAMBLE riel->rueda->batea OK | ruedas=%d verts batea=%d verts'
          % (len(vr), len(vb)))

    camara(escena, 'CAM_Carrito_Vias', (2.20, -2.40, 1.30), (0.0, 0.0, 0.35))
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
    print('LISTO — carrito de vias sobre tramo de riel (M35 / L40)')
