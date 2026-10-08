# -*- coding: utf-8 -*-
import re
P = "DOCUMENTACION/113-Pruebas-De-Stress/plan-actual/05-Checklist.md"
note = (
 "\n## Veredicto DoD (agnes-3-flash, Kilo Code, 2026-10-07, frente s2/61 - profundidad M25)\n"
 "M113 re-auditado con DoD 21.6: **DEUDA REAL** (no flip, no inflado). Conteo 102 [x] / 0 [?] / 30 [ ] es "
 "honesto, pero DoD incompleto:\n"
 "- 04-Codigo.md cita `perf_base.json` (baseline versionado) que NO existe en disco.\n"
 "- 07-Resultados-Testings.md AUSENTE.\n"
 "- 30 [ ] pendientes (metricas a definir: fisica < 5 ms, culling, prueba camara rapida/sobrevuelo, etc.).\n"
 "- Positivo: framework de stress EN DISCO (stress_runner.gd, stress_scenario.gd, stress_comparator.gd) + "
 "test_stress_m113 **19/0** (re-corrí yo). El framework base está bien construido; falta la validación de "
 "estrés (baselines/métricas/corridas) + 07.\n"
 "Clasificacion: **DEUDA REAL** (implementacion de la fase de validación de stress), no INFLADO. GLOBAL no "
 "tocado (flip = director).\n")
with open(P, "ab") as f:
    f.write(note.encode("utf-8"))
c = open(P, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M113 veredicto append; [x]=%d [?]=%d [ ]=%d (intacto)" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
