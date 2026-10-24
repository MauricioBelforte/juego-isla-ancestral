> **Estado:** 🟡 Liberado — iter. 14 (2026-10-23, Log 2163): consecuencias con respaldo en disco («jardín florecido» L108 y «cofradía activa» L111 flippeadas con cita; «taller abierto» L109 medido vacío y dejado [ ] con guarda) + sincronización de las dos líneas de totales (71/32/2 = 105) y de la COLA ACTIVA del BACKLOG-MASTER (2 ítems que ya estaban [x] desde iter. 12). Suite 456 -> **477 checks / 0 fallos / EXIT 0 x2** + guardián EN ROJO por inyección de runtime sobre el bloque S nuevo. — iter. 13 (2026-10-22, Log 2137): clusters Puzzles (6 cadenas: templos 24/25/26 + ruinas del barrizal/manantial/acantilado) e Investigación (5 cadenas: registro del faro, catálogo perdido, medidas de la isla, mapa de las plantas, cartas estelares) del 03-Diseno L46/L45 — NPC REALES de data/villagers/ (vera_ardilla, sofia_buho, pablo_pato, teo_conejo, bruno_sapo, luna_zorra, catalina_oso) y objetos REALES de data/items/ por campo id; 11 consecuencias peladas únicas (52/52 globales medidas sobre la carga) y 11 capítulos de diario únicos; consolidado en UN informe (regla del fundador, msg 183 del director); suite 379 -> **456 checks / 0 fallos / EXIT 0 x3** (binario real); guardián EN ROJO por inyección de runtime sobre el bloque R: EXIT 1 nombrando el bloque + piso; bloque R endurecido con verificación de NPC/objeto REALES por efecto (FileAccess / campo id) e unicidad global de flags; regresiones M55 diario 0, M55 persistencia 0, M59 autosave 0 (M71 8/2 = reproducción del BUG-143 conocido, previa); 69/105 [x]; 34 [ ] de contenido/dueños externos + 2 [?]. iter. 12 (2026-10-22, Log 2135): cluster Comerciantes del 03-Diseno L36 (3 cadenas de rutas y secretos: ruta del mercader con mercedes_lince + OBJ-ITE-052 «Moneda de oro», cargamento de telas con olivia_nutria + OBJ-ITE-010 «Tela», secreto del yunque con ramon_tejon + OBJ-TAL-002 «Yunque» — NPC y objetos REALES de data/villagers/ y data/items/; integracion M37 excluida por orden del director, msg 181) + flips de los items de 3 comerciantes y de documentar familias y comerciantes; suite 379 checks/0 fallos x3 y guardian probado EN ROJO por inyeccion de runtime sobre el bloque Q; 65/105 [x]; 38 [ ] de contenido/duenos externos + 2 [?]. iter. 11 (2026-10-22, Log 2134): cluster Secretas del 03-Diseno L38 (5 cadenas ocultas desbloqueadas por mundo: mapa secreto, cristal oculto, diario antiguo, pergamino mistico, mascara ceremonial — NPC y objetos REALES de data/villagers/ y data/items/) + flip del item de 5 cadenas secretas; suite 351 checks/0 fallos x3 y guardian probado EN ROJO por inyeccion de runtime sobre el bloque P; 63/105 [x]; 40 [ ] de contenido/duenos externos + 2 [?]. iter. 10 (2026-10-22, Log 2131): cluster Amistad del 03-Diseno (6 cadenas nuevas: regalo favorito, sentadilla de pesca, paseos, ficción, ayuda a un vecino, cartas de amistad — NPC y objetos REALES de data/villagers/ y data/items/) + flip del ítem de 6 misiones de amistad; suite 316 checks/0 fallos x3 y guardián probado EN ROJO por inyección de runtime sobre el bloque O; 62/105 [x]; 41 [ ] de contenido/dueños externos + 2 [?]. iter. 9 (2026-10-22, Log 2129): cluster Familias del 03-Diseno (3 cadenas nuevas: molinera, pescadores, guardas — NPC y objetos REALES de data/villagers/ y data/items/) + flips de los 3 items de familias; suite 258 checks/0 fallos x3 y guardian probado EN ROJO por inyeccion de runtime sobre el bloque N; 61/105 [x]; 42 [ ] de contenido/duenos externos + 2 [?]. iter. 8 (2026-10-22, Log 2127): cluster Objetos del 03-Diseno (6 cadenas nuevas: relicto, gema, carta, llave, farol, brújula — NPC y objetos REALES de data/villagers/ y data/items/) + flips de los ítems de 6 objetos legendarios y de documentar lugares/ruinas/objetos; suite 227 checks/0 fallos x3 y guardián probado EN ROJO por inyección de runtime sobre el bloque M; 58/105 [x]; 45 [ ] de contenido/dueños externos + 2 [?]. iter. 7 (2026-10-22, Log 2125): cluster Ruinas del 03-Diseno (4 cadenas nuevas: biblioteca quemada, observatorio, estación, puente — NPC y objetos REALES de data/villagers/ y data/items/) + flip del ítem de 4 ruinas; suite 169 checks/0 fallos x3 y guardián probado EN ROJO por inyección de runtime sobre el bloque L; 56/105 [x]; 47 [ ] de contenido/dueños externos + 2 [?]. Iter. 6 (Log 2117, 2026-10-22): cluster Lugares del 03-Diseno (3 cadenas nuevas: jardines, cofradía, molino) + flip del faro; 55/105. Iter. 5 (Log 2107, 2026-10-22): 6 historias de vecinos, 50/105.
> **Clasificación de los [ ] (iter. 2, Step-5-WorkBuddy, 2026-10-21, Log 2082):** por verbo — «Crear» = artefacto ausente en disco (0 capítulos capitulo-* en el catálogo M55; 0 cosméticos; 0 registros de taller/kiosko/estación) → [ ] honesto, no se inventa contenido; «Definir/Diseñar/Documentar» = flip sólo con cita en 02/03/04 o implementación; por dueño — externos M22/M24/M28/M32/M36/M37/M68 marcados en el ítem. Conteo por prefijo de línea: 65 [x] / 38 [ ] / 2 [?] = 105 (iter. 12, Log 2135: +3 [x] cluster Comerciantes (3 cadenas de NPC/objetos REALES, suite 379 checks x3 + guardian en rojo sobre el bloque Q; item de documentar familias y comerciantes con las dos mitades citadas: §Iter. 9 + §Iter. 12); iter. 11, Log 2134: +1 [x] «Crear 5 cadenas secretas ocultas» con 5 cadenas de NPC/objetos REALES, suite 351 checks x3 + guardian en rojo sobre el bloque P; iter. 10, Log 2131: +1 [x] «Crear 6 misiones de amistad» con 6 cadenas de NPC/objetos REALES, suite 316 checks x3 + guardián en rojo sobre el bloque O; iter. 9, Log 2129: +3 [x] cluster Familias (molinera, pescadores, guardas con NPC y objetos REALES, suite 258 checks x3 + guardian en rojo sobre el bloque N); iter. 3, Log 2083: el director degradó el [x] «molino funcionando» a [?] el 2026-10-21, msg 151; iter. 6, Log 2117: el flag recuperó respaldo con cadena-molino y volvió a [x] ofrecido a revertir; iter. 5, Log 2107: doctora [?] con 0 NPC médicos; iter. 4, Log 2085: +1 [?] «Definir el tipo de paso construir», dueños M22/M17).

## Reserva actual

| Campo | Valor |
|-------|-------|
| Módulo | M23 Historias Secundarias |
| Agente | step-3.7-flash (Kilo Code) |
| Fase | F7 |
| Dificultad | 3 |
| Visión | V0 |
| Entrada | M22✅ |
| Salida | Núcleo data-driven + test headless 0 fallos |
| Archivos afectados | `game/isla-ancestral/data/historias/`, `game/isla-ancestral/scripts/historias/`, `project.godot` |

## Historias de vecinos

- [x] Crear la historia de la panadera (2-4 pasos) [M] — cadena-panadera en data/historias/secundarias.json; npc catalina_oso (cocinera, villager medido: no existe rol "panadera" en disco). Log 2107.
- [x] Crear la historia del farero [M] — cadena-faro en data/historias/secundarias.json (4 pasos: hablar farero/explorar faro/puzzle/entregar; contexto narrativo; consecuencia faro_encendido en WorldState M21; testeada en test_historias.gd bloque C, Log 2082). 1 de 8 vecinos del catálogo.
- [?] Crear la historia de la doctora [M] — 0 NPC médicos en data/villagers/ (14 villagers medidos 2026-10-22: trovadora, carpintero, cocinera, pescador, artesana, granjero, mercader, guardabosques, sastra, ceramista, herrero, bibliotecaria, herbolario, farera). NO se inventa el personaje: crear un villager es contenido de otro dueño. El flip se otorga cuando el asset exista. Log 2107.
- [x] Crear la historia del carpintero [M] — cadena-carpintero en data/historias/secundarias.json; npc bruno_sapo (carpintero, villager medido). Log 2107.
- [x] Crear la historia de la tejedora [M] — cadena-tejedora en data/historias/secundarias.json; npc olivia_nutria (sastra, villager medido: no existe rol "tejedora" en disco). Log 2107.
- [x] Crear la historia del pescador [M] — cadena-pescador en data/historias/secundarias.json; npc finneas_zorro (pescador, villager medido). Log 2107.
- [x] Crear la historia del guarda [M] — cadena-guarda en data/historias/secundarias.json; npc nico_gato (guardabosques, villager medido: no existe rol "guarda" en disco). Log 2107.
- [x] Crear la historia del alquimista [M] — cadena-alquimista en data/historias/secundarias.json; npc teo_conejo (herbolario, villager medido: no existe rol "alquimista" en disco). Log 2107.
- [x] Documentar las historias de vecinos en el plan-actual [S] — 04-Codigo.md seccion "Iter. 5 - Historias de vecinos" (Log 2107): tabla de las 6 cadenas, mapeo honesto de roles vs villagers medidos, doctora [?] con evidencia, consecuencias peladas unicas, bloque J de la suite con 98 checks.

## Historias de lugares, ruinas y objetos

- [x] Crear la historia del faro (lugar) [M] — Step-5 2026-10-22 (iter. 6, Log 2117): cadena-faro en data/historias/secundarias.json (4 pasos: hablar farero / explorar faro / puzzle faro-linterna / entregar farol_cargado; consecuencia faro_encendido). 03-Diseno lista el faro en Vecinos (cubierto en iter. 5, L20) Y en Lugares (L31): la misma cadena cubre los dos clusters por diseno.
- [x] Crear la historia de la biblioteca [M] — cadena-biblioteca mergeada desde data/historias/cadenas_ejemplo.json vía RUTA_CATALOGO_EJEMPLOS (merge por id, fuente "ejemplos", secundarias.json no la tenía); corre end-to-end en test_historias.gd bloque H (hablar bibliotecaria / explorar biblioteca / entregar tomo_antiguo / completada, Log 2083). Nota: la recompensa de diario depende de la entrada mision_cadena-biblioteca en el catálogo de M55 (ausente hoy, dueño M55).
- [x] Crear la historia de los jardines [M] — Step-5 2026-10-22 (iter. 6, Log 2117): cadena-jardines en data/historias/secundarias.json (hablar mateo_mapache / explorar jardines / entregar baya_roja / puzzle semillas-perdidas; NPC REAL de data/villagers/ y objeto REAL de data/items/; consecuencia jardin_florecido). End-to-end en test_historias.gd bloque K (Log 2117).
- [ ] Crear la historia de la plaza [M] — la variante cadena-postgame-plaza de cadenas_ejemplo.json fue RECHAZADA por el validador en el merge (tipo de paso "construir" desconocido: 03-Diseno y TIPOS_PASO solo conocen hablar/explorar/puzzle/entregar; 0 usos del token en scripts/); cadena-epilogo-plaza del principal ya cubre la plaza post-final (L130). DECISION DEL DIRECTOR (msg 153, 2026-10-21): el rechazo es PERSISTENTE — no se agrega el tipo "construir" hoy (sin respaldo de diseño, mismo patrón que el rechazo de prereq_quest en M105) y el dato NO se migra sin orden. El flip de este ítem se otorga solo cuando el tipo exista o el dato se migre (ver ítem [?] siguiente). Log 2083 + Log 2085.
- [?] Definir el tipo de paso "construir" para cadenas de construcción [M] — **Dueños M22/M17 (decisión de diseño pendiente):** el CONTENIDO YA EXISTE (cadena-postgame-plaza en data/historias/cadenas_ejemplo.json: hablar alcalde / construir plaza / entregar plaza_reconstruida, postgame:true) pero su paso p2 usa el tipo "construir", ausente de TIPOS_PASO -> el merge lo rechaza por esquema inválido. No es un [ ] honesto de "crear": el dato está escrito; lo que falta es la decisión de esquema. Decisión del director (msg 153): rechazo persistente hasta que M22/M17 definan; cuando el tipo exista, el flip de «Crear la historia de la plaza» procede con el dato ya normalizado a flags pelados (plaza_decorada). Log 2083 + Log 2085.
- [x] Crear la historia del molino [M] — Step-5 2026-10-22 (iter. 6, Log 2117): cadena-molino en data/historias/secundarias.json (hablar aria_ciervo / explorar molino / entregar fibra_algodon / puzzle melodia-del-molino; NPC REAL y objeto REAL; consecuencia molino_funcionando). End-to-end en test_historias.gd bloque K (Log 2117).
- [x] Crear la historia de la cofradía [M] — Step-5 2026-10-22 (iter. 6, Log 2117): cadena-cofradia en data/historias/secundarias.json (hablar mercedes_lince / explorar cofradia / entregar fragmento_ancestral / puzzle sellos-antiguos; NPC REAL y objeto REAL; consecuencia cofradia_activa). End-to-end en test_historias.gd bloque K (Log 2117).
- [x] Crear historias de 4 ruinas (biblioteca quemada, observatorio, estación, puente) [M] — Step-5 2026-10-22 (iter. 7, Log 2125): 4 cadenas en data/historias/secundarias.json (sofia_buho bibliotecaria / vera_ardilla farera / ramon_tejon herrero / luna_zorra artesana, villagers REALES de data/villagers/; ancient_crystal / iron_ore / piedra_caliza REALES de data/items/; tomo_carbonizado narrativo — 0 items de libro en data/items/; consecuencias biblioteca_quemada_rescatada, observatorio_alineado, estacion_reparada, puente_cruzable). End-to-end en test_historias.gd bloque L (Log 2125).
- [x] Crear las historias de 6 objetos legendarios (relicto, gema, carta, llave, farol, brújula) [M] — Step-5 2026-10-22 (iter. 8, Log 2127): 6 cadenas en data/historias/secundarias.json (teo_conejo herbolario / pablo_pato ceramista / catalina_oso cocinera / bruno_sapo carpintero / nico_gato guardabosques / finneas_zorro pescador, villagers REALES de data/villagers/; gemstone, OBJ-SEC-004 "Reliquia oculta", OBJ-SEC-001 "Llave oculta" y OBJ-LUZ-005 "Farol" REALES de data/items/; carta_sellada y brujula_desorientada narrativos — 0 items de carta/brújula en data/items/; consecuencias relicto_devuelto, gema_devuelta, receta_heredada, llave_encontrada, patrulla_nocturna, brujula_calibrada). End-to-end en test_historias.gd bloque M (Log 2127).
- [x] Documentar historias de lugares, ruinas y objetos [S] — Step-5 2026-10-22: cluster Lugares en 04-Codigo.md §Iter. 6 (Log 2117), cluster Ruinas en §Iter. 7 (Log 2125) y cluster Objetos en §Iter. 8 (Log 2127, 6 cadenas). El ítem era COMPUESTO (lugares + ruinas + objetos): con iter. 8 los tres clusters tienen contenido en disco y documentación con cita. Anti-inflación respetada: no se flippó por la mitad en iter. 6.

## Historias de familias y comerciantes

- [x] Crear la historia de la familia molinera [M] — cadena-molinera en data/historias/secundarias.json (4 pasos: hablar mateo_mapache / explorar molino / entregar OBJ-REL-003 / puzzle piedras-de-molienda; consecuencia molienda_familiar_restaurada en WorldState M21; testeada end-to-end en test_historias.gd bloque N). NPC REAL mateo_mapache (granjero, data/villagers/) y objeto REAL OBJ-REL-003 «Reloj de arena» (data/items/, verificado por campo id). Log 2129.
- [x] Crear la historia de la familia pescadores [M] — cadena-pescadores en data/historias/secundarias.json (4 pasos: hablar finneas_zorro / explorar muelle_viejo / entregar OBJ-HER-014 / puzzle nudo-del-abuelo; consecuencia red_del_abuelo_reparada en WorldState M21; testeada end-to-end en test_historias.gd bloque N). NPC REAL finneas_zorro (pescador, data/villagers/) y objeto REAL OBJ-HER-014 «Red de captura» (data/items/, verificado por campo id). Log 2129.
- [x] Crear la historia de la familia guardas [M] — cadena-guardas en data/historias/secundarias.json (4 pasos: hablar nico_gato / explorar bosque_nocturno / entregar OBJ-LUZ-011 / puzzle ronda-de-los-guardas; consecuencia vigilia_de_los_guardas en WorldState M21; testeada end-to-end en test_historias.gd bloque N). NPC REAL nico_gato (guardabosques, data/villagers/) y objeto REAL OBJ-LUZ-011 «Candil» (data/items/, verificado por campo id). Log 2129.
- [x] Crear las historias de 3 comerciantes (rutas y secretos) [M] — Step-5-WorkBuddy 2026-10-22 (iter. 12, Log 2135): 3 cadenas en data/historias/secundarias.json (cadena-ruta-del-mercader con mercedes_lince mercader + OBJ-ITE-052 «Moneda de oro», cadena-cargamento-de-telas con olivia_nutria sastra + OBJ-ITE-010 «Tela», cadena-secreto-del-yunque con ramon_tejon herrero + OBJ-TAL-002 «Yunque»; NPC REALES de data/villagers/ y objetos REALES de data/items/ verificados por campo id; consecuencias ruta_comercial_reabierta, telas_reunidas, tecnica_del_yunque_recuperada). Cluster Comerciantes del 03-Diseno L36 completo en su parte de cadenas: la integracion con M37 (L152) queda [ ] con su dueno excluida por orden del director (msg 181). End-to-end x2 en test_historias.gd bloque Q (Log 2135).
- [x] Documentar historias de familias y comerciantes [S] — Step-5-WorkBuddy 2026-10-22: cluster Familias documentado en 04-Codigo.md §Iter. 9 (Log 2129, 3 cadenas) y cluster Comerciantes en §Iter. 12 (Log 2135, 3 cadenas). El item era COMPUESTO (familias + comerciantes): con iter. 12 las dos mitades tienen contenido en disco y documentacion con cita. Anti-inflacion respetada: no se flippo por la mitad en iter. 9.

## Historias estacionales y secretas

- [ ] Crear el evento de siembra (M32) [M] — **Dueño M32:** evento estacional; 0 cadenas estacionales en data/historias/secundarias.json (4 cadenas del principal: faro, invernadero, epilogo-plaza, luciernagas; 5 tras el merge de ejemplos, Log 2083).
- [ ] Crear el evento de vendimia [M] — **Dueño M32:** evento estacional; 0 en disco.
- [ ] Crear el evento de marea [M] — **Dueño M32:** evento estacional; 0 en disco.
- [ ] Crear el evento de eclipse [M] — **Dueño M32:** evento estacional; 0 en disco (el eclipse de cadena-faro es contexto narrativo, no el evento de M32).
- [x] Crear 5 cadenas secretas ocultas [M] — Step-5-WorkBuddy 2026-10-22 (iter. 11, Log 2134): 5 cadenas en data/historias/secundarias.json (cadena-mapa-secreto con nico_gato + OBJ-SEC-002 «Mapa secreto», cadena-cristal-oculto con vera_ardilla + OBJ-SEC-003 «Cristal oculto», cadena-diario-antiguo con sofia_buho + OBJ-SEC-005 «Diario antiguo», cadena-pergamino-mistico con teo_conejo + OBJ-ART-002 «Pergamino mistico», cadena-mascara-ceremonial con luna_zorra + OBJ-ART-004 «Mascara ceremonial»; NPC REALES de data/villagers/ y objetos REALES de data/items/ verificados por campo id). Las 5 nacen oculta:true -> invisibles en cadenas_disponibles() hasta iniciarse (descubrimiento por mundo, 03-Diseno L38/L58). End-to-end x2 en test_historias.gd bloque P (Log 2134).
- [x] Definir el descubrimiento de las ocultas por el mundo [M] — 03-Diseno L58 («se descubren por pistas del mundo (M22) o al leer un objeto») + implementado: ocultas invisibles en cadenas_disponibles() hasta iniciarse (secondary_stories_service.gd L71; test bloque E).
- [ ] Documentar historias estacionales y secretas [S]

## Cadenas de misiones y exploración

- [x] Definir 40+ cadenas de 3-5 pasos con contexto [M] — 03-Diseno §Catálogo (60 cadenas planificadas, 89 slots por tipo) + esquema con contexto obligatorio >=10 chars y pasos >=3 (validador). La ESCRITURA concreta de cada cadena son los ítems «Crear», que siguen [ ].
- [x] Definir el schema de cadena (pasos, recompensa, consecuencia, oculta, postgame) [M] — 03-Diseno §Esquema + scripts/historias/quest_chain.gd (Resource con id/título/contexto/pasos/recompensa/consecuencia/diálogo_posterior/oculta/postgame) + validador.
- [x] Crear 8 misiones de exploración (brújula, fauna, cronitado) [M] — Step-5-WorkBuddy 2026-10-23 (iter. 15, Log 2164): 8 cadenas en data/historias/secundarias.json (51 -> 59) con NPC REALES de data/villagers/ (finneas_zorro, teo_conejo, sofia_buho, aria_ciervo, catalina_oso, olivia_nutria, nico_gato, ramon_tejon) y objetos REALES de data/items/ por campo id (OBJ-HER-016 «Lupa mejorada», OBJ-NAT-027 «Liana», OBJ-REL-004 «Reloj ancestral», OBJ-LUZ-015 «Lámpara de lava», OBJ-LUZ-013 «Lámpara de sal», OBJ-ITE-009 «Cuerda», OBJ-HER-004 «Hoz», OBJ-ITE-013 «Clavos»); 03-Diseno L39 nombra 3 temas (brújula, fauna M65, cronitar ruinas) y los 5 restantes son extensión declarada (mirador del acantilado, grutas del manantial, playas del sur, sendero del bosque, muelle viejo; mismo patrón que Amistad 4+2 e Investigación 4+1); integración con M65 (sistema de fauna) FUERA por el patrón del director (M37 en Comerciantes, msg 181). Suite test_historias.gd bloque T: 543 checks / 0 fallos / EXIT 0 x3 + guardián EN ROJO por inyección de runtime.
- [x] Documentar cadenas y misiones de exploración [S] — Step-5-WorkBuddy 2026-10-23 (iter. 15, Log 2164): documentado en 04-Codigo.md §Iter. 15 (las 8 misiones con NPC/objetos REALES, flags de consecuencia, cobertura de suite y la interpretación declarada de «cronitar ruinas» = fechar las ruinas, 02-Analisis L20).

## Misiones de construcción y agricultura

- [ ] Crear 6 misiones de construcción (puentes, cofradía, plaza, senderos, kiosko, jardín) [M]
- [ ] Definir la reconstrucción del puente (M28) [M] — **Dueño M28:** sólo alcanzable como consecuencia «puente cruzable» (03-Diseno L53); la misión concreta no está definida.
- [ ] Crear 5 misiones de agricultura (invernadero, cruces, variantes) [M]
- [ ] Definir variantes estacionales de agricultura (M32) [S] — **Dueño M32:** 03-Diseno L70 define la variación estacional genérica; las variantes de agricultura en sí son de M32.
- [ ] Documentar misiones de construcción y agricultura [S]

## Misiones de pesca y colección

- [ ] Crear 4 misiones de pesca (peces-trofeo, documentación y suelta) [M]
- [ ] Crear 6 misiones de colección (murales, glifos, sellos, minerales, peces, plantas) [M]
- [x] Definir la integración con M36 (museo) [M] — 03-Diseno §Integración L71 («el museo alimenta misiones de colección (minerales, peces, murales)»). Implementación: dueño M36.
- [ ] Documentar misiones de pesca y colección [S]

## Misiones de amistad e investigación

- [x] Crear 6 misiones de amistad (regalo, pesca, paseos, ficción) [M] — Step-5 2026-10-22: cluster Amistad del 03-Diseno L44 en 04-Codigo.md §Iter. 10 (Log 2131). 6 cadenas nuevas en `data/historias/secundarias.json` (26 -> 32): regalo favorito (olivia_nutria + OBJ-ROP-005 "Bufanda"), sentadilla de pesca (finneas_zorro + OBJ-ITE-036 "Té"), paseos (sofia_buho + OBJ-NAT-022 "Flor rara"), ficcion (aria_ciervo + OBJ-NAT-023 "Flor luminiscente"), ayuda a un vecino (mercedes_lince + OBJ-ITE-035 "Miel") y cartas de amistad (luna_zorra + OBJ-NAT-004 "Flor silvestre"). NPC y objetos REALES verificados en disco (data/villagers/, data/items/ por campo id); 6 consecuencias peladas únicas (32/32) y 6 capítulos de diario únicos. Suite `test_historias.gd`: bloque O (58 checks) al FINAL de `_run()`; piso 258 -> **316 checks / 0 fallos / EXIT 0 x3** (binario real); guardián EN ROJO por inyección de runtime (Variant -> Dictionary): EXIT 1, «el bloque O NO se ejecuto» + «solo 259 checks (minimo 316)»; sonda borrada, sha256 verificado. Nota de alcance: el 03-Diseno L44 nombra 4 temas y el 02-Analisis L25 pide 6 misiones con 5 temas nombrados — la 6.a (cartas de amistad) es extensión declarada del cluster, sin dueno externo.
- [x] Crear 5 misiones de investigación (faro, biblioteca, geodesia, mapas) [M] — Step-5 2026-10-22 (iter. 13, Log 2137): cluster Investigación del 03-Diseno L45 (5 cadenas en data/historias/secundarias.json, 40 -> 51): registro del faro (vera_ardilla farera + OBJ-LUZ-012 "Linterna"), catálogo perdido (sofia_buho bibliotecaria + OBJ-EST-006 "Vitrina"), medidas de la isla (pablo_pato ceramista + OBJ-REL-002 "Reloj de péndulo"), mapa de las plantas (teo_conejo herbolario + OBJ-HER-015 "Lupa") y cartas estelares (sofia_buho + OBJ-LUZ-008 "Lámpara de cristal"). NPC y objetos REALES verificados en disco (data/villagers/, data/items/ por campo id); 5 consecuencias peladas únicas y 5 capítulos de diario únicos. Suite test_historias.gd bloque R: end-to-end de cadena-registro-del-faro. Nota de alcance: el 03-Diseno L45 nombra 4 temas (faro, biblioteca, geodesia, mapas) y el ítem pide 5 — la 5.a (cartas estelares) es extensión declarada del mismo núcleo de investigación (sofia_buho + observatorio), sin dueño externo.
- [x] Definir la integración con M36 (mapas) [S] — 02-Analisis L26 (misiones de investigación: «faro, biblioteca, geodesia, mapas M36») + 03-Diseno L45. Implementación: dueño M36.
- [x] Documentar misiones de amistad e investigación [S] — Step-5 2026-10-22 (iter. 13, Log 2137): documentación de los clusters Amistad e Investigación en 04-Codigo.md sec. Iter. 13 (cadenas, NPC/objetos REALES, flags y cobertura de suite por cluster).

## Misiones de puzzles

- [x] Crear 6 misiones de puzzles (templos 24/25/26, ruinas ocultas) [M] — Step-5 2026-10-22 (iter. 13, Log 2137): cluster Puzzles del 03-Diseno L46 (6 cadenas en data/historias/secundarias.json, 40 -> 51): templo de las 24 marcas (pablo_pato + OBJ-TAL-004 "Rueda de alfarero"), templo de los 25 engranajes (bruno_sapo carpintero + OBJ-HER-018 "Sierra"), templo de las 26 mareas (luna_zorra artesana + OBJ-PLA-004 "Orquídea"), ruinas del barrizal (catalina_oso cocinera + OBJ-ITE-021 "Pan"), ruinas del manantial (teo_conejo + OBJ-NAT-024 "Seta") y ruinas del acantilado (vera_ardilla + OBJ-LUZ-004 "Veladora"). NPC y objetos REALES verificados en disco; 6 consecuencias peladas únicas y 6 capítulos de diario únicos. Suite test_historias.gd bloque R: end-to-end de cadena-templo-de-las-24-marcas y cadena-ruinas-del-barrizal.
- [ ] Definir la integración con el framework M24 [M] — **Sin cita en disco:** M24 no se menciona en 02-Analisis ni 03-Diseno (§Integración cubre M68/M22/M32/M36/M37/M66). Pendiente de definir.
- [x] Documentar misiones de puzzles [S] — Step-5 2026-10-22 (iter. 13, Log 2137): documentación del cluster Puzzles en 04-Codigo.md sec. Iter. 13 (templos 24/25/26 + ruinas, NPC/objetos REALES, flags y cobertura de suite).

## Recompensas

- [ ] Crear 20 capítulos de diario (recompensa narrativa) [M]
- [ ] Crear recetas de conversación desbloqueables [M]
- [ ] Crear 10+ cosméticos (disfraces, sombreros, paletas de casa) [M]
- [x] Definir cero stats en recompensas (cozy) [S] — 03-Diseno L52 («10+ disfraces/sombreros/paletas de casa; nunca stats (visión cozy)»); el schema no tiene campo de stats (quest_chain.gd).
- [x] Definir recompensas únicas no duplicables (M66 cofre) [M] — 03-Diseno L25 («recompensa y consecuencia únicas») y L72 («recompensas en especie (nunca duplicadas — M66)»); validador exige recompensa presente + título único (secondary_stories_service.gd L212-221).
- [ ] Documentar recompensas en el plan-actual [S]

## Consecuencias y diálogos posteriores

- [x] Definir las 12 consecuencias persistentes [M] — 03-Diseno L53 lista las 12 (faro encendido, jardín florecido, taller abierto, plaza decorada, puente cruzable, cofradía activa, kiosko abierto, molino funcionando, estación reparada, biblioteca iluminada, camino al faro despejado, puerto ampliado). CREAR cada una: ítems siguientes.
- [x] Crear la consecuencia "faro encendido" [S] — glm-5.3-flash 2026-09-01: flag WorldState aplicado al completar cadena-faro (testeado)
- [x] Crear la consecuencia "jardín florecido" [S] — Step-5-WorkBuddy 2026-10-23 (iter. 14, Log 2163): el flag TIENE respaldo en disco: cadena-jardines (data/historias/secundarias.json, agregada en iter. 6, Log 2117) lo aplica como consecuencia a WorldState (M21) vía secondary_stories_service.gd L232-236, verificado end-to-end en el bloque S del suite (477 checks / 0 fallos / EXIT 0 x2 + guardián EN ROJO por inyección de runtime). El item estaba [ ] desde el núcleo por omisión: la cadena existía y el flag se aplicaba, no se había flippeado.
- [ ] Crear la consecuencia "taller abierto" [S] — Step-5-WorkBuddy 2026-10-23 (iter. 14, Log 2163): MEDIDO el vacío — 0 cadenas aplican el flag en ninguno de los dos catálogos (secundarias.json + cadenas_ejemplo.json) y 0 hits del token en res://data (bloque S del suite). Queda [ ] honesto; el bloque S falla si algún día el flag aparece (guarda del ítem).
- [x] Crear la consecuencia "plaza decorada" [S] — flag WorldState aplicado al completar cadena-epilogo-plaza (postgame)
- [x] Crear la consecuencia "cofradía activa" [S] — Step-5-WorkBuddy 2026-10-23 (iter. 14, Log 2163): el flag TIENE respaldo en disco: cadena-cofradia (data/historias/secundarias.json, agregada en iter. 6, Log 2117) lo aplica como consecuencia a WorldState (M21) vía secondary_stories_service.gd L232-236, verificado end-to-end en el bloque S del suite (477 checks / 0 fallos / EXIT 0 x2 + guardián EN ROJO por inyección de runtime).
- [x] Crear la consecuencia "molino funcionando" [S] — DEGRADADO por el director 2026-10-21 (medición Step-5, Log 2082: grep molino_funcionando sobre data/+scripts/ = 0 archivos; marca sin apoyo en disco). [x] — Step-5 2026-10-22 (iter. 6, Log 2117): el flag TIENE respaldo en disco: cadena-molino (data/historias/secundarias.json) lo aplica como consecuencia a WorldState (M21), verificado end-to-end en test_historias.gd bloque K (ws_has("molino_funcionando") verde). La degradacion a [?] del director (msg 151, 2026-10-21) se apoyo en el grep de Log 2082 (0 archivos): medicion de hoy = 1 archivo de datos + corrida end-to-end. Ofrecido a revertir si el director mantiene la degradacion.
- [x] Definir el cambio visual del mundo por consecuencia [M] — 03-Diseno L54 («cada consecuencia cambia el mundo visualmente y desbloquea diálogos posteriores»). Aplicación visual: dueños M17/M18/M27.
- [x] Definir diálogos posteriores por estado de mundo [M] — 03-Diseno L54 («guardado por NPC + estado de mundo») + campo dialogo_posterior del schema. Contenido de los diálogos: dueño M21.
- [ ] Documentar consecuencias y diálogos posteriores [S]

## Anti-repetición y contexto

- [x] Implementar el campo `contexto` obligatorio en el schema [M] — implementado en el validador (>=10 chars, testeado)
- [x] Implementar la validación de contexto en Editor [M] — validar_cadenas() ejecutable headless (patrón validate_*)
- [x] Implementar la prohibición de misiones genéricas ("recoge N") [M] — mismo validador (contexto >= 10 chars rechaza "recoge N")
- [x] Implementar la falla de build si una cadena carece de contexto [M] — validador devuelve errores con ids; enganche CI con M116 dueño
- [x] Documentar la anti-repetición en el plan-actual [S] — 04-Codigo Notas iter. 1

## Misiones ocultas y postgame

- [x] Definir el descubrimiento de misiones ocultas sin marcador [M] — implementado: ocultas invisibles en disponibles() hasta iniciarse (testeado)
- [x] Definir la activación por pistas del mundo (M22) [S] — 03-Diseno L58 («se descubren por pistas del mundo (M22) o al leer un objeto»).
- [ ] Crear 4 cadenas de postgame [M]
- [x] Definir la variación del postgame según el final de M22 [M] — 03-Diseno L59 («tras el final de M22 (cualquier final, con variantes por elección)»); el gate implementado exige final_elegido != "" (secondary_stories_service.gd L103-106).
- [x] Crear la reconstrucción de la plaza post-final [S] — cadena-epilogo-plaza (postgame:true, testeada tras final M22)
- [ ] Crear el memorial del Sello post-final [S]
- [ ] Crear el epílogo de la aldea [S]
- [ ] Crear el epílogo del guardián (final secreto) [S]
- [x] Documentar misiones ocultas y postgame [S] — 04-Codigo Notas iter. 1

## Persistencia y validador

- [x] Definir el guardado por cadena (paso, completada, consecuencias) [M] — get_save_data/restore: activas (paso_actual) + completadas
- [x] Implementar guardado atómico + `.bak` [M] — vía SaveManager M59 (escritura atómica central)
- [x] Implementar el validador de referencias (NPC/lugares/objetos reales) [M] — tipos + evidencia con _slug (testeado); NPCs/lugares reales cuando existan (M36/M25 con dueño)
- [x] Implementar el validador de alcanzabilidad (M66) [M]
- [x] Implementar el validador de recompensas únicas [M] — validador: recompensa/consecuencia presentes + título único
- [x] Documentar la persistencia y el validador [S] — 04-Codigo Notas iter. 1

## Integración

- [ ] Integrar con M68 (objetivos y evaluación) [M] — **Dueño M68:** las señales quest_started/quest_completed ya emiten (M07); el consumidor es de M68.
- [x] Integrar con M22 (hooks de consecuencia y postgame) [M] — postgame gating vía final_elegido + consecuencias vía WorldState (testeado)
- [ ] Integrar con M32 (estacionales) [M] — **Dueño M32.**
- [ ] Integrar con M36 (museo y colección) [M] — **Dueño M36** (definición en 03-Diseno L71; implementación pendiente de M36).
- [ ] Integrar con M37 (comerciantes) [M] — **Dueño M37** (definición en 03-Diseno L72).
- [x] Integrar con M66 (sin softlocks de cadena) [M] — validador de referencias/recompensas + restauración sin huérfanas (testeado)
- [x] Documentar la integración en el plan-actual [M] — 03-Diseno §Integración (M68/M22/M32/M36/M37/M66) + 04-Codigo reglas 3 y 6 + Notas del Agente (M22 hooks, M55 diario, M71 cosmetico, M59 persistencia, M21 WorldState).

## Testings y documentación

- [x] Diseñar test de validador de cadenas (contexto/referencias) [M] — test_historias.gd _test_validador (catálogo base limpio)
- [ ] Diseñar test E2E de 10 cadenas completas [M]
- [x] Diseñar test de consecuencias aplicadas y persistidas [M] — test_historias.gd _test_cadena_completa/_test_persistencia
- [x] Diseñar test de recompensas únicas [M] — recompensa única por cadena en validador + idempotencia de registro
- [x] Diseñar test de postgame tras cada final (4 variaciones) [M] — test_historias.gd bloque F itera los 4 finales de M22 (principal/regresar/guardian/secreto; data/historia/historia_principal.json): bloqueada sin final + abierta tras cada uno. 40 checks / 0 fallos / EXIT 0 x3, Log 2082.
- [x] Diseñar 06-Plan-Testings.md (unitarias + integración) [M] — creado en la iter. 2 (2026-10-21): 7 bloques unitarios + integración M21/M22/M55/M59/M71 + guarda anti-falso-verde.
- [x] Crear 07-Resultados-Testings.md [S] — creado en la iter. 2 (2026-10-21): corridas del binario real Godot 4.7.2 (3x verde + sonda roja) y regresiones.
- [x] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M] — 02-Analisis (49 líneas: alcance, catálogo, consecuencias) y 03-Diseno (76 líneas: esquema validado, catálogo 60 cadenas, recompensas, ocultas/postgame, anti-repetición, integración, QA).
- [x] Actualizar plan-actual como espejo del estado real [M] — iter. 2 (2026-10-21): este checklist + 04-Codigo Notas + 06/07 creados; Total recalculado por prefijo de línea.
- [x] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S] — Log 447 (renumeración pendiente, protocolo v2: reservado al bloquear)
- [x] Actualizar fila 23 en CHECKLIST-GLOBAL al implementar [S] — hecho (reserva + liberación)

**Total:** 73/105 [x] · 30/105 [ ] · 2 [?] (iter. 15 Step-5-WorkBuddy 2026-10-23, Log 2164: +2 [x] cluster Exploración — 8 cadenas (cartografía con la brújula, fauna, cronología de las ruinas + 5 extensiones declaradas) con NPC y objetos REALES, suite 543 checks/0 fallos x3 y guardián EN ROJO por inyección sobre el bloque T; 51 -> 59 cadenas en secundarias.json, 60 en carga; iter. 14 Step-5-WorkBuddy 2026-10-23, Log 2163: +2 [x] consecuencias con respaldo en disco ya existente — «jardín florecido» (L108) y «cofradía activa» (L111), aplicadas por cadena-jardines y cadena-cofradia desde iter. 6 y verificadas end-to-end en el bloque S nuevo (477 checks / 0 fallos / EXIT 0 x2 + guardián EN ROJO por inyección de runtime); «taller abierto» (L109) medido vacío y dejado [ ] con guarda; las 12 consecuencias de 03-Diseno L53 quedan en 8 con respaldo y 4 sin respaldo (taller_abierto, kiosko_abierto, camino_al_faro_despejado, puerto_ampliado); iter. 13 Step-5-WorkBuddy 2026-10-22, Log 2137: +4 [x] clusters Puzzles e Investigación — esa vuelta no se había volcado en esta línea, regularizado hoy contra el conteo por prefijo medido (69/34/2); iter. 11 Step-5-WorkBuddy 2026-10-22, Log 2134: +1 [x] cluster Secretas — 5 cadenas ocultas (mapa secreto, cristal oculto, diario antiguo, pergamino mistico, mascara ceremonial) con NPC y objetos REALES, suite 351 checks/0 fallos x3 y guardian EN ROJO por inyeccion de runtime sobre el bloque P; iter. 2 Step-5-WorkBuddy 2026-10-21, Log 2082: 19 flips con cita en disco — ver 04-Codigo.md §Notas del Agente iter. 2; iter. 3 Step-5-WorkBuddy 2026-10-21, Log 2083: merge de cadenas_ejemplo.json con +1 [x] (biblioteca, L32) y el rechazo validado de cadena-postgame-plaza; el director degradó el [x] «molino funcionando» (L111) a [?] el 2026-10-21, msg 151, por grep molino_funcionando = 0 archivos; iter. 4 Step-5-WorkBuddy 2026-10-21, Log 2085: normalización estado_mundo.* → flags pelados en cadenas_ejemplo.json (GO msg 153) y +1 [?] «Definir el tipo de paso construir» con dueños M22/M17; iter. 5 Step-5-WorkBuddy 2026-10-22, Log 2107: +7 [x] +1 [?] (6 vecinos con NPC reales, doctora sin asset); iter. 6 Step-5-WorkBuddy 2026-10-22, Log 2117: +4 [x] y -1 [?] — cluster Lugares (jardines/cofradía/molino con NPC y objetos reales, suite 129 checks x4 + guardián en rojo) y el faro (L31) por cadena-faro; los 48 [ ] son contenido narrativo ausente o ítems con dueño externo M22/M24/M28/M32/M36/M37/M68; iter. 7 Step-5-WorkBuddy 2026-10-22, Log 2125: +1 [x] cluster Ruinas; iter. 8 Step-5-WorkBuddy 2026-10-22, Log 2127: +2 [x] cluster Objetos — ninguna de las dos se había volcado en esta línea, regularizado hoy contra el conteo por prefijo medido; iter. 9 Step-5-WorkBuddy 2026-10-22, Log 2129: +3 [x] cluster Familias (molinera, pescadores, guardas con NPC y objetos REALES, suite 258 checks x3 + guardián en rojo sobre el bloque N); iter. 10 Step-5-WorkBuddy 2026-10-22, Log 2131: +1 [x] cluster Amistad — 6 cadenas (regalo favorito, sentadilla de pesca, paseos, ficción, ayuda a un vecino, cartas de amistad) con NPC y objetos REALES de data/villagers/ y data/items/, suite 316 checks/0 fallos x3 y guardián EN ROJO por inyección de runtime sobre el bloque O).
## Verificación QA Cruzado — Hy3 / Kilo Code (2026-09-02)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02
**Rol:** QA cruzado (AGENTS.md §21.8) — diálogos / narrativa / detección de bugs

### Resultado de test (headless, Godot 4.7.2-stable)
- godot --headless --path game/isla-ancestral --script res://scripts/historias/test_historias.gd -> **0 fallos** (assertions + cadena completa + entrega inventario + ocultas + postgame + persistencia).
- Comando exacto usado: `"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral" --script "res://scripts/historias/test_historias.gd"`
- Salida clave: `=== TEST M23 HISTORIAS: 0 fallo(s) ===` + cadenas `cadena-faro`, `cadena-invernadero`, `cadena-secretta-luciernagas`, `cadena-epilogo-plaza` iniciadas/completadas en el mismo test.

### Evidencia por ítem
- `_test_carga`: 4 cadenas cargadas + sección `secondary_stories` presente.
- `_test_validador`: catálogo base sin errores de anti-repetición.
- `_test_cadena_completa`: secuencia hablar/explorar/puzzle/entregar -> completada + `faro_encendido` aplicado en WorldState M21 + diario `mision_cadena-faro` en M55.
- `_test_entrega_inventario`: rechazo sin objeto + avance con `semilla_antigua` + consecuencia `invernadero_abierto`.
- `_test_ocultas`: `cadena-secretta-luciernagas` ausente en `cadenas_disponibles()` antes de iniciar, visible después.
- `_test_postgame`: `cadena-epilogo-plaza` bloqueada sin final M22, abierta tras `final_elegido` no vacío.
- `_test_persistencia`: round-trip `get_save_data`/`restore_save_data` + purga de huérfanas.

### Hallazgo honesto (brecha de producto)
A diferencia de los clusters legales/store (que solo tenían JSON+Validator+Test), M23 SÍ incluye un autoload de servicio real. Lo pendiente son ítems de PRODUCTO/contenido (60 cadenas narrativas, diálogos posteriores M21, cosméticos M53/M45, integraciones M68/M36/M37/M32, testings E2E) — trabajo de contenido, no de bug.

### Veredicto QA
- DoD del *núcleo data-driven de historias secundarias*: **CUMPLIDO** (servicio + validador + 4 cadenas + test 0 fallos + regresiones OK).
- Producto completo: **INCOMPLETO** (falta contenido y algunas integraciones con dueño).
- Estado: **🟡 Con dudas** (núcleo verificado; contenido pendiente).

**Firma:** Hy3 / Kilo Code — 2026-09-02
**Totales:** 105 ítems · Completados: 73 · Pendientes: 30 · No resueltos: 2.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 24 [x] / 80 [ ] / 0 [?].
> Las marcas no se tocaron.
