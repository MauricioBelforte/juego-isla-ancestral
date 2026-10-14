# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 "Lluvia de estrellas: d\u00edas 10 y 25": "AUDIT 2026-10-14 (step-5-kilocode): fase_umbral.json \u00a7estrellas documenta la ventana 20:00-22:00; el evento de calendario (dias 10/25) y las particulas son de M74/M52 sin implementar. Data parcial, implementacion externa.",
 "Part\u00edculas de estrellas fugaces": "AUDIT 2026-10-14 (step-5-kilocode): M52 sin implementar (0 hits de particulas de estrellas en scripts). Dueno M52.",
 "Interacci\u00f3n \"observar\" del lince": "AUDIT 2026-10-14 (step-5-kilocode): el lince no existe en data/fauna/catalog.json (7 especies). Dueno M36.",
 "Flora brillante: Senda de las Luci\u00e9rnagas": "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de flora brillante o senda de luciernagas; M15 contenido + M45 assets sin crear.",
 "Murales luminosos en ruinas (M25, lore M148)": "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de murales luminosos; duenos M25/M148.",
 "Diario M55 registra": "AUDIT 2026-10-14 (step-5-kilocode): M55 sin implementar (0 hits de diario en scripts). Dueno M55.",
 "TTS/texto accesible": "AUDIT 2026-10-14 (step-5-kilocode): M58 sin implementar para TTS; dueno M58.",
 "Linterna del jugador": "AUDIT 2026-10-14 (step-5-kilocode): data 'Linterna' existe en equipment_manager.gd L129 pero sin logica de mundo; dueno M13/M45.",
 "Opci\u00f3n M58 \"Noche clara\"": "AUDIT 2026-10-14 (step-5-kilocode): M58 sin implementar; el piso es constante en curva, el hook seria parametrizar sky_curve (K.2). Dueno M58.",
 "Faroles cada 40 m en poblado": "AUDIT 2026-10-14 (step-5-kilocode): prefab farol inexistente; M18-BIS WorkBuddy esta construyendo casas — coordinar al liberar. Dueno M18/M45.",
 "Minimapa operable de noche": "AUDIT 2026-10-14 (step-5-kilocode): M12 minimapa SI existe en disco (mapa_manager.gd) pero sin modo nocturno; dueno M12.",
 "QA M114: checklist visual nocturno": "AUDIT 2026-10-14 (step-5-kilocode): M114 sin implementar; QA visual del usuario o agente con vision. Dueno M114.",
 "1 draw call de nubes": "AUDIT 2026-10-14 (step-5-kilocode): sin nubes (D); la regla queda para el dueno escenico (M45).",
 "Test: umbral farol antes/despu\u00e9s": "AUDIT 2026-10-14 (step-5-kilocode): sin autoswitch runtime (RF6 [?]); el test se escribira con la feature. Dueno M18/M45.",
 "Transici\u00f3n amanecer/atardecer": "AUDIT 2026-10-14 (step-5-kilocode): day_night_cycle.gd tiene curvas de interpolacion (Curve) para transiciones; el polish de 90 s especifico no esta parametrizado. Parcial.",
 "`Sky` procedural con gradiente": "AUDIT 2026-10-14 (step-5-kilocode): fase_umbral.json tiene curvas de sol/luna/cielo; el Sky procedural con gradiente por hora es de M45 (K.2). Data parcial, escenico externo.",
 "Luna esf\u00e9rica con textura de fases (M45)": "AUDIT 2026-10-14 (step-5-kilocode): luz DirectionalLight3D sin mesh; textura de fases de M45 (K.2).",
 "Niebla por estaci\u00f3n/hora": "AUDIT 2026-10-14 (step-5-kilocode): fog_curve.tres existe (data) pero el nodo FogVolume no esta en escenas; la variacion por estacion/hora no esta implementada. Data parcial, nodo ausente.",
 "Faroles cada 40 m en poblado (M18)": "AUDIT 2026-10-14 (step-5-kilocode): prefab farol inexistente; dueno M18/M45.",
 "Sincronizaci\u00f3n lluvia de estrellas": "AUDIT 2026-10-14 (step-5-kilocode): fase_umbral.json §estrellas tiene la ventana; la sincronizacion con M52 (dias 10/25) es de M74/M52 sin implementar.",
 "Flora brillante con bonus x2": "AUDIT 2026-10-14 (step-5-kilocode): hook es_de_dia() existe (game_clock.gd L120, time_calendar.gd L155, day_night_cycle.gd L207); el bonus x2 es de M15/M93 sin implementar.",
 "Opci\u00f3n M58 \"Noche clara\" (piso 0.35)": "AUDIT 2026-10-14 (step-5-kilocode): M58 sin implementar; el hook seria parametrizar sky_curve (K.2). Dueno M58.",
 "Integraci\u00f3n con M49": "AUDIT 2026-10-14 (step-5-kilocode): M49 sin implementar (0 hits de integracion de iluminacion global). Dueno M49.",
 "QA visual M114 (checklist nocturno": "AUDIT 2026-10-14 (step-5-kilocode): M114 sin implementar; QA visual del usuario o agente con vision. Dueno M114.",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[\?\]", l):
        continue
    if "AUDIT 2026-10-14" in l:
        continue
    for clave, nota in notas.items():
        if clave in l:
            lines[i] = l.rstrip() + " | " + nota
            n += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (M31 b3 ampliado):", n)
