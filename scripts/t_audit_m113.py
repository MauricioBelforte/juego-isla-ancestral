# -*- coding: utf-8 -*-
import re
P = "DOCUMENTACION/113-Pruebas-De-Stress/plan-actual/05-Checklist.md"
note = (
 "\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-07, volumen M113)\n"
 "M113 auditado: SUSTENTADO, 0 degradaciones. 102 [x] / 0 [?] / 30 [ ]. Verificación contra disco: "
 "framework de stress en scripts/stress/ (stress_runner.gd, stress_scenario.gd, stress_comparator.gd) + "
 "test_stress_m113 19/0 (re-corrido por agnes). Los [x] son definiciones del framework (StressRunner headless, "
 "StressScenario Setup/Execute/Teardown, p50/p95/max por métrica, reporte JSON). 0 [x] citan perf_base.json "
 "(el baseline está entre los 30 [ ] pendientes). GLOBAL NO tocado (flip/pase = director).\n")
with open(P, "ab") as f:
    f.write(note.encode("utf-8"))
c = open(P, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M113 note appendida; [x]=%d [?]=%d [ ]=%d" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
