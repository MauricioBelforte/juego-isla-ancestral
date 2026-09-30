# -*- coding: utf-8 -*-
import io, os, subprocess
ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
out = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2", "git_status_snapshot.txt")
s = subprocess.check_output(["git", "-C", ROOT, "status", "--short"], stderr=subprocess.STDOUT).decode("utf-8", "replace")
with io.open(out, "w", encoding="utf-8", newline="\n") as f:
    f.write(s)
print("lineas escritas:", len(s.splitlines()))