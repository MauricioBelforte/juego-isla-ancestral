# -*- coding: utf-8 -*-
# Descubrimiento vuelta 42: estado_director, canal, git/Cron C, riel, pools, flota, watchdog, detector.
import io, os, json, glob, subprocess, hashlib, re

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
GAME = os.path.join(RAIZ, u"game", u"isla-ancestral")

def rd(p):
    try:
        return io.open(p, encoding=u"utf-8", errors=u"replace").read()
    except Exception as e:
        return u"ERR:" + str(e)

print(u"=== A. ESTADO_DIRECTOR (vs snapshot v41) ===")
snap41 = json.load(io.open(RAIZ + u"\\Temp\\kilo\\estado_director_v41.json", encoding=u"utf-8")) if os.path.exists(RAIZ + u"\\Temp\\kilo\\estado_director_v41.json") else {}
edp = RAIZ + u"\\Logs\\estado_director.json"
ed = json.loads(rd(edp))
print(u"claves:", len(ed), u"| mtime:", __import__("datetime").datetime.fromtimestamp(os.path.getmtime(edp)).strftime(u"%Y-%m-%d %H:%M:%S"))
k41, k42 = set(snap41.keys()), set(ed.keys())
print(u"nuevas claves vs v41:", sorted(k42 - k41) if k42 - k41 else u"NINGUNA")
print(u"quitadas vs v41:", sorted(k41 - k42) if k41 - k42 else u"NINGUNA")
cambios = []
for k in sorted(k41 & k42):
    if json.dumps(snap41[k], sort_keys=True) != json.dumps(ed.get(k), sort_keys=True):
        cambios.append(k)
print(u"claves CAMBIADAS vs v41:", cambios if cambios else u"NINGUNA")
for k in [u"ling_345-351_acusado", u"ling_342_acusado", u"ling_345_351", u"ling_352"]:
    if k in ed:
        print(u"  campo", k, u"=", json.dumps(ed[k], ensure_ascii=False)[:300])
for k in [u"ling", u"pt", u"go", u"bug_156_i18n_json", u"bug156", u"sello_14_m64", u"sellos_218"]:
    if k in ed:
        print(u"  campo", k, u"=", json.dumps(ed[k], ensure_ascii=False)[:200])

print(u"\n=== B. CANAL LING (ultimos 6 numerados + nuevos >353) ===")
canal = os.path.join(RAIZ, u"Mensajes entre modelos", u"Ling-3.1-Flash")
msgs = [f for f in glob.glob(canal + u"\\*.md")]
def num(f):
    m = re.match(r"(\d+)-", os.path.basename(f))
    return int(m.group(1)) if m else 0
msgs_n = sorted([(num(f), f) for f in msgs], key=lambda t: t[0])
for n, f in msgs_n[-6:]:
    print(u"  #%d %s | %dB" % (n, os.path.basename(f)[:90], len(rd(f))))
nuevos = [t for t in msgs_n if t[0] > 353]
print(u"mensajes >353 (agnes/otro respondio?):", [(n, os.path.basename(f)[:80]) for n, f in nuevos] if nuevos else u"NINGUNO (anti-loop sigue)")

print(u"\n=== C. GIT: HEAD, Cron C 00:17Z, preservacion v40/v41 ===")
def git(*args):
    r = subprocess.run([u"git"] + list(args), cwd=RAIZ, capture_output=True)
    return r.stdout.decode(u"utf-8", u"replace") + r.stderr.decode(u"utf-8", u"replace")
head = git(u"rev-parse", u"HEAD").strip()
print(u"HEAD:", head[:12], u"(v41 cerro con 6a8ab2f; muto:", head[:7] != u"6a8ab2f", u")")
print(u"log -3:", git(u"log", u"--oneline", u"-3").strip().replace(u"\n", u" || "))
try:
    h_aud = subprocess.run([u"git", u"show", u"HEAD:DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"], cwd=RAIZ, capture_output=True).stdout.decode(u"utf-8", u"replace")
    h_bk = subprocess.run([u"git", u"show", u"HEAD:DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md"], cwd=RAIZ, capture_output=True).stdout.decode(u"utf-8", u"replace")
    print(u"HEAD-AUDITORIA tiene ## 32. (v40 versionado):", u"## 32." in h_aud, u"| ## 33. (v41):", u"## 33." in h_aud)
    print(u"HEAD-backlog tiene VUELTA 40 CIERRE:", u"VUELTA 40 CIERRE" in h_bk, u"| VUELTA 41 CIERRE:", u"VUELTA 41 CIERRE" in h_bk)
    tree = subprocess.run([u"git", u"ls-tree", u"-r", u"--name-only", u"HEAD", u"Mensajes entre modelos/Ling-3.1-Flash/"], cwd=RAIZ, capture_output=True).stdout.decode(u"utf-8", u"replace")
    print(u"HEAD tiene msg 352:", bool([l for l in tree.split(u"\n") if l.startswith(u"352-")]), u"| msg 353:", bool([l for l in tree.split(u"\n") if l.startswith(u"353-")]))
except Exception as e:
    print(u"git show err:", e)
st = git(u"status", u"--porcelain").strip()
print(u"WT archivos:", len([l for l in st.split(u"\n") if l.strip()]) if st else 0)

print(u"\n=== D. CENTINELA RIEL ===")
for rel, exp in [(u"scripts/ling_i18n_manager.gd", u"047eab5ff111dffdc3f3b48f8241c787e104c0a5"),
                 (u"translation/pt.po", u"d2b567c48e88cfa6d9d22d76eaf31804e1e9028c")]:
    wt = rd(os.path.join(GAME, rel)).encode(u"utf-8")
    h = hashlib.sha1(b"blob " + str(len(wt)).encode() + b"\0" + wt).hexdigest()
    hhead = subprocess.run([u"git", u"rev-parse", u"HEAD:" + rel.replace(u"\\", u"/")], cwd=GAME, capture_output=True).stdout.decode().strip()
    print(u"  %s: WT=%s HEAD=%s INTACTO=%s" % (rel.split(u"/")[-1], h[:12], hhead[:12], h == hhead == exp))
pt = rd(os.path.join(GAME, u"translation", u"pt.po"))
print(u"  msgids pt.po:", len(re.findall(r'^msgid\s+"(?!")', pt, re.M)), u"| .mo count:", len(glob.glob(GAME + u"\\**\\*.mo", recursive=True)))

print(u"\n=== E. POOLS ===")
pc = [x for x in rd(os.path.join(canal, u"NUMEROS_DISPONIBLES.txt")).split(u"\n") if x.strip()]
pl = [x for x in rd(RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
print(u"canal cabeza:", pc[0], u"| Logs cabeza:", pl[0])

print(u"\n=== F. WATCHDOG + DETECTOR ===")
r = subprocess.run([u"python", u"-X", u"utf8", u"scripts/validar_i18n_integridad.py"], cwd=GAME, capture_output=True)
print(u"watchdog rc:", r.returncode)
det = subprocess.run([u"python", u"-X", u"utf8", u"scripts/verificar_claims_md_detector.py"], cwd=RAIZ, capture_output=True)
dt = det.stdout.decode(u"utf-8", u"replace")
print(u"detector rc:", det.returncode, u"| chars:", len(dt))
for k in [u"A1=", u"R4=", u"A2=", u"A3=", u"C2=", u"SOS=", u"FP=", u"F=", u"GRIS=", u"[x]="]:
    m = re.search(re.escape(k) + u"([0-9]+)", dt)
    print(u"   ", k, m.group(1) if m else u"?")

print(u"\n=== G. FLOTA (latidos) ===")
for carp in [u"agnes-3-flash", u"Hy3", u"DeepSeek-V4.1-Flash", u"atria-dawn-s2", u"Step-5-WorkBuddy", u"GLM-5.3-Flash"]:
    d = os.path.join(RAIZ, u"Mensajes entre modelos", carp)
    if os.path.isdir(d):
        fs = sorted(glob.glob(d + u"\\*.md"), key=os.path.getmtime)
        if fs:
            last = fs[-1]
            mt = __import__("datetime").datetime.fromtimestamp(os.path.getmtime(last)).strftime(u"%m-%d %H:%M")
            print(u"  %s: ultimo %s | mtime %s" % (carp, os.path.basename(last)[:70], mt))
logs = sorted(glob.glob(RAIZ + u"\\Logs\\[0-9][0-9][0-9][0-9]-*.md"))
print(u"Logs ultimos 5:")
for f in logs[-5:]:
    print(u"  ", os.path.basename(f)[:80])

print(u"\n=== H. SNAPSHOT v42 ===")
json.dump(ed, io.open(RAIZ + u"\\Temp\\kilo\\estado_director_v42.json", u"w", encoding=u"utf-8"), ensure_ascii=False, indent=1)
print(u"snapshot guardado")
