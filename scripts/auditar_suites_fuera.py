# Auditoria de suites INVISIBLES: suites de test que viven FUERA de res://tests/ y por lo tanto
# NO las ejecuta el runner central (game/isla-ancestral/tests/run_tests.gd solo descubre
# res://tests/). Este script corre esas suites y lista las que estan EN ROJO o con TIMEOUT
# (fallos invisibles: nadie los ve porque no corren en CI).
#
# Modelo: minimax-m3-1-flash | Plataforma: MiniMax API (Kilo Code) | Fecha: 2026-10-21
# Uso: python scripts/auditar_suites_fuera.py [--workers 6] [--timeout 45]
# Salida: scripts/../Logs/auditoria_suites_fuera.json + resumen por stdout.
#
# NO usa globs amplias para borrar nada: solo LEE y ejecuta. No toca el codigo de los modulos.
import io, os, json, subprocess, threading, queue, time, re, argparse

RAIZ = 'game/isla-ancestral'
GODOT = r'C:\\Temp\\godot\\Godot_v4.7.2-stable_win64_console.exe'
TMP = os.path.join(os.environ.get('TEMP', '.'), 'censo_suites')
OUT = 'Logs/auditoria_suites_fuera.json'
WORKERS = 6
TIMEOUT = 45

ap = argparse.ArgumentParser()
ap.add_argument('--workers', type=int, default=6)
ap.add_argument('--timeout', type=int, default=45)
ap.add_argument('--godot', default=GODOT)
args = ap.parse_args()
WORKERS = args.workers
TIMEOUT = args.timeout
GODOT = args.godot

def census():
    dentro, fuera = [], []
    for dp, dn, fn in os.walk(RAIZ):
        dn[:] = [d for d in dn if d not in ('.godot', 'addons', '.git', 'assets')]
        for f in fn:
            if not f.endswith('.gd'):
                continue
            low = f.lower()
            if low.startswith('test_') or low.endswith('_test.gd'):
                p = os.path.join(dp, f).replace('\\', '/')
                (dentro if p.startswith(RAIZ + '/tests/') else fuera).append(p)
    return dentro, fuera

dentro, fuera = census()
print('suites totales: %d | dentro de res://tests/: %d | FUERA: %d' % (len(dentro) + len(fuera), len(dentro), len(fuera)))
os.makedirs(TMP, exist_ok=True)
q = queue.Queue()
for p in fuera:
    q.put(p)
resultados = []
lock = threading.Lock()
hechos = [0]

def worker(wid):
    env = dict(os.environ)
    env['APPDATA'] = os.path.join(TMP, 'w%d' % wid)
    os.makedirs(env['APPDATA'], exist_ok=True)
    while True:
        try:
            p = q.get_nowait()
        except queue.Empty:
            return
        ruta = 'res://' + p.replace(RAIZ + '/', '')
        rc = -99
        txt = ''
        try:
            r = subprocess.run([GODOT, '--headless', '--path', RAIZ, '--script', ruta],
                               capture_output=True, text=True, encoding='utf-8', errors='replace',
                               timeout=TIMEOUT, env=env)
            rc = r.returncode
            txt = (r.stdout or '') + (r.stderr or '')
        except subprocess.TimeoutExpired:
            rc = -1
        resumen = piso = parse_err = ''
        for l in txt.split('\n'):
            t = l.strip()
            if 'Parse Error' in t or 'SCRIPT ERROR' in t:
                parse_err = t[:90]
            if re.search(r'RESUMEN|Resumen|RESULTADO', t) and not resumen:
                resumen = t[:110]
            if 'PISO NO CUMPLIDO' in t and not piso:
                piso = t[:70]
        with lock:
            hechos[0] += 1
            if hechos[0] % 50 == 0:
                print('   ... %d/%d' % (hechos[0], len(fuera)), flush=True)
            resultados.append({'ruta': ruta, 'rc': rc, 'resumen': resumen, 'piso': piso,
                               'parse': parse_err, 'err': 'timeout' if rc == -1 else ''})
        q.task_done()

hilos = [threading.Thread(target=worker, args=(i,), daemon=True) for i in range(WORKERS)]
t0 = time.time()
for h in hilos:
    h.start()
for h in hilos:
    h.join()
dt = time.time() - t0
verdes = [r for r in resultados if r['rc'] == 0]
rojas = [r for r in resultados if r['rc'] not in (0, -1)]
timeouts = [r for r in resultados if r['rc'] == -1]
print()
print('=== VERDES: %d | EN ROJO: %d | TIMEOUT: %d (%.1f s con %d workers) ===' % (len(verdes), len(rojas), len(timeouts), dt, WORKERS))
print('=== %d suites FUERA de res://tests/ | dentro: %d | TOTAL: %d ===' % (len(fuera), len(dentro), len(dentro) + len(fuera)))
for r in rojas:
    print('   ROJO rc=%-4s %s' % (r['rc'], r['ruta']))
    if r['resumen']:
        print('        %s' % r['resumen'][:108])
    if r['piso']:
        print('        %s' % r['piso'])
    if r['parse']:
        print('        %s' % r['parse'])
for r in timeouts:
    print('   TIMEOUT %s' % r['ruta'])
os.makedirs('Logs', exist_ok=True)
io.open(OUT, 'w', encoding='utf-8').write(json.dumps(resultados, ensure_ascii=False, indent=1))
print('detalle: %s' % OUT)
