# -*- coding: utf-8 -*-
"""CHECK v41: 34 checks tolerantes a drift de flota activa y al slot Cron C 00:17Z (runtime discovery)."""
import io
import os
import re
import glob
import json
import datetime
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
CANAL = RAIZ + u"\\Mensajes entre modelos\\Ling-3.1-Flash"
GD = RAIZ + u"\\game\\isla-ancestral"
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
BKP = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"

def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

def git(*a):
    return subprocess.run([u"git", u"-C", RAIZ] + list(a), capture_output=True,
                          text=True, encoding=u"utf-8", errors=u"replace").stdout

results = []
def ck(n, name, ok, detail=u""):
    results.append((n, name, bool(ok), detail))

msg353 = sorted(glob.glob(CANAL + u"\\353-*vuelta41*.md"))
logs41 = sorted(glob.glob(RAIZ + u"\\Logs\\*-vuelta41-*.md"))
nlog = None
if logs41:
    m = re.search(r"# Log (\d+)", rd(logs41[0]))
    nlog = m.group(1) if m else None

# 1. msg 353
if msg353:
    t = rd(msg353[0]); sz = os.path.getsize(msg353[0])
    ck(1, u"msg 353 existe + canónico + firma + responde + <4KiB",
       u"**VUELTA 41 CIERRE**" in t and u"**Modelo:** Ling-3.1-Flash" in t and
       u"**Responde a:** agnes-3-flash" in t and sz < 4096,
       u"%s (%dB)" % (os.path.basename(msg353[0])[:55], sz))
else:
    ck(1, u"msg 353 existe", False, u"no glob")

# 2. pool canal
pc = [x for x in rd(CANAL + u"\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
ck(2, u"pool canal cabeza >= 354 (353 consumido)", len(pc) > 0 and int(pc[0]) >= 354, u"cabeza=" + (pc[0] if pc else u"?"))

# 3. AUDITORIA §33
t = rd(AUD)
ck(3, u"AUDITORIA §33 VUELTA 41 (msg353+LogN runtime)",
   u"## 33." in t and u"VUELTA 41" in t and u"353" in t and (nlog or u"2349") in t,
   u"%d chars, NLOG=%s" % (len(t), nlog))

# 4. backlog ESTADO v41
b = rd(BKP)
ck(4, u"backlog 01: ESTADO v41 (VUELTA 41 CIERRE) + header v14-v41", u"VUELTA 41 CIERRE" in b and u"v14-v41" in b, u"%d chars" % len(b))

# 5. §32 (v40) intacto
ck(5, u"AUDITORIA §32 (v40) intacto", u"## 32." in t)

# 6. Log vuelta41 unico
ck(6, u"Logs: exactamente 1 *-vuelta41-* con '# Log 23xx' + VUELTA 41",
   len(logs41) == 1 and u"VUELTA 41" in rd(logs41[0]) and u"# Log 23" in rd(logs41[0]),
   os.path.basename(logs41[0])[:55] if logs41 else u"ninguno")

# 7. pool Logs
pl = [x for x in rd(RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
ck(7, u"pool Logs cabeza >= NLOG+1; NLOG no en pool",
   len(pl) > 0 and int(pl[0]) >= (int(nlog) + 1 if nlog else 2350) and (nlog not in pl),
   u"cabeza=" + (pl[0] if pl else u"?"))

# 8. BACKLOG-MASTER
bm = rd(RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\BACKLOG-MASTER.md")
ck(8, u"BACKLOG-MASTER: lineas 'Log creado: **2344/2345/2348/NLOG**'",
   u"**2344**" in bm and u"**2345**" in bm and u"**2348**" in bm and (u"**" + (nlog or u"2349") + u"**") in bm)

# 9. blobs riel
mgr = git(u"hash-object", u"game/isla-ancestral/scripts/localization/localization_manager.gd").strip()
ptb = git(u"hash-object", u"game/isla-ancestral/locales/pt.po").strip()
ck(9, u"riel blobs INTACTOS (manager 047eab5ff111 / pt.po d2b567c48e88)",
   mgr == u"047eab5ff111dffdc3f3b48f8241c787e104c0a5" and ptb == u"d2b567c48e88cfa6d9d22d76eaf31804e1e9028c",
   mgr[:12] + u" / " + ptb[:12])

# 10. .mo
mo = glob.glob(GD + u"\\**\\*.mo", recursive=True)
ck(10, u"0 archivos .mo en game/", len(mo) == 0, u"count=" + str(len(mo)))

# 11-12. Totales reales de 05-Checklist
ck157 = rd(RAIZ + u"\\DOCUMENTACION\\157-Medios-De-Transporte\\plan-actual\\05-Checklist.md")
ck(11, u"M157 (157-Medios-De-Transporte) Totales 132 items (8 [x]/124 [ ])",
   u"132 items" in ck157 and u"8 [x] / 124 [ ]" in ck157, u"132")
ck87 = rd(RAIZ + u"\\DOCUMENTACION\\87-Localizacion\\plan-actual\\05-Checklist.md")
ck(12, u"M87 (87-Localizacion) Totales 140 ítems", (u"140 ítems" in ck87) or (u"= 140" in ck87), u"140")

# 13. estado_director
edp = RAIZ + u"\\Logs\\estado_director.json"
ed = json.loads(rd(edp))
mt = datetime.datetime.fromtimestamp(os.stat(edp).st_mtime)
ck(13, u"estado_director >= 398 claves + 6 claves dormancia + mtime>=20:12",
   len(ed) >= 398 and u"crons_apagados_6nov" in ed and u"flota_6nov_actual" in ed and
   u"nemotron_desbloqueado" in ed and u"step5_fuera" in ed and u"fuera_flota" in ed and
   mt >= datetime.datetime(2026, 11, 6, 20, 12),
   u"%d claves, mtime %s" % (len(ed), mt.strftime(u"%H:%M")))
ck(13.1, u"flota_6nov_actual incluye 'Ling (reactivado)'",
   u"Ling (reactivado)" in json.dumps(ed.get(u"flota_6nov_actual", []), ensure_ascii=False))

# 14. censor
cz = rd(RAIZ + u"\\Temp\\kilo\\v41_censor_gitsha.txt")
ck(14, u"censor v41: 2x INTACTO=True + msgids 276 + diff vacío + HEAD 6a8ab2f",
   cz.count(u"INTACTO=True") == 2 and u"msgids(regex ^msgid \", sin header): 276" in cz and
   u"git diff HEAD riel i18n: ''" in cz and u"6a8ab2f" in cz)

# 15. watchdog
vd = rd(RAIZ + u"\\Temp\\kilo\\v41_validador_i18n.txt")
ck(15, u"watchdog v41 LIMPIO rc=0", u"rc=0" in vd and u"LIMPIO" in vd and u"[PT] 170 claves" in vd)

# 16. detector
dd = rd(RAIZ + u"\\Temp\\kilo\\v41_detector_delta.txt")
ck(16, u"detector v41: 82591 chars + [x]=22649 + A1=21 + R4=187 (14ª hora)",
   len(dd) == 82591 and u"items [x]: 22649" in dd and u"A1-GRAVE flip declarado no aplicado: 21" in dd and
   u"R4-GRAVE re-flip Beam-26oct spec sobre disco: 187" in dd, u"%d chars" % len(dd))

# 17. HEAD 6a8ab2f en historia
ck(17, u"6a8ab2f en git log -5 (Cron C puede haber encima)", u"6a8ab2f" in git(u"log", u"--oneline", u"-5"),
   u"HEAD ahora=" + git(u"log", u"-1", u"--format=%h").strip())

# 18. msg Ling versionados en HEAD
ls = git(u"ls-tree", u"-r", u"--name-only", u"HEAD")
lingv = [l for l in ls.split(u"\n") if l.startswith(u"Mensajes entre modelos/Ling-3.1-Flash/")]
need = [u"347-", u"348-", u"349-", u"350-", u"351-"]
have = all(any(n in l for l in lingv) for n in need)
has352 = any(u"352-" in l for l in lingv)
ck(18, u"msg Ling 347-351 versionados en HEAD (352 informativo)",
   have and len(lingv) >= 14, u"%d entries; 352 versionado=%s" % (len(lingv), has352))

# 19. canal max == 353
allm = sorted(glob.glob(CANAL + u"\\*.md"))
nums = []
for p in allm:
    mm = re.match(r"(\d+)-", os.path.basename(p))
    if mm:
        nums.append(int(mm.group(1)))
ck(19, u"canal: max numerado == 353 (sin 354+)", bool(nums) and max(nums) == 353, u"max=" + str(max(nums) if nums else 0))

# 20. Logs 2344-2348 existen
ok20 = all(glob.glob(RAIZ + u"\\Logs\\%d-*.md" % n) for n in [2344, 2345, 2346, 2347, 2348])
ck(20, u"Logs 2344/2345/2346/2347/2348 existen (v39 doble + Hy3 + M107 + v40)", ok20)

# 21. wiring CI
qy = rd(RAIZ + u"\\.github\\workflows\\quality.yml")
ck(21, u"quality.yml: test_diario_persist + test_persistencia_m64",
   u"test_diario_persist" in qy and u"test_persistencia_m64" in qy)

# 22. bug_156
ck(22, u"estado_director tiene bug_156_i18n_json (DS#491)", u"bug_156_i18n_json" in ed)

# 23. §32 preservado (HEAD o WT — tolerante al slot 00:17Z)
diff_aud = git(u"diff", u"HEAD", u"--", u"DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")
h32 = git(u"show", u"HEAD:DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")
ck(23, u"§32 (v40) preservado: versionado en HEAD (Cron C 00:17Z) o en WT diff",
   u"## 32." in h32 or u"## 32." in diff_aud,
   u"en HEAD=" + str(u"## 32." in h32) + u" en WT=" + str(u"## 32." in diff_aud))

# 24. flota evidencia
f1 = glob.glob(RAIZ + u"\\Mensajes entre modelos\\Hy3\\497-*.md")
f2 = glob.glob(RAIZ + u"\\Logs\\2347-*.md")
ck(24, u"flota: Hy3/497 (acuse tanda restante) + Log 2347 (M107)", bool(f1 and f2))

# 25. Log 2347 = M107
l2347 = rd(glob.glob(RAIZ + u"\\Logs\\2347-*.md")[0]) if f2 else u""
ck(25, u"Log 2347 = reconciliacion conteo M107 + backup", u"M107" in l2347 and u"econcili" in l2347)

# 26. WT acotado
st = [l for l in git(u"status", u"--porcelain").split(u"\n") if l.strip()]
ck(26, u"WT total <= 60 (flota activa)", len(st) <= 60, u"WT=" + str(len(st)))

# 27. msg 353 contenido
if msg353:
    t353 = rd(msg353[0])
    ck(27, u"msg 353 cita 6a8ab2f + 398 + 2349 + anti-loop",
       u"6a8ab2f" in t353 and u"398" in t353 and (u"2349" in t353 or (nlog or u"2349") in t353) and u"anti-loop" in t353.lower())
else:
    ck(27, u"msg 353 contenido", False, u"no existe")

# 28-29. crecimiento
ck(28, u"AUDITORIA >= 103000 chars", len(t) >= 103000, str(len(t)))
ck(29, u"backlog 01 >= 220242 chars", len(b) >= 220242, str(len(b)))

# 30. sello_14_m64
ck(30, u"estado_director: sello_14_m64 (109/119, Hy3 gate-2 sostuvo)",
   u"sello_14_m64" in ed and u"109/119" in json.dumps(ed.get(u"sello_14_m64", {}), ensure_ascii=False))

# 31. Log NLOG en disco
ck(31, u"Log NLOG en disco (glob vuelta41)", len(logs41) == 1, os.path.basename(logs41[0])[:60] if logs41 else u"ninguno")

# 32-33. Cron C 6a8ab2f preservó v39
hb_head = git(u"show", u"HEAD:DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md")
ck(32, u"Cron C 6a8ab2f preservó v39: HEAD-backlog tiene 'VUELTA 39 CIERRE'", u"VUELTA 39 CIERRE" in hb_head)
ck(33, u"HEAD-AUDITORIA contiene '## 31.' (§31 v39 versionado)", u"## 31." in h32 if h32 else u"## 31." in git(u"show", u"HEAD:DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"))

# 34. v40 preservado en HEAD o WT (tolerante slot 00:17Z)
ck(34, u"v40 preservado: HEAD-backlog 'VUELTA 40 CIERRE' o §32 en WT diff",
   u"VUELTA 40 CIERRE" in hb_head or u"## 32." in diff_aud,
   u"HEAD-backlog v40=" + str(u"VUELTA 40 CIERRE" in hb_head) + u" WT-diff §32=" + str(u"## 32." in diff_aud))

np_ = sum(1 for r in results if r[2])
nf = sum(1 for r in results if not r[2])
print(u"=" * 70)
for n, name, ok, detail in results:
    print(u"%s check %s: %s | %s" % (u"PASS" if ok else u"FAIL", n, name, detail))
print(u"=" * 70)
print(u"RESULTADO: %d PASS / %d FAIL" % (np_, nf))
import sys
sys.exit(0 if nf == 0 else 1)
