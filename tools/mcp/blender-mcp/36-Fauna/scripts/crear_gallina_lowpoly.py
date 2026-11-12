# crear_gallina_lowpoly.py — Gallina (M36 / L22 / B25)
#
# HUECO REAL MEDIDO 2026-11-11 21:15 -0300:
#   `HY4/BACKLOGS/02-Backlog-Pendientes-Assets.md` L22 "- [ ] Gallina"
#   `HY4/36-Fauna/checklist.md` L26 y
#   `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` L208: idem, `[ ]`.
#   0 GLB / 0 .blend / 0 generador `*gallina*`. `36-Fauna` tiene 11 GLB
#   nominales y NINGUNO es una gallina. No es duplicado.
#
# ===========================================================================
# HUECO DE SPEC MEDIDO (A DIFERENCIA DE B21 Y B24)
# ===========================================================================
# `DOCUMENTACION/36-Fauna/plan-inicial/01-Requerimientos.md` L27-L57 lista
#   27 especies y NO contiene "Gallina" (0 hits). A diferencia de
#   B21 (Cangrejo Ermitano, ancla L29) y B24 (Cabra de los Picos, ancla
#   L48), AQUI NO HAY ANCLA DE SPEC REAL.
# `grep -rniE 'gallina|pollo|corral|huevo' DOCUMENTACION/33-Agricultura/`
#   = 0 hits: tampoco hay spec de granja.
# `grep -rniE '\b(gallina|gallo|poll[oa]s?)\b' DOCUMENTACION/` = 11 hits,
#   TODOS en backlogs/checklists/actas de HY4; NINGUNO define cotas,
#   silueta, materiales, paleta, rareza ni comportamiento.
# FALSO POSITIVO MEDIDO Y EXCLUIDO: la alternativa `ave` suelta da 15802
#   hits (`ave` es subcadena de "suave"/"clave"/"nave"/"grave"; medido
#   echo 'suave' | grep -ci ave = 1). Se usaron LIMITES DE PALABRA.
#   Misma familia que B20 (v[ii]as), B23 (salamandra_ancestral) y B24
#   (chivo subcadena de "archivo").
# `DOCUMENTACION/GUIA-BLENDER/10-animales-bimodo.md` seccion 10.2 define
#   la anatomia del AVE BIMODO (2 poses, _Ala_L/R, _Pata_0/1, _Cola,
#   cuaterniones medidos). **NO APLICA**: el hueco L22 "Gallina" NO pide
#   animacion, a diferencia de L23 "Mariposa (alas simples para animar)".
#   B25 es un PROP ESTATICO de diorama, no un asset bimodo.
# => TODAS las cotas de abajo son DECISION DE AUTORIA. No se cita spec
#    inexistente. La rareza/bioma la decide el DIRECTOR.
#
# ===========================================================================
# DESTINO (MEDIDO)
# ===========================================================================
# 1 asset x 3 LOD = 3 GLB: `36-Fauna_gallina.glb` (alta/media/baja).
# `36-Fauna` YA esta en `MODULOS` (exportar_godot.py L70): NO se crea
#   modulo ni se toca el exportador.
#
# ===========================================================================
# COTAS (DECISION DE AUTORIA)
# ===========================================================================
#   1 voxel = 1.00 m · Z_APOYO = 0.045 (E-12, arena top 0.05 / E-67).
#   RODELA .................. 3 franjas 0.44 x 0.10 x 0.04, 12 vertices
#      apoyados, huella 0.44 x 0.36. Una gallina suelta tendria ~0.30x0.20
#      y FALLARIA E-50 (min_fp=0.30, min_toca=8 DEFAULT, NO relajado).
#   CUERPO .................. 3 cajas escalonadas (trasero/tronco/pecho).
#   CABEZA .................. 1 caja con hocico en x=0.35.
#   APENDICES CRITICOS (6) .. 2 patas + 2 ALAS laterales + CRESTA +
#      COLA LEVANTADA. Silueta de AVE, geometricamente distinta de B23
#      (lagarto con cresta central) y B24 (cabra con 2 cuernos).
#   CRESTA APOYADA .......... base 0.245 = tope de la cabeza, tope 0.335
#      (Y_CIMA). LECCION DEL HALLAZGO VISUAL B23: alla la cresta flotaba
#      2 cm y se vio en az000/az180; aqui NO hay separacion.
#   COLA APOYADA ............ base 0.085 = tope de la rodela, tope 0.245.
#   ZONA VACIA (0.27,0.28) .. 0 niveles de vertice: solo hay vertices en
#      0.265 (lomo/plumas), 0.285 (plumas) y 0.335 (cresta). Anti-cunia.
#   DETALLES (6) ............ 2 ojos + 1 pico + 3 plumas, TODOS podables
#      en BAJA por volumen_bbox < 1e-4 (UMBRAL_PODA).
#   GEOMETRIA AXIS-ALIGNED .. guardia POSITIVA por NIVELES DE COORDENADA
#      en el BIN del GLB (familia B18..B24).
#
# ===========================================================================
# PRESUPUESTO M166 Y DISENO DE LOS 3 LOD (A VERIFICAR, NO HEREDADO)
# ===========================================================================
#   ALTA  = 10 objetos / 7 materiales: 4 criticas `_NOFUNDIR` + 6 detalles.
#           19 cajas x 12 tris = 228 tris.
#   MEDIA =  7 objetos / 7 materiales: FASE 1 funde los 6 detalles en 3
#            grupos por lista de material (merge LOSSLESS, 228 tris).
#   BAJA  =  4 objetos / 4 materiales: FASE 0 PODA los 6 detalles, el
#            DECIMATE actua sobre **0 mallas**. 13 cajas = 156 tris.
#            LOD REAL por poda deliberada, SIN deformacion.
# 1 material por critica => en BAJA quedan EXACTAMENTE 4 materiales
#   (Roca/Cuerpo/Cabeza/Apendice), sin disparar la poda de materiales.
#
# LECCION APLICADA DE B18 (acta 28) A B24 (acta 34): el DECIMATE sobre
#   cajas disjuntas mueve vertices FUERA de los planos autorizados,
#   invisible en el render y NO detectado por chk_asset.py, que mide
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
#     --python crear_gallina_lowpoly.py
#   generar_variante_headless.py -- 36-Fauna gallina_lowpoly --media --baja
import bpy
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja, piezas, zmin_real,
                             Z_APOYO)

MODULO = '36-Fauna'
ASSET = 'gallina'

# --- Paleta (DECISION DE AUTORIA): blanca + mostaza + rojo ---
PALETA = {
    'Roca':     (0.55, 0.53, 0.50),
    'Cuerpo':   (0.95, 0.94, 0.90),
    'Cabeza':   (0.98, 0.96, 0.91),
    'Apendice': (0.92, 0.68, 0.20),   # mostaza: patas/alas/cola/cresta
    'Ojo':      (0.08, 0.08, 0.10),
    'Pico':     (0.95, 0.55, 0.15),
    'Pluma':    (0.80, 0.22, 0.18),   # rojo: 3 motas
}

Z = Z_APOYO                       # 0.045

# RODELA: 3 franjas (12 vertices apoyados, huella 0.44 x 0.36).
AR_SX, AR_SY, AR_SZ = 0.44, 0.10, 0.04
AR_YS = (-0.13, 0.0, 0.13)
AR_Z = Z + AR_SZ / 2.0                       # 0.065 -> 0.045..0.085
AR_TOPE = Z + AR_SZ                          # 0.085

# CUERPO ESCALONADO: (x, y, z, sx, sy, sz); TODOS con base en 0.085.
CUERPO = (
    (-0.14, 0.0, 0.120, 0.10, 0.14, 0.07),   # trasero   0.085..0.155
    (-0.02, 0.0, 0.155, 0.22, 0.20, 0.14),   # tronco    0.085..0.225
    ( 0.14, 0.0, 0.175, 0.16, 0.18, 0.18),   # pecho     0.085..0.265
)
CABEZA = (0.28, 0.0, 0.165, 0.14, 0.15, 0.16)  # 0.085..0.245, x .21..0.35

# APENDICES CRITICOS: 2 patas + 2 alas + cresta + cola (6 cajas).
PATA_SX, PATA_SY, PATA_SZ = 0.05, 0.04, 0.04
PATA_X, PATA_Z = 0.10, 0.105                    # 0.085..0.125
PATA_YS = (-0.055, 0.055)
ALA_SX, ALA_SY, ALA_SZ = 0.14, 0.03, 0.10
ALA_X, ALA_Z = 0.02, 0.190                      # 0.140..0.240
ALA_YS = (-0.105, 0.105)   # SOBRESALEN del tronco (+-0.10): visibles
CRESTA = (0.28, 0.0, 0.290, 0.06, 0.04, 0.09)  # 0.245..0.335 APOYADA
COLA = (-0.22, 0.0, 0.165, 0.12, 0.10, 0.16)   # 0.085..0.245 APOYADA

# DETALLES (6), TODOS podables en BAJA por volumen_bbox < UMBRAL_PODA.
OJO_SX, OJO_SY, OJO_SZ = 0.035, 0.02, 0.035    # 2.45e-5 m3
OJO_X, OJO_Z = 0.310, 0.205                     # 0.1875..0.2225
OJO_YS = (-0.085, 0.085)   # SOBRESALEN de la cabeza (+-0.075)
PICO_SX, PICO_SY, PICO_SZ = 0.03, 0.05, 0.03    # 4.5e-5 m3
PICO_X, PICO_Z = 0.365, 0.185                    # x .35..0.38, z .17..0.20
PLUMA_SX, PLUMA_SY, PLUMA_SZ = 0.02, 0.02, 0.02  # 8e-6 m3
PLUMA_XS = (-0.06, 0.04, 0.14)
PLUMA_Y, PLUMA_Z = 0.0, 0.275                    # 0.265..0.285, lomo

Y_CIMA = 0.335
VACIA_LO, VACIA_HI = 0.27, 0.28   # zona anti-cunia: 0 niveles autorizados
UMBRAL_PODA = 1e-4
PROTEGIDAS = ('pie', 'base', 'soporte', 'tronco', 'poste', 'cuerpo', 'tapa')

assert abs(Y_CIMA - 0.335) < 1e-9, 'cota superior incoherente'
assert AR_SX > 0.30 and (AR_YS[-1] + AR_SY / 2.0) * 2.0 > 0.30, \
    'la rodela no satisface E-50 (min_fp=0.30)'
assert len(AR_YS) * 4 >= 8, 'la rodela no aporta 8 vertices de apoyo'
assert 0.265 < VACIA_LO < VACIA_HI < 0.285, \
    'la zona vacia no queda entre las plumas y la cresta'
assert abs((CRESTA[2] - CRESTA[5] / 2.0) - 0.245) < 1e-9, \
    'la base de la cresta NO coincide con el tope de la cabeza: FLOTARIA'
assert abs((COLA[2] - COLA[5] / 2.0) - AR_TOPE) < 1e-9, \
    'la base de la cola NO coincide con el tope de la rodela: FLOTARIA'
for _s, _v in (('ojo', OJO_SX * OJO_SY * OJO_SZ),
               ('pico', PICO_SX * PICO_SY * PICO_SZ),
               ('pluma', PLUMA_SX * PLUMA_SY * PLUMA_SZ)):
    assert _v < UMBRAL_PODA, '%s NO es podable (vol=%.2g)' % (_s, _v)
for _n in ('SM_Gallina_Ojo_1', 'SM_Gallina_Pico_1', 'SM_Gallina_Pluma_1'):
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
        return mat('MAT_Gallina_%s' % pieza, color, **kw)

    ROCA_M = M('Roca', PALETA['Roca'])
    CUERPO_M = M('Cuerpo', PALETA['Cuerpo'])
    CABEZA_M = M('Cabeza', PALETA['Cabeza'])
    APENDICE_M = M('Apendice', PALETA['Apendice'])
    OJO_M = M('Ojo', PALETA['Ojo'], rough=0.35, spec=0.55)
    PICO_M = M('Pico', PALETA['Pico'])
    PLUMA_M = M('Pluma', PALETA['Pluma'], rough=0.45, spec=0.40)

    # --- CRITICA 1: rodela (3 cajas / 24 verts / 12 apoyados) ---
    frs = [caja('SM_Gallina_Franja_1_NOFUNDIR' if i == 0
                else 'SM_Gallina_Franja_%d' % (i + 1),
                0.0, y, AR_Z, AR_SX, AR_SY, AR_SZ, ROCA_M)
           for i, y in enumerate(AR_YS)]
    rodela = unir('SM_Gallina_Franja_1_NOFUNDIR', frs)
    rodela.name = 'SM_Gallina_Rodela_NOFUNDIR'

    # --- CRITICA 2: cuerpo escalonado (3 cajas / 24 verts) ---
    cb = [caja('SM_Gallina_Lomo_1_NOFUNDIR' if i == 0
               else 'SM_Gallina_Lomo_%d' % (i + 1),
               *t, CUERPO_M)
          for i, t in enumerate(CUERPO)]
    cuerpo = unir('SM_Gallina_Lomo_1_NOFUNDIR', cb)
    cuerpo.name = 'SM_Gallina_Cuerpo_NOFUNDIR'

    # --- CRITICA 3: cabeza (1 caja / 8 verts) ---
    cabeza = caja('SM_Gallina_Cabeza_NOFUNDIR', *CABEZA, CABEZA_M)

    # --- CRITICA 4: 2 patas + 2 alas + cresta + cola (6 cajas / 48 verts) ---
    ap = []
    for i, y in enumerate(PATA_YS):
        ap.append(caja('SM_Gallina_Pata_%d' % (i + 1), PATA_X, y, PATA_Z,
                       PATA_SX, PATA_SY, PATA_SZ, APENDICE_M))
    for i, y in enumerate(ALA_YS):
        ap.append(caja('SM_Gallina_Ala_%d' % (i + 1), ALA_X, y, ALA_Z,
                       ALA_SX, ALA_SY, ALA_SZ, APENDICE_M))
    ap.append(caja('SM_Gallina_Cresta_1', *CRESTA, APENDICE_M))
    ap.append(caja('SM_Gallina_Cola_1', *COLA, APENDICE_M))
    assert len(ap) == 6, 'deben ser 6 apendices, hay %d' % len(ap)
    ap[0].name = 'SM_Gallina_Pata_ACTIVO'
    apendices = unir('SM_Gallina_Pata_ACTIVO', ap)
    apendices.name = 'SM_Gallina_Apendices_NOFUNDIR'

    # --- NO CRITICOS (6), TODOS podables en BAJA por volumen < 1e-4 ---
    ojos = [caja('SM_Gallina_Ojo_%d' % (i + 1), OJO_X, y, OJO_Z,
                 OJO_SX, OJO_SY, OJO_SZ, OJO_M)
            for i, y in enumerate(OJO_YS)]
    pico = caja('SM_Gallina_Pico_1', PICO_X, 0.0, PICO_Z,
                PICO_SX, PICO_SY, PICO_SZ, PICO_M)
    plumas = [caja('SM_Gallina_Pluma_%d' % (i + 1), x, PLUMA_Y, PLUMA_Z,
                   PLUMA_SX, PLUMA_SY, PLUMA_SZ, PLUMA_M)
              for i, x in enumerate(PLUMA_XS)]
    detalles = ojos + [pico] + plumas

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
    assert all(n.startswith('MAT_Gallina_') for n in mats), \
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

    # --- Guardia POSITIVA de altura, cresta/cola y zona vacia ---
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

    # --- Guardia POSITIVA de silueta de AVE ---
    vc = vertices(cuerpo)
    for _tope in (0.155, 0.225, 0.265):
        assert any(abs(w.z - _tope) < 1e-4 for w in vc), \
            'falta el escalon del lomo en z=%.3f' % _tope
    va = vertices(apendices)
    assert any(abs(w.z - Y_CIMA) < 1e-4 for w in va), \
        'falta el tope de la cresta'
    assert any(abs(w.y - 0.12) < 1e-4 for w in va), \
        'falta el borde del ala en y=+0.12'
    assert any(abs(w.y + 0.12) < 1e-4 for w in va), \
        'falta el borde del ala en y=-0.12'
    # Cresta APOYADA: 4 verts del tope de la cabeza + 4 de la base de la
    # cresta + 4 del tope de la cola = 12 vertices reales en z=0.245.
    union = [w for w in vertices(cabeza) + vertices(apendices)
             if abs(w.z - 0.245) < 1e-4]
    assert len(union) == 12, \
        'cresta/cola FLOTANTES o mal asentadas: %d vertices en z=0.245 ' \
        '(esperados 12)' % len(union)
    vt = vertices(cabeza)
    assert any(abs(w.x - 0.35) < 1e-4 for w in vt), \
        'falta el hocico en x=0.35'
    print('ENSAMBLE rodela->cuerpo(3 escalones)->cabeza->6 apendices OK | '
          'CRESTA+COLA APOYADAS %d verts en z=0.245 | ALAS +-0.12 OK'
          % len(union))

    camara(escena, 'CAM_Gallina', (1.45, -1.60, 0.90), (0.0, 0.0, 0.19))
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
    print('LISTO — gallina sobre rodela (M36 / L22)')
