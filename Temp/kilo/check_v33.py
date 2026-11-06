# -*- coding: utf-8 -*-
"""check_v33: verifica integridad de las escrituras de la vuelta 33 (16 checks)."""
import io
import os
import glob
import hashlib
import json

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

# 1-3. msg 345
m345 = glob.glob(CANAL + u"\\345-*.md")
if m345:
    b = rdb(m345[0]); t = rd(m345[0])
    chk(u"msg345 existe", True, u"%d bytes" % len(b))
    chk(u"msg345 <4KiB", len(b) < 4096, u"%d B" % len(b))
    chk(u"msg345 firma+responde+Log2330", u"Ling-3.1-Flash" in t and u"agnes-3-flash" in t and u"Responde a" in t and u"Log **2330**" in t and u"Log 2328 ritual" not in t)
else:
    chk(u"msg345 existe", False); chk(u"msg345 <4KiB", False); chk(u"msg345 firma+responde+Log2330", False)

# 4-5. pool canal
pool_c = [x for x in rd(CANAL + u"\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
chk(u"pool canal 345 consumido", u"345" not in pool_c)
chk(u"pool canal cabeza 346", pool_c[0].strip() == u"346", pool_c[0])

# 6. AUDITORIA §25 con Log 2330
aud = rd(BK + u"\\..\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")
chk(u"AUDITORIA sec25+Log2330", u"## 25. Vuelta 33" in aud and u"Log **2330**" in aud)

# 7-9. backlog v33
bkv = rd(BK + u"\\01-Backlog-Vueltas-31oct.md")
chk(u"backlog ESTADO v33", u"VUELTA 33 CIERRE" in bkv)
chk(u"backlog header v14-v33", u"ESTADO v14-v33" in bkv)
chk(u"backlog v32 preservado + Log2330 + cabeza2331", u"VUELTA 32 CIERRE" in bkv and u"**Log 2330**" in bkv and u"Logs cabeza **2331**" in bkv)

# 10. Log 2330 existe
logs = glob.glob(RAIZ + u"\\Logs\\2330-*.md")
chk(u"log 2330 existe", len(logs) == 1, os.path.basename(logs[0]) if logs else u"")

# 11-12. pool Logs: 2330 borrado, cabeza 2331
pool_l = [x for x in rd(RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
chk(u"pool Logs 2330 borrado", u"2330" not in pool_l)
chk(u"pool Logs cabeza 2331", pool_l[0].strip() == u"2331", pool_l[0])

# 13. BACKLOG-MASTER linea 2330
bm = BK + u"\\BACKLOG-MASTER.md"
chk(u"BACKLOG-MASTER 2330", os.path.exists(bm) and u"2330" in rd(bm))

# 14. pt.po sha intacto (riel PT)
sha = hashlib.sha1(rdb(GD + u"\\locales\\pt.po")).hexdigest().upper()
chk(u"pt.po sha 6E5C intacto", sha.startswith(u"6E5C19683F"), sha[:10])

# 15. 0 .mo en repo
mo2 = glob.glob(GD + u"\\**\\*.mo", recursive=True)
chk(u"0 .mo en game/ recursivo", len(mo2) == 0, u"hallados=%d" % len(mo2))

# 16. M157/M87 Totales intactos + estado_director + evidencia fix
m157 = rd(RAIZ + u"\\DOCUMENTACION\\157-Medios-De-Transporte\\plan-actual\\05-Checklist.md")
m87 = rd(RAIZ + u"\\DOCUMENTACION\\87-Localizacion\\plan-actual\\05-Checklist.md")
chk(u"M157 Totales 132 intacto", u"132 items" in m157 and u"Completados: 8" in m157)
chk(u"M87 Totales 140 intacto", u"140" in m87 and u"135" in m87)
ed = json.loads(rd(RAIZ + u"\\Logs\\estado_director.json"))
chk(u"estado_director 391 + bug_156", len(ed) == 391 and u"bug_156_i18n_json" in ed, u"%d claves" % len(ed))
fx = rd(RAIZ + u"\\Temp\\kilo\\v33_fix_mo.txt")
chk(u"fix_mo round-trip PASS", u"259/259 OK" in fx and u"272/272 OK" in fx and fx.count(u"-> PASS") >= 3)

# ---- reporte ----
n_ok = sum(1 for _, ok, _ in results if ok)
n_fail = sum(1 for _, ok, _ in results if not ok)
for name, ok, detail in results:
    print(u"%s %s%s" % (u"PASS" if ok else u"FAIL", name, (u" | " + detail) if detail else u""))
print(u"=== check_v33: %d PASS / %d FAIL ===" % (n_ok, n_fail))
raise SystemExit(0 if n_fail == 0 else 1)
