**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 20: Sistema de Amistad

## A. Requisitos y alcance (8)

- [x] Definir el problema: relaciones significativas con vecinos sin castigo por ausencia [S]
- [x] Registrar dependencias: M19, M14, M29; relaciones M21, M23, M26, M31, M32, M73 [S]
- [x] Catalogar los 26 puntos de la seccion 19 del plan maestro [S]
- [x] Stack confirmado: Godot 4.x (>= 4.4.1) + Voxel Tools + GDScript [S]
- [x] RF1: niveles de amistad 0-10 con umbrales [S]
- [x] RF2: puntos de amistad acumulativos sin fuente de decaimiento [S]
- [x] RF3: limite de un regalo efectivo por vecino y dia [S]
- [x] RF4-RF8: preferencias, charlas, cartas, recompensas y eventos definidos [S]

## B. Puntos y progresion (8)

- [x] Curva de umbrales por nivel definida (20, 40, 70, 100, 140, 190, 250, 320, 400, 500) [S]
- [x] Regalo amado 20 puntos [S]
- [x] Regalo que gusta 10 puntos [S]
- [x] Regalo neutral 5 puntos [S]
- [x] Regalo duplicado 2 puntos (cortesia, nunca 0) [S]
- [x] Charla diaria 5 + 1 por nivel (max +10) [S]
- [x] Carta respondida 8 puntos [S]
- [x] Evento como participante 15 puntos [S]

## C. Niveles y desbloqueos (9)

- [x] Capacidad para definir nombres de nivel: Conocido, Amigo, Confidente, Mejor amigo [S]
- [x] Recompensas por nivel configuradas en data (objetos, recetas, frases) [S]
- [x] Acceso a eventos por nivel minimo [S]
- [x] Desbloqueo de historias de amistad al nivel requerido (M23) [S]
- [x] Excedente de puntos conservado al subir de nivel [S]
- [x] Bandeja de recompensas pendientes sin expiracion [S]
- [x] Recompensas reclamables en cualquier momento posterior (sin FOMO) [S]
- [x] Progress visible: barra de progreso dentro del nivel actual [S]
- [x] Feedback de nivel subido con animacion y lista de desbloqueos [M]

## D. Regalos y evaluador (11)

- [x] GiftEvaluator como clase estatica pura y determinista [S]
- [x] Clasificacion amado / gusta / neutral / duplicado [S]
- [x] Consumir gustos y disgustos de VecinoData (M19) de solo lectura [S]
- [x] Consumir categoria, rareza, calidad y valor de ItemData (M14) [S]
- [x] Evaluacion sin aleatoriedad critica [S]
- [x] Registro de duplicados por vecino en la memoria del NPC [S]
- [x] El item regalado sale del inventario y queda del vecino [S]
- [x] Reaccion del vecino por clase de regalo (expresion + texto M21) [M]
- [x] Soporte para regalos de cumpleanos sin consumir limite diario [M]
- [x] Soporte para objetos sin metadatos de regalo (regalo_valido = false) [S]
- [x] Coste de evaluacion menor a 1 ms por regalo [S]

## E. Charlas (7)

- [x] Registro de 1 charla efectiva por vecino y dia [S]
- [x] Puntos base + bonus por nivel de confianza [S]
- [x] Variantes de dialogo por nivel de amistad (M21) [M]
- [x] El vecino menciona recuerdos (primer regalo, cumpleanos celebrado) [M]
- [x] Charla no consume regalo diario (independiente) [S]
- [x] Sin charla repetida con los mismos puntos en el mismo dia [S]
- [x] Mensaje discreto de UI cuando la charla del dia ya se realizo [S]

## F. Cartas (7)

- [x] Enviar carta con texto seleccionado y adjunto opcional [M]
- [x] Limite de 1 carta efectiva por vecino y dia [S]
- [x] Respuesta del vecino al dia siguiente de juego (M29) [M]
- [x] Bandeja de correo para recibir respuestas y adjuntos de retorno [M]
- [x] Puntos aplicados al recibir la respuesta, no al enviar [S]
- [x] Textos de cartas y respuestas por vecino en data [C]
- [x] Notificacion de carta nueva sin interrumpir el flujo de juego [S]

## G. Eventos con amigos (9)

- [x] FriendshipEvent como Resource: tipo, nivel minimo, dia, hora, lugar, puntos [S]
- [x] Tipos soportados: visita, picnic, reunion, cumpleanos, festival (M73) [S]
- [x] Requisito de nivel minimo verificado antes de convocar [S]
- [x] Franja horaria validada contra el reloj M29 [S]
- [x] Lugar validado contra POI del mundo (M19/M08) [S]
- [x] Puntos otorgados a todos los participantes [S]
- [x] Escenas breves de evento con dialogos de los vecinos (M21) [C]
- [x] Registro del evento en la memoria del vecino (recuerdo) [S]
- [x] Eventos sin obligacion: el jugador puede declinar sin penalizacion [S]

## H. Sin decaimiento y sin FOMO (8)

- [x] Ausencia prolongada no reduce puntos ni niveles [S]
- [x] Ignorar a un vecino no afecta la relacion [S]
- [x] Sin timers de recompensas obligatorias diarias [S]
- [x] Contenido desbloqueable por amistad siempre disponible despues [S]
- [x] Recompensas por nivel no expiran [S]
- [x] Festivos/cumpleanos perdidos no castigan (se pueden repetir o conmemorar despues) [S]
- [x] Decision documentada: Alternativa B (acumulativa) en 02-Analisis.md [S]
- [x] Sin acciones negativas implementadas en el alcance base [S]

## I. Arquitectura y servicio (9)

- [x] FriendshipService como autoload unico [S]
- [x] Separacion de logica pura y capa de UI [S]
- [x] Estado por vecino independiente (no globales) [S]
- [x] Senales: regalo_entregado, charla_realizada, carta_recibida, nivel_subido, evento_celebrado [S]
- [x] Sin bucles por vecino en update (evaluacion solo bajo accion) [S]
- [x] Desacoplamiento: UI suscribe senales y llama API publica [S]
- [x] Recursos de configuracion (.tres) para niveles, eventos y cartas [S]
- [x] Compatible con pausa de M29 (contadores de dia congelados) [S]
- [x] Log DOM-AMISTAD centralizado con rotacion (seccion 18) [M]

## J. API GDScript (7)

- [x] get_nivel / get_puntos / get_progreso por vecino [S]
- [x] get_limite_dia(vecino, tipo) para UI [S]
- [x] regalar(vecino_id, item_id) -> Dictionary con clase y puntos [S]
- [x] charlar(vecino_id) -> Dictionary [S]
- [x] enviar_carta / celebrar_evento con contratos definidos [S]
- [x] get_memoria / get_recompensas_pendientes / reclamar_recompensa [S]
- [x] API estable y documentada para otros modulos (M21, M23, UI) [S]

## K. Integracion M19 (NPC y Vecinos) (7)

- [x] VecinoData consumido de M19: gustos, disgustos, amados, personalidad [S]
- [x] Los vecinos no registrados no existen en el servicio [S]
- [x] Alta desregistro de vecino: al mudarse se conserva el historial para futuro reencuentro [S]
- [x] Memoria del vecino alimentada por interacciones destacadas [S]
- [x] Rutinas y horarios de M19 intactos (M20 no modifica IA) [S]
- [x] Cambios de rutina sociales (visitar al mejor amigo) habilitados por data [M]
- [x] Sin acoplamiento con componentes de navegacion ni FSM [S]

## L. Integracion M14 (Inventario) (6)

- [x] Metadatos de item consultados sin modificar M14 [S]
- [x] Extraccion del item al regalar integrada [S]
- [x] Insercion de objetos de recompensa al reclamar [S]
- [x] Recetas desbloqueadas por nivel van a la tabla de crafting [S]
- [x] Adjuntos de carta usados y recibidos correctamente [S]
- [x] Items decorativos de recompensa marcados como regalo valido [S]

## M. Integracion M23 (Historias Secundarias) (6)

- [x] Misiones de amistad consultan nivel minimo [S]
- [x] Misiones consultan memoria del vecino (recuerdos) [S]
- [x] Bonus de puntos al completar historia secundaria [S]
- [x] Recompensas exclusivas por historia [S]
- [x] Cierre de historia crea recuerdo permanente [S]
- [x] Sin bucles: amistad 10 no bloquea historias pendientes [S]

## N. Persistencia (6)

- [x] Estado por vecino serializable: puntos, nivel, historial de hoy [S]
- [x] Cartas pendientes y respuestas guardadas [S]
- [x] Eventos celebrados y memoria persistidos [S]
- [x] Schema versionado y migracion al cargar (M26) [M]
- [x] Guardar/recargar a mitad de nivel restaura progreso exacto [M]
- [x] Vecinos nuevos agregados al schema sin romper guardados previos [M]

## O. Edge cases (9)

- [x] Regalo duplicado con puntos minimos y mensaje amable [S]
- [x] Vecino ausente de la isla (viaje, M69): regalo rechazado con aviso [S]
- [x] Vecino que se muda: historial archivado, sistema no falla [M]
- [x] Inventario vacio: opcion regalar deshabilitada con tooltip [S]
- [x] Carta sin texto seleccionado: validacion [S]
- [x] Evento convocado con participante ausente: se omite con aviso [S]
- [x] Doble click en reclamar recompensa: idempotente [S]
- [x] Dia cambiado a mitad de accion (medianoche M29): limites recien recalculados [M]
- [x] Guardado corrupto del modulo: fallback a estado vacio sin crash [M]

## P. Optimizacion y rendimiento (5)

- [x] Evaluador sin allocations relevantes (diccionarios reutilizados) [S]
- [x] Indice de vecinos por id para consultas O(1) [S]
- [x] Sin suscriptores colgados al destruir UI [S]
- [x] Bandeja de recompensas bajo demanda (no refresco continuo) [S]
- [x] Logs de debug desactivados en release (conditional symbols) [S]

## Q. UI/UX y feedback (7)

- [x] Panel de vecino con nivel, puntos y barra de progreso [M]
- [x] HUD de limite diario (regalo, charla, carta) [M]
- [x] Popup de reaccion del vecino al regalo [M]
- [x] Bandeja de correo y recompensas con contador no intrusivo [M]
- [x] Animacion de nivel subido con desbloqueos listados [M]
- [x] Tooltips en items de regalo con pista de gustos descubiertos [M]
- [x] Accesibilidad: textos legibles, contraste, opcion de texto lento [M]

## R. Polish y cozy (6)

- [x] Frases de despedida segun nivel ("hasta manana, amigo") [M]
- [x] Recuerdos hablados: el vecino comenta el primer regalo [M]
- [x] Pequenos regalos de retorno del vecino por correo [M]
- [x] Reacciones suaves y nunca hostiles por parte del vecino [S]
- [x] Coherencia de tono: el NPC nunca rechaza con dureza [S]
- [x] Eventos con ambiente acogedor (sonido ambiente, luz calida) [C]

## S. Testings y QA (7)

- [x] Test: regalo amado/gusta/neutral/duplicado devuelve puntos esperados [M]
- [x] Test: limite diario respetado para regalo, charla y carta [M]
- [x] Test: excedente conservado al subir de nivel [M]
- [x] Test: ausencia de 30 dias no reduce puntos (sin FOMO) [M]
- [x] Test: guardar/cargar a mitad de nivel restaura exacto [M]
- [x] Test: reclamar recompensa idempotente [S]
- [x] Recorrido M114: 10 vecinos a nivel 5+ en sesiones simuladas sin fallos [C]

## T. Documentacion y cierre (5)

- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado (alternativas y decision) [S]
- [x] 03-Diseno creado y firmado (arquitectura y contratos) [S]
- [x] 04-Codigo creado y firmado (rutas, firmas, Notas del Agente) [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]