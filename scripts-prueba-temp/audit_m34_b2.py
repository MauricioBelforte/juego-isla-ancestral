# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/34-Pesca/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 11: "AUDIT 2026-10-13 (step-5-kilocode): FishingSpot.bioma es un int que 'lo informa M51' (fishing_spot.gd L15) con get_bioma() L32; la derivacion desde voxel/chunk no existe en M34.",
 12: "AUDIT 2026-10-13 (step-5-kilocode): get_punto_impacto() devuelve global_position directo (fishing_spot.gd L35-36); el calculo sobre la superficie del agua (raycast/nivel de mar) no existe.",
 13: "AUDIT 2026-10-13 (step-5-kilocode): activar_marcador_visual() solo visible=true; desactivar_marcador_visual() es pass (fishing_spot.gd L38-42) — sin ondulaciones ni burbujas (M52).",
 14: "AUDIT 2026-10-13 (step-5-kilocode): rango_lanzamiento existe en FishingRod (L12) y se carga de datos (fishing_manager.gd L97) pero spot_apunta_desde IGNORA el rango: devuelve el primer spot registrado sin medir distancia (comentario 'Con M51 no integrado').",
 15: "AUDIT 2026-10-13 (step-5-kilocode): el contrato activar_marcador_visual existe pero el trigger 'al equipar la cana' no esta cableado (M53/M13).",
 16: "AUDIT 2026-10-13 (step-5-kilocode): prueba pendiente de M51 (biomas reales) y M93 (peces por bioma); no ejecutable hoy.",
 17: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de RigidBody/parabola en scripts/fishing/; la sesion (fishing_session.gd: calcular_espera, lanzar, _abrir_ventana) es logica pura sin flotador visible — stub declarado en el propio item.",
 18: "AUDIT 2026-10-13 (step-5-kilocode): idem — get_punto_impacto() es el contrato pero no hay objeto flotador fisico que quede en el punto.",
 19: "AUDIT 2026-10-13 (step-5-kilocode): time_calendar.gd tiene signal evento_activado (L13) y _on_evento_activado (L101) pero fishing_manager.gd tiene 0 hits de festival/evento: M34 no consume el bono temporal.",
 20: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de DonationService/marcar_disponible en pesca; M34 si tiene entrega_museo() (fishing_manager.gd) como contrato pero el estado 'disponible' lo computa M37.",
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
print("anotados (M34 b2):", checked)
