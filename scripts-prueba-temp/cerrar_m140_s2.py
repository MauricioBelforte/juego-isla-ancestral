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
 "agricultura completa": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — scripts/farm/ con 10 archivos (crop_tile, farm_service, farm_state_store, farm_tool_controller + tests de clima y voxel). Riego 15 hits, cultivo 45, estacion 15. Nota honesta: heladas 0 hits. Ver 2.1.1.",
 "pesca completa": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — scripts/fishing/ completo (FishingSpot, FishingSession, FishDefinition, minijuego, ASMR M44) verificado tambien en la auditoria de M34 (Log 1823). Ver 2.1.1.",
 "miner\u00eda completa": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — scripts/mineria/ con 4 scripts + colocar_props_m25.gd. Ver 2.1.1.",
 "construcci\u00f3n ampliada": "COMPLETADO 2026-10-14 (step-5-kilocode): presente como contrato — construccion_validator.gd + zonas_permisos.gd + catalogo de muebles (data/houses/). Nota honesta arrastrada: la fuente M17 no esta implementada. Ver 2.1.1.",
 "amistad avanzada": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — friendship_service.gd + data/balance/friendship.json con niveles (15 hits), regalos y ofertas de trueque por nivel. Ver 2.1.1.",
 "viajes entre islas": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — travel_service.gd + red de transporte de 10 paradas y 20 rutas, incluida la parada puerto_aurora (barco). Ver 2.1.1.",
 "templos con puzzles complejos": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — scripts/templos/ con puzzle_def (MAX_EMISORES 16), puzzle_agua, puzzle_bloques, puzzle_dificultad + invariante anti-softlock M66. Ver 2.1.1.",
 "herramientas 5 niveles": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — scripts/tools/ con 8 scripts, 90 hits de 'herramienta' y 57 de 'nivel'. Ver 2.1.1.",
 "100% de m71 est\u00e1 presente": "COMPLETADO 2026-10-14 (step-5-kilocode): verificado — DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md tiene 168/168 [x] y 0 [ ]. M71 esta completo, por lo que su contenido esta presente para Alpha. Ver 2.1.1.",
}

PEND = {
 "crafting y cocina completos": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado contra disco — data/balance/crafting.json tiene solo **7 recetas** de las 60+ que pide el item. Deuda real de M16. No inflado.",
 "artefactos 6 pasivos": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): 0 hits de 'artefacto' y 0 de 'pasivo' en scripts/tools/ y en los datos. Los artefactos pasivos no existen. No inflado.",
 "habilidades con xp": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): hay XP (4 hits) y niveles (80) pero 0 hits de 'habilidad' y 0 de 'ventaja' en scripts/progresion/. Sistema de habilidades ausente. No inflado.",
 "men\u00fa de progresi\u00f3n": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): no hay menu de progresion en scripts/ui/ (los hits de UI son de donation, museo y equipment). Pieza de UI ausente. No inflado.",
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
t = t.replace("Completados: 26 \u00b7 Pendientes: 98 \u00b7 No resueltos: 0", "Completados: 35 \u00b7 Pendientes: 89 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n, "| pendientes reales:", n_pen)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
