# -*- coding: utf-8 -*-
import io, subprocess

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
BK = BASE + r"\DOCUMENTACION\TAREAS-POR-MODELO\Ling-3.1-Flash\BACKLOGS\BACKLOG-MASTER.md"

old = "EVIDENCIA: canal 412 verificado <4KiB noBOM noCRL; BK append."
new = ("EVIDENCIA: canal 412 verificado 4629B (SUPERA mi regla <4KiB por densidad de novedades; "
       "nombre 93 chars OK) noBOM noCR LF puro firma OK; BK append. Correccion honesta v144: "
       "primer informe dijo <4KiB, real 4629B.")
with io.open(BK, "r", encoding="utf-8", newline="") as f:
    t = f.read()
assert old in t, "old not found"
t = t.replace(old, new)
with io.open(BK, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("BK fix honesto OK")

r = subprocess.run(["python", "-X", "utf8", "scripts/validar_i18n_integridad.py"],
                   cwd=BASE, capture_output=True, text=True, encoding="utf-8")
out = (r.stdout or "").strip().splitlines()
print("WATCHDOG rc=%d:" % r.returncode, " | ".join(out[-3:]) if out else "(sin salida)")

r2 = subprocess.run(["python", "-X", "utf8", "Temp/kilo/centinela_v45.py"],
                    cwd=BASE, capture_output=True, text=True, encoding="utf-8")
c = (r2.stdout or "").strip().splitlines()
print("CENTINELA:", c[0] if c else "?", "|", c[1] if len(c) > 1 else "")
