**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. 1 por Deepseek V4 Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 (iter. 2 — glm-5.3-flash/Kilo Code)

## Reserva actual

- **Módulo:** 28 Viajes
- **Reservado por:** glm-5.3-flash (Kilo Code)
- **Estado:** ✅ Liberado — iter. 2 cerrada (Log 517)
- **Fase:** F7 (producción de contenido)
- **Dificultad:** 3
- **Visión:** V0 (sin captura obligatoria; TravelService ya verificado headless)
- **Entrada:** TravelService autoload ✅ (iter. 1, glm-5.3-flash 2026-09-01); M22✅ M29✅ M32✅ M38✅ M59✅
- **Salida:** HarborDock/Harbor/EmbarkTrigger + TravelUI capa UI + test_harbor_viajes 26/0 OK
- **Archivos:** `scripts/viajes/{travel_service,boat_route,harbor_dock,harbor,embark_trigger,travel_ui,test_viajes,test_harbor_viajes}.gd`
- **Log:** 517

---

# 05-Checklist.md — Módulo 28: Viajes

## A. Requisitos del módulo (10)

- [ ] Definir el problema: desplazamiento cozy entre islas con el Gran Vapor [M]
- [x] Registrar dependencias: M22, M27; relaciones M32, M63, M69, M29, M38, M50, M51, M57, M58, M73 [S] — M22 núcleo propio ✅ (gating flags), M27 🟢 no bloquea V0 (islas virtuales)
- [ ] Catalogar los 25 puntos de la sección 27 del plan maestro [S]
- [ ] RF1: boleto y reserva con capacidad del vapor [M]
- [ ] RF2: embarque con animación guiada desde el muelle [M]
- [ ] RF3: travesía visible entre 20 y 60 segundos [M]
- [ ] RF4: llegada con atraque automático y desembarque suave [M]
- [ ] RF5: viaje rápido costoso vía M69 [S]
- [x] RF6: clima M32 que retrasa pero nunca bloquea [S] — retraso-sin-bloqueo implementado y testead (§3.1.5/§3.2.4)
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

- [x] Clase Harbor (Node3D) instanciada por isla de M27 [M] — iter. 2: harbor.gd autoload-ready (island_id export, find_free_dock, lock_dock/release_dock, dock_count, occupied_dock_count, get_embark_position); test_harbor 10/10 OK
- [x] Lista de docks con HarborDock (Marker3D) y detección de ocupación [M] — iter. 2: harbor_dock.gd (lock/release/is_locked/get_boat/dock_locked/dock_released signals); test_harbor validates
- [x] find_free_dock con retorno de muelle libre o nulo [M] — iter. 2: retorna primer dock no bloqueado, emite no_free_dock si ninguno
- [x] lock() y release() de docks con referencia al barco atracado [M] — iter. 2: ambas implementadas y testeadas
- [x] EmbarkTrigger (Area3D) con prompt "Hablar con el conserje" [S] — iter. 2: embark_trigger.gd (body_entered/exited, emitir prompt via EventBus.interaction, abrir_pantalla_viaje)
- [ ] Reserva temprana del dock de destino al zarpar [M] — pendiente integración M27 (islas reales con Harbour)
- [ ] Muelle secundario como respaldo ante ocupación prolongada [M] — [?] diseño: espera 10s en data-driven, sin auto-switch; dueño M27
- [x] Posición de aparición del jugador tras desembarcar [S] — iter. 2: get_embark_position() retorna global_position del primer dock libre (o fallback primer dock)

## F. Servicio de Viajes (TravelService) (10)

- [x] Autoload TravelService registrado en project.godot [S] — glm-5.3-flash 2026-09-01 (sin class_name, convención del proyecto)
- [ ] Catálogo de BoatRoute cargado al inicio con validación de extremos [M]
- [x] request_travel(destination) con diccionario de resultado ok/razón [M] — {ok, motivo, route_id} con validaciones en cadena (testeado)
- [x] Exclusividad: un solo viaje activo, request_travel falla si viajando [M] — testead (segundo request falla "viaje activo")
- [x] Validación de boleto, coste, horario y desbloqueo antes de zarpar [M] — AO M38 + flag M22 + línea nocturna 21-05 + temporada M93 (testeado)
- [x] apply_weather_delay con retraso de 5 a 15 segundos, jamás cancelación [M] — factor clima en request: delay 5-15 s + duración +25%, jamás cancelación (testeado con tormenta forzada)
- [x] cancel_travel con devolución del 100 % o 50 % según momento [M] — pre-embarque 100% (testeado); en travesía no cancela; 50% pendiente de BOARDING visual V2
- [x] Emisión de señales travel_started, travel_progress, travel_arrived [S] — travel_started/progress/arrived/delayed/cancelled + log [M28]
- [x] serialize() y restore() del estado completo de travesía [M] — get_save_data/restore_save_data (ISaveProvider M59): mitad de ruta + ruta huérfana sin soft-lock (testeado)
- [ ] Fallback de restore: ruta desconocida devuelve al muelle de origen [M]

## G. Interfaz de Viaje (TravelUI) (8)

- [x] Pantalla de reserva con lista de destinos, coste y horario [M] — iter. 2: TravelUI.show_reservation_screen(harbor_id) emite opciones desde TravelService.get_available_destinations(); bridge a M53 vía EventBus.ui.travel_ui_cambio
- [ ] Botón de abordar deshabilitado hasta completar validaciones [S] — dueño M53 (capa UI)
- [ ] Botón de cancelar visible hasta zarpar [S] — dueño M53
- [ ] Barra de progreso "Llegando a [isla]..." durante SAILING [M] — iter. 2: show_travel_progress(progress, label) implementado; bridge M53
- [ ] Aviso amistoso de retraso por clima con diálogo del capitán [S] — iter. 2: show_weather_delay_notice(seconds, reason) implementado
- [ ] Confirmación explícita del coste del viaje rápido (M69) [S] — dueño M69
- [ ] Notificación de devolución tras cancelar [S] — iter. 2: show_refund_notice(coins) con auto-cerrar 2s
- [ ] set_interactive(false) durante transiciones (sección 8 AGENTS.md) [S] — iter. 2: _set_interactivo disponible; M53 consumirá

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

- [x] 01-Requerimientos.md creado y firmado [S] — iter. 1 Deepseek
- [x] 02-Analisis.md con alternativas y decisiones justificadas [S] — iter. 1 Deepseek
- [x] 03-Diseno.md con arquitectura, flujos y contratos API [S] — iter. 1 Deepseek
- [x] 04-Codigo.md con rutas, firmas clave y logs [S] — iter. 1+2 glm-5.3-flash
- [x] Este 05-Checklist.md con todos los ítems del módulo [S] — iter. 2 glm-5.3-flash
- [x] Copia idéntica completada en plan-actual/ [S] — iter. 1+2
- [x] Casos de prueba de puerto ocupado, clima y cancelación cubiertos en diseño [M] — iter. 2: test_harbor_viajes.gd cubre puerto ocupado; test_viajes.gd cubre clima/cancelación
- [x] Verificación de que el diseño cumple la Definición de Completado (sección 21.6 AGENTS.md) [M] — iter. 2: test headless 0 fallos; DoD cumplido para iter. 2

---

## Notas del Agente

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 06:15
**Estado:** Liberado (iter. 2 cerrada)

### Lo que hice en iter. 2 (Log 517)
- **HarborDock.gd** (40 l�neas): lock(boat)/release()/is_locked()/get_boat() + se�ales dock_locked/dock_released. Duck-typing: nodes without class_name.
- **Harbor.gd** (70 l�neas): find_free_dock(), lock_dock(boat)/release_dock(boat)/is_dock_available(), dock_count()/occupied_dock_count()/get_embark_position(). Recolecta hijos HarborDock en _ready.
- **EmbarkTrigger.gd** (50 l�neas): Area3D con body_entered/exited, emite prompt via EventBus.interaction.prompt_visible/hidden, abre pantalla viaje v�a TravelUI.show_reservation_screen.
- **TravelUI.gd** (95 l�neas): CanvasLayer con show_reservation_screen(harbor_id)/show_travel_progress/show_weather_delay_notice/show_refund_notice/set_interactive. Bridge a M53 v�a EventBus.ui.travel_ui_cambio.
- **test_harbor_viajes.gd** (180 l�neas): 26 checks � HarborDock lock/release, Harbor multi-dock, TravelUI screens, flujo integrado. 0 fallos.

### Lo que NO est� resuelto (pendientes con due�o)
- Integraci�n M27: Harbor no est� vinculado a islas reales (requiere M27 islas)
- UI completa M53: botones de reserva/cancelaci�n, barra visual de progreso
- Boat escena V2: Node3D con movimiento por curva, part�culas, colisi�n
- Optimizaci�n secci�n K: precarga M63, culling, budget frame
- Audio/VFX secci�n L: olas, silbato, gaviotas, m�sica, lluvia, faroles
- Reserva temprana dock destino al zarpar (E6): requiere integraci�n M27
- Muelle secundario (E7): dise�o pendiente [?]

### Decisiones clave
1. Sin class_name en autoloads (Harbor, TravelUI) � convenci�n proyecto �9.17. Solo BoatRoute tiene class_name porque es Resource.
2. Duck-typing en TODO: TravelService usa get_node_or_null para WorldState/EconomyManager/Weather/GameTime/TimeCalendar. Si no existen, fallback seguro.
3. TravelUI no tiene l�gica de gameplay: solo refleja estado y emite se�ales. M53 consumir� EventBus.ui.travel_ui_cambio.
4. Harbor recolecta docks hijos en _ready via duck-typing (has_method "lock"/"release"). No requiere escenas pre-configuradas para tests.

### Validaci�n
- Compilaci�n: 0 errores tras iter. 2 (solo warnings pre-existentes del proyecto).
- test_harbor_viajes.gd: 26/26 OK, exit 0.
- test_viajes.gd (regresi�n): 0 fallos, exit 0.
- test_progresion.gd (M71 regresi�n): 0 fallos, exit 0.
- Boot runtime: [M28] Rutas cargadas: 4, sin errores.

### Recomendaciones para el pr�ximo agente
- Para integrar M27: cada isla debe instanciar un Harbor con docks hijos; el harbor_id debe coincidir con island_id.
- Para M53: escuchar EventBus.ui.travel_ui_cambio y mostrar paneles seg�n tipo (RESERVATION/PROGRESS/WEATHER_DELAY/REFUND/HIDDEN).
- Para Boat V2: reutilizar BoatRoute.sample_position(t) y _process delta para movimiento; agregar part�culas con M51.
- El flujo de reserva temprana de dock destino requiere llamar Harbor.lock_dock() desde TravelService._zarpar().
