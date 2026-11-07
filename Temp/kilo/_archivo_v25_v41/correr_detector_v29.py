# -*- coding: utf-8 -*-
"""Correr el detector v8.1 como subproceso y persistir su salida en Temp/kilo/v29_detector_delta.txt (UTF-8/LF)."""
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
io.open("Temp/kilo/v29_detector_delta.txt", "w", encoding="utf-8", newline="\n").write(salida)
print("exit:", p.returncode, "| chars:", len(salida))
