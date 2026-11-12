# crear_cabra_lowpoly.py — Cabra / «Cabra de los Picos» (M36 / L21 / B24)
#
# HUECO REAL MEDIDO 2026-11-11 20:50 -0300:
#   `HY4/BACKLOGS/02-Backlog-Pendientes-Assets.md` L21 "- [ ] Cabra"
#   `HY4/36-Fauna/checklist.md` L25 y
#   `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` L207: idem, `[ ]`.
#   0 GLB / 0 .blend / 0 generador `*cabra*`. `36-Fauna` tiene 10 GLB
#   nominales y NINGUNO es una cabra. No es duplicado.
#
# ===========================================================================
# ANCLA DE SPEC REAL (A DIFERENCIA DE B22 Y B23)
# ===========================================================================
# `DOCUMENTACION/36-Fauna/plan-inicial/01-Requerimientos.md` L48:
#   | Cabra de los Picos | Montaña | Poco comun | Diurno | Todas |
#   | CURIOSO (trepa, no teme a las alturas) | dias claros |
# Es el mismo caso de B21 (Cangrejo Ermitano, ancla L29): bioma, rareza,
#   horario, estacion, comportamiento y clima SI estan definidos. Se modela
#   la ESPECIE DEL CATALOGO: cabra de montaña, trepadora, con CUERNOS y
#   rodela de ROCA (no arena). El checklist dice "Cabra" a secas: la
#   diferencia de rotulo se publica, NO se edita 01-Requerimientos.md.
# NINGUN documento define cotas, silueta, materiales ni paleta del prop:
#   TODO eso es DECISION DE AUTORIA (cabecera de este generador).
#
# TRAMPA DE MEDICION NUEVA (documentada en el mensaje 63): el primer barrido
#   `grep -rniE 'cabra|chivo|caprino' DOCUMENTACION/` = 12352 hits, TODOS
#   falsos positivos: `chivo` es SUBCADENA de "ar"+"chivo" = "archivo".
#   Con limites de palabra `\b(cabra|caprino)\b` = 13 hits reales (1 ancla
#   L48, 2 de 65-Animales-IA que NO son spec de asset, 10 de backlogs HY4).
#
# ===========================================================================
# DESTINO (MEDIDO)
# ===========================================================================
# 1 asset x 3 LOD = 3 GLB: `36-Fauna_cabra.glb` (alta/media/baja).
# Se usa el ROTULO DEL HUECO L21, no `cabra_picos`: decision reversible y
#   de bajo riesgo. Queda PROPUESTO al director si prefiere alinear el GLB
#   con el catalogo. Hy4 no renombra nada ya publicado.
# `36-Fauna` YA esta en `MODULOS` (exportar_godot.py L70): NO se crea modulo
#   ni se toca el exportador.
#
# ===========================================================================
# COTAS (DECISION DE AUTORIA)
# ===========================================================================
#   1 voxel = 1.00 m · Z_APOYO = 0.045 (E-12, arena top 0.05 / E-67).
#   RODELA DE ROCA ....... 3 franjas 0.44 x 0.10 x 0.04 en y=-0.13/0/0.13:
#      12 vertices apoyados, huella 0.44 x 0.36. Una cabra suelta tendria
#      ~0.30 x 0.20 y FALLARIA E-50 (min_fp=0.30, min_toca=8). Es un PROP
#      de diorama, NO una escena integrada. Coherente con bioma Montaña.
#   CUERPO ESCALONADO ..... 3 cajas: trasero -> tronco -> pecho.
#   CABEZA ................ 1 caja con hocico en x=0.35.
#   APENDICES CRITICOS .... 4 patas + 2 CUERNOS APOYADOS en el tope de la
#      cabeza (0.245), hasta Y_CIMA=0.335.
#   CUERNOS APOYADOS ...... LECCION DEL HALLAZGO VISUAL B23: alla la cresta
#      flotaba 2 cm y se vio en az000/az180. Aqui NO hay separacion: la
#      base del cuerno COINCIDE con el tope de la cabeza (24 vertices
#      compartidos en z=0.245) y la guardia lo exige de forma POSITIVA.
#   ZONA VACIA (0.27,0.28) 0 niveles de vertice: las cajas solo tienen
#      vertices en 0.245, 0.265 y 0.335. Anti-cunia para la guardia.
#   DETALLES (6) .......... 2 ojos + 1 barba + 3 manchas, TODOS podables
#      en BAJA por volumen_bbox < 1e-4 (UMBRAL_PODA).
#   GEOMETRIA AXIS-ALIGNED  TODAS cajas en planos ortogonales: guardia
#      POSITIVA por NIVELES DE COORDENADA en el BIN (familia B18..B23).
#
# ===========================================================================
# PRESUPUESTO M166 Y DISENO DE LOS 3 LOD (A VERIFICAR, NO HEREDADO)
# ===========================================================================
#   ALTA  = 10 objetos / 7 materiales: 4 criticas `_NOFUNDIR` + 6 detalles.
#           19 cajas x 12 tris = 228 tris.
#   MEDIA =  7 objetos / 7 materiales: FASE 1 funde los 6 detalles en 3
#            grupos por lista de material (merge LOSSLESS, 228 tris).
#   BAJA  =  4 objetos / 4 materiales: FASE 0 PODA los 6 detalles y, al no
#            quedar NINGUN objeto no-critico, el DECIMATE actua sobre
#            **0 mallas**. 13 cajas x 12 tris = 156 tris.
#            LOD REAL por poda deliberada, SIN deformacion.
#
# LECCION APLICADA DE B18 (acta 28) A B23 (acta 33): el DECIMATE sobre
#   cajas disjuntas mueve vertices FUERA de los planos autorizados,
#   invisible en el render y NO detectado por `chk_asset.py`, que mide
#   COSTE, no FORMA. Se evita POR DISENIO. Ningun nombre de detalle
#   contiene un sufijo de `PROTEGIDAS`, que inhibiria la poda EN SILENCIO.
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
#     --python crear_cabra_lowpoly.py
#   generar_variante_headless.py -- 36-Fauna cabra_lowpoly --media --baja
import bpy
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja, piezas, zmin_real,
                             Z_APOYO)

MODULO = '36-Fauna'
ASSET = 'cabra'

# --- Paleta (DECISION DE AUTORIA): crema de montaña + cuernos marrones ---
PALETA = {
    'Roca':    (0.52, 0.50, 0.47),   # gris de montaña
    'Cuerpo':  (0.86, 0.81, 0.68),   # crema
    'Cabeza':  (0.92, 0.88, 0.76),   # crema claro
    'Cuerno':  (0.42, 0.32, 0.24),   # marron oscuro (patas + cuernos)
    'Ojo':     (0.08, 0.08, 0.10),
    'Barba':   (0.97, 0.96, 0.91),   # blanco
    'Mancha':  (0.62, 0.48, 0.34),   # marron manchas
}

Z = Z_APOYO                       # 0.045

# RODELA DE ROCA: 3 franjas (12 vertices apoyados, huella 0.44 x 0.36).
AR_SX, AR_SY, AR_SZ = 0.44, 0.10, 0.04
AR_YS = (-0.13, 0.0, 0.13)
AR_Z = Z + AR_SZ / 2.0                       # 0.065 -> 0.045..0.085
AR_TOPE = Z + AR_SZ                          # 0.085

# CUERPO ESCALONADO: (x, y, z, sx, sy, sz); TODOS con base en 0.085.
CUERPO = (
    (-0.14, 0.0, 0.120, 0.10, 0.12, 0.07),   # trasero   0.085..0.155
    (-0.02, 0.0, 0.155, 0.22, 0.18, 0.14),   # tronco    0.085..0.225
    ( 0.14, 0.0, 0.175, 0.16, 0.18, 0.18),   # pecho     0.085..0.265
)
CABEZA = (0.28, 0.0, 0.165, 0.14, 0.15, 0.16)  # 0.085..0.245, x .21..0.35

# APENDICES CRITICOS: 4 patas + 2 cuernos.
PATA_SX, PATA_SY, PATA_SZ = 0.07, 0.05, 0.04
PATA_Z = 0.105                                   # 0.085..0.125
PATA_XS = (-0.06, 0.14)
PATA_YS = (-0.105, 0.105)
CUERNO_SX, CUERNO_SY, CUERNO_SZ = 0.05, 0.04, 0.09
CUERNO_X, CUERNO_Z = 0.28, 0.290                 # 0.245..0.335 APOYADOS
CUERNO_YS = (-0.05, 0.05)

# DETALLES (6), TODOS podables en BAJA por volumen_bbox < UMBRAL_PODA.
OJO_SX, OJO_SY, OJO_SZ = 0.035, 0.02, 0.035    # 2.45e-5 m3
OJO_X, OJO_Z = 0.310, 0.205                     # 0.1875..0.2225
OJO_YS = (-0.085, 0.085)   # SOBRESALEN de la cabeza (+-0.075): visibles
BARBA_SX, BARBA_SY, BARBA_SZ = 0.02, 0.05, 0.04  # 4e-5 m3
BARBA_X, BARBA_Z = 0.355, 0.145                  # 0.125..0.165, hocico
MAN_SX, MAN_SY, MAN_SZ = 0.02, 0.01, 0.03       # 6e-6 m3
MAN_XS = (-0.06, 0.04, 0.14)
MAN_Y, MAN_Z = 0.100, 0.200                      # 0.185..0.215

Y_CIMA = 0.335
VACIA_LO, VACIA_HI = 0.27, 0.28   # zona anti-cunia: 0 niveles autorizados
UMBRAL_PODA = 1e-4
PROTEGIDAS = ('pie', 'base', 'soporte', 'tronco', 'poste', 'cuerpo', 'tapa')

assert abs(Y_CIMA - 0.335) < 1e-9, 'cota superior incoherente'
assert AR_SX > 0.30 and (AR_YS[-1] + AR_SY / 2.0) * 2.0 > 0.30, \
    'la rodela no satisface E-50 (min_fp=0.30)'
assert len(AR_YS) * 4 >= 8, 'la rodela no aporta 8 vertices de apoyo'
assert 0.265 < VACIA_LO < VACIA_HI < 0.335, \
    'la zona vacia no queda entre el lomo y el tope de los cuernos'
assert abs((CUERNO_Z - CUERNO_SZ / 2.0) - 0.245) < 1e-9, \
    'la base del cuerno NO coincide con el tope de la cabeza: FLOTARIA'
for _s, _v in (('ojo', OJO_SX * OJO_SY * OJO_SZ),
               ('barba', BARBA_SX * BARBA_SY * BARBA_SZ),
               ('mancha', MAN_SX * MAN_SY * MAN_SZ)):
    assert _v < UMBRAL_PODA, '%s NO es podable (vol=%.2g)' % (_s, _v)
for _n in ('SM_Cabra_Ojo_1', 'SM_Cabra_Barba_1', 'SM_Cabra_Mancha_1'):
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

    def M(pieza, color, **kw):
        return mat('MAT_Cabra_%s' % pieza, color, **kw)

    ROCA_M = M('Roca', PALETA['Roca'])
    CUERPO_M = M('Cuerpo', PALETA['Cuerpo'])
    CABEZA_M = M('Cabeza', PALETA['Cabeza'])
    CUERNO_M = M('Cuerno', PALETA['Cuerno'])
    OJO_M = M('Ojo', PALETA['Ojo'], rough=0.35, spec=0.55)
    BARBA_M = M('Barba', PALETA['Barba'])
    MANCHA_M = M('Mancha', PALETA['Mancha'], rough=0.45, spec=0.40)

    # --- CRITICA 1: rodela de roca (3 cajas / 24 verts / 12 apoyados) ---
    frs = [caja('SM_Cabra_Franja_1_NOFUNDIR' if i == 0
                else 'SM_Cabra_Franja_%d' % (i + 1),
                0.0, y, AR_Z, AR_SX, AR_SY, AR_SZ, ROCA_M)
           for i, y in enumerate(AR_YS)]
    rodela = unir('SM_Cabra_Franja_1_NOFUNDIR', frs)
    rodela.name = 'SM_Cabra_Rodela_NOFUNDIR'

    # --- CRITICA 2: cuerpo escalonado (3 cajas / 24 verts) ---
    cb = [caja('SM_Cabra_Lomo_1_NOFUNDIR' if i == 0
               else 'SM_Cabra_Lomo_%d' % (i + 1),
               *t, CUERPO_M)
          for i, t in enumerate(CUERPO)]
    cuerpo = unir('SM_Cabra_Lomo_1_NOFUNDIR', cb)
    cuerpo.name = 'SM_Cabra_Cuerpo_NOFUNDIR'

    # --- CRITICA 3: cabeza (1 caja / 8 verts) ---
    cabeza = caja('SM_Cabra_Cabeza_NOFUNDIR', *CABEZA, CABEZA_M)

    # --- CRITICA 4: 4 patas + 2 cuernos (6 cajas / 48 verts) ---
    ap = [caja('SM_Cabra_Pata_%d' % (i + 1), x, y, PATA_Z,
               PATA_SX, PATA_SY, PATA_SZ, CUERNO_M)
          for i, (x, y) in enumerate((x, y) for x in PATA_XS
                                    for y in PATA_YS)]
    ap[0].name = 'SM_Cabra_Pata_ACTIVO'
    ap += [caja('SM_Cabra_Cuerno_%d' % (i + 1), CUERNO_X, y, CUERNO_Z,
                CUERNO_SX, CUERNO_SY, CUERNO_SZ, CUERNO_M)
           for i, y in enumerate(CUERNO_YS)]
    apendices = unir('SM_Cabra_Pata_ACTIVO', ap)
    apendices.name = 'SM_Cabra_CuernosPatas_NOFUNDIR'

    # --- NO CRITICOS (6), TODOS podables en BAJA por volumen < 1e-4 ---
    ojos = [caja('SM_Cabra_Ojo_%d' % (i + 1), OJO_X, y, OJO_Z,
                 OJO_SX, OJO_SY, OJO_SZ, OJO_M)
            for i, y in enumerate(OJO_YS)]
    barba = caja('SM_Cabra_Barba_1', BARBA_X, 0.0, BARBA_Z,
                 BARBA_SX, BARBA_SY, BARBA_SZ, BARBA_M)
    manchas = [caja('SM_Cabra_Mancha_%d' % (i + 1), x, MAN_Y, MAN_Z,
                    MAN_SX, MAN_SY, MAN_SZ, MANCHA_M)
               for i, x in enumerate(MAN_XS)]
    detalles = ojos + [barba] + manchas

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
    assert all(n.startswith('MAT_Cabra_') for n in mats), \
        'material ajeno en la escena: %s' % mats
    print('LOD_PREVISTO ALTA=%d obj/%d mats | criticas=%d | detalles=%d '
          '-> MEDIA=7 | BAJA(poda 6)=4, DECIMATE=0 mallas'
          % (len(ps), len(mats), len(criticas), len(detalles)))

    # --- Procedencia POSITIVA de las 4 criticas: 8 verts por caja ---
    for o, n in ((rodela, 24), (cuerpo, 24), (cabeza, 8), (apendices, 48)):
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

    # --- Guardia POSITIVA de altura, cuernos y zona vacia ---
    z_max = max(w.z for o in ps for w in vertices(o))
    assert abs(z_max - Y_CIMA) < 1e-4, \
        'algo sobrevuela los cuernos: z_max=%.4f' % z_max
    niv = niveles_z(ps)
    espurios = [v for v in niv if VACIA_LO < v < VACIA_HI]
    assert not espurios, 'niveles espurios en zona vacia: %s' % espurios[:5]
    print('ALTURA_REAL z=[%.4f..%.4f] alto=%.4f | HUELLA_CONTACTO=%.2fx%.2f '
          '| toca=%d' % (Z, z_max, z_max - Z, fp_x, fp_y, toca))
    print('ZONA_VACIA (%.2f, %.2f): 0 niveles | niveles_z=%d'
          % (VACIA_LO, VACIA_HI, len(niv)))

    # --- Guardia POSITIVA de silueta: lomo + hocico + cuernos APOYADOS ---
    vc = vertices(cuerpo)
    for _tope in (0.155, 0.225, 0.265):
        assert any(abs(w.z - _tope) < 1e-4 for w in vc), \
            'falta el escalon del lomo en z=%.3f' % _tope
    va = vertices(apendices)
    assert any(abs(w.z - Y_CIMA) < 1e-4 for w in va), \
        'falta el tope de los cuernos'
    # Vertices REALES del .blend en z=0.245: 4 del tope de la cabeza +
    # 8 de las bases de los 2 cuernos = 12. (El BIN del GLB triplica por
    # normales de cara; la guardia C18 calibrara ese valor por separado.)
    union = [w for w in vertices(cabeza) + vertices(apendices)
             if abs(w.z - 0.245) < 1e-4]
    assert len(union) == 12, \
        'cuernos FLOTANTES o mal asentados: %d vertices en z=0.245 ' \
        '(esperados 12)' % len(union)
    vt = vertices(cabeza)
    assert any(abs(w.x - 0.35) < 1e-4 for w in vt), \
        'falta el hocico en x=0.35'
    print('ENSAMBLE rodela->cuerpo(3 escalones)->cabeza->6 apendices OK | '
          'CUERNOS APOYADOS %d verts en z=0.245' % len(union))

    camara(escena, 'CAM_Cabra_Picos', (1.45, -1.60, 0.90),
           (0.0, 0.0, 0.19))
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
    print('LISTO — cabra de los picos sobre rodela de roca (M36 / L21)')
