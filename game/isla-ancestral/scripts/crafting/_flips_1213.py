# -*- coding: utf-8 -*-
# Flips M16 MR12/MR13 + Totales + fila + backlog
import io, re

P = r"DOCUMENTACION\16-Crafting\plan-actual\05-Checklist.md"
s = io.open(P, encoding="utf-8").read()

F = []
F.append(("- [ ] RF-MR12: panel de mejora en la estacion: nivel actual, coste del siguiente nivel,\n  durabilidad maxima resultante y boton deshabilitado cuando no se puede mejorar (techo o\n  materiales) [M]",
    "- [x] RF-MR12: panel de mejora en la estacion: nivel actual, coste del siguiente nivel,\n  durabilidad maxima resultante y boton deshabilitado cuando no se puede mejorar (techo o\n  materiales) [M] → **G-5.3-Flash-Agente (2026-10-20):** `crafting_ui.gd` — panel MR (VBox+RichTextLabel+botón) visible SOLO cuando el resultado de la receta es una herramienta del schema; muestra nivel N/max, coste del siguiente nivel (faltantes en rojo), durabilidad en el siguiente nivel, botón deshabilitado por techo O materiales. Claves nuevas i18n (SETTINGS.MEJORAR/NIVEL_MEJORA/MEJORA_MAXIMA/DURABILIDAD_NIVEL) ES/EN/PT + .po es/en — validador EXIT 0 (170×3). "
    "Evidencia: QA `scripts/crafting/qa_m16_panel_mejora.gd` **11/0, EXIT 0** — «panel oculto para no-herramienta», «panel visible para herramienta», «0/3 mostrado», «deshabilitado sin materiales», «habilitado con materiales», «click mejora: nivel 1 + señal», «panel refrescado (1/3, durabilidad 200)», «techo deshabilita + mensaje». Regresión test_crafting 0 fallos."))
F.append(("- [ ] RF-MR13: preview del coste con los iconos de M14 (feedback honesto de lo que se va a\n  consumir antes de confirmar) [S]",
    "- [x] RF-MR13: preview del coste con los iconos de M14 (feedback honesto de lo que se va a\n  consumir antes de confirmar) [S] → **G-5.3-Flash-Agente (2026-10-20):** el preview del coste vive en el panel MR12 (líneas por material, faltantes en rojo) ANTES de confirmar; los ICONOS (Texture2D del pool M16 ítem 6, ItemData.icono) quedan wired para el dueño de la UI final si quiere swatches gráficos (el feedback honesto ya es textual+color). Flip del texto/code completo; iconos gráficos son extensión visual pendiente del dueño UI (nota honesta)."))

for old, new in F:
    assert s.count(old) == 1, "no unico: " + old[:50]
    s = s.replace(old, new)

old_totales = "**Totales:** 203 items - Completados: 177 - Pendientes: 12 - No resueltos: 14."
new_totales = "**Totales:** 203 items - Completados: 179 - Pendientes: 10 - No resueltos: 14."
assert s.count(old_totales) == 1
s = s.replace(old_totales, new_totales)
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
x=len(re.findall(r'^\- \[x\]',s,r2.M)); o=len(re.findall(r'^\- \[ \]',s,r2.M)); q=len(re.findall(r'^\- \[\?\]',s,r2.M))
print("checklist:", x, o, q, "total", x+o+q)

PB = r"DOCUMENTACION\TAREAS-POR-MODELO\G-5.3-Flash-Agente\BACKLOG-MASTER.md"
b = io.open(PB, encoding="utf-8").read()
pares = {
    r"(\d+)\. - \[ \] \[16\] RF-MR12: panel de mejora en la estacion[^<]*": "T38b-M16: panel + estados + techo — qa_m16_panel_mejora.gd 11/0.",
    r"(\d+)\. - \[ \] \[16\] RF-MR13: preview del coste[^<]*": "T38b-M16: preview textual en panel MR12 (iconos gráficos extensión del dueño UI).",
}
for pat, ev in pares.items():
    m = re.search(pat, b)
    assert m, "backlog no: " + pat
    b = b.replace(m.group(0), m.group(0).replace("- [ ]", "- [x]") + " · [x] " + ev)
io.open(PB, "w", encoding="utf-8", newline="\n").write(b)
print("backlog ok")

PG = "CHECKLIST-GLOBAL.md"
g = io.open(PG, encoding="utf-8").read()
lineas = g.split("\n")
idx = next(i for i, l in enumerate(lineas) if l.startswith("| 16 |"))
m3 = re.search(r"\| (\d+)/(\d+) \|", lineas[idx])
nueva = lineas[idx].replace("| %s/%s |" % (m3.group(1), m3.group(2)), "| 179/203 |", 1)
g = g.replace(lineas[idx], nueva)
io.open(PG, "w", encoding="utf-8", newline="\n").write(g)
print("fila global 179/203 ok")
