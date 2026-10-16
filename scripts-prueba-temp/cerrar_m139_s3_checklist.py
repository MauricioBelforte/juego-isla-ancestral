# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

NOTAS = {
 "Definir el enclave visitable": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 03-Diseno.md seccion 2.2 \u2014 muelle, 1 NPC (Bram, ver 2.3.1), tienda unica de arrecife glasswork (stock propio abajo) y vista al oceanico como anzuelo. Es DEFINICION: la construccion del enclave queda para Alpha (ver item 2).",
 "Asegurar que Coral NO se construye": "COMPLETADO 2026-10-14 (step-5-kilocode): regla explicita en 03-Diseno.md 2.2 \u2014 'visitable no construido', 'se deja inacabado a proposito con hit explicito para Alpha (M140)'. Hit H11 agregado a la tabla de hits el 2026-10-14.",
 "Documentar el anzuelo de curiosidad": "COMPLETADO 2026-10-14 (step-5-kilocode): documentado en 03-Diseno.md 2.2 \u2014 'vista al oceanico como anzuelo de curiosidad (M152/M153)'. Modulos 152-Principios-Innegociables y 153-Objetivo-Final existen en disco.",
 "Definir el NPC enano de Coral": "COMPLETADO 2026-10-14 (step-5-kilocode): Bram, enano vidriero de arrecife \u2014 agregado al elenco (03-Diseno.md 2.3) con rol, rutina (muelle->taller->mirador) y gancho, y 11 lineas de dialogo base escritas en la seccion 2.3.1. Variantes por estacion/dia (M29) e IA (M64) quedan como trabajo de sus modulos duenos.",
 "Definir la tienda unica de Coral": "COMPLETADO 2026-10-14 (step-5-kilocode): stock propio definido en 03-Diseno.md 2.3.1 \u2014 cristal_arrecife, lampara_coral, prisma_mareal, cebo_brillante, botella_mensaje, pendiente_marea. Regla: ninguno se consigue en Aurora; el enclave es la unica fuente (M39).",
 "Registrar hit explicito para Alpha": "COMPLETADO 2026-10-14 (step-5-kilocode): hit H11 'Coral completado: enclave terminado e integrado al flujo de Alpha' agregado a la tabla de hits de 03-Diseno.md; la nota de cierre paso de H1-H10 a H1-H11.",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = l.lower().replace("\u00e1","a").replace("\u00e9","e").replace("\u00ed","i").replace("\u00f3","o").replace("\u00fa","u").replace("\u00f1","n")
    for clave, nota in NOTAS.items():
        if clave.lower().replace("\u00e1","a").replace("\u00e9","e").replace("\u00ed","i").replace("\u00f3","o").replace("\u00fa","u").replace("\u00f1","n") in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                n += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("promovidos:", n)
t = "\n".join(lines)
t = t.replace("Completados: 22 \u00b7 Pendientes: 118 \u00b7 No resueltos: 2", "Completados: 28 \u00b7 Pendientes: 112 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos: [x]=%d [ ]=%d [?]=%d total=%d" % (x, s, q, x+s+q))
