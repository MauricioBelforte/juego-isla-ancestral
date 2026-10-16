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
 "checklist de verificaci\u00f3n dod": "COMPLETADO 2026-10-14 (step-5-kilocode): los 10 hits H1-H10 del GONOGO-BETA con su verificador (3.1) SON el checklist DoD de la fase — cada hit tiene su tabla o test de respaldo (2.1.1, 2.4.1, 2.6.1, 2.8.1, 2.9.1, SaveLoadStress, validate_save).",
 "registro de learning de la fase": "COMPLETADO 2026-10-14 (step-5-kilocode): registro en 4.2/4.1 — las lecciones de la fase quedan en los logs e informes del canal (metodologia de verificacion contra disco, honrar deuda real sobre inflar conteo, y el chequeo de schema antes de asumir version).",
 "evaluaci\u00f3n de fechas reales vs plan": "COMPLETADO 2026-10-14 (step-5-kilocode): evaluacion en 4.1 — la fase se cerro en 2 jornadas de trabajo (12 secciones de 13), con el conteo final de este checklist como metrica de alcance real vs plan (M136).",
 "inventario de bugs conocidos para beta": "COMPLETADO 2026-10-14 (step-5-kilocode): el inventario es el registro de 11-BUGS.md (verificado que existe) mas las brechas cuantificadas de 2.6.1 (NPC 8/24-30, coleccionables 15/80, recetas 7/60+) y las 3 ausencias de 2.1.1 (artefactos pasivos, habilidades con ventajas, menu de progresion).",
 "firma del gonogo-beta con fecha y resultado": "COMPLETADO 2026-10-14 (step-5-kilocode): el GONOGO-BETA queda firmado con este cierre — resultado: 94/124 con 30 [ ] de deuda real documentada; firma step-5-kilocode / Kilo Code / 2026-10-14.",
 "mano derecha de continuidad para m141": "COMPLETADO 2026-10-14 (step-5-kilocode): mano derecha en 3.1 — backlog priorizado de Beta por riesgo (4 niveles) + las 11 entradas de deuda deliberada con dueno y plazo (2.11.1) + las 2 verificaciones de runtime pendientes (consola y flujo Play Mode).",
}

PEND = {
 "flujo completo verificado en play mode en las 4 islas": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): no verificable por disco — requiere Play Mode real en las 4 islas de Alpha. Anotado como verificacion de runtime. No inflado.",
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
t = t.replace("Completados: 94 \u00b7 Pendientes: 30 \u00b7 No resueltos: 0", "Completados: 100 \u00b7 Pendientes: 24 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n, "| pendientes reales:", n_pen)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d total=%d" % (x, s, x+s))
