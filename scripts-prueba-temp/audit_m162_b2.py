# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = [
 ("Verificar que el Pescador mencione peces de M160", "AUDIT 2026-10-14 (step-5-kilocode): solo 2 de 367 grafos mencionan 'pez'; M160 no tiene datos de peces en data/ (no existe data/m160). Mencion no verificable."),
 ("Verificar coherencia del Herrero con sistema de forja", "AUDIT 2026-10-14 (step-5-kilocode): 4 de 367 grafos mencionan 'forja'; M158 no tiene datos en data/ (no existe data/m158). Coherencia no verificable."),
 ("Verificar que la Pescadora mencione arrecifes", "AUDIT 2026-10-14 (step-5-kilocode): 3 de 367 grafos mencionan 'arrecife'; M160 no tiene datos de arrecifes en disco. No verificable."),
 ("Verificar que el Comerciante refleje precios progresivos", "AUDIT 2026-10-14 (step-5-kilocode): 0 de 367 grafos mencionan 'precio'; la dimension economica de M38 no alimenta el selector de M162. No verificable."),
 ("Verificar que el Guardia mencione rutas de M160", "AUDIT 2026-10-14 (step-5-kilocode): 3 de 367 grafos mencionan 'ruta'; data/viajes/rutas.json existe (820 B) pero es de transporte (M69), no de M160. Mencion laxa."),
 ("Verificar que la Ni\u00f1a de la Playa tenga di\u00e1logos innocent", "AUDIT 2026-10-14 (step-5-kilocode): idem item 35 — sin etiqueta de adecuacion por edad en datos ni selector. No verificable por estructura."),
 ("Verificar que el Herrero mencione cobre de Coral", "AUDIT 2026-10-14 (step-5-kilocode): 4 de 367 grafos mencionan 'cobre'; la mencion existe pero el vinculo con el cobre de Coral (M15/M160) no esta explicitado."),
 ("Verificar que el Comerciante tenga items exclusivos", "AUDIT 2026-10-14 (step-5-kilocode): sin dimension de items/stock en M162; los items exclusivos son de M15/M38."),
 ("Verificar que el Guardia mencione peligros del arrecife", "AUDIT 2026-10-14 (step-5-kilocode): 6 de 367 grafos mencionan 'peligro'; mencion generica, no especifica del arrecife. No verificable."),
 ("Verificar que la Pescadora tenga tips de pesca por cap\u00edtulo", "AUDIT 2026-10-14 (step-5-kilocode): los grafos de cor_003/004/005 existen por capitulo (cap0-cap7); el contenido 'tips de pesca' no se verifico nodo por nodo."),
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
print("anotados (M162 b2):", n)
