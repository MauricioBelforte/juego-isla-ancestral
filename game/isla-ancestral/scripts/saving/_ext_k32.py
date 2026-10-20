# -*- coding: utf-8 -*-
# Extensión K.32 M69 (boot wiring) + reporte 153
import io

P = r"DOCUMENTACION\69-Fast-Travel\plan-actual\05-Checklist.md"
s = io.open(P, encoding="utf-8").read()
ancla = "«payload inválido ignorado» (malformed sin crash). CHECKS_MINIMOS 33→37 (piso del guardián)."
ext = (ancla + "\n"
       "  **EXTENSIÓN G-5.3-Flash-Agente (tanda 23, 2026-10-19):** WIRING DE BOOT CERRADO — el gap detectado por "
       "`qa_m59_payload_sections.gd` (el payload del snapshot no contenía 'fast_travel': el servicio existía pero nadie lo "
       "montaba en la escena real) queda resuelto: `main_island.gd` ahora monta el servicio "
       "(`_crear_fast_travel_service()`, patrón `_crear_*` del archivo). Evidencia: el payload del boot pasa de 49 → **50 "
       "secciones con 'fast_travel' incluida**, el mismo QA ahora la exige como aserción dura (8/0, EXIT 0) y el boot "
       "imprime «[M69] FastTravelService listo (4 anclas, 4 desbloqueadas)» + «montado (anclas + provider fast_travel)». "
       "Regresiones: service 55/0, FX QA OK, M89 48/0 — todas EXIT 0.")
assert s.count(ancla) == 1, s.count(ancla)
s = s.replace(ancla, ext)
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
print("extension K.32 ok")
