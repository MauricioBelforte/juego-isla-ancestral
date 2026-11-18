from pathlib import Path

REPO = Path(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral")
P = REPO / "DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/22-Backlog-M154-Visual-Checklist.md"

b = P.read_bytes()
assert not b.startswith(b"\xef\xbb\xbf")
assert b.count(b"\r\n") == 0 and b.count(b"\n") == 30
t = b.decode("utf-8")
assert t.count("- [ ] T22-") == 12, t.count("- [ ] T22-")

notes = {
    "T22-01": "seccion `## Barrido HY4 Flash 17nov` agregada al 05-Checklist de M154; CRLF preservado (218 -> 319), sin BOM/FFFD, 0 checkboxes nuevos",
    "T22-02": "15 capturas inutilizables con T18-id + modulo + nombre de archivo (grupo 1 de la seccion)",
    "T22-03": "19 capturas con capsula azul (grupo 2)",
    "T22-04": "5 capturas con triangulos verdes (grupo 3)",
    "T22-05": "4 capturas con HUD tapando inventario (grupo 4)",
    "T22-06": "5 capturas con franjas horarias indistinguibles (grupo 5)",
    "T22-07": "9 capturas con terreno/costuras/SCRIPT ERROR (grupo 6)",
    "T22-08": "8 capturas restantes (grupo 7): los patrones 1-6 se solapan en 7 ids, union=50, no 53. Cuenta verificada 58/58 PROBLEMA listados, 0 OK incluidos",
    "T22-09": "re-medido 20/20 modos M41-M60: 18 con drift<=5; M46 +8, M50 +7 SIGUEN en GLOBAL",
    "T22-10": "re-medido 20/20 modos M61-M80: 17 con drift<=5; M63 +26, M66 +7, M69 +19 SIGUEN en GLOBAL",
    "T22-11": "re-medido 20/20 modos M81-M100: 19 con drift<=5; M94 +6 SIGUE en GLOBAL",
    "T22-12": "re-medido 20/20 modos M101-M120: 18 con drift<=5; M104 +8, M106 +12 SIGUEN en GLOBAL",
}

lines = t.split("\n")
out = []
for line in lines:
    m = line.startswith("- [ ] T22-")
    if m:
        tid = line.split(":", 1)[0].replace("- [ ] ", "")
        assert tid in notes, tid
        line = line.replace("- [ ] ", "- [x] ", 1) + " — **EVIDENCIA:** " + notes[tid]
    out.append(line)
res = "\n".join(out)
assert res.count("- [x] T22-") == 12 and "- [ ] T22-" not in res

res += "\n\n## Cierre de tanda (HY4 Flash, 2026-11-18 03:xx UTC)\n\n"
res += "- **12/12 tareas cerradas** con evidencia medida. Parte A: 58/58 hallazgos organizados en M154. Parte B: 80/80 modulos re-medidos contra `CHECKLIST-GLOBAL.md`.\n"
res += "- **Resultado Parte B:** 8 drifts >5 persisten (7 reportados en backlog 09 + M50 nuevo). Reportados al director; NO se edita GLOBAL ni checklists ajenos.\n"
res += "- **Discrepancia de cuenta:** T22-08 estimaba 5 hallazgos restantes; la medicion da 8 por solapamiento de 7 capturas entre patrones.\n"
res += "- Sin commit/push. Sin flips en `05-Checklist` de modulos ajenos (solo se anadio la seccion de evidencia autorizada en M154).\n"
res += "\n**Firma:** hy4-flash\n"

raw = res.encode("utf-8")
P.write_bytes(raw)
b2 = P.read_bytes()
assert not b2.startswith(b"\xef\xbb\xbf") and b2.count(b"\r\n") == 0
assert b2.decode("utf-8").count("- [x] T22-") == 12
print("OK backlog 22: 12/12 | bytes", len(b), "->", len(b2), "| LF", b.count(b"\n"), "->", b2.count(b"\n"))
