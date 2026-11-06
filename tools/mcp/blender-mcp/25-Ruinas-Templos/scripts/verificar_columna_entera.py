# verificar_columna_entera.py — Guardia POSITIVA de geometría del capitel (M25)
#
# NO es QA §21.8 ni sello: es una guardia de AUTORÍA, para no creerle a un
# `chk_asset.py` verde. El 2026-11-06 la BAJA de `columna_entera` pasaba los
# tres presupuestos M166 (342/700 tris, 4/6 obj, 4/4 mats) con el ÁBACO
# COLAPSADO por el decimate: 0 caras laterales completas, vértices a 2.8267 y
# 2.8733, y aire visible bajo la losa en la hoja de capturas. El presupuesto
# mide COSTE, no FORMA. Esta guardia mide la FORMA.
#
# Uso (Blender headless, sin socket 9876):
#   blender -b --factory-startup --python verificar_columna_entera.py
#   blender -b --factory-startup --python verificar_columna_entera.py -- \
#       <blend1> <blend2> <blend3>
#
# Con 3 blends son 9 checks por blend = 27. `CHECKS_MINIMOS` está MEDIDO en
# verde, no estimado. Si un bloque no se ejecuta => CIEGO (exit 3), porque un
# verde con menos checks de los medidos es un falso verde.
#
# TRES CAMINOS MEDIDOS 2026-11-06 (no estimados):
#   VERDE 3 blends canónicos -> CHECKS=27 PASADOS=27 FALLOS=0 exit 0
#   ROJO  (3.er blend = BAJA defectuosa ratio 0.70 sin `_NOFUNDIR`) ->
#         CHECKS=27 PASADOS=25 FALLOS=2 exit 1; fallan C6 (0 caras en ábaco)
#         y C9 (4 vértices a 2.8267/2.8733). Detecta el efecto, no el literal.
#   CIEGO (1 solo blend) -> CHECKS=9 BLOQUES=1 exit 3.
# Un check que falla SIGUE contando como ejecutado: si se contara solo el
# verde, el rojo parecería ciego (25 < 27) y el guardián sería un falso verde.
#
# SEGUNDO HALLAZGO de la propia guardia: C4 inicialmente medía el bbox de
# TODOS los vértices y daba 1.0000x1.0140 (los glifos sobresalen 14 mm);
# corregida a HUELLA DE APOYO (vértices en Z_APOYO), con esa corrección C4
# detectó que el decimate también se comía 2 esquinas del plinto:
# 1.0000x0.8800 con 14 vértices. De ahí el `_NOFUNDIR` adicional en el plinto.
import bpy  # noqa: E402
import os  # noqa: E402
import sys  # noqa: E402

MOD_DIR = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))
BASE = 'columna_entera_lowpoly'
DEFAULT = [os.path.join(MOD_DIR, BASE + s + '.blend')
           for s in ('', '_media', '_baja')]

# MEDIDO EN VERDE 2026-11-06: 3 blends x 9 checks = 27 checks / 0 fallos.
# Se midió primero con el piso en 0 y recién entonces se fijó la cifra real.
CHECKS_MINIMOS = 27

Z_APOYO = 0.045
H = 3.00
Z_ABACO_0, Z_ABACO_1 = 2.78, 2.92
Z_REMATE_0, Z_REMATE_1 = 2.92, 3.00
MATS = {'MAT_ColEnt_Piedra', 'MAT_ColEnt_PiedraOsc',
        'MAT_ColEnt_Tallado', 'MAT_ColEnt_Musgo'}


def verts_mundo(o):
    return [o.matrix_world @ v.co for v in o.data.vertices]


def caras_losa(obs, z0, z1):
    """Caras LATERALES que unen EXACTAMENTE la base y el tope de una losa.

    Un decimate que colapsa una caja delgada deja triángulos con vértices a
    alturas intermedias: esos triángulos NO cuentan. Por eso la aserción es
    positiva (exige las 4 caras) y no un `not` sobre el literal del defecto.
    """
    n = 0
    for o in obs:
        m3 = o.matrix_world.to_3x3()
        for f in o.data.polygons:
            zs = [round((o.matrix_world @ o.data.vertices[i].co).z, 4)
                  for i in f.vertices]
            if min(zs) < z0 - 1e-3 or max(zs) > z1 + 1e-3:
                continue
            if abs(min(zs) - z0) > 1e-3 or abs(max(zs) - z1) > 1e-3:
                continue
            if any(abs(z - z0) > 1e-3 and abs(z - z1) > 1e-3 for z in zs):
                continue
            if abs((m3 @ f.normal).z) < 0.5:
                n += 1
    return n


def caras_equino(obs):
    n = 0
    for o in obs:
        m3 = o.matrix_world.to_3x3()
        for f in o.data.polygons:
            cz = sum((o.matrix_world @ o.data.vertices[i].co).z
                     for i in f.vertices) / len(f.vertices)
            if 2.55 < cz < 2.77 and abs((m3 @ f.normal).z) < 0.9:
                n += 1
    return n


def verificar(ruta):
    etiqueta = os.path.basename(ruta)
    bpy.ops.wm.open_mainfile(filepath=os.path.abspath(ruta))
    bpy.context.view_layer.update()
    obs = [o for o in bpy.context.scene.objects
           if o.type == 'MESH' and o.name.startswith('SM_')]
    vs = [v for o in obs for v in verts_mundo(o)]
    ok = 0
    fallos = 0

    def check(num, cond, detalle):
        nonlocal ok, fallos
        if cond:
            ok += 1
            print('OK   %-42s C%d %s' % (etiqueta, num, detalle))
        else:
            fallos += 1
            print('FAIL %-42s C%d %s' % (etiqueta, num, detalle))

    check(1, len(obs) > 0, 'objetos SM_ = %d' % len(obs))
    if not vs:
        for n in range(2, 10):
            check(n, False, 'sin vértices: no se puede medir')
        return ok, fallos

    zmin, zmax = min(v.z for v in vs), max(v.z for v in vs)
    # C4 mide la HUELLA DE APOYO (vértices en Z_APOYO), no el bbox de todos
    # los vértices: los 4 glifos sobresalen 14 mm de la cara frontal, así que
    # el bbox global da 1.0000 x 1.0140. `asentar()` mide exactamente esto.
    va = [v for v in vs if abs(v.z - Z_APOYO) < 1e-4]
    fx = (max(v.x for v in va) - min(v.x for v in va)) if va else -1.0
    fy = (max(v.y for v in va) - min(v.y for v in va)) if va else -1.0

    check(2, abs(zmin - Z_APOYO) < 1e-4, 'z_min=%.4f (Z_APOYO=%.4f)' % (zmin, Z_APOYO))
    check(3, abs(zmax - H) < 1e-4, 'z_max=%.4f (H=%.2f)' % (zmax, H))
    check(4, len(va) >= 8 and abs(fx - 1.0) < 1e-4 and abs(fy - 1.0) < 1e-4,
          'huella_apoyo=%.4fx%.4f con %d vértices (spec 1x1)' % (fx, fy, len(va)))

    usados = set()
    for o in obs:
        for f in o.data.polygons:
            if f.material_index < len(o.data.materials):
                m = o.data.materials[f.material_index]
                if m:
                    usados.add(m.name)
    check(5, usados == MATS, 'materiales por cara=%d %s' % (len(usados), sorted(usados)))

    n_abaco = caras_losa(obs, Z_ABACO_0, Z_ABACO_1)
    n_remate = caras_losa(obs, Z_REMATE_0, Z_REMATE_1)
    n_equino = caras_equino(obs)
    check(6, n_abaco >= 4, 'caras laterales completas ABACO=%d (>=4)' % n_abaco)
    check(7, n_remate >= 4, 'caras laterales completas REMATE=%d (>=4)' % n_remate)
    check(8, n_equino >= 16, 'caras laterales EQUINO=%d (>=16)' % n_equino)

    huerfanos = [round(v.z, 4) for v in vs if Z_ABACO_0 + 0.01 < v.z < Z_ABACO_1 - 0.01]
    check(9, len(huerfanos) == 0,
          'vértices a media losa=%d %s' % (len(huerfanos), sorted(set(huerfanos))[:4]))
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
    # Un check que FALLA sigue siendo un check EJECUTADO: si se contara solo
    # el verde, la inyección en rojo parecería "CIEGO" (25 < 27) en lugar de
    # ROJO. CIEGO significa bloque que NO corrió, no aserción que falló.
    total_chequeos = total_ok + total_fallos
    print('CHECKS=%d PASADOS=%d FALLOS=%d MINIMO=%d BLOQUES=%d'
          % (total_chequeos, total_ok, total_fallos, CHECKS_MINIMOS, bloques))
    if total_chequeos < CHECKS_MINIMOS or bloques < len(DEFAULT):
        print('CIEGO: faltan bloques o checks respecto del verde medido')
        sys.exit(3)
    if total_fallos:
        print('ROJO: %d aserciones de geometría fallaron' % total_fallos)
        sys.exit(1)
    print('VERDE: capitel íntegro en %d blends' % bloques)
    sys.exit(0)


if __name__ == '__main__':
    main()
