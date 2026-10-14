# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

# Los 4 que faltan: matchean por texto exacto corto
fix = [
 ("Luna esf\u00e9rica con textura de fases [S]", "AUDIT 2026-10-14 (step-5-kilocode): luz DirectionalLight3D sin mesh; textura de fases de M45 (K.2)."),
 ("Validaci\u00f3n de rangos de curvas en dev mode", "AUDIT 2026-10-14 (step-5-kilocode): test_curvas_luz.gd EXISTE (validacion en CI); M110 dev tools sin implementar. Parcial. Dueno M110."),
 ("M17 Construcci\u00f3n: faroles sin red", "AUDIT 2026-10-14 (step-5-kilocode): M17 sin faroles; puzzle farol_cargado en data/cadenas (M23). Dueno M17/M18."),
 ("Murales luminosos en ruinas (M25/M148) [C]", "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de murales luminosos; duenos M25/M148."),
]

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[\?\]", l):
        continue
    if "AUDIT 2026-10-14" in l:
        continue
    for clave, nota in fix:
        if clave in l:
            lines[i] = l.rstrip() + " | " + nota
            n += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (finales):", n)
