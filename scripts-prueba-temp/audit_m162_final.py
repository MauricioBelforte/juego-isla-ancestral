# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = [
 ("Verificar coherencia de CEN con eventos de M22", "AUDIT 2026-10-14 (step-5-kilocode): flag_capitulo (M22) SI alimenta el selector; grafos de cen_001-005 por capitulo. Coherencia por capitulo respaldada; por evento (M74) no."),
 ("Verificar coherencia del Encantador con sistema de encantamientos", "AUDIT 2026-10-14 (step-5-kilocode): M158 sin datos en disco (no existe data/m158). No verificable."),
 ("Verificar que la Sanadora tenga pociones por cap\u00edtulo", "AUDIT 2026-10-14 (step-5-kilocode): grafos de cen_005 existen por capitulo; contenido 'pociones' no verificado nodo por nodo."),
 ("Verificar que el Guardia Ancestral mencione el templo", "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de 'templo' en los 367 grafos; M160 sin datos de templo en disco. No verificable."),
 ("Verificar que el Artista mencione ubicaciones de M160", "AUDIT 2026-10-14 (step-5-kilocode): M160 sin datos de ubicaciones en disco. No verificable."),
 ("Verificar que el Encantador mencione magia de AUR", "AUDIT 2026-10-14 (step-5-kilocode): grafos de aur_005 existen; 'magia de AUR' como contenido no verificado nodo por nodo."),
 ("Verificar que la Sanadora tenga remedios de hierbas de AUR", "AUDIT 2026-10-14 (step-5-kilocode): grafos ESTACIONALES de aur_003 existen (gen_m162_estaciones.py); contenido 'remedios de hierbas' no verificado."),
 ("Verificar coherencia de AUR con eventos de M22", "AUDIT 2026-10-14 (step-5-kilocode): flag_capitulo (M22) alimenta el selector; grafos de aur_001-005 por capitulo. Por capitulo respaldada; por evento no."),
 ("Verificar que el Guardia Ancestral proteja templo consistentemente", "AUDIT 2026-10-14 (step-5-kilocode): sin dimension de proteccion/templo en el selector; no verificable por estructura."),
 ("Verificar que las franjas horarias generan di\u00e1logos diferentes", "AUDIT 2026-10-14 (step-5-kilocode): la dimension hora/es_de_noche SI alimenta el selector (L15) y hay 23 grafos generados por noche (gen_m162_noche.py); las franjas horarias completas y el conteo esperado no estan definidos como dato verificable."),
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
print("anotados (M162 final):", n)
