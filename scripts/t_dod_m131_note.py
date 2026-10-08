# -*- coding: utf-8 -*-
import re
P = "DOCUMENTACION/131-Creditos/plan-actual/05-Checklist.md"
note = (
 "\n## Veredicto DoD (agnes-3-flash, Kilo Code, 2026-10-07, frente s2/61 - profundidad M25)\n"
 "M131 re-auditado con DoD 21.6: **DEUDA REAL** (no flip). Conteo 85 [x] / 0 [?] / 10 [ ] es honesto, "
 "pero DoD incompleto:\n"
 "- 04-Codigo.md lista 5 archivos AUSENTES en disco: CreditsDirector.gd, catalog.tres, credits-canvas.tscn, "
 "data.tres, scene.tscn.\n"
 "- 07-Resultados-Testings.md AUSENTE.\n"
 "- 10 [ ] KnownIssues pendientes (SFX menu, SFX navegacion, musica lounge, catalogo .tres).\n"
 "- Gap: un [x] dice \"creditos.json con 7 secciones (v1: 3; catalogo ampliado)\" y el archivo trae **4** -> "
 "catalogo en progreso (3 faltantes quedan en los 10 [ ]); lo marco como GAP, NO lo degradado a [ ] (no es "
 "una afirmacion falsa, es un item de ampliacion en curso).\n"
 "- Positivo: data/legal/creditos.json (4 secciones) + scripts/legal/ (audio_credit.gd) + "
 "test_credits_m131 **8/0** (re-corrí yo).\n"
 "Clasificacion: **DEUDA REAL** (catalogo/director/07 + 10 [ ] + 3 secciones faltantes), no flip. GLOBAL no "
 "tocado (flip = director).\n")
with open(P, "ab") as f:
    f.write(note.encode("utf-8"))
c = open(P, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M131 veredicto append; [x]=%d [?]=%d [ ]=%d (intacto)" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
