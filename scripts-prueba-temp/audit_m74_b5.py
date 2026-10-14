# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 41: "AUDIT 2026-10-13 (step-5-kilocode): hay conversiones defensivas a StringName (event_manager.gd L631/712/715) pero los diccionarios del modulo no estan tipados con clave StringName de forma uniforme.",
 42: "AUDIT 2026-10-13 (step-5-kilocode): el manager escucha anio_cambio (comentario L15) pero no hay escritura diferida unica del historial al fin de ano (la purga es por dia, L165-170).",
 43: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de UI de agenda con reciclado de instancias en el modulo (los 'instancia' son de tests).",
 44: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de animacion/tween en banners de evento.",
 45: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de monitoreo de allocate de strings en bucles de agenda.",
 46: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de test de frame budget con Profiler para el modulo.",
 47: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de medicion de memoria del catalogo cargado.",
 48: "AUDIT 2026-10-13 (step-5-kilocode): no existe suite test_clima planificada para variante cubierta y traslado (los tests existentes cubren otro frente).",
 49: "AUDIT 2026-10-13 (step-5-kilocode): no existe caso de carga concurrente sin clonacion planificado (ver item 37).",
 50: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de medicion de frame budget con Profiler en escena de festival.",
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
print("anotados (M74 b5):", checked)
