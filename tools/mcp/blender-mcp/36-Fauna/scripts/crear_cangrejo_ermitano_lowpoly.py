# crear_cangrejo_ermitano_lowpoly.py — Cangrejo ermitano sobre rodela de marea (M36 / L39)
#
# Checklist `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` L228,
#   `HY4/BACKLOGS/02-Backlog-Pendientes-Assets.md` L39 y
#   `DOCUMENTACION/TAREAS-POR-MODELO/HY4/35-Mineria/checklist.md` L13:
#   "Cangrejo ermitano (recompensa rara)" seguia `[ ]`.
# Medido 2026-11-09 01:20 -0300: 0 GLB `*cangrejo_ermit*`, 0 generador y 0
#   `.blend` con ese nombre. El parecido `36-Fauna_cangrejo_playa.glb` (3 LOD,
#   9-sep) es un CANGREJO COMUN SIN CONCHA; el ermitano se distingue por la
#   CARACOLA que habita. No es un duplicado: el hueco sigue abierto.
#
# ===========================================================================
# ANCLA DE SPEC REAL (a diferencia de B19/B20, donde la spec estaba ausente)
# ===========================================================================
# `DOCUMENTACION/36-Fauna/plan-inicial/01-Requerimientos.md:29`:
#   | Cangrejo Ermitano | Playa | Comun | Diurno | Todas |
#   | CURIOSO (se acerca lentamente) | aparece tras la marea alta |
# `DOCUMENTACION/36-Fauna/plan-inicial/04-Codigo.md:205`: `cangrejo_ermitano`
#   entre las 5 especies de prototipo del flujo de fauna.
#
# CONTRADICCION MEDIDA, PUBLICADA Y **NO RESUELTA**: los 3 checklists rotulan
#   el item "recompensa rara"; el catalogo M36 lo declara **"Comun"**. La rareza
#   la decide el DIRECTOR. Hy4 modela la ESPECIE del catalogo y NO edita
#   `01-Requerimientos.md` ni ningun checklist.
# Ningun documento define COTAS, SILUETA, MATERIALES ni la concha. TODAS las
#   cotas de abajo son DECISION DE AUTORIA documentada, NUNCA cita de spec.
#
#   1 voxel = 1.00 m ........ convencion del proyecto (M25, actas 19/25/26/27).
#   Z_APOYO = 0.045 ......... E-12 (arena top 0.05, E-67).
#   AMBITO "34/35" .......... los 3 checklists encuadran el item bajo
#                              "Modulo 34 - Pesca / 35 - Mineria". Ese es el
#                              encuadre NARRATIVO, NO el modulo de assets:
#                              `grep -c '34-Pesca' exportar_godot.py` = 0,
#                              asi que un GLB bajo 34-Pesca exportaria
#                              **0 archivos EN SILENCIO** (E-63 / T-02, fallo
#                              ya sufrido en T-01a y T-02). `36-Fauna` YA esta
#                              en `MODULOS` (L70). Destino:
#                              `36-Fauna_cangrejo_ermitano.glb`.
#                              NO se crea modulo ni se toca el exportador.
#   RODELA DE MAREA ......... decision de AUTORIA: un cangrejo suelto tendria
#                              huella de contacto ~0.20 x 0.18 y FALLARIA
#                              E-50 (min_fp=0.30, min_toca=8). Se modela sobre
#                              3 franjas de arena humeda (ripples tras la marea
#                              alta, el disparador del catalogo) de 0.44 x 0.36
#                              con **12 vertices apoyados**. Es un PROP de
#                              diorama, NO una escena integrada.
#   CONCHA ESCALONADA ....... 4 cajas decrecientes + 1 labio = la caracola. Es
#                              el rasgo que DIFERENCIA al ermitano del cangrejo
#                              de playa ya existente.
#   GEOMETRIA AXIS-ALIGNED .. TODAS las piezas son cajas en planos ortogonales.
#                              Ademas de la estetica voxel, permite una guardia
#                              POSITIVA por NIVELES DE COORDENADA en el BIN del
#                              GLB (misma familia que B18/B19/B20).
#
# ===========================================================================
# PRESUPUESTO M166 Y DISENO DE LOS 3 LOD (MEDIDO ANTES DE PUBLICAR)
# ===========================================================================
#   ALTA  = 10 objetos / 7 materiales: 4 criticas `_NOFUNDIR` + 6 detalles.
#           25 cajas x 12 tris = 300 tris.
#   MEDIA =  7 objetos / 7 materiales: FASE 1 funde los 6 detalles en 3 grupos
#            por lista de material (merge LOSSLESS, mismos 300 tris).
#   BAJA  =  4 objetos / 4 materiales: la FASE 0 de `generar_variante.py`
#            PODA los 6 detalles porque CADA UNO tiene volumen_bbox < 1e-4,
#            y al no quedar NINGUN objeto no-critico el DECIMATE actua sobre
#            0 mallas. 19 cajas x 12 tris = 228 tris.
#            LOD REAL por poda deliberada, SIN deformacion.
#
# LECCION APLICADA DE B18 (acta 28), B19 (acta 29) Y B20 (acta 30): el
#   DECIMATE sobre cajas disjuntas mueve vertices FUERA de los planos
#   autorizados (12 defectos en valla recto, 10 en esquina), invisible en el
#   render y NO detectado por `chk_asset.py`, que mide COSTE, no FORMA. Aca se
#   evita POR DISENIO: 0 mallas decimadas. Los 6 detalles se dejan SUELTOS y
#   pequenos a proposito. Ademas ningun nombre de detalle contiene un sufijo
#   de `PROTEGIDAS` ('Pie','Base','Soporte','Tronco','Poste','Cuerpo','Tapa'),
#   que inhibiria la poda EN SILENCIO.
#
# ZONA VACIA (guardia anti-cunia): entre el tope de los ojos (z=0.285) y la
#   base del apice de la concha (z=0.355) NO hay NIVELES de vertices en
#   (0.29, 0.35). Un colapso de aristas introduciria niveles espurios ahi.
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

MODULO = '36-Fauna'
ASSET = 'cangrejo_ermitano'

# --- Cotas (DECISION DE AUTORIA, ver cabecera) ---
Z = Z_APOYO                       # 0.045

# RODELA DE MAREA: 3 franjas de arena humeda (12 vertices apoyados).
AR_SX, AR_SY, AR_SZ = 0.44, 0.10, 0.04
AR_YS = (-0.13, 0.0, 0.13)
AR_Z = Z + AR_SZ / 2.0                       # 0.065 -> 0.045..0.085
Z_AR_TOPE = Z + AR_SZ                       # 0.085

# CONCHA ESCALONADA: 4 cajas decrecientes desplazadas en +X (espira voxel).
CONCHA = (
    (-0.05, 0.0, 0.135, 0.30, 0.24, 0.10),   # T1 0.085..0.185
    (-0.03, 0.0, 0.230, 0.24, 0.20, 0.09),   # T2 0.185..0.275
    (-0.01, 0.0, 0.315, 0.18, 0.15, 0.08),   # T3 0.275..0.355
    ( 0.01, 0.0, 0.390, 0.11, 0.10, 0.07),   # T4 0.355..0.425
)
LABIO = (0.115, 0.0, 0.135, 0.04, 0.20, 0.10)  # boca, 0.085..0.185
Y_CIMA = 0.425

# CUERPO: abdomen + 2 pedunculos + 4 patas
ABD = (0.19, 0.0, 0.130, 0.16, 0.14, 0.09)     # 0.085..0.175
PED_SX, PED_SY, PED_SZ = 0.025, 0.025, 0.075
PED_X = 0.235
PED_YS = (-0.045, 0.045)
PED_Z = 0.2125                                  # 0.175..0.250
PAT_SX, PAT_SY, PAT_SZ = 0.05, 0.06, 0.025
PAT_XS = (0.15, 0.23)
PAT_YS = (-0.10, 0.10)
PAT_Z = 0.0975                                  # 0.085..0.110

# PINZAS: 2 brazos + 2 tenazas
BRA_SX, BRA_SY, BRA_SZ = 0.10, 0.035, 0.035
BRA_X, BRA_Z = 0.24, 0.145                     # 0.1275..0.1625
TEN_SX, TEN_SY, TEN_SZ = 0.055, 0.06, 0.055
TEN_X, TEN_Z = 0.30, 0.145                     # 0.1175..0.1725
PIN_YS = (-0.105, 0.105)
TEN_YS = (-0.115, 0.115)

# DETALLES (6), TODOS podables en BAJA por volumen_bbox < UMBRAL_PODA.
OJO_SX, OJO_SY, OJO_SZ = 0.045, 0.045, 0.035  # 7.0875e-5 m3
OJO_X, OJO_Z = 0.235, 0.2675                   # 0.250..0.285
BUR_SX, BUR_SY, BUR_SZ = 0.05, 0.05, 0.03     # 7.50e-5 m3
BUR_X, BUR_Z = -0.19, 0.100                    # 0.085..0.115
CON_SX, CON_SY, CON_SZ = 0.05, 0.05, 0.035    # 8.75e-5 m3
CON_X, CON_Z = 0.19, 0.1025                    # 0.085..0.120
ESQ_Y = (-0.155, 0.155)

VACIA_LO, VACIA_HI = 0.29, 0.35   # zona anti-cunia
UMBRAL_PODA = 1e-4                # FASE 0 de generar_variante.py
PROTEGIDAS = ('pie', 'base', 'soporte', 'tronco', 'poste', 'cuerpo', 'tapa')

assert abs(Y_CIMA - 0.425) < 1e-9, 'cota superior incoherente'
assert AR_SX > 0.30 and (AR_YS[-1] + AR_SY / 2.0) * 2.0 > 0.30, \
    'la rodela no satisface E-50 (min_fp=0.30)'
assert len(AR_YS) * 4 >= 8, 'la rodela no aporta 8 vertices de apoyo'
assert 0.285 < VACIA_LO < VACIA_HI < 0.355, \
    'la zona vacia no queda entre los ojos y el apice de la concha'
for _s, _v in (('ojo', OJO_SX * OJO_SY * OJO_SZ),
               ('burbuja', BUR_SX * BUR_SY * BUR_SZ),
               ('conchita', CON_SX * CON_SY * CON_SZ)):
    assert _v < UMBRAL_PODA, '%s NO es podable (vol=%.2g)' % (_s, _v)
for _n in ('SM_Cangrejo_Ojo_1', 'SM_Cangrejo_Burbuja_1',
           'SM_Cangrejo_Conchita_1'):
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

    ARENA_H = mat('MAT_Cangrejo_ArenaHumeda', (0.62, 0.55, 0.42))
    CONCHA_M = mat('MAT_Cangrejo_Concha', (0.78, 0.62, 0.42))
    CAPARAZON = mat('MAT_Cangrejo_Caparazon', (0.72, 0.30, 0.22))
    PINZA_M = mat('MAT_Cangrejo_Pinza', (0.85, 0.42, 0.30))
    OJO_M = mat('MAT_Cangrejo_Ojo', (0.10, 0.10, 0.12),
                rough=0.35, spec=0.55)
    ESPUMA_M = mat('MAT_Cangrejo_Espuma', (0.92, 0.94, 0.92))
    NACAR_M = mat('MAT_Cangrejo_Nacar', (0.80, 0.78, 0.86),
                  rough=0.45, spec=0.40)

    # --- CRITICA 1: 3 franjas de arena humeda (12 verts, huella 0.44x0.36) ---
    frs = [caja('SM_Cangrejo_Franja_1_NOFUNDIR' if i == 0
                else 'SM_Cangrejo_Franja_%d' % (i + 1),
                0.0, y, AR_Z, AR_SX, AR_SY, AR_SZ, ARENA_H)
           for i, y in enumerate(AR_YS)]
    rodela = unir('SM_Cangrejo_Franja_1_NOFUNDIR', frs)
    rodela.name = 'SM_Cangrejo_Rodela_NOFUNDIR'

    # --- CRITICA 2: concha escalonada (4 tiers + labio de la boca) ---
    cp = [caja('SM_Cangrejo_Concha_T1_NOFUNDIR' if i == 0
               else 'SM_Cangrejo_Concha_T%d' % (i + 1),
               x, y, z, sx, sy, sz, CONCHA_M)
          for i, (x, y, z, sx, sy, sz) in enumerate(CONCHA)]
    cp.append(caja('SM_Cangrejo_Concha_Labio', *LABIO, CONCHA_M))
    concha = unir('SM_Cangrejo_Concha_T1_NOFUNDIR', cp)
    concha.name = 'SM_Cangrejo_Concha_NOFUNDIR'

    # --- CRITICA 3: cuerpo (abdomen + 2 pedunculos + 4 patas) ---
    cb = [caja('SM_Cangrejo_Abdomen_NOFUNDIR', *ABD, CAPARAZON)]
    for i, y in enumerate(PED_YS):
        cb.append(caja('SM_Cangrejo_Pedunculo_%d' % (i + 1),
                       PED_X, y, PED_Z, PED_SX, PED_SY, PED_SZ, CAPARAZON))
    k = 0
    for x in PAT_XS:
        for y in PAT_YS:
            k += 1
            cb.append(caja('SM_Cangrejo_Pata_%d' % k,
                           x, y, PAT_Z, PAT_SX, PAT_SY, PAT_SZ, CAPARAZON))
    cuerpo = unir('SM_Cangrejo_Abdomen_NOFUNDIR', cb)
    cuerpo.name = 'SM_Cangrejo_Cuerpo_NOFUNDIR'

    # --- CRITICA 4: 2 pinzas (brazo + tenaza cada una) ---
    pz = []
    for i, y in enumerate(PIN_YS):
        pz.append(caja('SM_Cangrejo_Brazo_%d' % (i + 1),
                       BRA_X, y, BRA_Z, BRA_SX, BRA_SY, BRA_SZ, PINZA_M))
    for i, y in enumerate(TEN_YS):
        pz.append(caja('SM_Cangrejo_Tenaza_%d' % (i + 1),
                       TEN_X, y, TEN_Z, TEN_SX, TEN_SY, TEN_SZ, PINZA_M))
    pinzas = unir('SM_Cangrejo_Brazo_1', pz)
    pinzas.name = 'SM_Cangrejo_Pinzas_NOFUNDIR'

    # --- NO CRITICOS (6), TODOS podables en BAJA por volumen < 1e-4 ---
    ojos = [caja('SM_Cangrejo_Ojo_%d' % (i + 1),
                 OJO_X, y, OJO_Z, OJO_SX, OJO_SY, OJO_SZ, OJO_M)
            for i, y in enumerate(PED_YS)]
    burbujas = [caja('SM_Cangrejo_Burbuja_%d' % (i + 1),
                     BUR_X, y, BUR_Z, BUR_SX, BUR_SY, BUR_SZ, ESPUMA_M)
                for i, y in enumerate(ESQ_Y)]
    conchitas = [caja('SM_Cangrejo_Conchita_%d' % (i + 1),
                      CON_X, y, CON_Z, CON_SX, CON_SY, CON_SZ, NACAR_M)
                 for i, y in enumerate(ESQ_Y)]
    detalles = ojos + burbujas + conchitas

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

    # --- Procedencia POSITIVA de las 4 criticas: 8 verts por caja ---
    # 3 franjas = 24, concha 5 = 40, cuerpo 7 = 56, pinzas 4 = 32.
    for o, n in ((rodela, 24), (concha, 40), (cuerpo, 56), (pinzas, 32)):
        assert len(vertices(o)) == n, \
            '%s deberia tener %d vertices (cajas sin colapsar), hay %d' \
            % (o.name, n, len(vertices(o)))

    for o in ps:
        zz = zmin_real(o)
        assert zz >= Z - 1e-4, '%s hunde %.4f < %.4f' % (o.name, zz, Z)

    # --- Guardia POSITIVA de apoyo: 12 esquinas de franja en z=Z ---
    vs_ar = vertices(rodela)
    n_apoyo = 0
    for y in AR_YS:
        for dx in (-AR_SX / 2.0, AR_SX / 2.0):
            for dy in (-AR_SY / 2.0, AR_SY / 2.0):
                ok = any(abs(w.x - dx) < 1e-4
                         and abs(w.y - (y + dy)) < 1e-4
                         and abs(w.z - Z) < 1e-4 for w in vs_ar)
                assert ok, 'falta esquina de franja en (%.2f, %.2f)' % (
                    dx, y + dy)
                n_apoyo += 1
    print('RODELA APOYADA %d/12 esquinas en z=%.4f' % (n_apoyo, Z))

    # --- Guardia POSITIVA de altura, concha y zona vacia ---
    z_max = max(w.z for o in ps for w in vertices(o))
    assert abs(z_max - Y_CIMA) < 1e-4, \
        'algo sobrevuela el apice de la concha: z_max=%.4f' % z_max
    niv = niveles_z(ps)
    espurios = [v for v in niv if VACIA_LO < v < VACIA_HI]
    assert not espurios, 'niveles espurios en zona vacia: %s' % espurios[:5]
    print('ALTURA_REAL z=[%.4f..%.4f] alto=%.4f | HUELLA_CONTACTO=%.2fx%.2f '
          '| toca=%d' % (Z, z_max, z_max - Z, fp_x, fp_y, toca))
    print('ZONA_VACIA (%.2f, %.2f): 0 niveles | niveles_z=%d'
          % (VACIA_LO, VACIA_HI, len(niv)))

    # --- Guardia POSITIVA de silueta: concha ESCALONADA y ojos SOBRE pedunculos ---
    vc = vertices(concha)
    for _tope in (0.185, 0.275, 0.355, 0.425):
        assert any(abs(w.z - _tope) < 1e-4 for w in vc), \
            'falta el escalon de la concha en z=%.3f' % _tope
    anchos = {}
    for _z in (0.085, 0.185, 0.275, 0.355, 0.425):
        _fila = [w.x for w in vc if abs(w.z - _z) < 1e-4]
        anchos[_z] = max(_fila) - min(_fila)
    assert anchos[0.425] < anchos[0.355] < anchos[0.185], \
        'la concha no decrece hacia el apice: %s' % anchos
    vo = [w for d in ojos for w in vertices(d)]
    vp = vertices(cuerpo)
    assert any(abs(w.z - 0.250) < 1e-4 for w in vp), \
        'los pedunculos no llegan al arranque de los ojos'
    assert all(abs(w.z - 0.250) < 1e-4 or abs(w.z - 0.285) < 1e-4
               for w in vo), 'los ojos no estan sobre los pedunculos'
    print('ENSAMBLE rodela->concha(4 escalones)->cuerpo->ojos OK | '
          'concha=%d verts cuerpo=%d verts' % (len(vc), len(vp)))

    camara(escena, 'CAM_Cangrejo_Ermitano', (1.30, -1.45, 0.85),
           (0.0, 0.0, 0.22))
    shade_flat(escena)
    ruta = guardar(escena, MODULO, ASSET)
    print('VARIANTE %-20s | SM_=%d | mats=%d | tris~%d | z_min=%.4f '
          '| z_max=%.4f | toca=%d | fp=%.2fx%.2f'
          % (ASSET, len(ps), len(mats),
             sum(len(o.data.loop_triangles) for o in ps), z_fin, z_max,
             toca, fp_x, fp_y))
    return ruta


if __name__ == '__main__':
    construir()
    print('LISTO — cangrejo ermitano sobre rodela de marea (M36 / L39)')
