# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 11: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de magnetismo/luz en scripts/player/; no hay sistema de luz ni esporas.",
 12: "AUDIT 2026-10-13 (step-5-kilocode): NO existe InteractionService con ese nombre, pero el equivalente de M70 existe y tiene rango: interaction_manager.gd (autoload 'interacciones') con DEFAULT_RANGO=2.5 + radio por interactuable (interactable_base.gd L18 documenta 1.5 m por defecto -> 4.0 m totales, coincide con el diseno); test_interacciones.gd L124 verifica 2.5+0.5=3 m.",
 13: "AUDIT 2026-10-13 (step-5-kilocode): confirmada la correccion del item — el equivalente es scripts/interacciones/interaction_manager.gd (autoload, M70) con contrato IInteractable, senales objetivo_seleccionado/objetivo_perdido/interaccion_iniciada/terminada/cancelada/estado_cambiado (L24-29), histeresis 0.15 m (L38) y desempate por orden de registro.",
 14: "AUDIT 2026-10-13 (step-5-kilocode): no hay highlight del objetivo del jugador; los unicos highlights son de herramientas/preview (tool_controller.gd L59, preview_herramientas.gd), que es otro frente.",
 15: "AUDIT 2026-10-13 (step-5-kilocode): el manager tiene histeresis y orden de registro como desempate (interaction_manager.gd L38 y comentario L12) pero NO hay seleccion por centro de rayo: la seleccion es por distancia (L207-208).",
 16: "AUDIT 2026-10-13 (step-5-kilocode): el HUD del prompt EXISTE — hud_screen.gd L17 referencia %InteractPrompt y scripts/ui/hud/interact_prompt.gd implementa show_prompt(text)/hide_prompt() (consumido por M70); el texto localizable (M57) no esta verificado en el prompt.",
 17: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de esporas/luz en scripts/player/; sin sistema de luz.",
 18: "AUDIT 2026-10-13 (step-5-kilocode): sin magnetismo ni animacion de entrada de 0.3 s.",
 19: "AUDIT 2026-10-13 (step-5-kilocode): PlayerLightInventory no existe; la recepcion de esporas es de M14, modulo separado.",
 20: "AUDIT 2026-10-13 (step-5-kilocode): no hay HUD de luz total (6 esferas).",
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
print("anotados (M11 b2):", checked)
