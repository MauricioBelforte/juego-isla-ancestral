# -*- coding: utf-8 -*-
"""Convierte los rieles D1/I1/G2 de Nemotron a formato checkbox ([ ]/[x] por item)
para que el ciclo del cronómetro pueda seguirlos (causa del 'backlog vacío')."""
import re
import os

BASE = r"DOCUMENTACION\TAREAS-POR-MODELO\Nemotron-3.5-Super-VL"

def convertir(path, id_pattern):
    lineas = open(path, encoding="utf-8").read().split("\n")
    out = []
    cambios = 0
    for l in lineas:
        s = l.rstrip()
        # filas que empiezan con el id del item y NO tienen columna de estado -> agregar [ ]
        if re.match(id_pattern, s) and "[ ]" not in s and "[x]" not in s:
            out.append(s + "  | [ ] |")
            cambios += 1
        else:
            out.append(l)
    if cambios:
        open(path, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
    return cambios

c1 = convertir(os.path.join(BASE, "RIEL-D1-DOC-INTELLIGENCE.md"), r"^\| D1-\d+ \|")
c2 = convertir(os.path.join(BASE, "RIEL-I1-INVESTIGACION.md"), r"^\| I1-\d+ \|")
c3 = convertir(os.path.join(BASE, "RIEL-G2-GATE2-SONDAS-MICRO.md"), r"^\| G2-\d+ \|")
print("checkboxes agregados: D1=%d I1=%d G2=%d" % (c1, c2, c3))
