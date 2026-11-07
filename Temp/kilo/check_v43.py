# -*- coding: utf-8 -*-
"""Check v43: escrituras v43 reales + centinela flips atribuidos + estado nuevo + riel intacto."""
import io, os, glob, subprocess, re, hashlib, json

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
GAME = os.path.join(RAIZ, u"game", u"isla-ancestral")
CANAL = os.path.join(RAIZ, u"Mensajes entre modelos", u"Ling-3.1-Flash")
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"
BM = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\BACKLOG-MASTER.md"

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
mg = glob.glob(CANAL + u"\\355-*.md")
MSG355 = mg[0] if mg else u""
msg355 = rd(MSG355) if MSG355 else u""
vl = glob.glob(RAIZ + u"\\Logs\\*-vuelta43-*.md")
NLOG = int(re.match(r"(\d+)-", os.path.basename(vl[0])).group(1)) if vl else 0

# 1. msg 355
bn = os.path.basename(MSG355) if MSG355 else u""
check(u"1 msg 355 existe+canonico+firma+<4KiB",
      bool(MSG355) and bn.startswith(u"355-") and u"de-ling-3.1-flash-a-agnes-3-flash" in bn
      and u"**VUELTA 43 CIERRE**" in msg355 and u"**Modelo:** Ling-3.1-Flash" in msg355
      and len(msg355.encode(u"utf-8")) < 4096,
      u"%s | %dB" % (bn[:55], len(msg355)))
check(u"1b msg 355 cita Log 2355 + 38 checks + centinela + anti-loop + 6a8ab2f + d2b567c48e88",
      all(s in msg355 for s in [u"Log 2355", u"38 PASS", u"centinela", u"anti-loop", u"6a8ab2f", u"d2b567c48e88", u"22654"]),
      u"NLOG=%d" % NLOG)

# 2. pool canal
pc = [x for x in rd(os.path.join(CANAL, u"NUMEROS_DISPONIBLES.txt")).split(u"\n") if x.strip()]
check(u"2 pool canal cabeza >= 356 (355 consumido helper)", int(pc[0]) >= 356, u"cabeza=%s" % pc[0])

# 3. AUDITORIA §35 + addendum + 38 checks
aud = rd(AUD)
check(u"3 AUDITORIA §35 VUELTA 43 + addendum v42 + '38 checks' + §34 intacto",
      u"## 35." in aud and u"Addendum v42" in aud and u"38 checks" in aud and u"## 34." in aud,
      u"%d chars" % len(aud))

# 4. backlog ESTADO v43 + addendum v42 + header
bk = rd(BK)
check(u"4 backlog 01: ESTADO v43 + ADDENDUM v42 + header v14-v43",
      u"VUELTA 43 CIERRE" in bk and u"ADDENDUM v42" in bk and u"v14-v43" in bk,
      u"%d chars" % len(bk))

# 5. Log 2355
check(u"5 Logs: exactamente 1 *-vuelta43-* con '# Log 2355' + cita msg 355 + M17/M129",
      len(vl) == 1 and u"# Log 2355" in rd(vl[0]) and u"355" in rd(vl[0]) and u"M17" in rd(vl[0]) and u"M129" in rd(vl[0]),
      os.path.basename(vl[0])[:55] if vl else u"NINGUNO")

# 6. pool Logs
pl = [x for x in rd(RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
check(u"6 pool Logs cabeza >= 2356; 2355 no en pool", int(pl[0]) >= 2356 and u"2355" not in pl,
      u"cabeza=%s" % pl[0])

# 7. BACKLOG-MASTER linea 2355
bmt = rd(BM)
check(u"7 BACKLOG-MASTER linea 'Log creado: **2355**'", u"Log creado: **2355**" in bmt, u"%d chars" % len(bmt))

# 8. riel canónico
def sha_blob(path):
    b = rd(path).encode(u"utf-8")
    return hashlib.sha1(b"blob " + str(len(b)).encode() + b"\0" + b).hexdigest()
ri_ok = True
for loc, exp in [(u"es", u"954107e1948a"), (u"en", u"a601d4f63b76"), (u"pt", u"d2b567c48e88")]:
    p = os.path.join(GAME, u"locales", loc + u".po")
    t = rd(p)
    h = sha_blob(p)
    out, _ = git(u"rev-parse", u"HEAD:game/isla-ancestral/locales/%s.po" % loc, cwd=GAME)
    ri_ok = ri_ok and (len(re.findall(r'^msgid\s+"(?!")', t, re.M)) == 276) and (h == out.strip()) and h.startswith(exp)
check(u"8 RIEL CANONICO locales 276 msgids + sha + WT==HEAD", ri_ok, u"re-verificado v43")

# 9. manager canónico
lm = os.path.join(GAME, u"scripts", u"localization", u"localization_manager.gd")
h = sha_blob(lm)
out, _ = git(u"rev-parse", u"HEAD:game/isla-ancestral/scripts/localization/localization_manager.gd", cwd=GAME)
check(u"9 localization_manager.gd can WT==HEAD 047eab5ff111", h == out.strip() and h.startswith(u"047eab5ff111"), h[:12])

# 10. watchdog
r = subprocess.run([u"python", u"-X", u"utf8", u"scripts/validar_i18n_integridad.py"], cwd=RAIZ, capture_output=True)
wo = r.stdout.decode(u"utf-8", u"replace")
check(u"10 watchdog oficial rc=0 + LIMPIO (cwd=RAIZ)", r.returncode == 0 and u"LIMPIO" in wo, u"rc=%d" % r.returncode)

# 11. detector determinista + conteos
outs = []
rc2 = 0
for _ in range(2):
    r2 = subprocess.run([u"python", u"-X", u"utf8", u"scripts/detectar_autocontradiccion.py"], cwd=RAIZ, capture_output=True)
    rc2 = r2.returncode
    outs.append(r2.stdout.decode(u"utf-8", u"replace"))
m = re.search(r"JSON:(\{.*\})", outs[0], re.S)
dj = json.loads(m.group(1)) if m else {}
check(u"11 detector determinista + 168 + invariantes + items_x>=22654 C2>=552",
      rc2 == 0 and outs[0] == outs[1] and dj.get(u"checklists") == 168 and dj.get(u"A1") == 21 and dj.get(u"R4") == 187
      and dj.get(u"items_x", 0) >= 22654 and dj.get(u"C2", 0) >= 552,
      u"items_x=%s C2=%s chk=%s" % (dj.get(u"items_x"), dj.get(u"C2"), dj.get(u"checklists")))

# 12. M17 flips sustentados
m17 = rd(RAIZ + u"\\DOCUMENTACION\\17-Construccion\\plan-actual\\05-Checklist.md")
x17 = len(re.findall(r"^- \[x\]", m17, re.M)); e17 = len(re.findall(r"^- \[ \]", m17, re.M)); q17 = len(re.findall(r"^- \[\?\]", m17, re.M))
t17 = re.search(u"Totales:\\*\\*\\s*(\\d+)\\s+ítems", m17)
check(u"12 M17 marcas 139/35/1 coherentes + Totales + citas D97/D102/F127/P256 + suite",
      (x17, e17, q17) == (139, 35, 1) and t17 and t17.group(1) == u"175"
      and all(s in m17 for s in [u"D97", u"D102", u"F127", u"P256", u"test_m17_persistencia_rejilla.gd", u"2026-11-06"]),
      u"[x]=%d [ ]=%d [?]=%d Totales=%s" % (x17, e17, q17, t17.group(1) if t17 else u"?"))

# 13. M129 flip sustentado
m129 = rd(RAIZ + u"\\DOCUMENTACION\\129-Merchandising\\plan-actual\\05-Checklist.md")
x129 = len(re.findall(r"^- \[x\]", m129, re.M)); e129 = len(re.findall(r"^- \[ \]", m129, re.M)); q129 = len(re.findall(r"^- \[\?\]", m129, re.M))
t129 = re.search(u"Totales:\\*\\*\\s*(\\d+)\\s+ítems", m129)
check(u"13 M129 marcas 107/0/1 coherentes + Totales 108 + citas merch v3",
      (x129, e129, q129) == (107, 0, 1) and t129 and t129.group(1) == u"108"
      and all(s in m129 for s in [u"merch_manager.gd", u"reservar_unidades", u"58 checks", u"B-17", u"2026-11-06"]),
      u"[x]=%d [ ]=%d [?]=%d Totales=%s" % (x129, e129, q129, t129.group(1) if t129 else u"?"))

# 14. artefactos DS-OC en disco
arts = [u"tests/test_m17_persistencia_rejilla.gd", u"tests/test_m17_construccion_validacion.gd",
        u"tests/test_m17_reglas_pieza.gd", u"tests/test_m17_suites_integracion.gd",
        u"scripts/legal/merch_manager.gd", u"scripts/legal/merch_validator.gd",
        u"tests/test_merch_m129.gd", u"tests/test_merch_boot_m129.gd",
        u"data/legal/merchandising.json", u"scripts/construccion/construccion_mundo.gd", u"scripts/construccion/build_manager.gd"]
miss = []
for a in arts:
    if not os.path.isfile(os.path.join(GAME, a)) and not glob.glob(os.path.join(GAME, u"**", os.path.basename(a)), recursive=True):
        miss.append(a)
check(u"14 artefactos DS-OC M17/M129 en disco (11 citados)", len(miss) == 0, u"faltan: %s" % (miss if miss else u"ninguno"))

# 15. regimen agrupador: 0 D codigo
st = git(u"status", u"--porcelain")[0]
wt = len([l for l in st.split(u"\n") if l.strip()])
d_code = [l for l in st if l[:2].strip() == u"D" and (l[3:].startswith(u"game/") or l[3:].startswith(u"scripts/"))]
check(u"15 0 deletions en game/scripts (régimen agrupador)", len(d_code) == 0, u"WT=%d" % wt)

# 16. Temp/kilo
temp_mine = len(glob.glob(RAIZ + u"\\Temp\\kilo\\*"))
check(u"16 Temp/kilo directos <= 60 (limpieza reversible)", temp_mine <= 60, u"directos=%d" % temp_mine)
arch = len(glob.glob(RAIZ + u"\\Temp\\kilo\\_archivo_v25_v41\\*"))
check(u"16b _archivo_v25_v41 con 176 movidos (trazable)", arch == 176, u"archivos=%d" % arch)

# 17. HEAD
out, _ = git(u"log", u"--oneline", u"-5")
check(u"17 HEAD 6a8ab2f en log -5", u"6a8ab2f" in out, out.strip().split(u"\n")[0][:60])

# 18. msg 354 intacto
m354 = glob.glob(CANAL + u"\\354-*.md")
check(u"18 msg 354 (v42) intacto", bool(m354) and u"**VUELTA 42 CIERRE**" in rd(m354[0]), u"max canal=%s" % bn[:1])

# 19. canal max == 355
nums = []
for f in glob.glob(CANAL + u"\\*.md"):
    mm = re.match(u"(\\d+)-", os.path.basename(f))
    if mm:
        nums.append(int(mm.group(1)))
check(u"19 canal max numerado == 355", max(nums) == 355, u"max=%d" % max(nums))

# 20. encoding estricto
enc_ok = True
for p in [AUD, BK, BM, MSG355] + vl:
    try:
        t = io.open(p, encoding=u"utf-8").read()
        if u"�" in t or u"Ã³" in t or u"â€" in t:
            enc_ok = False
    except UnicodeDecodeError:
        enc_ok = False
check(u"20 encoding UTF-8 estricto (AUD/BK/BM/msg355/Log)", enc_ok)

# 21. estado_director
edp = RAIZ + u"\\Logs\\estado_director.json"
ed = json.loads(rd(edp))
check(u"21 estado_director >= 399 claves", len(ed) >= 399, u"%d claves" % len(ed))

# 22. copias ausentes documentadas
check(u"22 translation/ y ling_i18n_manager.gd ausentes (documentado §34/addendum)",
      not os.path.exists(os.path.join(GAME, u"translation")) and not os.path.exists(os.path.join(GAME, u"scripts", u"ling_i18n_manager.gd")))

# 23. anti-loop honesto
check(u"23 ling_345-351_acusado NO registrado (anti-loop) o registrado=agnes respondió",
      (u"ling_345-351_acusado" not in ed) or bool(ed.get(u"ling_345-351_acusado")),
      u"presente=%s" % (u"ling_345-351_acusado" in ed))

print(u"\n" + u"=" * 78)
np_ = sum(1 for _, ok, _ in results if ok)
nf_ = sum(1 for _, ok, _ in results if not ok)
print(u"RESULTADO: %d PASS / %d FAIL" % (np_, nf_))
for name, ok, det in results:
    if not ok:
        print(u"  FAIL:", name, u"|", det)
