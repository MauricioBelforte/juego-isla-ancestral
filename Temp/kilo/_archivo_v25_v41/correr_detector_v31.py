# -*- coding: utf-8 -*-
"""Detector v8.1 v31: subprocess + persistencia UTF-8/LF en Temp/kilo/v31_detector_delta.txt."""
import io
import subprocess
import sys

p = subprocess.run(
    [sys.executable, "-X", "utf8", "scripts/detectar_autocontradiccion.py"],
    capture_output=True, text=True, encoding="utf-8", errors="replace",
)
salida = p.stdout
if p.stderr:
    salida += "\n[STDERR]\n" + p.stderr
io.open("Temp/kilo/v31_detector_delta.txt", "w", encoding="utf-8", newline="\n").write(salida)
print("exit:", p.returncode, "| chars:", len(salida))
