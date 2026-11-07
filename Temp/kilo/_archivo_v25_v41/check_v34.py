# -*- coding: utf-8 -*-
"""check_v34: verifica integridad de las escrituras de la vuelta 34 (22 checks).
Descubre N del log y msg via glob (robusto a drift de pool entre escritura y check)."""
import io
import os
import glob
import hashlib
import json
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
GD = RAIZ + u"\\game\\isla-ancestral"
CANAL = RAIZ + u"\\Mensajes entre modelos\\Ling-3.1-Flash"
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS"

def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

def rdb(p):
    return io.open(p, u"rb").read()

results = []
def chk(name, ok, detail=u""):
    results.append((name, bool(ok), detail))

# ---- descubrir msg 346 y log vuelta34 ----
m346 = glob.glob(CANAL + u"\\346-*.md")
logv34 = glob.glob(RAIZ + u"\\Logs\\*-vuelta34-*.md")
NLOG = logv34[0].split(u"\\")[-1].split(u"-")[0] if logv34 else u"?"

# 1-3. msg 346
if m346:
    b = rdb(m346[0]); t = rd(m346[0])
    chk(u"msg346 existe", True, u"%d bytes" % len(b))
    chk(u"msg346 <4KiB", len(b) < 4096, u"%d B" % len(b))
    chk(u"msg346 firma+responde+vuelta34",
        u"Ling-3.1-Flash" in t and u"agnes-3-flash" in t and u"Responde a" in t
        and (u"VUELTA 34" in t or u"vuelta 34" in t))
else:
    chk(u"msg346 existe", False); chk(u"msg346 <4KiB", False); chk(u"msg346 firma+responde+vuelta34", False)

# 4-5. pool canal
pool_c = [x for x in rd(CANAL + u"\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
chk(u"pool canal 346 consumido", u"346" not in pool_c)
chk(u"pool canal cabeza 347", pool_c[0].strip() == u"347", pool_c[0])

# 6. AUDITORIA §26 con Log N
aud = rd(BK + u"\\..\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")
chk(u"AUDITORIA sec26+LogN", (u"## 26." in aud) and ((u"Log **%s**" % NLOG) in aud or (u"Log %s" % NLOG) in aud), u"N=%s" % NLOG)

# 7-9. backlog v34
bkv = rd(BK + u"\\01-Backlog-Vueltas-31oct.md")
chk(u"backlog ESTADO v34", u"VUELTA 34 CIERRE" in bkv)
chk(u"backlog header v14-v34", u"ESTADO v14-v34" in bkv)
chk(u"backlog v33 preservado + LogN + cabeza", u"VUELTA 33 CIERRE" in bkv and (u"**Log %s**" % NLOG) in bkv)

# 10. Log vuelta34 existe
chk(u"log vuelta34 existe", len(logv34) == 1, os.path.basename(logv34[0]) if logv34 else u"")

# 11-12. pool Logs: NLOG borrado, cabeza NLOG+1
pool_l = [x for x in rd(RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
chk(u"pool Logs NLOG borrado", NLOG not in pool_l, u"N=%s" % NLOG)
chk(u"pool Logs cabeza NLOG+1", pool_l[0].strip() == str(int(NLOG) + 1) if NLOG.isdigit() else False, pool_l[0] if pool_l else u"")

# 13. BACKLOG-MASTER linea NLOG
bm = BK + u"\\BACKLOG-MASTER.md"
chk(u"BACKLOG-MASTER NLOG", os.path.exists(bm) and NLOG in rd(bm))

# 14-15. blobs git intactos (metodo correcto centinela)
def git(*args):
    return subprocess.run([u"git", u"-C", RAIZ] + list(args), capture_output=True,
                          text=True, encoding=u"utf-8", errors=u"replace").stdout.strip()
mgr = git(u"hash-object", u"game/isla-ancestral/scripts/localization/localization_manager.gd")
ptb = git(u"hash-object", u"game/isla-ancestral/locales/pt.po")
chk(u"manager blob 047eab5ff111 intacto", mgr == u"047eab5ff111dffdc3f3b48f8241c787e104c0a5", mgr[:10])
chk(u"pt.po blob d2b567c48e88 intacto", ptb == u"d2b567c48e88cfa6d9d22d76eaf31804e1e9028c", ptb[:10])

# 16. 0 .mo en repo
mo2 = glob.glob(GD + u"\\**\\*.mo", recursive=True)
chk(u"0 .mo en game/ recursivo", len(mo2) == 0, u"hallados=%d" % len(mo2))

# 17. M157/M87 Totales intactos + estado_director
m157 = rd(RAIZ + u"\\DOCUMENTACION\\157-Medios-De-Transporte\\plan-actual\\05-Checklist.md")
m87 = rd(RAIZ + u"\\DOCUMENTACION\\87-Localizacion\\plan-actual\\05-Checklist.md")
chk(u"M157 Totales 132 intacto", u"132 items" in m157 and u"Completados: 8" in m157)
chk(u"M87 Totales 140 intacto", u"140" in m87 and u"135" in m87)
ed = json.loads(rd(RAIZ + u"\\Logs\\estado_director.json"))
chk(u"estado_director 391 + bug_156", len(ed) == 391 and u"bug_156_i18n_json" in ed, u"%d claves" % len(ed))

# 18-19. evidencia v34 disco (censor corregido + watchdog + detector)
cen = rd(RAIZ + u"\\Temp\\kilo\\v34_censor_gitsha.txt")
chk(u"censor gitsha INTACTO True", u"manager INTACTO (WT==HEAD): True" in cen and u"pt.po INTACTO (WT==HEAD): True" in cen)
val = rd(RAIZ + u"\\Temp\\kilo\\v34_validador_i18n.txt")
chk(u"validador v34 LIMPIO", u"LIMPIO" in val and u"170 claves" in val and u"comunes: 159" in val)
det = rd(RAIZ + u"\\Temp\\kilo\\v34_detector_delta.txt")
chk(u"detector v34 82KB + invariantes", len(det) > 80000 and u"GRIS diseno step-5 14oct: 209" in det and u"FP: 4" in det, u"%d chars" % len(det))

# ---- reporte ----
n_ok = sum(1 for _, ok, _ in results if ok)
n_fail = sum(1 for _, ok, _ in results if not ok)
for name, ok, detail in results:
    print(u"%s %s%s" % (u"PASS" if ok else u"FAIL", name, (u" | " + detail) if detail else u""))
print(u"=== check_v34: %d PASS / %d FAIL ===" % (n_ok, n_fail))
raise SystemExit(0 if n_fail == 0 else 1)
