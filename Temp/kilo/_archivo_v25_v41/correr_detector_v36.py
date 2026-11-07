# -*- coding: utf-8 -*-
"""Vuelta 36: correr detector autocontradicciones v8.1 (8ª hora) y persistir evidencia en disco."""
import io
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
r = subprocess.run([u"python", u"-X", u"utf8", u"scripts/detectar_autocontradiccion.py"],
                   capture_output=True, text=True, encoding=u"utf-8", errors=u"replace", cwd=RAIZ)
out = u"=== DETECTOR v8.1 8ª hora (vuelta 36) ===\nrc=%d\n--- stdout ---\n%s\n--- stderr ---\n%s" % (r.returncode, r.stdout, r.stderr)
with io.open(RAIZ + u"\\Temp\\kilo\\v36_detector_delta.txt", u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(out)
print(u"rc=%d; salida %d chars -> Temp/kilo/v36_detector_delta.txt" % (r.returncode, len(out)))
