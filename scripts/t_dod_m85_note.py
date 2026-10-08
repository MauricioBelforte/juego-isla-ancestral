# -*- coding: utf-8 -*-
import re
P = "DOCUMENTACION/85-Modelos-3D-Legal/plan-actual/05-Checklist.md"
c = open(P, "rb").read().decode("utf-8")
# 4 "Implementar [x]" con metodo sin codigo -> [ ] INFLADO (trampa 119)
repls = [
 ("- [x] Implementar add_license() y add_credit()",
  "- [ ] Implementar add_license() y add_credit() - INFLADO (agnes-3-flash DoD 2026-10-07): metodo sin codigo en disco, model_license.gd/model_credit.gd ausentes"),
 ("- [x] Implementar generate_credits_text() (formato compacto)",
  "- [ ] Implementar generate_credits_text() (formato compacto) - INFLADO (agnes-3-flash DoD 2026-10-07): metodo sin codigo en disco"),
 ("- [x] Implementar generate_credits_web() (formato detallado)",
  "- [ ] Implementar generate_credits_web() (formato detallado) - INFLADO (agnes-3-flash DoD 2026-10-07): metodo sin codigo en disco"),
 ("- [x] Implementar save_build_credits() para builds",
  "- [ ] Implementar save_build_credits() para builds - INFLADO (agnes-3-flash DoD 2026-10-07): metodo sin codigo en disco"),
]
for old, new in repls:
    assert c.count(old) == 1, "no unico: %s" % old[:40]
    c = c.replace(old, new)
note = (
 "\n## Veredicto DoD (agnes-3-flash, Kilo Code, 2026-10-07, frente s2/61 - profundidad M25)\n"
 "M85 re-auditado con DoD 21.6: **INFLADO** (trampa 119). 99 [x] / 0 [?] / 1 [ ] (antes). Los 4 [x] "
 "\"Implementar X()\" (add_license/add_credit, generate_credits_text, generate_credits_web, save_build_credits) "
 "NO tienen codigo en disco (verifique func X() en todo el proyecto: SIN-CODIGO) y los .gd model_license/"
 "model_credit/model_legal_manager/model_license_validator estan AUSENTES (solo existe audio_license de M84). "
 "Los degrade a [ ] con motivo inline. L119 (guia de arte) es un KnownIssue honesto (diseo en 03-Diseno) - "
 "lo dejo. 07-Resultados AUSENTE. La parte de licenciamiento de MODELOS 3D no esta implementada. "
 "Clasificacion: **INFLADO** (4 [x] -> [ ]) + el resto de los 95 [x] son diseno/documentacion legitimos "
 "(documentados en 03/04-Diseno). GLOBAL no tocado (flip = director).\n")
c += note
open(P, "wb").write(c.encode("utf-8"))
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M85 post: [x]=%d [?]=%d [ ]=%d (antes 99/0/1; 4 [x]->[ ] por INFLADO)" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
