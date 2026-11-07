# -*- coding: utf-8 -*-
"""CENSOR RIEL v36 (metodo git blob sha — lección v34): manager + pt.po WT vs HEAD.
UTF-8 LF. Salida: Temp/kilo/v36_censor_gitsha.txt"""
import io
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
GD = RAIZ + u"\\game\\isla-ancestral"

def git(*args):
    return subprocess.run([u"git", u"-C", RAIZ] + list(args), capture_output=True,
                          text=True, encoding=u"utf-8", errors=u"replace").stdout.strip()

head = git(u"rev-parse", u"HEAD")
mgr_wt = git(u"hash-object", u"game/isla-ancestral/scripts/localization/localization_manager.gd")
mgr_hd = git(u"rev-parse", u"HEAD:game/isla-ancestral/scripts/localization/localization_manager.gd")
pt_wt = git(u"hash-object", u"game/isla-ancestral/locales/pt.po")
pt_hd = git(u"rev-parse", u"HEAD:game/isla-ancestral/locales/pt.po")
status = git(u"status", u"--porcelain")
n_wt = len([l for l in status.split(u"\n") if l.strip()])
diff_riego = git(u"diff", u"HEAD", u"--", u"game/isla-ancestral/scripts/localization/localization_manager.gd",
                 u"game/isla-ancestral/locales/pt.po", u"game/isla-ancestral/data/localizacion")
msgids = len([l for l in io.open(GD + u"\\locales\\pt.po", encoding=u"utf-8", errors=u"replace").read().split(u"\n")
              if l.startswith(u'msgid "') and l != u'msgid ""'])
mo = subprocess.run([u"powershell", u"-NoProfile", u"-Command",
                     u"(Get-ChildItem -Path '%s' -Recurse -Filter *.mo -ErrorAction SilentlyContinue | Measure-Object).Count" % GD.replace(u"\\", u"\\\\")],
                    capture_output=True, text=True, encoding=u"utf-8", errors=u"replace").stdout.strip()

txt = u"""CENSOR RIEL v36 (metodo git blob sha) — %s
manager WT=%s HEAD=%s INTACTO=%s
pt.po   WT=%s HEAD=%s INTACTO=%s
pt.po msgids(regex ^msgid "): %d
.mo en game/ recursivo: %s
WT status porcelain count: %d
git diff HEAD riel i18n: '%s'
REFERENCIA v35: manager 047eab5ff111; pt.po d2b567c48e88; HEAD 9e08a34c0a06.
""" % (head[:12], mgr_wt[:10], mgr_hd[:10], mgr_wt == mgr_hd,
       pt_wt[:10], pt_hd[:10], pt_wt == pt_hd, msgids, mo, n_wt, diff_riego[:80])
with io.open(RAIZ + u"\\Temp\\kilo\\v36_censor_gitsha.txt", u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(txt)
print(txt)
