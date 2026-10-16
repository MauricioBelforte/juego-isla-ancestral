# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 11: "AUDIT 2026-10-13 (step-5-kilocode): _sorpresa_semanal_count existe (event_manager.gd L41) pero no hay logica de reprogramar la sorpresa descartada a otro dia.",
 12: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de tutorial/primer festival (M92) en scripts/eventos/.",
 13: "AUDIT 2026-10-13 (step-5-kilocode): la recompensa compensatoria al cancelar esta implementada y testeada (event_manager.gd L272-283, test_event_manager_verificacion.gd L294) pero falta el disparador: nadie llama _finalizar_evento(cancelado=true) por fallo de escena de M63 (0 llamadores en produccion).",
 14: "AUDIT 2026-10-13 (step-5-kilocode): evidencia parcial — recinto FALTANTE no crashea (test_barrido_m74.gd L139 'evento sin escena_recinto no crashea' + load() con null-safe en L84); recinto CORRUPTO no tiene prueba ni manejo.",
 15: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de carga de recintos bajo demanda/streaming (M63) en scripts/eventos/.",
 16: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de avisos accesibles con texto e icono (M58) en scripts/eventos/.",
 17: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de opcion de pausar avisos de eventos.",
 18: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de alto contraste en banners de evento.",
 19: "AUDIT 2026-10-13 (step-5-kilocode): los nombres/descripciones existen como CLAVES de localizacion (nombre_clave/descripcion_clave, event_definition.gd L178-179) pero 0 usos de tr() en scripts/eventos/ (los hits de 'tr(' eran falsos positivos de str(); no hay consumo de M57 verificado).",
 20: "AUDIT 2026-10-13 (step-5-kilocode): hay texto hardcodeado en espanol en prints de debug (event_manager.gd L168 'Buzon: %d entregas purgadas...' y similares); no se verifico texto de UI.",
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
print("anotados (M74 b2):", checked)
