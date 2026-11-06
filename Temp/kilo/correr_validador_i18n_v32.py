# -*- coding: utf-8 -*-
"""Re-correr watchdog i18n propio v32 (post-descubrimiento sha pt.po cambido) -> Temp/kilo/v32_validador_i18n.txt."""
import io
import subprocess
import sys

p = subprocess.run(
    [sys.executable, "-X", "utf8", "scripts/validar_i18n_integridad.py"],
    capture_output=True, text=True, encoding="utf-8", errors="replace",
)
salida = p.stdout
if p.stderr:
    salida += "\n[STDERR]\n" + p.stderr
io.open("Temp/kilo/v32_validador_i18n.txt", "w", encoding="utf-8", newline="\n").write(salida)
print("exit:", p.returncode, "| chars:", len(salida))
