# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = [
 "AUDIT 2026-10-13 (step-5-kilocode): evidencia parcial en 2 modulos: punto_partida_mundo() (island_definition.gd L114) lo consume island_travel_guard.gd L118 y hay test (test_islas_m27.gd L525-526); M28 tiene request_travel() (viajes/travel_service.gd L101). La cadena completa embarque->travesia no esta verificada como unidad.",
 "AUDIT 2026-10-13 (step-5-kilocode): sin evidencia de progreso real de IslandLoading hacia la pantalla de viaje; M63 no aparece como proveedor de progreso.",
 "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de punto_de_llegada en todo scripts/islas/.",
 "AUDIT 2026-10-13 (step-5-kilocode): marcar_visitada() existe (island_registry.gd L367, con nota M59/M54) pero tiene 0 llamadores: nunca se invoca al desembarcar.",
 "AUDIT 2026-10-13 (step-5-kilocode): ID_PRINCIPAL=aurora existe (island_travel_guard.gd L31) pero no hay logica de regreso gratis desde cualquier muelle.",
 "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de estacional/temporada en islas/; no hay consulta al calendario M29.",
 "AUDIT 2026-10-13 (step-5-kilocode): clima_tendencia es solo dato (generar_islas.gd L124); no hay consumo de M32/M31 en el flujo de viaje.",
 "AUDIT 2026-10-13 (step-5-kilocode): el flag de requisito existe (island_definition.gd L75, M22 via WorldState) pero no hay logica de boleto que-blquee/no-bloquee el regreso.",
 "AUDIT 2026-10-13 (step-5-kilocode): sin evidencia de spawn condicionado de NPC viajeros a la isla activa.",
 "AUDIT 2026-10-13 (step-5-kilocode): esta_desbloqueada() existe y esta testeada (island_registry.gd L404, test_islas_m27.gd L417-420) pero tiene 0 llamadores en produccion: ni travel_service ni el guard la consultan para atracar.",
]

idx = 0
checked = 0
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[\?\]", l):
        if 20 <= idx < 30:
            if "AUDIT 2026-10-13" not in l:
                lines[i] = l.rstrip() + " | " + notas[idx - 20]
                checked += 1
        idx += 1

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("items auditados y anotados (b3):", checked)
