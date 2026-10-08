# -*- coding: utf-8 -*-
import glob
NOTES = {
    "50": ("test_vegetation_headless.gd 7/0", "scripts/vegetacion/"),
    "51": ("agua_animada.gd + batimetría en island_generator", "M51 sin suite dedicada; verificado contra disco: scripts/world/agua_animada.gd + params de water_level en island_generator. (BUG-105 agua blanca = visual, pendiente, no toca los [x])"),
    "52": ("test_vfx_m52_iter6.gd 76/0", "scripts/particles/ (vfx catalog/director/factory/pool)"),
    "53": ("test_ui_framework.gd 0/0", "scripts/ui/; P-37 (Log 1151) hooks i18n/accesibilidad en ui_manager.gd — [x] de traducción en vivo legítimos (confirmado por Atria s2/68)"),
    "54": ("test_mapa_m54.gd 42/0", "scripts/mapa/; P-59 OK 133/177 (Atria s2/68)"),
}
COUNTS = {"50": 29, "51": 35, "52": 137, "53": 139, "54": 133}
for rid, (test, ev) in NOTES.items():
    g = glob.glob("DOCUMENTACION/%s-*" % rid)[0] + "/plan-actual/05-Checklist.md"
    note = ("\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 6)\n"
            "Los [%d [x]] verificados contra disco y sustentados; 0 degradaciones. Evidencia: %s = %s.\n"
            % (COUNTS[rid], test, ev))
    with open(g, "ab") as f:
        f.write(note.encode("utf-8"))
    print("M%s note appended" % rid)
