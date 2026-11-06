# -*- coding: utf-8 -*-
"""check_v39: verifica integridad de las escrituras de la vuelta 39 (27 checks).
Adaptado a hechos verificados en disco: doble ritual (Logs 2344+2345), Cron C 4091de8
preservó riel v35-v38, flota reactivada (estado_director mutó a 397 claves).
Tolerante a drift de flota activa (>= en pools/HEAD/mtime)."""
import io
import os
import glob
import json
import datetime
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
GD = RAIZ + u"\\game\\isla-ancestral"
CANAL = RAIZ + u"\\Mensajes entre modelos\\Ling-3.1-Flash"
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS"

def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

def rdb(p):
    return io.open(p, u"rb").read()

def git(*a):
    return subprocess.run([u"git", u"-C", RAIZ] + list(a), capture_output=True,
                          text=True, encoding=u"utf-8", errors=u"replace").stdout.strip()

results = []
def chk(name, ok, detail=u""):
    results.append((name, bool(ok), detail))

# ---- descubrir hechos ----
m351 = glob.glob(CANAL + u"\\351-*.md")
logv39 = sorted(glob.glob(RAIZ + u"\\Logs\\*-vuelta39-*.md"))
N1 = logv39[0].split(u"\\")[-1].split(u"-")[0] if logv39 else u"?"
N2 = logv39[-1].split(u"\\")[-1].split(u"-")[0] if logv39 else u"?"

# 1-3. msg 351
if m351:
    b = rdb(m351[0]); t = rd(m351[0])
    chk(u"msg351 existe", True, u"%d bytes" % len(b))
    chk(u"msg351 <4KiB", len(b) < 4096, u"%d B" % len(b))
    chk(u"msg351 firma+responde+vuelta39",
        u"Ling-3.1-Flash" in t and u"agnes-3-flash" in t and u"Responde a" in t
        and (u"VUELTA 39" in t or u"vuelta 39" in t))
else:
    chk(u"msg351 existe", False); chk(u"msg351 <4KiB", False); chk(u"msg351 firma+responde+vuelta39", False)

# 4-5. pool canal
pool_c = [x for x in rd(CANAL + u"\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
chk(u"pool canal 351 consumido", u"351" not in pool_c)
chk(u"pool canal cabeza 352", pool_c[0].strip() == u"352", pool_c[0])

# 6. AUDITORIA §31 con Logs N1+N2
aud = rd(BK + u"\\..\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")
chk(u"AUDITORIA sec31+LogN1+N2", (u"## 31." in aud) and N1 in aud and N2 in aud, u"N=%s+%s" % (N1, N2))

# 7-9. backlog v39
bkv = rd(BK + u"\\01-Backlog-Vueltas-31oct.md")
chk(u"backlog ESTADO v39", u"VUELTA 39 CIERRE" in bkv)
chk(u"backlog header v14-v39", u"ESTADO v14-v39" in bkv)
chk(u"backlog v38 preservado + Log2343", u"VUELTA 38 CIERRE" in bkv and u"**Log 2343**" in bkv)

# 10. doble ritual: exactamente 2 logs vuelta39 (2344+2345)
chk(u"logs vuelta39 == 2 (doble ritual documentado)", len(logv39) == 2,
    u"; ".join(os.path.basename(x)[:60] for x in logv39))

# 11-12. pool Logs
pool_l = [x for x in rd(RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
chk(u"pool Logs sin N1 ni N2", (N1 not in pool_l) and (N2 not in pool_l), u"N=%s+%s" % (N1, N2))
chk(u"pool Logs cabeza >= N2+1", (int(pool_l[0]) >= int(N2) + 1) if N2.isdigit() else False, pool_l[0])

# 13. BACKLOG-MASTER lineas N1 y N2
bm = BK + u"\\BACKLOG-MASTER.md"
tbm = rd(bm) if os.path.exists(bm) else u""
chk(u"BACKLOG-MASTER N1 y N2", N1 in tbm and N2 in tbm)

# 14-15. blobs git intactos (centinela)
mgr = git(u"hash-object", u"game/isla-ancestral/scripts/localization/localization_manager.gd")
ptb = git(u"hash-object", u"game/isla-ancestral/locales/pt.po")
chk(u"manager blob 047eab5ff111 intacto", mgr == u"047eab5ff111dffdc3f3b48f8241c787e104c0a5", mgr[:10])
chk(u"pt.po blob d2b567c48e88 intacto", ptb == u"d2b567c48e88cfa6d9d22d76eaf31804e1e9028c", ptb[:10])

# 16. 0 .mo
mo2 = glob.glob(GD + u"\\**\\*.mo", recursive=True)
chk(u"0 .mo en game/ recursivo", len(mo2) == 0, u"hallados=%d" % len(mo2))

# 17-18. M157/M87 Totales
m157 = rd(RAIZ + u"\\DOCUMENTACION\\157-Medios-De-Transporte\\plan-actual\\05-Checklist.md")
m87 = rd(RAIZ + u"\\DOCUMENTACION\\87-Localizacion\\plan-actual\\05-Checklist.md")
chk(u"M157 Totales 132 intacto", u"132 items" in m157 and u"Completados: 8" in m157)
chk(u"M87 Totales 140 intacto", u"140" in m87 and u"135" in m87)

# 19. estado_director reactivado (>=397 claves, mtime >= 19:00 hoy, bug_152 presente)
edp = RAIZ + u"\\Logs\\estado_director.json"
ed = json.loads(rd(edp))
mt = datetime.datetime.fromtimestamp(os.stat(edp).st_mtime)
raw = rd(edp)
chk(u"estado_director reactivado (>=397, mtime>=19:00, bug_156)",
    len(ed) >= 397 and mt >= datetime.datetime(2026, 11, 6, 19, 0) and u"bug_156_i18n_json" in raw,
    u"%d claves, mtime %s" % (len(ed), mt.strftime(u"%H:%M")))

# 20. censor v39 (evidencia discovery): INTACTO + HEAD 390652a
cen = rd(RAIZ + u"\\Temp\\kilo\\v39_censor_gitsha.txt")
chk(u"censor v39 INTACTO + 390652a",
    u"manager WT=047eab5ff1 HEAD=047eab5ff1 INTACTO=True" in cen
    and u"pt.po   WT=d2b567c48e HEAD=d2b567c48e INTACTO=True" in cen
    and u"390652a6" in cen)

# 21. validador v39 LIMPIO
val = rd(RAIZ + u"\\Temp\\kilo\\v39_validador_i18n.txt")
chk(u"validador v39 LIMPIO", u"rc=0" in val and u"LIMPIO" in val and u"170 claves" in val and u"comunes: 159" in val)

# 22. detector v39: 82591 chars + invariantes
det = rd(RAIZ + u"\\Temp\\kilo\\v39_detector_delta.txt")
chk(u"detector v39 82591 chars + invariantes",
    len(det) == 82591 and u"checklists escaneados: 168" in det
    and u"GRIS diseno step-5 14oct: 209" in det and u"FP: 4" in det and u"items [x]: 22649" in det
    and u"R4-GRAVE re-flip Beam-26oct spec sobre disco: 187" in det,
    u"%d chars" % len(det))

# 23. AUDITORIA versionada en git (Cron C 4091de8)
logaud = git(u"log", u"--oneline", u"-1", u"--", u"DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")
chk(u"AUDITORIA versionada (4091de8)", u"4091de8" in logaud, logaud[:70])

# 24. wiring CI intacto
qy = rd(RAIZ + u"\\.github\\workflows\\quality.yml")
chk(u"quality.yml L679+L553 cableados", u"scripts/diario/test_diario_persist.gd" in qy and u"scripts/ia_npc/test_persistencia_m64.gd" in qy)

# 25. Cron C 4091de8 en historia reciente (tolerante a nuevos commits de flota activa)
log3 = git(u"log", u"-3", u"--format=%h")
chk(u"Cron C 4091de8 en git log -3", u"4091de8" in log3, log3.replace(u"\n", u" | ")[:80])

# 26. mis msg 347-351 versionados por Cron C (ls-tree: rutas completas; --stat abrevia rutas largas)
tree26 = git(u"ls-tree", u"-r", u"--name-only", u"4091de8")
pres = [n for n in [u"347-", u"348-", u"349-", u"350-", u"351-"] if any((u"Ling-3.1-Flash/" + n) in l for l in tree26.split(u"\n"))]
chk(u"msg Ling 347-351 versionados en 4091de8", len(pres) == 5, u"versionados: %s" % u",".join(pres))

# 27. canal sin 352+ (ultimo = 351 mio; sin acuse agnes intermedio)
m352 = glob.glob(CANAL + u"\\35[2-9]-*.md") + glob.glob(CANAL + u"\\4[0-9][0-9]-*.md")
chk(u"canal sin 352+ (ultimo=351 mio)", len(m352) == 0 and len(m351) == 1, u"352+ hallados=%d" % len(m352))

# ---- reporte ----
n_ok = sum(1 for _, ok, _ in results if ok)
n_fail = sum(1 for _, ok, _ in results if not ok)
for name, ok, detail in results:
    print(u"%s %s%s" % (u"PASS" if ok else u"FAIL", name, (u" | " + detail) if detail else u""))
print(u"=== check_v39: %d PASS / %d FAIL ===" % (n_ok, n_fail))
raise SystemExit(0 if n_fail == 0 else 1)
