# -*- coding: utf-8 -*-
import re
P = "DOCUMENTACION/120-DLC-Y-Expansiones/plan-actual/05-Checklist.md"
note = (
 "\n## Veredicto DoD (agnes-3-flash, Kilo Code, 2026-10-07, frente s2/61 - profundidad M25)\n"
 "M120 re-auditado con DoD 21.6 (no solo conteo): **DEUDA REAL** (no flip, no inflado). Conteo 163 [x] / "
 "0 [?] / 59 [ ] es honesto, pero el DoD NO esta completo:\n"
 "- 04-Codigo.md lista 3 archivos .gd que NO existen en disco: dlc_bundle_manager.gd, dlc_compatibility_checker.gd, "
 "dlc_uninstaller.gd (scripts/dlc/ solo trae dlc_manager.gd + sincronizar_dlc.gd + test_dlc_m120.gd). Son los 3 "
 "\"Diseñar [x]\": el DISENO esta documentado en 03-Diseno (subyacente), pero la IMPLEMENTACION (.gd) falta.\n"
 "- 07-Resultados-Testings.md AUSENTE (no hay doc de resultados de testing).\n"
 "- 59 [ ] pendientes (estrategia de separacion base/DLC, que queda en base, diseno de nuevas ruinas, etc.).\n"
 "- Positivo: dlc_manager.gd existe + test_dlc_m120 16/0 (re-corrí yo); data/dlc/ (manifest, bundles) en disco.\n"
 "Clasificacion: **DEUDA REAL** (implementacion pendiente), no INFLADO (los [x] de diseno son legitimos y "
 "documentados). Dejar M120 en 166 (no flip) con nota de deuda + dueno = implementador M120. GLOBAL no tocado (flip = director).\n")
with open(P, "ab") as f:
    f.write(note.encode("utf-8"))
c = open(P, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M120 veredicto append; [x]=%d [?]=%d [ ]=%d (intacto)" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
