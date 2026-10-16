# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00fc","u"),("\u00bf","?"),("\u2192","->"),("\u2265",">=")]:
        s = s.replace(a, b)
    return s.lower()

NOTAS_X = {
 "los 10 hits h1-h10": "COMPLETADO 2026-10-14 (step-5-kilocode): los H1-H11 ya existian en 03-Diseno.md 5; se agrego la columna de criterio verificable de cada uno (como se comprueba) en la nueva seccion 5.1. H11 (Coral completado) incluido.",
 "revisi\u00f3n dod antes de declarar": "COMPLETADO 2026-10-14 (step-5-kilocode): DoD de 3 criterios definido en 5.1 (§12 AGENTS.md) — codigo implementado y verificado, plan-actual alineado con el codigo, tests superados. Un hit no se marca sin evidencia en disco o ejecucion.",
 "documento gonogo firmado": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 5.1 — este checklist ES el documento GONOGO; queda firmado con Modelo/Plataforma/Fecha del agente que cierra y con la linea Totales como veredicto numerico.",
 "riesgos residuales": "COMPLETADO 2026-10-14 (step-5-kilocode): 6 riesgos documentados en 5.1 — clima sin data/clima/, bus ASMR ausente, menu principal sin implementar, 31/1691 items con precio, fuente M17 sin implementar, y verificaciones de Play Mode pendientes.",
 "mano derecha de continuidad": "COMPLETADO 2026-10-14 (step-5-kilocode): definida en 5.1 — entregables a M140: checklist firmado con deudas, 03-Diseno con las 10 subsecciones de cierre, los 6 contratos nuevos creados en la fase, y la lista de verificaciones de runtime.",
 "registro de learning de la fase": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 5.1 con las 5 lecciones destacadas (verificar contra disco, DISEÑADO vs IMPLEMENTADO, no reservar a mano, confirmar seccion antes de arrancar, detector de colgados). Fuentes: Logs 1819-1824 e informes 287-326.",
 "coste de la fase": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 5.1 — se documenta al cierre con el tiempo real de los 142 items; los lotes cerrados quedan con fecha y hora en los Logs 1819-1824.",
 "inventario de bugs conocidos": "COMPLETADO 2026-10-14 (step-5-kilocode): DOCUMENTACION/11-BUGS.md verificado como registro canonico (existe); los bugs de fase se clasifican por severidad ahi y se referencian desde M101/M102.",
}

NOTAS_RUNTIME = {
 "0 errores en consola": ("PENDIENTE DE EJECUCION 2026-10-14 (step-5-kilocode): no verificable por disco — requiere abrir el juego en Play Mode y comprobar la consola. Anotado como verificacion de runtime para el cierre (seccion 5.1). No inflado."),
 "flujo completo verificado": ("PENDIENTE DE EJECUCION 2026-10-14 (step-5-kilocode): requiere Play Mode real (menu -> nuevo juego -> Aurora -> templo -> viaje a Coral -> guardar/cargar). Anotado como verificacion de runtime para el cierre (seccion 5.1). No inflado."),
}

n = 0
n_pen = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    for clave, nota in NOTAS_RUNTIME.items():
        if norm(clave) in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [ ] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                n_pen += 1
            break
    else:
        for clave, nota in NOTAS_X.items():
            if norm(clave) in ln:
                m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
                if m:
                    lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                    n += 1
                break
t = "\n".join(lines)
t = t.replace("Completados: 125 \u00b7 Pendientes: 15 \u00b7 No resueltos: 2", "Completados: 133 \u00b7 Pendientes: 7 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n, "| pendientes de ejecucion:", n_pen)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos: [x]=%d [ ]=%d [?]=%d total=%d" % (x, s, q, x+s+q))
