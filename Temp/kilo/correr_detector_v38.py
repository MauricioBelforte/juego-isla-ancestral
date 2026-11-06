# -*- coding: utf-8 -*-
"""Vuelta 38: correr detector autocontradicciones (10ª hora) y persistir evidencia en disco.
Ruta verificada (lección v36): scripts/detectar_autocontradiccion.py."""
import io
import subprocess
import sys

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
p = subprocess.run(
    [sys.executable, "-X", "utf8", "scripts/detectar_autocontradiccion.py"],
    capture_output=True, text=True, encoding="utf-8", errors="replace", cwd=RAIZ,
)
salida = p.stdout
if p.stderr:
    salida += "\n[STDERR]\n" + p.stderr
io.open(RAIZ + r"\Temp\kilo\v38_detector_delta.txt", "w", encoding="utf-8", newline="\n").write(salida)
print("exit:", p.returncode, "| chars:", len(salida))
