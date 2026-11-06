# verificar_casa_mansion.py — Guardia POSITIVA de geometría (M18-BIS, Mansión)
#
# NO es QA §21.8 ni sello: es una guardia de AUTORÍA. `chk_asset.py` mide
# COSTE (objetos/tris/materiales), no FORMA. El 2026-11-06 la primera BAJA de
# la mansión (ratio 0.48, sin `_NOFUNDIR`) daba VERDE en M166 (684/700 tris,
# 4/6 obj, 4/4 mats) con dos defectos reales medidos sobre vértices:
#   - 3/4 esquinas del cuerpo en Z_APOYO (el decimate se comió una esquina
#     del zócalo dentro de la malla de piedra fundida).
#   - 0 vértices de escalón: Y máx. de apoyo cayó de 5.4700 a 5.0000, es
#     decir, el acceso desapareció.
# Mismo patrón que el PLINTO/ÁBACO de `columna_entera` (M25, acta 19).
#
# FIX (en el generador, NO en el derivador compartido): las mallas
# `SM_Mansion_Zocalo_NOFUNDIR` y `SM_Mansion_Pedestal_NOFUNDIR` quedan fuera
# de poda/merge/decimate. BAJA final: 6 obj / 676 tris / 4 mats, ratio 0.40.
#
# Uso (Blender headless, sin socket 9876):
#   blender -b --factory-startup --python verificar_casa_mansion.py
#   blender -b --factory-startup --python verificar_casa_mansion.py -- \
#       <blend1> <blend2> <blend3>
#
# Un check que FALLA se cuenta igual como EJECUTADO (si se contaran solo los
# verdes, la inyección en rojo parecería CIEGA). CIEGO = bloque que NO corrió.
#
# TRES CAMINOS MEDIDOS 2026-11-06:
#   VERDE 3 blends canónicos -> 33/33/0, exit 0
#   ROJO  3.er blend con esquina + escalón inyectados -> 33/31/2, exit 1
#         (fallan C4 y C5; C11 sigue verde porque el pórtico no se tocó)
#   CIEGO 1 solo blend -> 11 checks / 1 bloque, exit 3
#
# Correcciones de diseño de la propia guardia (todas documentadas en sitio):
#   C6  exigía 4 vértices de dintel dentro de (-0.55,0.55), pero el dintel
#       tiene sus vértices en x=+-0.60 -> aserción IMPOSIBLE, rojo falso.
#   C5  medía la saliente sobre TODOS los vértices de apoyo; al sacar el
#       pórtico al exterior sus postes daban 0.56 m -> rojo falso. Ahora
#       mide sólo PIEDRA (escalón real 0.47 m).
#   C11 exigía 20 vértices de base (cifra de ALTA); el LOD de BAJA conserva
#       6 por diseño -> rojo falso. Ahora mide el EFECTO: apoyado + exterior
#       + postes erguidos (z>2.0).
import bpy  # noqa: E402
import os  # noqa: E402
import sys  # noqa: E402

MOD_DIR = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))
BASE = 'casa_mansion_lowpoly'
DEFAULT = [os.path.join(MOD_DIR, BASE + s + '.blend')
           for s in ('', '_media', '_baja')]

# MEDIDO EN VERDE el 2026-11-06: 3 blends x 10 checks = 30 checks / 0 fallos.
# Se corrió primero con el piso en 0 y recién entonces se fijó la cifra real.
# MEDIDO EN VERDE el 2026-11-06: 3 blends x 11 checks = 33 checks / 0 fallos.
# Se corrió primero con el piso en 0 y recién entonces se fijó la cifra real.
CHECKS_MINIMOS = 33

Z_APOYO = 0.045
ANCHO_X, FONDO_Y = 14.0, 10.0
Y_FRENTE = 4.90
Z_TECHO_EN_CHIM = 3.7431
MATS = {'MAT_Mansion_Piedra', 'MAT_Mansion_Madera',
        'MAT_Mansion_Acento', 'MAT_Mansion_Jade'}

# 5 ambientes + jardín interior (01-Requerimientos.md L62 / L205).
ZONAS = {
    'vestibulo':  lambda v: v.y > 1.85 and v.x < 2.35,
    'cocina':     lambda v: v.y > 1.85 and v.x > 2.45,
    'biblioteca': lambda v: -1.35 < v.y < 1.75 and v.x < -2.25,
    'dormitorio': lambda v: v.y < -1.45 and v.x < -2.25,
    'jardin':     lambda v: v.y < 1.75 and -2.15 < v.x < 2.15,
    'museo':      lambda v: v.y < 1.75 and v.x > 2.25,
}


def verts_mundo(o):
    return [o.matrix_world @ v.co for v in o.data.vertices]


def verificar(ruta):
    etiqueta = os.path.basename(ruta)
    bpy.ops.wm.open_mainfile(filepath=os.path.abspath(ruta))
    bpy.context.view_layer.update()
    obs = [o for o in bpy.context.scene.objects
           if o.type == 'MESH' and o.name.startswith('SM_')]
    ok = 0
    fallos = 0

    def check(num, cond, detalle):
        nonlocal ok, fallos
        if cond:
            ok += 1
            print('OK   %-42s C%-2d %s' % (etiqueta, num, detalle))
        else:
            fallos += 1
            print('FAIL %-42s C%-2d %s' % (etiqueta, num, detalle))

    check(1, len(obs) > 0, 'objetos SM_ = %d' % len(obs))
    if not obs:
        for n in range(2, 12):
            check(n, False, 'sin objetos: no se puede medir')
        return ok, fallos

    datos = []
    usados = set()
    for o in obs:
        mn = [m.name if m else '?' for m in o.data.materials]
        for f in o.data.polygons:
            if f.material_index < len(mn):
                usados.add(mn[f.material_index])
        for v in o.data.vertices:
            datos.append((o.matrix_world @ v.co, mn))
    vs = [d[0] for d in datos]
    zmin, zmax = min(v.z for v in vs), max(v.z for v in vs)

    check(2, abs(zmin - Z_APOYO) < 1e-4,
          'z_min=%.4f (Z_APOYO=%.4f)' % (zmin, Z_APOYO))
    check(3, zmax > 4.95,
          'z_max=%.4f (techo/cumbrera presentes, >4.95)' % zmax)

    # C4: huella EXACTA del CUERPO medida sobre el ZÓCALO, no sobre todos los
    # vértices: el techo vuela 0.17 m y el escalón sobresale 0.47 m. Además
    # exige las 4 ESQUINAS (la aserción positiva que detecta el decimate).
    zoc = [o for o in obs if o.name.startswith('SM_Mansion_Zocalo')]
    va = [v for o in zoc for v in verts_mundo(o)
          if abs(v.z - Z_APOYO) < 1e-4]
    if va:
        fx = max(v.x for v in va) - min(v.x for v in va)
        fy = max(v.y for v in va) - min(v.y for v in va)
        esquinas = sum(
            1 for ex in (-7.0, 7.0) for ey in (-5.0, 5.0)
            if any(abs(v.x - ex) < 0.02 and abs(v.y - ey) < 0.02 for v in va))
    else:
        fx = fy = -1.0
        esquinas = 0
    check(4, len(va) >= 8 and abs(fx - ANCHO_X) < 1e-4
          and abs(fy - FONDO_Y) < 1e-4 and esquinas == 4,
          'huella_zocalo=%.4fx%.4f esquinas=%d/4 (spec 14x10)'
          % (fx, fy, esquinas))

    # C5: el escalón de acceso es la ÚNICA pieza de PIEDRA que puede salir
    # del cuerpo. Se mide sobre PIEDRA, no sobre todos los vértices: desde que
    # el pórtico se sacó al exterior, sus postes también tocan Z_APOYO en
    # y=5.56. Medir sobre `todos` daría saliente 0.56 (falso roto) y además
    # permitiría que C5 pase aunque el escalón hubiera desaparecido.
    apoyo_piedra = [v for v, ms in datos
                    if 'MAT_Mansion_Piedra' in ms
                    and abs(v.z - Z_APOYO) < 1e-4]
    escalon = [v for v in apoyo_piedra if v.y > 5.02]
    saliente = ((max(v.y for v in apoyo_piedra) - FONDO_Y / 2)
                if apoyo_piedra else -1.0)
    check(5, len(escalon) >= 2 and 0.0 < saliente < 0.50,
          'escalon=%d verts saliente=%.4f m (0 < s < 0.50)'
          % (len(escalon), saliente))

    # C6: hueco REAL 1.20x2.10, no puerta pintada. Exige ADEMÁS el dintel
    # (así un muro directamente borrado no pasaría por "0 vértices").
    piedra = [w for w, ms in datos if 'MAT_Mansion_Piedra' in ms]
    vano = [v for v in piedra if abs(v.y - Y_FRENTE) < 0.12
            and -0.55 < v.x < 0.55 and 0.35 < v.z < 1.90]
    # Error de diseño propio corregido el 2026-11-06: el dintel es una caja de
    # 1.20 m cuyos vértices están en x=-0.60 / +0.60, NO dentro de (-0.55,
    # 0.55). Exigir 4 vértices en ese intervalo era una aserción IMPOSIBLE que
    # daba ROJO en los 3 blends canónicos. Se mide sobre |x| <= 0.70.
    dintel = [v for v in piedra if abs(v.y - Y_FRENTE) < 0.12
              and abs(v.x) <= 0.70 and v.z > 2.20]
    check(6, len(vano) == 0 and len(dintel) >= 4,
          'puerta: piedra_en_vano=%d dintel=%d verts'
          % (len(vano), len(dintel)))

    check(7, usados == MATS,
          'materiales por cara=%d %s' % (len(usados), sorted(usados)))

    zonas = {z: sum(1 for v, ms in datos
                    if pred(v) and 0.20 < v.z < 3.2
                    and any(m != 'MAT_Mansion_Piedra' for m in ms))
             for z, pred in ZONAS.items()}
    check(8, len(zonas) == 6 and all(n > 0 for n in zonas.values()),
          '6 ambientes con contenido=%s'
          % ','.join('%s:%d' % (k, zonas[k]) for k in sorted(zonas)))

    # C9: la chimenea asoma SOBRE el techo en su propio Y (unión positiva
    # contra el aire), no basta con que exista un vértice alto cualquiera.
    somb = [v for v, ms in datos if 'MAT_Mansion_Acento' in ms
            and abs(v.x - 4.30) < 0.30 and abs(v.y - 3.30) < 0.30
            and v.z > 4.0]
    z_somb = max((v.z for v in somb), default=-1.0)
    check(9, len(somb) >= 4 and z_somb > Z_TECHO_EN_CHIM + 0.30,
          'sombrerete=%d verts z=%.4f > techo %.4f + 0.30'
          % (len(somb), z_somb, Z_TECHO_EN_CHIM))

    jade = [v for v, ms in datos if 'MAT_Mansion_Jade' in ms]
    check(10, len(jade) >= 30,
          'vidrios/jardín Jade=%d verts (>=30)' % len(jade))

    # C11: pórtico EXTERIOR y APOYADO. Detecta los dos defectos que la
    # revisión visual encontró y que ningún presupuesto M166 ve: postes
    # enterrados dentro del muro frontal y postes flotando 6 cm.
    # Tercera corrección de diseño de la propia guardia: exigir 20 vértices
    # de apoyo era una cifra de ALTA. El LOD de BAJA conserva 6 por diseño
    # (decimate legitimo), así que un conteo fijo daba un FALSO ROJO. El
    # check mide el EFECTO: base apoyada + pórtico por DELANTE del muro +
    # postes ERGUIDOS (z>2.0), no un número que el LOD cambia por definición.
    apoyo = [v for v in vs if abs(v.z - Z_APOYO) < 1e-4]
    portico = [v for v in apoyo if v.y > 5.15 and 1.40 < abs(v.x) < 1.70]
    columnas = [v for v in vs if v.y > 5.15 and 1.40 < abs(v.x) < 1.70
                and v.z > 2.0]
    y_portico = min((v.y for v in portico), default=-1.0)
    z_portico = max((v.z for v in columnas), default=-1.0)
    check(11, len(portico) >= 4 and y_portico > Y_FRENTE + 0.30
          and z_portico > 2.0,
          'portico=%d verts apoyados y_min=%.4f z_postes=%.4f (muro %.2f)'
          % (len(portico), y_portico, z_portico, Y_FRENTE))
    return ok, fallos


def main():
    argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
    rutas = argv or DEFAULT
    for r in rutas:
        if not os.path.isfile(r):
            print('FALTA BLEND: %s' % r)
            sys.exit(2)
    total_ok = 0
    total_fallos = 0
    bloques = 0
    for r in rutas:
        a, b = verificar(r)
        total_ok += a
        total_fallos += b
        bloques += 1
    total_chequeos = total_ok + total_fallos
    print('CHECKS=%d PASADOS=%d FALLOS=%d MINIMO=%d BLOQUES=%d'
          % (total_chequeos, total_ok, total_fallos, CHECKS_MINIMOS, bloques))
    if total_chequeos < CHECKS_MINIMOS or bloques < len(DEFAULT):
        print('CIEGO: faltan bloques o checks respecto del verde medido')
        sys.exit(3)
    if total_fallos:
        print('ROJO: %d aserciones de geometría fallaron' % total_fallos)
        sys.exit(1)
    print('VERDE: mansión íntegra en %d blends' % bloques)
    sys.exit(0)


if __name__ == '__main__':
    main()
