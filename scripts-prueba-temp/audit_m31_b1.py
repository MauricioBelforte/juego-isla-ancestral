# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 "P6: estrellas": "AUDIT 2026-10-14 (step-5-kilocode): RESPALDADO — data/light/fase_umbral.json tiene estrellas.alpha_inicio=20, alpha_fin=22, alpha_max=1.0, descripcion 'suben de 0 a 100% entre 20:00 y 22:00 (diseno P6)'. El canvas procedural lo consume day_night_cycle.gd.",
 "P7: luna": "AUDIT 2026-10-14 (step-5-kilocode): PARCIAL — day_night_cycle.gd L54 carga moon_curve.tres (Curva) para la luz de luna; la esfera con textura de fases es de M45 (K.2), no de M31.",
 "P8: nubes": "AUDIT 2026-10-14 (step-5-kilocode): sin implementar (0 hits de nubes/velo/drift en scripts/islas ni world); escenico V2 (K.2). Deuda de M45.",
 "P11: niebla": "AUDIT 2026-10-14 (step-5-kilocode): PARCIAL — fase_umbral.json §niebla apunta a res://data/light/fog_curve.tres (Curva data-driven); el nodo FogVolume no existe en escenas .tscn (0 hits). La data existe, el nodo no.",
 "P17: spawn de recursos": "AUDIT 2026-10-14 (step-5-kilocode): M15 tiene temporada_respawn (iter. 5) pero sin ventana horaria; el spawn nocturno opcional no esta implementado. Deuda de M15/M10.",
 "P19: eventos nocturnos": "AUDIT 2026-10-14 (step-5-kilocode): datos de estrellas existen en JSON; el evento de calendario es de M74 y las particulas de M52; la cadena completa no esta implementada.",
 "P20: secretos nocturnos": "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de flora brillante ni murales lore; duenos M15/M25/M148 (seccion G). Deuda externa.",
 "Luna esferica con textura": "AUDIT 2026-10-13 (step-5-kilocode): luz sin mesh — day_night_cycle.gd usa DirectionalLight3D para la luna; la esfera con textura de fases es de M45 (K.2).",
 "Nubes velo 2D": "AUDIT 2026-10-14 (step-5-kilocode): sin implementar (0 hits en scripts/islas ni world). Deuda de M45 (K.2).",
 "Niebla (FogVolume": "AUDIT 2026-10-14 (step-5-kilocode): data fog_curve.tres existe (fase_umbral.json §niebla) pero el nodo FogVolume no existe en ninguna escena .tscn (0 hits).",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[\?\]", l):
        continue
    for clave, nota in notas.items():
        if clave in l and "AUDIT 2026-10-14" not in l:
            lines[i] = l.rstrip() + " | " + nota
            n += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (M31 b1):", n)
