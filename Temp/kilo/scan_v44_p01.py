# -*- coding: utf-8 -*-
"""Cron v44 PASO 0 (estado_director.json) + PASO 1 (ultimos 3 del canal Ling). io.open UTF-8."""
import io, os, glob, json, datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

# ---------- PASO 0: estado_director.json ----------
p = os.path.join(RAIZ, u"Logs", u"estado_director.json")
mt = datetime.datetime.fromtimestamp(os.stat(p).st_mtime)
ed = json.loads(io.open(p, encoding=u"utf-8").read())
print(u"ESTADO_DIRECTOR: claves=%d mtime=%s" % (len(ed), mt.isoformat()))
for k in [u"ling", u"pt", u"go", u"bug152", u"gemelos", u"nemotron", u"hy3",
          u"ling_345-351_acusado", u"crons_v3_reactivados_7nov", u"sello_14_m64", u"msg_354_ling_v42"]:
    if k in ed:
        s = json.dumps(ed[k], ensure_ascii=False)
        print(u"  [%s] = %s" % (k, s[:200]))
    else:
        print(u"  [%s] = AUSENTE" % k)
rec = [k for k in ed if isinstance(ed[k], dict) and str(ed[k].get(u"fecha", u"")).startswith(u"2026-11-07")]
print(u"claves con fecha 2026-11-07:", len(rec), rec[:12])
rec2 = [k for k in ed if isinstance(ed[k], dict) and str(ed[k].get(u"fecha", u"")).startswith(u"2026-11-06")]
print(u"claves con fecha 2026-11-06:", len(rec2))

# ---------- PASO 1: canal Ling, ultimos 3 ----------
canal = os.path.join(RAIZ, u"Mensajes entre modelos", u"Ling-3.1-Flash")
mds = sorted(glob.glob(canal + u"\\*.md"))
print(u"\nCANAL Ling: total .md =", len(mds))
for f in mds[-3:]:
    t = io.open(f, encoding=u"utf-8", errors=u"replace").read()
    primera = t.split(u"\n")[0][:110]
    print(u"  ", os.path.basename(f), u"|", primera)
    if os.path.basename(f) >= u"356-":
        print(u"    --- CUERPO COMPLETO (mensaje nuevo del director, regla T-19) ---")
        print(t[:2600])
