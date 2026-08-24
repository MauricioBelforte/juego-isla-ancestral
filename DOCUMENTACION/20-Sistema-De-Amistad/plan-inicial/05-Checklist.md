**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 20: Sistema de Amistad

## A. Requisitos y alcance (8)

- [ ] Definir el problema: relaciones significativas con vecinos sin castigo por ausencia [S]
- [ ] Registrar dependencias: M19, M14, M29; relaciones M21, M23, M26, M31, M32, M73 [S]
- [ ] Catalogar los 26 puntos de la seccion 19 del plan maestro [S]
- [ ] Stack confirmado: Godot 4.x (>= 4.4.1) + Voxel Tools + GDScript [S]
- [ ] RF1: niveles de amistad 0-10 con umbrales [S]
- [ ] RF2: puntos de amistad acumulativos sin fuente de decaimiento [S]
- [ ] RF3: limite de un regalo efectivo por vecino y dia [S]
- [ ] RF4-RF8: preferencias, charlas, cartas, recompensas y eventos definidos [S]

## B. Puntos y progresion (8)

- [ ] Curva de umbrales por nivel definida (20, 40, 70, 100, 140, 190, 250, 320, 400, 500) [S]
- [ ] Regalo amado 20 puntos [S]
- [ ] Regalo que gusta 10 puntos [S]
- [ ] Regalo neutral 5 puntos [S]
- [ ] Regalo duplicado 2 puntos (cortesia, nunca 0) [S]
- [ ] Charla diaria 5 + 1 por nivel (max +10) [S]
- [ ] Carta respondida 8 puntos [S]
- [ ] Evento como participante 15 puntos [S]

## C. Niveles y desbloqueos (9)

- [ ] Capacidad para definir nombres de nivel: Conocido, Amigo, Confidente, Mejor amigo [S]
- [ ] Recompensas por nivel configuradas en data (objetos, recetas, frases) [S]
- [ ] Acceso a eventos por nivel minimo [S]
- [ ] Desbloqueo de historias de amistad al nivel requerido (M23) [S]
- [ ] Excedente de puntos conservado al subir de nivel [S]
- [ ] Bandeja de recompensas pendientes sin expiracion [S]
- [ ] Recompensas reclamables en cualquier momento posterior (sin FOMO) [S]
- [ ] Progress visible: barra de progreso dentro del nivel actual [S]
- [ ] Feedback de nivel subido con animacion y lista de desbloqueos [M]

## D. Regalos y evaluador (11)

- [ ] GiftEvaluator como clase estatica pura y determinista [S]
- [ ] Clasificacion amado / gusta / neutral / duplicado [S]
- [ ] Consumir gustos y disgustos de VecinoData (M19) de solo lectura [S]
- [ ] Consumir categoria, rareza, calidad y valor de ItemData (M14) [S]
- [ ] Evaluacion sin aleatoriedad critica [S]
- [ ] Registro de duplicados por vecino en la memoria del NPC [S]
- [ ] El item regalado sale del inventario y queda del vecino [S]
- [ ] Reaccion del vecino por clase de regalo (expresion + texto M21) [M]
- [ ] Soporte para regalos de cumpleanos sin consumir limite diario [M]
- [ ] Soporte para objetos sin metadatos de regalo (regalo_valido = false) [S]
- [ ] Coste de evaluacion menor a 1 ms por regalo [S]

## E. Charlas (7)

- [ ] Registro de 1 charla efectiva por vecino y dia [S]
- [ ] Puntos base + bonus por nivel de confianza [S]
- [ ] Variantes de dialogo por nivel de amistad (M21) [M]
- [ ] El vecino menciona recuerdos (primer regalo, cumpleanos celebrado) [M]
- [ ] Charla no consume regalo diario (independiente) [S]
- [ ] Sin charla repetida con los mismos puntos en el mismo dia [S]
- [ ] Mensaje discreto de UI cuando la charla del dia ya se realizo [S]

## F. Cartas (7)

- [ ] Enviar carta con texto seleccionado y adjunto opcional [M]
- [ ] Limite de 1 carta efectiva por vecino y dia [S]
- [ ] Respuesta del vecino al dia siguiente de juego (M29) [M]
- [ ] Bandeja de correo para recibir respuestas y adjuntos de retorno [M]
- [ ] Puntos aplicados al recibir la respuesta, no al enviar [S]
- [ ] Textos de cartas y respuestas por vecino en data [C]
- [ ] Notificacion de carta nueva sin interrumpir el flujo de juego [S]

## G. Eventos con amigos (9)

- [ ] FriendshipEvent como Resource: tipo, nivel minimo, dia, hora, lugar, puntos [S]
- [ ] Tipos soportados: visita, picnic, reunion, cumpleanos, festival (M73) [S]
- [ ] Requisito de nivel minimo verificado antes de convocar [S]
- [ ] Franja horaria validada contra el reloj M29 [S]
- [ ] Lugar validado contra POI del mundo (M19/M08) [S]
- [ ] Puntos otorgados a todos los participantes [S]
- [ ] Escenas breves de evento con dialogos de los vecinos (M21) [C]
- [ ] Registro del evento en la memoria del vecino (recuerdo) [S]
- [ ] Eventos sin obligacion: el jugador puede declinar sin penalizacion [S]

## H. Sin decaimiento y sin FOMO (8)

- [ ] Ausencia prolongada no reduce puntos ni niveles [S]
- [ ] Ignorar a un vecino no afecta la relacion [S]
- [ ] Sin timers de recompensas obligatorias diarias [S]
- [ ] Contenido desbloqueable por amistad siempre disponible despues [S]
- [ ] Recompensas por nivel no expiran [S]
- [ ] Festivos/cumpleanos perdidos no castigan (se pueden repetir o conmemorar despues) [S]
- [ ] Decision documentada: Alternativa B (acumulativa) en 02-Analisis.md [S]
- [ ] Sin acciones negativas implementadas en el alcance base [S]

## I. Arquitectura y servicio (9)

- [ ] FriendshipService como autoload unico [S]
- [ ] Separacion de logica pura y capa de UI [S]
- [ ] Estado por vecino independiente (no globales) [S]
- [ ] Senales: regalo_entregado, charla_realizada, carta_recibida, nivel_subido, evento_celebrado [S]
- [ ] Sin bucles por vecino en update (evaluacion solo bajo accion) [S]
- [ ] Desacoplamiento: UI suscribe senales y llama API publica [S]
- [ ] Recursos de configuracion (.tres) para niveles, eventos y cartas [S]
- [ ] Compatible con pausa de M29 (contadores de dia congelados) [S]
- [ ] Log DOM-AMISTAD centralizado con rotacion (seccion 18) [M]

## J. API GDScript (7)

- [ ] get_nivel / get_puntos / get_progreso por vecino [S]
- [ ] get_limite_dia(vecino, tipo) para UI [S]
- [ ] regalar(vecino_id, item_id) -> Dictionary con clase y puntos [S]
- [ ] charlar(vecino_id) -> Dictionary [S]
- [ ] enviar_carta / celebrar_evento con contratos definidos [S]
- [ ] get_memoria / get_recompensas_pendientes / reclamar_recompensa [S]
- [ ] API estable y documentada para otros modulos (M21, M23, UI) [S]

## K. Integracion M19 (NPC y Vecinos) (7)

- [ ] VecinoData consumido de M19: gustos, disgustos, amados, personalidad [S]
- [ ] Los vecinos no registrados no existen en el servicio [S]
- [ ] Alta desregistro de vecino: al mudarse se conserva el historial para futuro reencuentro [S]
- [ ] Memoria del vecino alimentada por interacciones destacadas [S]
- [ ] Rutinas y horarios de M19 intactos (M20 no modifica IA) [S]
- [ ] Cambios de rutina sociales (visitar al mejor amigo) habilitados por data [M]
- [ ] Sin acoplamiento con componentes de navegacion ni FSM [S]

## L. Integracion M14 (Inventario) (6)

- [ ] Metadatos de item consultados sin modificar M14 [S]
- [ ] Extraccion del item al regalar integrada [S]
- [ ] Insercion de objetos de recompensa al reclamar [S]
- [ ] Recetas desbloqueadas por nivel van a la tabla de crafting [S]
- [ ] Adjuntos de carta usados y recibidos correctamente [S]
- [ ] Items decorativos de recompensa marcados como regalo valido [S]

## M. Integracion M23 (Historias Secundarias) (6)

- [ ] Misiones de amistad consultan nivel minimo [S]
- [ ] Misiones consultan memoria del vecino (recuerdos) [S]
- [ ] Bonus de puntos al completar historia secundaria [S]
- [ ] Recompensas exclusivas por historia [S]
- [ ] Cierre de historia crea recuerdo permanente [S]
- [ ] Sin bucles: amistad 10 no bloquea historias pendientes [S]

## N. Persistencia (6)

- [ ] Estado por vecino serializable: puntos, nivel, historial de hoy [S]
- [ ] Cartas pendientes y respuestas guardadas [S]
- [ ] Eventos celebrados y memoria persistidos [S]
- [ ] Schema versionado y migracion al cargar (M26) [M]
- [ ] Guardar/recargar a mitad de nivel restaura progreso exacto [M]
- [ ] Vecinos nuevos agregados al schema sin romper guardados previos [M]

## O. Edge cases (9)

- [ ] Regalo duplicado con puntos minimos y mensaje amable [S]
- [ ] Vecino ausente de la isla (viaje, M69): regalo rechazado con aviso [S]
- [ ] Vecino que se muda: historial archivado, sistema no falla [M]
- [ ] Inventario vacio: opcion regalar deshabilitada con tooltip [S]
- [ ] Carta sin texto seleccionado: validacion [S]
- [ ] Evento convocado con participante ausente: se omite con aviso [S]
- [ ] Doble click en reclamar recompensa: idempotente [S]
- [ ] Dia cambiado a mitad de accion (medianoche M29): limites recien recalculados [M]
- [ ] Guardado corrupto del modulo: fallback a estado vacio sin crash [M]

## P. Optimizacion y rendimiento (5)

- [ ] Evaluador sin allocations relevantes (diccionarios reutilizados) [S]
- [ ] Indice de vecinos por id para consultas O(1) [S]
- [ ] Sin suscriptores colgados al destruir UI [S]
- [ ] Bandeja de recompensas bajo demanda (no refresco continuo) [S]
- [ ] Logs de debug desactivados en release (conditional symbols) [S]

## Q. UI/UX y feedback (7)

- [ ] Panel de vecino con nivel, puntos y barra de progreso [M]
- [ ] HUD de limite diario (regalo, charla, carta) [M]
- [ ] Popup de reaccion del vecino al regalo [M]
- [ ] Bandeja de correo y recompensas con contador no intrusivo [M]
- [ ] Animacion de nivel subido con desbloqueos listados [M]
- [ ] Tooltips en items de regalo con pista de gustos descubiertos [M]
- [ ] Accesibilidad: textos legibles, contraste, opcion de texto lento [M]

## R. Polish y cozy (6)

- [ ] Frases de despedida segun nivel ("hasta manana, amigo") [M]
- [ ] Recuerdos hablados: el vecino comenta el primer regalo [M]
- [ ] Pequenos regalos de retorno del vecino por correo [M]
- [ ] Reacciones suaves y nunca hostiles por parte del vecino [S]
- [ ] Coherencia de tono: el NPC nunca rechaza con dureza [S]
- [ ] Eventos con ambiente acogedor (sonido ambiente, luz calida) [C]

## S. Testings y QA (7)

- [ ] Test: regalo amado/gusta/neutral/duplicado devuelve puntos esperados [M]
- [ ] Test: limite diario respetado para regalo, charla y carta [M]
- [ ] Test: excedente conservado al subir de nivel [M]
- [ ] Test: ausencia de 30 dias no reduce puntos (sin FOMO) [M]
- [ ] Test: guardar/cargar a mitad de nivel restaura exacto [M]
- [ ] Test: reclamar recompensa idempotente [S]
- [ ] Recorrido M114: 10 vecinos a nivel 5+ en sesiones simuladas sin fallos [C]

## T. Documentacion y cierre (5)

- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado (alternativas y decision) [S]
- [ ] 03-Diseno creado y firmado (arquitectura y contratos) [S]
- [ ] 04-Codigo creado y firmado (rutas, firmas, Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]