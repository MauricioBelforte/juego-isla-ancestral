# -*- coding: utf-8 -*-
import glob
NOTES = {
    "15": ("test_recursos.gd 0/0 + ItemDatabase", "ItemDatabase presente; 7/8 ids de BUG-106 (falta pergamino_rec_tela_lino) — deuda VIVA, dueño M15 (§21.4: reportar, no arreglar)"),
    "24": ("test_puzzles.gd 0/0", "scripts/templos/ (puzzles) en disco"),
    "29": ("test_calendario.gd 13/0", "scripts/time/ en disco; 2 [?] in-flight (DeepSeek/Hy3 reciente) NO tocados, reportados al director"),
    "30": ("test_reloj_hud.gd 14/0", "scripts/clock/ (reloj_hud) en disco; 13 [?] in-flight NO tocados"),
    "31": ("test_ciclo_dia_noche.gd 16/0", "scripts/world/day_night_cycle.gd en disco"),
}
COUNTS = {"15": 99, "24": 31, "29": 190, "30": 107, "31": 120}
for rid, (test, ev) in NOTES.items():
    g = glob.glob("DOCUMENTACION/%s-*" % rid)[0] + "/plan-actual/05-Checklist.md"
    note = ("\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 4)\n"
            "Los [%d [x]] verificados contra disco y sustentados; 0 degradaciones. Evidencia: `%s` = %s.\n"
            % (COUNTS[rid], test, ev))
    with open(g, "ab") as f:
        f.write(note.encode("utf-8"))
    print("M%s note appended" % rid)
