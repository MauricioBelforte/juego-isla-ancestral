## 1. Arquitectura de la fase


## 2. Diseño del mundo Pre-Alpha


### 2.1 Aurora (primer bioma completo)

| Sector | Contenido | Módulos |
|---|---|---|
| Costa Este (puerto) | Muelle, Gran Vapor atracado, mercado de pescado | M28/M67/M19 |
| Pradera central | Pueblo: talleres, tienda Tía Rúa, plaza, casas 2-3 | M18/M39 |
| Bosque Oeste | Recursos (maderas, frutas), mina ligera, campamento | M15/M35/M50 |
| Colina Norte | Templo de Brisa + subida con 2 puzzles ambientales | M26/M24 |
| Acantilados Sur | Faro en ruinas (misterio visible M153), Kor vigilando | M153/M19 |

- Área ~2 km² navegables en **6 zonas de streaming** (M63) con presupuesto de memoria (M62).
- Vegetación (M50): palmeras, bambú, hibiscos, pasto alto; flora transmisora de estado (M09).
- Agua (M51): litoral con ondas suaves; pesca (M34) cerca de costa.


### 2.1.1 Definicion del bioma Aurora (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 2 del `05-Checklist.md` (Primer bioma — Aurora) con lo que ya existe en disco
mas la definicion de lo que faltaba. Regla: donde un modulo dueno ya tiene el sistema, la
definicion se apoya en el; donde no existe, se define aqui y queda marcado el dueeno.

**Geografia (5 sectores, definidos):**

| Sector | Ubicacion | Contenido | Modulos |
|---|---|---|---|
| Costa E | borde este | Puerto y muelle de salida a Coral | M28/M67 |
| Pradera central | centro | Pueblo, plaza, talleres, tienda | M17/M39/M53 |
| Bosque W | oeste | Lena, setas, fauna de bosque | M09/M50/M36 |
| Colina N | norte | Templo de Brisa en la cima | M26/M24/M13 |
| Acantilados S | sur | Faro y mirador | M09/M42 |

**Area navegable: ~2 km2** (definida; limite mar-tierra por el nivel de mar de M51).

**6 zonas de streaming (M63):** Costa-E, Pradera, Bosque-W, Colina-N, Acantilados-S y Puerto
(transicion). Base real: `scripts/stream/stream_manager.gd` con suite M63 (6 iteraciones de test).

**POIs por sector (definidos):** muelle (Costa-E), plaza + talleres + tienda (Pradera), mina
(Bosque-W, ver M35), templo (Colina-N), faro (Acantilados-S). Sin catalogo de POIs en disco
todavia: la definicion queda aqui y su implementacion es de M22/M64.

**Vegetacion (M50, con respaldo real en `data/vegetacion/vegetacion_config.json` v2):** palmeras
(3 tipos en playa), bambu (`canas_bambu` en ribera), pasto alto (`hierba_alta` en pradera y
cercanias). **Hibisco: no existe con ese nombre** — los equivalentes son `flor_isla` y
`arbusto_floral`; queda anotado como deuda de nombrado de M50.

**Litoral pescable (M51/M34):** el sistema de pesca existe (`scripts/fishing/`, spots con
`bioma` informado por M51) y el agua es de M51; la definicion de que todo el litoral de Aurora es
pescable queda aqui, sujeta a que M51 integre los voxels de agua (stub `es_agua_pescable()`
documentada en M34).

**Flora transmisora de estado (M09):** flora registrada existe (`baya_roja` en el registro del
museo M37); la definicion de que la flora de Aurora transmite estados (ej. baya = energia)
requiere el catalogo de M09, que no esta en disco. **Queda `[ ]` con esa nota.**

**Puntos de descanso / cama (M11/M18):** camas existen como muebles
(`data/houses/cama_madera.tres`, catalogo M18); la definicion de los puntos de descanso de Aurora
(mas uno en la Pradera y uno en el Puerto) queda aqui. Implementacion: M18.

**Ciclo dia/noche (M31):** el modulo M31 existe (`DOCUMENTACION/31-Ciclo-Dia-Noche`) y el
`TimeCalendar` es autoload; Aurora usa el ciclo global sin variacion propia. **Definicion:**

**Clima base (M32):** tropical suave — sin datos de clima en disco (`data/clima/` no existe); la
definicion (lluvia ligara ocasional, sin tormentas salvo evento) queda aqui para que M32 la
consuma. **Queda `[ ]` hasta que M32 tenga datos.**

**Fauna inicial (M36, con respaldo real en `data/fauna/catalog.json`, 7 especies):** aves —
`gaviota_playera` (playa), `lechuza_bosque` (bosque), `halcon_montana` (montana) — visibles en
Aurora. **Peces costeros: no estan en el catalogo de fauna** (son del sistema de pesca M34,
`data/balance/fishing.json`); quedan como deuda de catalogo de M36.


### 2.2 Enclave de Coral (núcleo del 2º bioma, visitable no construido)

- Muelle, 1 NPC, tienda única (arrecife glasswork), vista al océano como anzuelo de curiosidad (M152/M153).
- Se deja "inacabado a propósito" con hit explícito para Alpha (M140).


### 2.3 Elenco NPC (6-10, M19/M64)

| NPC | Rol | Rutina | Gancho |
|---|---|---|---|
| Finneas | Vecino principal (del slice M138) | Taller → plaza → faro | Ciclo de misión intro (M22/M23) |
| Maribel | Pescadora | Muelle → mercado | Compra pescado +15% al entardecer |
| Obé | Artesano | Taller → mina | Desbloquea piezas de construcción (M17) |
| Tía Rúa | Tiendera | Tienda 08:00-20:00 (M39) | Tienda AO: semillas, herramientas, deco |
| Pax | Niño explorador | Rutina libre bosque/playa | Coleccionables escondidos (M73) |
| Kor | Vigía | Acantilado S (bucle fijo) | Misterio del faro (M153) |
| Cole | (Banco miniatura) | Oficina 2 h al día | Depósito de AO con interés leve (M38) |
| Bram | Enano vidriero de arrecife (Coral) | Muelle → taller de vidrio → mirador | Pide material del arrecife; pista del 2º bioma (M152/M153) |

- Diálogos: 10+ líneas por NPC (M21), con variantes por estación/día (M29).
- IA: máquina de estados + waypoints con tolerancia (M64); anti-stuck con teleport (M66).


### 2.3.1 Bram, enano vidriero de Coral (cerrado 2026-10-14, step-5-kilocode)

Cierra el item "NPC enano de Coral con 10+ lÃ­neas de diÃ¡logo (M21)" del checklist.
Rol: vidriero de arrecife. Rutina: muelle â taller de vidrio â mirador (bucle fijo con
tolerancia, M64). Gancho: pide material del arrecife y da la pista del 2Âº bioma.

**DiÃ¡logos base (11 lÃ­as, tono cozy, sin apuro):**

1. "Â¿Viste cÃ³mo brilla el cristal cuando baja la marea? Eso es trabajo mÃ­o, y un poco del mar."
2. "El enclave no estÃ¡ terminado, muchacho. Algunas cosas se dejan a medias para que el que venga despuÃ©s tenga quÃ© inventar."
3. "Traeme un pedazo de arrecife y te hago algo que ni la tienda de Aurora tiene."
4. "El ocÃ©ano guarda mÃ¡s islas. Yo solo cuido la orilla de esta."
5. "De chico creÃ­a que el mar terminaba en el acantilado. QuÃ© sÃ© yo."
6. "Si vas a navegar, llevÃ¡ cristal. Los peces grandes cobran peaje."
7. "Cuando llueve, el cristal canta. Quedate un rato y escuchÃ¡."
8. "Mi taller es chico, pero ve todo el ocÃ©ano."
9. "No compres baratijas. ComprÃ¡ cosas que duren mÃ¡s que vos."
10. "VolvÃ© cuando quieras. El mar no tiene apuro, y yo tampoco."
11. *(noche)* "A esta hora el enclave parece terminado. Espejismo lindo."

Variantes por estaciÃ³n y por dÃ­a (M29) a cargo de M21; la tabla de rutas queda en M19/M64.

**Tienda Ãºnica de Coral (arrecife glasswork) â— stock propio definido 2026-10-14 (step-5-kilocode):**

| Ãtem | Tipo | MÃ³dulo |
|---|---|---|
| `cristal_arrecife` | material base de crafteo | M16/M17 |
| `lampara_coral` | decoraciÃ³n (luz cÃ¡lida) | M18/M53 |
| `prisma_mareal` | decoraciÃ³n rara (baja rotaciÃ³n) | M39 |
| `cebo_brillante` | cebo de pesca (+rareza de picada) | M34 |
| `botella_mensaje` | objeto de misiÃ³n (pista del 2Âº bioma) | M22/M153 |
| `pendiente_marea` | accesorio estÃ©tico | M39 |

Regla: ninguno de estos Ã­tems se consigue en Aurora â€” el enclave es la Ãºnica fuente (M39).


### 2.3.2 Horarios, pronombres canonicos y ganchos (cerrado 2026-10-14, step-5-kilocode)

Cierra los items de rutas, horarios, pronombres y ganchos de la seccion 4 del checklist.
Base: elenco de 2.3 (rol y gancho ya definidos) + esta tabla de rangos sin solapamiento.

**Rangos de rutina (hora 0-23, sin solapamiento catastrofico):**

| NPC | 06-12 | 12-18 | 18-22 | 22-06 |
|---|---|---|---|---|
| Finneas | taller | plaza | faro | casa |
| Maribel | **muelle (40% del dia: pesca)** | mercado (60%) | casa | casa |
| Obé | taller | mina | casa | casa |
| Tía Rúa | casa | **tienda (08:00-20:00, M39)** | casa | casa |
| Pax | bosque | playa | libre | casa |
| Kor | **acantilado S (bucle fijo)** | acantilado S | acantilado S | casa |
| Cole | casa | **oficina banco 14-16 (2 h)** | casa | casa |
| Bram (Coral) | muelle | taller de vidrio | mirador | casa |

Regla anti-solapamiento: dos NPC con puesto fijo nunca comparten el mismo waypoint en la misma
franja (Kor y Bram son puestos fijos en zonas distintas). Tolerancia de desvio 0.75 m (M66).

**Pronombres y nombres canonicos (M147):**

| NPC | Pronombres | Nota |
|---|---|---|
| Finneas | él | vecino principal, heredado del slice M138 |
| Maribel | ella | pescadora |
| Obé | él | artesano |
| Tía Rúa | ella | tiendera |
| Pax | elle | niñe exploradore |
| Kor | él | vigía |
| Cole | elle | banco miniatura |
| Bram | él | enano vidriero (Coral) |

Estos son los nombres y pronombres canonicos del elenco Pre-Alpha; M147 (World-Building) es la guia
de referencia y cualquier cambio se hace allá primero.

**Ganchos (resumen, ya definidos en 2.3 y 2.3.1):** Maribel = pescado +15% al entardecer ·
Pax = coleccionables escondidos (M73) · Kor = misterio del faro (M153) · Cole = deposito con
interes 0.5% diario (M38) · Obé = desbloquea piezas de construccion (M17) ·
Bram = material del arrecife + pista del 2º bioma · Finneas = cadena intro (M22/M23) ·
Tía Rúa = tienda AO (M39).

**Plantillas creadas:** `scripts/world/npc/npc_profile.gd` (Resource con validacion) y
`scripts/world/npc/rutina_ia.gd` (maquina de estados IDLE/CAMINANDO/ESPERANDO/EN_PUESTO/RECUPERANDO
con anti-stuck y teleport al waypoint previo, M66).


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


### 2.4 Templo de Brisa (M26/M24/M13)

```
Subida: 2 puzzles ambientales (rompecorrientes de viento)
Sala 1 "Las Velas":   3 velas; ordenarlas usando ráfagas de viento (M42 feedback)
Sala 2 "El Carillón": 5 campanas; imitar una melodía suave (memorización con feedback ASMR M44)
Recompensa: Herramienta del Viento (M13) → desbloquea viento para los puzzles ambientales; lore canónico
            del Templo (flechas, símbolos M147) SIN spoiler de otros templos (M153)
```

- Normas de templo (canon M26): 2 salas, 1 herramienta, 1 pieza de lore, dificultad progresiva con
  hint no intrusivo (M58/M66: sin softlocks, hints por formato de acceso).


### 2.5 Economía Pre-Alpha (M38/M39/M93)

- Moneda AO. Dos tiendas en Aurora (Tía Rúa + mercado de Maribel) + 1 en Coral.
- Precios según curvas M93 (lineal en rutina, logarítmica en metas largas); márgenes de venta 55-70%.
- Simulación en CI (M118): detecta grind/exploit (M93) y falla el build si el jugador más productivo
  rompe la curva en < 30 h de juego simuladas.
- Bancolocal de Cole: depósito con interés 0.5% diario (M38), techo para evitar inflación.



### 2.5.1 Cierre economico de fase (2026-10-14, step-5-kilocode)

Cierra la seccion 5 del checklist con definiciones + respaldo en disco.

**Moneda:** el **AO** (aureo de Aurora) es la unica divisa de la fase. Sin moneda de segundo bioma
hasta Alpha; el trueque conceptual (ya definido en 2.5) cubre islas futuras sin romper esto.

**Tiendas (verificado contra `scripts/shops/catalogo_tiendas.gd`):**

| Tienda | Isla | Dueno | Estado |
|---|---|---|---|
| `tienda_general` | Aurora | Tia Rua | **registrada en catalogo** (TIENDAS.GENERAL) |
| `herreria` | Aurora | Obe / herrero | **registrada en catalogo** (TIENDAS.HERRERIA) |
| `mercader_viajero` | rotativo | - | registrado (no cuenta como tienda fija) |
| tienda glasswork (Coral) | Coral | Bram | **definida** en 2.3.1 con stock propio; pendiente de alta en el catalogo (M39) |

**Margenes de venta:** 55-70% sobre el precio base de compra - el jugador vende a ese rango y la
tienda recompara al 100%. Regla de balance en M93.

**Stock regenerativo diario:** cada tienda regenera el **40% del stock** cada ciclo de dia (M31);
los items de rareza COMUN regeneran siempre, los RAROS cada 3 dias y los EPICOS no regeneran.
Implementacion del ciclo en M39 (hoy shop.gd solo tiene stock inicial).

**Flujo de venta (definido, 4 pasos atomicos):** 1) confirmacion en UI (M53, con precio y cantidad)
-> 2) oro atomico via EconomyManager (sin doble credito) -> 3) sonido ASMR por threshold de precio
(M43/M42) -> 4) persistencia en el save del dia (M59). ShopManager ya emite las senales
`compra_exitosa` / `venta_exitosa` para los pasos 2 y 3.

**Banco de Cole (2.5):** interes 0.5% diario. **Techo anti-inflacion:** 10.000 AO base + 500 AO por
nivel de relacion con Cole (tope 25.000). Implementacion en M38.

**Anti-grind:** el precio de compra de un item sube **5% por unidad comprada en la misma sesion**,
con tope de 25% - evita farming de un solo item. Regla en M93.

**Simulacion economica en CI (respaldada):**
- `scripts/shops/test_loop_economico.gd` - loop end-to-end M38 + M14 + M39.
- `scripts/tests/test_balance_m93_iter4.gd` - curvas no exponenciales, reglas anti-grind/techos.

**Umbral de fallo de la simulacion:** el test debe mantener la curva sana durante **30 h de juego
simulado**; si se rompe antes, es fallo (criterio ya presente en el diseno de M93 y en el H5 de fase).

### 2.6 Construcción (M17/M16/M18)

- Catálogo de 30+ piezas: vallas, caminos, mobiliario, decoración y 3 estructuras (casa de campo, invernadero pequeño, gazebo).
- Colocación por grid ligero (sin física), validada contra terreno voxel y colisiones (M08/M09).
- Desbloqueo: Obé entrega piezas según progreso de amistad (M20) y misiones (M23).
- Todas las piezas se persisten en save v3.


### 2.6.1 Sistema de construccion de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 6 del checklist. El motor ya existe y esta testeado; lo que faltaba era el
catalogo y las reglas de fase.

**Lo que ya existe en disco (verificado, no inventado):**

| Componente | Archivo | Cubre |
|---|---|---|
| Validador de terreno | `scripts/construccion/construccion_validator.gd` | nucleo PURO (sin nodos ni VoxelTools): superficie/pared/agua, **limite de zona** (`Motivo.LIMITE_DE_ZONA`) |
| Permisos por zona | `scripts/construccion/zonas_permisos.gd` | parcela del jugador EDIFICABLE, ruina/templo PROTEGIDA (M25) |
| Preview translucido | `scripts/construccion/build_preview.gd` + `build_ghost.gd` | feedback visual de validez (M44) |
| Persistencia | `scripts/saving/buildings_save_provider.gd` (M59) + `test_m18_m60_integration.gd` (10 checks) | contrato ISaveProvider; **nota honesta:** el provider existe pero la fuente M17 todavia no esta implementada |
| Catalogo base | 6 muebles en `data/houses/*.tres` | cama, cofre, estanteria, lampara, mesa, silla |

**Catalogo de fase — 30 piezas (definidas aqui; 6 ya existen como .tres):**

| Categoria | Piezas |
|---|---|
| Vallas (6) | valla_madera, valla_jardin, valla_piedra, valla_bambu, puerta_jardin, arco_flores |
| Caminos (6) | camino_tierra, camino_adoquin, camino_grava, camino_madera, losa_jardin, borde_cesped |
| Mobiliario (10) | mesa_madera*, silla_madera*, cama_madera*, cofre_madera*, estanteria*, lampara_pared*, banco_plaza, sillon_exterior, mesita_noche, armario_roble |
| Deco (8) | maceta_flor, farol_jardin, molino_deco, comedero_pajaros, estatua_farol, cartel_madera, banderin_fiesta, alfombra_exterior |

(* las 6 que ya tienen .tres)

**3 estructuras de fase:** casa de campo (4 etapas: solar → estructura → techo → terminación),
invernadero pequeño (3 etapas) y gazebo (2 etapas). Las etapas las administra `house_manager.gd`
(ya tiene `avanzar_etapa`).

**Colocacion:** grid ligero de 1 m sin fisica — encaja con el validador de nucleo puro; la pieza se
coloca en la celda libre mas cercana al puntero y se rechaza con el motivo correspondiente.

**Costo por pieza (M93):** vallas 3-8 AO + 1 material · caminos 1-2 AO · mobiliario 15-120 AO +
1-3 materiales · deco 5-40 AO. Las recetas de crafteo viven en `crafting.json` (M16).

**Desbloqueo por amistad (M20):** respaldado por `data/economia/friendship.json` — nivel 2
desbloquea `recetas_basicas`, nivel 4 `recetas_avanzadas` + trueque especial. Obe (M23) anade el
gancho de mision que desbloquea las 3 estructuras.

**Clima (M32):** el **invernadero** es la unica estructura que interactua con el clima — la lluvia
duplica la velocidad de crecimiento de lo plantado adentro y el sol directo la reduce a la mitad.
El resto de las piezas es neutra al clima.

**Limite por zona (M61):** 40 piezas en la parcela del jugador, 25 en la plaza y 0 en ruinas y
templos. El validador ya rechaza con `LIMITE_DE_ZONA`; los numeros por zona quedan como balance de
M61.

**Categorias visuales (M46):** 4 materiales canonicos — madera, piedra, tela y planta. Toda pieza
usa uno de esos 4 con la paleta Maldivas del proyecto; nada de metal salvo el herrero.

**Interaccion con NPC (M19):** `banco_plaza` es sentable (accion SENTARSE ya existe en
`item_data.gd`); los NPC con rutina libre (Pax) pueden usar bancos como waypoint de descanso.

### 2.7 Guardado v3 (M59/M60)

```
manifest.json  → versión de schema, checksums de particiones, última zona
zona_<id>.dat  → estado de la zona (NPC, inventario, tiendas, cámara, hora)
voxel_<id>.dat → delta de chunks editados (M60)
meta.json      → opciones, stats de sesión, flags de progresión global
```

- Escritura: transaccional (temp + rename), doble copia; carga < 2 s en 20/20 ciclos (M66 valida integridad).


### 2.7.1 Templo de Brisa — cierre de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 7 del checklist. Lo que ya existe en disco (verificado): el capitulo de historia
`scripts/eventos/data/capitulos/historia_c4_templo_brisa.tres` (gatillo `templo_brisa_abierto`,
7 sellos requeridos, capitulo 4) y la invariante anti-softlock
`scripts/core/invariants/puzzle_invariant.gd` (M66: resolubilidad en 30 s + reinicio del slot),
ademas de `softlock_guard.gd` / `softlock_rules.gd` y el catalogo de puzzles de
`scripts/templos/`.

**Acceso por la colina N:** 2 puzzles ambientales en la subida —
1) **semillas al viento**: soplar 3 tallos de semilla en orden de cercania (ensinanza la mecanica
de rafaga sin UI), 2) **antorchas de piedra**: encender 2 antorchas siguiendo la direccion del
viento. Ninguno bloquea la subida: se puede pasar y volver.

**Sala 1 "Las Velas":** 3 velas sobre una mesa de piedra. Hay que encenderlas en el orden que
marca la direccion de la rafaga del momento (N -> E -> S). Una vela mal encendida se apaga sola y
reintenta sin castigo.

**Feedback de las velas:** silbido de llama por vela (M42) y parpadeo de luz calida en proporcion
a la rafaga (M44). Los 3 componentes ya tienen modulos duenos.

**Sala 2 "El Carrillon":** 5 campanas de metal soplado. La melodia son 5 notas graves que se tocan
en el orden que susurra el lore de la sala (la misma que aparece en el capitulo 4). Error = la
campana suena muda y el puzzle continua.

**Feedback ASMR del carillon:** tonos puros con decay largo y sin percusiva (M44/M42); volumen
bajo para no saturar.

**Herramienta del Viento (M13):** recompensa al cerrar las 2 salas. Permite **llamar una rafaga**
(accion dedicada) con cooldown de 3 s. Es la primera herramienta "climatica" del juego y abre la
mecanica para templos futuros.

**Lore canonico (M147/M153):** el Templo de Brisa es el primero de 6; su sala central tiene runas
de viento y un mural del archipielago. **Anti-spoiler garantizado:** las runas son genericas
(direccion de viento), ningun texto nombra a los otros 5 templos, y el capitulo 4
(`historia_c4_templo_brisa.tres`) solo habla de este. Los 7 sellos requeridos por el capitulo son
los de completitud, no pistas.

**Hint no intrusivo (M58/M66):** solo aparece si el jugador permanece >20 s a <2 m del puzzle sin
interactuar, y como susurro de texto (no pop-up ni flecha). Desactivable en ajustes de
accesibilidad.

**3 rutas de solucion por sala:** para cada sala hay 3 caminos validos —
**orden** (seguir la mecanica tal cual), **observacion** (leer pirolo del lore/ambiente) y
**ayuda** (pista del hint tras 2 fallos). Las 3 llevan a la misma resolucion; no hay ruta "mas
rapida" que rompa balance.

**Anti-softlock (M66):** respaldado por `puzzle_invariant.gd` — si un slot de puzzle no es
resoluble en 30 s de diagnostico, se reinicia al estado inicial. Combinado con
`softlock_guard.gd` (autoload) y la regla de que ningun puzzle del templo es obligatorio para
salir.

**Recompensa extra (M73):** una **pagina de lore** coleccionable escondida en la sala 2 (detras del
carrillon, visible solo con la Herramienta del Viento ya obtenida). Cuenta para el set de M73.

**Viento en el exterior tras la herramienta:** con la Herramienta del Viento, las rafagas mueven
semillas y hojas en toda la isla, y abren **atajos de polen** (corrientes que aceleran el paso por
la pradera). Es el primer cambio global del mundo por una herramienta.

### 2.7.1 Save v3 + menu de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 10 del checklist. **El motor de save ya esta implementado y verificado:**

| Componente | Archivo | Cubre |
|---|---|---|
| Schema versionado | `scripts/saving/save_schema.gd` | `schema_version` por save (M60) |
| Escritura | `scripts/saving/save_writer.gd` | escritura + temp/rename (transaccional) |
| Carga | `scripts/saving/save_loader.gd` | carga por slots |
| Snapshots | `scripts/saving/save_snapshot.gd` | estado consistente por guardado |
| Integridad | `scripts/saving/validate_save.gd` + `test_checksum_hmac.gd` | validacion y checksum HMAC (M66) |
| Backups | `scripts/saving/save_backup.gd` + `test_backup_rotations.gd`, `test_rotate_m59.gd` | rotacion y recuperacion (M107) |
| Slots | `test_slots_m59.gd`, `test_slot_range.gd` | multiples partidas |
| Proveedores | `save_provider.gd`, `player_save_provider.gd`, `buildings_save_provider.gd` | ISaveProvider por sistema (M59) |
| Limites | `test_save_size_cap.gd` | tope de tamano de save |

**Versionado de schema (M60):** cada save guarda `schema_version`. Al cargar, si la version es
menor se migra en cadena (`migrar_v1_a_v2`, `migrar_v2_a_v3`); si es mayor, se rechaza con mensaje
claro. La version actual de fase es **3**.

**Escritura transaccional:** el writer escribe a `.tmp`, hace `rename()` atomico y solo despues
borra el backup previo. Verificado por el fix BUG-112 (rotate devuelve false si algun rename falla).

**Verificacion de integridad al continuar (M66):** `validate_save.gd` valida manifest y checksum
HMAC antes de entrar al mundo. Si falla, se ofrece recuperar la copia alternativa; si tambien
falla, se ofrece empezar partida nueva (nunca se pierde el acceso al juego).

**Recuperacion con copia alternativa:** la rotacion guarda la ultima version valida como
`backup`. La secuencia es: intentar save actual -> intentar backup -> ofrecer partida nueva.
Tests: `test_backup_rotations.gd` y `test_rotate_m59.gd`.

**Carga < 2 s en 20/20 ciclos:** criterio de fase. Los ciclos guardar/cargar estan cubiertos por
`test_autosave_m59.gd` y `test_close_save.gd`; el umbral de 2 s se mide con el StreamManager y la
pantalla de carga existente (la barra refleja progreso real).

**Menu principal (definido, M53/M92):** 4 opciones — **Continuar** (ultimo slot), **Nuevo juego**,
**Ajustes** (M57/M58: idioma, audio, accesibilidad) y **Creditos**. Fondo: la escena del puerto de
Aurora con camara lenta. No existe aun en disco: es la pieza de UI que falta para la fase.

**UI deshabilitada durante cargas (regla §8 AGENTS.md):** `scripts/stream/pantalla_carga.gd`
(M63 P1) ya es un CanvasLayer con barra ColorRect y bloqueo de input; la regla se mantiene — la UI
nunca recibe eventos mientras la barra esta activa.

**Pantalla de carga con barra y mensajes:** ya implementada — barra de progreso **real** del
StreamManager + consejos de mundo rotando (`tips.txt` via `ConsejosCarga`) + fundido. Sin
`tips.txt`, la pantalla funciona igual.

**Flujo "nuevo juego" con confirmacion:** si hay save en el slot, se pide confirmacion explicita
("¿Sobrescribir la partida guardada?") con el tiempo de juego y la fecha del save. No se sobrescribe
nunca en un solo click.

**Navegacion con gamepad y teclado (M57/M58):** `menu_navigator.gd` existe (con test M64). Regla:
todo elemento del menu es alcanzable con flechas + A/Enter, con focus visible y sin trampas de
foco; el gamepad se puede usar en todo momento (nunca se exige mouse).

**Tutorial visual sin texto (M92):** `tutorial_manager.gd` (autoload "Tutorial") ya orquesta
capitulos con pasos PISTA/SECUENCIA/CONSEJO y triggers por senal. La fase exige que los **primeros
3 pasos sean 100% visuales** (mover -> mirar -> interactuar: iconos en mundo, sin texto). Los
consejos de texto quedan para despues del tercer paso.

### 2.8 Audio global (M41-M44)

- Buses: `Music`, `Ambient`, `SFX`, `ASMR`, `UI` (M41-M44) con transiciones por zona/clima (M32).
- Música adaptativa por estado (día/noche M31, lluvia M32, templo M26).
- Eventos 2D/3D por pool (M44).


### 2.8.1 Gran Vapor — cierre de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 8 del checklist. Respaldos verificados en disco: la red de transporte
(`scripts/transporte/generar_red_transporte.gd` — 10 paradas, 20 rutas, incluye `puerto_aurora` con
tipo `barco` e `isla_raiz`), el servicio de viaje (`scripts/viajes/travel_service.gd` — contrato de
embarque con flags M22 via WorldState y `_destinos_visitados`), `boat_route.gd`, los modulos
67-Vehiculos y 68-Transporte-Y-Navegacion, y el leitmotiv `leit_gran_vapor` ya presente en
`music_context_matrix.json` (M41) junto a las capas `olas`/`gaviotas` de `ambient_biome_bank.json`
(M42).

**Gran Vapor:** unico vehiculo de la fase. Atracado en el puerto de Aurora (parada `puerto_aurora`
de la red de transporte), con apariencia de vapor de carga remodelado a ferry. No se conduce: es
transporte de punto a punto.

**Interaccion de embarque (IViajable):** el muelle expone el contrato — el jugador habla con el
tripulante, confirma destino (Coral) y el servicio de viaje valida el flag de desbloqueo (M22 via
WorldState). Con la herramienta `IViajable` creada hoy para el contrato entre capas, el muelle y el
`travel_service` quedan con interfaz comun.

**Cutscene de travesia:** 20-25 s sin gameplay de mar. Camara fija en la popa mirando la estela,
el barco saliendo del puerto, un primer plano del ocena y la llegada al muelle de Coral. Se puede
saltar con la accion de cancelar (sin penalizacion).

**Desembarco en Coral y vuelta:** el desembarco deja al jugador en el muelle de Coral (sector ya
definido en 2.2) con Bram visible como primer contacto. La vuelta es desde el mismo muelle, sin
costo adicional y sin desbloqueo extra (ida y vuelta libre dentro de la misma sesion de viaje).

**Costo del viaje:** ticket de **25 AO** el primer viaje; viajes siguientes **gratis** el mismo dia
(regla cozy anti-frustracion). Coincide con la recompensa por descubrir ruta nueva (25 AO) que ya
existe en `meta.json`, asi que el primer viaje se autofinancia con el meta.

**Que se puede llevar:** el inventario completo viaja con el jugador (regla anti-frustracion: nunca
separar al jugador de sus cosas). Las piezas colocadas y las plantas de la parcela no viajan.

**Vista del ocena como anzuelo (M51/M152):** durante la cutscene, el horizonte muestra siluetas de
islas no visitadas con neblina. Es la unica pista visual del segundo bioma y funciona como anzuelo
de curiosidad (mecanica documentada en 2.2).

**Camara del Gran Vapor (M12):** la cutscene usa el `camera_rig` existente en modo fijo (sin
spring); al embarcar la camara pasa a modo cinematico y al desembarcar vuelve al seguimiento del
jugador. Sin modo de conduccion.

**Audio de travesia (M42/M41):** capas `olas` + `gaviotas` (M42) como base, con el leitmotiv
`leit_gran_vapor` (M41) entrando en el segundo plano cuando el puerto se pierde de vista. Volumen
bajo, sin percusiva.

**Variante para que no sea repetitivo:** el tripulante tiene 4 lineas de dialogo rotativas por viaje
(una por viaje del dia, ciclo de 4 dias) mas una variante nocturna. El dialogo se almacena en el
`world_state` para no repetir la misma linea dos veces seguidas.

### 2.8.1 Sistema de audio de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 11 del checklist. **La arquitectura de audio ya existe y esta operativa:**

| Director / config | Ruta (autoload) | Cubre |
|---|---|---|
| `AudioConfig` | `scripts/audio/audio_config_service.gd` | perfiles y volumen; fuente de verdad de audio |
| `MusicDirector` | `scripts/audio/music_director.gd` | musica por contexto (M41) |
| `AmbientDirector` | `scripts/audio/ambient_director.gd` | ambiente (M42) |
| `SFXManager` | `scripts/audio/sfx_manager.gd` | efectos de sonido (M43) |
| `FeedbackDirector` | `scripts/audio/feedback_director.gd` | **ASMR y feedback con recetas de capas por accion**, blacklist anti-agresion y sincronia de keyframes (M44) |
| `NarrativeSound` | `scripts/audio/narrative_sound.gd` | sonido narrativo |

**Buses (verificado en `audio_config_service.gd`):** se crean 7 en runtime — `Master` (base) +
`Music`, `SFX`, `Ambient`, `Voice`, `UI` y `Cinematic`. **Nota honesta: el bus `ASMR` que pide el
checklist NO existe** — hoy el ASMR se implementa como capas dentro de `FeedbackDirector` sobre el
bus `SFX`. La definicion del bus propio queda anotada como deuda: agregarlo como hijo de Master con
atenuacion -6 dB y limite deTrue Peak en 3 dB.

**Transiciones de musica por zona y estado:** respaldadas por
`data/audio/music_context_matrix.json` (temas, capas, stings y variaciones) + `MusicDirector`. La
matriz ya cubre contexto por zona y estado (dia/noche/lluvia, con `coral_dia`, `coral_noche`,
`coral_lluvia` y `leit_gran_vapor`).

**Ambiente por sector:** respaldado por `data/audio/ambient_biome_bank.json`, que define capas para
**10 sectores** (playa, bosque, pradera, volcan, montana, selva, desierto, laguna, arrecife, ceniza)
con variante `clima_2`. Los sectores de la fase (puerto, bosque, templo, faro) mapean a playa /
bosque / montana / acantilado.

**SFX por interaccion (M43):** `SFXManager` los emite por evento; la regla de fase es que todo lo
interactuable del slice (recoger, pescar, vender, construir, abrir) tenga su sample con variacion de
tono para no cansar.

**ASMR de recoleccion y venta (M44):** `FeedbackDirector` ya aplica recetas de capas por accion con
precedencia contextual (interior/clima/hora). La regla de fase: recoleccion = capas cortas y
cristalinas; venta = capas con decay medio. Sin muestras agresivas (la blacklist anti-agresion ya
esta implementada).

**Audio UI:** bus `UI` con confirmaciones cortas y no repetitivas (max 1 sonido cada 150 ms para
evitar spam al navegar el menu).

**Musica del templo con tension suave:** definida como **sting** de la matriz (no tema completo):
acordes graves con quinta suspendida, sin percusion, entrando solo en las 2 salas de puzzle y
saliendo al resolverlos. Volumen 20% por debajo del tema base.

**Persistencia de niveles de volumen:** `GameSettings` documenta el volumen y delega en
`AudioConfig.set_volumen()` como fuente de verdad; los niveles se guardan en el save de ajustes y se
aplican al arrancar.

## 3. Pipeline de assets (M108) — gate de calidad

```
Modelo/escena fuente → import normalizado (nombres, unidades) → materiales/texturas comprimidas
→ prefab/prefab_variante en biblioteca (M108) → validación automática (LOD, collision, bounds, frame budget M61)
→ integración en zona → playtest corto (M114) → commit
```

- El 100% de los assets del Pre-Alpha pasa por el pipeline (sin atajos); la CI falla si un asset no cumple presupuestos.


### 3.1 Cierre del pipeline de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 9 del checklist. Todo el flujo descrito arriba ya tiene implementacion verificada.

**Verificado en disco:**

| Componente | Ruta | Que cubre |
|---|---|---|
| Validador de assets (tool) | `tools/asset_validator.gd` | validacion automatica previa a importar |
| Validador de assets (pipeline) | `tools/asset_pipeline/asset_validator.gd` | el mismo gate dentro del pipeline |
| Zona de cuarentena | `assets/staging/` (existe) | assets sin .import valido no entran a produccion |
| Biblioteca de assets | `assets/2d`, `assets/3d`, `assets/final`, `assets/fichas`, `assets/fonts` | destino por tipo de asset |
| Perfiles de rendimiento | `scripts/rendimiento/asset_profile.gd` (autoload AssetProfile) | perfiles baja/media/alta, blacklist de GPU y deteccion automatica |
| LOD | `scripts/construccion/build_ghost.gd` (`DISTANCIA_LOD = 40.0`, `aplicar_lod()`) | patron de LOD por distancia ya en uso |
| Modulos duenos | M108 (pipeline), M45 (3D), M46 (2D), M47 (texturas) | todos con 01/02/03 documentados |

**Convenciones de importacion (definidas aqui, las valida el gate):**
- **Nombres**: `snake_case` con prefijo de familia (`veg_`, `prop_`, `edificio_`, `npc_`) y sufijo de
  variante (`_v2`). Nunca espacios ni tildes.
- **Unidades**: 1 unidad = 1 metro; escala 1:1 en el import; nada de escalado en el prefab.
- **Collision**: solo las piezas con colision explicita en el nombre (`_col`) generan shape; el resto
  es decoracion pura.
- **Bounds**: cada asset se importa con su bounding box verificado (maxima dimension <= 12 m para
  props, <= 30 m para edificios).

**Validador en CI**: el gate falla (y por lo tanto la CI) si un asset no cumple nombre, formato,
tamano (<= 5 MB por textura), dimensiones (potencia de 2), mipmaps y licencia documentada. Los dos
validadores encontrados cubren el gate; el pipeline documentado en M108 es la fuente.

**Presupuesto de draw calls por zona (M61, hoy 61-Rendimiento)**: <= 120 draw calls por zona en
perfil media, <= 200 en alta, <= 60 en baja — los perfiles los expone AssetProfile. La zona mas
pesada (Pradera) es la que se mide primero.

**Comprension de texturas (M47)**: VRAM Compartido para props yVegetacion, Lossless para UI y
fichas. Nadie importa textura sin compresion; el gate la verifica.

**LOD y culling por zona desde el dia 1**: LOD por distancia a los 40 m (patron de build_ghost) y
culling por zona con `stream_manager.gd` (M63). Cada zona declara su radio de culling.

**Rolling backlog de assets**: una familia por semana (semana 1 vegetacion, semana 2 props de
pueblo, semana 3 edificios, semana 4 NPC, semana 5 templo, semana 6 barco). Cada familia pasa
completa por el pipeline antes de tocar la siguiente.

**Assets heredados del slice (M138)**: los assets actuales de `assets/` vienen del slice. Se
reimportan una sola vez por el pipeline completo (cuarentena -> validacion -> biblioteca) y quedan
marcados con `origen = M138` en su ficha. Los que no pasen el gate se rehacen, no se parchean.

## 4. Métricas y telemetría (M104/M105)

- Métricas de fase: FPS/p99, memoria (M62), tiempos de carga por zona (M63), distancia de stream, sesiones completadas, horas hasta fin de contenido, uso de cada sistema (tienda, construcción, templo, viaje).
- Dashboards locales para playtests (M114); sin envío remoto en esta fase.


### 4.1 Cierre de metricas y rendimiento de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 12 del checklist. Respaldos verificados en disco:

| Componente | Ruta | Cubre |
|---|---|---|
| Frame budget por categoria | `scripts/performance/budget_profile.gd` (+ `test_budget_profile.gd`) | M61: `CATEGORIAS_OFICIALES`, marca inicio/fin de categoria y acumula tiempos (segun 03-Diseno 2.1) |
| Perfiles de hardware | `scripts/hardware/hardware_profile.gd` + autoload `AssetProfile` | perfiles baja/media/alta + blacklist GPU |
| Presupuesto de memoria | `DOCUMENTACION/62-Memoria/plan-actual/03-Diseno.md` (RF2 / presets M90) | total **1.500 / 2.000 / 2.500 MB** por preset |
| Streaming y LOD | `scripts/stream/stream_manager.gd` | LOD por region (coronas del oceano, pisos del subterraneo) + `chunk_lod0/lod1` con distancias |
| Telemetria | `scripts/telemetry/telemetry_director.gd` + `test_telemetria_iter5/7.gd` | M104/M105 con **opt-in** (`establecer_opt_in`, `_cargar_opt_in`) |
| Playtest | `DOCUMENTACION/114-Playtest/` | protocolo profesional + plantilla `PLAYTEST-ENCUESTA.md` + nomenclatura por tester |

**Dashboards locales para playtest (M114):** panel de superposicion (F3) con FPS actual, p99 de
frame, memoria estimada, tiempos de carga de la ultima zona y presupuesto consumido por categoria.
100% local — el mismo BudgetProfile ya expone las categorias; el dashboard solo las lee.

**Frame budget por categoria a cada zona nueva (M61):** toda zona nueva declara su presupuesto por
categoria antes de entrar; si una categoria se pasa del 100% durante 60 frames seguidos, se marca la
zona como `fuera_de_presupuesto` y aparece en el dashboard. La Pradera es la zona de referencia.

**Presupuesto de memoria 1.5 GB con streaming (M62):** el preset base de fase es **1.500 MB** (el
primero de la tabla de M62). Con streaming activo el techo se mantiene; sin streaming (menu,
pantallas modales) el presupuesto no se consume — regla ya presente en `stream_manager.gd`.

**Gate de zona (falla CI):** `test_budget_profile.gd` y el pipeline M108 actuan de gate: si una zona
no declara presupuesto por categoria o se pasa del techo, la CI falla. No se mergea zona sin gate.

**Telemetria de sesion local sin envio remoto (M104/M105):** la telemetria es **opt-in** y escribe
en disco local (`user://`); no hay envio remoto. Si el jugador no acepta, no se registra nada.

**Playtest de fase (M114):** 2-4 h con **5+ testers**, protocolo y plantillas ya definidos en el
modulo 114; cada sesion se archiva con la nomenclatura estandarizada.

**Encuesta de sesion (M114):** la plantilla `PLAYTEST-ENCUESTA.md` es la encuesta post-sesion; se
aplica al terminar cada sesion de playtest.

**Criterio >= 80% "queria seguir jugando":** es el umbral de exito de fase; se mide sobre las
encuestas de los 5+ testers (promedio de la pregunta de continuidad).

**Medicion de distancia de streaming y pops (M63):** el `stream_manager.gd` ya mide las coronas LOD
con distancias declaradas (`chunk_lod0` 1.0, `chunk_lod1` 3.0 ...); la metrica de pops (cuantas
veces una pieza aparecio dentro del radio de vision) se agrega al dashboard local.

## 5. Hits de Pre-Alpha → Alpha (M140)

| Hit | Criterio de salida |
|---|---|
| H1 | Aurora completa navegable con los 6 sectores y GONOGO pasado |
| H2 | Elenco NPC completo con rutinas y diálogos validados |
| H3 | Templo de Brisa jugable de punta a punta sin guiones |
| H4 | Gran Vapor ida/vuelta a Coral operativo |
| H5 | Economía con AO, 2 tiendas y ciclo de venta estable en CI |
| H6 | Construcción con 30 piezas y persistencia perfecta |
| H7 | Save v3 con integridad (20/20) y menú completo |
| H8 | Audio global por buses y transiciones OK |
| H9 | Pipeline M108 cumplido al 100% y métricas de fase OK |
| H10 | Playtest 2-4 h con ≥ 5 testers y ≥ 80% "quería seguir" |
| H11 | Coral completado: enclave terminado e integrado al flujo de Alpha (muelle, tienda glasswork, Bram) |

Se aprueba Alpha (M140) solo cuando H1-H11 estén todos cumplidos y documentados (DoD, sección 12 AGENTS.md).

### 5.1 Cierre de fase con criterios verificables (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 13 del checklist. **Los H1-H11 ya estaban definidos** (seccion 5, H11 agregado por
mi el 2026-10-14); lo que faltaba eran los **criterios verificables** de cada uno:

| Hit | Criterio verificable (como se comprueba) |
|---|---|
| H1 | Navegar los 6 sectores de Aurora en una sesion sin salir del mundo; GONOGO local pasado |
| H2 | Los 8 NPC del elenco (2.3) con rutina activa y las 10+ lineas de dialogo base por NPC (2.3.3) |
| H3 | Completar las 2 salas del Templo de Brisa (Velas + Carrillon) de punta a punta sin usar consola |
| H4 | Viaje de ida Y vuelta Aurora↔Coral por el Gran Vapor, con desembarco correcto en ambos muelles |
| H5 | 2 tiendas de Aurora + 1 de Coral con ciclo de venta estable; `test_loop_economico.gd` + `test_balance_m93_iter4.gd` en verde |
| H6 | 30 piezas colocables con persistencia perfecta tras guardar/cargar (`buildings_save_provider.gd`) |
| H7 | Save v3 con integridad validada (`validate_save.gd` + checksum HMAC) y menu principal completo |
| H8 | Audio por buses verificados + transiciones por zona/estado sobre `music_context_matrix.json` |
| H9 | Pipeline M108 al 100% (todo asset por cuarentena + validador) y presupuestos de fase OK (4.1) |
| H10 | Playtest 2-4 h con ≥ 5 testers y ≥ 80% "queria seguir jugando" (encuesta M114) |
| H11 | Enclave de Coral terminado e integrado al flujo (muelle, tienda glasswork, Bram) |

**Revision DoD antes de declarar completa la fase (§12 AGENTS.md):** los 3 criterios —
codigo implementado y verificado, documentacion `plan-actual/` alineada con el codigo, y tests
superados. Un hit no se marca cumplido sin evidencia en disco o ejecucion.

**Documento GONOGO firmado:** `DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md` (este archivo)
es el documento GONOGO: queda firmado con Modelo/Plataforma/Fecha del agente que cierra la fase y con
la linea Totales como veredicto numerico. Se considera firmado cuando todos los items estan `[x]` o
tienen `[ ]` con deuda justificada.

**Riesgos residuales que pasan a Alpha:**
1. **Clima base (M32)** — `data/clima/` no existe; la definicion quedo documentada pero sin datos.
2. **Bus ASMR** — hoy cubierto como capas de FeedbackDirector sobre el bus SFX; falta el bus propio.
3. **Menu principal** — no implementado en disco; es la pieza de UI que falta construir.
4. **Catalogo de precios** — de 1691 items con id, solo 31 tienen precio (deuda de M15).
5. **Flujo M17 (construccion)** — el save provider existe pero la fuente M17 no esta implementada.
6. **Verificacion en Play Mode** — los items de consola y flujo completo requieren ejecucion real.

**Mano derecha de continuidad para M140:** se entrega (a) el checklist firmado con las deudas
anteriores, (b) el `03-Diseno.md` con las secciones 2.1.1 / 2.3.1-2.3.3 / 2.5.1 / 2.6.1 / 2.7.1 /
2.8.1 / 3.1 / 4.1 / 5.1 como definicion de fase, (c) los contratos nuevos creados
(`ITienda`, `ITemplo`, `IViajable`, `NpcProfile`, `RutinaIA`, `SesionMaster`), y (d) la lista de
verificaciones pendientes en runtime.

**Registro de learning de la fase:** las lecciones quedaron en los Logs 1819-1824 y en los informes
287-326 — destacadas: (1) verificar cada item contra disco antes de promover, (2) distinguir DISEÑADO
de IMPLEMENTADO, (3) no reservar numeros a mano, (4) confirmar la seccion con el director antes de
arrancar, (5) el detector de agentes colgados con `.ultima-revision-*.txt`.

**0 errores en consola al entrar en Play Mode:** pendiente de ejecucion real — no verificable por
disco. Queda anotado como verificacion de runtime para el cierre.

**Flujo completo verificado en Play Mode:** pendiente de ejecucion real (menu → nuevo juego →
Aurora → templo → viaje a Coral → guardar/cargar). Queda anotado como verificacion de runtime.

**Coste de la fase:** se documenta al cierre con el tiempo real de los 142 items (los lotes cerrados
quedan en los logs 1819-1824 con fecha y hora).

**Inventario de bugs conocidos:** `DOCUMENTACION/11-BUGS.md` es el registro canónico (existe); los
bugs de fase se clasifican por severidad ahi y se referencian desde M101/M102.
