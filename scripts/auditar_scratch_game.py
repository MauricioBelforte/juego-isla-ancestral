# -*- coding: utf-8 -*-
"""
Guardia B5 (HY4, 2026-11-04): congela el inventario de .py dentro de game/.

Problema que cierra: el Log 1190 midio 42 scripts .py en el arbol de Godot;
al reingresar el 4-nov habia 65. Godot ignora los .py, pero cada vuelta de la
flota deja scratch nuevo ahi. B5 relocalizo 22 (sin borrar) y esta guardia
congela los 43 restantes: cualquier .py NUEVO bajo game/ falla el check.

Segunda cosa que guarda: el Log 1190 declaro 2 "huerfanos reales" buscando
solo salidas .blend. Falso positivo doble:
  - crear_hierba_alta_lowpoly.py vive en 50-Vegetacion/scripts/ y tiene
    3 .blend + GLB + ficha.
  - crear_jugador_voxel.py exporta GLB DIRECTO (sin .blend) y su GLB esta
    versionado.
Las aserciones de salida son POSITIVAS (el artefacto existe), no solo
negativas, para que el falsable no se cuele por variacion de literal.

Uso:
    python scripts/auditar_scratch_game.py --check
    python scripts/auditar_scratch_game.py --self-test

Exit: 0 = verde, 1 = fallo, 3 = CIEGO (no se midio nada / bloque no llamado).
"""
import os
import shutil
import subprocess
import sys
import tempfile

PREFIJO = 'game/isla-ancestral/'

# Inventario MEDIDO en verde tras la relocalizacion B5 (43 archivos).
# Solo se amplia con una decision explicita del dueno del modulo.
BASELINE = """
scripts/abeja_rerender.py
scripts/abeja_v1.py
scripts/community/discord_setup.py
scripts/community/report_analyzer.py
scripts/community/steam_announcement.py
scripts/conejo_exportar.py
scripts/conejo_guardar.py
scripts/conejo_v1.py
scripts/conejo_v10.py
scripts/conejo_v11.py
scripts/conejo_v7.py
scripts/conejo_v8.py
scripts/conejo_v9.py
scripts/crear_conejo_lowpoly.py
scripts/debug_normales.py
scripts/erizo_rana_v1.py
scripts/fix_stats.py
scripts/fix_stats_v2.py
scripts/gen_m162_amistad.py
scripts/gen_m162_amistad_all.py
scripts/gen_m162_dialogues.py
scripts/gen_m162_estaciones.py
scripts/gen_m162_noche.py
scripts/gen_m162_noche_all.py
scripts/lechuza_v1.py
scripts/nutria_v1.py
scripts/pez_v1.py
scripts/reescalar_fauna_v1.py
scripts/reescalar_v3_feedback.py
scripts/reescalar_v4_feedback.py
scripts/reescalar_v5.py
scripts/reescalar_v6_flor.py
scripts/reescalar_v7_flor.py
scripts/reescalar_vegetacion.py
scripts/reescalar_vegetacion_v2.py
scripts/render_cerca_conejo.py
scripts/render_nutria_ciclos.py
scripts/render_orbital.py
scripts/render_orbital_conejo.py
scripts/shops/scripts-prueba/diag_m39_facts.py
scripts/test_minimo.py
tools/font_subsetter.py
tools/validate_dialogues.py
""".split()

# Evidencia POSITIVA de los dos ex-huerfanos del Log 1190.
SALIDAS = (
    ('script_hierba', 'tools/mcp/blender-mcp/50-Vegetacion/scripts/crear_hierba_alta_lowpoly.py'),
    ('blend_hierba', 'tools/mcp/blender-mcp/50-Vegetacion/hierba_alta_lowpoly.blend'),
    ('glb_hierba', 'game/isla-ancestral/assets/3d/media/50-Vegetacion_hierba_alta.glb'),
    ('ficha_hierba', 'game/isla-ancestral/assets/fichas/50-Vegetacion_hierba_alta.md'),
    ('script_jugador', 'tools/mcp/blender-mcp/scripts-reutilizables/crear_jugador_voxel.py'),
    ('glb_jugador', 'game/isla-ancestral/assets/3d/media/45-Arte3D_jugador_voxel.glb'),
)

CHECKS_MINIMOS = 13  # MEDIDO en verde: 13 checks / 0 fallos (2026-11-04)


def rutas_base():
    return set(PREFIJO + x for x in BASELINE)


def escanear(raiz):
    """Devuelve las rutas .py bajo game/ relativas a raiz (separador /)."""
    out = set()
    g = os.path.join(raiz, 'game')
    if not os.path.isdir(g):
        return out
    for root, dirs, files in os.walk(g):
        dirs[:] = [d for d in dirs if d not in ('.godot', '__pycache__', '.import')]
        for f in files:
            if f.endswith('.py'):
                p = os.path.relpath(os.path.join(root, f), raiz).replace(os.sep, '/')
                out.add(p)
    return out


def detectar(raiz, baseline=None):
    """(nuevos, faltantes, total). faltantes es informativo, no bloqueante."""
    base = rutas_base() if baseline is None else set(baseline)
    vistos = escanear(raiz)
    return sorted(vistos - base), sorted(base - vistos), len(vistos)


def verificar_salidas(raiz):
    """Aserciones POSITIVAS: los ex-huerfanos SI produjeron artefacto."""
    res = []
    for etiqueta, ruta in SALIDAS:
        res.append((etiqueta, os.path.isfile(os.path.join(raiz, ruta))))
    p = os.path.join(raiz, SALIDAS[4][1])
    try:
        s = open(p, 'rb').read().decode('utf-8', 'replace')
    except OSError:
        s = ''
    res.append(('jugador_exporta_GLB', 'export_format="GLB"' in s))
    res.append(('jugador_declara_ruta', 'RUTA_SALIDA' in s))
    return res


def check(raiz):
    nuevos, faltantes, total = detectar(raiz)
    salidas = verificar_salidas(raiz)
    if total == 0:
        print('[CIEGO] No se midio ningun .py bajo game/.')
        return 3
    print('[B5] .py bajo game/: %d | baseline: %d | nuevos: %d | faltantes: %d'
          % (total, len(rutas_base()), len(nuevos), len(faltantes)))
    for p in nuevos:
        print('  [NUEVO] %s' % p)
    for etiqueta, ok in salidas:
        if not ok:
            print('  [SALIDA AUSENTE] %s' % etiqueta)
    malos = len(nuevos) + sum(1 for _, ok in salidas if not ok)
    if malos:
        print('[B5] ROJO: %d problema(s).' % malos)
        return 1
    print('[B5] VERDE: sin scratch nuevo y con las 8 evidencias de salida.')
    return 0


def escribir(raiz, ruta, texto):
    p = os.path.join(raiz, ruta)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, 'w', encoding='utf-8', newline='\n') as f:
        f.write(texto)


def repo_temporal(codigo, con_salidas=True):
    d = tempfile.mkdtemp(prefix='b5_selftest_')
    os.makedirs(os.path.join(d, 'scripts'))
    escribir(d, 'scripts/auditar_scratch_game.py', codigo)
    escribir(d, PREFIJO + 'tools/validate_dialogues.py', '# vivo\n')
    if con_salidas:
        for _, ruta in SALIDAS:
            escribir(d, ruta, '# fixture\n')
        escribir(d, SALIDAS[4][1],
                'RUTA_SALIDA = "x.glb"\nexport_format="GLB"\n')
    return d


def correr(d, *args):
    p = subprocess.run([sys.executable, 'scripts/auditar_scratch_game.py'] + list(args),
                       cwd=d, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return p.returncode, p.stdout.decode('utf-8', 'replace')


def self_test():
    """End-to-end por ruta real. Devuelve 0 verde / 1 rojo / 3 ciego."""
    codigo = open(os.path.join(os.getcwd(), 'scripts',
                               'auditar_scratch_game.py'), 'rb').read().decode('utf-8')
    checks = []
    fallos = [0]
    hecho = {}

    def ok(etiqueta, condicion, detalle=''):
        checks.append(etiqueta)
        if not condicion:
            fallos[0] += 1
            print('  [FAIL] %s %s' % (etiqueta, detalle))

    # S1: repositorio verde (solo baseline + evidencias presentes).
    d = repo_temporal(codigo)
    rc, out = correr(d, '--check')
    ok('S1_verde_exit0', rc == 0, 'rc=%d' % rc)
    ok('S1_verde_mide_1', '.py bajo game/: 1' in out, out[:120])
    hecho['S1'] = True

    # S2: inyeccion de scratch nuevo -> ROJO y nombra el archivo.
    escribir(d, PREFIJO + 'scripts/_scratch_nuevo.py', '# nuevo\n')
    rc, out = correr(d, '--check')
    ok('S2_rojo_exit1', rc == 1, 'rc=%d' % rc)
    ok('S2_rojo_nombra', '_scratch_nuevo.py' in out, out[:160])
    hecho['S2'] = True

    # S3: arbol sin .py -> CIEGO, no verde heredado.
    shutil.rmtree(os.path.join(d, 'game'))
    rc, out = correr(d, '--check')
    ok('S3_ciego_exit3', rc == 3, 'rc=%d' % rc)
    ok('S3_ciego_dice', '[CIEGO]' in out, out[:120])
    hecho['S3'] = True
    shutil.rmtree(d, ignore_errors=True)

    # S4: funcion pura, match conocido y no-match conocido (trampa 61).
    d = repo_temporal(codigo)
    escribir(d, PREFIJO + 'scripts/_inyectado.py', '# x\n')
    nuevos, faltantes, total = detectar(d)
    ok('S4_total_2', total == 2, 'total=%d' % total)
    ok('S4_detecta_match', nuevos == [PREFIJO + 'scripts/_inyectado.py'], str(nuevos))
    ok('S4_no_detecta_baseline',
       PREFIJO + 'tools/validate_dialogues.py' not in nuevos)
    ok('S4_faltantes_medidos', len(faltantes) == len(BASELINE) - 1,
       'faltantes=%d' % len(faltantes))
    shutil.rmtree(d, ignore_errors=True)
    hecho['S4'] = True

    # S5: evidencias positivas de los ex-huerfanos.
    d = repo_temporal(codigo)
    sal = verificar_salidas(d)
    ok('S5_8_evidencias', len(sal) == 8, 'n=%d' % len(sal))
    ok('S5_todas_verdes', all(v for _, v in sal), str(sal))
    # S6: control negativo: si falta un GLB, la asercion DEBE caer.
    os.remove(os.path.join(d, SALIDAS[5][1]))
    sal2 = verificar_salidas(d)
    ok('S6_control_negativo',
       dict(sal2)['glb_jugador'] is False and any(v for _, v in sal2))
    shutil.rmtree(d, ignore_errors=True)
    hecho['S5'] = True
    hecho['S6'] = True

    # Guardia de alcanzabilidad: si un bloque no se llamo, CIEGO (exit 3).
    if len(hecho) != 6 or len(checks) < CHECKS_MINIMOS:
        print('[CIEGO] bloques=%d checks=%d piso=%d'
              % (len(hecho), len(checks), CHECKS_MINIMOS))
        return 3
    print('[B5-SELFTEST] %d checks / %d fallos | bloques: %s'
          % (len(checks), fallos[0], ','.join(sorted(hecho))))
    return 1 if fallos[0] else 0


def main():
    if '--self-test' in sys.argv[1:]:
        return self_test()
    if '--check' in sys.argv[1:]:
        return check(os.getcwd())
    print(__doc__)
    return 0


if __name__ == '__main__':
    sys.exit(main())
