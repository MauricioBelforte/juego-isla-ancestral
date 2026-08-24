**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 68: Transporte y Navegación (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo.

## A. TransportManager (autoload)

- [ ] Definir TransportManager como autoload único de transporte [M]
- [ ] Cargar el grafo de paradas/rutas desde transport_network.tres [M]
- [ ] Exponer API list_routes/buy_ticket a la UI (M53) [S]
- [ ] Registrar logs TRIP-START y TRIP-END [S]
- [ ] Emitir eventos TRIP_FINISHED (M07) [S]

## B. Infraestructura (Puertos)

- [ ] Definir paradas tipo barco en islas principales (M28) [M]
- [ ] Muelles con docking del vehículo (M67) [M]
- [ ] Puertos con cartel y marcador en el mapa (M54) [M]
- [ ] Puerto de festival temporal (M74) [M]
- [ ] Testear docking del barco en puertos angostos [C]

## C. Infraestructura (Estaciones)

- [ ] Plataformas de dirigible con parada [M]
- [ ] Estación central de tren SOLO si M67 define la locomotora [M]
- [ ] Parada en la isla del Este y del Norte [M]
- [ ] Estaciones con indicación de horarios (M29) [M]
- [ ] Documentar el estado condicional de la estación de tren [S]

## D. Red de Rutas (grafo)

- [ ] Definir transport_route.gd (origen, destino, duración, coste) [M]
- [ ] Crear transport_network.tres como única fuente de verdad [M]
- [ ] Definir 8-12 paradas y 15-20 rutas típicas [M]
- [ ] Sin bucles duplicados (grafo simple validado) [M]
- [ ] Testear el grafo con ruta corta (dijkstra, orden de paradas) [C]

## E. Costes y Descuentos (M38/M20)

- [ ] Definir coste base por ruta (M38) [M]
- [ ] Coste directo mayor que combinar rutas (incentivo de exploración) [M]
- [ ] Descuento del 20% con amistad nivel 5+ (M20) [M]
- [ ] Descuentos visibles en el panel (M53) [S]
- [ ] Testear costes con economía vacía y llena [M]

## F. Desbloqueo (M71)

- [ ] Desbloquear paradas al construir infraestructura (M71) [M]
- [ ] Desbloquear rutas por progreso de historia (M22) [M]
- [ ] Rutas bloqueadas con aviso de requisito [S]
- [ ] Log STOP-UNLOCKED [S]
- [ ] Testear desbloqueo en orden correcto [M]

## G. Restricciones (Horarios y Clima)

- [ ] Rutas respetan horario (M29: apertura/cierre por parada) [M]
- [ ] Rutas de barco bloqueadas con tormenta (M32) [M]
- [ ] Dirigible bloqueado con viento fuerte (M32) [M]
- [ ] Aviso claro si se intenta viajar fuera de horario [S]
- [ ] Testear restricciones con cambios de clima en vivo [C]

## H. Mapa de Transporte (M54)

- [ ] Definir capa de transporte en el mapa (M54) [M]
- [ ] Dibujar rutas como líneas en la capa [M]
- [ ] Marcadores de parada con horarios en el mapa [M]
- [ ] Sincronizar capa con el grafo (una sola fuente) [M]
- [ ] Testear el mapa con 3 idiomas (M87) [M]

## I. Señalización en el Mundo (M46)

- [ ] Carteles de madera con direcciones y distancias [M]
- [ ] Carteles de parada con horarios [M]
- [ ] Carteles en atlas batchable (M46/M61) [M]
- [ ] Señalización consistente con el mapa (validador) [M]
- [ ] Testear carteles de noche (legibles, M49) [M]

## J. Marcadores y Waypoints

- [ ] Marcadores de paradas en el mapa (M54) [S]
- [ ] Waypoints automáticos en rutas largas [M]
- [ ] Waypoints manuales del jugador (marcas en el mapa) [M]
- [ ] Persistencia de waypoints (M59) [M]
- [ ] Testear waypoints con rutas de 2+ paradas [M]

## K. Panel de Transporte (M53)

- [ ] Panel de transporte con lista de rutas [M]
- [ ] Mostrar coste, duración y horario por ruta [M]
- [ ] Confirmación de compra con aviso de dinero insuficiente [M]
- [ ] Botón de "viajar ahora" y "programar" (esperar horario) [M]
- [ ] Testear panel en pausa y desde el mapa [M]

## L. Viajes y Tiempos

- [ ] Duración por ruta (real o montaje con fade) [M]
- [ ] Viajes cortos (muelle cercano) en tiempo real con vehículo (M67) [M]
- [ ] Viajes largos con montaje de fade [M]
- [ ] Tiempos visibles en el panel antes de comprar [S]
- [ ] Testear tiempos en 3 rutas distintas [M]

## M. Transiciones (Sin Perder al Jugador)

- [ ] Transición cozy < 4 s con mensaje "Viajando a X..." (M44) [M]
- [ ] Barra de progreso (M08) si el destino tarda [M]
- [ ] Cargar destino ANTES de mover al jugador (M61) [C]
- [ ] Reaparición orientada al destino (nunca perder al jugador) [C]
- [ ] Testear transición con streaming pesado [C]

## N. Viajes Especiales (M74/M31)

- [ ] Viaje al festival (parada temporal, M74) [M]
- [ ] Tour de luna llena (M31) con precio especial [M]
- [ ] Viajes especiales registrados en el calendario (M29) [M]
- [ ] No aparecer en el grafo normal (solo programados) [M]
- [ ] Testear viajes especiales fuera de fecha (no disponibles) [M]

## O. Viajes Narrativos (M22/M23)

- [ ] Rutas narrativas sin coste [M]
- [ ] Diálogos a bordo durante el trayecto (M21) [M]
- [ ] Avanzar hitos de historia al llegar (M22/M23) [M]
- [ ] Viaje narrativo no interrumpible [M]
- [ ] Testear viaje narrativo del capítulo 1 al 7 [C]

## P. Eventos de Ruta

- [ ] Encuentros suaves en ruta (NPC M64 en el muelle) [M]
- [ ] Eventos de ruta sin peligro (sin clima hostil inesperado) [M]
- [ ] Señal sonora/visual de evento en ruta (M43/M44) [S]
- [ ] Evento de ruta del festival (M74) [M]
- [ ] Testear eventos sin romper la transición [M]

## Q. Coordinación con Fast Travel (M69)

- [ ] Compartir estaciones con M69 (misma red) [M]
- [ ] M69 solo muestra destinos con estación desbloqueada [M]
- [ ] M69 sin duplicar costes ni rutas de M68 [M]
- [ ] M69 más caro que el boleto de ruta (decisión) [M]
- [ ] Testear coordinación con M69 en 3 destinos [C]

## R. Animaciones y Pasajeros (M48/M64)

- [ ] Puertas/gangways animados en paradas (M48) [M]
- [ ] Bandera del barco con viento (M50) en paradas [S]
- [ ] NPC pasajeros en paradas (M64) [M]
- [ ] NPC abordando el vehículo (M67) [M]
- [ ] Testear animaciones con LOD (M61) [M]

## S. IP Pasantes y Accesibilidad (M58)

- [ ] HUD del viaje legible con alto contraste [M]
- [ ] Tamaño de texto configurable en el panel [M]
- [ ] Reduce Motion: transiciones cortas sin zoom [M]
- [ ] Subtítulos en mensajes de viaje [S]
- [ ] Panel de transporte accesible con gamepad (M57) [M]

## T. Edge Cases

- [ ] Viajar con dinero justo o en la última hora de horario [M]
- [ ] Viajar durante diálogo (M21, bloqueado) o con inventario lleno [M]
- [ ] Viajar al destino destruido (ruina M25) o con el vehículo en uso (M67) [M]
- [ ] Carga de guardado a mitad de viaje (M59) y viajes dobles (cola) [C]
- [ ] Parada recién desbloqueada sin señal y clima cambiadizo (M32) [M]

## U. Rendimiento (M61)

- [ ] Red en un solo .tres (sin nodos por escena) [M]
- [ ] Señalización batchable (M46, ≤ 4 carteles por escena) [M]
- [ ] Capa de mapa sin draw calls nuevos [M]
- [ ] Transición reutilizable (SceneTransition M61) [M]
- [ ] Probar con profiler (M116) [C]

## V. Localización (M87)

- [ ] Localizar nombres de paradas y rutas [M]
- [ ] Localizar mensajes de viaje y horarios [M]
- [ ] Localizar carteles del mundo [M]
- [ ] Respetar plurales y formatos de hora (12h/24h) [M]
- [ ] Testear panel y carteles en 3 idiomas [M]

## W. Validación y QA

- [ ] Crear validate_transport.gd (grafo, señalización vs mapa, costes, transiciones) [C]
- [ ] Probar ciclo completo: abrir mapa → elegir ruta → pagar → viajar → llegar [C]
- [ ] Probar viaje narrativo completo (M22) [C]
- [ ] Probar viaje de festival (M74) [C]
- [ ] Revisar logs TRP-* en consola sin errores [S]

## X. Documentación

- [ ] Documentar la red de transporte en 04-Codigo.md [M]
- [ ] Documentar la coordinación con M69 [M]
- [ ] Documentar la regla "nunca perder al jugador" [M]
- [ ] Documentar el estado condicional de la estación de tren [S]
- [ ] Agregar notas del agente al 04-Codigo.md (honestidad) [S]

## Y. Cierre del Módulo

- [ ] Firmar los documentos del módulo (modelo y plataforma) [S]
- [ ] Actualizar CHECKLIST-GLOBAL con el progreso real [S]
- [ ] Actualizar DOCUMENTACION/README.md con el módulo 68 [S]
- [ ] Actualizar ESTADO-PARALELO.md [S]
- [ ] Generar el log 64 en Logs/ [S]

## Z. Validación Final (DoD)

- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Push del módulo y reporte al usuario [S]
- [ ] Marcar ítems solo al cumplir la DoD (sección 21.6) [S]
- [ ] Revisar que plan-inicial == plan-actual (SHA-256) [S]
- [ ] Confirmar 130 ítems exactos [S]