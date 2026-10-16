# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = [
 ("Verificar que el Carpintero refleje progresi\u00f3n", "AUDIT 2026-10-14 (step-5-kilocode): reflejo parcial — ContextualDialogueManager recibe amistad_<slug> (M20) y capitulo (M22); la progresion de herramientas T1 (M13) NO es dimension del selector (L7-16). Sin verificacion por herramienta."),
 ("Verificar que la Vendedora refleje cambios econ\u00f3micos", "AUDIT 2026-10-14 (step-5-kilocode): el selector usa flag_capitulo (M22) como proxy de cambios economicos; no hay dimension economica directa (M38). Parcial por capitulo."),
 ("Verificar que el Pescador refleje cambios en el mar", "AUDIT 2026-10-14 (step-5-kilocode): sin dimension de mar/pesca en el selector; los 367 grafos cubren SALUDO/HISTORIA/MISION/AMBIENTE/AMISTAD/ESTACIONAL/HORA. No verificable."),
 ("Verificar que la Agricultora refleje impacto de cenizas", "AUDIT 2026-10-14 (step-5-kilocode): cen_001-005 existen con grafos por capitulo (5 NPCs), pero el 'impacto de cenizas' como estado de M32/M15 no es dimension del selector. No verificable."),
 ("Verificar que la Ni\u00f1a tenga di\u00e1logos innocent-appropriate", "AUDIT 2026-10-14 (step-5-kilocode): no hay etiqueta de edad/inappropriate en los datos ni en el selector; la adecuacion es de contenido (M21/M148), no verificable por estructura."),
 ("Verificar que el Animador mencione eventos/festivales", "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de feria/festival en contextual_dialogue_manager.gd; los eventos son de M74 y no alimentan el selector de M162. No verificable."),
 ("Verificar que las misiones del Carpintero sean completables", "AUDIT 2026-10-14 (step-5-kilocode): hay 19 grafos tipo MISION; la completabilidad depende de las cadenas de M23 (datos verificados) pero no hay test que cruce mision de dialogo con cadena completable."),
 ("Verificar que la Agricultora tenga remedios por estaci\u00f3n", "AUDIT 2026-10-14 (step-5-kilocode): hay grafos ESTACIONALES (generados por gen_m162_estaciones.py) y la dimension estacion (M29) si alimenta el selector; el contenido 'remedios' no se verifico nodo por nodo."),
 ("Verificar que el Animador mencione festivales de M29", "AUDIT 2026-10-14 (step-5-kilocode): idem — sin dimension de festivales en el selector; M29 alimenta hora/estacion/dia/mes, no eventos."),
 ("Verificar que la Vendedora tenga stock coherente", "AUDIT 2026-10-14 (step-5-kilocode): sin dimension de stock/economia en M162; la coherencia de stock es de M38/M16."),
]

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[\?\]", l):
        continue
    if "AUDIT 2026-10-14" in l:
        continue
    for clave, nota in notas:
        if clave in l:
            lines[i] = l.rstrip() + " | " + nota
            n += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (M162 b1):", n)
