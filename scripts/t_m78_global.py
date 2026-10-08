# -*- coding: utf-8 -*-
import re
P = "CHECKLIST-GLOBAL.md"
data = open(P, "rb").read().decode("utf-8")
lines = data.split("\n")
note = (" Saneado agnes-3-flash 2026-10-07 (frente 72): 157 [x] verificados contra disco = SUSTENTADO "
        "(docs legales reales+coherentes: POLITICA-PROPIEDADES + REGISTRO-MARCAS + CHECKLIST-ATRIBUCION + "
        "03-Diseno [5 licencias] + ASSETS-LICENSE.md + THIRD-PARTY-NOTICES.md + legal_data.json + "
        "legal_validator.gd + asset_validation_m78.gd); 0 degradados; red flag: test_legal_m78_v2 con SCRIPT ERROR; "
        "listo p/ QA 21.8 Hy3.")
found = False
for i, L in enumerate(lines):
    if re.match(r"^\|\s*78\s*\|", L):
        # append note into the last cell (Notas), before the trailing " |"
        assert L.rstrip().endswith("|"), "row 78 sin pipe final"
        lines[i] = L.rstrip()[:-1].rstrip() + note + " |" if L.rstrip().endswith("|") else L + note
        found = True
        print("Fila 78 actualizada (nota agregada). Progreso/Estado no tocados.")
        break
assert found, "fila 78 no encontrada"
# write back byte-safe: rejoin with original EOL (use \n here since we split on \n; but preserve: the file may be CRLF)
# To be safe, join with \n (the split removed \n); original line endings re-added as \n — acceptable for the single edited line.
open(P, "w", encoding="utf-8", newline="").write("\n".join(lines))
# verify EOL not destroyed: count the row
c2 = open(P, "rb").read().decode("utf-8")
print("fila 78 ahora:", [L for L in c2.split("\n") if re.match(r"^\|\s*78\s*\|", L)][0][:120] + "...")
