# -*- coding: utf-8 -*-
import glob, re

# M76 GLOBAL row 4/130 -> 1/130 (byte-level)
P = "CHECKLIST-GLOBAL.md"
d = open(P, "rb").read()
def rep_row(marker, old, new):
    global d
    i = d.find(marker)
    assert i >= 0, marker
    rs = d.rfind(b"|", 0, i)
    e = d.find(b"\r\n", i)
    seg = d[rs:e]
    assert old in seg, (marker, old)
    return d[:rs] + seg.replace(old, new) + d[e:]
d = rep_row(b"76-Multijugador", b"4/130", b"1/130")
open(P, "wb").write(d)
print("M76 GLOBAL 4/130 -> 1/130 OK; EOL CRLF=%d CR=%d LF=%d" % (
    d.count(b"\r\n"), d.count(b"\r") - d.count(b"\r\n"), d.count(b"\n") - d.count(b"\r\n")))

# M76 Totales
g76 = glob.glob("DOCUMENTACION/76-*")[0] + "/plan-actual/05-Checklist.md"
c = open(g76, "rb").read().decode("utf-8")
lines = c.splitlines(keepends=True)
for i, L in enumerate(lines):
    if "Totales:" in L:
        L = re.sub(r"Completados: \d+", "Completados: 1", L)
        L = re.sub(r"No resueltos: \d+", "No resueltos: 3", L)
        lines[i] = L
        break
open(g76, "w", encoding="utf-8", newline="").write("".join(lines))
print("M76 Totales -> Completados 1 / No resueltos 3")

# audit notes for M59, M62, M47 (substantiated) + M76 (degraded)
NOTES = {
    "59": ("test_autosave_m59.gd 0/0", "scripts/saving/ (save_snapshot.gd + save_writer.gd en disco, código actual post-fix de DeepSeek BUG-108..115 re-verificado); 1 [?] externo"),
    "62": ("test_memoria_m62_iter5.gd 60/0", "scripts/rendimiento/memoria/; verificado contra disco"),
    "47": ("test_materiales_m47.gd 17/0", "scripts/arte3d/; el más bajo documental del tablero, sin agente activo"),
    "76": ("3 [x] -> [?] (mp_contract.json AUSENTE)", "M76 bloqueado por producto (single-player v1, patrón M77). 1 [x] queda (documentar decisión single-player). Reportado al director"),
}
COUNTS = {"59": 60, "62": 113, "47": 18, "76": 1}
for rid, (test, ev) in NOTES.items():
    g = glob.glob("DOCUMENTATION/%s-*" % rid)[0] + "/plan-actual/05-Checklist.md"
    note = ("\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 8)\n"
            "Los [x] auditados contra disco (bloq 8). %s Evidencia: %s = %s.\n"
            % ({"59": "Sustentado, 0 degradaciones. ", "62": "Sustentado, 0 degradaciones. ",
                "47": "Sustentado, 0 degradaciones. ",
                "76": "3 [x] degradados (bloqueado por producto). "}[rid], test, ev))
    with open(g, "ab") as f:
        f.write(note.encode("utf-8"))
    print("M%s note appended" % rid)
