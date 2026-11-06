# -*- coding: utf-8 -*-
"""Persistir sonda i18n v31 (diff game/+scripts/ vs HEAD) en Temp/kilo/v31_sonda_movida.txt."""
import io
import runpy
import contextlib

buf = io.StringIO()
with contextlib.redirect_stdout(buf):
    runpy.run_path("Temp/kilo/sonda_v28_movida.py", run_name="__main__")
io.open("Temp/kilo/v31_sonda_movida.txt", "w", encoding="utf-8", newline="\n").write(buf.getvalue())
print("persistido:", len(buf.getvalue()), "chars en Temp/kilo/v31_sonda_movida.txt")
