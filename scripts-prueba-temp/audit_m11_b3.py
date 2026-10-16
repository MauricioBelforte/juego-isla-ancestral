# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 21: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de recogida de esporas/luz en scripts/player/; el sistema de luz no existe (ver item 11).",
 22: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de audio de recogida de esporas.",
 23: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de light_collected en todo game/isla-ancestral/scripts/; EventBus existe (event_bus.gd) pero sin esa senal.",
 24: "AUDIT 2026-10-13 (step-5-kilocode): sin destellos en streaming lejano; no hay entidades de luz para streamear.",
 25: "AUDIT 2026-10-13 (step-5-kilocode): no hay esporas que recoger ni persistencia de recogida (M59 no lleva este estado).",
 26: "AUDIT 2026-10-13 (step-5-kilocode): PlayerEnergy ES informativo por diseno — player_energy.gd L13/L41/L57: umbral de fatiga 30% 'informativo, no bloqueante' y la regla cozy impide que baje por caminar/correr; pero el modelo NO esta cableado a player.gd (comentario L24-25), asi que en runtime no hay nada que bloquee ni informe.",
 27: "AUDIT 2026-10-13 (step-5-kilocode): no hay barra de stamina con fade; PlayerEnergy.expone en_fatiga() pero ningun HUD lo consume (M53).",
 28: "AUDIT 2026-10-13 (step-5-kilocode): UMBRAL_FATIGA=30.0 existe en el modelo (player_energy.gd L41) con _fatiga_avisada (L45); el icono suave en HUD es de M53 y no existe.",
 29: "AUDIT 2026-10-13 (step-5-kilocode): sin vibracion ni tinte de bordes al 30% (M53).",
 30: "AUDIT 2026-10-13 (step-5-kilocode): confirmado — no hay sistema de dano por caida en player.gd (los hits de 'fall' son del fallback de mano M13 y del suelo fantasma); la amortiguacion >3 bloques no esta implementada.",
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

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (M11 b3):", checked)
