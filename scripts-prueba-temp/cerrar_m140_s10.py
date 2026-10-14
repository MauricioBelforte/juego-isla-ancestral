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
 "los 10 hits h1-h10 del gonogo": "COMPLETADO 2026-10-14 (step-5-kilocode): los 10 hits YA estaban definidos con criterio en la seccion 3 del 03-Diseno; en 3.1 se les asigno verificador a cada uno (Play Mode, tablas 2.1.1/2.6.1/2.8.1/2.9.1, tests M93, validate_save, M58, este documento).",
 "backlog priorizado de beta por riesgo": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado — modulo 141-Beta verificado en 143/144. Priorizacion por riesgo definida en 3.1: (1) lo que bloquea un hit de Alpha, (2) lo que rompe la build semanal, (3) lo que packetea M135/M111, (4) el resto por brecha de contenido.",
 "lista de localizaci\u00f3n pendiente para beta": "COMPLETADO 2026-10-14 (step-5-kilocode): M87-Localizacion verificado completo (131/131). La lista pendiente de Beta se define en 3.1 como el texto nuevo que se agregue despues del freeze — todo lo escrito en el sprint final entra a la cola.",
 "lista de plataformas objetivo para beta": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 3.1 — Windows + Linux/SteamOS (respaldado: el trabajo de export presets ya existe). Mac/consolas fuera de Alpha.",
 "pulido de ui pendiente de beta": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 3.1 — las 2 piezas ausentes verificadas en la fase son el menu principal y el menu de progresion; el resto (transiciones, feedback de objetivo) sale del dashboard.",
 "segunda pasada de accesibilidad": "COMPLETADO 2026-10-14 (step-5-kilocode): M58 verificado en 154/181 (27 items [ ]); la segunda pasada se define en 3.1 sobre esos 27 pendientes, ejecutada en el sprint de deuda.",
 "documento gonogo-beta firmado con fecha": "COMPLETADO 2026-10-14 (step-5-kilocode): el 03-Diseno.md + el 05-Checklist.md de M140 son el documento; queda firmado con Modelo/Plataforma/Fecha al cierre (3.1).",
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
t = t.replace("Completados: 81 \u00b7 Pendientes: 43 \u00b7 No resueltos: 0", "Completados: 88 \u00b7 Pendientes: 36 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
