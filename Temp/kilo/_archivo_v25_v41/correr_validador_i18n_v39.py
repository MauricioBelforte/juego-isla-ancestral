# -*- coding: utf-8 -*-
"""Vuelta 39: correr watchdog oficial validar_i18n_integridad.py y persistir evidencia en disco."""
import io
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
r = subprocess.run([u"python", u"-X", u"utf8", u"scripts/validar_i18n_integridad.py"],
                   capture_output=True, text=True, encoding=u"utf-8", errors=u"replace", cwd=RAIZ)
out = u"=== WATCHDOG i18n oficial v39 (scripts/validar_i18n_integridad.py) ===\nrc=%d\n--- stdout ---\n%s\n--- stderr ---\n%s" % (r.returncode, r.stdout, r.stderr)
with io.open(RAIZ + u"\\Temp\\kilo\\v39_validador_i18n.txt", u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(out)
print(u"rc=%d; salida %d chars -> Temp/kilo/v39_validador_i18n.txt" % (r.returncode, len(out)))
