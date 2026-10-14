# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 1: "AUDIT 2026-10-13 (step-5-kilocode): el campo escena_recinto existe y se serializa (event_definition.gd L61/L188) pero no hay instanciacion ni activacion del recinto por interaccion de M70.",
 2: "AUDIT 2026-10-13 (step-5-kilocode): existen senales de ciclo (evento_iniciado/terminado, event_manager.gd L22-31) pero no hay senial ni consumo de musica/ambiente festivo (M41/M42/M43).",
 3: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de minijuego/partida de festival en scripts/eventos/.",
 4: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de entrega de progreso a M71 (logros) en scripts/eventos/.",
 5: "AUDIT 2026-10-13 (step-5-kilocode): existe buzon_entregas.gd (recompensa fuera de inventario) y la senal evento_recompensa_entregada (event_manager.gd L26) pero no hay mensaje de UI 'ya recibiste la recompensa de este ano'.",
 6: "AUDIT 2026-10-13 (step-5-kilocode): _on_clima_cambio ante tormenta (event_manager.gd L176-186) es un STUB: imprime y hace pass ('la UI consumiria esta senal'); no hay intercambio real de escena.",
 7: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de reprogramacion de evento por clima severo sin variante (la senal evento_reprogramado existe, L29, pero sin esa logica).",
 8: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de logica de no-interrupcion de evento ante tormenta a mitad.",
 9: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de espera al cierre del dia para finalizar evento interrumpido.",
 10: "AUDIT 2026-10-13 (step-5-kilocode): los dialogos con variante existentes son estacionales/contextuales (M162, test_contextual_dialogue_m162.gd), no dialogos de variante cubierta para recintos techados de M21.",
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
print("anotados (M74 b1):", checked)
