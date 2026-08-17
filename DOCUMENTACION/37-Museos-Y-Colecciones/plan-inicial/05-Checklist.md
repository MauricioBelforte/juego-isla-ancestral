**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 37: Museos y Colecciones

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [x] cumplido · [ ] pendiente · [?] no resuelto.

## A. Alcance y requisitos (10)

- [x] Definir el problema: museo como sistema de coleccion visitable y gratificante [S]
- [x] Registrar dependencias: M36 (fauna), M34 (pesca), M25 (ruinas), M55 (diario) [S]
- [x] Registrar relaciones: M29/M31 (reloj), M71 (logros), M39 (infraestructura), M69 (fast travel) [S]
- [x] RF1: edificio de museo visitable en Aurora [S]
- [x] RF2: donacion de fauna avistada desde M36 [S]
- [x] RF3: donacion de peces capturados desde M34 [S]
- [x] RF4: donacion de fosiles y piezas de ruinas desde M25 [S]
- [x] RF5: donacion de obras de arte ancestral [S]
- [x] RF6: exposiciones completables con recompensa por coleccion completa [S]
- [x] RF7+RF8: registro de donaciones, colecciones y recompensas en M55 Diario [S]

## B. Analisis y decisiones (8)

- [x] Analizar alternativa A: colecciones solo con logros y menu, sin edificio [S]
- [x] Analizar alternativa B: museo fisico visitable con vitrinas instanciadas [S]
- [x] Analizar alternativa C: tour guiado con camara fija y galeria cinematica [S]
- [x] Analizar alternativa D: catalogo integrado unicamente en M55 Diario [S]
- [x] Decidir: edificio visitable con vitrinas instanciadas (alternativa B) [S]
- [x] Decidir: CollectionRegistry como autoridad unica de progreso [S]
- [x] Decidir: DonationService separado para validacion y consumo [S]
- [x] Documentar alternativas descartadas con justificacion tecnica [S]

## C. Arquitectura y datos (12)

- [x] Clase Museum como nodo raiz de la escena del edificio [S]
- [x] Clase CollectionRegistry como autoload de registro y persistencia [M]
- [x] Clase ExhibitSlot para vitrinas instanciables por pieza [S]
- [x] Clase DonationService como autoload orquestador de donaciones [M]
- [x] Clase ExhibitionData (Resource) con lista de piezas y recompensa [S]
- [x] Clase ExhibitData (Resource) con metadatos de la pieza [S]
- [x] Clase DonationResult con estado aceptado y motivo de rechazo [S]
- [x] IDs unicos por pieza (exposicion_id + item_id) como clave de registro [S]
- [x] Esquema de carpetas res:// definido para scripts, escenas y datos [S]
- [x] Desacople total UI vs sistema de coleccion mediante senales [M]
- [x] Compatibilidad de extension: nuevas exposiciones sin cambios estructurales [S]
- [x] Versionado del bloque de guardado para migraciones futuras [M]

## D. Museum: edificio y salas (12)

- [x] Escena museum.tscn creada con entrada, mostrador y cartel de progreso [M]
- [x] Cuatro salas iniciales: fauna, peces, fosiles y arte [M]
- [x] Puertas de salas funcionales con transicion interior suave [M]
- [x] Sala de fauna con dioramas para avistamientos de M36 [M]
- [x] Sala de peces con acuarios para capturas de M34 [M]
- [x] Sala de fosiles con pedestales y montajes de M25 [M]
- [x] Sala de arte con marcos y paredes de exhibicion [M]
- [x] Curador NPC con dialogo de recepcion y agradecimientos cozy [M]
- [x] Iluminacion interior calida y estatica (horneada) [S]
- [x] Construccion voxel de vitrinas coherente con el estilo del mundo [C]
- [x] Navegabilidad completa de salas sin colisiones molestas [S]
- [x] El museo es accesible desde el inicio de la partida (sin bloqueos) [S]

## E. ExhibitSlot: vitrinas instanciadas (12)

- [x] Escena exhibit_slot.tscn generica y reutilizable [S]
- [x] Instanciado de vitrinas en runtime segun ExhibitionData [M]
- [x] place_item valida vitrina libre y tipo de pieza correcto [S]
- [x] Vitrina ocupada muestra el modelo/iscon de la pieza registrada [M]
- [x] Vitrina libre muestra silueta y etiqueta "Por donar" [S]
- [x] Inspeccion de pieza abre panel con nombre, procedencia y curiosidad [S]
- [x] Variante para peces: acuario con nado animado por spline [C]
- [x] Variante para fosiles: montaje en pedestal con iluminacion suave [S]
- [x] Variante para fauna: diorama estatico con el modelo avistado [M]
- [x] Variante para arte: cuadro en marco sobre pared [S]
- [x] clear() devuelve el slot al estado libre sin perder configuracion [S]
- [x] Pool de slots libres con prefab ligero (sin modelos pesados) [C]

## F. DonationService: donaciones (14)

- [x] Donacion desde el inventario del jugador con seleccion en UI [M]
- [x] Validacion de propiedad del item antes de donar [S]
- [x] Validacion de item existente en el catalogo de la exposicion [S]
- [x] Donacion duplicada rechazada con motivo "duplicate" [S]
- [x] Donacion de item de otra exposicion rechazada con motivo "wrong_exhibition" [S]
- [x] Donacion de item inexistente rechazada con motivo "invalid_item" [S]
- [x] Donacion de item no poseido rechazada con motivo "not_owned" [S]
- [x] Confirmacion del jugador antes de consumir el item [S]
- [x] Consumo del inventario ocurre solo tras validacion exitosa [S]
- [x] Rollback del registro si falla la escritura posterior al consumo [M]
- [x] DonationResult estructurado con motivo y datos de contexto [S]
- [x] Senal donation_accepted para UI, audio y diario [S]
- [x] Senal donation_rejected con motivo visible en pantalla [S]
- [x] Mensajes cozy del curador al aceptar cada pieza [S]

## G. CollectionRegistry: registro y progreso (12)

- [x] Registro persistente de piezas por exposicion [M]
- [x] Conteo de piezas registradas por exposicion [S]
- [x] Porcentaje de completado por exposicion [S]
- [x] Porcentaje global del museo [S]
- [x] Deteccion de exposicion completa al registrar la ultima pieza [S]
- [x] Emision de exhibition_completed exactamente una vez [S]
- [x] Consulta is_registered por Dictionary en O(1) [S]
- [x] Iteracion ordenada de piezas para la UI [S]
- [x] Serializacion to_save_data compatible con el guardado del juego [M]
- [x] restore_from_save reconstruye registro y recompensas otorgadas [M]
- [x] Reconstruccion de vitrinas visibles al cargar partida [M]
- [x] Garantia de cero duplicados por clave unica (exposicion, item) [S]

## H. Exposiciones, recompensas y logros (10)

- [x] Exposicion "Fauna Avistada" definida con piezas de M36 [M]
- [x] Exposicion "Peces del Archipielago" definida con piezas de M34 [M]
- [x] Exposicion "Fosiles y Ruinas" definida con piezas de M25 [M]
- [x] Exposicion "Arte de Aurora" definida con obras de M37 [M]
- [x] Recompensa unica por exposicion completada (item exclusivo) [S]
- [x] Trofeo final por museo 100% completado [S]
- [x] Entrega de recompensa idempotente (nunca duplicada tras guardados) [S]
- [x] Notificacion especial visual y de audio al completar exposicion [S]
- [x] Compatibilidad con el sistema de logros (M71) [S]
- [x] Pieza secreta opcional desbloqueable por descubrimiento (plan futuro) [S]

## I. M55 Diario (8)

- [x] Registro de cada donacion aceptada en el diario [S]
- [x] Registro de cada exposicion completada en el diario [S]
- [x] Registro de cada recompensa recibida en el diario [S]
- [x] Entradas fechadas con el reloj M29/M31 [S]
- [x] Vinculo bidireccional: consultar piezas del museo desde el diario [M]
- [x] Emision de senales tipadas sin acoplarse a la UI del diario [S]
- [x] El diario no interrumpe el flujo de donacion (receptor async) [S]
- [x] Historial ordenado cronologicamente sin entradas duplicadas [S]

## J. Edge cases y manejo de errores (12)

- [x] Donacion duplicada rechazada sin consumir inventario [S]
- [x] Vitrina ocupada nunca sobrescrita con otra pieza [S]
- [x] Items donables registrados antes de restaurar el museo (cola pendiente) [M]
- [x] Inventario vacio al abrir el panel de donacion (UI vacia elegante) [S]
- [x] Fallo de senal de modulo origen (M36/M34/M25) sin crasheo [M]
- [x] Carga de partida con vitrinas parcialmente pobladas [M]
- [x] Cierre del juego entre consumo y escritura de guardado (rollback) [M]
- [x] Doble interaccion simultanea sobre la misma vitrina [M]
- [x] Museo visitado durante fast travel sin corrupcion de estado (M69) [S]
- [x] Falta de resource .tres de exposicion con fallback y log ERROR [S]
- [x] Recompensa otorgada con inventario lleno (cola o correo de items) [M]
- [x] Logs de error con contexto [M37] y datos de la operacion [S]

## K. Persistencia y guardado (8)

- [x] Estado del registro guardado con la partida [M]
- [x] Estado de recompensas otorgadas guardado [S]
- [x] Escritura atomica del bloque de museo [M]
- [x] Reconstruccion posicional de objetos en vitrinas al cargar [M]
- [x] Migracion de guardados viejos a nuevas exposiciones [C]
- [x] Compatibilidad con el autosave general del juego [S]
- [x] Restauracion de curaduria (nombres y descripciones) al cargar [S]
- [x] Test de carga/descarga con museo al 50% y al 100% [M]

## L. UI y feedback (10)

- [x] Panel de donacion con lista filtrada de items donables [M]
- [x] Barra de progreso por exposicion con contador de piezas [S]
- [x] Tooltip de vitrina al pasar el cursor (nombre y estado) [S]
- [x] Feedback visual al donar (particulas y brillo en la vitrina) [S]
- [x] Feedback de rechazo con motivo visible [S]
- [x] Cartel de recompensa al completar exposicion [S]
- [x] Contador global del museo en el cartel de entrada [S]
- [x] Navegacion completa por mando y teclado en la UI [M]
- [x] Mensajes de estado durante la carga del edificio [S]
- [x] Botones deshabilitados durante animaciones para evitar clicks rapidos [S]

## M. Optimizacion y rendimiento (8)

- [x] Vitrinas instanciadas solo para piezas registradas [C]
- [x] Culling de salas distantes desde el jugador [M]
- [x] Consultas is_registered sin allocs en hot path [S]
- [x] Modelos de piezas con LOD o mesh simplificado [C]
- [x] Iluminacion estatica horneada en interiores [C]
- [x] Acuarios con simulacion de nado ligera sin fisicas por pez [M]
- [x] Carga de sala bajo 250 ms medido con Profiler [M]
- [x] Inspeccion y UI sin micro-stutter en el frame budget [M]

## N. QA, testings y polish (12)

- [x] Test: donacion feliz completa una exposicion entera [M]
- [x] Test: donacion duplicada rechazada con motivo correcto [M]
- [x] Test: vitrina ocupada nunca sobrescrita [M]
- [x] Test: recompensa otorgada una sola vez en multiples cargas [M]
- [x] Test: museo 100% desbloquea el trofeo final [M]
- [x] Test: guardar y cargar conserva piezas y vitrinas [M]
- [x] Test: integracion de senales con M36/M34/M25/M55 [C]
- [x] Test: edge cases (inventario vacio, sala incorrecta, item inexistente) [M]
- [x] Recorrido manual: visitar el museo completo tres veces seguidas [C]
- [x] Polish: animacion de colocacion de la pieza en la vitrina [S]
- [x] Polish: sonido ambiente del museo (reverb suave, musica tenue) [S]
- [x] Documentacion plan-actual alineada con el codigo real implementado [S]