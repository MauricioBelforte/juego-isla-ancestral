# -*- coding: utf-8 -*-
"""Correr detector de autocontradicciones v40; guardar salida CRUDA (sin header wrapper)."""
import io
import sys
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

p = subprocess.run([sys.executable, u"-X", u"utf8", u"scripts/detectar_autocontradiccion.py"],
                   cwd=RAIZ, capture_output=True, text=True, encoding=u"utf-8", errors=u"replace")
with io.open(RAIZ + u"\\Temp\\kilo\\v40_detector_delta.txt", u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(p.stdout)
print(u"rc=%d stdout_chars=%d stderr_chars=%d" % (p.returncode, len(p.stdout), len(p.stderr)))
print(p.stdout[:900])
if p.stderr:
    print(u"--- stderr ---")
    print(p.stderr[:500])
