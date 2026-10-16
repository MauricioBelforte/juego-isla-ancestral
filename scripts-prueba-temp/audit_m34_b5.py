# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/34-Pesca/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 41: "AUDIT 2026-10-13 (step-5-kilocode): la sesion tiene cancelar() sin castigo (fishing_session.gd L99 'chunk descargado, pausa prolongada') pero no hay chequeo de distancia jugador-spot: falta la posicion del jugador (M11) y el rango real (spot_apunta_desde ignora rango, item 14).",
 42: "AUDIT 2026-10-13 (step-5-kilocode): es_agua_pescable() es stub return true (fishing_spot.gd L29-30), tierra firme y agua decorativa se aceptan por igual; rechazo suave inexistente.",
 43: "AUDIT 2026-10-13 (step-5-kilocode): las timers son SceneTreeTimer pausables con get_tree().paused (fishing_session.gd L8/L24-25/L46/L60) — el mecanismo base existe; el edge case especifico de pausa en fase A/B no tiene prueba dedicada.",
 44: "AUDIT 2026-10-13 (step-5-kilocode): no hay flotador fisico (items 17/18) ni recogida automatica; FishingManager si persiste peces sueltos anti-perdida (L39) pero eso es otro mecanismo.",
 45: "AUDIT 2026-10-13 (step-5-kilocode): spot_apunta_desde devuelve el PRIMER spot registrado valido (fishing_manager.gd L114-119, comentario 'Con M51 no integrado') — no hay seleccion por centro del rayo ni desempate.",
 46: "AUDIT 2026-10-13 (step-5-kilocode): la FSM admite notificar_pulsacion_boton() programatica (fishing_session.gd L63) pero el toggle de captura automatica es de M57 y no existe.",
 47: "AUDIT 2026-10-13 (step-5-kilocode): dueno M57/M53; sin opciones de contraste para las ventanas del minijuego.",
 48: "AUDIT 2026-10-13 (step-5-kilocode): dueno M57/M52; los efectos base (ondulaciones/brillos) tampoco existen (items 38-40).",
 49: "AUDIT 2026-10-13 (step-5-kilocode): data/balance/fishing.json tiene 4 cebos y 3 canas, 0 con precio_compra — el balance sin grind en M93/M38 no esta hecho.",
 50: "AUDIT 2026-10-13 (step-5-kilocode): 'sin combate' si esta garantizado por diseno (sesion sin castigos, captura_fallida no punitivo L227) pero la presentacion suave (burbujas doradas) es data M93 + VFX M52, inexistentes.",
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
print("anotados (M34 b5):", checked)
