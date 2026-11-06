# -*- coding: utf-8 -*-
"""Censor riel PT + repo (vuelta 34): sha pt.po/manager, msgids, .mo, HEAD, WT count."""
import io
import os
import re
import glob
import hashlib
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
GD = RAIZ + u"\\game\\isla-ancestral"

def sha(p):
    return hashlib.sha1(io.open(p, u"rb").read()).hexdigest().upper()

pt = sha(GD + u"\\locales\\pt.po")
mgr = sha(GD + u"\\scripts\\localization\\localization_manager.gd")
po = io.open(GD + u"\\locales\\pt.po", encoding=u"utf-8", errors=u"replace").read()
n_msgid = len(re.findall(r'msgid "', po))
mo = glob.glob(GD + u"\\**\\*.mo", recursive=True)
head = subprocess.run([u"git", u"rev-parse", u"--short", u"HEAD"], cwd=RAIZ, capture_output=True, text=True).stdout.strip()
wt = subprocess.run([u"git", u"status", u"--porcelain"], cwd=RAIZ, capture_output=True, text=True).stdout.strip()
wt_n = len([l for l in wt.split(u"\n") if l.strip()]) if wt else 0
print(u"pt.po sha=%s (vivo esperado 6E5C19683F...)" % pt[:10])
print(u"manager sha=%s" % mgr[:10])
print(u"pt.po msgids(regex)=%d" % n_msgid)
print(u".mo en repo=%d" % len(mo))
print(u"HEAD=%s" % head)
print(u"WT archivos=%d" % wt_n)
print(u"CRITERIOS: pt_sha_ok=%s | msgids=277 | mo=0" % pt.startswith(u"6E5C19683F"))
