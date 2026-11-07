# -*- coding: utf-8 -*-
"""Correr watchdog oficial v41 y guardar evidencia (header + rc + stdout + stderr)."""
import io
import sys
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

p = subprocess.run([sys.executable, u"-X", u"utf8", u"scripts/validar_i18n_integridad.py"],
                   cwd=RAIZ, capture_output=True, text=True, encoding=u"utf-8", errors=u"replace")
out = u"=== WATCHDOG i18n oficial v41 (scripts/validar_i18n_integridad.py) ===\nrc=%d\n--- stdout ---\n%s\n--- stderr ---\n%s" % (
    p.returncode, p.stdout, p.stderr)
with io.open(RAIZ + u"\\Temp\\kilo\\v41_validador_i18n.txt", u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(out)
print(out[:1800])
