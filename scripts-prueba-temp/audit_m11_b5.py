# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 41: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de pasos por superficie (footstep) ligados al jugador; los hits de 'pasos' son de escalas UI de accesibilidad.",
 42: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de audio de salto/aterrizaje en scripts/player/.",
 43: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de splash de entrada/salida de agua.",
 44: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de chirrido de interaccion por material.",
 45: "AUDIT 2026-10-13 (step-5-kilocode): assets finales de personaje pendientes de M65 (terceros); no verificable desde M11.",
 46: "AUDIT 2026-10-13 (step-5-kilocode): no-aplicable hoy — sin audio de pasos ni saltos no hay loops que solapar.",
 47: "AUDIT 2026-10-13 (step-5-kilocode): no-aplicable hoy — sin audio de personaje no hay capas que mezclar (M53).",
 48: "AUDIT 2026-10-13 (step-5-kilocode): confirmado — el directorio game/isla-ancestral/data/player/ NO EXISTE (hay 80 carpetas de datos, ninguna es 'player'); las constantes viven hardcodeadas en player.gd (move_speed L8, gravity L9, jump_force L10).",
 49: "AUDIT 2026-10-13 (step-5-kilocode): idem — no existe player_motion.tres ni equivalente; las constantes fisicas estan en el script y en Player.tscn L19-21.",
 50: "AUDIT 2026-10-13 (step-5-kilocode): no existe GameState con seccion M11; player_save_provider.gd (M59) guarda name/position/spawn_position/zone con duck-typing y trata spawn_position como punto de reanudacion, no spawn real — energetgia/stamina/FSM no se persisten.",
 51: "AUDIT 2026-10-13 (step-5-kilocode): caida sin dano confirmada (no hay sistema de dano) pero sin amortiguacion; buceo y sprint — el sprint SI existe como factor (player_core_m11.gd L50) aunque el buceo no; la triada anti-frustration no esta completa.",
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
print("anotados (M11 b5/final):", checked)
