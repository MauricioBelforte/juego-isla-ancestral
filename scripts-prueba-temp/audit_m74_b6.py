# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

promo_evidencia = (" | PROMOVIDO [x] 2026-10-13 (step-5-kilocode): M154 operativo — "
 "DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md tabla de estado (2026-08-22/25) marca V1 capturas, "
 "V2 MCP screen, V4 godot-mcp y V5 Blender como OPERATIVAS; verificacion en vivo: esta sesion "
 "(Kilo Code) tiene los tools mcp__screen__* conectados, es decir V2 activa hoy.")

notas = {
 51: "AUDIT 2026-10-13 (step-5-kilocode): verificacion manual en Play Mode; no verificable por disco. Pendiente de ejecucion.",
 52: "AUDIT 2026-10-13 (step-5-kilocode): verificacion de runtime (NullReference/MissingReference); no verificable por disco. Pendiente.",
 53: "AUDIT 2026-10-13 (step-5-kilocode): prueba de flujo completo extremo a extremo; manual. Pendiente.",
 54: "AUDIT 2026-10-13 (step-5-kilocode): prueba en escena de plaza y de recinto; manual. Pendiente.",
 55: "AUDIT 2026-10-13 (step-5-kilocode): prueba con clima severo forzado desde debug (M32/M110); manual. Pendiente.",
 56: "AUDIT 2026-10-13 (step-5-kilocode): prueba de recompensas con inventario lleno/vacio; manual. Pendiente.",
 57: "AUDIT 2026-10-13 (step-5-kilocode): prueba anti-FOMO (perder un festival y vivirirlo al ano siguiente); manual. Pendiente.",
 59: "AUDIT 2026-10-13 (step-5-kilocode): el bloqueo esta documentado en el propio item (regresiones ajenas: event_bus.gd parse error + vehicle_manager.gd autoload roto, avisados en ESTADO-PARALELO). No verificado por mi: requiere corregir esos frentes primero.",
}

idx = 0
checked = 0
flipped = 0
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[\?\]", l):
        n = idx + 1
        if n == 58:
            lines[i] = re.sub(r"^- \[\?\]", "- [x]", l).rstrip() + promo_evidencia
            flipped += 1
        elif n in notas and "AUDIT 2026-10-13" not in l:
            lines[i] = l.rstrip() + " | " + notas[n]
            checked += 1
        idx += 1

txt = "\n".join(lines)
# Totales: 226+1=127? no: 226 [x] -> 227; 59 [?] -> 58
txt = txt.replace("Completados: 226 \u00b7 Pendientes: 0 \u00b7 No resueltos: 59",
                  "Completados: 227 \u00b7 Pendientes: 0 \u00b7 No resueltos: 58")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(txt)
print("anotados:", checked, "| promovidos:", flipped)
