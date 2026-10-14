# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 31: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de tutorial/primer festival (M92) en scripts/eventos/ (ver item 12).",
 32: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de analytics/telemetria (M104) en scripts/eventos/.",
 33: "AUDIT 2026-10-13 (step-5-kilocode): hay proteccion anti-duplicado de recompensas (recompensas_recibidas en event_state.gd + deep-copy en buzon_entregas.gd L38/47/64) pero no hay aviso claro en UI para recompensa duplicada.",
 34: "AUDIT 2026-10-13 (step-5-kilocode): _on_clima_cambio con tormenta es un stub (print + pass, event_manager.gd L176-186); no se aplica la variante cubierta ni se cancela, la escena no cambia.",
 35: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de logica de cierre normal ante tormenta a mitad de evento (ver item 8).",
 36: "AUDIT 2026-10-13 (step-5-kilocode): la compensacion al cancelar existe y esta testeada (event_manager.gd L272-283) pero el disparador 'recinto roto/corrupto' no existe y 'corrupto' no tiene prueba (solo 'faltante', item 14).",
 37: "AUDIT 2026-10-13 (step-5-kilocode): el buzon deep-copia las recompensas (buzon_entregas.gd L38/47/64) pero no hay prueba ni guarda de carga concurrente doble de eventos.",
 38: "AUDIT 2026-10-13 (step-5-kilocode): las prioridades de solape entre eventos de M74 existen (event_definition.gd L49-50, senal solape_resuelto L31) pero no hay regla cruzada cumpleanos-M29 vs feria.",
 39: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de carga/instanciacion de escena de recinto al iniciar evento (ver items 1 y 15).",
 40: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de liberacion (queue_free/free) de escenas de recinto en produccion; los unicos free() son de tests.",
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
print("anotados (M74 b4):", checked)
