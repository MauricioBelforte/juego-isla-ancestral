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
 "sprint final de qa": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.9.1 — ultimas 3 semanas antes del GONOGO-BETA, con las builds semanales de M114 (5+ jugadores) como hito.",
 "triaje diario con severidades p0-p2": "COMPLETADO 2026-10-14 (step-5-kilocode): 11-BUGS.md ya usa 4 niveles (Critico/Mayor/Menor/Trivial); mapeo 1:1 a P0-P2 definido en 2.9.1 (P0=Critico, P1=Mayor+Menor bloqueante, P2=Menor+Trivial).",
 "pol\u00edtica de duplicados": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldada — modulo 102-Bug-Tracking verificado completo (140/140). Duplicado se cierra referenciando al ID original, nunca se borra. Ver 2.9.1.",
 "fix con test de regresi\u00f3n adjunto": "COMPLETADO 2026-10-14 (step-5-kilocode): politica definida en 2.9.1 (ningun fix de P0/P1 se mergea sin su test). Nota honesta: M112 esta en 211/216 y en scripts/ hay solo 1 archivo con 'regresion' en el nombre — la politica es la definicion, no el estado actual.",
 "encuesta de diversi\u00f3n y confusi\u00f3n": "COMPLETADO 2026-10-14 (step-5-kilocode): M114 verificado completo (185/185) con plantilla PLAYTEST-ENCUESTA.md; la encuesta de Alpha agrega 2 preguntas (diversion y confusion) en 2.9.1.",
 "m\u00e9tricas de bugs por semana": "COMPLETADO 2026-10-14 (step-5-kilocode): definidas en 2.9.1 — abiertos/cerrados/regresion por semana + contador de duplicados, saliendo del registro 11-BUGS.md (verificado que existe).",
 "cierre con 0 bugs p0/p1": "COMPLETADO 2026-10-14 (step-5-kilocode): criterio de GONOGO-BETA definido en 2.9.1 — 0 P0 y 0 P1 abiertos, cada P2 con entrada documentada en 11-BUGS.md.",
 "auditor\u00eda de severidad duplicada": "COMPLETADO 2026-10-14 (step-5-kilocode): definida en 2.9.1 — revision cruzada semanal de severidades asignadas por distintos reportadores al mismo bug (leccion de BUG-034), hecha por un agente distinto del que tri—.",
 "integraci\u00f3n de qa con el tracking": "COMPLETADO 2026-10-14 (step-5-kilocode): verificados completos — 101-QA-General 209/209 y 102-Bug-Tracking 140/140. 11-BUGS.md es el registro operativo.",
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
t = t.replace("Completados: 64 \u00b7 Pendientes: 60 \u00b7 No resueltos: 0", "Completados: 73 \u00b7 Pendientes: 51 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
