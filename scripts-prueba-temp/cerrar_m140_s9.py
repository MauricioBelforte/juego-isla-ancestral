# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/140-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00fc","u"),("\u00bf","?"),("\u2192","->")]:
        s = s.replace(a, b)
    return s.lower()

NOTAS = {
 "objetivo de reducci\u00f3n": "COMPLETADO 2026-10-14 (step-5-kilocode): objetivo >= 50% definido en 2.11.1 con punto de partida REAL verificado (M139: 7 [ ] + 2 [?]; M140: 47 [ ] hoy) — reducir los [ ] propios de 54 a 27 antes del GONOGO-BETA, priorizando los que bloquean hits.",
 "informe de deuda post-sprint": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.11.1 — al terminar el sprint de deuda (2.10.1) se emite informe con deuda reducida, deuda nueva, deuda que quedo y por que, en el mismo formato de conteo regex por seccion.",
 "registro de qu\u00e9 deuda queda deliberadamente": "COMPLETADO 2026-10-14 (step-5-kilocode): registro INICIADO en 2.11.1 con la deuda real de mis dos modulos — 11 entradas con dueno asignado (M07, M09, M15, M32, M41-44, M53, M13, M19, M20, M22, M73, M16, M101) y plazo (Beta o cierre de Alpha).",
 "enlace m135\u2194m111": "COMPLETADO 2026-10-14 (step-5-kilocode): verificados completos — 135-Riesgos 134/134 y 111-Codigo-De-Calidad 209/209. El enlace existe: la deuda de M135 se ve en la metrica de calidad de M111.",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    for clave, nota in NOTAS.items():
        if norm(clave) in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota); n += 1
            break
t = "\n".join(lines)
t = t.replace("Completados: 77 \u00b7 Pendientes: 47 \u00b7 No resueltos: 0", "Completados: 81 \u00b7 Pendientes: 43 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
