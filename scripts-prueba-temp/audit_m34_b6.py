# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/34-Pesca/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    txt = f.read()
lines = txt.split("\n")

notas = {
 51: "AUDIT 2026-10-13 (step-5-kilocode): get_collection_data() devuelve _coleccion.duplicate(true) (fishing_manager.gd L467-468) — dato listo; la vista de desafios del registro es de M53.",
 52: "AUDIT 2026-10-13 (step-5-kilocode): FishDefinition tiene estaciones/franjas/climas (fishing_manager.gd _candidatas_de_estacion, _franja_de_hora) y el registro las expone; la vista previa en UI es de M53.",
 53: "AUDIT 2026-10-13 (step-5-kilocode): la divergencia plan-actual vs plan-inicial es POR DISEÑO (AGENTS.md §3: plan-inicial es historico no modificable); no es una tarea pendiente sino una regla del repo.",
 54: "AUDIT 2026-10-13 (step-5-kilocode): achievement_service.gd L141-144 consume captura_exitosa para stats (verificado en produccion) pero telemetria_m104.gd (M105) es consumido por pausa_contemplativa/house_manager/transport_route_events — NO por pesca: el registro de capturas para balance no existe.",
}

idx = 0
checked = 0
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[\?\]", l):
        n = idx + 1
        if n in notas and "AUDIT 2026-10-13" not in l:
            lines[i] = l.rstrip() + " | " + notas[n]
            checked += 1
        idx += 1

txt = "\n".join(lines)
txt = txt.replace("84 [x] / 69 [?] con dueño / 0 [ ] de 153",
                  "99 [x] / 54 [?] con dueño / 0 [ ] de 153 (conteo regex real 2026-10-13; linea previa decia 84/69 de la iter 2)")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(txt)
print("anotados (M34 final):", checked)
