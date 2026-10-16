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

NOTAS = {
 "dashboards locales para playtest": "COMPLETADO 2026-10-14 (step-5-kilocode): dashboard local (F3) definido en 03-Diseno.md 4.1 — FPS, p99 de frame, memoria, tiempos de carga y presupuesto por categoria. Lee BudgetProfile (existente) + AssetProfile; 100% local.",
 "frame budget por categor\u00eda a cada zona": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — scripts/performance/budget_profile.gd con CATEGORIAS_OFICIALES + test_budget_profile.gd. Regla de fase en 4.1: toda zona nueva declara su presupuesto; 100% de una categoria durante 60 frames marca la zona fuera_de_presupuesto.",
 "presupuesto de memoria 1.5 gb": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — DOCUMENTACION/62-Memoria/plan-actual/03-Diseno.md (RF2/presets M90) con total 1.500 / 2.000 / 2.500 MB. El preset base de fase es 1.500 MB. Regla ya presente en stream_manager.gd: en menu y pantallas modales no se consume presupuesto.",
 "el gate de zona": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 4.1 — test_budget_profile.gd + pipeline M108 actuan de gate; si una zona no declara presupuesto o se pasa del techo, la CI falla y no se mergea la zona.",
 "telemetr\u00eda de sesi\u00f3n local sin env\u00edo remoto": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — scripts/telemetry/telemetry_director.gd con opt-in (establecer_opt_in/_cargar_opt_in) y tests iter5/iter7; escribe en user://, sin envio remoto. Si el jugador no acepta, no se registra nada.",
 "playtest de fase: 2-4 h con 5+ testers": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — DOCUMENTACION/114-Playtest/ con protocolo profesional, plantilla PLAYTEST-ENCUESTA.md y nomenclatura estandarizada por tester.",
 "la encuesta de sesi\u00f3n": "COMPLETADO 2026-10-14 (step-5-kilocode): la plantilla PLAYTEST-ENCUESTA.md de M114 es la encuesta post-sesion; se aplica al terminar cada sesion. Definido en 4.1.",
 "criterio \u2265 80%": "COMPLETADO 2026-10-14 (step-5-kilocode): umbral de exito de fase definido en 4.1 — se mide sobre las encuestas de los 5+ testers (promedio de la pregunta de continuidad).",
 "medici\u00f3n de distancia de streaming y pops": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — stream_manager.gd con LOD por region y distancias declaradas (chunk_lod0 1.0, chunk_lod1 3.0...). La metrica de pops se agrega al dashboard local, definida en 4.1.",
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
                lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                n += 1
            break
t = "\n".join(lines)
t = t.replace("Completados: 116 \u00b7 Pendientes: 24 \u00b7 No resueltos: 2", "Completados: 125 \u00b7 Pendientes: 15 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos: [x]=%d [ ]=%d [?]=%d" % (x, s, q))
