# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 21: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de semilla/seed en scripts/eventos/; no hay logica de determinismo por semilla de partida.",
 22: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de banners/modales en scripts/eventos/ (la UI de avisos no esta implementada en el modulo).",
 23: "AUDIT 2026-10-13 (step-5-kilocode): el consumidor existe pero esta ROTO: recompensa_def.gd L95-97 llama fs.sumar_puntos() y friendship_service.gd NO expone sumar_puntos ni modificar (API real: get_puntos, registrar_evento, aplicar_puntos vive en VecinoAmistad) -> en runtime cae al push_warning y la recompensa de amistad no se entrega.",
 24: "AUDIT 2026-10-13 (step-5-kilocode): el gancho existe pero esta DORMIDO: recompensa_def.gd L103-109 llama registrar_progreso_evento solo si M71 lo expone; el unico 'func registrar_progreso_evento' del repo esta en el test (test_event_manager_verificacion.gd L77); el propio comentario admite 'se deja el gancho; hasta entonces NO se marca entregada'.",
 25: "AUDIT 2026-10-13 (step-5-kilocode): mismo patron: recompensa_def.gd L110+ llama museo.registrar_recuerdo() por duck-typing, pero el unico 'func registrar_recuerdo' esta en el test (L71); /root/Museo no expone el metodo en produccion.",
 26: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de cargador bajo demanda de recintos (M63) en scripts/eventos/ (ver item 15).",
 27: "AUDIT 2026-10-13 (step-5-kilocode): el diseno separa UI por senales (event_manager.gd L16) pero no hay consumo de convenciones M53 en el modulo.",
 28: "AUDIT 2026-10-13 (step-5-kilocode): 0 usos reales de tr() en scripts/eventos/ (las coincidencias de 'tr(' eran de str()); las claves nombre_clave/descripcion_clave existen pero sin consumo de M57 verificado.",
 29: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de accesibilidad (M58) en banners/avisos del modulo.",
 30: "AUDIT 2026-10-13 (step-5-kilocode): el anti-FOMO anual esta implementado (event_manager.gd L9/L128, todos los eventos vuelven a PENDIENTE) y hay auditoria de catalogo (test_barrido_m74.gd L10) pero NO hay ruta alternativa de recompensas importantes via M39/M37/M23.",
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
print("anotados (M74 b3):", checked)
