# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/34-Pesca/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 31: "AUDIT 2026-10-13 (step-5-kilocode): idem item 20/23 — el dato de pieza disponible se calcula en M37/M53; M34 no notifica.",
 32: "AUDIT 2026-10-13 (step-5-kilocode): los nombres ya son claves localizables — data/fishing/fishing.json usa nombre_i18n='PESCA.PEZ_SARDINA' etc. y fishing_manager.gd L109 las carga (nombre_es como fallback); el consumo de M86/M57 no esta verificado.",
 33: "AUDIT 2026-10-13 (step-5-kilocode): existe el estado LANZANDO (fishing_session.gd L13) pero no hay senal especifica de lanzamiento ni samples (M42/M52).",
 34: "AUDIT 2026-10-13 (step-5-kilocode): sin flotador fisico (item 17/18) no hay evento de splash; samples de M42/M52.",
 35: "AUDIT 2026-10-13 (step-5-kilocode): picada_iniciada se emite (fishing_manager.gd L206) como contrato; los samples de sonido son de M42.",
 36: "AUDIT 2026-10-13 (step-5-kilocode): captura_fallida('el_pez_se_fue') L227 es el contrato; samples de M42.",
 37: "AUDIT 2026-10-13 (step-5-kilocode): captura_exitosa(pez, tamano) es el contrato; sample festivo de M42.",
 38: "AUDIT 2026-10-13 (step-5-kilocode): sin VFX de ondulacion; el unico marcador es visible=true (fishing_spot.gd L38-39) — stub.",
 39: "AUDIT 2026-10-13 (step-5-kilocode): sin VFX de burbujas en spots activos (M52).",
 40: "AUDIT 2026-10-13 (step-5-kilocode): el dato de rareza existe (peso_rareza, UMBRAL_RARO=0.08 en fishing_manager.gd L408) pero no hay brillo al caer (M52).",
}

idx = 0
checked = 0
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[\?\]", l):
        n = idx + 1
        if n in notas and "AUDIT 2026-10-13" not in l:
            lines[i] = l.rstrip() + " | " + notas[n]
            checked += 1
        idx += 1

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (M34 b4):", checked)
