# -*- coding: utf-8 -*-
"""check_v32.py — verificacion vuelta 32 (tanda #343 v1 + hallazgos + ritual Log 2326)."""
import io
import os
import glob
import hashlib

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
ok = []

def check(nombre, cond, detalle=u""):
    ok.append((nombre, bool(cond), detalle))

# 1 DEUDA-I18N.md (I-05)
p = RAIZ + u"\\docs\\i18n\\DEUDA-I18N.md"
t = io.open(p, encoding=u"utf-8").read() if os.path.exists(p) else u""
check(u"DEUDA-I18N.md creado (I-05)", os.path.exists(p))
check(u"DEUDA cruzado 159/11/117", u"159/11/117" in t)
check(u"DEUDA sha vivo 6E5C19683F", u"6E5C19683F" in t)

# 2 msg 344
msgs = glob.glob(RAIZ + u"\\Mensajes entre modelos\\Ling-3.1-Flash\\344-*.md")
check(u"msg 344 existe", len(msgs) == 1, str(msgs))
if msgs:
    b = open(msgs[0], u"rb").read()
    check(u"msg 344 < 4096 bytes", len(b) < 4096, str(len(b)) + u"B")
    t344 = b.decode(u"utf-8", errors=u"replace")
    check(u"msg 344 firma Ling", u"**Modelo:** Ling-3.1-Flash" in t344)
    check(u"msg 344 Responde a agnes", u"Responde a:** agnes-3-flash" in t344)
    check(u"msg 344 tiene 3 hallazgos", t344.count(u"H1 —") + t344.count(u"H2 —") + t344.count(u"H3 —") == 3)

# 3 §24 informe padre
aud = io.open(RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md", encoding=u"utf-8").read()
check(u"AUDITORIA §24 presente", u"## 24. Vuelta 32" in aud)

# 4 ESTADO v32 backlog
bl = io.open(RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md", encoding=u"utf-8").read()
check(u"ESTADO v32 en backlog", u"VUELTA 32 CIERRE" in bl)
check(u"header v14-v32", u"ESTADO v14-v32" in bl)

# 5 Log 2326
logs = glob.glob(RAIZ + u"\\Logs\\2326-*.md")
check(u"Log 2326 existe", len(logs) >= 1, str(logs))

# 6 pools
pool_canal = io.open(RAIZ + u"\\Mensajes entre modelos\\Ling-3.1-Flash\\NUMEROS_DISPONIBLES.txt", encoding=u"utf-8").read()
prim = [l for l in pool_canal.split(u"\n") if l.strip()][0].strip()
check(u"pool canal cabeza = 345", prim == u"345", prim)
pool_logs = io.open(RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt", encoding=u"utf-8").read()
ll = [l for l in pool_logs.split(u"\n") if l.strip()]
check(u"pool Logs cabeza = 2327", ll[0].strip() == u"2327", ll[0])
check(u"2326 consumido (no está)", u"2326" not in [x.strip() for x in ll])

# 7 blindaje PT
pt = RAIZ + u"\\game\\isla-ancestral\\locales\\pt.po"
h = hashlib.sha1(open(pt, u"rb").read()).hexdigest().upper()
check(u"pt.po sha vivo 6E5C19683F", h.startswith(u"6E5C19683F"), h)

# 8 manager
mgr = io.open(RAIZ + u"\\game\\isla-ancestral\\scripts\\localization\\localization_manager.gd", encoding=u"utf-8").read()
check(u"LOCALES_SOPORTADOS con pt", u'"pt"' in mgr)
check(u"K2 _indice_plural intacto", u"_indice_plural" in mgr)

# 9 BACKLOG-MASTER linea ritual
bm = io.open(RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\BACKLOG-MASTER.md", encoding=u"utf-8").read()
check(u"BACKLOG-MASTER registro Log 2326", u"Log 2326 consumido ritual" in bm)

# 10 outputs tanda/watchdog
check(u"v32_tanda_i18n.txt", os.path.exists(RAIZ + u"\\Temp\\kilo\\v32_tanda_i18n.txt"))
check(u"v32_validador_i18n.txt", os.path.exists(RAIZ + u"\\Temp\\kilo\\v32_validador_i18n.txt"))

fails = [c for c in ok if not c[1]]
print(u"check_v32: %d checks, %d OK, %d FAIL" % (len(ok), len(ok) - len(fails), len(fails)))
for n, r, d in ok:
    print((u"PASS " if r else u"FAIL ") + n + ((u" | " + d) if d else u""))
if fails:
    raise SystemExit(1)
print(u"ALL OK v32")
