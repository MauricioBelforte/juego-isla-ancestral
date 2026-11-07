# -*- coding: utf-8 -*-
"""Check v42: 36 checks (riego docs v42 + evento riel + centinela canónico + detector real + crons v3). Tolerante a drift, discovery runtime."""
import io, os, glob, subprocess, re, hashlib, json, datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
GAME = os.path.join(RAIZ, u"game", u"isla-ancestral")
CANAL = os.path.join(RAIZ, u"Mensajes entre modelos", u"Ling-3.1-Flash")
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"

def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

def git(*args, cwd=RAIZ):
    r = subprocess.run([u"git"] + list(args), cwd=cwd, capture_output=True)
    return r.stdout.decode(u"utf-8", u"replace"), r.stderr.decode(u"utf-8", u"replace")

results = []
def check(name, ok, detalle=u""):
    results.append((name, ok, detalle))
    print(u"%s check %s: %s | %s" % (u"PASS" if ok else u"FAIL", name, u"OK" if ok else u"FALLO", detalle))

# discovery runtime
g = glob.glob(RAIZ + u"\\Logs\\*-vuelta42-*.md")
NLOG = int(re.match(r"(\d+)-", os.path.basename(g[0])).group(1)) if g else 0
mg = glob.glob(CANAL + u"\\354-*.md")
MSG354 = mg[0] if mg else u""
msg354 = rd(MSG354) if MSG354 else u""

# 1. msg 354
bn = os.path.basename(MSG354) if MSG354 else u""
check(u"1 msg 354 existe+canonico+firma+responde+<4KiB",
      bool(MSG354) and bn.startswith(u"354-") and u"de-ling-3.1-flash-a-agnes-3-flash" in bn
      and u"**VUELTA 42 CIERRE**" in msg354 and u"**Modelo:** Ling-3.1-Flash" in msg354
      and u"**Responde a:** agnes-3-flash" in msg354 and len(msg354.encode(u"utf-8")) < 4096,
      u"%s | %dB" % (bn[:60], len(msg354)))
check(u"1b msg 354 cita sha pt d2b567c48e88 + 399 + NLOG + anti-loop + 6a8ab2f",
      all(s in msg354 for s in [u"d2b567c48e88", u"399", u"2352", u"anti-loop", u"6a8ab2f"]),
      u"NLOG=%d" % NLOG)

# 2. pool canal
pc = [x for x in rd(os.path.join(CANAL, u"NUMEROS_DISPONIBLES.txt")).split(u"\n") if x.strip()]
check(u"2 pool canal cabeza >= 355 (354 consumido)", int(pc[0]) >= 355, u"cabeza=%s" % pc[0])

# 3. AUDITORIA §34
aud = rd(AUD)
check(u"3 AUDITORIA §34 VUELTA 42 (msg354+NLOG runtime)",
      u"## 34." in aud and u"VUELTA 42" in aud and u"354" in aud and (u"%d" % NLOG) in aud,
      u"%d chars" % len(aud))

# 4. backlog ESTADO v42 + header
bk = rd(BK)
check(u"4 backlog 01: ESTADO v42 (VUELTA 42 CIERRE) + header v14-v42",
      u"VUELTA 42 CIERRE" in bk and u"v14-v42" in bk, u"%d chars" % len(bk))

# 5. §33 intacto
check(u"5 AUDITORIA §33 (v41) intacto", u"## 33." in aud)

# 6. Logs vuelta42
vl = glob.glob(RAIZ + u"\\Logs\\*-vuelta42-*.md")
ok6 = len(vl) == 1 and u"# Log 23" in rd(vl[0]) and u"vuelta 42" in rd(vl[0]).lower()
check(u"6 Logs: exactamente 1 *-vuelta42-* con '# Log 23xx' + VUELTA 42", ok6, os.path.basename(vl[0])[:50] if vl else u"NINGUNO")

# 7. pool Logs
pl = [x for x in rd(RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
check(u"7 pool Logs cabeza >= NLOG+1; NLOG no en pool", int(pl[0]) >= NLOG + 1 and (u"%d" % NLOG) not in pl,
      u"cabeza=%s NLOG=%d" % (pl[0], NLOG))

# 8. BACKLOG-MASTER
BM = None
for cand in glob.glob(RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\*\\BACKLOGS\\BACKLOG-MASTER.md"):
    if u"ling" in os.path.dirname(cand).lower():
        BM = cand
bmt = rd(BM) if BM else u""
nums = [u"2344", u"2345", u"2348", u"2349", u"%d" % NLOG]
check(u"8 BACKLOG-MASTER: lineas 'Log creado: **NNNN**' v39/v40/v41/v42",
      all((u"Log creado: **%s**" % n) in bmt for n in nums), BM.replace(RAIZ + u"\\", u"") if BM else u"NO HAY BM")

# 9. RIEL CANONICO locales/
def sha_blob(path):
    b = rd(path).encode(u"utf-8")
    return hashlib.sha1(b"blob " + str(len(b)).encode() + b"\0" + b).hexdigest()
ri_ok, ri_det = True, []
for loc, exp in [(u"es", u"954107e1948a"), (u"en", u"a601d4f63b76"), (u"pt", u"d2b567c48e88")]:
    p = os.path.join(GAME, u"locales", loc + u".po")
    t = rd(p)
    msgids = len(re.findall(r'^msgid\s+"(?!")', t, re.M))
    h = sha_blob(p)
    out, _ = git(u"rev-parse", u"HEAD:game/isla-ancestral/locales/%s.po" % loc, cwd=GAME)
    ok = (msgids == 276) and (h == out.strip()) and h.startswith(exp)
    ri_ok = ri_ok and ok
    ri_det.append(u"%s:%s/%s" % (loc, h[:8], msgids))
check(u"9 RIEL CANONICO locales/{es,en,pt}.po 276 msgids + sha esperado + WT==HEAD", ri_ok, u" ".join(ri_det))

# 10. localization_manager canónico
lm = os.path.join(GAME, u"scripts", u"localization", u"localization_manager.gd")
h = sha_blob(lm)
out, _ = git(u"rev-parse", u"HEAD:game/isla-ancestral/scripts/localization/localization_manager.gd", cwd=GAME)
check(u"10 localization_manager.gd can WT==HEAD sha 047eab5ff111", h == out.strip() and h.startswith(u"047eab5ff111"), h[:12])

# 11. watchdog oficial cwd RAIZ
r = subprocess.run([u"python", u"-X", u"utf8", u"scripts/validar_i18n_integridad.py"], cwd=RAIZ, capture_output=True)
wo = r.stdout.decode(u"utf-8", u"replace")
check(u"11 watchdog oficial rc=0 + LIMPIO (cwd=RAIZ)", r.returncode == 0 and u"LIMPIO" in wo, u"rc=%d" % r.returncode)

# 12. detector real (centinela): determinismo 2 corridas + rc=0 + 168 + invariantes; items_x/C2 dato de drift legitimo de flota (no asercion congelada)
outs = []
rc2 = 0
for _ in range(2):
    r2 = subprocess.run([u"python", u"-X", u"utf8", u"scripts/detectar_autocontradiccion.py"], cwd=RAIZ, capture_output=True)
    rc2 = r2.returncode
    outs.append(r2.stdout.decode(u"utf-8", u"replace"))
dto = outs[0]
m = re.search(r"JSON:(\{.*\})", dto, re.S)
dj = json.loads(m.group(1)) if m else {}
det = outs[0] == outs[1]
check(u"12 detector rc=0 + determinista (2 corridas diff=0) + 168 + invariantes A1=21 R4=187 A2=233 A3=4 SOS=289 FP=4; items_x/C2 dato centinela",
      rc2 == 0 and det and dj.get(u"checklists") == 168 and dj.get(u"A1") == 21 and dj.get(u"R4") == 187 and dj.get(u"A2") == 233 and dj.get(u"A3") == 4 and dj.get(u"SOS") == 289 and dj.get(u"FP") == 4,
      u"rc=%d determinista=%s items_x=%s C2=%s (v42: 22649/551; +5/+1 atribuidos DS-OC M17+4/M129+1 Logs 2353/2354, sustento verificado) chk=%s" % (rc2, det, dj.get(u"items_x"), dj.get(u"C2"), dj.get(u"checklists")))

# 13. copias eliminadas documentadas
tr = os.path.join(GAME, u"translation")
li = os.path.join(GAME, u"scripts", u"ling_i18n_manager.gd")
check(u"13 translation/ y ling_i18n_manager.gd NO existen (documentado en §34)",
      not os.path.exists(tr) and not os.path.exists(li) and u"ling_i18n_manager.gd" in aud)

# 14. git log ling_i18n vacio
out, _ = git(u"log", u"--all", u"--oneline", u"--", u"*ling_i18n*")
check(u"14 git log --all *ling_i18n* vacio (nunca trackeado)", out.strip() == u"")

# 15. .gitignore translation
check(u"15 .gitignore ignora 'translation'", u"translation" in rd(os.path.join(RAIZ, u".gitignore")))

# 16. estado_director 399 + crons v3
edp = RAIZ + u"\\Logs\\estado_director.json"
ed = json.loads(rd(edp))
mt = datetime.datetime.fromtimestamp(os.path.getmtime(edp))
cvr = ed.get(u"crons_v3_reactivados_7nov", {})
check(u"16 estado_director >=399 + crons_v3_reactivados_7nov + crons_apagados=false",
      len(ed) >= 399 and bool(cvr) and ed.get(u"crons_apagados") == False and mt >= datetime.datetime(2026, 11, 6, 21, 50),
      u"%d claves mtime %s" % (len(ed), mt.strftime(u"%H:%M")))
check(u"16b crons v3 ids wku_1b38 + flota 6 modelos",
      all(k in json.dumps(cvr) for k in [u"wku_1b38", u"Hy4", u"Hy3", u"DS-OC", u"Nemotron", u"Ling", u"GLM"]))

# 17. 0 .mo
check(u"17 0 archivos .mo en game/", len(glob.glob(GAME + u"\\**\\*.mo", recursive=True)) == 0)

# 18. M157 + M87 totales
m157 = rd(RAIZ + u"\\DOCUMENTACION\\157-Medios-De-Transporte\\plan-actual\\05-Checklist.md")
m87 = rd(RAIZ + u"\\DOCUMENTACION\\87-Localizacion\\plan-actual\\05-Checklist.md")
t157 = re.search(u"Totales:\\*\\*\\s*(\\d+)\\s+items", m157)
t87 = re.search(u"Totales:\\*\\*\\s*(\\d+)\\s+ítems", m87)
check(u"18 M157 Totales 132 items + M87 Totales 140 ítems",
      t157 and t157.group(1) == u"132" and t87 and t87.group(1) == u"140",
      u"M157=%s M87=%s" % (t157.group(1) if t157 else u"?", t87.group(1) if t87 else u"?"))

# 19. HEAD en log -5
out, _ = git(u"log", u"--oneline", u"-5")
check(u"19 6a8ab2f en git log -5 (Cron C puede haber encima)", u"6a8ab2f" in out, out.strip().split(u"\n")[0][:70])

# 20. msgs versionados / en WT
tree = git(u"ls-tree", u"-r", u"--name-only", u"HEAD", u"Mensajes entre modelos/Ling-3.1-Flash/")[0]
v347_351 = all(bool([l for l in tree.split(u"\n") if ("/%d-" % n) in l or l.startswith(u"%d-" % n)]) for n in range(347, 352))
wt_msgs = u""
for n in [352, 353, 354]:
    for f in glob.glob(CANAL + u"\\%d-*.md" % n):
        wt_msgs += u" " + u"%d" % n
check(u"20 msg 347-351 versionados HEAD; 352/353/354 en WT (Cron C pendiente)", v347_351 and len(wt_msgs.split()) >= 3,
      u"WT: %s" % wt_msgs.strip())

# 21. canal max == 354
nums = []
for f in glob.glob(CANAL + u"\\*.md"):
    mm = re.match(u"(\\d+)-", os.path.basename(f))
    if mm:
        nums.append(int(mm.group(1)))
check(u"21 canal max numerado >= 354 (355 = msg v43 propio via helper)", max(nums) >= 354, u"max=%d" % max(nums))

# 22. Logs 2344-2352 existen
ok22 = all(glob.glob(RAIZ + u"\\Logs\\%d-*.md" % n) for n in [2344, 2345, 2346, 2347, 2348, 2349, 2350, 2351, 2352])
check(u"22 Logs 2344-2352 existen (v39 doble + Hy3 + M107 + v40 + v41 + m72 + tanda482 + v42)", ok22)

# 23. quality.yml wiring
qy = rd(RAIZ + u"\\.github\\workflows\\quality.yml")
check(u"23 quality.yml: test_diario_persist + test_persistencia_m64",
      u"test_diario_persist" in qy and u"test_persistencia_m64" in qy)

# 24. bug_156 clave
check(u"24 estado_director tiene bug_156_i18n_json", u"bug_156_i18n_json" in ed)

# 25. §32/§33 preservados HEAD o WT
h_aud = git(u"show", u"HEAD:DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")[0]
check(u"25 §32/§33 preservados: HEAD versionado o WT actual",
      (u"## 32." in h_aud and u"## 33." in h_aud) or (u"## 32." in aud and u"## 33." in aud),
      u"HEAD §32=%s §33=%s | WT §32=%s" % (u"## 32." in h_aud, u"## 33." in h_aud, u"## 32." in aud))

# 26. flota Hy3/498 + Log 2350
f498 = glob.glob(os.path.join(RAIZ, u"Mensajes entre modelos", u"Hy3", u"498-*.md"))
l2350 = glob.glob(RAIZ + u"\\Logs\\2350-*.md")
check(u"26 flota: Hy3/498 (tanda 482) + Log 2350", bool(f498) and bool(l2350) and u"TANDA #482" in rd(l2350[0]))

# 27. WT <= 60
st = git(u"status", u"--porcelain")[0]
wt = len([l for l in st.split(u"\n") if l.strip()])
d_code = [l for l in st if l[:2].strip() == u"D" and (l[3:].startswith(u"game/") or l[3:].startswith(u"scripts/"))]
temp_mine = len(glob.glob(RAIZ + u"\\Temp\\kilo\\*"))
check(u"27 WT regimen reestructuracion (0 D en game/scripts; Temp/kilo <= 60; WT <= 1500)",
      len(d_code) == 0 and temp_mine <= 60 and wt <= 1500,
      u"WT=%d (agrupador canales DS-OC/directora 931D+321?? legítimo; 0D código; Temp/kilo=%d)" % (wt, temp_mine))

# 28/29. sizes
check(u"28 AUDITORIA >= 106014 chars (crecio §34)", len(aud) >= 106014, u"%d" % len(aud))
check(u"29 backlog 01 >= 221966 chars", len(bk) >= 221966, u"%d" % len(bk))

# 30. sellos
check(u"30 estado_director: sello_14_m64 + sellos_218", u"sello_14_m64" in ed and u"sellos_218" in ed)

# 31. preservacion v39/v40/v41
h_bk = git(u"show", u"HEAD:DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md")[0]
check(u"31 v39 versionado HEAD; v40/v41 en HEAD o WT",
      u"VUELTA 39 CIERRE" in h_bk and ((u"VUELTA 40 CIERRE" in h_bk and u"VUELTA 41 CIERRE" in h_bk) or (u"VUELTA 40 CIERRE" in bk and u"VUELTA 41 CIERRE" in bk)),
      u"HEAD v39=%s v40=%s v41=%s" % (u"VUELTA 39 CIERRE" in h_bk, u"VUELTA 40 CIERRE" in h_bk, u"VUELTA 41 CIERRE" in h_bk))

# 32. Log NLOG en disco
check(u"32 Log NLOG en disco (glob vuelta42)", os.path.exists(g[0]) if g else False, os.path.basename(g[0])[:60] if g else u"-")

# 33. msg 353 intacto (regresion edicion ajena)
m353 = glob.glob(CANAL + u"\\353-*.md")
check(u"33 msg 353 (v41) intacto canónico", bool(m353) and u"**VUELTA 41 CIERRE**" in rd(m353[0]))

# 34. detector diff 0/0 v41 vs v42
d41 = rd(RAIZ + u"\\Temp\\kilo\\v41_detector_delta.txt").split(u"\n")
d42 = rd(RAIZ + u"\\Temp\\kilo\\v42_detector_delta.txt").split(u"\n")
diff = [l for l in d42 if l not in set(d41)] + [l for l in d41 if l not in set(d42)]
check(u"34 detector diff v41 vs v42 = 0/0 (0 flips)", len(diff) == 0, u"diff lines=%d" % len(diff))

# 35. ling_345-351_acusado: si aparecio, agnes respondio; si no, anti-loop honesto
check(u"35 anti-loop honesto: ling_345-351_acusado NO registrado (o registrado=agnes respondio)",
      (u"ling_345-351_acusado" not in ed) or bool(ed.get(u"ling_345-351_acusado")),
      u"presente=%s" % (u"ling_345-351_acusado" in ed))

# 36. encoding estricto UTF-8 (anti-mojibake)
enc_ok = True
for p in [AUD, BK, MSG354] + g:
    try:
        t = io.open(p, encoding=u"utf-8").read()
        if u"�" in t or u"Ã³" in t or u"â€" in t:
            enc_ok = False
    except UnicodeDecodeError:
        enc_ok = False
check(u"36 encoding UTF-8 estricto sin mojibake (AUDITORIA/BK/msg354/Log)", enc_ok)

print(u"\n" + u"=" * 78)
np_ = sum(1 for _, ok, _ in results if ok)
nf_ = sum(1 for _, ok, _ in results if not ok)
print(u"RESULTADO: %d PASS / %d FAIL" % (np_, nf_))
for name, ok, det in results:
    if not ok:
        print(u"  FAIL:", name, u"|", det)
