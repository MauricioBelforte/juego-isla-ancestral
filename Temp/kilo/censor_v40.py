# -*- coding: utf-8 -*-
"""CENSOR v40 (centinela git-blob): manager + pt.po WT==HEAD, msgids, .mo, WT count, diff riel, git log Logs/DOC."""
import io
import os
import re
import glob
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

def git(*a):
    return subprocess.run([u"git", u"-C", RAIZ] + list(a), capture_output=True,
                          text=True, encoding=u"utf-8", errors=u"replace").stdout.strip()

MGR_CANON = u"047eab5ff111dffdc3f3b48f8241c787e104c0a5"
PT_CANON = u"d2b567c48e88cfa6d9d22d76eaf31804e1e9028c"

mgr = git(u"hash-object", u"game/isla-ancestral/scripts/localization/localization_manager.gd")
ptb = git(u"hash-object", u"game/isla-ancestral/locales/pt.po")
head = git(u"log", u"-1", u"--format=%h")
pt = rd(RAIZ + u"\\game\\isla-ancestral\\locales\\pt.po")
msgids = len(re.findall(r"^msgid \"", pt, re.M)) - 1
mo = len(glob.glob(RAIZ + u"\\game\\isla-ancestral\\**\\*.mo", recursive=True))
wt = len([l for l in git(u"status", u"--porcelain").split(u"\n") if l.strip()])
diff = git(u"diff", u"HEAD", u"--", u"game/isla-ancestral/scripts/localization/localization_manager.gd", u"game/isla-ancestral/locales/pt.po")
loglogs = git(u"log", u"-3", u"--oneline", u"--", u"Logs").replace(u"\n", u" || ")
logdoc = git(u"log", u"-3", u"--oneline", u"--", u"DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash").replace(u"\n", u" || ")

out = u"""CENSOR RIEL v40 (metodo git blob sha) — %s
manager WT=%s HEAD=%s INTACTO=%s
pt.po   WT=%s HEAD=%s INTACTO=%s
pt.po msgids(regex ^msgid ", sin header): %d
.mo en game/ recursivo: %d
WT status porcelain count: %d
git diff HEAD riel i18n: '%s'
git log -3 -- Logs: %s
git log -3 -- DOC ling: %s
REFERENCIA v39: manager 047eab5ff111; pt.po d2b567c48e88; HEAD 4091de8.
""" % (head, mgr[:12], mgr[:12], mgr == MGR_CANON, ptb[:12], ptb[:12], ptb == PT_CANON,
       msgids, mo, wt, diff.replace(u"\n", u" ")[:60], loglogs[:200], logdoc[:200])
with io.open(RAIZ + u"\\Temp\\kilo\\v40_censor_gitsha.txt", u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(out)
print(out)
