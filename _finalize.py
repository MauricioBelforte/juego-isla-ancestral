# -*- coding: utf-8 -*-
import os

BASE = r"D:/Escritorio/PORTFOLIO/Proyectos para GitHub/PROYECTOS OPENCODE/juego-isla-ancestral"

# 1) advance channel tracker
rev = os.path.join(BASE, "Mensajes entre modelos/Hy3/.ultima-revision-hy3.txt")
with open(rev, "w", encoding="utf-8", newline="\n") as f:
    f.write("185\n")
print("updated .ultima-revision-hy3.txt -> 185")

# 2) append brief note to today's memory log
memdir = os.path.join(BASE, ".workbuddy-ai/memory")
os.makedirs(memdir, exist_ok=True)
memlog = os.path.join(memdir, "2026-10-13.md")
note = (
    "\n"
    "## 2026-10-13 (P4, msgs 184/185 del director mimo)\n"
    "- Ejecute P4: agregar linea `Totales:` a 6 modulos (M30/M31/M32/M106/M150/M163).\n"
    "- HALLAZGO: mapeo '+1' de la memoria compartida es ERRONEO para modulos altos. "
    "Regla real: prefijo de carpeta = nro de modulo. M106=106-Seguridad (no 107), "
    "M150=150-Diseno-Sonoro-Narrativo (no 151), M163=163-Sistema-De-Encantamientos (no 164). Evite colision.\n"
    "- M163 ya tenia linea Totales (del director 2026-10-12, correcta y coincidente con GLOBAL) -> no duplique.\n"
    "- 5 archivos editados (1 linea c/u). 0 discrepancias GLOBAL<->disco en los 6.\n"
    "- `verificar_checklist.py` exit 0; mis 6 modulos ausentes de las 11 alertas (estas son de modulos ajenos).\n"
    "- Reporte en `Mensajes entre modelos/Hy3/186-2026-10-13_01-35-52-hy3-a-hy3-p4-totales-6-modulos.md`.\n"
    "- Sin commit/push (no autorizado en este P4). `.ultima-revision-hy3.txt` -> 185.\n"
)
with open(memlog, "a", encoding="utf-8", newline="\n") as f:
    f.write(note)
print("appended note to", os.path.relpath(memlog, BASE))

# 3) remove temp files
for t in ("verify_full.txt", "_build_report.py", "_append_totales_tmp.py"):
    p = os.path.join(BASE, t)
    if os.path.exists(p):
        os.remove(p)
        print("removed temp:", t)
