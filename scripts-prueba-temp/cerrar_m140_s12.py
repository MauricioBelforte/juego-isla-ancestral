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
 "tama\u00f1o m\u00ednimo de texto al 150%": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — verificados 47 hits de escala de texto en scripts/ (accesibilidad_schema, accesibilidad_aplicador, action_prompt_overlay). La escala al 150% existe como ajuste de M58. Ver 4.2.",
 "feedback de audio completo en nuevas interacciones": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — feedback_director.gd (M44) con test_feedback_m44.gd; las nuevas interacciones de Alpha entran por receta de capas (M139 2.8.1). Ver 4.2.",
}

PEND = {
 "modos de color para puzzles de espejos": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): los modos de color existen (8 hits: accesibilidad_schema, gestor_config, mapa_manager) pero hay 0 hits de 'espejo'/'sombra' en el manager: no estan aplicados a puzzles. Ver 4.2. No inflado.",
 "navegaci\u00f3n del diario con gamepad": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): 0 hits de la combinacion diario+gamepad (si hay 29 hits de gamepad en general, incluido control_input.gd). Ver 4.2. No inflado.",
 "estados vac\u00edos de colecciones": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): los 5 hits son de otros sistemas; no hay un patron de estado vacio para colecciones. Definido en 4.2 como texto + ilustracion, nunca lista vacia. No inflado.",
}

n = n_pen = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    for clave, nota in PEND.items():
        if norm(clave) in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [ ] %s %s \u2014 %s" % (m.group(1), m.group(2), nota); n_pen += 1
            break
    else:
        for clave, nota in NOTAS.items():
            if norm(clave) in ln:
                m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
                if m:
                    lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota); n += 1
                break
t = "\n".join(lines)
t = t.replace("Completados: 92 \u00b7 Pendientes: 32 \u00b7 No resueltos: 0", "Completados: 94 \u00b7 Pendientes: 30 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n, "| pendientes reales:", n_pen)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
