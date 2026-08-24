**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 28: Viajes

## A. Requisitos del módulo (10)

- [ ] Definir el problema: desplazamiento cozy entre islas con el Gran Vapor [M]
- [ ] Registrar dependencias: M22, M27; relaciones M32, M63, M69, M29, M38, M50, M51, M57, M58, M73 [S]
- [ ] Catalogar los 25 puntos de la sección 27 del plan maestro [S]
- [ ] RF1: boleto y reserva con capacidad del vapor [M]
- [ ] RF2: embarque con animación guiada desde el muelle [M]
- [ ] RF3: travesía visible entre 20 y 60 segundos [M]
- [ ] RF4: llegada con atraque automático y desembarque suave [M]
- [ ] RF5: viaje rápido costoso vía M69 [S]
- [ ] RF6: clima M32 que retrasa pero nunca bloquea [S]
- [ ] NFR: cozy, sin soft-locks, accesibilidad, guardado M58 [M]

## B. Resolución de los 25 puntos del plan maestro (25)

- [ ] P1: diseño del puerto — Harbor con docks, muelle y zona de embarque [C]
- [ ] P2: diseño del barco — Gran Vapor con cubierta navegable y chimenea [C]
- [ ] P3: diseño del dirigible — vehículo opcional de contenido tardío, no bloqueante [M]
- [ ] P4: diseño del submarino — vehículo opcional de expediciones, no bloqueante [M]
- [ ] P5: diseño del boleto — objeto comprado en M38, consumible por viaje [M]
- [ ] P6: diseño de requisitos — desbloqueos por M22 y M70 para rutas y expediciones [M]
- [ ] P7: diseño del sistema de reservas — plaza reservada sobre capacidad del vapor [C]
- [ ] P8: diseño de la animación de embarque — cámara cinematográfica, caminata guiada [C]
- [ ] P9: diseño de la pantalla de viaje — TravelUI con destino, coste y horario [M]
- [ ] P10: diseño de la transición — fade de 0.5 s al desembarcar y al viaje rápido [S]
- [ ] P11: diseño de la llegada — atraque, pasarela y aparición en el muelle [M]
- [ ] P12: diseño de efectos de clima — olas, balanceo, lluvia y niebla en travesía [M]
- [ ] P13: diseño del calendario — ventanas de salida del vapor según M29 [M]
- [ ] P14: diseño de viajes especiales — líneas nocturna y estacional reutilizando TravelService [M]
- [ ] P15: diseño de expediciones secretas — rutas con required_quest y bandera is_secret [M]
- [ ] P16: diseño de viajes nocturnos — ambientación con faroles y cielo estrellado [M]
- [ ] P17: diseño de viajes estacionales — decorados y música por estación [M]
- [ ] P18: diseño de eventos en el trayecto — umbrales de progreso con NPC y diálogos [M]
- [ ] P19: diseño de objetos coleccionables del viaje — ítems visibles junto a la ruta [M]
- [ ] P20: diseño de NPC viajeros — pasajeros con rutinas breves a cubierta [M]
- [ ] P21: diseño de transporte de recursos — almacén del vapor con capacidad limitada [M]
- [ ] P22: diseño de almacenamiento — inventario del barco separado del jugador [M]
- [ ] P23: definición de restricciones — un viaje activo, destinos desbloqueados, horarios [M]
- [ ] P24: definición de costes — boleto, viaje rápido y devoluciones en M38 [M]
- [ ] P25: definición de desbloqueos — rutas progresivas ligadas a M22 y M70 [M]

## C. Gran Vapor (Boat) (8)

- [ ] Clase Boat (Node3D) con estados DOCKED, BOARDING, SAILING, ARRIVING [M]
- [ ] Avance del barco por la curva de BoatRoute en _physics_process [C]
- [ ] Balanceo y cabeceo suaves según weather_factor [M]
- [ ] Cubierta caminable (BoatDeck) con colisiones del jugador [M]
- [ ] Estela de partículas (WakeFX) activa solo en SAILING [M]
- [ ] Humo de chimenea con puffs periódicos (M51) [S]
- [ ] Silbato del vapor al zarpar y al atracar (M42) [S]
- [ ] Teleport a punto de curva para restaurar guardado (M58) [M]

## D. Ruta (BoatRoute) (7)

- [ ] Resource BoatRoute con route_id, origen y destino por island_id [S]
- [ ] Curva Curve3D baked para trayectoria estable por el mar [M]
- [ ] sample_position(t) con interpolación sobre longitud baked [M]
- [ ] compute_duration_with_weather con tope máximo de 90 segundos [M]
- [ ] Coste en monedas y campo required_quest para desbloqueos [S]
- [ ] Bandera is_secret y is_night_line para líneas especiales [S]
- [ ] Resources .tres versionables en res://_Project/data/routes/ [S]

## E. Puerto (Harbor) (8)

- [ ] Clase Harbor (Node3D) instanciada por isla de M27 [M]
- [ ] Lista de docks con HarborDock (Marker3D) y detección de ocupación [M]
- [ ] find_free_dock con retorno de muelle libre o nulo [M]
- [ ] lock() y release() de docks con referencia al barco atracado [M]
- [ ] EmbarkTrigger (Area3D) con prompt "Hablar con el conserje" [S]
- [ ] Reserva temprana del dock de destino al zarpar [M]
- [ ] Muelle secundario como respaldo ante ocupación prolongada [M]
- [ ] Posición de aparición del jugador tras desembarcar [S]

## F. Servicio de Viajes (TravelService) (10)

- [ ] Autoload TravelService registrado en project.godot [S]
- [ ] Catálogo de BoatRoute cargado al inicio con validación de extremos [M]
- [ ] request_travel(destination) con diccionario de resultado ok/razón [M]
- [ ] Exclusividad: un solo viaje activo, request_travel falla si viajando [M]
- [ ] Validación de boleto, coste, horario y desbloqueo antes de zarpar [M]
- [ ] apply_weather_delay con retraso de 5 a 15 segundos, jamás cancelación [M]
- [ ] cancel_travel con devolución del 100 % o 50 % según momento [M]
- [ ] Emisión de señales travel_started, travel_progress, travel_arrived [S]
- [ ] serialize() y restore() del estado completo de travesía [M]
- [ ] Fallback de restore: ruta desconocida devuelve al muelle de origen [M]

## G. Interfaz de Viaje (TravelUI) (8)

- [ ] Pantalla de reserva con lista de destinos, coste y horario [M]
- [ ] Botón de abordar deshabilitado hasta completar validaciones [S]
- [ ] Botón de cancelar visible hasta zarpar [S]
- [ ] Barra de progreso "Llegando a [isla]..." durante SAILING [M]
- [ ] Aviso amistoso de retraso por clima con diálogo del capitán [S]
- [ ] Confirmación explícita del coste del viaje rápido (M69) [S]
- [ ] Notificación de devolución tras cancelar [S]
- [ ] set_interactive(false) durante transiciones (sección 8 AGENTS.md) [S]

## H. Flujos del viaje (10)

- [ ] Flujo completo: embarque, travesía y llegada de punta a punta [C]
- [ ] Flujo de llegada con muelle libre y atraque directo [M]
- [ ] Flujo de llegada con muelle ocupado: espera animada de hasta 10 s [C]
- [ ] Flujo de cancelación antes del embarque con devolución del 100 % [M]
- [ ] Flujo de cancelación en cubierta con devolución del 50 % [M]
- [ ] Flujo de clima adverso: retraso visible, zarpe garantizado [M]
- [ ] Flujo de viaje rápido con requisitos y fade directo [M]
- [ ] Flujo de destino bloqueado por requisitos con mensaje claro [S]
- [ ] Flujo nocturno con ambientación y faroles activos [M]
- [ ] Flujo de expedición secreta con ruta is_secret [M]

## I. Integración con otros módulos (10)

- [ ] M27: Harbors vinculados por island_id a las islas del mundo [M]
- [ ] M32: consulta del estado del clima para calcular retraso sin bloqueo [M]
- [ ] M69: viaje rápido con puntos desbloqueados, coste alto y visita previa [M]
- [ ] M63: precarga de la isla destino al confirmar el boleto [C]
- [ ] M63: liberación de la isla origen al zarpar [M]
- [ ] M29: ventanas de salida y líneas nocturnas según el reloj [M]
- [ ] M38: pago de boleto, viaje rápido y devoluciones [M]
- [ ] M58: guardado y restauración a mitad de travesía [M]
- [ ] M50: estela y boyantez sobre agua decorativa sin colisiones [M]
- [ ] M73: viajes estacionales y de festival reutilizando TravelService [M]

## J. Edge cases y manejo de errores (10)

- [ ] Llegada con muelle ocupado: espera visible, nunca soft-lock [C]
- [ ] Cancelación con boleto consumido: devolución calculada correcta [M]
- [ ] Clima extremo: retraso máximo aplicado y zarpe garantizado [M]
- [ ] Doble pulsación de abordar: exclusividad de estado lo descarta [S]
- [ ] Reserva duplicada del mismo destino: segundo intento rechazado [S]
- [ ] Destino aún no desbloqueado: mensaje de requisito pendiente [S]
- [ ] Insuficiencia de monedas: aviso sin cobro parcial [S]
- [ ] Fallo de streaming del destino (M63): espera en cubierta con mensaje [C]
- [ ] Guardado durante SAILING: restaura en el punto medio de la curva [M]
- [ ] Jugador fuera del barco al zarpar: reubicación automática a cubierta [M]

## K. Optimización y rendimiento (8)

- [ ] Precarga de la escena destino durante la travesía (M63) [C]
- [ ] Travesía con tope de 90 s para limitar tiempo de streaming [S]
- [ ] Pool de partículas de estela y humo sin instancias dinámicas [M]
- [ ] Culling de la isla origen al alejarse de su puerto [M]
- [ ] Cache de nodos en _ready, sin get_node en bucles [S]
- [ ] Budget de frame menor o igual a 16 ms durante la travesía [C]
- [ ] Sin alocaciones en el bucle de progreso de la ruta [M]
- [ ] Opción de accesibilidad: travesía acelerada a la mitad del tiempo [S]

## L. Audio, VFX y polish (8)

- [ ] Sonido de olas según weather_factor (M41) [M]
- [ ] Silbato del vapor al zarpar y atracar (M42) [S]
- [ ] Gaviotas y ambiente de puerto en el muelle [S]
- [ ] Música de travesía tranquila (M40) con crossfade [M]
- [ ] Lluvia y nieve en cubierta con partículas (M51) [M]
- [ ] Faroles y luces cálidas en línea nocturna [M]
- [ ] Confirmación visual de llegada con banner del nombre de la isla [S]
- [ ] Diálogo amable del capitán al retrasar por clima [S]

## M. Documentación y testings (8)

- [ ] 01-Requerimientos.md creado y firmado [S]
- [ ] 02-Analisis.md con alternativas y decisiones justificadas [S]
- [ ] 03-Diseno.md con arquitectura, flujos y contratos API [S]
- [ ] 04-Codigo.md con rutas, firmas clave y logs [S]
- [ ] Este 05-Checklist.md con todos los ítems del módulo [S]
- [ ] Copia idéntica completada en plan-actual/ [S]
- [ ] Casos de prueba de puerto ocupado, clima y cancelación cubiertos en diseño [M]
- [ ] Verificación de que el diseño cumple la Definición de Completado (sección 21.6 AGENTS.md) [M]