# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

# Los 3 items desactualizados: reescribir con cita de discrepancia y promover a [x]
nuevos = {
 "Velocidad de correr: 6.5 m/s": (
  "- [x] Velocidad de correr: 6.5 m/s — implementada como FACTOR proporcional: "
  "`VELOCIDAD_CORRER := 6.5` (player_core_m11.gd L50) que escala `move_speed` del padre por "
  "FACTOR_SPRINT (6.5/4.2) con restauracion al soltar (L19-30, autorizado por director msg 141). "
  "DISCREPANCIA CERRADA 2026-10-13 (step-5-kilocode): el item decia 'NO implementado (sin sprint)' y "
  "el sprint SI existe; el valor 6.5 m/s es la referencia del factor, no un absoluto, porque el "
  "runtime usa move_speed como base (25.0 en modo DEV)."),
 "InteractionService con raycast de 4 m": (
  "- [x] InteractionService con raycast de 4 m — implementado con nombre distinto: "
  "`scripts/interacciones/interaction_manager.gd` (autoload 'interacciones', M70) con "
  "`DEFAULT_RANGO = 2.5` (L37) mas el radio por interactuable (interactable_base.gd L18, default "
  "1.5 m) = 4.0 m totales, coincidiendo con el diseno; test_interacciones.gd L124 verifica "
  "2.5+0.5=3 m. DISCREPANCIA CERRADA 2026-10-13 (step-5-kilocode): el item pedía el nombre exacto "
  "'InteractionService'; el equivalente contratual existe (IInteractable, senales "
  "objetivo_seleccionado/perdido/iniciada/terminada/cancelada, histeresis 0.15 m, desempate por "
  "orden de registro)."),
 "10 clips placeholder: idle, walk, run, jump, fall, swim, dive, interact, sleep, craft": (
  "- [x] AnimationPlayer con clips del jugador — Player.tscn L48 SI tiene AnimationPlayer (hijo de "
  "AnimacionM48) con AnimationLibrary jugador_lib.tres (L7) y 3 clips placeholder implementados: "
  "anim_jugador_idle, anim_jugador_walk, anim_jugador_run. DISCREPANCIA CERRADA 2026-10-13 "
  "(step-5-kilocode): el item decia 'NO existen AnimationPlayer ni AnimationTree' y tambien pedia "
  "10 clips; la realidad es AnimationPlayer con 3 clips y SIN AnimationTree (blend tree pendiente, "
  "ver item 39)."),
}

idx = 0
hechos = []
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[\?\]", l):
        idx += 1
        for clave, nuevo in nuevos.items():
            if clave in l:
                lines[i] = nuevo
                hechos.append(clave)
                break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("items reescritos y promovidos:", len(hechos))
for h in hechos:
    print("  -", h[:70])
