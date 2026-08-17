**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 28: Viajes

## A. Requisitos del módulo (10)

- [x] Definir el problema: desplazamiento cozy entre islas con el Gran Vapor [M]
- [x] Registrar dependencias: M22, M27; relaciones M32, M63, M69, M29, M38, M50, M51, M57, M58, M73 [S]
- [x] Catalogar los 25 puntos de la sección 27 del plan maestro [S]
- [x] RF1: boleto y reserva con capacidad del vapor [M]
- [x] RF2: embarque con animación guiada desde el muelle [M]
- [x] RF3: travesía visible entre 20 y 60 segundos [M]
- [x] RF4: llegada con atraque automático y desembarque suave [M]
- [x] RF5: viaje rápido costoso vía M69 [S]
- [x] RF6: clima M32 que retrasa pero nunca bloquea [S]
- [x] NFR: cozy, sin soft-locks, accesibilidad, guardado M58 [M]

## B. Resolución de los 25 puntos del plan maestro (25)

- [x] P1: diseño del puerto — Harbor con docks, muelle y zona de embarque [C]
- [x] P2: diseño del barco — Gran Vapor con cubierta navegable y chimenea [C]
- [x] P3: diseño del dirigible — vehículo opcional de contenido tardío, no bloqueante [M]
- [x] P4: diseño del submarino — vehículo opcional de expediciones, no bloqueante [M]
- [x] P5: diseño del boleto — objeto comprado en M38, consumible por viaje [M]
- [x] P6: diseño de requisitos — desbloqueos por M22 y M70 para rutas y expediciones [M]
- [x] P7: diseño del sistema de reservas — plaza reservada sobre capacidad del vapor [C]
- [x] P8: diseño de la animación de embarque — cámara cinematográfica, caminata guiada [C]
- [x] P9: diseño de la pantalla de viaje — TravelUI con destino, coste y horario [M]
- [x] P10: diseño de la transición — fade de 0.5 s al desembarcar y al viaje rápido [S]
- [x] P11: diseño de la llegada — atraque, pasarela y aparición en el muelle [M]
- [x] P12: diseño de efectos de clima — olas, balanceo, lluvia y niebla en travesía [M]
- [x] P13: diseño del calendario — ventanas de salida del vapor según M29 [M]
- [x] P14: diseño de viajes especiales — líneas nocturna y estacional reutilizando TravelService [M]
- [x] P15: diseño de expediciones secretas — rutas con required_quest y bandera is_secret [M]
- [x] P16: diseño de viajes nocturnos — ambientación con faroles y cielo estrellado [M]
- [x] P17: diseño de viajes estacionales — decorados y música por estación [M]
- [x] P18: diseño de eventos en el trayecto — umbrales de progreso con NPC y diálogos [M]
- [x] P19: diseño de objetos coleccionables del viaje — ítems visibles junto a la ruta [M]
- [x] P20: diseño de NPC viajeros — pasajeros con rutinas breves a cubierta [M]
- [x] P21: diseño de transporte de recursos — almacén del vapor con capacidad limitada [M]
- [x] P22: diseño de almacenamiento — inventario del barco separado del jugador [M]
- [x] P23: definición de restricciones — un viaje activo, destinos desbloqueados, horarios [M]
- [x] P24: definición de costes — boleto, viaje rápido y devoluciones en M38 [M]
- [x] P25: definición de desbloqueos — rutas progresivas ligadas a M22 y M70 [M]

## C. Gran Vapor (Boat) (8)

- [x] Clase Boat (Node3D) con estados DOCKED, BOARDING, SAILING, ARRIVING [M]
- [x] Avance del barco por la curva de BoatRoute en _physics_process [C]
- [x] Balanceo y cabeceo suaves según weather_factor [M]
- [x] Cubierta caminable (BoatDeck) con colisiones del jugador [M]
- [x] Estela de partículas (WakeFX) activa solo en SAILING [M]
- [x] Humo de chimenea con puffs periódicos (M51) [S]
- [x] Silbato del vapor al zarpar y al atracar (M42) [S]
- [x] Teleport a punto de curva para restaurar guardado (M58) [M]

## D. Ruta (BoatRoute) (7)

- [x] Resource BoatRoute con route_id, origen y destino por island_id [S]
- [x] Curva Curve3D baked para trayectoria estable por el mar [M]
- [x] sample_position(t) con interpolación sobre longitud baked [M]
- [x] compute_duration_with_weather con tope máximo de 90 segundos [M]
- [x] Coste en monedas y campo required_quest para desbloqueos [S]
- [x] Bandera is_secret y is_night_line para líneas especiales [S]
- [x] Resources .tres versionables en res://_Project/data/routes/ [S]

## E. Puerto (Harbor) (8)

- [x] Clase Harbor (Node3D) instanciada por isla de M27 [M]
- [x] Lista de docks con HarborDock (Marker3D) y detección de ocupación [M]
- [x] find_free_dock con retorno de muelle libre o nulo [M]
- [x] lock() y release() de docks con referencia al barco atracado [M]
- [x] EmbarkTrigger (Area3D) con prompt "Hablar con el conserje" [S]
- [x] Reserva temprana del dock de destino al zarpar [M]
- [x] Muelle secundario como respaldo ante ocupación prolongada [M]
- [x] Posición de aparición del jugador tras desembarcar [S]

## F. Servicio de Viajes (TravelService) (10)

- [x] Autoload TravelService registrado en project.godot [S]
- [x] Catálogo de BoatRoute cargado al inicio con validación de extremos [M]
- [x] request_travel(destination) con diccionario de resultado ok/razón [M]
- [x] Exclusividad: un solo viaje activo, request_travel falla si viajando [M]
- [x] Validación de boleto, coste, horario y desbloqueo antes de zarpar [M]
- [x] apply_weather_delay con retraso de 5 a 15 segundos, jamás cancelación [M]
- [x] cancel_travel con devolución del 100 % o 50 % según momento [M]
- [x] Emisión de señales travel_started, travel_progress, travel_arrived [S]
- [x] serialize() y restore() del estado completo de travesía [M]
- [x] Fallback de restore: ruta desconocida devuelve al muelle de origen [M]

## G. Interfaz de Viaje (TravelUI) (8)

- [x] Pantalla de reserva con lista de destinos, coste y horario [M]
- [x] Botón de abordar deshabilitado hasta completar validaciones [S]
- [x] Botón de cancelar visible hasta zarpar [S]
- [x] Barra de progreso "Llegando a [isla]..." durante SAILING [M]
- [x] Aviso amistoso de retraso por clima con diálogo del capitán [S]
- [x] Confirmación explícita del coste del viaje rápido (M69) [S]
- [x] Notificación de devolución tras cancelar [S]
- [x] set_interactive(false) durante transiciones (sección 8 AGENTS.md) [S]

## H. Flujos del viaje (10)

- [x] Flujo completo: embarque, travesía y llegada de punta a punta [C]
- [x] Flujo de llegada con muelle libre y atraque directo [M]
- [x] Flujo de llegada con muelle ocupado: espera animada de hasta 10 s [C]
- [x] Flujo de cancelación antes del embarque con devolución del 100 % [M]
- [x] Flujo de cancelación en cubierta con devolución del 50 % [M]
- [x] Flujo de clima adverso: retraso visible, zarpe garantizado [M]
- [x] Flujo de viaje rápido con requisitos y fade directo [M]
- [x] Flujo de destino bloqueado por requisitos con mensaje claro [S]
- [x] Flujo nocturno con ambientación y faroles activos [M]
- [x] Flujo de expedición secreta con ruta is_secret [M]

## I. Integración con otros módulos (10)

- [x] M27: Harbors vinculados por island_id a las islas del mundo [M]
- [x] M32: consulta del estado del clima para calcular retraso sin bloqueo [M]
- [x] M69: viaje rápido con puntos desbloqueados, coste alto y visita previa [M]
- [x] M63: precarga de la isla destino al confirmar el boleto [C]
- [x] M63: liberación de la isla origen al zarpar [M]
- [x] M29: ventanas de salida y líneas nocturnas según el reloj [M]
- [x] M38: pago de boleto, viaje rápido y devoluciones [M]
- [x] M58: guardado y restauración a mitad de travesía [M]
- [x] M50: estela y boyantez sobre agua decorativa sin colisiones [M]
- [x] M73: viajes estacionales y de festival reutilizando TravelService [M]

## J. Edge cases y manejo de errores (10)

- [x] Llegada con muelle ocupado: espera visible, nunca soft-lock [C]
- [x] Cancelación con boleto consumido: devolución calculada correcta [M]
- [x] Clima extremo: retraso máximo aplicado y zarpe garantizado [M]
- [x] Doble pulsación de abordar: exclusividad de estado lo descarta [S]
- [x] Reserva duplicada del mismo destino: segundo intento rechazado [S]
- [x] Destino aún no desbloqueado: mensaje de requisito pendiente [S]
- [x] Insuficiencia de monedas: aviso sin cobro parcial [S]
- [x] Fallo de streaming del destino (M63): espera en cubierta con mensaje [C]
- [x] Guardado durante SAILING: restaura en el punto medio de la curva [M]
- [x] Jugador fuera del barco al zarpar: reubicación automática a cubierta [M]

## K. Optimización y rendimiento (8)

- [x] Precarga de la escena destino durante la travesía (M63) [C]
- [x] Travesía con tope de 90 s para limitar tiempo de streaming [S]
- [x] Pool de partículas de estela y humo sin instancias dinámicas [M]
- [x] Culling de la isla origen al alejarse de su puerto [M]
- [x] Cache de nodos en _ready, sin get_node en bucles [S]
- [x] Budget de frame menor o igual a 16 ms durante la travesía [C]
- [x] Sin alocaciones en el bucle de progreso de la ruta [M]
- [x] Opción de accesibilidad: travesía acelerada a la mitad del tiempo [S]

## L. Audio, VFX y polish (8)

- [x] Sonido de olas según weather_factor (M41) [M]
- [x] Silbato del vapor al zarpar y atracar (M42) [S]
- [x] Gaviotas y ambiente de puerto en el muelle [S]
- [x] Música de travesía tranquila (M40) con crossfade [M]
- [x] Lluvia y nieve en cubierta con partículas (M51) [M]
- [x] Faroles y luces cálidas en línea nocturna [M]
- [x] Confirmación visual de llegada con banner del nombre de la isla [S]
- [x] Diálogo amable del capitán al retrasar por clima [S]

## M. Documentación y testings (8)

- [x] 01-Requerimientos.md creado y firmado [S]
- [x] 02-Analisis.md con alternativas y decisiones justificadas [S]
- [x] 03-Diseno.md con arquitectura, flujos y contratos API [S]
- [x] 04-Codigo.md con rutas, firmas clave y logs [S]
- [x] Este 05-Checklist.md con todos los ítems del módulo [S]
- [x] Copia idéntica completada en plan-actual/ [S]
- [x] Casos de prueba de puerto ocupado, clima y cancelación cubiertos en diseño [M]
- [x] Verificación de que el diseño cumple la Definición de Completado (sección 21.6 AGENTS.md) [M]