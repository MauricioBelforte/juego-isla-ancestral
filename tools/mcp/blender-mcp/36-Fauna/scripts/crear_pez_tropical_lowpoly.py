# crear_pez_tropical_lowpoly.py — Pez tropical, 2 variantes de color (M36 / L19 / B22)
#
# HUECO REAL MEDIDO 2026-11-09 23:47 -0300:
#   `HY4/BACKLOGS/02-Backlog-Pendientes-Assets.md` L19
#       "- [ ] Pez tropical (2 variantes de color)"
#   `HY4/36-Fauna/checklist.md` L23: idem, `[ ]`.
#   0 GLB `*pez_tropical*`, 0 generador, 0 `.blend` con ese nombre.
#   `36-Fauna` tiene 7 GLB (cangrejo x2, conejo, gaviota, jabali, nutria,
#   tortuga) y NINGUNO es un pez tropical. No es duplicado.
#
# ===========================================================================
# HUECO DE SPEC (MEDIDO, NO SUPÚESTO)
# ===========================================================================
# `DOCUMENTACION/36-Fauna/plan-inicial/01-Requerimientos.md` L27-L57 lista
#   **27 especies** y NO contiene "Pez tropical" (si "Pez Ciego de la Gruta"
#   L54 y "Salmon Saltarin" L37). `grep -rniE 'pez tropical|lagarto de isla|
#   gallina' DOCUMENTACION/` = 17 hits, TODOS en backlogs/checklists de HY4
#   o en una mencion generica de `70-Interacciones`; NINGUNO define cotas,
#   silueta, materiales ni rareza.
#   => TODAS las cotas de abajo son DECISION DE AUTORIA. No se cita spec
#      inexistente. La rareza/condicion de captura la decide el DIRECTOR.
#
# ===========================================================================
# NAMING: TRES ETIQUETAS VIEJAS + DECISION DE B22 (publicada en el mensaje 57)
# ===========================================================================
# El legado tiene `[x] Pez` (`pez_cozy.blend`), `[x] Pez rio`
#   (`sm_pez_rio.blend`) y `[ ] Pez tropical`, mas `[ ] Pez capturable`
#   compartido M34/M35/M36. El acta `08` L41 ya midio los dos `.blend` como
#   PARCIALES: sin GLB y sin variantes de color.
# B22 modela SOLO "Pez tropical" y resuelve "2 variantes de color" como
#   **2 assets nominales x 3 LOD = 6 GLB**:
#      36-Fauna_pez_tropical_azul.glb
#      36-Fauna_pez_tropical_naranja.glb
#   NO se reutiliza, renombra ni sobreescribe el legado.
# `grep -c '34-Pesca' exportar_godot.py` = 0 -> un GLB bajo `34-Pesca`
#   exportaria **0 archivos EN SILENCIO** (E-63 / T-02). `36-Fauna` YA esta
#   en `MODULOS` (L70): NO se crea modulo ni se toca el exportador.
# "Pez capturable" y `34-Pesca` quedan FUERA de B22 (decision 2 del acuse 56).
#
# ===========================================================================
# COTAS (DECISION DE AUTORIA)
# ===========================================================================
#   1 voxel = 1.00 m · Z_APOYO = 0.045 (E-12, arena top 0.05 / E-67).
#   RODELA DE ARRECIFE ... 3 franjas de arena coralina 0.44 x 0.36, 12
#      vertices apoyados. Un pez suelto tendria huella ~0.20 x 0.10 y
#      FALLARIA E-50 (min_fp=0.30, min_toca=8). Es un PROP de diorama,
#      NO una escena integrada.
#   CUERPO ESCALONADO ..... 4 cajas decrecientes/crecientes en X = la
#      silueta de pez (pedunculo -> lomo -> cabeza).
#   ALETA CAUDAL .......... 2 cajas separadas en Y = abanico de cola.
#   ALETA DORSAL .......... 1 caja SOBRE el lomo, con ZONA VACIA entre
#      el tope del cuerpo (0.255) y su base (0.275): (0.26, 0.27) no
#      tiene NINGUN nivel de vertice. Anti-cunia para la guardia.
#   ALETAS PECTORALES ..... 2 cajas a +-Y.
#   DETALLES (6) .......... 2 ojos + 1 boca + 3 escamas, TODOS podables
#      en BAJA por volumen_bbox < 1e-4 (UMBRAL_PODA de generar_variante).
#   GEOMETRIA AXIS-ALIGNED  TODAS las piezas son cajas en planos ortogonales:
#      ademas de la estetica voxel, permite una guardia POSITIVA por
#      NIVELES DE COORDENADA en el BIN del GLB (familia B18/B19/B20/B21).
#
# ===========================================================================
# PRESUPUESTO M166 Y DISENO DE LOS 3 LOD (A VERIFICAR, NO HEREDADO)
# ===========================================================================
#   ALTA  = 10 objetos / 7 materiales: 4 criticas `_NOFUNDIR` + 6 detalles.
#           18 cajas x 12 tris = 216 tris.
#   MEDIA =  7 objetos / 7 materiales: FASE 1 funde los 6 detalles en 3
#            grupos por lista de material (merge LOSSLESS, 216 tris).
#   BAJA  =  4 objetos / 4 materiales: FASE 0 PODA los 6 detalles y, al no
#            quedar NINGUN objeto no-critico, el DECIMATE actua sobre
#            **0 mallas**. 12 cajas x 12 tris = 144 tris.
#            LOD REAL por poda deliberada, SIN deformacion.
#
# LECCION APLICADA DE B18 (acta 28) A B21 (acta 31): el DECIMATE sobre
#   cajas disjuntas mueve vertices FUERA de los planos autorizados (12 y 10
#   defectos en la valla), invisible en el render y NO detectado por
#   `chk_asset.py`, que mide COSTE, no FORMA. Se evita POR DISENIO.
#   Ningun nombre de detalle contiene un sufijo de `PROTEGIDAS`
#   ('Pie','Base','Soporte','Tronco','Poste','Cuerpo','Tapa'), que inhibiria
#   la poda EN SILENCIO.
#
# Reglas aplicadas (GUIA-BLENDER / plantilla_asset.py):
#   E-12 Z_APOYO=0.045 · E-24 zmin_real() sobre VERTICES reales ·
#   E-50 huella > 0.30 m en X e Y con min_toca=8 (DEFAULT, no relajado) ·
#   E-44 solo SM_* se exporta · E-42 materiales por CARAS ·
#   E-68 caja() recibe la DIMENSION FINAL · E-27 SIN parents.
#
# USO (100 % headless, --python-exit-code 1 es OBLIGATORIO: sin el un
#   AssertionError interno devuelve RC=0, falso verde medido en M18-BIS):
#   blender -b --factory-startup --python-exit-code 1 \
#     --python crear_pez_tropical_lowpoly.py -- azul
#   blender -b --factory-startup --python-exit-code 1 \
#     --python crear_pez_tropical_lowpoly.py -- naranja
#   generar_variante_headless.py -- 36-Fauna pez_tropical_azul_lowpoly
#       --media --baja   (y lo mismo para naranja)
import bpy
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja, piezas, zmin_real,
                             Z_APOYO)

MODULO = '36-Fauna'

# --- Paletas: la diferencia REAL entre las 2 variantes de color ---
# Nombres de material con token de variante: el guardia C16 los exige en el
# GLB para probar que NO son dos copias del mismo asset.
PALETAS = {
    'azul': {
        'Cuerpo':  (0.16, 0.52, 0.86),   # azul tropical
        'Cabeza':  (0.20, 0.62, 0.90),
        'Aleta':   (0.95, 0.78, 0.22),   # amarillo
        'Escama':  (0.98, 0.90, 0.40),
        'Boca':    (0.92, 0.92, 0.88),
    },
    'naranja': {
        'Cuerpo':  (0.92, 0.42, 0.14),   # naranja coral
        'Cabeza':  (0.96, 0.55, 0.20),
        'Aleta':   (0.96, 0.94, 0.88),   # blanco
        'Escama':  (0.99, 0.85, 0.65),
        'Boca':    (0.35, 0.20, 0.12),
    },
}
TOKENS = {'azul': 'Azul', 'naranja': 'Naranja'}

Z = Z_APOYO                       # 0.045

# RODELA DE ARRECIFE: 3 franjas (12 vertices apoyados, huella 0.44 x 0.36).
AR_SX, AR_SY, AR_SZ = 0.44, 0.10, 0.04
AR_YS = (-0.13, 0.0, 0.13)
AR_Z = Z + AR_SZ / 2.0                       # 0.065 -> 0.045..0.085
AR_TOPE = Z + AR_SZ                          # 0.085

# CUERPO ESCALONADO: (x, y, z, sx, sy, sz); TODOS con base en 0.085.
CUERPO = (
    (-0.17, 0.0, 0.120, 0.10, 0.08, 0.07),   # pedunculo  0.085..0.155
    (-0.06, 0.0, 0.150, 0.18, 0.14, 0.13),   # lomo bajo  0.085..0.215
    ( 0.08, 0.0, 0.170, 0.20, 0.18, 0.17),   # lomo alto  0.085..0.255
)
CABEZA = (0.22, 0.0, 0.160, 0.14, 0.15, 0.15)  # 0.085..0.235

# ALETAS: caudal (2 cajas en +-Y), dorsal (1 arriba), pectorales (2 en +-Y).
CAUDAL_SX, CAUDAL_SY, CAUDAL_SZ = 0.08, 0.05, 0.11
CAUDAL_X, CAUDAL_Z = -0.26, 0.150            # 0.095..0.205
CAUDAL_YS = (-0.06, 0.06)
DORSAL = (0.06, 0.0, 0.305, 0.10, 0.03, 0.06)  # 0.275..0.335
PEC_SX, PEC_SY, PEC_SZ = 0.07, 0.04, 0.06
PEC_X, PEC_Z = 0.10, 0.150                   # 0.120..0.180
PEC_YS = (-0.105, 0.105)

# DETALLES (6), TODOS podables en BAJA por volumen_bbox < UMBRAL_PODA.
OJO_SX, OJO_SY, OJO_SZ = 0.035, 0.02, 0.035    # 2.45e-5 m3
OJO_X, OJO_Z = 0.255, 0.205                     # 0.1875..0.2225
OJO_YS = (-0.085, 0.085)   # SOBRESALEN de la cabeza (+-0.075): visibles
BOCA_SX, BOCA_SY, BOCA_SZ = 0.02, 0.05, 0.025   # 2.5e-5 m3
BOCA_X, BOCA_Z = 0.295, 0.125                   # 0.1125..0.1375, hocico
ESC_SX, ESC_SY, ESC_SZ = 0.02, 0.01, 0.03       # 6e-6 m3
ESC_XS = (-0.04, 0.04, 0.12)
ESC_Y, ESC_Z = 0.095, 0.170                     # 0.155..0.185

Y_CIMA = 0.335
VACIA_LO, VACIA_HI = 0.26, 0.27   # zona anti-cunia: 0 niveles autorizados
UMBRAL_PODA = 1e-4
PROTEGIDAS = ('pie', 'base', 'soporte', 'tronco', 'poste', 'cuerpo', 'tapa')

assert abs(Y_CIMA - 0.335) < 1e-9, 'cota superior incoherente'
assert AR_SX > 0.30 and (AR_YS[-1] + AR_SY / 2.0) * 2.0 > 0.30, \
    'la rodela no satisface E-50 (min_fp=0.30)'
assert len(AR_YS) * 4 >= 8, 'la rodela no aporta 8 vertices de apoyo'
assert 0.255 < VACIA_LO < VACIA_HI < 0.275, \
    'la zona vacia no queda entre el lomo y la base de la dorsal'
for _s, _v in (('ojo', OJO_SX * OJO_SY * OJO_SZ),
               ('boca', BOCA_SX * BOCA_SY * BOCA_SZ),
               ('escama', ESC_SX * ESC_SY * ESC_SZ)):
    assert _v < UMBRAL_PODA, '%s NO es podable (vol=%.2g)' % (_s, _v)
for _n in ('SM_Pez_Ojo_1', 'SM_Pez_Boca_1', 'SM_Pez_Escama_1'):
    assert not any(p in _n.lower() for p in PROTEGIDAS), \
        '%s contiene un sufijo PROTEGIDAS: la FASE 0 no lo podaria' % _n


def leer_variante():
    """`-- azul` / `-- naranja`. Blender Windows pasa TODO el argv."""
    if '--' in sys.argv:
        argv = sys.argv[sys.argv.index('--') + 1:]
    else:
        argv = [a for a in sys.argv[1:] if not a.endswith('.py')]
    v = argv[0] if argv else 'azul'
    assert v in PALETAS, 'variante desconocida %r (azul|naranja)' % v
    return v


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


def construir(variante):
    escena = limpiar()
    pal = PALETAS[variante]
    tok = TOKENS[variante]

    def M(pieza, color, **kw):
        return mat('MAT_Pez_%s_%s' % (tok, pieza), color, **kw)

    ARENA_M = mat('MAT_Pez_%s_Arena' % tok, (0.62, 0.55, 0.42))
    CUERPO_M = M('Cuerpo', pal['Cuerpo'])
    CABEZA_M = M('Cabeza', pal['Cabeza'])
    ALETA_M = M('Aleta', pal['Aleta'])
    OJO_M = M('Ojo', (0.08, 0.08, 0.10), rough=0.35, spec=0.55)
    BOCA_M = M('Boca', pal['Boca'])
    ESCAMA_M = M('Escama', pal['Escama'], rough=0.45, spec=0.40)

    # --- CRITICA 1: rodela de arrecife (3 cajas / 24 verts / 12 apoyados) ---
    frs = [caja('SM_Pez_Franja_1_NOFUNDIR' if i == 0
                else 'SM_Pez_Franja_%d' % (i + 1),
                0.0, y, AR_Z, AR_SX, AR_SY, AR_SZ, ARENA_M)
           for i, y in enumerate(AR_YS)]
    rodela = unir('SM_Pez_Franja_1_NOFUNDIR', frs)
    rodela.name = 'SM_Pez_Rodela_NOFUNDIR'

    # --- CRITICA 2: cuerpo escalonado (3 cajas / 24 verts) ---
    cb = [caja('SM_Pez_Lomo_1_NOFUNDIR' if i == 0
               else 'SM_Pez_Lomo_%d' % (i + 1),
               *t, CUERPO_M)
          for i, t in enumerate(CUERPO)]
    cuerpo = unir('SM_Pez_Lomo_1_NOFUNDIR', cb)
    cuerpo.name = 'SM_Pez_Cuerpo_NOFUNDIR'

    # --- CRITICA 3: cabeza (1 caja / 8 verts) ---
    cabeza = caja('SM_Pez_Cabeza_NOFUNDIR', *CABEZA, CABEZA_M)

    # --- CRITICA 4: 5 aletas (caudal 2 + dorsal 1 + pectorales 2 / 40 verts) ---
    al = [caja('SM_Pez_Caudal_%d' % (i + 1), CAUDAL_X, y, CAUDAL_Z,
               CAUDAL_SX, CAUDAL_SY, CAUDAL_SZ, ALETA_M)
          for i, y in enumerate(CAUDAL_YS)]
    al.append(caja('SM_Pez_Dorsal_NOFUNDIR_TMP', *DORSAL, ALETA_M))
    al += [caja('SM_Pez_Pectoral_%d' % (i + 1), PEC_X, y, PEC_Z,
                PEC_SX, PEC_SY, PEC_SZ, ALETA_M)
           for i, y in enumerate(PEC_YS)]
    # El activo del join debe ser el primero: se renombra despues.
    al[0].name = 'SM_Pez_Aletas_ACTIVO'
    aletas = unir('SM_Pez_Aletas_ACTIVO', al)
    aletas.name = 'SM_Pez_Aletas_NOFUNDIR'

    # --- NO CRITICOS (6), TODOS podables en BAJA por volumen < 1e-4 ---
    ojos = [caja('SM_Pez_Ojo_%d' % (i + 1), OJO_X, y, OJO_Z,
                 OJO_SX, OJO_SY, OJO_SZ, OJO_M)
            for i, y in enumerate(OJO_YS)]
    boca = caja('SM_Pez_Boca_1', BOCA_X, 0.0, BOCA_Z,
                BOCA_SX, BOCA_SY, BOCA_SZ, BOCA_M)
    escamas = [caja('SM_Pez_Escama_%d' % (i + 1), x, ESC_Y, ESC_Z,
                    ESC_SX, ESC_SY, ESC_SZ, ESCAMA_M)
               for i, x in enumerate(ESC_XS)]
    detalles = ojos + [boca] + escamas

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
        assert vol < UMBRAL_PODA, '%s NO es podable (vol=%.2g)' % (d.name, vol)
    mats = {m.name for o in ps for m in o.data.materials if m}
    assert len(mats) == 7, 'ALTA debe tener 7 materiales, hay %d' % len(mats)
    assert all(tok in n for n in mats), 'falta el token de variante en %s' % mats
    print('LOD_PREVISTO variante=%s ALTA=%d obj/%d mats | criticas=%d | '
          'detalles=%d -> MEDIA=7 | BAJA(poda 6)=4, DECIMATE=0 mallas'
          % (variante, len(ps), len(mats), len(criticas), len(detalles)))

    # --- Procedencia POSITIVA de las 4 criticas: 8 verts por caja ---
    for o, n in ((rodela, 24), (cuerpo, 24), (cabeza, 8), (aletas, 40)):
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

    # --- Guardia POSITIVA de altura, dorsal y zona vacia ---
    z_max = max(w.z for o in ps for w in vertices(o))
    assert abs(z_max - Y_CIMA) < 1e-4, \
        'algo sobrevuela la dorsal: z_max=%.4f' % z_max
    niv = niveles_z(ps)
    espurios = [v for v in niv if VACIA_LO < v < VACIA_HI]
    assert not espurios, 'niveles espurios en zona vacia: %s' % espurios[:5]
    print('ALTURA_REAL z=[%.4f..%.4f] alto=%.4f | HUELLA_CONTACTO=%.2fx%.2f '
          '| toca=%d' % (Z, z_max, z_max - Z, fp_x, fp_y, toca))
    print('ZONA_VACIA (%.2f, %.2f): 0 niveles | niveles_z=%d'
          % (VACIA_LO, VACIA_HI, len(niv)))

    # --- Guardia POSITIVA de silueta: cuerpo escalonado + cola + dorsal ---
    vc = vertices(cuerpo)
    for _tope in (0.155, 0.215, 0.255):
        assert any(abs(w.z - _tope) < 1e-4 for w in vc), \
            'falta el escalon del lomo en z=%.3f' % _tope
    va = vertices(aletas)
    assert any(abs(w.x - (-0.30)) < 1e-4 for w in va), \
        'falta el borde de la aleta caudal en x=-0.30'
    assert any(abs(w.z - Y_CIMA) < 1e-4 for w in va), \
        'falta el tope de la aleta dorsal'
    vt = vertices(cabeza)
    assert any(abs(w.x - 0.29) < 1e-4 for w in vt), \
        'falta el hocico en x=0.29'
    print('ENSAMBLE rodela->cuerpo(3 escalones)->cabeza->5 aletas OK | '
          'cuerpo=%d verts aletas=%d verts' % (len(vc), len(va)))

    asset = 'pez_tropical_' + variante
    camara(escena, 'CAM_Pez_Tropical_' + tok, (1.30, -1.45, 0.85),
           (0.0, 0.0, 0.19))
    shade_flat(escena)
    ruta = guardar(escena, MODULO, asset)
    print('VARIANTE %-20s | SM_=%d | mats=%d | tris~%d | z_min=%.4f '
          '| z_max=%.4f | toca=%d | fp=%.2fx%.2f'
          % (asset, len(ps), len(mats),
             sum(len(o.data.loop_triangles) for o in ps), z_fin, z_max,
             toca, fp_x, fp_y))
    return ruta


if __name__ == '__main__':
    _v = leer_variante()
    construir(_v)
    print('LISTO — pez tropical [%s] sobre rodela de arrecife (M36 / L19)'
          % _v)
