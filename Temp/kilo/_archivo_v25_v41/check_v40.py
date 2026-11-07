# -*- coding: utf-8 -*-
"""CHECK v40: 31 checks tolerantes a drift de flota activa (>=, descubrimiento runtime, race 2347)."""
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

def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

def git(*a):
    return subprocess.run([u"git", u"-C", RAIZ] + list(a), capture_output=True,
                          text=True, encoding=u"utf-8", errors=u"replace").stdout

results = []
def ck(n, name, ok, detail=u""):
    results.append((n, name, bool(ok), detail))

msg352 = sorted(glob.glob(CANAL + u"\\352-*vuelta40*.md"))
logs40 = sorted(glob.glob(RAIZ + u"\\Logs\\*-vuelta40-*.md"))
nlog = None
if logs40:
    m = re.search(r"# Log (\d+)", rd(logs40[0]))
    nlog = m.group(1) if m else None

# 1. msg 352
if msg352:
    t = rd(msg352[0]); sz = os.path.getsize(msg352[0])
    ck(1, u"msg 352 existe + canónico + firma + responde + <4KiB",
       u"**VUELTA 40 CIERRE**" in t and u"**Modelo:** Ling-3.1-Flash" in t and
       u"**Responde a:** agnes-3-flash" in t and sz < 4096,
       u"%s (%dB)" % (os.path.basename(msg352[0])[:55], sz))
else:
    ck(1, u"msg 352 existe", False, u"no glob")

# 2. pool canal
pc = [x for x in rd(CANAL + u"\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
ck(2, u"pool canal cabeza >= 353 (352 consumido + ampliado 353-382)", len(pc) > 0 and int(pc[0]) >= 353, u"cabeza=" + (pc[0] if pc else u"?"))

# 3. AUDITORIA §32
t = rd(RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")
ck(3, u"AUDITORIA §32 VUELTA 40 (msg352+LogN runtime)", u"## 32." in t and u"VUELTA 40" in t and u"352" in t and (nlog or u"2348") in t,
   u"%d chars, NLOG=%s" % (len(t), nlog))

# 4. backlog ESTADO v40
b = rd(RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md")
ck(4, u"backlog 01: ESTADO v40 (VUELTA 40 CIERRE) + header v14-v40", u"VUELTA 40 CIERRE" in b and u"v14-v40" in b, u"%d chars" % len(b))

# 5. §31 preservado
ck(5, u"AUDITORIA §31 (v39) intacto", u"## 31." in t)

# 6. Log vuelta40 unico
ck(6, u"Logs: exactamente 1 *-vuelta40-* con '# Log 23xx' + VUELTA 40",
   len(logs40) == 1 and u"VUELTA 40" in rd(logs40[0]) and u"# Log 23" in rd(logs40[0]),
   os.path.basename(logs40[0])[:55] if logs40 else u"ninguno")

# 7. pool Logs
pl = [x for x in rd(RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
ck(7, u"pool Logs cabeza >= 2349; NLOG no en pool",
   len(pl) > 0 and int(pl[0]) >= 2349 and (nlog not in pl), u"cabeza=" + (pl[0] if pl else u"?"))

# 8. BACKLOG-MASTER
bm = rd(RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\BACKLOG-MASTER.md")
ck(8, u"BACKLOG-MASTER: lineas 'Log creado: **2344/2345/NLOG**'",
   u"**2344**" in bm and u"**2345**" in bm and (u"**" + (nlog or u"2348") + u"**") in bm)

# 9. blobs riel
mgr = git(u"hash-object", u"game/isla-ancestral/scripts/localization/localization_manager.gd").strip()
ptb = git(u"hash-object", u"game/isla-ancestral/locales/pt.po").strip()
ck(9, u"riel blobs INTACTOS (manager 047eab5ff111 / pt.po d2b567c48e88)",
   mgr == u"047eab5ff111dffdc3f3b48f8241c787e104c0a5" and ptb == u"d2b567c48e88cfa6d9d22d76eaf31804e1e9028c",
   mgr[:12] + u" / " + ptb[:12])

# 10. .mo
mo = glob.glob(GD + u"\\**\\*.mo", recursive=True)
ck(10, u"0 archivos .mo en game/", len(mo) == 0, u"count=" + str(len(mo)))

# 11-12. Totales reales de los 05-Checklist (paths canónicos descubiertos en disco)
ck157 = rd(RAIZ + u"\\DOCUMENTACION\\157-Medios-De-Transporte\\plan-actual\\05-Checklist.md")
ck(11, u"M157 (157-Medios-De-Transporte) Totales 132 items (8 [x]/124 [ ])",
   u"132 items" in ck157 and u"8 [x] / 124 [ ]" in ck157, u"132")
ck87 = rd(RAIZ + u"\\DOCUMENTACION\\87-Localizacion\\plan-actual\\05-Checklist.md")
ck(12, u"M87 (87-Localizacion) Totales 140 ítems", (u"140 ítems" in ck87) or (u"= 140" in ck87), u"140")

# 13. estado_director
edp = RAIZ + u"\\Logs\\estado_director.json"
ed = json.loads(rd(edp))
mt = datetime.datetime.fromtimestamp(os.stat(edp).st_mtime)
ck(13, u"estado_director >= 397 claves + 6 claves dormancia + mtime>=19:00",
   len(ed) >= 397 and u"crons_apagados_6nov" in ed and u"flota_6nov_actual" in ed and
   u"nemotron_desbloqueado" in ed and u"step5_fuera" in ed and u"fuera_flota" in ed and
   mt >= datetime.datetime(2026, 11, 6, 19, 0),
   u"%d claves, mtime %s" % (len(ed), mt.strftime(u"%H:%M")))
ck(13.1, u"flota_6nov_actual incluye 'Ling (reactivado)'",
   u"Ling (reactivado)" in json.dumps(ed.get(u"flota_6nov_actual", []), ensure_ascii=False))

# 14. censor
cz = rd(RAIZ + u"\\Temp\\kilo\\v40_censor_gitsha.txt")
ck(14, u"censor v40: 2x INTACTO=True + msgids 276 + diff vacío",
   cz.count(u"INTACTO=True") == 2 and u"msgids(regex ^msgid \", sin header): 276" in cz and u"git diff HEAD riel i18n: ''" in cz)

# 15. watchdog
vd = rd(RAIZ + u"\\Temp\\kilo\\v40_validador_i18n.txt")
ck(15, u"watchdog v40 LIMPIO rc=0", u"rc=0" in vd and u"LIMPIO" in vd and u"[PT] 170 claves" in vd)

# 16. detector
dd = rd(RAIZ + u"\\Temp\\kilo\\v40_detector_delta.txt")
ck(16, u"detector v40: 82591 chars + [x]=22649 + A1=21 + R4=187",
   len(dd) == 82591 and u"items [x]: 22649" in dd and u"A1-GRAVE flip declarado no aplicado: 21" in dd and
   u"R4-GRAVE re-flip Beam-26oct spec sobre disco: 187" in dd, u"%d chars" % len(dd))

# 17. HEAD
head_now = git(u"log", u"-1", u"--format=%h").strip()
ck(17, u"4091de8 en git log -5 (Cron C 6a8ab2f puede estar encima)",
   u"4091de8" in git(u"log", u"--oneline", u"-5"), u"HEAD ahora=" + head_now)

# 18. msg Ling versionados
ls = git(u"ls-tree", u"-r", u"--name-only", u"4091de8")
lingv = [l for l in ls.split(u"\n") if l.startswith(u"Mensajes entre modelos/Ling-3.1-Flash/")]
need = [u"347-", u"348-", u"349-", u"350-", u"351-"]
have = all(any(n in l for l in lingv) for n in need)
ck(18, u"msg Ling 347-351 versionados en 4091de8 (>=14 entries)",
   have and len(lingv) >= 14, u"%d entries" % len(lingv))

# 19. canal max == 352
allm = sorted(glob.glob(CANAL + u"\\*.md"))
nums = []
for p in allm:
    mm = re.match(r"(\d+)-", os.path.basename(p))
    if mm:
        nums.append(int(mm.group(1)))
ck(19, u"canal: max numerado == 352 (sin 353+)", bool(nums) and max(nums) == 352, u"max=" + str(max(nums) if nums else 0))

# 20. Logs 2344/2345/2346/2348 (2347 = flota, race)
e2344 = glob.glob(RAIZ + u"\\Logs\\2344-*.md")
e2345 = glob.glob(RAIZ + u"\\Logs\\2345-*.md")
e2346 = glob.glob(RAIZ + u"\\Logs\\2346-*.md")
e2348 = glob.glob(RAIZ + u"\\Logs\\2348-*.md")
ck(20, u"Logs 2344/2345 (míos v39) + 2346 (Hy3) + 2348 (mío v40) existen",
   bool(e2344 and e2345 and e2346 and e2348))

# 21. wiring CI
qy = rd(RAIZ + u"\\.github\\workflows\\quality.yml")
ck(21, u"quality.yml: test_diario_persist + test_persistencia_m64",
   u"test_diario_persist" in qy and u"test_persistencia_m64" in qy)

# 22. bug_156
ck(22, u"estado_director tiene bug_156_i18n_json (DS#491)", u"bug_156_i18n_json" in ed)

# 23. §31 en WT
diff_aud = git(u"diff", u"HEAD", u"--", u"DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")
h31 = git(u"show", u"HEAD:DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")
ck(23, u"§31 (v39) preservado: versionado en HEAD (Cron C) o en WT diff",
   u"## 31." in h31 or u"## 31." in diff_aud,
   u"en HEAD=" + str(u"## 31." in h31) + u" en WT=" + str(u"## 31." in diff_aud))

# 24. flota activa
f1 = glob.glob(RAIZ + u"\\Mensajes entre modelos\\Hy3\\495-*.md")
f2 = glob.glob(RAIZ + u"\\Mensajes entre modelos\\Nemotron-3.5-Super-VL\\273-*.md")
f3 = glob.glob(RAIZ + u"\\Mensajes entre modelos\\DS-V4.1-Flash-Opencode\\249-*.md")
f4 = glob.glob(RAIZ + u"\\Mensajes entre modelos\\HY4\\30-*.md")
ck(24, u"flota activa: Hy3/495 + Nem/273 + DS-OC/249 + HY4/30", bool(f1 and f2 and f3 and f4))

# 25. Log 2346 Hy3
l2346 = rd(glob.glob(RAIZ + u"\\Logs\\2346-*.md")[0]) if e2346 else u""
ck(25, u"Log 2346 = Hy3 verifica tarea 494 (M37+M64+bugmouse)", u"Hy3 verifies director task 494" in l2346)

# 26. WT acotado
st = [l for l in git(u"status", u"--porcelain").split(u"\n") if l.strip()]
ck(26, u"WT total <= 60 (flota activa)", len(st) <= 60, u"WT=" + str(len(st)))

# 27. msg 352 contenido
if msg352:
    t352 = rd(msg352[0])
    ck(27, u"msg 352 cita crons_apagados + 4091de8 + 397 + Log 2348",
       u"crons_apagados" in t352 and u"4091de8" in t352 and u"397" in t352 and u"2348" in t352)
else:
    ck(27, u"msg 352 contenido", False, u"no existe")

# 28. AUDITORIA creció
ck(28, u"AUDITORIA >= 100000 chars", len(t) >= 100000, str(len(t)))

# 29. backlog creció
ck(29, u"backlog 01 >= 218014 chars", len(b) >= 218014, str(len(b)))

# 30. race 2347 documentado: nlog == 2348 y 2347 no en pool
ck(30, u"race 2347: ritual tomó 2348 (2347 consumido por flota); 2347 no en pool",
   nlog == u"2348" and u"2347" not in pl, u"NLOG=%s cabeza=%s" % (nlog, pl[0] if pl else u"?"))

# 31. Log 2347 existe en disco (consumidor flota escribió) O pool lo consumió sin archivo aun
e2347 = glob.glob(RAIZ + u"\\Logs\\2347-*.md")
ck(31, u"Log 2347 en disco (flota) o pendiente de escritura por consumidor",
   bool(e2347) or u"2347" not in pl,
   (os.path.basename(e2347[0])[:70] if e2347 else u"2347 consumido, archivo aun no escrito")[:90])

# 32. Cron C 6a8ab2f preservó ESTADO v39 en HEAD
hb_head = git(u"show", u"HEAD:DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md")
ck(32, u"Cron C 6a8ab2f preservó v39: HEAD-version backlog tiene 'VUELTA 39 CIERRE'", u"VUELTA 39 CIERRE" in hb_head)

# 33. sello_14_m64 en estado_director (agnes 20:12)
ck(33, u"estado_director: sello_14_m64 (M64 sellado 23:12, Hy3 gate-2 sostuvo, 109/119)",
   u"sello_14_m64" in ed and u"109/119" in json.dumps(ed.get(u"sello_14_m64", {}), ensure_ascii=False))

np_ = sum(1 for r in results if r[2])
nf = sum(1 for r in results if not r[2])
print(u"=" * 70)
for n, name, ok, detail in results:
    print(u"%s check %s: %s | %s" % (u"PASS" if ok else u"FAIL", n, name, detail))
print(u"=" * 70)
print(u"RESULTADO: %d PASS / %d FAIL" % (np_, nf))
import sys
sys.exit(0 if nf == 0 else 1)
