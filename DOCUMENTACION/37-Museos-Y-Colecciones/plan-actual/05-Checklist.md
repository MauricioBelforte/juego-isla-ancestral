**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 37: Museos y Colecciones

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Alcance y requisitos (10)

- [ ] Definir el problema: museo como sistema de coleccion visitable y gratificante [S]
- [ ] Registrar dependencias: M36 (fauna), M34 (pesca), M25 (ruinas), M55 (diario) [S]
- [ ] Registrar relaciones: M29/M31 (reloj), M71 (logros), M39 (infraestructura), M69 (fast travel) [S]
- [ ] RF1: edificio de museo visitable en Aurora [S]
- [ ] RF2: donacion de fauna avistada desde M36 [S]
- [ ] RF3: donacion de peces capturados desde M34 [S]
- [ ] RF4: donacion de fosiles y piezas de ruinas desde M25 [S]
- [ ] RF5: donacion de obras de arte ancestral [S]
- [ ] RF6: exposiciones completables con recompensa por coleccion completa [S]
- [ ] RF7+RF8: registro de donaciones, colecciones y recompensas en M55 Diario [S]

## B. Analisis y decisiones (8)

- [ ] Analizar alternativa A: colecciones solo con logros y menu, sin edificio [S]
- [ ] Analizar alternativa B: museo fisico visitable con vitrinas instanciadas [S]
- [ ] Analizar alternativa C: tour guiado con camara fija y galeria cinematica [S]
- [ ] Analizar alternativa D: catalogo integrado unicamente en M55 Diario [S]
- [ ] Decidir: edificio visitable con vitrinas instanciadas (alternativa B) [S]
- [ ] Decidir: CollectionRegistry como autoridad unica de progreso [S]
- [ ] Decidir: DonationService separado para validacion y consumo [S]
- [ ] Documentar alternativas descartadas con justificacion tecnica [S]

## C. Arquitectura y datos (12)

- [ ] Clase Museum como nodo raiz de la escena del edificio [S]
- [ ] Clase CollectionRegistry como autoload de registro y persistencia [M]
- [ ] Clase ExhibitSlot para vitrinas instanciables por pieza [S]
- [ ] Clase DonationService como autoload orquestador de donaciones [M]
- [ ] Clase ExhibitionData (Resource) con lista de piezas y recompensa [S]
- [ ] Clase ExhibitData (Resource) con metadatos de la pieza [S]
- [ ] Clase DonationResult con estado aceptado y motivo de rechazo [S]
- [ ] IDs unicos por pieza (exposicion_id + item_id) como clave de registro [S]
- [ ] Esquema de carpetas res:// definido para scripts, escenas y datos [S]
- [ ] Desacople total UI vs sistema de coleccion mediante senales [M]
- [ ] Compatibilidad de extension: nuevas exposiciones sin cambios estructurales [S]
- [ ] Versionado del bloque de guardado para migraciones futuras [M]

## D. Museum: edificio y salas (12)

- [ ] Escena museum.tscn creada con entrada, mostrador y cartel de progreso [M]
- [ ] Cuatro salas iniciales: fauna, peces, fosiles y arte [M]
- [ ] Puertas de salas funcionales con transicion interior suave [M]
- [ ] Sala de fauna con dioramas para avistamientos de M36 [M]
- [ ] Sala de peces con acuarios para capturas de M34 [M]
- [ ] Sala de fosiles con pedestales y montajes de M25 [M]
- [ ] Sala de arte con marcos y paredes de exhibicion [M]
- [ ] Curador NPC con dialogo de recepcion y agradecimientos cozy [M]
- [ ] Iluminacion interior calida y estatica (horneada) [S]
- [ ] Construccion voxel de vitrinas coherente con el estilo del mundo [C]
- [ ] Navegabilidad completa de salas sin colisiones molestas [S]
- [ ] El museo es accesible desde el inicio de la partida (sin bloqueos) [S]

## E. ExhibitSlot: vitrinas instanciadas (12)

- [ ] Escena exhibit_slot.tscn generica y reutilizable [S]
- [ ] Instanciado de vitrinas en runtime segun ExhibitionData [M]
- [ ] place_item valida vitrina libre y tipo de pieza correcto [S]
- [ ] Vitrina ocupada muestra el modelo/iscon de la pieza registrada [M]
- [ ] Vitrina libre muestra silueta y etiqueta "Por donar" [S]
- [ ] Inspeccion de pieza abre panel con nombre, procedencia y curiosidad [S]
- [ ] Variante para peces: acuario con nado animado por spline [C]
- [ ] Variante para fosiles: montaje en pedestal con iluminacion suave [S]
- [ ] Variante para fauna: diorama estatico con el modelo avistado [M]
- [ ] Variante para arte: cuadro en marco sobre pared [S]
- [ ] clear() devuelve el slot al estado libre sin perder configuracion [S]
- [ ] Pool de slots libres con prefab ligero (sin modelos pesados) [C]

## F. DonationService: donaciones (14)

- [ ] Donacion desde el inventario del jugador con seleccion en UI [M]
- [ ] Validacion de propiedad del item antes de donar [S]
- [ ] Validacion de item existente en el catalogo de la exposicion [S]
- [ ] Donacion duplicada rechazada con motivo "duplicate" [S]
- [ ] Donacion de item de otra exposicion rechazada con motivo "wrong_exhibition" [S]
- [ ] Donacion de item inexistente rechazada con motivo "invalid_item" [S]
- [ ] Donacion de item no poseido rechazada con motivo "not_owned" [S]
- [ ] Confirmacion del jugador antes de consumir el item [S]
- [ ] Consumo del inventario ocurre solo tras validacion exitosa [S]
- [ ] Rollback del registro si falla la escritura posterior al consumo [M]
- [ ] DonationResult estructurado con motivo y datos de contexto [S]
- [ ] Senal donation_accepted para UI, audio y diario [S]
- [ ] Senal donation_rejected con motivo visible en pantalla [S]
- [ ] Mensajes cozy del curador al aceptar cada pieza [S]

## G. CollectionRegistry: registro y progreso (12)

- [ ] Registro persistente de piezas por exposicion [M]
- [ ] Conteo de piezas registradas por exposicion [S]
- [ ] Porcentaje de completado por exposicion [S]
- [ ] Porcentaje global del museo [S]
- [ ] Deteccion de exposicion completa al registrar la ultima pieza [S]
- [ ] Emision de exhibition_completed exactamente una vez [S]
- [ ] Consulta is_registered por Dictionary en O(1) [S]
- [ ] Iteracion ordenada de piezas para la UI [S]
- [ ] Serializacion to_save_data compatible con el guardado del juego [M]
- [ ] restore_from_save reconstruye registro y recompensas otorgadas [M]
- [ ] Reconstruccion de vitrinas visibles al cargar partida [M]
- [ ] Garantia de cero duplicados por clave unica (exposicion, item) [S]

## H. Exposiciones, recompensas y logros (10)

- [ ] Exposicion "Fauna Avistada" definida con piezas de M36 [M]
- [ ] Exposicion "Peces del Archipielago" definida con piezas de M34 [M]
- [ ] Exposicion "Fosiles y Ruinas" definida con piezas de M25 [M]
- [ ] Exposicion "Arte de Aurora" definida con obras de M37 [M]
- [ ] Recompensa unica por exposicion completada (item exclusivo) [S]
- [ ] Trofeo final por museo 100% completado [S]
- [ ] Entrega de recompensa idempotente (nunca duplicada tras guardados) [S]
- [ ] Notificacion especial visual y de audio al completar exposicion [S]
- [ ] Compatibilidad con el sistema de logros (M71) [S]
- [ ] Pieza secreta opcional desbloqueable por descubrimiento (plan futuro) [S]

## I. M55 Diario (8)

- [ ] Registro de cada donacion aceptada en el diario [S]
- [ ] Registro de cada exposicion completada en el diario [S]
- [ ] Registro de cada recompensa recibida en el diario [S]
- [ ] Entradas fechadas con el reloj M29/M31 [S]
- [ ] Vinculo bidireccional: consultar piezas del museo desde el diario [M]
- [ ] Emision de senales tipadas sin acoplarse a la UI del diario [S]
- [ ] El diario no interrumpe el flujo de donacion (receptor async) [S]
- [ ] Historial ordenado cronologicamente sin entradas duplicadas [S]

## J. Edge cases y manejo de errores (12)

- [ ] Donacion duplicada rechazada sin consumir inventario [S]
- [ ] Vitrina ocupada nunca sobrescrita con otra pieza [S]
- [ ] Items donables registrados antes de restaurar el museo (cola pendiente) [M]
- [ ] Inventario vacio al abrir el panel de donacion (UI vacia elegante) [S]
- [ ] Fallo de senal de modulo origen (M36/M34/M25) sin crasheo [M]
- [ ] Carga de partida con vitrinas parcialmente pobladas [M]
- [ ] Cierre del juego entre consumo y escritura de guardado (rollback) [M]
- [ ] Doble interaccion simultanea sobre la misma vitrina [M]
- [ ] Museo visitado durante fast travel sin corrupcion de estado (M69) [S]
- [ ] Falta de resource .tres de exposicion con fallback y log ERROR [S]
- [ ] Recompensa otorgada con inventario lleno (cola o correo de items) [M]
- [ ] Logs de error con contexto [M37] y datos de la operacion [S]

## K. Persistencia y guardado (8)

- [ ] Estado del registro guardado con la partida [M]
- [ ] Estado de recompensas otorgadas guardado [S]
- [ ] Escritura atomica del bloque de museo [M]
- [ ] Reconstruccion posicional de objetos en vitrinas al cargar [M]
- [ ] Migracion de guardados viejos a nuevas exposiciones [C]
- [ ] Compatibilidad con el autosave general del juego [S]
- [ ] Restauracion de curaduria (nombres y descripciones) al cargar [S]
- [ ] Test de carga/descarga con museo al 50% y al 100% [M]

## L. UI y feedback (10)

- [ ] Panel de donacion con lista filtrada de items donables [M]
- [ ] Barra de progreso por exposicion con contador de piezas [S]
- [ ] Tooltip de vitrina al pasar el cursor (nombre y estado) [S]
- [ ] Feedback visual al donar (particulas y brillo en la vitrina) [S]
- [ ] Feedback de rechazo con motivo visible [S]
- [ ] Cartel de recompensa al completar exposicion [S]
- [ ] Contador global del museo en el cartel de entrada [S]
- [ ] Navegacion completa por mando y teclado en la UI [M]
- [ ] Mensajes de estado durante la carga del edificio [S]
- [ ] Botones deshabilitados durante animaciones para evitar clicks rapidos [S]

## M. Optimizacion y rendimiento (8)

- [ ] Vitrinas instanciadas solo para piezas registradas [C]
- [ ] Culling de salas distantes desde el jugador [M]
- [ ] Consultas is_registered sin allocs en hot path [S]
- [ ] Modelos de piezas con LOD o mesh simplificado [C]
- [ ] Iluminacion estatica horneada en interiores [C]
- [ ] Acuarios con simulacion de nado ligera sin fisicas por pez [M]
- [ ] Carga de sala bajo 250 ms medido con Profiler [M]
- [ ] Inspeccion y UI sin micro-stutter en el frame budget [M]

## N. QA, testings y polish (12)

- [ ] Test: donacion feliz completa una exposicion entera [M]
- [ ] Test: donacion duplicada rechazada con motivo correcto [M]
- [ ] Test: vitrina ocupada nunca sobrescrita [M]
- [ ] Test: recompensa otorgada una sola vez en multiples cargas [M]
- [ ] Test: museo 100% desbloquea el trofeo final [M]
- [ ] Test: guardar y cargar conserva piezas y vitrinas [M]
- [ ] Test: integracion de senales con M36/M34/M25/M55 [C]
- [ ] Test: edge cases (inventario vacio, sala incorrecta, item inexistente) [M]
- [ ] Recorrido manual: visitar el museo completo tres veces seguidas [C]
- [ ] Polish: animacion de colocacion de la pieza en la vitrina [S]
- [ ] Polish: sonido ambiente del museo (reverb suave, musica tenue) [S]
- [ ] Documentacion plan-actual alineada con el codigo real implementado [S]