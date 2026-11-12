# crear_mariposa_lowpoly.py — Mariposa Lunar (M36 / L23 / B26)
#
# HUECO REAL MEDIDO 2026-11-11 21:50 -0300:
#   `HY4/BACKLOGS/02-Backlog-Pendientes-Assets.md` L23
#       "- [ ] Mariposa (alas simples para animar)"
#   `HY4/36-Fauna/checklist.md` L27 y
#   `CHECKLIST-OBJETOS-BLENDER.md` L209: idem, `[ ]`.
#   0 GLB / 0 .blend / 0 generador `*mariposa*`. `36-Fauna` tiene 12 GLB
#   nominales y NINGUNO es mariposa. No es duplicado.
#   Es el ULTIMO HUECO de la COLA ACTIVA M36 (acuse 68).
#
# ===========================================================================
# ANCLA DE SPEC REAL (como B21 y B24)
# ===========================================================================
# `DOCUMENTACION/36-Fauna/plan-inicial/01-Requerimientos.md` L45:
#   | Mariposa Lunar | Bosque Ancestral | Rara | Nocturno |
#   | Primavera/Verano | CURIOSO (revolotea cerca de la luz de la camara) |
#   | noches despejadas |
# Bioma/rareza/horario/estacion/comportamiento/clima DEFINIDOS. Se modela
#   la ESPECIE DEL CATALOGO (nocturna, rara, atraida por la luz) con paleta
#   violeta/azul y motas luminosas. NINGUN documento define cotas, silueta
#   ni materiales del prop -> DECISION DE AUTORIA. Hy4 no edita
#   01-Requerimientos.md.
# `grep -rniE '\b(mariposa|mariposas)\b' DOCUMENTACION/` = 17 hits
#   (1 ancla L45, 1 checklist M36 L118, 2 de 33-Agricultura, resto HY4).
# FALSO POSITIVO MEDIDO Y EXCLUIDO: `ala` suelta = 8536 hits
#   (`ala` subcadena de "sala"/"mala"/"pala"; echo 'sala' | grep -ci ala
#   = 1). Familia de B20/B23/B24/B25.
#
# ===========================================================================
# DECISION SOBRE "ALAS SIMPLES PARA ANIMAR" Y LA GUIA 10 (PUBLICADA)
# ===========================================================================
# `DOCUMENTACION/GUIA-BLENDER/10-animales-bimodo.md` seccion 10.2
#   ("Anatomia minima del ave bimodo o animal bimodo en general") exige
#   `SM_<Animal>_Ala_L / _R` y regla 1: "ALAS: loft por ANILLOS desde el
#   hombro ... NO cubos" con ORIGEN en el hombro (pivote Godot).
#   El checklist L23 pide "alas SIMPLES para animar".
# B26 **NO ES UN ASSET BIMODO** (sin 2 poses ni modos de locomocion; es un
#   prop estatico de diorama). Se aplica de la guia SOLO la convencion de
#   NOMBRES y el requisito funcional de PIEZAS INDEPENDIENTES, con
#   MATERIALES DISTINTOS (`AlaL` / `AlaR`) para que el merge por material
#   de `generar_variante.py` NO las fusione en ningun LOD.
#   NO se aplica el loft de 8 anillos ni el pivote en hombro: el checklist
#   pide alas simples y todo el ciclo B18-B25 usa cajas axis-aligned para
#   la guardia por NIVELES DE COORDENADA.
# "PARA ANIMAR" queda satisfecho EN EL ASSET: las 2 alas son mallas/nodos
#   SEPARADOS en los 3 LOD, listos para que un dueno posterior (M48
#   Animacion / integracion en escena) les asigne rotacion. Hy4 NO
#   implementa animacion, rigs, pivotes ni integracion en escena.
#   Contrato bimodo completo => PROPUESTO para una eventual B26-bis.
#
# ===========================================================================
# DESTINO (MEDIDO)
# ===========================================================================
# 1 asset x 3 LOD = 3 GLB: `36-Fauna_mariposa.glb` (alta/media/baja).
# `36-Fauna` YA esta en `MODULOS` (exportar_godot.py L70): NO se crea
#   modulo ni se toca el exportador.
#
# ===========================================================================
# COTAS (DECISION DE AUTORIA)
# ===========================================================================
#   1 voxel = 1.00 m · Z_APOYO = 0.045 (E-12, arena top 0.05 / E-67).
#   RODELA .................. 3 franjas 0.44 x 0.10 x 0.04, 12 vertices
#      apoyados, huella 0.44 x 0.36. Una mariposa suelta tendria ~0.20x0.10
#      y FALLARIA E-50 (min_fp=0.30, min_toca=8 DEFAULT, NO relajado).
#   CUERPO .................. 3 cajas escalonadas DELGADAS (sy=0.10/0.12).
#   ALAS (2 objetos) ........ `SM_Mariposa_Ala_L/R_NOFUNDIR`, 2 cajas cada
#      una (superior + inferior), en y=+-0.15/0.16. PIEZAS SEPARADAS con
#      materiales `AlaL`/`AlaR` DISTINTOS -> jamas se fusionan.
#   DETALLES (6) ............ 2 ojos + 2 antenas + 2 manchas, TODOS
#      podables en BAJA por volumen_bbox < 1e-4.
#   ZONA VACIA (0.27,0.28) .. 0 niveles: solo hay vertices en 0.265 y
#      0.29. Anti-cunia para la guardia. Y_CIMA = 0.31 (ala superior).
#   1 MATERIAL POR CRITICA => en BAJA quedan EXACTAMENTE 4 materiales.
#   GEOMETRIA AXIS-ALIGNED .. guardia POSITIVA por NIVELES DE COORDENADA.
#
# ===========================================================================
# PRESUPUESTO M166 Y DISENO DE LOS 3 LOD (A VERIFICAR, NO HEREDADO)
# ===========================================================================
#   ALTA  = 10 objetos / 7 materiales: 4 criticas + 6 detalles.
#           16 cajas x 12 tris = 192 tris.
#   MEDIA =  7 objetos / 7 materiales: FASE 1 funde los 6 detalles en 3
#            grupos por lista de material (merge LOSSLESS, 192 tris).
#   BAJA  =  4 objetos / 4 materiales: FASE 0 PODA los 6 detalles, el
#            DECIMATE actua sobre **0 mallas**. 10 cajas = 120 tris.
#            LOD REAL por poda deliberada, SIN deformacion.
#
# LECCION APLICADA DE B18 (acta 28) A B25 (acta 35): el DECIMATE sobre
#   cajas disjuntas mueve vertices FUERA de los planos autorizados,
#   invisible en el render y NO detectado por chk_asset.py (mide COSTE,
#   no FORMA). Se evita POR DISENIO. Ningun nombre de detalle contiene
#   un sufijo de `PROTEGIDAS`, que inhibiria la poda EN SILENCIO.
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
#     --python crear_mariposa_lowpoly.py
#   generar_variante_headless.py -- 36-Fauna mariposa_lowpoly --media --baja
import bpy
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
from plantilla_asset import (limpiar, mat, arena, iluminar, asentar, camara,
                             shade_flat, guardar, caja, piezas, zmin_real,
                             Z_APOYO)

MODULO = '36-Fauna'
ASSET = 'mariposa'

# --- Paleta (DECISION DE AUTORIA): nocturna, rara, atraida por la luz ---
PALETA = {
    'Roca':   (0.52, 0.50, 0.47),
    'Cuerpo': (0.20, 0.18, 0.34),   # azul noche
    'AlaL':   (0.42, 0.32, 0.72),   # violeta
    'AlaR':   (0.30, 0.46, 0.78),   # azul (DISTINTO adrede: no fusionar)
    'Ojo':    (0.08, 0.08, 0.10),
    'Antena': (0.96, 0.94, 0.86),
    'Mancha': (0.98, 0.88, 0.40),   # motas luminosas
}

Z = Z_APOYO                       # 0.045

# RODELA: 3 franjas (12 vertices apoyados, huella 0.44 x 0.36).
AR_SX, AR_SY, AR_SZ = 0.44, 0.10, 0.04
AR_YS = (-0.13, 0.0, 0.13)
AR_Z = Z + AR_SZ / 2.0                       # 0.065 -> 0.045..0.085
AR_TOPE = Z + AR_SZ                          # 0.085

# CUERPO DELGADO ESCALONADO: (x, y, z, sx, sy, sz); base 0.085.
CUERPO = (
    (-0.14, 0.0, 0.120, 0.10, 0.10, 0.07),   # abdomen  0.085..0.155
    (-0.02, 0.0, 0.155, 0.22, 0.12, 0.14),   # torax    0.085..0.225
    ( 0.14, 0.0, 0.175, 0.16, 0.12, 0.18),   # cabeza   0.085..0.265
)

# ALAS: 2 cajas por lado. Superior e inferior, SIMPLES y SEPARADAS.
# (x, y, z, sx, sy, sz). y>0 = Ala_R (azul), y<0 = Ala_L (violeta).
ALA_SUP = (0.02, 0.16, 0.300, 0.18, 0.12, 0.02)   # z 0.29..0.31
ALA_INF = (-0.10, 0.15, 0.250, 0.14, 0.10, 0.02)  # z 0.24..0.26

# DETALLES (6), TODOS podables en BAJA por volumen_bbox < UMBRAL_PODA.
OJO_SX, OJO_SY, OJO_SZ = 0.035, 0.02, 0.035    # 2.45e-5 m3
OJO_X, OJO_Z = 0.210, 0.235                     # 0.2175..0.2525
OJO_YS = (-0.075, 0.075)   # sobresalen de la cabeza (+-0.06)
ANT_SX, ANT_SY, ANT_SZ = 0.02, 0.02, 0.04       # 1.6e-5 m3
ANT_X, ANT_Z = 0.230, 0.285                     # 0.265..0.305
ANT_YS = (-0.03, 0.03)
MAN_SX, MAN_SY, MAN_SZ = 0.02, 0.01, 0.03       # 6e-6 m3
MAN_XS = (-0.04, 0.10)
MAN_Y, MAN_Z = 0.065, 0.200                     # 0.185..0.215

Y_CIMA = 0.31
VACIA_LO, VACIA_HI = 0.27, 0.28   # zona anti-cunia: 0 niveles autorizados
UMBRAL_PODA = 1e-4
PROTEGIDAS = ('pie', 'base', 'soporte', 'tronco', 'poste', 'cuerpo', 'tapa')

assert abs(Y_CIMA - 0.31) < 1e-9, 'cota superior incoherente'
assert AR_SX > 0.30 and (AR_YS[-1] + AR_SY / 2.0) * 2.0 > 0.30, \
    'la rodela no satisface E-50 (min_fp=0.30)'
assert len(AR_YS) * 4 >= 8, 'la rodela no aporta 8 vertices de apoyo'
assert 0.265 < VACIA_LO < VACIA_HI < 0.29, \
    'la zona vacia no queda entre el lomo y el ala superior'
for _s, _v in (('ojo', OJO_SX * OJO_SY * OJO_SZ),
               ('antena', ANT_SX * ANT_SY * ANT_SZ),
               ('mancha', MAN_SX * MAN_SY * MAN_SZ)):
    assert _v < UMBRAL_PODA, '%s NO es podable (vol=%.2g)' % (_s, _v)
for _n in ('SM_Mariposa_Ojo_1', 'SM_Mariposa_Antena_1',
           'SM_Mariposa_Mancha_1'):
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
        return mat('MAT_Mariposa_%s' % pieza, color, **kw)

    ROCA_M = M('Roca', PALETA['Roca'])
    CUERPO_M = M('Cuerpo', PALETA['Cuerpo'])
    ALAL_M = M('AlaL', PALETA['AlaL'], rough=0.45, spec=0.40)
    ALAR_M = M('AlaR', PALETA['AlaR'], rough=0.45, spec=0.40)
    OJO_M = M('Ojo', PALETA['Ojo'], rough=0.35, spec=0.55)
    ANT_M = M('Antena', PALETA['Antena'])
    # NO usar `emisivo=`: la rama de `plantilla_asset.py::mat()` hace
    # `(*emisivo[0], 1.0)` sobre un float -> TypeError (bug LATENTE de la
    # plantilla, medido en B26; ningun generador B18-B25 la habia usado).
    # No se toca infraestructura ajena sin GO: el brillo se logra con el
    # color base amarillo claro + spec alto. Hallazgo reportado al director.
    MAN_M = M('Mancha', PALETA['Mancha'], rough=0.30, spec=0.60)

    # --- CRITICA 1: rodela (3 cajas / 24 verts / 12 apoyados) ---
    frs = [caja('SM_Mariposa_Franja_1_NOFUNDIR' if i == 0
                else 'SM_Mariposa_Franja_%d' % (i + 1),
                0.0, y, AR_Z, AR_SX, AR_SY, AR_SZ, ROCA_M)
           for i, y in enumerate(AR_YS)]
    rodela = unir('SM_Mariposa_Franja_1_NOFUNDIR', frs)
    rodela.name = 'SM_Mariposa_Rodela_NOFUNDIR'

    # --- CRITICA 2: cuerpo delgado escalonado (3 cajas / 24 verts) ---
    cb = [caja('SM_Mariposa_Lomo_1_NOFUNDIR' if i == 0
               else 'SM_Mariposa_Lomo_%d' % (i + 1),
               *t, CUERPO_M)
          for i, t in enumerate(CUERPO)]
    cuerpo = unir('SM_Mariposa_Lomo_1_NOFUNDIR', cb)
    cuerpo.name = 'SM_Mariposa_Cuerpo_NOFUNDIR'

    # --- CRITICAS 3 y 4: ALAS SEPARADAS, materiales DISTINTOS ---
    # Cada ala es su PROPIO objeto `_NOFUNDIR`: el merge por lista de
    # material no puede juntarlas (AlaL != AlaR), y FASE 0 no las poda.
    sup_l = tuple([ALA_SUP[0], -ALA_SUP[1], ALA_SUP[2],
                   ALA_SUP[3], ALA_SUP[4], ALA_SUP[5]])
    inf_l = tuple([ALA_INF[0], -ALA_INF[1], ALA_INF[2],
                   ALA_INF[3], ALA_INF[4], ALA_INF[5]])
    par_l = [caja('SM_Mariposa_Ala_L_ACTIVO', *sup_l, ALAL_M),
             caja('SM_Mariposa_Ala_L_Inf', *inf_l, ALAL_M)]
    ala_l = unir('SM_Mariposa_Ala_L_ACTIVO', par_l)
    ala_l.name = 'SM_Mariposa_Ala_L_NOFUNDIR'

    par_r = [caja('SM_Mariposa_Ala_R_ACTIVO', *ALA_SUP, ALAR_M),
             caja('SM_Mariposa_Ala_R_Inf', *ALA_INF, ALAR_M)]
    ala_r = unir('SM_Mariposa_Ala_R_ACTIVO', par_r)
    ala_r.name = 'SM_Mariposa_Ala_R_NOFUNDIR'

    # --- NO CRITICOS (6), TODOS podables en BAJA por volumen < 1e-4 ---
    ojos = [caja('SM_Mariposa_Ojo_%d' % (i + 1), OJO_X, y, OJO_Z,
                 OJO_SX, OJO_SY, OJO_SZ, OJO_M)
            for i, y in enumerate(OJO_YS)]
    antenas = [caja('SM_Mariposa_Antena_%d' % (i + 1), ANT_X, y, ANT_Z,
                    ANT_SX, ANT_SY, ANT_SZ, ANT_M)
               for i, y in enumerate(ANT_YS)]
    manchas = [caja('SM_Mariposa_Mancha_%d' % (i + 1), x, MAN_Y, MAN_Z,
                    MAN_SX, MAN_SY, MAN_SZ, MAN_M)
               for i, x in enumerate(MAN_XS)]
    detalles = ojos + antenas + manchas

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
    assert all(n.startswith('MAT_Mariposa_') for n in mats), \
        'material ajeno en la escena: %s' % mats
    print('LOD_PREVISTO ALTA=%d obj/%d mats | criticas=%d | detalles=%d '
          '-> MEDIA=7 | BAJA(poda 6)=4, DECIMATE=0 mallas'
          % (len(ps), len(mats), len(criticas), len(detalles)))

    # --- Guardia POSITIVA de ALAS SEPARADAS (el requisito "para animar") ---
    ml = {m.name for m in ala_l.data.materials if m}
    mr = {m.name for m in ala_r.data.materials if m}
    assert ml == {'MAT_Mariposa_AlaL'} and mr == {'MAT_Mariposa_AlaR'}, \
        'las alas NO tienen materiales distintos: L=%s R=%s' % (ml, mr)
    assert not (ml & mr), 'las alas comparten material: se fusionarian'
    print('ALAS SEPARADAS L=%s (%d verts) R=%s (%d verts) '
          '| materiales DISTINTOS -> no fusionables'
          % (ala_l.name, len(vertices(ala_l)), ala_r.name,
             len(vertices(ala_r))))

    # --- Procedencia POSITIVA de las 4 criticas: 8 verts por caja ---
    for o, n in ((rodela, 24), (cuerpo, 24), (ala_l, 16), (ala_r, 16)):
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

    # --- Guardia POSITIVA de altura, alas y zona vacia ---
    z_max = max(w.z for o in ps for w in vertices(o))
    assert abs(z_max - Y_CIMA) < 1e-4, \
        'algo sobrevuela las alas: z_max=%.4f' % z_max
    niv = niveles_z(ps)
    espurios = [v for v in niv if VACIA_LO < v < VACIA_HI]
    assert not espurios, 'niveles espurios en zona vacia: %s' % espurios[:5]
    print('ALTURA_REAL z=[%.4f..%.4f] alto=%.4f | HUELLA_CONTACTO=%.2fx%.2f '
          '| toca=%d' % (Z, z_max, z_max - Z, fp_x, fp_y, toca))
    print('ZONA_VACIA (%.2f, %.2f): 0 niveles | niveles_z=%d'
          % (VACIA_LO, VACIA_HI, len(niv)))

    # --- Guardia POSITIVA de silueta de mariposa ---
    vc = vertices(cuerpo)
    for _tope in (0.155, 0.225, 0.265):
        assert any(abs(w.z - _tope) < 1e-4 for w in vc), \
            'falta el escalon del cuerpo en z=%.3f' % _tope
    vl, vr = vertices(ala_l), vertices(ala_r)
    assert any(abs(w.z - Y_CIMA) < 1e-4 for w in vl + vr), \
        'falta el tope del ala superior'
    assert any(abs(w.y + 0.22) < 1e-4 for w in vl), \
        'falta el borde exterior del ala L en y=-0.22'
    assert any(abs(w.y - 0.22) < 1e-4 for w in vr), \
        'falta el borde exterior del ala R en y=+0.22'
    assert any(abs(w.z - 0.24) < 1e-4 for w in vl + vr), \
        'falta el ala inferior (z=0.24)'
    print('ENSAMBLE rodela->cuerpo(3 escalones)->2 ALAS(2 cajas c/u) '
          '->6 detalles OK | y=+-0.22 | z=[0.24,0.31]')

    camara(escena, 'CAM_Mariposa_Lunar', (1.45, -1.60, 0.90),
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
    print('LISTO — mariposa lunar sobre rodela (M36 / L23)')
