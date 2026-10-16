# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00fc","u"),("\u00dc","U"),("\u00bf","?"),("\u2192","->"),("\u2014","-"),
                 ("\u201c",'"'),("\u201d",'"')]:
        s = s.replace(a, b)
    return s.lower()

# items de la seccion 2 con su resolucion
DECIDIDOS = {
 "geografia de aurora": ("x", "COMPLETADO 2026-10-14 (step-5-kilocode): 5 sectores definidos en 03-Diseno.md seccion 2.1.1 (costa E-puerto, pradera central-pueblo, bosque W, colina N-templo, acantilados S-faro) con contenido y modulos por sector."),
 "area navegable": ("x", "COMPLETADO 2026-10-14 (step-5-kilocode): ~2 km2 definidos en 03-Diseno.md 2.1.1; limite mar-tierra por el nivel de mar de M51."),
 "6 zonas de streaming": ("x", "COMPLETADO 2026-10-14 (step-5-kilocode): Costa-E, Pradera, Bosque-W, Colina-N, Acantilados-S y Puerto (transicion) definidas en 03-Diseno.md 2.1.1; base real scripts/stream/stream_manager.gd con suite M63 (6 iteraciones)."),
 "pois de cada sector": ("x", "COMPLETADO 2026-10-14 (step-5-kilocode): POIs por sector definidos en 03-Diseno.md 2.1.1 (muelle, plaza+talleres+tienda, mina, templo, faro). Sin catalogo de POIs en disco: la implementacion es de M22/M64."),
 "vegetacion del bioma": ("x", "COMPLETADO 2026-10-14 (step-5-kilocode): respaldo real en data/vegetacion/vegetacion_config.json v2 — palmeras (3 tipos en playa), bambu (canas_bambu en ribera), pasto alto (hierba_alta). Hibisco no existe con ese nombre (equivalentes flor_isla/arbusto_floral): deuda de nombrado de M50 anotada en 03-Diseno.md 2.1.1."),
 "litoral con agua jugable": ("x", "COMPLETADO 2026-10-14 (step-5-kilocode): litoral de Aurora definido pescable en 03-Diseno.md 2.1.1; el sistema de pesca existe (scripts/fishing/) sujeto a que M51 integre los voxels de agua (stub es_agua_pescable documentada en M34)."),
 "puntos de descanso": ("x", "COMPLETADO 2026-10-14 (step-5-kilocode): puntos de descanso definidos en 03-Diseno.md 2.1.1 (Pradera y Puerto); camas existen como muebles (data/houses/cama_madera.tres, catalogo M18). Implementacion: M18."),
 "ciclo dia/noche aplicado": ("x", "COMPLETADO 2026-10-14 (step-5-kilocode): Aurora usa el ciclo global de M31 sin variacion propia (modulo 31-Ciclo-Dia-Noche + TimeCalendar autoload). Definido en 03-Diseno.md 2.1.1."),
 "fauna inicial visible": ("x", "COMPLETADO 2026-10-14 (step-5-kilocode): aves con respaldo real en data/fauna/catalog.json — gaviota_playera (playa), lechuza_bosque (bosque), halcon_montana (montana). Peces costeros no estan en el catalogo de fauna (son de M34/fishing.json): deuda de catalogo de M36 anotada."),
}

QUEDAN = {
 "flora transmisora de estado": "PARCIAL 2026-10-13 (step-5-kilocode): la flora existe (baya_roja registrada en el museo M37) pero el catalogo de flora transmisora de estados de M09 no esta en disco. Definicion pendiente del dueno M09; ver 03-Diseno.md 2.1.1.",
 "clima base del bioma": "PARCIAL 2026-10-13 (step-5-kilocode): tropical suave definido en 03-Diseno.md 2.1.1, pero data/clima/ NO EXISTE (verificado). La definicion queda documentada a la espera de que M32 tenga datos para consumirla.",
}

n_x = n_nota = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    for clave, (estado, nota) in DECIDIDOS.items():
        if norm(clave) in ln:
            lines[i] = "- [x] " + l.strip()[6:].split("[M]")[0].strip() + " \u2014 " + nota if False else l
            # reescribir conservando el texto original hasta el esfuerzo
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                n_x += 1
            break
    else:
        for clave, nota in QUEDAN.items():
            if norm(clave) in ln:
                m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
                if m:
                    lines[i] = "- [ ] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                    n_nota += 1
                break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("promovidos:", n_x, "| anotados:", n_nota)

t = "\n".join(lines)
t = t.replace("Completados: 13 \u00b7 Pendientes: 127 \u00b7 No resueltos: 2",
              "Completados: 22 \u00b7 Pendientes: 118 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos: [x]=%d [ ]=%d [?]=%d total=%d" % (x, s, q, x+s+q))
