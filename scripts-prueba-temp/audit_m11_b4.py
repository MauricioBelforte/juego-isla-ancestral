# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 31: "AUDIT 2026-10-13 (step-5-kilocode): el modelo de energia es estructuralmente sin deuda (regen 1/min SIEMPRE, player_energy.gd L11-13) pero el hueco de fatiga del sprint no esta medido ni expuesto; el modelo no esta cableado a player.gd.",
 32: "AUDIT 2026-10-13 (step-5-kilocode): player_core_m11.gd L254-260 tiene recargar_dormir()/recargar_descanso() (reglas L67/L68) pero nadie las invoca desde el ciclo dia/noche M29: 0 llamadores.",
 33: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de alimentos/bienestar en player.gd; no hay consumo de comida para energia.",
 34: "AUDIT 2026-10-13 (step-5-kilocode): sin aviso suave por dormir poco; las rutinas de descanso existen (recargar_dormir) pero sin disparador.",
 35: "AUDIT 2026-10-13 (step-5-kilocode): no hay toggle hold/alternate de sprint en settings; player_core_m11.gd aplica el factor al mantener la accion de correr.",
 36: "AUDIT 2026-10-13 (step-5-kilocode): la validacion cozy es de diseno (regla L70 en player_energy.gd: 'la energia NUNCA llega a cero por caminar o correr'); no hay test automatizado que la verifique en runtime.",
 37: "AUDIT 2026-10-13 (step-5-kilocode): player_core_m11.gd L19-30 documenta que RESTAURA move_speed al soltar el sprint (sin penalizar la siguiente accion); verificado en el codigo del adaptador.",
 38: "AUDIT 2026-10-13 (step-5-kilocode): Player.tscn SI tiene AnimationPlayer (L48, hijo de AnimacionM48) con AnimationLibrary jugador_lib.tres (L7) — pero la libreria solo tiene 3 clips placeholder: anim_jugador_idle, anim_jugador_walk, anim_jugador_run. Faltan jump, fall, swim, dive, interact, sleep, craft.",
 39: "AUDIT 2026-10-13 (step-5-kilocode): no existe AnimationTree en Player.tscn (solo AnimationPlayer); el blend tree walk<->run no existe. animacion_jugador_m48.gd documenta el mapeo FSM->clips con los 3 placeholders.",
 40: "AUDIT 2026-10-13 (step-5-kilocode): sin AnimationTree no hay crossfade; el item es no-aplicable mientras no existan mas clips.",
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
print("anotados (M11 b4):", checked)
