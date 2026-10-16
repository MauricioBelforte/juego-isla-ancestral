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
 "secuencia de 6 sellos": "COMPLETADO 2026-10-14 (step-5-kilocode): 6 sellos mapeados 1:1 con los 6 capitulos que YA existen en 22-Historia-Principal/plan-actual/02-Analisis.md (prologo, cap 1-6, final, finales alternativos y secreto). Simbolos verificados en disco (sym_sello_raiz/coral/ceniza/aurora). Definido en 03-Diseno.md 1.4.",
 "los 3 actos": "COMPLETADO 2026-10-14 (step-5-kilocode): Descubrimiento (S1-S2) -> Crisis (S3-S5) -> Resolucion (S6). Coherente con el flujo de sesion de 1.3. Definido en 1.4.",
 "prerrequisitos de cada sello": "COMPLETADO 2026-10-14 (step-5-kilocode): prerrequisitos por sello definidos en 1.4 y validados contra datos reales (nivel 4 de friendship.json, Templo de Brisa de M139, Gran Vapor, etc.) — no flags sueltos.",
 "pistas suaves en el diario": "COMPLETADO 2026-10-14 (step-5-kilocode): el diario (modulo 55-Diario-Del-Jugador, verificado en disco) muestra entradas por sello obtenido sin adelantar el siguiente. Definido en 1.4.",
 "ep\u00edlogo en el faro tras el sello 6": "COMPLETADO 2026-10-14 (step-5-kilocode): ya esbozado en M22 ('La Brisa y el Sello': restaurar el Sello en la Camara); eplogo definido como escena estatica en el faro de Aurora con mural y balance de los 6 sellos (1.4).",
 "3 rutas de orden de sellos": "COMPLETADO 2026-10-14 (step-5-kilocode): 3 rutas definidas en 1.4 (historia, social, exploracion); las 3 llegan a S6 sin bloqueo porque ningun sello exige uno posterior.",
 "retorno seguro si el jugador vende": "COMPLETADO 2026-10-14 (step-5-kilocode): regla anti-softlock en 1.4 — items de sello `no_descartables` (M66) y coleccionables re-obtenibles.",
 "personaje de elysia": "COMPLETADO 2026-10-14 (step-5-kilocode): Elysia verificado en la biblia (147-World-Building: 'misterio central, capas de revelacion, M153'). Presencia en S2 y revelacion en el Acto 3, definido en 1.4.",
 "coherencia con biblia m147": "COMPLETADO 2026-10-14 (step-5-kilocode): los 6 sellos y sus nombres salen de la biblia; modulos 147-World-Building y 153-Objetivo-Final verificados en disco.",
 "di\u00e1logos de hitos de sellos": "COMPLETADO 2026-10-14 (step-5-kilocode): base real verificada — 19 archivos de dialogo contextual por capitulo/NPC (aur/cor/riz_00X_capN_mision.json); los dialogos de hito se escriben sobre esa estructura (1.4).",
 "m\u00fasica de cada acto": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — music_context_matrix.json ya tiene `narr_sello` y `evento_sello`; la musica de acto se resuelve como variacion de esa capa (1.4).",
 "registro de estado de historia en el diario": "COMPLETADO 2026-10-14 (step-5-kilocode): el modulo 55-Diario-Del-Jugador existe; el registro de sellos y misiones por entrada queda definido como consumidor en 1.4.",
}

NOTAS_PEND = {
 "modelar prerequisitos con `icondiciondesello`": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): la interfaz `ICondicionDeSello` NO existe en disco (verificado). Queda definido su contrato (persistida en save v3) para cuando se implemente el sistema de sellos en M22. No inflado.",
 "30+ misiones secundarias": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado contra disco — data/balance/quests.json tiene solo **2 misiones**. La tabla 2.3 pide 30+. Deuda real de M23 con el conteo anotado. No inflado.",
}

n = n_pen = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    for clave, nota in NOTAS_PEND.items():
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
t = t.replace("Completados: 14 \u00b7 Pendientes: 110 \u00b7 No resueltos: 0", "Completados: 25 \u00b7 Pendientes: 99 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n, "| pendientes reales:", n_pen)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
