# -*- coding: utf-8 -*-
import re
P = "DOCUMENTACION/131-Creditos/plan-actual/05-Checklist.md"
note = (
 "\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-07, volumen M131)\n"
 "M131 auditado: 85 [x] SUSTENTADOS, 0 degradaciones. 85 [x] / 0 [?] / 10 [ ]. Verificación contra disco: "
 "data/legal/creditos.json (4 secciones) + scripts/legal/ (audio_credit.gd, audio_credits_generator.gd) + "
 "test_credits_m131 8/0 (re-corrí yo). Nota: un [x] cita 'creditos.json con 7 secciones (v1: 3; catálogo ampliado)' "
 "y el archivo trae 4 — el catálogo está parcialmente poblado (las 3 restantes + catalogo creditos.tres están en los "
 "10 [ ]). Los 10 [ ] = KnownIssues NO BLOQUEANTES (SFX encendido/apagado de menú, SFX navegación, música lounge, "
 "catalogo .tres) — los dejo [ ] (deuda real), NO los marco [x]. GLOBAL/11-BUGS NO tocados (flip/pase = director).\n")
with open(P, "ab") as f:
    f.write(note.encode("utf-8"))
c = open(P, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M131 note appendida; [x]=%d [?]=%d [ ]=%d" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
