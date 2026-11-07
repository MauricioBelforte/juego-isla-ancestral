# -*- coding: utf-8 -*-
"""Persistir la salida de la sonda i18n v29 en Temp/kilo/v29_sonda_movida.txt (UTF-8/LF, io.open)."""
import io
import runpy
import contextlib

buf = io.StringIO()
with contextlib.redirect_stdout(buf):
    runpy.run_path("Temp/kilo/sonda_v28_movida.py", run_name="__main__")
io.open("Temp/kilo/v29_sonda_movida.txt", "w", encoding="utf-8", newline="\n").write(buf.getvalue())
print("persistido:", len(buf.getvalue()), "chars en Temp/kilo/v29_sonda_movida.txt")
