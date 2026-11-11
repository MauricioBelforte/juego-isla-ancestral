# crear_lagarto_isla_lowpoly.py — Lagarto de isla (M36 / L20 / B23)
#
# HUECO REAL MEDIDO 2026-11-10 22:55 -0300:
#   `HY4/BACKLOGS/02-Backlog-Pendientes-Assets.md` L20
#       "- [ ] Lagarto de isla"
#   `HY4/36-Fauna/checklist.md` L24 y
#   `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` L205: idem, `[ ]`.
#   0 GLB / 0 .blend / 0 generador `*lagarto*`. `36-Fauna` tiene 9 GLB
#   nominales (cangrejo x2, conejo, gaviota, jabali, nutria, pez tropical
#   x2, tortuga) y NINGUNO es un lagarto. No es duplicado.
#
# ===========================================================================
# HUECO DE SPEC (MEDIDO, NO SUPUESTO) — con la DISTINCION que corresponde
# ===========================================================================
# `DOCUMENTACION/36-Fauna/plan-inicial/01-Requerimientos.md` L27-L57 lista
#   **27 especies** y NO contiene "Lagarto de isla".
# `grep -rniE 'lagarto|lagartija|salamandra|gecko' DOCUMENTACION/` = **23
#   hits**, pero NO son spec de asset:
#     * 6 = "Lagarto de isla", TODOS en backlogs/checklists de HY4.
#     * 14 = "salamandra_ancestral", la especie del CATALOGO DE DATOS DE
#       RUNTIME (`data/fauna/catalog.json`, 7 especies M36/M93) y sus
#       tests/auditorias ajenas. Es un registro de GAMEPLAY, no un asset 3D,
#       y NO es "Lagarto de isla".
#     * el resto son menciones colaterales de esos mismos catalogos.
#   NINGUNO define cotas, silueta, materiales ni rareza del prop.
#   => Se publica la DISTINCION en vez de un "0 resultados" enganoso
#      (misma trampa medida en B20 con `v[ii]as`/`vag[oo]n`).
#      TODAS las cotas de abajo son DECISION DE AUTORIA. No se cita spec
#      inexistente. La rareza la decide el DIRECTOR.
#
# ===========================================================================
# DESTINO (MEDIDO)
# ===========================================================================
# 1 asset x 3 LOD = 3 GLB: `36-Fauna_lagarto_isla.glb` (alta/media/baja).
# `36-Fauna` YA esta en `MODULOS` (exportar_godot.py L70): NO se crea modulo
#   ni se toca el exportador. `grep -c '34-Pesca' exportar_godot.py` = 0:
#   un GLB bajo `34-Pesca` exportaria 0 archivos EN SILENCIO (E-63 / T-02).
#
# ===========================================================================
# COTAS (DECISION DE AUTORIA)
# ===========================================================================
#   1 voxel = 1.00 m · Z_APOYO = 0.045 (E-12, arena top 0.05 / E-67).
#   RODELA DE ROCA/ARENA .. 3 franjas 0.44 x 0.10 x 0.04 en y=-0.13/0/0.13:
#      12 vertices apoyados, huella 0.44 x 0.36. Un lagarto suelto tendria
#      huella ~0.30 x 0.20 y FALLARIA E-50 (min_fp=0.30, min_toca=8). Es un
#      PROP de diorama, NO una escena integrada.
#   CUERPO ESCALONADO ..... 3 cajas decrecientes/crecientes en X:
#      arranque de cola -> tronco bajo -> tronco alto.
#   CABEZA ................ 1 caja con hocico en x=0.35.
#   APENDICES CRITICOS .... cola (x=-0.38), 4 patas y CRESTA DORSAL.
#   CRESTA DORSAL ......... 1 caja APOYADA en el tope del lomo (base 0.265,
#      tope 0.315). REVISION VISUAL B23: la version inicial la separaba 2 cm
#      del lomo y se veia FLOTANDO en az000/az180; se corrigio apoyandola.
#   ZONA VACIA ............ (0.27, 0.28) sigue sin NINGUN nivel de vertice:
#      las cajas solo tienen vertices en 0.265 y 0.315, asi que el intervalo
#      interior queda vacio IGUAL. Anti-cunia para la guardia: cualquier
#      vertice movido por decimate a 0.275 introduce un nivel espurio.
#   DETALLES (6) .......... 2 ojos + 1 boca + 3 escamas, TODOS podables en
#      BAJA por volumen_bbox < 1e-4 (UMBRAL_PODA de generar_variante).
#   GEOMETRIA AXIS-ALIGNED  TODAS las piezas son cajas en planos ortogonales:
#      ademas de la estetica voxel, permite una guardia POSITIVA por
#      NIVELES DE COORDENADA en el BIN del GLB (familia B18..B22).
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
# LECCION APLICADA DE B18 (acta 28) A B22 (acta 32): el DECIMATE sobre
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
#     --python crear_lagarto_isla_lowpoly.py
#   generar_variante_headless.py -- 36-Fauna lagarto_isla_lowpoly --media
#   generar_variante_headless.py -- 36-Fauna lagarto_isla_lowpoly --baja
import bpy
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja, piezas, zmin_real,
                             Z_APOYO)

MODULO = '36-Fauna'
ASSET = 'lagarto_isla'

# --- Paleta (DECISION DE AUTORIA): verde de isla + cresta coralina ---
PALETA = {
    'Arena':   (0.62, 0.55, 0.42),
    'Cuerpo':  (0.26, 0.58, 0.28),   # verde lagarto
    'Cabeza':  (0.36, 0.68, 0.34),   # verde claro
    'Apendice': (0.18, 0.44, 0.22),  # verde oscuro patas/cola/cresta
    'Ojo':     (0.08, 0.08, 0.10),
    'Boca':    (0.72, 0.36, 0.34),
    'Escama':  (0.96, 0.86, 0.42),   # manchas amarillas
}

Z = Z_APOYO                       # 0.045

# RODELA: 3 franjas (12 vertices apoyados, huella 0.44 x 0.36).
AR_SX, AR_SY, AR_SZ = 0.44, 0.10, 0.04
AR_YS = (-0.13, 0.0, 0.13)
AR_Z = Z + AR_SZ / 2.0                       # 0.065 -> 0.045..0.085
AR_TOPE = Z + AR_SZ                          # 0.085

# CUERPO ESCALONADO: (x, y, z, sx, sy, sz); TODOS con base en 0.085.
CUERPO = (
    (-0.14, 0.0, 0.120, 0.10, 0.10, 0.07),   # arranque cola 0.085..0.155
    (-0.02, 0.0, 0.155, 0.22, 0.16, 0.14),   # tronco bajo 0.085..0.225
    ( 0.14, 0.0, 0.175, 0.16, 0.18, 0.18),   # tronco alto 0.085..0.265
)
CABEZA = (0.28, 0.0, 0.165, 0.14, 0.15, 0.16)  # 0.085..0.245, x .21..0.35

# APENDICES CRITICOS: cola + 4 patas + cresta dorsal.
COLA = (-0.30, 0.0, 0.115, 0.16, 0.06, 0.06)   # x -0.38..-0.22
PATA_SX, PATA_SY, PATA_SZ = 0.07, 0.05, 0.04
PATA_Z = 0.105                                   # 0.085..0.125
PATA_XS = (-0.06, 0.14)
PATA_YS = (-0.105, 0.105)
CRESTA = (0.06, 0.0, 0.290, 0.12, 0.03, 0.05)   # 0.265..0.315 APOYADA

# DETALLES (6), TODOS podables en BAJA por volumen_bbox < UMBRAL_PODA.
OJO_SX, OJO_SY, OJO_SZ = 0.035, 0.02, 0.035    # 2.45e-5 m3
OJO_X, OJO_Z = 0.310, 0.235                     # 0.2175..0.2525
OJO_YS = (-0.085, 0.085)   # SOBRESALEN de la cabeza (+-0.075): visibles
BOCA_SX, BOCA_SY, BOCA_SZ = 0.02, 0.06, 0.025   # 3e-5 m3
BOCA_X, BOCA_Z = 0.355, 0.125                   # 0.1125..0.1375, hocico
ESC_SX, ESC_SY, ESC_SZ = 0.02, 0.01, 0.03       # 6e-6 m3
ESC_XS = (-0.06, 0.04, 0.14)
ESC_Y, ESC_Z = 0.100, 0.200                     # 0.185..0.215

Y_CIMA = 0.315
VACIA_LO, VACIA_HI = 0.27, 0.28   # zona anti-cunia: 0 niveles autorizados
UMBRAL_PODA = 1e-4
PROTEGIDAS = ('pie', 'base', 'soporte', 'tronco', 'poste', 'cuerpo', 'tapa')

assert abs(Y_CIMA - 0.315) < 1e-9, 'cota superior incoherente'
assert AR_SX > 0.30 and (AR_YS[-1] + AR_SY / 2.0) * 2.0 > 0.30, \
    'la rodela no satisface E-50 (min_fp=0.30)'
assert len(AR_YS) * 4 >= 8, 'la rodela no aporta 8 vertices de apoyo'
assert 0.265 < VACIA_LO < VACIA_HI < 0.315, \
    'la zona vacia no queda dentro del rango de la cresta apoyada'
for _s, _v in (('ojo', OJO_SX * OJO_SY * OJO_SZ),
               ('boca', BOCA_SX * BOCA_SY * BOCA_SZ),
               ('escama', ESC_SX * ESC_SY * ESC_SZ)):
    assert _v < UMBRAL_PODA, '%s NO es podable (vol=%.2g)' % (_s, _v)
for _n in ('SM_Lagarto_Ojo_1', 'SM_Lagarto_Boca_1', 'SM_Lagarto_Escama_1'):
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
        return mat('MAT_Lagarto_%s' % pieza, color, **kw)

    ARENA_M = M('Arena', PALETA['Arena'])
    CUERPO_M = M('Cuerpo', PALETA['Cuerpo'])
    CABEZA_M = M('Cabeza', PALETA['Cabeza'])
    APENDICE_M = M('Apendice', PALETA['Apendice'])
    OJO_M = M('Ojo', PALETA['Ojo'], rough=0.35, spec=0.55)
    BOCA_M = M('Boca', PALETA['Boca'])
    ESCAMA_M = M('Escama', PALETA['Escama'], rough=0.45, spec=0.40)

    # --- CRITICA 1: rodela de roca/arena (3 cajas / 24 verts / 12 apoyados) ---
    frs = [caja('SM_Lagarto_Franja_1_NOFUNDIR' if i == 0
                else 'SM_Lagarto_Franja_%d' % (i + 1),
                0.0, y, AR_Z, AR_SX, AR_SY, AR_SZ, ARENA_M)
           for i, y in enumerate(AR_YS)]
    rodela = unir('SM_Lagarto_Franja_1_NOFUNDIR', frs)
    rodela.name = 'SM_Lagarto_Rodela_NOFUNDIR'

    # --- CRITICA 2: cuerpo escalonado (3 cajas / 24 verts) ---
    cb = [caja('SM_Lagarto_Lomo_1_NOFUNDIR' if i == 0
               else 'SM_Lagarto_Lomo_%d' % (i + 1),
               *t, CUERPO_M)
          for i, t in enumerate(CUERPO)]
    cuerpo = unir('SM_Lagarto_Lomo_1_NOFUNDIR', cb)
    cuerpo.name = 'SM_Lagarto_Cuerpo_NOFUNDIR'

    # --- CRITICA 3: cabeza (1 caja / 8 verts) ---
    cabeza = caja('SM_Lagarto_Cabeza_NOFUNDIR', *CABEZA, CABEZA_M)

    # --- CRITICA 4: cola + 4 patas + cresta (6 cajas / 48 verts) ---
    ap = [caja('SM_Lagarto_Cola_ACTIVO', *COLA, APENDICE_M)]
    ap += [caja('SM_Lagarto_Pata_%d' % (i + 1), x, y, PATA_Z,
                PATA_SX, PATA_SY, PATA_SZ, APENDICE_M)
           for i, (x, y) in enumerate((x, y) for x in PATA_XS
                                     for y in PATA_YS)]
    ap.append(caja('SM_Lagarto_Cresta_1', *CRESTA, APENDICE_M))
    apendices = unir('SM_Lagarto_Cola_ACTIVO', ap)
    apendices.name = 'SM_Lagarto_Apendices_NOFUNDIR'

    # --- NO CRITICOS (6), TODOS podables en BAJA por volumen < 1e-4 ---
    ojos = [caja('SM_Lagarto_Ojo_%d' % (i + 1), OJO_X, y, OJO_Z,
                 OJO_SX, OJO_SY, OJO_SZ, OJO_M)
            for i, y in enumerate(OJO_YS)]
    boca = caja('SM_Lagarto_Boca_1', BOCA_X, 0.0, BOCA_Z,
                BOCA_SX, BOCA_SY, BOCA_SZ, BOCA_M)
    escamas = [caja('SM_Lagarto_Escama_%d' % (i + 1), x, ESC_Y, ESC_Z,
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
    assert all(n.startswith('MAT_Lagarto_') for n in mats), \
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

    # --- Guardia POSITIVA de altura, cresta y zona vacia ---
    z_max = max(w.z for o in ps for w in vertices(o))
    assert abs(z_max - Y_CIMA) < 1e-4, \
        'algo sobrevuela la cresta: z_max=%.4f' % z_max
    niv = niveles_z(ps)
    espurios = [v for v in niv if VACIA_LO < v < VACIA_HI]
    assert not espurios, 'niveles espurios en zona vacia: %s' % espurios[:5]
    print('ALTURA_REAL z=[%.4f..%.4f] alto=%.4f | HUELLA_CONTACTO=%.2fx%.2f '
          '| toca=%d' % (Z, z_max, z_max - Z, fp_x, fp_y, toca))
    print('ZONA_VACIA (%.2f, %.2f): 0 niveles | niveles_z=%d'
          % (VACIA_LO, VACIA_HI, len(niv)))

    # --- Guardia POSITIVA de silueta: lomo escalonado + cola + hocico ---
    vc = vertices(cuerpo)
    for _tope in (0.155, 0.225, 0.265):
        assert any(abs(w.z - _tope) < 1e-4 for w in vc), \
            'falta el escalon del lomo en z=%.3f' % _tope
    va = vertices(apendices)
    assert any(abs(w.x - (-0.38)) < 1e-4 for w in va), \
        'falta el borde de la cola en x=-0.38'
    assert any(abs(w.z - Y_CIMA) < 1e-4 for w in va), \
        'falta el tope de la cresta dorsal'
    vt = vertices(cabeza)
    assert any(abs(w.x - 0.35) < 1e-4 for w in vt), \
        'falta el hocico en x=0.35'
    print('ENSAMBLE rodela->cuerpo(3 escalones)->cabeza->6 apendices OK | '
          'cuerpo=%d verts apendices=%d verts' % (len(vc), len(va)))

    camara(escena, 'CAM_Lagarto_Isla', (1.45, -1.60, 0.90),
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
    print('LISTO — lagarto de isla sobre rodela de roca (M36 / L20)')
