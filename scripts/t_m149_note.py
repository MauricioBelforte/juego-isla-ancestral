# -*- coding: utf-8 -*-
P = "DOCUMENTACION/149-Nombres-Y-Nomenclatura/plan-actual/05-Checklist.md"
note = (
 "\n## Notas del Agente — Verificación M149 (agnés-3-flash, Kilo Code, 2026-10-08, frente canal 81)\n"
 "Conteo: 99 [x] / 1 [?] / 0 [ ]. Verificación DoD (mod. documental, criterio = artefacto .md):\n"
 "- Los 99 [x] estan SUSTENTADOS: los 10 artefactos .md citados EXISTEN y son coherentes "
 "(03-Diseno.md, code-conventions.md, npc-names.md, place-names.md, quick-reference.md, "
 "validation-process.md — en plan-actual/ y operativa/).\n"
 "- El unico [?] (L51 'Revisar con hablantes nativos') es una DEPENDENCIA HUMANA REAL, no agentizable: "
 "es el sign-off de validacion linguistica de la nomenclatura, que requiere hablantes nativos del equipo. "
 "Ya esta caracterizada (dueño M141/M87, programado para beta, no bloqueante) y la parte de AGENTE "
 "(chequeo documental multilingue) YA esta hecha en validation-process.md §1. No hay artefacto .md que "
 "la cierre: cerrar = el sign-off humano, que no es entregable de agente.\n"
 "- Veredicto: M149 = 99/100 SUSTANTIVO (nomenclatura documentada y coherente). El [?] queda como deuda "
 "externa caracterizada. M149 se queda en 166 (no flip, es del director). Sin trabajo agentizable restante.\n")
with open(P, "ab") as f:
    f.write(note.encode("utf-8"))
import re
c = open(P, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M149 verificacion append; [x]=%d [?]=%d [ ]=%d (intacto)" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
