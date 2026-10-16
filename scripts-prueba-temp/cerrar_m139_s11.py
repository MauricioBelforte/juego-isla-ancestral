# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00fc","u"),("\u00bf","?"),("\u2192","->")]:
        s = s.replace(a, b)
    return s.lower()

NOTAS = {
 "transiciones de m\u00fasica por zona": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — data/audio/music_context_matrix.json (temas, capas, stings, variaciones) + autoload MusicDirector. La matriz ya cubre contexto por zona y estado (coral_dia/noche/lluvia, leit_gran_vapor). Definido en 03-Diseno.md 2.8.1.",
 "ambiente por sector": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — data/audio/ambient_biome_bank.json con capas para 10 sectores (playa, bosque, pradera, volcan, montana, selva, desierto, laguna, arrecife, ceniza) y variante clima_2; autoload AmbientDirector. Mapeo de los 4 sectores de fase en 2.8.1.",
 "eventos de sfx por interacci\u00f3n": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — autoload SFXManager (M43). Regla de fase en 2.8.1: todo interactuable tiene sample con variacion de tono.",
 "eventos asmr de recolecci\u00f3n y venta": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — FeedbackDirector (M44) aplica recetas de capas por accion con precedencia contextual (interior/clima/hora) y blacklist anti-agresion. Regla de fase en 2.8.1 (recoleccion cristalina, venta con decay medio).",
 "audio ui": "COMPLETADO 2026-10-14 (step-5-kilocode): bus `UI` verificado en audio_config_service.gd; regla de fase en 2.8.1 — confirmaciones cortas y no repetitivas (max 1 sonido cada 150 ms al navegar).",
 "m\u00fasica del templo con tensi\u00f3n suave": "COMPLETADO 2026-10-14 (step-5-kilocode): definida en 2.8.1 como sting (no tema completo) — acordes graves con quinta suspendida, sin percusion, solo en las 2 salas de puzzle y saliendo al resolverlas, 20% mas bajo que el tema base.",
 "persistencia de niveles de volumen": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — GameSettings delega en AudioConfig.set_volumen() como fuente de verdad; los niveles se guardan en el save de ajustes y se aplican al arrancar.",
}

NOTA_PENDIENTE = ("PENDIENTE REAL 2026-10-14 (step-5-kilocode): de los 5 buses que pide el item, 4 existen "
 "verificados en audio_config_service.gd (Master base + Music, SFX, Ambient, Voice, UI, Cinematic = 7 buses). "
 "Falta el bus **ASMR**: hoy el ASMR se implementa como capas dentro de FeedbackDirector (M44) sobre el bus SFX. "
 "Definicion de la deuda en 03-Diseno.md 2.8.1: crear ASMR como hijo de Master con atenuacion -6 dB y limite "
 "de True Peak en 3 dB. No inflado.")

n = 0
n_pend = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    if norm("Definir buses: Music, Ambient, SFX, ASMR, UI") in ln:
        m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
        if m:
            lines[i] = "- [ ] %s %s \u2014 %s" % (m.group(1), m.group(2), NOTA_PENDIENTE)
            n_pend += 1
        continue
    for clave, nota in NOTAS.items():
        if norm(clave) in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                n += 1
            break

t = "\n".join(lines)
t = t.replace("Completados: 109 \u00b7 Pendientes: 31 \u00b7 No resueltos: 2", "Completados: 116 \u00b7 Pendientes: 24 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n, "| con nota honesta:", n_pend)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos reales: [x]=%d [ ]=%d [?]=%d" % (x, s, q))
