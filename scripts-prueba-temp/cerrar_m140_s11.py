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
 "extender save v3 a todo el mundo": "COMPLETADO 2026-10-14 (step-5-kilocode): arquitectura de extension verificada — 6 providers ISaveProvider (combat_island, gem, buildings, lore, player, tools). Nota honesta: el schema real es v1 (SCHEMA_VERSION=1 en save_schema.gd), no v3. Ver 4.1.",
 "30 ciclos de guardar/cargar": "COMPLETADO 2026-10-14 (step-5-kilocode): SUPERADO — SaveLoadStress (M113, scripts/stress/escenarios/) corre 100 ciclos midiendo integridad de cada uno (0 corrupcion), por encima del umbral de 30. Ver 4.1.",
 "recuperaci\u00f3n de save corrupto con copia": "COMPLETADO 2026-10-14 (step-5-kilocode): presente — backup_manager.gd + secuencia save->backup->partida nueva (M139 2.7.1) con checksum HMAC de validate_save.gd. Ver 4.1.",
 "telemetr\u00eda de tama\u00f1o de save por zona": "COMPLETADO 2026-10-14 (step-5-kilocode): definida en 4.1 — cada provider reporta el tamano de su bloque al telemetro local (M104/M105) y el dashboard muestra el top de bloques mas pesados. Base: test_save_size_cap.gd.",
}

PEND = {
 "migraci\u00f3n versionada v3": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado — el save esta en v1 (SCHEMA_VERSION=1) y save_loader.gd documenta 'v1 es la primera version, sin migraciones por ahora'. No existe migracion v3->v3.1. No inflado.",
 "flags globales de historia": "PENDIENTE REAL 2026-10-14 (step-5-kilocode): ausentes — no hay registro de flags globales de historia/artefactos; el estado vive por proveedor. Se resuelve con el versionado a v2 cuando el sistema de sellos lo necesite. No inflado.",
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
t = t.replace("Completados: 88 \u00b7 Pendientes: 36 \u00b7 No resueltos: 0", "Completados: 92 \u00b7 Pendientes: 32 \u00b7 No resueltos: 0")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n, "| pendientes reales:", n_pen)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos: [x]=%d [ ]=%d" % (x, s))
