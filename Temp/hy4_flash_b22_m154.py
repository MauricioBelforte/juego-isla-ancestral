from pathlib import Path
import re

REPO = Path(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral")
SRC = REPO / "DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/18-Backlog-VISUAL-QA-PRUEBA.md"
DST = REPO / "DOCUMENTACION/154-Vision-Del-Agente/plan-actual/05-Checklist.md"

# --- 1. medir fuente ---
t = SRC.read_text(encoding="utf-8")
items = {}
for line in t.splitlines():
    m = re.match(r'- \[x\] (T18-\d{2}): ([^/]+) / (\S+) - ver y verificar — (OK|PROBLEMA): (.*)', line)
    if m:
        items[m.group(1)] = (m.group(2).strip(), m.group(3), m.group(4), m.group(5))
assert len(items) == 60, len(items)
prob = {k: v for k, v in items.items() if v[2] == "PROBLEMA"}
ok = {k: v for k, v in items.items() if v[2] == "OK"}
assert len(prob) == 58 and len(ok) == 2, (len(prob), len(ok))

def expand(parts):
    out = []
    for part in parts:
        if isinstance(part, tuple):
            out += [f"T18-{i:02d}" for i in range(part[0], part[1] + 1)]
        else:
            out.append(f"T18-{part:02d}")
    return out

groups = [
    ("1. Capturas inutilizables para QA (15)", expand([5, 18, (26, 30), 33, 37, 38, 40, (52, 55)])),
    ("2. Personaje como capsula azul (19)", expand([(6, 9), 16, 17, 19, 20, 32, (44, 51), 56, 58])),
    ("3. Triangulos verdes flotando (5)", expand([1, 2, 3, 22, 23])),
    ("4. Reloj HUD tapando la cabecera del inventario (4)", expand([(11, 14)])),
    ("5. Franjas horarias indistinguibles (5)", expand([(16, 20)])),
    ("6. Terreno blanco, costuras negras y SCRIPT ERROR (9)", expand([4, 6, 15, 21, 34, (57, 60)])),
]
union = set().union(*[set(v) for _, v in groups])
resto = sorted(set(prob) - union)
assert not (set(ok) & union)
assert len(union) == 50 and len(resto) == 8, (len(union), len(resto))
groups.append(("7. Otros hallazgos no encuadrados en los patrones anteriores (8)", resto))

# --- 2. construir seccion (viñetas simples: NO suman al total del checklist) ---
L = []
L.append("## Barrido HY4 Flash 17nov — 58 hallazgos visuales (capturas)")
L.append("")
L.append("> **Origen:** prueba 18 (backlog `18-Backlog-VISUAL-QA-PRUEBA.md`, reporte `Mensajes entre modelos/HY4 Flash/029-...`).")
L.append("> 60 capturas inspeccionadas individualmente: **2 OK** (T18-24, T18-25) y **58 PROBLEMA**. 0 `[?]`.")
L.append("> Rutas relativas a `tools/mcp/godot-mcp/capturas/`. **No se modifican marcas ni el sello §21.8 existente**:")
L.append("> esta seccion es evidencia de hallazgos, no una verificacion del modulo.")
L.append("")
overlap = sorted([k for k in union if sum(k in v for _, v in groups[:6]) > 1])
for title, ids in groups:
    L.append(f"### {title}")
    L.append("")
    for kid in sorted(ids, key=lambda x: int(x[4:])):
        mod, cap, verdict, desc = items[kid]
        assert verdict == "PROBLEMA", (kid, verdict)
        L.append(f"- {kid} · {mod} · `{cap}` — {desc}")
    L.append("")
L.append("### Nota de medicion (discrepancia de agrupacion)")
L.append("")
L.append("- Los patrones 1-6 se solapan en **7 capturas** (" + ", ".join(overlap) + "), asi que su union es **50**, no 58.")
L.append("- Quedan **8** capturas sin encuadrar en esos patrones (grupo 7), no las 5 que estimaba la tarea T22-08 del backlog 22.")
L.append("- Cuenta final verificada: 60 inspeccionadas = 2 OK + 50 en patrones + 8 otros = **60**; los 58 PROBLEMA quedan todos listados una vez en el grupo que les corresponde segun el orden de esta seccion.")
L.append("")
L.append("**Registro:** HY4 Flash / WorkBuddy — 2026-11-18 (datos medidos el 2026-11-17).")

block = "\r\n".join(L)

# --- 3. escribir conservando CRLF byte-exacto ---
b = DST.read_bytes()
assert not b.startswith(b"\xef\xbb\xbf")
assert b.count(b"\n") == b.count(b"\r\n") and b.count(b"\r") == b.count(b"\r\n")
txt = b.decode("utf-8")
assert "Barrido HY4 Flash 17nov" not in txt
out = txt.rstrip("\r\n") + "\r\n\r\n" + block + "\r\n"
raw = out.encode("utf-8")
DST.write_bytes(raw)

# --- 4. re-medir el efecto ---
b2 = DST.read_bytes()
assert b2.count(b"\n") == b2.count(b"\r\n") and b2.count(b"\r") == b.count(b"\r\n")
assert not b2.startswith(b"\xef\xbb\xbf") and b2.count(b"\xef\xbf\xbd") == 0
t2 = b2.decode("utf-8")
listed = re.findall(r"^- (T18-\d{2}) · ", t2, re.M)
assert len(listed) == 58, len(listed)
assert len(set(listed)) == 58 and set(listed) == set(prob)
assert "[x]" not in block and "- [ ]" not in block
print("OK: seccion agregada | bytes", len(b), "->", len(b2), "| CRLF", b.count(b"\r\n"), "->", b2.count(b"\r\n"))
print("hallazgos listados:", len(listed), "| unicos:", len(set(listed)), "| OK excluidos:", sorted(ok))
print("grupos:", [(t, len(v)) for t, v in groups])
print("overlap:", overlap)
print("resto:", resto)
