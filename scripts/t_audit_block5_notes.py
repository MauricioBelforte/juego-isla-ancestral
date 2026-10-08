# -*- coding: utf-8 -*-
import glob
NOTES = {
    "33": ("test_farm.gd 0/0", "scripts/farm/ (farm_service, farm_state_store, farm_tool_controller) + data/balance/farming.json"),
    "34": ("test_fishing.gd 0/0", "scripts/fishing/"),
    "35": ("test_mineria.gd 0/0", "scripts/mineria/"),
    "36": ("test_fauna.gd 0/0", "36 .glb fauna en assets/; 4 [x] de asset correctamente etiquetados 'dueño M45 / KnownIssue no bloqueante' (no entrega falsa); JabaliNPC + JabaliAdultoNPC presentes en main_island.tscn"),
    "41": ("test_musica_m41.gd 14/0 (sistema musical OK)", "2 [x] DEGRADADOS a [?] (bloque 5, regla nueva Atria s2/49): 'Temas de lugar especial: 6' y 'Variaciones +24' citan audio entregado pero HAY 0 archivos de audio (.ogg/.wav) en el proyecto entero (constatado M43). Los 19 [x] de specs P# y el sistema musical se sostienen; solo las 2 cuentas de assets entregados caen a [?]"),
}
COUNTS = {"33": 67, "34": 84, "35": 60, "36": 226, "41": 59}
for rid, (test, ev) in NOTES.items():
    g = glob.glob("DOCUMENTACION/%s-*" % rid)[0] + "/plan-actual/05-Checklist.md"
    note = ("\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 5)\n"
            "[x] auditados contra disco (bloq 5). %s Evidencia: `%s` = %s.\n"
            % ({"33": "Sustentado, 0 degradaciones. ", "34": "Sustentado, 0 degradaciones. ",
                "35": "Sustentado, 0 degradaciones. ", "36": "Sustentado, 0 degradaciones. ",
                "41": "Sustentado (sistema+specs) pero 2 [x] degradados. "}[rid], test, ev))
    with open(g, "ab") as f:
        f.write(note.encode("utf-8"))
    print("M%s note appended" % rid)
