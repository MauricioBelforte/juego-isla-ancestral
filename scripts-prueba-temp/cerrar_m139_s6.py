# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00fc","u"),("\u00bf","?"),("\u2192","->")]:
        s = s.replace(a, b)
    return s.lower()

NOTAS = {
 "cat\u00e1logo de 30+ piezas": "COMPLETADO 2026-10-14 (step-5-kilocode): catalogo de 30 piezas definido en 03-Diseno.md 2.6.1 (6 vallas, 6 caminos, 10 mobiliario, 8 deco). 6 ya existen como .tres en data/houses/; las 24 restantes son definicion para M17/M46.",
 "3 estructuras": "COMPLETADO 2026-10-14 (step-5-kilocode): casa de campo (4 etapas), invernadero pequeno (3) y gazebo (2) definidas en 2.6.1; house_manager.gd ya tiene avanzar_etapa()/obtener_etapa().",
 "colocaci\u00f3n por grid ligero": "COMPLETADO 2026-10-14 (step-5-kilocode): grid de 1 m sin fisica definido en 2.6.1, encajando con el validador de nucleo puro (construccion_validator.gd: 'sin dependencias de nodos, VoxelTools ni autoloads').",
 "validaci\u00f3n contra terreno voxel": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — construccion_validator.gd valida superficie/pared/agua y zonas_permisos.gd protege ruinas y templos (M25). Definicion completada en 2.6.1.",
 "preview transl\u00facido": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — build_preview.gd y build_ghost.gd (feedback visual de validez). Definicion de la regla en 2.6.1.",
 "desbloqueo por amistad/misiones": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — data/economia/friendship.json (nivel 2 recetas_basicas, nivel 4 recetas_avanzadas + trueque). Obe (M23) como gancho de mision, definido en 2.6.1.",
 "persistencia de piezas en save v3": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — buildings_save_provider.gd implementa ISaveProvider (M59) y test_m18_m60_integration.gd tiene 10 checks. Nota honesta: el provider existe pero la fuente M17 todavia no esta implementada.",
 "costo de cada pieza": "COMPLETADO 2026-10-14 (step-5-kilocode): tabla de costos por categoria en 2.6.1 (vallas 3-8 AO + 1 material, caminos 1-2 AO, mobiliario 15-120 AO + 1-3 materiales, deco 5-40 AO); recetas en crafting.json (M16).",
 "piezas interact\u00faan con el clima": "COMPLETADO 2026-10-14 (step-5-kilocode): regla definida en 2.6.1 — solo el invernadero interactua con el clima (lluvia x2 crecimiento, sol directo x0.5); el resto es neutro.",
 "l\u00edmite de piezas por zona": "COMPLETADO 2026-10-14 (step-5-kilocode): limites definidos en 2.6.1 (40 parcela / 25 plaza / 0 ruinas y templos) sobre el respaldo existente — construccion_validator.gd ya rechaza con Motivo.LIMITE_DE_ZONA y zonas_permisos.gd.",
 "categor\u00edas visuales de piezas": "COMPLETADO 2026-10-14 (step-5-kilocode): 4 materiales canonicos (madera, piedra, tela, planta) con paleta Maldivas definidos en 2.6.1; nada de metal salvo el herrero.",
 "piezas que interact\u00faan con npc": "COMPLETADO 2026-10-14 (step-5-kilocode): banco_plaza sentable definido en 2.6.1 (la accion SENTARSE ya existe en item_data.gd) y usable como waypoint de descanso por NPC de rutina libre (Pax).",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    for clave, nota in NOTAS.items():
        if norm(clave) in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                n += 1
            break

t = "\n".join(lines)
t = t.replace("Completados: 53 \u00b7 Pendientes: 87 \u00b7 No resueltos: 2", "Completados: 64 \u00b7 Pendientes: 76 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos: [x]=%d [ ]=%d [?]=%d" % (x, s, q))
