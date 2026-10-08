# -*- coding: utf-8 -*-
import glob

NOTES = {
    "162": ("test_contextual_dialogue_m162.gd", "0 fallos (EXIT 0); scripts/dialogos/ + data/dialogues/contextual/*.json"),
    "164": ("test_combat_m164_atria.gd", "0 fallos (EXIT 0); scripts/combat/ (combat_island_system, enemy/boss_data, island_zone, gem_save_provider)"),
    "63": ("test_stream_m63_iter6.gd", "42 checks / 0 fallos; scripts/stream/ (pantalla_carga, LRU chunks, load_threaded); 45 [x] con .gd verificados en disco (no solo sello Hy3)"),
    "26": ("test_templo_m26.gd", "92 checks / 0 fallos (rojo de parse-JSON inyectado esperado); scripts/templos/ (templo_flow, puzzle_*, templo_validadores)"),
}

for rid, (test, ev) in NOTES.items():
    g = glob.glob("DOCUMENTACION/%s-*" % rid)[0] + "/plan-actual/05-Checklist.md"
    note = ("\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06)\n"
            "Auditoría del bloque 2 (T-D7): los [%d [x]] se verificaron contra disco y sustentados; 0 degradaciones. "
            "Evidencia: `%s` = %s.\n" % (
                {"162": 80, "164": 70, "63": 67, "26": 62}[rid], test, ev))
    # binary append
    with open(g, "ab") as f:
        f.write(note.encode("utf-8"))
    print("M%s note appended to 05-Checklist.md" % rid)
