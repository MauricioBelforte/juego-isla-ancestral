# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 "M32 Clima: lluvia de estrellas": "AUDIT 2026-10-14 (step-5-kilocode): verificado — weather_service.gd (scripts/clima/) tiene enum Clima {SOLEADO, NUBLADO, LLUVIA, TORMENTA, NIEBLA, NIEVE, VIENTO...} SIN 'lluvia de estrellas'; el evento es de M74 + particulas M52. Confirmado.",
 "Lluvia de estrellas: dias 10 y 25": "AUDIT 2026-10-14 (step-5-kilocode): fase_umbral.json §estrellas documenta la ventana 20:00-22:00; el evento de calendario (dias 10/25) y las particulas son de M74/M52 sin implementar. Data parcial, implementacion externa.",
 "Particulas de estrellas fugaces": "AUDIT 2026-10-14 (step-5-kilocode): M52 sin implementar (0 hits de particulas de estrellas en scripts). Dueño M52.",
 "Lince de luna": "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de lince en data/fauna/catalog.json (7 especies: gaviota_playera, conejo_pradera, nutria_ribera, lechuza_bosque, salamandra_ancestral, cangrejo_humedal, halcon_montana). Fauna especial de M36/M93 sin crear.",
 "Interaccion observar del lince": "AUDIT 2026-10-14 (step-5-kilocode): idem — el lince no existe en el catalogo de fauna. Dueño M36.",
 "Flora brillante: Senda de las Luciernagas": "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de flora brillante o senda de luciernagas; M15 contenido + M45 assets sin crear.",
 "Bono x2 de noche en flora": "AUDIT 2026-10-14 (step-5-kilocode): hook futuro — es_de_dia() EXISTE en game_clock.gd L120, time_calendar.gd L155 y day_night_cycle.gd L207 (los consumidores pueden leerlo); la implementacion del bono es de M15/M93.",
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
print("anotados (M31 b3):", n)
