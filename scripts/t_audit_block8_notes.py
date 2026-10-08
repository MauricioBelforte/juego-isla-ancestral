# -*- coding: utf-8 -*-
import os
BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
DOC = os.path.join(BASE, "DOCUMENTACION")
NAMES = {"59": "59-Guardado", "62": "62-Memoria", "47": "47-Texturas-Y-Materiales", "76": "76-Multijugador"}
NOTES = {
    "59": ("Sustentado, 0 degradaciones.", "test_autosave_m59.gd 0/0", "scripts/saving/ (save_snapshot.gd + save_writer.gd re-verificados contra el codigo actual post-fix de DeepSeek BUG-108..115); 1 [?] externo"),
    "62": ("Sustentado, 0 degradaciones.", "test_memoria_m62_iter5.gd 60/0", "scripts/rendimiento/memoria/; verificado contra disco"),
    "47": ("Sustentado, 0 degradaciones.", "test_materiales_m47.gd 17/0", "scripts/arte3d/; el mas bajo documental del tablero, sin agente activo"),
    "76": ("3 [x] degradados (bloqueado por producto).", "mp_contract.json AUSENTE", "M76 bloqueado single-player v1 (patron M77): 3 [x] -> [?] (mp_contract.json x2 + reporte futuro). 1 [x] queda (documentar decision single-player). Reportado al director"),
}
for rid, (ver, test, ev) in NOTES.items():
    p = os.path.join(DOC, NAMES[rid], "plan-actual", "05-Checklist.md")
    assert os.path.exists(p), p
    note = ("\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 8)\n"
            "M%s: %s Evidencia: %s = %s.\n" % (rid, ver, test, ev))
    with open(p, "ab") as f:
        f.write(note.encode("utf-8"))
    print("M%s note appended" % rid)
