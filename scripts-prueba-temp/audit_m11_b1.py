# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 1: "AUDIT 2026-10-13 (step-5-kilocode): confirmado — Player.tscn L13-14 declara radius=0.4/height=1.5 (diseno pedia 0.6/1.8); divergencia documentada en el propio item.",
 2: "AUDIT 2026-10-13 (step-5-kilocode): confirmado — Player.tscn L19 serializa move_speed=5.0 y player.gd L60 lo fuerza a 25.0 en modo DEV (comment 'la escena player.tscn sobrescribe'); la suite mide 25.0.",
 3: "AUDIT 2026-10-13 (step-5-kilocode): el sprint SI esta implementado como FACTOR proporcional — player_core_m11.gd L50 VELOCIDAD_CORRER=6.5 escalando move_speed por FACTOR_SPRINT (6.5/4.2), con restauracion al soltar (L19-30). El item dice 'NO implementado (sin sprint)': DESACTUALIZADO, la evidencia en disco lo contradice.",
 4: "AUDIT 2026-10-13 (step-5-kilocode): nadar existe como elevacion — player.gd L322 velocity.y=4.0 para subir con espacio dentro del agua; no hay velocidad horizontal de nado 2.5 m/s.",
 5: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de buceo con velocidad 1.8 m/s; existe nadar-a-superficie (tecla N, player.gd L445-466) que es otro mecanismo.",
 6: "AUDIT 2026-10-13 (step-5-kilocode): confirmado — jump_force=8 con gravity=20 (Player.tscn L20-21) da 1.6 m, no 1.2 m; divergencia documentada.",
 7: "AUDIT 2026-10-13 (step-5-kilocode): gravity=20.0 confirmada (Player.tscn L20, player.gd L9) vs 12 del diseno; no hay velocidad terminal explicita (sin clamp de caida).",
 8: "AUDIT 2026-10-13 (step-5-kilocode): confirmado — la colision usa VoxelBoxMover (player.gd L16/L89) sin step-up configurable; no hay implementacion de step-up 0.6 m.",
 9: "AUDIT 2026-10-13 (step-5-kilocode): no hay sistema de aire de buceo; los hits de 'aire' son de la funcion de superficie (player.gd L458/L466), no de oxigeno.",
 10: "AUDIT 2026-10-13 (step-5-kilocode): PlayerEnergy existe (player_energy.gd, class_name PlayerEnergy, ENERGIA_MAX=100) con modelo cozy 1/min por decision del director (msg 135) — NO el 12/s drain y 8/s regen del diseno; el propio archivo documenta que 03-Diseno.md quedo como deuda documental. Ademas NO esta cableado a player.gd (comentario L24-25: 'No esta cableado a player.gd').",
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
print("anotados (M11 b1):", checked)
