# -*- coding: utf-8 -*-
"""Re-correr watchdog i18n oficial (scripts/validar_i18n_integridad.py) v35 -> Temp/kilo/v35_validador_i18n.txt."""
import io
import subprocess
import sys

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
p = subprocess.run(
    [sys.executable, "-X", "utf8", "scripts/validar_i18n_integridad.py"],
    capture_output=True, text=True, encoding="utf-8", errors="replace", cwd=ROOT,
)
salida = p.stdout
if p.stderr:
    salida += "\n[STDERR]\n" + p.stderr
io.open(ROOT + r"\Temp\kilo\v35_validador_i18n.txt", "w", encoding="utf-8", newline="\n").write(salida)
print("exit:", p.returncode, "| chars:", len(salida))
