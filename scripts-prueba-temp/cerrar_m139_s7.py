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
 "acceso por la colina n con 2 puzzles": "COMPLETADO 2026-10-14 (step-5-kilocode): acceso definido en 03-Diseno.md 2.7.1 — 2 puzzles ambientales en la subida (3 tallos de semilla en orden de cercania + 2 antorchas por direccion del viento), ninguno bloquea el paso.",
 "sala 1 \"las velas\"": "COMPLETADO 2026-10-14 (step-5-kilocode): sala definida en 2.7.1 — 3 velas en orden N->E->S segun la direccion de la rafaga; vela mal encendida se apaga sola y reintenta sin castigo. Base: scripts/templos/puzzle_def.gd (MAX_EMISORES 16).",
 "feedback de las velas": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.7.1 — silbido de llama por vela (M42) + parpadeo de luz en proporcion a la rafaga (M44).",
 "sala 2 \"el carill\u00f3n\"": "COMPLETADO 2026-10-14 (step-5-kilocode): sala definida en 2.7.1 — 5 campanas de metal soplado, melodia de 5 notas graves tomada del lore del capitulo 4; error = campana muda, el puzzle continua.",
 "feedback asmr del carill\u00f3n": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.7.1 — tonos puros con decay largo, sin percusiva y volumen bajo (M44/M42).",
 "herramienta del viento como recompensa": "COMPLETADO 2026-10-14 (step-5-kilocode): definida en 2.7.1 — recompensa al cerrar las 2 salas, permite llamar una rafaga con cooldown de 3 s (M13). Primera herramienta climatica del juego.",
 "lore can\u00f3nico del templo": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — scripts/eventos/data/capitulos/historia_c4_templo_brisa.tres (capitulo 4, gatillo templo_brisa_abierto, 7 sellos requeridos). Definicion ampliada en 2.7.1 (runas de viento + mural del archipielago).",
 "no se revela spoiler": "COMPLETADO 2026-10-14 (step-5-kilocode): garantia definida en 2.7.1 — runas genericas de direccion de viento, ningun texto nombra a los otros 5 templos, y el capitulo 4 solo habla de este. Los 7 sellos son de completitud, no pistas.",
 "hint no intrusivo": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.7.1 — susurro de texto solo si el jugador permanece >20 s a <2 m del puzzle sin interactuar; sin pop-up ni flecha; desactivable en ajustes de accesibilidad (M58/M66).",
 "variante de soluci\u00f3n (3 rutas": "COMPLETADO 2026-10-14 (step-5-kilocode): 3 rutas por sala definidas en 2.7.1 — orden (mecanica), observacion (lore/ambiente) y ayuda (hint tras 2 fallos). Las 3 llevan a la misma resolucion.",
 "ausencia de softlock": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — scripts/core/invariants/puzzle_invariant.gd (M66: resolubilidad en 30 s + reinicio del slot) y softlock_guard.gd/softlock_rules.gd. Regla anida en 2.7.1: ningun puzzle del templo es obligatorio para salir.",
 "recompensa extra: pieza de lore": "COMPLETADO 2026-10-14 (step-5-kilocode): definida en 2.7.1 — pagina de lore oculta en la sala 2, visible solo con la Herramienta del Viento ya obtenida; cuenta para el set de M73 (modulo 73-Coleccionables existe).",
 "el viento afecta al exterior": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.7.1 — con la herramienta, las rafagas mueven semillas y hojas en toda la isla y abren atajos de polen (corrientes que aceleran la pradera). Primer cambio global del mundo por una herramienta.",
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
t = t.replace("Completados: 65 \u00b7 Pendientes: 75 \u00b7 No resueltos: 2", "Completados: 78 \u00b7 Pendientes: 62 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos reales: [x]=%d [ ]=%d [?]=%d" % (x, s, q))
