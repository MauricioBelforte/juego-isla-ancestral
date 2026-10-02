# -*- coding: utf-8 -*-
import io
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
files = [
    r"\Logs\1135-P-23-CIERRE-SESION_2026-09-20_08-25-00.md",
    r"\DOCUMENTACION\TAREAS-POR-MODELO\atria-dawn-s2\BACKLOG-MASTER.md",
    r"\Mensajes entre modelos\ESTADO-PARALELO.md",
    r"\DOCUMENTACION\11-BUGS.md",
    r"\DOCUMENTACION\GUIA-GODOT\06-registro-errores.md",
]
for rel in files:
    try:
        b = open(root + rel, "rb").read()
        t = b.decode("utf-8")
        bad = any(s in t for s in ("Â§", "Ã±", "â€", "ðŸ", "Ã³", "Ã­"))
        print("%-62s BOM=%s mojibake=%s" % (rel[-60:], b[:1] == b"\xef", bad))
    except Exception as e:
        print(rel, "ERROR", e)
bm = io.open(root + r"\DOCUMENTACION\TAREAS-POR-MODELO\atria-dawn-s2\BACKLOG-MASTER.md", encoding="utf-8").read()
print("P-17.6 [x]:", "[x] **P-17.6" in bm)
print("P-23 cerrado:", "Sesi\u00f3n s2 cerrada" in bm)