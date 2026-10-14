# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = [
 ("Verificar coherencia de COR con eventos de M22", "AUDIT 2026-10-14 (step-5-kilocode): la dimension flag_capitulo (M22, 0-7) SI alimenta el selector (L13); los grafos de cor_001-005 existen por capitulo. Coherencia por capitulo respaldada; por evento (M74) no."),
 ("Verificar coherencia del Herrero Avanzado con sistema de hierro", "AUDIT 2026-10-14 (step-5-kilocode): 4 grafos mencionan 'forja'; M158 no tiene datos en disco (no existe data/m158). Coherencia no verificable."),
 ("Verificar que el Minero mencione minerales", "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de 'mineral' en los 367 grafos; M160 no tiene datos de minerales en disco. No verificable."),
 ("Verificar que la Cocinera tenga recetas por cap\u00edtulo", "AUDIT 2026-10-14 (step-5-kilocode): grafos de cen_003 existen por capitulo; el contenido 'recetas' no se verifico nodo por nodo. Parcial."),
 ("Verificar que el Bibliotecario revele lore gradual", "AUDIT 2026-10-14 (step-5-kilocode): la dimension flag_capitulo (M22) permite revelado gradual por capitulo; el contenido lore del Bibliotecario no se verifico nodo por nodo. Parcial."),
 ("Verificar que el Guardia mencione la mina", "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de 'mina' en los 367 grafos; M160 no tiene datos de mina en disco. No verificable."),
 ("Verificar que el Bibliotecario mencione cenizas de biblioteca", "AUDIT 2026-10-14 (step-5-kilocode): grafos de cen_004 existen por capitulo; el contenido 'cenizas de biblioteca' no se verifico nodo por nodo."),
 ("Verificar que el Herrero tenga hierro de Ceniza", "AUDIT 2026-10-14 (step-5-kilocode): 4 grafos mencionan 'forja'; el hierro de Ceniza como material de M158 no tiene datos en disco. No verificable."),
 ("Verificar que la Cocinera mencione ingredientes de CEN", "AUDIT 2026-10-14 (step-5-kilocode): grafos de cen_003 existen; ingredientes de CEN como datos de M15/M160 no estan en disco. No verificable."),
 ("Verificar que el Minero tenga misiones de exploraci\u00f3n", "AUDIT 2026-10-14 (step-5-kilocode): hay 19 grafos tipo MISION en el registro; misiones de exploracion del Minero no se verificaron contra cadenas de M23."),
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
print("anotados (M162 b3):", n)
