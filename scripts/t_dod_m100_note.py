# -*- coding: utf-8 -*-
import re
P = "DOCUMENTACION/100-Community-Management/plan-actual/05-Checklist.md"
note = (
 "\n## Veredicto DoD (agnes-3-flash, Kilo Code, 2026-10-07, frente s2/61 - profundidad M25)\n"
 "M100 re-auditado con DoD 21.6: **DEUDA REAL** (no flip). Conteo 146 [x] / 0 [?] / 76 [ ] es honesto, "
 "pero DoD incompleto:\n"
 "- 04-Codigo.md cita 3 datos que NO existen en disco: report_categories.json, roadmap.json, roles.json.\n"
 "- 07-Resultados-Testings.md AUSENTE.\n"
 "- 76 [ ] pendientes.\n"
 "- Positivo: scripts/community/community_manager.gd existe + test_community_m100 **8/0** (re-corrí yo) + "
 "data/support/faq.json + data/community/community_calendar.json en disco.\n"
 "Los [x] son tareas de gestion de comunidad ABSTRACTAS (moderacion, reportes, feedback, filtraciones) — "
 "no INFLADO (no citan archivos falsos). Clasificacion: **DEUDA REAL** (implementacion de datos 3 JSON + "
 "76 [ ]), no flip. GLOBAL no tocado (flip = director).\n")
with open(P, "ab") as f:
    f.write(note.encode("utf-8"))
c = open(P, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M100 veredicto append; [x]=%d [?]=%d [ ]=%d (intacto)" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
