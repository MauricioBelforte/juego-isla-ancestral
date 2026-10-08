# -*- coding: utf-8 -*-
import re
P = "DOCUMENTACION/85-Modelos-3D-Legal/plan-actual/05-Checklist.md"
note = (
 "\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-07, volumen M85)\n"
 "M85 auditado: 99 [x] SUSTENTADOS, 0 degradaciones. 99 [x] / 0 [?] / 1 [ ]. Verificación: los [x] son "
 "definiciones/diseño del modelo de licenciamiento de modelos 3D (Resource ModelLicense, enums ModelType/"
 "LicenseScope, Resource ModelCredit, Work-for-Hire vs License) — DISEÑADOS en 03-Diseno.md, no claims de "
 "archivo falsificables. El 1 [ ] SB-02 (L48 'inventario de todas las librerías de stock') = KNOWNISSUE NO "
 "BLOQUEANTE = DEUDA REAL → por regla de Atria (canal/59) NO lo marco [x]: lo dejo [ ] y lo reporto. "
 "GLOBAL/11-BUGS NO tocados (flip/pase = director).\n")
with open(P, "ab") as f:
    f.write(note.encode("utf-8"))
c = open(P, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M85 note appendida; [x]=%d [?]=%d [ ]=%d" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
