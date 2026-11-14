# verificar_columna_rota_blends.py — Guardia POSITIVA de FORMA sobre los 6
# .blend de `columna_rota` (2 variantes de altura x 3 LOD), módulo M25 / B29.
#
# NO es QA §21.8 ni sello: es una guardia de AUTORIA/REGRESION.
#
# HUECO QUE CUBRE: `columna_entera` tiene DOS guardias (bpy sobre .blend +
# BIN sobre GLB); `columna_rota` solo tenia la del BIN (B27,
# verificar_columna_rota.py, 114/114/0). chk_asset.py mide COSTE, no FORMA.
# El precedente real es 2026-11-06: la BAJA de columna_entera pasaba los 3
# presupuestos M166 (342/700 tris, 4/6 obj, 4/4 mats) con el ABACO
# COLAPSADO por decimate. Un verde de coste NO se hereda a la forma; un
# verde del BIN NO se hereda al .blend de origen.
#
# HALLAZGO REAL MEDIDO EN B29 (Temp/hy4_b29_blends_probe_20261114.json):
#   MEDIA  desv_max=0.0000, 0 vertices fuera de plano  -> merge FASE 1 limpio
#   BAJA   desv_max=0.0418 m, 21/22 niveles espurios, 34/42 vertices fuera
#          de plano, z_max deriva +0.0007 m. Es la TRAMPA B18 (DECIMATE
#          sobre cajas disjuntas mueve vertices fuera de los planos
#          autorizados), invisible en el render y en chk_asset.py.
# C10 es un TECHO DE REGRESION sobre esa DEUDA ABIERTA, NO una aprobacion:
# tolera lo ya medido para que un dano MAYOR (colapso de losa) caiga en
# ROJO. Si el director autoriza re-autorar la BAJA con poda deliberada
# (0 decimate, como B19-B26), ESTE TECHO DEBE BAJAR A 0 y C10 debe
# re-medirse. No se consagra el bug: se publica con la cifra medida.
#
# Uso (Blender 4.2 headless, --python-exit-code 1 OBLIGATORIO: sin el,
# un AssertionError interno devuelve RC=0 = falso verde, medido en M18-BIS):
#   blender -b --factory-startup --python-exit-code 1 --python \
#       verificar_columna_rota_blends.py -- --piso 0
#   blender -b --factory-startup --python-exit-code 1 --python \
#       verificar_columna_rota_blends.py                      # VERDE
#   blender -b --factory-startup --python-exit-code 1 --python \
#       verificar_columna_rota_blends.py -- --inyectar       # ROJO colapso
#   blender -b --factory-startup --python-exit-code 1 --python \
#       verificar_columna_rota_blends.py -- --inyectar-decimate  # ROJO decimate
#   blender -b --factory-startup --python-exit-code 1 --python \
#       verificar_columna_rota_blends.py -- --solo <blend>   # CIEGO exit 3
#
# La inyeccion escribe SOLO en Temp/; los 6 .blend publicados quedan
# intactos (se verifica por sha256 antes y despues).
import bpy  # noqa: E402
import os  # noqa: E402
import sys  # noqa: E402
import hashlib  # noqa: E402

RAIZ = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                   '..', '..', '..', '..', '..'))
MOD_DIR = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp', '25-Ruinas-Templos')
TEMP = os.path.join(RAIZ, 'Temp')
ROJO = os.path.join(TEMP, 'hy4_b29_rojo_20261114.blend')
ROJO_DEC = os.path.join(TEMP, 'hy4_b29_rojo_decimate_20261114.blend')

VARIANTES = ('columna_rota_alta_lowpoly', 'columna_rota_baja_lowpoly')
SUFS = ('', '_media', '_baja')
LODS = ('alta', 'media', 'baja')

# --- COTAS MEDIDAS EN VERDE (sonda B29), no estimadas -------------------
Z_APOYO = 0.045
TOPES = {'columna_rota_alta_lowpoly': 2.1900,
         'columna_rota_baja_lowpoly': 1.4900}
TOL_ZMAX = 0.001          # admite la deriva +0.0007 del decimate en BAJA
OBJETOS = {'alta': 12, 'media': 5, 'baja': 4}
HUELLA_X, TOL_X = 1.2280, 0.002
HUELLA_Y_LO, HUELLA_Y_HI = 0.9450, 0.9520
APOYO_MIN = 24
MATS = {'alta': 5, 'media': 5, 'baja': 4}
TRIS_MAX = {'alta': 6000, 'media': 1500, 'baja': 700}  # presupuesto M166
TECHO_DECIMATE = 0.0450   # MEDIDO 0.0418 + 0.0032 margen float32. DEUDA ABIERTA
TECHO_VERTS = 46          # MEDIDO: 34 y 42 vertices fuera de plano en BAJA
                          # + 4 de margen. Techo de REGRESION, no aprobacion.
CORONA_MIN = 2            # MEDIDO: 2 vertices en (tope-0.02, tope+0.001)
FUSTE_MIN = 1.0           # MEDIDO: rango minimo del fuste = 1.0150 m
DIF_ALTURA, TOL_DIF = 0.7000, 0.001

# MEDIDO EN VERDE 2026-11-14 con `--piso 0` ANTES de fijar la constante:
#   10 checks x 6 blends + 3 globales = 63, CHECKS=63 PASADOS=63
#   FALLOS=0 BLOQUES=6 GLOBALES=3 RC=0. Ver acta 39 / log 2419.
CHECKS_MINIMOS = 63
BLOQUES_MINIMOS = 6


def sha12(ruta):
    h = hashlib.sha256()
    with open(ruta, 'rb') as f:
        for bloque in iter(lambda: f.read(1 << 16), b''):
            h.update(bloque)
    return h.hexdigest()[:12]


def verts_mundo(o):
    return [o.matrix_world @ v.co for v in o.data.vertices]


def leer(ruta):
    """Abre un .blend y devuelve TODAS las mediciones de forma."""
    bpy.ops.wm.open_mainfile(filepath=os.path.abspath(ruta))
    bpy.context.view_layer.update()
    obs = [o for o in bpy.context.scene.objects
           if o.type == 'MESH' and o.name.startswith('SM_')]
    vs = [v for o in obs for v in verts_mundo(o)]
    if not vs:
        return None
    zs = [round(v.z, 4) for v in vs]
    niveles = {}
    for z in zs:
        niveles[z] = niveles.get(z, 0) + 1
    va = [v for v in vs if abs(v.z - Z_APOYO) < 1e-4]
    fx = (max(v.x for v in va) - min(v.x for v in va)) if va else -1.0
    fy = (max(v.y for v in va) - min(v.y for v in va)) if va else -1.0

    mats = set()
    tris = 0
    rangos = []
    for o in obs:
        m = o.data
        m.calc_loop_triangles()
        tris += len(m.loop_triangles)
        for f in m.polygons:
            if f.material_index < len(m.materials):
                mat = m.materials[f.material_index]
                if mat:
                    mats.add(mat.name)
        ov = verts_mundo(o)
        rangos.append((o.name, max(w.z for w in ov) - min(w.z for w in ov)))
    return {
        'nombres': [o.name for o in obs],
        'zmin': min(v.z for v in vs),
        'zmax': max(v.z for v in vs),
        'niveles': sorted(niveles),
        'conteos': niveles,
        'huella': (fx, fy),
        'apoyo': len(va),
        'mats': mats,
        'tris': tris,
        'rango_max': max((r for _, r in rangos), default=0.0),
        'n_obj': len(obs),
    }


def desviacion(conteos, ref):
    """(desv_max, niveles_espurios, vertices_fuera_de_plano).

    La referencia es el ALTA del mismo asset (sin decimate), NO un numero
    escrito a mano: si se re-autora el ALTA, la guardia se re-calibra sola.
    """
    if not ref:
        return 0.0, 0, 0
    desv_max = 0.0
    n_fuera = 0
    nverts = 0
    for n, cuenta in conteos.items():
        d = min(abs(n - r) for r in ref)
        desv_max = max(desv_max, d)
        if d > 0.0005:
            n_fuera += 1
            nverts += cuenta
    return desv_max, n_fuera, nverts


def verificar(ruta, variante, lod, ref):
    etiqueta = '%s/%s' % ('A' if 'alta_lowpoly' in variante else 'B', lod)
    d = leer(ruta)
    ok = fallos = 0

    def check(num, cond, detalle):
        nonlocal ok, fallos
        if cond:
            ok += 1
            print('OK   %-8s C%-2d %s' % (etiqueta, num, detalle))
        else:
            fallos += 1
            print('FAIL %-8s C%-2d %s' % (etiqueta, num, detalle))

    if d is None:
        for n in range(1, 11):
            check(n, False, 'sin vertices SM_: no se puede medir')
        return ok, fallos, None

    tope = TOPES[variante]
    desv, n_fuera, nverts_fuera = desviacion(d['conteos'], ref)
    # BANDA ABSOLUTA respecto del TOPE ESPERADO, no del zmax medido: si se
    # usara zmax, un colapso de la corona redefiniria la banda y C9 daria
    # verde sobre el propio dano (falso verde medido en el primer ROJO).
    corona = sum(c for n, c in d['conteos'].items()
                 if tope - 0.02 < n <= tope + 0.001)
    fx, fy = d['huella']

    check(1, d['n_obj'] == OBJETOS[lod],
          'objetos SM_=%d (esperado %d)' % (d['n_obj'], OBJETOS[lod]))
    check(2, abs(d['zmin'] - Z_APOYO) < 1e-4,
          'z_min=%.4f (Z_APOYO=%.4f)' % (d['zmin'], Z_APOYO))
    check(3, abs(d['zmax'] - tope) <= TOL_ZMAX,
          'z_max=%.4f (tope=%.4f tol=%.4f)' % (d['zmax'], tope, TOL_ZMAX))
    check(4, (abs(fx - HUELLA_X) <= TOL_X
              and HUELLA_Y_LO <= fy <= HUELLA_Y_HI
              and d['apoyo'] >= APOYO_MIN),
          'huella_apoyo=%.4fx%.4f con %d vertices' % (fx, fy, d['apoyo']))
    check(5, len(d['mats']) == MATS[lod],
          'materiales_por_cara=%d (esperado %d) %s'
          % (len(d['mats']), MATS[lod], sorted(d['mats'])))
    check(6, d['tris'] <= TRIS_MAX[lod],
          'tris=%d <= %d (perfil M166 %s)' % (d['tris'], TRIS_MAX[lod], lod))
    if lod == 'alta':
        estructura = all(any(k in n for n in d['nombres'])
                         for k in ('Fuste', 'Corona', 'Basa'))
    else:
        estructura = any(n.startswith('SM_ColRota_M_ColRota_')
                         for n in d['nombres'])
    check(7, estructura,
          'estructura %s: %s' % (lod, d['nombres'][:3]))
    check(8, d['rango_max'] >= FUSTE_MIN,
          'fuste_integro rango_max=%.4f (>=%.2f)' % (d['rango_max'], FUSTE_MIN))
    check(9, corona >= CORONA_MIN,
          'corona_no_colapsada vertices=%d (>=%d)' % (corona, CORONA_MIN))
    check(10, desv <= TECHO_DECIMATE and nverts_fuera <= TECHO_VERTS,
          'TECHO_REGRESION_decimate desv_max=%.4f (techo=%.4f) '
          'niveles_espurios=%d vertices_fuera_plano=%d (techo=%d) '
          '[DEUDA ABIERTA]'
          % (desv, TECHO_DECIMATE, n_fuera, nverts_fuera, TECHO_VERTS))
    return ok, fallos, d


def inyectar(src, dst, modo):
    """Reproduce EN UNA COPIA los DOS danos reales que esta guardia vigila.

    modo='colapso'  : baja 0.09 m los vertices de la corona. Es el dano de
        2026-11-06 en columna_entera (vertices a 2.8267/2.8733 bajo una
        losa de 2.92). Rompe C3/C9/G3: tope, corona y diferencia de altura.
    modo='decimate' : desplaza +0.0133 m en Z y X TODOS los vertices del
        objeto mayor. Es la TRAMPA B18 (DECIMATE sobre cajas disjuntas
        mueve vertices fuera de los planos autorizados). Rompe C10: el
        techo de regresion de vertices fuera de plano.
    El .blend publicado NO se toca en ninguno de los dos casos.
    """
    bpy.ops.wm.open_mainfile(filepath=os.path.abspath(src))
    bpy.context.view_layer.update()
    obs = [o for o in bpy.context.scene.objects
           if o.type == 'MESH' and o.name.startswith('SM_')]
    cambiados = 0
    if modo == 'colapso':
        zmax = max((o.matrix_world @ v.co).z
                   for o in obs for v in o.data.vertices)
        for o in obs:
            for v in o.data.vertices:
                w = o.matrix_world @ v.co
                if w.z > zmax - 0.15:
                    v.co.z -= 0.09
                    cambiados += 1
            o.data.update()
    else:
        mayor = max(obs, key=lambda o: len(o.data.vertices))
        for v in mayor.data.vertices:
            v.co.z += 0.0133
            v.co.x += 0.0133
            cambiados += 1
        mayor.data.update()
    os.makedirs(TEMP, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(dst))
    return cambiados


def main():
    argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
    piso = CHECKS_MINIMOS
    solo, rojo = None, None
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--piso':
            i += 1
            piso = int(argv[i])
        elif a == '--solo':
            i += 1
            solo = argv[i]
        elif a == '--inyectar':
            rojo = 'colapso'
        elif a == '--inyectar-decimate':
            rojo = 'decimate'
        i += 1

    # Referencia de niveles: el ALTA de cada variante (sin decimate).
    ref = {}
    for var in VARIANTES:
        d = leer(os.path.join(MOD_DIR, var + '.blend'))
        ref[var] = d['niveles'] if d else []
        print('REF  %-28s niveles_autorizados=%d tope=%.4f'
              % (var, len(ref[var]), max(ref[var]) if ref[var] else -1))

    rutas = []
    for var in VARIANTES:
        for suf, lod in zip(SUFS, LODS):
            rutas.append((var, lod, os.path.join(MOD_DIR, var + suf + '.blend')))

    if solo:
        var = next((v for v in VARIANTES if os.path.basename(solo).startswith(v)),
                   VARIANTES[0])
        rutas = [(var, 'alta', solo)]

    if rojo:
        src = os.path.join(MOD_DIR, VARIANTES[0] + '_baja.blend')
        publicado = sha12(src)
        dst = ROJO if rojo == 'colapso' else ROJO_DEC
        cambiados = inyectar(src, dst, rojo)
        assert sha12(src) == publicado, 'la inyeccion toco el .blend publicado'
        print('INYECCION [%s]: %d vertices mutados en %s | publicado sha=%s '
              'INTACTO' % (rojo, cambiados, os.path.relpath(dst, RAIZ),
                           publicado))
        rutas = [(v, l, dst if (v == VARIANTES[0] and l == 'baja') else r)
                 for v, l, r in rutas]

    total_ok = total_fallos = bloques = 0
    zmax_por = {}
    for var, lod, ruta in rutas:
        if not os.path.isfile(ruta):
            print('FALTA BLEND: %s' % ruta)
            sys.exit(2)
        a, b, medido = verificar(ruta, var, lod, ref[var])
        total_ok += a
        total_fallos += b
        bloques += 1
        if medido:
            zmax_por[(var, lod)] = medido['zmax']

    # Globales POSITIVOS: las 2 variantes deben diferir EXACTAMENTE 0.70 m
    # en los 3 LOD. Con --solo no hay par -> no se publica ningun global
    # (publicar uno que no se ejecuto seria un check invisible, trampa 46).
    globales = 0
    if not solo:
        for lod in LODS:
            a = zmax_por.get((VARIANTES[0], lod))
            b = zmax_por.get((VARIANTES[1], lod))
            cond = (a is not None and b is not None
                    and abs((a - b) - DIF_ALTURA) <= TOL_DIF)
            if cond:
                total_ok += 1
            else:
                total_fallos += 1
            globales += 1
            print('%s G%-2d %-5s diff=%.4f (esperado %.4f)'
                  % ('OK  ' if cond else 'FAIL', globales, lod,
                     (a - b) if (a is not None and b is not None) else -1,
                     DIF_ALTURA))

    # Un check que FALLA sigue siendo EJECUTADO: si se contara solo el
    # verde, el ROJO pareceria CIEGO. CIEGO = bloque que NO corrio.
    total = total_ok + total_fallos
    print('CHECKS=%d PASADOS=%d FALLOS=%d BLOQUES=%d GLOBALES=%d PISO=%d'
          % (total, total_ok, total_fallos, bloques, globales, piso))
    if total < piso or bloques < BLOQUES_MINIMOS:
        print('CIEGO: faltan bloques o checks respecto del verde medido')
        sys.exit(3)
    if total_fallos:
        print('ROJO: %d aserciones de forma fallaron' % total_fallos)
        sys.exit(1)
    print('VERDE: forma de columna_rota integra en %d blends' % bloques)
    sys.exit(0)


if __name__ == '__main__':
    main()
