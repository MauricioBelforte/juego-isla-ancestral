# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 "Prefab de farol con omni": "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de prefab de farol con luz omni 3200K en escenas; los 30 hits de 'farol' son de puzzles de cadenas (test_historias.gd). Dueño M18/M45 (K.2).",
 "Canvas de estrellas": "AUDIT 2026-10-14 (step-5-kilocode): sin implementar (0 hits de canvas de estrellas en scripts). Los datos de estrellas existen en fase_umbral.json pero el canvas no. Dueño M45 (K.2).",
 "Compatible con M12 minimapa": "AUDIT 2026-10-14 (step-5-kilocode): M12 minimapa SI existe en disco (scripts/mapas/mapa_manager.gd, mapa_markers.gd, test_mapa_m54.gd) — el item decía 'sin implementar'. La regla 'sin luz' está documentada en diseño §4. Requiere corrección del item, no degradación.",
 "`season_mod.tres`": "AUDIT 2026-10-14 (step-5-kilocode): NO existe (0 hits de season_mod); hay una curva anual única. K.2 visual fino.",
 "Validacion de rangos de curvas": "AUDIT 2026-10-14 (step-5-kilocode): test_curvas_luz.gd EXISTE (valida rangos en CI); M110 dev tools sin implementar. Parcial: la validación en CI existe, la de dev mode no. Dueño M110.",
 "M15 Recursos: flor lum": "AUDIT 2026-10-14 (step-5-kilocode): M15 solo tiene temporada_respawn (iter. 5); flor lumínica y cristales estelares inexistentes. Dueño M15.",
 "M17 Construccion: faroles": "AUDIT 2026-10-14 (step-5-kilocode): M17 sin faroles; el puzzle farol_cargado existe en data/cadenas (M23). Dueño M17/M18.",
 "M13 Linterna": "AUDIT 2026-10-14 (step-5-kilocode): 'Linterna' existe en equipment_manager.gd L129 (data) pero sin lógica de linterna en el mundo; el puzzle faro-linterna existe en test_historias.gd L71-72. Dueño M13 contenido + M92 sugerencia.",
 "M37 Museo: horario": "AUDIT 2026-10-14 (step-5-kilocode): scripts/museos no existe; M37 28/148. Dueño M37.",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[\?\]", l):
        continue
    if "AUDIT 2026-10-14" in l:
        continue
    for clave, nota in notas.items():
        if clave in l:
            lines[i] = l.rstrip() + " | " + nota
            n += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (M31 b2):", n)
