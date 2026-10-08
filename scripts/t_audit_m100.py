# -*- coding: utf-8 -*-
import re
P = "DOCUMENTACION/100-Community-Management/plan-actual/05-Checklist.md"
note = (
 "\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-07, volumen M100)\n"
 "M100 auditado: SUSTENTADO, 0 degradaciones. 146 [x] / 0 [?] / 76 [ ]. Verificación contra disco: "
 "los [x] son tareas de gestión/comunidad ABSTRACTAS (crear moderación, reportes, canales de feedback, "
 "recopilar sugerencias, gestionar filtraciones) — no citan archivos falsificables. Los datos de comunidad "
 "EXISTEN en disco: data/support/faq.json + data/community/community_calendar.json. 03-Diseno.md documenta "
 "el sistema (15.8KB). Los report_categories/roadmap/roles.json son NOMBRES DE DISEÑO no creados como "
 "archivos, pero 0 [x] los citan (el conteo por línea: 0). GLOBAL NO tocado (flip/pase = director).\n")
with open(P, "ab") as f:
    f.write(note.encode("utf-8"))
c = open(P, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M100 note appendida; [x]=%d [?]=%d [ ]=%d" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
