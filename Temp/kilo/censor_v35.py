# -*- coding: utf-8 -*-
"""Censor riel v35 (metodo git blob sha, corregido en v34): manager + pt.po WT vs HEAD,
HEAD corto, WT status count, msgids pt.po, .mo count. UTF-8."""
import io
import glob
import re
import subprocess

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
MANAGER = u"game/isla-ancestral/scripts/localization/localization_manager.gd"
PT = u"game/isla-ancestral/locales/pt.po"

def git(*args):
    return subprocess.run([u"git", u"-C", ROOT] + list(args), capture_output=True,
                          text=True, encoding=u"utf-8", errors=u"replace").stdout.strip()

head = git(u"rev-parse", u"HEAD")
mgr_wt = git(u"hash-object", MANAGER)
mgr_head = git(u"rev-parse", u"HEAD:" + MANAGER)
pt_wt = git(u"hash-object", PT)
pt_head = git(u"rev-parse", u"HEAD:" + PT)
status = git(u"status", u"--porcelain")
wt_count = len([l for l in status.split(u"\n") if l.strip()])
pt_raw = io.open(ROOT + u"\\" + PT.replace(u"/", u"\\"), encoding=u"utf-8", errors=u"replace").read()
msgids = len(re.findall(r'^msgid "', pt_raw, re.M))
mo = glob.glob(ROOT + u"\\game\\isla-ancestral\\**\\*.mo", recursive=True)
diff_riel = git(u"diff", u"HEAD", u"--stat", u"--", u"game/isla-ancestral/scripts/localization/", u"game/isla-ancestral/locales/", u"game/isla-ancestral/data/localizacion/")

lineas = [
    u"CENSOR RIEL v35 (metodo git blob sha) — " + head[:12],
    u"manager WT=" + mgr_wt[:10] + u" HEAD=" + mgr_head[:10] + u" INTACTO=" + str(mgr_wt == mgr_head),
    u"pt.po   WT=" + pt_wt[:10] + u" HEAD=" + pt_head[:10] + u" INTACTO=" + str(pt_wt == pt_head),
    u"pt.po msgids(regex ^msgid \"): %d" % msgids,
    u".mo en game/ recursivo: %d" % len(mo),
    u"WT status porcelain count: %d" % wt_count,
    u"git diff HEAD --stat riel i18n: %r" % diff_riel,
    u"REFERENCIA v34: manager 047eab5ff111 (071a2f9); pt.po d2b567c48e88; HEAD 13d247158ec9.",
]
txt = u"\n".join(lineas) + u"\n"
io.open(ROOT + u"\\Temp\\kilo\\v35_censor_gitsha.txt", u"w", encoding=u"utf-8", newline=u"\n").write(txt)
print(txt)
