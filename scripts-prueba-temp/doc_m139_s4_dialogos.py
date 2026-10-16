# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """
### 2.3.3 Dialogos del elenco + variantes (cerrado 2026-10-14, step-5-kilocode)

Cierra "10+ lineas de dialogo por NPC (M21)" y "variantes de dialogo por estacion/dia (M29)".
Regla de formato: 10 lineas base por NPC + 3 variantes contextuales (lluvia, noche, festival).

**Finneas (el):** 1 "Buen dia para arreglar algo, ¿no?" 2 "El temple estuvo raro anoche. Lo senti
desde aca." 3 "Si ves a Maribel, decile que el clavo del muelle sigue flojo." 4 "Cuando era chico
este pueblo era la mitad." 5 "No toques nada de mi taller sin preguntar. Bueno, si esta roto, tocalo."
6 "El faro viejo todavia gira. Nadie sabe por que." 7 "Un vecino que no saluda es una puerta
cerrada." 8 "Si vas al templo, lleva una vela. Y paciencia." 9 "Aurora no es grande, pero alcanza."
10 "Manana sera otro dia. Literalmente, con el ciclo nuevo."

**Maribel (ella):** 1 "El que pesca temprano come dos veces." 2 "Al entardecer pago quince por
ciento mas. El mar esta de bueno." 3 "Las redes de mi padre siguen en el muelle. Sirven todavia."
4 "Si sacas un pez raro, traemelo antes que se eche a perder." 5 "No me hables antes del primer cafe."
6 "La marea manda, no yo." 7 "Los domingos vendo en la plaza. Los sabados, en el muelle."
8 "Un anzuelo bien puesto vale mas que uno caro." 9 "El mar da y quita. Uno aprende a no discutir."
10 "Cuando llueve, los peces se esconden. Yo tambien."

**Obe (el):** 1 "Toda pieza buena empende torcida." 2 "La mina da lo que da. No se apura."
3 "Si construis, medí dos veces. O tres." 4 "Mi abuelo hacia sillas con tres clavos. Eran buenas."
5 "El bambu aguanta mas de lo que parece." 6 "Cuando algo no cierra, es que sobra un mueble."
7 "Te presto la herramienta, no el dedo." 8 "En el taller se piensa; en la mina, se fuerza."
9 "Una casa sin ventana al este es un pan sin corteza." 10 "Volve si queres aprender, no si queres
que te haga el trabajo."

**Tia Rua (ella):** 1 "Pase, que ya abri." 2 "Hoy hay semillas nuevas. Llegaron con la marea."
3 "Si no hay stock, no insista. O insista, pero vuelva manana." 4 "Mi tienda cierra a las ocho.
Reloj en mano." 5 "Los precios son los precios. El cafe, no." 6 "Lo barato sale caro, y lo caro
tambien, si no lo cuidás." 7 "Decile a Pax que deje de esconder cosas en mis estantes."
8 "La gente compra lo que necesita. Y despues lo que quiere." 9 "Si viene el festival, aviso."
10 "Vuelva siempre. Es gratis."

**Pax (elle):** 1 "¿Jugamos a las escondidas?" 2 "Encontre algo brillante detras del faro. Es
secreto." 3 "Los adultos caminan mirando el piso. Yo miro para arriba." 4 "Si me ganas, te doy
una piedra." 5 "El bosque tiene caminos que no estan en los mapas." 6 "¿Viste mi cometa?"
7 "A veces hablo con las gaviotas. No responden, pero escuchan." 8 "Cuando sea grande voy a
explorar el mar." 9 "Correr es gratis." 10 "Guardo tesoros. Uno te toca si sos paciente."

**Kor (el):** 1 "El faro gira. Yo miro." 2 "Anoche vi una luz afuera. Grande." 3 "No es un barco.
Los barcos se mueven distinto." 4 "Cincuenta anos aca y el mar sigue siendo nuevo."
5 "Si escuchas la campana, veni. O no, si tenes miedo." 6 "El acantilado habla cuando hay viento."
7 "Nadie me cree hasta que lo ve." 8 "Un vigio duerme parado. Es mas facil de lo que suena."
9 "Si el mar se calma de golpe, cuidado." 10 "Aurora duerme. Yo no."

**Cole (elle):** 1 "Abro dos horas. Despues, soy gente." 2 "Guardo monedas, no secretos."
3 "El interes es leve. La confianza, no." 4 "Si depositas hoy, manana hay un poco mas."
5 "No presto. Eso es otro negocio." 6 "Mi banco es chico, pero cierra con llave."
7 "La inflacion es el monstruo que no se ve." 8 "Traerme una moneda rara es buena idea."
9 "Si el pueblo crece, mi escritorio tambien." 10 "Vuelva en horario. Soy de cumplir."

**Bram (el):** 1 "¿Viste como brilla el cristal cuando baja la marea?" 2 "El enclave no esta
terminado, muchacho." 3 "Traeme un pedazo de arrecife." 4 "El oceano guarda mas islas."
5 "De chico creia que el mar terminaba en el acantilado." 6 "Si vas a navegar, lleva cristal."
7 "Cuando llueve, el cristal canta." 8 "Mi taller es chico, pero ve todo el oceano."
9 "No compres baratijas." 10 "El mar no tiene apuro, y yo tampoco."

**Variantes contextuales (M29) — una por NPC, para 3 contextos:**

| NPC | Lluvia | Noche | Festival |
|---|---|---|---|
| Finneas | "Dia de taller. No de visita." | "¿Oiste eso? Fue el faro." | "Hasta yo salgo a la plaza." |
| Maribel | "Hoy no se pesca. Se teje." | "El mar de noche es otra cosa." | "Pescado fresco, precio de fiesta." |
| Obe | "La mina se inunda. A descansar." | "Los sueños tambien se construyen." | "Hago un banco para la plaza." |
| Tia Rua | "Vendra menos gente. Igual abro." | "Cerrado. Volve manana." | "Descuentos solo si hay cola." |
| Pax | "¡Charcos!" | "Los tesoros tambien duermen." | "¡Hay juegos! Voy ganando." |
| Kor | "El viento tapa todo. Hasta la luz." | "Es cuando mas se ve." | "Un vigio tambien baila. Mal." |
| Cole | "Igual abro. Dos horas son dos horas." | "Cerrado. ¿Obvio?" | "Interes doble. Es broma." |
| Bram | "El cristal canta fuerte hoy." | "Parece terminado. Espejismo." | "Hasta el mar festeja." |

Las variantes por estacion (verano/lluvia) y por dia de ciclo quedan como datos de M29; la
estructura y el ejemplo por NPC ya estan definidos aqui (M21 consume).
"""

ancla = "## 5. Hits de Pre-Alpha"
if ancla in t:
    t = t.replace(ancla, seccion.strip() + "\n\n" + ancla, 1)
    print("seccion 2.3.3 insertada")
else:
    # insertar antes de la seccion 3 de pipeline
    a2 = "## 3. Pipeline de assets (M108)"
    if a2 in t:
        t = t.replace(a2, seccion.strip() + "\n\n" + a2, 1)
        print("seccion 2.3.3 insertada (antes de pipeline)")
    else:
        print("AVISO: ancla no encontrada")

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("03-Diseno.md actualizado")
