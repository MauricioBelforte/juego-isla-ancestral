# -*- coding: utf-8 -*-
"""Descubrimiento v40: canal, pools, git, latidos flota, Logs nuevos, estado_director mtime."""
import io
import os
import glob
import json
import datetime
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
CANAL = RAIZ + u"\\Mensajes entre modelos\\Ling-3.1-Flash"

def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

def git(*a):
    return subprocess.run([u"git", u"-C", RAIZ] + list(a), capture_output=True,
                          text=True, encoding=u"utf-8", errors=u"replace").stdout.strip()

print(u"=== PASO 1: ultimos 5 msg del canal Ling ===")
msgs = sorted(glob.glob(CANAL + u"\\*.md"))
for m in msgs[-5:]:
    print(u"  ", os.path.basename(m)[:130])
print(u"  (total .md en canal:", len(msgs), u")")

print()
print(u"=== pools cabezas + hora ===")
pc = [x for x in rd(CANAL + u"\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
pl = [x for x in rd(RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()]
print(u"  canal cabeza:", pc[0], u"| Logs cabeza:", pl[0])
print(u"  hora local:", datetime.datetime.now().strftime(u"%Y-%m-%d_%H-%M-%S"), u"UTC:", datetime.datetime.utcnow().strftime(u"%H:%M"))

print()
print(u"=== git ===")
print(u"  HEAD:", git(u"log", u"-1", u"--format=%h %s")[:130])
print(u"  log -5:", git(u"log", u"--oneline", u"-5").replace(u"\n", u" || ")[:300])
print(u"  AUDITORIA ult commit:", git(u"log", u"-1", u"--format=%h %ad %s", u"--date=short", u"--", u"DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")[:130])
print(u"  BACKLOG-01 ult commit:", git(u"log", u"-1", u"--format=%h %s", u"--", u"DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md")[:130])
print(u"  Logs/ ult commit:", git(u"log", u"-1", u"--format=%h %s", u"--", u"Logs")[:130])
mgr = git(u"hash-object", u"game/isla-ancestral/scripts/localization/localization_manager.gd")
ptb = git(u"hash-object", u"game/isla-ancestral/locales/pt.po")
print(u"  riel blobs: manager", mgr[:12], u"pt.po", ptb[:12],
      u"INTACTO" if (mgr == u"047eab5ff111dffdc3f3b48f8241c787e104c0a5" and ptb == u"d2b567c48e88cfa6d9d22d76eaf31804e1e9028c") else u"*** MUTADO ***")
mo = glob.glob(RAIZ + u"\\game\\isla-ancestral\\**\\*.mo", recursive=True)
print(u"  .mo en game/:", len(mo))
st = [l for l in git(u"status", u"--porcelain").split(u"\n") if l.strip()]
print(u"  WT total:", len(st))

print()
print(u"=== estado_director mtime ===")
edp = RAIZ + u"\\Logs\\estado_director.json"
mt = datetime.datetime.fromtimestamp(os.stat(edp).st_mtime)
print(u"  ", mt.strftime(u"%Y-%m-%d %H:%M"))
ed = json.loads(rd(edp))
print(u"  claves:", len(ed))
print(u"  ling_345-351_acusado registrado:", any(u"acus" in k.lower() and u"345" in str(k) + str(ed.get(k, u""))[:50] for k in ed if u"ling" in k.lower()))
for k in sorted(ed):
    if u"ling" in k.lower() and (u"345" in k or u"347" in k or u"349" in k or u"351" in k or u"acus" in k.lower()):
        print(u"   key:", k, u"=", json.dumps(ed[k], ensure_ascii=False)[:200])

print()
print(u"=== latidos flota: .md bajo Mensajes entre modelos/ con mtime >= 19:15 local ===")
base = RAIZ + u"\\Mensajes entre modelos"
res = []
for root, dirs, fns in os.walk(base):
    for fn in fns:
        if fn.endswith(u".md"):
            p = os.path.join(root, fn)
            try:
                ts = os.stat(p).st_mtime
            except OSError:
                continue
            res.append((ts, p))
res.sort(reverse=True)
lim = datetime.datetime(2026, 11, 6, 19, 15).timestamp()
hoy = [r for r in res if r[0] > lim]
print(u"  hallados:", len(hoy))
for ts, p in hoy[:18]:
    print(u"  ", datetime.datetime.fromtimestamp(ts).strftime(u"%H:%M"), u"|", os.path.relpath(p, base)[:115])

print()
print(u"=== Logs/ nuevos (mtime >= 19:00) ===")
for p in sorted(glob.glob(RAIZ + u"\\Logs\\*.md"), key=os.path.getmtime, reverse=True)[:8]:
    ts = os.stat(p).st_mtime
    if ts >= datetime.datetime(2026, 11, 6, 19, 0).timestamp():
        print(u"  ", datetime.datetime.fromtimestamp(ts).strftime(u"%H:%M"), u"|", os.path.basename(p)[:115])
