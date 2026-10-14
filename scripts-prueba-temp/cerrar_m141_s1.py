# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/141-Beta/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00fc","u"),("\u00bf","?"),("\u2192","->")]:
        s = s.replace(a, b)
    return s.lower()

# los 3 [?] pasan a [x] con definicion; creditos con cita
fijos = {
 "coleccionables localizables sin gu\u00eda": ("x", "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 03-Diseno.md 2.8 — cada coleccionable recibe una pista de diario textual y ambiguada al descubrir su zona; el diario (M55) es el unico contenedor. Objetivo Beta: 80/80 sin guia externa."),
 "evento de cierre: festival con todos los npc": ("x", "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.8 — Festival de la Brisa tras el ultimo sello, instancia del motor M74 existente (event_manager.gd, event_definition.gd, contexto_festival.gd) con todos los NPC del elenco en la plaza de Aurora."),
 "cr\u00e9ditos de cierre con equipo": ("x", "PROMOVIDO 2026-10-14 (step-5-kilocode) — era FALSO NEGATIVO del QA de s2: el sistema existe y es data-driven (scripts/legal/credits_manager.gd, autoload de M131, + data/legal/creditos.json con 7 entradas). El QA reporto 'grep 0 hits' porque el archivo vive en scripts/legal/. Solo falta completar las secciones del JSON."),
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[\?\]", l):
        continue
    ln = norm(l)
    for clave, (estado, nota) in fijos.items():
        if norm(clave) in ln:
            marca = "[x]" if estado == "x" else "[ ]"
            # conservar el texto original del item (sin la nota previa del QA)
            base = re.sub(r"\s*-\s*\*\*QA s2.*$", "", l)
            base = re.sub(r"^\s*- \[\?\]\s*", "", base)
            lines[i] = "- %s %s \u2014 %s" % (marca, base.strip(), nota)
            n += 1
            break

t = "\n".join(lines)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("promovidos:", n)
print("conteos: [x]=%d [ ]=%d [?]=%d total=%d" % (x, s, q, x+s+q))
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
