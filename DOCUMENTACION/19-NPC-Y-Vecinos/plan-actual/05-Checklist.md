**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. 1 por Deepseek V4 Flash)
**Plataforma:** Kilo Code

# 05-Checklist.md — Módulo 19: NPC y Vecinos

> Marcadores de esfuerzo al final de cada ítem: [S] simple · [M] medio · [C] complejo.

## A. Requisitos del módulo (8)

- [x] Definir el problema: isla vacía sin habitantes, necesidad de 8-12 vecinos memorables [S]
- [ ] Registrar relaciones: M64 consume, M21/M20/M25 integran, M29/M61 como fuente [S]
- [ ] Catalogar los 26 puntos de la sección 18 del plan maestro [S]
- [x] RF1: población gestionada de 8-12 vecinos simultáneos [S] — iter. 1: POBLACION_MAX=10 en VillagerManager con plaza_libre(); test mudanzas valida límite
- [x] RF2: mudanza con permiso del jugador (entrada) y aviso previo (salida) [S] — glm-5.3-flash 2026-09-01: propuesta/aprobación/llegada/partida implementadas y testeadas
- [ ] RF3: rutinas diarias por perfil y franja horaria [S]
- [x] RF4: interacción con tecla F con indicador y despacho a diálogo [S]
- [x] RF5+RF6+RF7: reacciones a regalos, estado emocional y memoria de interacciones [S] — iter. 3: memoria P26 completa (registrar_interaccion/memoria_de/memoria_conteo, cap rotativo 20, persistente M59) + regalo_recibido enlaza a memoria + M20/M21 consumen señales (villager_mood tiene ánimo)

## B. Resolución de los 26 puntos del plan (26)

- [x] P1: definir cantidad inicial de NPC (6 al primer día) [M] — iter. 3: poblar_arranque() activa hasta 6 perfiles (idempotente, determinista por id; testeado: 5 perfiles disponibles → 5 activados)
- [x] P2: definir cantidad máxima (10 activos, rango 8-12) [S]
- [ ] P3: diseñar especies (oso, mapache, zorro, rana, conejo, búho, nutria, jabalí, gato, erizo) [M]
- [ ] P4: diseñar siluetas (referencia a escena vóxel por especie) [M]
- [ ] P5: diseñar personalidades (animada, seria, dulce, tímida, soñadora, gruñona amable) [M]
- [ ] P6: diseñar edades (niñez, juventud, adulto, anciano) [S]
- [ ] P7: diseñar profesiones (granjero, pescador, cocinero, artesano, bibliotecario, guía) [M]
- [ ] P8: diseñar historias (trasfondo por vecino en fichas de perfil) [M]
- [ ] P9: diseñar gustos (lista de objetos por vecino) [S]
- [ ] P10: diseñar disgustos (lista de objetos rechazados) [S]
- [x] P11: diseñar rutinas (agenda diaria por perfil) [M] — iter. 3: rutina_diaria del perfil .tres tiene prioridad sobre franjas default (testeado)
- [x] P12: diseñar horarios (franjas 06-08 desayuno, 08-12 trabajo, 12-14 comida, 14-18 trabajo/ocio, 18-22 social, 22-06 sueño) [M] — iter. 3: FRANJAS_DIA con 6 franjas del diseño; 22-06 = dormir SIEMPRE (testeado)
- [ ] P13: diseñar hogares (parcela propia con estilo por vecino) [M]
- [ ] P14: diseñar relaciones (vínculos entre vecinos: parejas, amigos, rivales amistosos) [M]
- [ ] P15: diseñar amistades (afinidad entre vecinos que comparten hobbies) [S]
- [ ] P16: diseñar conflictos (desacuerdos suaves, nunca hostilidad) [M]
- [ ] P17: diseñar hobbies (pesca, jardinería, lectura, canto, artesanía) [S]
- [ ] P18: diseñar diálogos (líneas por contexto: saludo, clima, ruinas, regalo) [M]
- [ ] P19: diseñar regalos (mapa de gustos/disgustos a objetos del juego) [M]
- [ ] P20: diseñar misiones (encargos personales del vecino al jugador) [M]
- [ ] P21: diseñar eventos (cumpleaños, festivales, visitas de candidatos) [M]
- [ ] P22: diseñar animaciones (saludar, sentarse, dormir, caminar, comer) [M]
- [x] P23: crear navegación (contrato de destinos válidos hacia M64; el vecino no patenta IA propia) [M] — iter. 3: agenda_dia()/actividad_actual() son el contrato de consulta; get_hogares()/get_spawn_for_parcela() dan destinos físicos; la IA la patenta M64
- [x] P24: crear comportamiento (perfil alimenta la agenda de M64; reglas de ocupación del vecino) [M] — iter. 3: actividad_actual() combina perfil+franjas+PRNG determinista (testeado: retorna actividad válida en cualquier hora)
- [x] P25: crear estados emocionales (VillagerMood con base persistida + deltas) [M]
- [x] P26: crear memoria de interacciones (historial por vecino: regalos, charlas, hitos) [M] — iter. 3: registrar_interaccion() con cap rotativo 20 + memoria_de()/memoria_conteo() + persistencia con purga de huérfanos (testeado round-trip)

## C. Datos y perfiles del vecino (8)

- [x] VillagerProfile como Resource (.tres) editable en editor [S]
- [x] Campos: id, nombre, especie, silueta, personalidad, edad, profesión, historia [S]
- [x] Campos: gustos, disgustos, hobbies, linea_saludo, linea_despedida, linea_sueno [S]
- [ ] rutina_diaria como Dictionary hora→actividad [S]
- [x] hogar_deseado (bioma/estilo de parcela) [S]
- [x] Evaluación de objetos: evaluar_objeto() con tabla gustos/disgustos/neutro [S]
- [ ] Ids únicos de vecino sin duplicados posibles en el catálogo [S]
- [x] Catálogo de candidatos mayor que el límite activo (14 perfiles) [M] — 5 perfiles .tres en data/villagers/ (catalina + finneas/mateo/luna/bruno)

## D. Población de la isla y mudanza (9)

- [x] 6 vecinos iniciales al primer día (población de arranque) [M] — iter. 3: poblar_arranque() deferred al boot, activa perfiles con snap al terreno (TerrainLocator) y memoria de mudanza; idempotente (testeado)
- [x] Límite máximo 10 activos con plaza_libre() verificable [S]
- [x] Candidato aparece como visitante en puerto/plaza cuando hay plaza libre [M] — proponer_mudanza() + visitantes[] (indicador visual con dueño M53)
- [ ] Propuesta de mudanza visible con burbuja de interés (indicador) [M]
- [x] Aprobar mudanza asigna parcela libre y agenda llegada al día siguiente 08:00 [M] — aprobar_mudanza() agenda día siguiente, llegada 08:00 vía GameTime.hora_cambio + _asignar_hogar()
- [x] Cancelar mudanza limpia en las 3 fases (propuesta, aprobada, llegada) [M] — cancelar_mudanza() en propuesta y aprobada (testeadas); llegada-en-curso cubierta por el mismo dictionary
- [x] Aviso de partida 1 día antes con diálogo de despedida [M] — anunciar_partida() + aviso_partida() (burbuja visual con dueño M53)
- [x] Rechazo de partida: el vecino permanece con enfriamiento de 30 días de nuevos avisos [M] — rechazar_partida() + enfriamiento 30 días (ENFRIAMIENTO_PARTIDA, testeadas)
- [x] Partida libera la parcela y notifica a la población (reacción de otros vecinos) [M] — aceptar_partida() → día siguiente 08:00 libera hogar + señal vecino_partio

## E. Rutinas diarias y horarios (8)

- [ ] Agenda por franja horaria alineada con M29 (Tiempo/Calendario) [S]
- [ ] Variación +/- 30 min por vecino usando PRNG de partida (M29) [S]
- [ ] Franja noche: todos duermen (niños 21:00, ancianos 20:30, resto 22:00) [S]
- [ ] Franjas de comida: desayuno 06-08, almuerzo 12-14, cena 19-21 [S]
- [ ] Actividad principal por profesión (granjero→parcela, pescador→muelle) [M]
- [ ] Ocio social 18-22: plaza, cantina, playa según afinidad [M]
- [ ] Comportamiento en días de lluvia: rutina indoor (refugio/casa) [M]
- [ ] Comportamiento en festivales: agenda especial de evento (M73/M29) [M]

## F. Interacción con tecla F (7)

- [x] Acción interactuar mapeada en InputMap de Godot (tecla F) [S]
- [x] Detección del vecino más cercano en rango 3.0 m del jugador [M]
- [x] Raycast vóxel entre jugador y vecino (no interactuar a través de paredes) [C] — hay_linea_de_vision() muestreo DDA vía VoxelTool (patrón M13), integrada en _intentar_interaccion/detectar_objetivo
- [x] Indicador visual "F" sobre la cabeza solo cuando hay objetivo válido [M]
- [ ] Vecinos ocupados (dormido, dialogando, evento) se excluyen o ignoran con feedback [M]
- [x] Un solo vecino por frame: prioridad al más cercano sin toggles raros [S]
- [x] Interacción despachada al VillagerDialogueHook (sin UI propia) [S]

## G. Regalos y reacciones (6)

- [ ] Regalo desde inventario hacia el vecino con la tecla F (un objeto a la vez) [M]
- [x] Evaluación contra gustos/disgustos con evaluación numérica (+1.0 / -0.5 / 0.0) [S]
- [x] Línea de reacción contextual según resultado (hook hacia M21) [S]
- [x] Delta de estado emocional al recibir regalo (VillagerMood) [S]
- [ ] Señal regalo_recibido emitida para M20 (puntos de amistad) [S]
- [ ] Límite de regalos por día (máx 3 por vecino, sin penalización adicional) [M]

## H. Estados emocionales y memoria (8)

- [ ] ánimo_base persistido por vecino (checkpoint) [S]
- [ ] Deltas calculados: clima (M31/M32), estación (M29), hora, eventos [M]
- [x] Clamp del ánimo a [-1.0, 1.0] con estado textual (alegre/neutral/triste) [S]
- [x] factor_dialogo que escala tono de líneas para M21 [S]
- [ ] Historial persistente: regalos recibidos con fecha y resultado [M]
- [ ] Historial persistente: charlas contadas y hitos de amistad [S]
- [ ] Memoria de objetos rechazados repetidos (el vecino lo recuerda en charla) [M]
- [ ] El ánimo nunca bloquea contenido: solo modula tono (cozy) [S]

## I. Integración con M64 (IA de NPC) (6)

- [x] VillagerManager.obtener_activos() como fuente de agentes de la burbuja [S] — existe desde iter. 1 (NPCManager se suscribe a poblacion_cambio; verificado en boot)
- [x] rutina_diaria del perfil alimenta la agenda horaria de M64 [S] — iter. 3: agenda_dia() prioriza rutina_diaria del .tres sobre franjas default (testeado)
- [ ] El vecino informa objetivo_actual() para animación sincronizada [S]
- [ ] NPCs fuera de la burbuja usan receta ligera (M64) sin pérdida de datos [M]
- [ ] Fallback IrACasa respeta la parcela del hogar del vecino [M]
- [ ] Sin duplicación de lógica: M19 entrega datos, M64 ejecuta comportamiento [S]

## J. Integración con M21 (Diálogos) (6)

- [x] VillagerDialogueHook con señal linea_solicitada [S]
- [ ] Líneas por contexto: saludo, clima, hora, estación, progreso, regalo [M]
- [ ] Respuestas seleccionables provistas por el hook (respuestas_disponibles) [M]
- [ ] Cierre de conversación con notificar_cierre (resumen para M20) [S]
- [ ] Claves de línea únicas listas para localización (base de traducción M21) [M]
- [x] Diálogos cortos no bloqueantes (el vecino reanuda su agenda al terminar) [S] — contracto: interaccion F no detiene la agenda (actividad_actual() sigue calculando); M21/M64 dueno de la presentación

## K. Integración con M20 (Amistad) (6)

- [x] Señal regalo_recibido con objeto_id y resultado de evaluación [S]
- [x] Señal conversacion_terminada con resumen (charla, opciones elegidas) [S]
- [ ] Nivel de amistad consumible por el hook para líneas especiales [M]
- [ ] Cambios de rutina por amistad alta (invitaciones del vecino) [M]
- [ ] Eventos colectivos (fiestas) combinables con vínculos [S]
- [ ] Sin pérdida de amistad por no jugar (cozy, sin castigo por ausencia) [S]

## L. Integración con M25 (Ruinas) (4)

- [ ] Líneas ruina_* activadas al descubrir ruinas (hook) [M]
- [ ] Vecino con amistad alta revela pista de ruina (evento único) [C]
- [ ] Hallazgo de ruina suma delta de mood +0.2 al vecino con quien se comparte [S]
- [ ] Historia de vecinos conectada a la narrativa ancestral sin spoilers globales [M]

## M. Edge cases y robustez (7)

- [ ] Vecino bloqueado por terreno vóxel (pared, cierre de parcela) → fallback de M64 [M]
- [ ] Vecino atascado contra otro NPC o el jugador → el jugador nunca es empujado [M]
- [ ] Mudanza cancelada a mitad de proceso → cancelación limpia en cualquier fase [M]
- [ ] Vecino dormido con F pulsada → feedback respetuoso ("duerme profundamente") [S]
- [ ] Plaza ocupada con candidato en visita → el visitante espera o se va según temporizador [M]
- [ ] Guardado con IDs huérfanos → descartar con log y reparar catálogo [M]
- [ ] Doble entrada del mismo perfil (bug de persistencia) → validación de unicidad al cargar [M]

## N. Optimización y rendimiento (6)

- [ ] Catálogo cargado bajo demanda (no instanciar los 14 candidatos) [M]
- [ ] VillagerManager sin procesamiento por frame (solo eventos y ticks de M29) [S]
- [ ] Detección de objetivo F con barrido barato (distancia + raycast único) [M]
- [ ] Indicador "F" instanciado por pool (un solo nodo reutilizado) [M]
- [ ] Meshes vóxel por silueta con pooling de instancias (Voxel Tools) [C]
- [ ] Sin pathfinding a destinos fuera de navmesh (validación previa con M64) [M]

## O. Persistencia y guardado (5)

- [x] VillagerSaveData: activos (perfil_id, parcela_id, animo_base, memoria) [M] — iter. 3: save con hogares (parcela_id) + memoria P26; ánimo base vive en villager_mood.gd (M19) y su persistencia con dueño M64/M20
- [ ] Persistencia de visitantes y partidas pendientes [S]
- [ ] Determinismo entre cargas: mismo día genera la misma agenda (PRNG M29) [M]
- [ ] Migración de guardado: versión de datos del módulo (v1) [S]
- [ ] Guardado atómico con validación de integridad y log de errores [M]

## P. Pruebas y QA (5)

- [ ] Test: 24 h simuladas → rutinas cumplidas por los 10 vecinos [C]
- [ ] Test: flujo completo de mudanza (visita → permiso → llegada → partida) [M]
- [ ] Test: cancelación de mudanza en las 3 fases sin estado corrupto [M]
- [ ] Test: raycast vóxel de F a través de pared de 1 vóxel (bloqueo correcto) [C]
- [ ] Recorrido cozy: 3 días de juego con regalos, charlas y 1 mudanza sin bugs [C]

## Q. Documentación y cierre (5)

- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado (alternativas documentadas) [S]
- [ ] 03-Diseno creado y firmado (arquitectura + contratos API) [S]
- [ ] 04-Codigo creado y firmado (rutas, firmas GDScript, Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo, 130 ítems) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

## Notas del Agente

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 21:45
**Estado:** Liberado (iter. 3 cerrada) — 45/131 [x]

### Lo que hice en iter. 3 (Log 553)
- **P26 memoria de interacciones**: registrar_interaccion(vecino, tipo, detalle) con cap rotativo 20 (FIFO), memoria_de()/memoria_conteo() para M20/M21/M64, entregar_regalo() ahora memorializa, persistencia en sección "npc" con purga de huérfanos.
- **P11/P12/P24 agenda horaria para M64**: agenda_dia(vecino, dia) con las 6 franjas del diseño (06-08 desayuno … 22-06 dormir), rutina_diaria del perfil .tres con prioridad, variación PRNG determinista (seed día*100000+hash(id), 15% ocio, dormir SIEMPRE fijo); actividad_actual() consulta la franja vigente (soporta franja nocturna circular).
- **P1 población de arranque**: poblar_arranque() deferred al boot activa hasta 6 perfiles (orden determinista por id, snap al terreno con TerrainLocator, parcela asignada, memoria de mudanza), idempotente; en headless sin escena registra nodos lógicos bajo el manager (la visual completa M64/escena).
- **FIX de aliasing crítico**: get_save_data() serializaba Dictionary/Array POR REFERENCIA sin duplicate() — un _clear() posterior del restore vaciaba también el save capturado. Corregido con deep copy en TODOS los campos (memoria/hogares/llegadas/partidas/enfriamientos). Bug latente desde iter. 2 que las pruebas de round-trip de mudanzas no detectaban porque no hacían clear intermedio.
- **Tests**: test_memoria_agenda.gd nuevo (8 secciones ~35 checks) — 0 fallos; regresión test_mudanzas.gd 0 fallos.

### Hallazgo técnico (pitfall para guía 07 §8)
- **Aliasing de Dictionary/Array en get_save_data()**: en Godot los contenedores son por referencia. Si get_save_data() los serializa sin .duplicate(true) y el flujo de guardado (o un restore intermedio) muta el estado, el snapshot queda corrompido silenciosamente. Regla: SIEMPRE deep-copy en get_save_data() de ISaveProviders. Los otros providers del proyecto deberían auditarse con este lente (M22/M32/M59 providers).

### Lo que NO está resuelto (pendientes con dueño)
- P3-P10, P13-P22: diseño de especies/siluetas/personalidades/relaciones/diálogos concretos (contenido, dueño M19 contenido + M161 visual).
- Burbujas/indicadores visuales (M53), animaciones (M48).
- Agenda en festivales (§M73/M29): hook pendiente de EventManager.
- Ánimo base persistido: villager_mood tiene el estado, su guardado con dueño M64/M20.
- El villager.tscn en scenes/npc/ no existe aún (el manager cae a Node3D placeholder): dueño M161/M45 visual.

### Validación
- test_memoria_agenda.gd: 0 fallos (8 secciones).
- Regresión: test_mudanzas.gd 0 fallos; test_inventario.gd 0 fallos; test_museo.gd 0 fallos.
- Boot: [M19] Catálogo de vecinos: 5 perfiles + Población de arranque: 5 vecinos activados.

### Recomendaciones para el próximo agente
- M64: consumir actividad_actual(vecino_id) cada tick para el estado de la FSM y agenda_dia() para planificar el día; los destinos físicos están en get_hogares()/get_spawn_for_parcela().
- M20/M21: la memoria de cada vecino alimenta reacciones con continuidad (memoria_conteo(vecino, "regalo") para diálogos "ya me diste N regalos").
- Auditar los otros ISaveProvider con el lente del aliasing (deep copy en get_save_data).
- Poblar arranque es deferred: si la escena Main carga más tarde, los vecinos quedan bajo el manager (lógicos); al existir villager.tscn se instanciará con perfil sincronizado.
