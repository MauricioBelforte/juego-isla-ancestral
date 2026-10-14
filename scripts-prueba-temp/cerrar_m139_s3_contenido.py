# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

# 1) agregar el enano de Coral al elenco NPC (fila en la tabla + bloque de dialogo)
ancla_tabla = "| Cole | (Banco miniatura) | Oficina 2 h al d\xc3\xada | Dep\xc3\xb3sito de AO con inter\xc3\xa9s leve (M38) |"
fila = ("| Bram | Enano vidriero de arrecife (Coral) | Muelle \xe2\x86\x92 taller de vidrio \xe2\x86\x92 mirador | "
        "Pide material del arrecife; pista del 2\xc2\xba bioma (M152/M153) |")
if ancla_tabla in t:
    t = t.replace(ancla_tabla, ancla_tabla + "\n" + fila, 1)
    print("elenco NPC: fila de Bram agregada")
else:
    print("AVISO: no se encontro la fila de Cole")

dialogo = """
### 2.3.1 Bram, enano vidriero de Coral (cerrado 2026-10-14, step-5-kilocode)

Cierra el item "NPC enano de Coral con 10+ l\xc3\xadneas de di\xc3\xa1logo (M21)" del checklist.
Rol: vidriero de arrecife. Rutina: muelle \xe2\x86\x92 taller de vidrio \xe2\x86\x92 mirador (bucle fijo con
tolerancia, M64). Gancho: pide material del arrecife y da la pista del 2\xc2\xba bioma.

**Di\xc3\xa1logos base (11 l\xc3\xadas, tono cozy, sin apuro):**

1. "\xc2\xbfViste c\xc3\xb3mo brilla el cristal cuando baja la marea? Eso es trabajo m\xc3\xado, y un poco del mar."
2. "El enclave no est\xc3\xa1 terminado, muchacho. Algunas cosas se dejan a medias para que el que venga despu\xc3\xa9s tenga qu\xc3\xa9 inventar."
3. "Traeme un pedazo de arrecife y te hago algo que ni la tienda de Aurora tiene."
4. "El oc\xc3\xa9ano guarda m\xc3\xa1s islas. Yo solo cuido la orilla de esta."
5. "De chico cre\xc3\xada que el mar terminaba en el acantilado. Qu\xc3\xa9 s\xc3\xa9 yo."
6. "Si vas a navegar, llev\xc3\xa1 cristal. Los peces grandes cobran peaje."
7. "Cuando llueve, el cristal canta. Quedate un rato y escuch\xc3\xa1."
8. "Mi taller es chico, pero ve todo el oc\xc3\xa9ano."
9. "No compres baratijas. Compr\xc3\xa1 cosas que duren m\xc3\xa1s que vos."
10. "Volv\xc3\xa9 cuando quieras. El mar no tiene apuro, y yo tampoco."
11. *(noche)* "A esta hora el enclave parece terminado. Espejismo lindo."

Variantes por estaci\xc3\xb3n y por d\xc3\xada (M29) a cargo de M21; la tabla de rutas queda en M19/M64.
"""

# 2) stock de la tienda glasswork de Coral
stock = """
**Tienda \xc3\xbanica de Coral (arrecife glasswork) \xe2\x80\u2014 stock propio definido 2026-10-14 (step-5-kilocode):**

| \xc3\u008dtem | Tipo | M\xc3\xb3dulo |
|---|---|---|
| `cristal_arrecife` | material base de crafteo | M16/M17 |
| `lampara_coral` | decoraci\xc3\xb3n (luz c\xc3\xa1lida) | M18/M53 |
| `prisma_mareal` | decoraci\xc3\xb3n rara (baja rotaci\xc3\xb3n) | M39 |
| `cebo_brillante` | cebo de pesca (+rareza de picada) | M34 |
| `botella_mensaje` | objeto de misi\xc3\xb3n (pista del 2\xc2\xba bioma) | M22/M153 |
| `pendiente_marea` | accesorio est\xc3\xa9tico | M39 |

Regla: ninguno de estos \xc3\u00adtems se consigue en Aurora \xe2\u20ac\u201d el enclave es la \xc3\xbanica fuente (M39).
"""

# insertar ambos bloques despues de la seccion 2.3 (antes de 2.4)
ancla = "### 2.4 Templo de Brisa (M26/M24/M13)"
if ancla in t:
    t = t.replace(ancla, dialogo.strip() + "\n\n" + stock.strip() + "\n\n" + ancla, 1)
    print("dialogo de Bram y stock de la tienda insertados")
else:
    print("AVISO: no se encontro la seccion 2.4")

# 3) hit explicito H11 en la tabla de hits
ancla_h = "| H10 | Playtest 2-4 h con \xe2\x89\xa5 5 testers y \xe2\x89\xa5 80% \"quer\xc3\xada seguir\" |"
h11 = "\n| H11 | Coral completado: enclave terminado e integrado al flujo (muelle, tienda glasswork, Bram |"
if ancla_h in t:
    t = t.replace(ancla_h, ancla_h + "\n| H11 | Coral completado: enclave terminado e integrado al flujo de Alpha (muelle, tienda glasswork, Bram) |", 1)
    print("hit H11 agregado a la tabla")
else:
    print("AVISO: no se encontro H10")

# nota de cierre de fase
t = t.replace(
  "Se aprueba Alpha (M140) solo cuando H1-H10 est\xc3\xa9n todos cumplidos y documentados (DoD, secci\xc3\xb3n 12 AGENTS.md).",
  "Se aprueba Alpha (M140) solo cuando H1-H11 est\xc3\xa9n todos cumplidos y documentados (DoD, secci\xc3\xb3n 12 AGENTS.md). H11 (completar Coral) se agrega el 2026-10-14 por step-5-kilocode, cerrando el item del checklist.")

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("03-Diseno.md actualizado")
