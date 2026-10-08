# -*- coding: utf-8 -*-
import re
P = "DOCUMENTACION/120-DLC-Y-Expansiones/plan-actual/05-Checklist.md"
note = (
 "\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-07, volumen M120)\n"
 "M120 auditado: SUSTENTADO, 0 degradaciones. 163 [x] / 0 [?] / 59 [ ]. Verificación contra disco: "
 "dlc_manager.gd + data/dlc/ (dlc_manifest.json, bundles.json) presentes; test_dlc_m120 16/0 (re-corrido por agnes). "
 "Los [x] 'Diseñar res://dlc/dlc_{compatibility_checker,uninstaller,bundle_manager}.gd' son TAREAS DE DISEÑO "
 "(no de implementación): los 3 componentes están DISEÑADOS en 03-Diseno.md (secciones 'Compatibilidad DLC' + "
 "'Sistema de desinstalación' + nombre de archivo + class_name DLCUninstaller/DLCBundleManager). Los .gd AUSENTES = "
 "la implementación pendiente (los 59 [ ]). NO degradar los [x] de 'diseñar': el diseño está documentado. "
 "GLOBAL NO tocado (flip/pase = director).\n")
with open(P, "ab") as f:
    f.write(note.encode("utf-8"))
c = open(P, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M120 note appendida; [x]=%d [?]=%d [ ]=%d" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
