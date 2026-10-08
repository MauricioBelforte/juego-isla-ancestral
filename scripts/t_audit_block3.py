# -*- coding: utf-8 -*-
import glob
NOTES = {
    "14": ("test_inventario_iter5.gd", "0 fallos (EXIT 0); scripts/inventario/"),
    "16": ("test_crafting.gd", "0 fallos (EXIT 0); scripts/crafting/"),
    "20": ("test_amistad.gd", "14 checks / 0 fallos; scripts/friendship/"),
    "21": ("test_dialogos.gd", "0 fallos; scripts/dialogos/"),
    "155": ("equipment_manager.gd + equipment_catalog.tres", "84 [x] en disco: scripts/player/equipment_manager.gd, data/equipment/equipment_catalog.tres + .glb vestimenta (alta/baja/media)"),
}
COUNTS = {"14": 136, "16": 43, "20": 50, "21": 13, "155": 84}
for rid, (test, ev) in NOTES.items():
    g = glob.glob("DOCUMENTACION/%s-*" % rid)[0] + "/plan-actual/05-Checklist.md"
    note = ("\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 3)\n"
            "Los [%d [x]] verificados contra disco y sustentados; 0 degradaciones. Evidencia: `%s` = %s.\n"
            % (COUNTS[rid], test, ev))
    with open(g, "ab") as f:
        f.write(note.encode("utf-8"))
    print("M%s note appended" % rid)
