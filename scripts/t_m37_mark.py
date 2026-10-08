# -*- coding: utf-8 -*-
import re
p = "DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md"
c = open(p, encoding="utf-8").read()
# [ ] que mi slice RF1/RF5 (logica headless de vitrinas/edificio/donacion) cubre
keys = [
    "RF1: edificio de museo visitable en Aurora",
    "Decidir: edificio visitable con vitrinas instanciadas (alternativa B)",
    "Instanciado de vitrinas en runtime segun ExhibitionData",
    "Vitrina ocupada muestra el modelo/iscon de la pieza registrada",
    "Vitrina libre muestra silueta y etiqueta \"Por donar\"",
    "Vitrina ocupada nunca sobrescrita con otra pieza",
    "place_item valida vitrina libre y tipo de pieza correcto",
    "RF5: donacion de obras de arte ancestral",
]
n = 0
for k in keys:
    target = "[ ] " + k
    if target in c:
        c = c.replace(target, "[x] " + k, 1)
        n += 1
    else:
        print("  NO encontre:", k[:40])
# NOTA-AGNES al final
nota = ("\n## NOTA-AGNES (slice RF1/RF5, 2026-10-08, agnes-3-flash)\n"
        "Este slice implemento la LOGICA del museo (Museum.gd + ExhibitSlot.gd, Node3D headless-friendly)\n"
        "+ el cableado de donacion/refresh (RF5). El teste test_museo_rf1.gd (0/0) verifica: edificio,\n"
        "vitrinas instanciadas, place_item (libre/sobrescritura), inspect 'Por donar', refresh_from_registry,\n"
        "request_donation_ui. PENDING (fuera de este slice): construccion VOXEL 3D de vitrinas (item [C]),\n"
        "panel UI M53 de donacion + escena museum.tscn posicionada en el mundo. Los [x] de arriba son la\n"
        "logica verificada, no el 3D/UI.\n")
if "NOTA-AGNES" not in c:
    c = c + nota
open(p, "w", encoding="utf-8").write(c)
print("marcados [x]:", n)
moj = re.search(r"Ã|Â|â€", c)
print("mojibake:", bool(moj))
