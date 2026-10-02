# -*- coding: utf-8 -*-
"""Analiza los hunks SIN commitear de los archivos compartidos para detectar
autores multiples (conflictos reales para el merge)."""
import io, os, re, subprocess
ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
BASE = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2")
COMPARTIDOS = [
    "DOCUMENTACION/11-BUGS.md",
    "Mensajes entre modelos/ESTADO-PARALELO.md",
    "DOCUMENTACION/GUIA-GODOT/06-registro-errores.md",
    "CHECKLIST-GLOBAL.md",
    "Logs/NUMEROS_DISPONIBLES.txt",
]
PATRONES = [
    (r"atria|Atria|ATRIA", "atria-dawn"),
    (r"hy3|Hy3", "hy3"),
    (r"[Dd]eep[Ss]eek", "deepseek"),
    (r"agnes|Agnes|AGNES", "agnes"),
    (r"[Gg][Ll][Mm]", "glm"),
    (r"[Mm]i[Mm]o", "mimo"),
    (r"[Kk]imi", "kimi"),
    (r"[Gg]emini", "gemini"),
]
rep = os.path.join(BASE, "compartidos_hunks.txt")
with io.open(rep, "w", encoding="utf-8", newline="\n") as out:
    for rel in COMPARTIDOS:
        d = subprocess.check_output(["git", "-C", ROOT, "diff", "--unified=0", "--", rel],
                                    stderr=subprocess.STDOUT).decode("utf-8", "replace")
        adds = [l for l in d.split("\n") if l.startswith("+") and not l.startswith("+++")]
        dels = [l for l in d.split("\n") if l.startswith("-") and not l.startswith("---")]
        out.write("\n=== %s\n" % rel)
        out.write("anadidas: %d  eliminadas: %d\n" % (len(adds), len(dels)))
        texto = "\n".join(adds + dels)
        autores = set()
        for pat, nom in PATRONES:
            if re.search(pat, texto):
                autores.add(nom)
        out.write("menciones de modelos en el diff: %s\n" % sorted(autores))
        # muestra las primeras 6 lineas anadidas
        for l in adds[:6]:
            out.write("  + %s\n" % l[1:150])
print("reporte:", rep)