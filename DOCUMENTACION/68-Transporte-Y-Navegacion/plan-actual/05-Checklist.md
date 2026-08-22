**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 68: Transporte y Navegación (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo.

## A. TransportManager (autoload)

- [x] Definir TransportManager como autoload único de transporte [M]
- [x] Cargar el grafo de paradas/rutas desde transport_network.tres [M]
- [x] Exponer API list_routes/buy_ticket a la UI (M53) [S]
- [x] Registrar logs TRIP-START y TRIP-END [S]
- [x] Emitir eventos TRIP_FINISHED (M07) [S]

## B. Infraestructura (Puertos)

- [x] Definir paradas tipo barco en islas principales (M28) [M]
- [x] Muelles con docking del vehículo (M67) [M]
- [x] Puertos con cartel y marcador en el mapa (M54) [M]
- [x] Puerto de festival temporal (M74) [M]
- [x] Testear docking del barco en puertos angostos [C]

## C. Infraestructura (Estaciones)

- [x] Plataformas de dirigible con parada [M]
- [x] Estación central de tren SOLO si M67 define la locomotora [M]
- [x] Parada en la isla del Este y del Norte [M]
- [x] Estaciones con indicación de horarios (M29) [M]
- [x] Documentar el estado condicional de la estación de tren [S]

## D. Red de Rutas (grafo)

- [x] Definir transport_route.gd (origen, destino, duración, coste) [M]
- [x] Crear transport_network.tres como única fuente de verdad [M]
- [x] Definir 8-12 paradas y 15-20 rutas típicas [M]
- [x] Sin bucles duplicados (grafo simple validado) [M]
- [x] Testear el grafo con ruta corta (dijkstra, orden de paradas) [C]

## E. Costes y Descuentos (M38/M20)

- [x] Definir coste base por ruta (M38) [M]
- [x] Coste directo mayor que combinar rutas (incentivo de exploración) [M]
- [x] Descuento del 20% con amistad nivel 5+ (M20) [M]
- [x] Descuentos visibles en el panel (M53) [S]
- [x] Testear costes con economía vacía y llena [M]

## F. Desbloqueo (M71)

- [x] Desbloquear paradas al construir infraestructura (M71) [M]
- [x] Desbloquear rutas por progreso de historia (M22) [M]
- [x] Rutas bloqueadas con aviso de requisito [S]
- [x] Log STOP-UNLOCKED [S]
- [x] Testear desbloqueo en orden correcto [M]

## G. Restricciones (Horarios y Clima)

- [x] Rutas respetan horario (M29: apertura/cierre por parada) [M]
- [x] Rutas de barco bloqueadas con tormenta (M32) [M]
- [x] Dirigible bloqueado con viento fuerte (M32) [M]
- [x] Aviso claro si se intenta viajar fuera de horario [S]
- [x] Testear restricciones con cambios de clima en vivo [C]

## H. Mapa de Transporte (M54)

- [x] Definir capa de transporte en el mapa (M54) [M]
- [x] Dibujar rutas como líneas en la capa [M]
- [x] Marcadores de parada con horarios en el mapa [M]
- [x] Sincronizar capa con el grafo (una sola fuente) [M]
- [x] Testear el mapa con 3 idiomas (M87) [M]

## I. Señalización en el Mundo (M46)

- [x] Carteles de madera con direcciones y distancias [M]
- [x] Carteles de parada con horarios [M]
- [x] Carteles en atlas batchable (M46/M61) [M]
- [x] Señalización consistente con el mapa (validador) [M]
- [x] Testear carteles de noche (legibles, M49) [M]

## J. Marcadores y Waypoints

- [x] Marcadores de paradas en el mapa (M54) [S]
- [x] Waypoints automáticos en rutas largas [M]
- [x] Waypoints manuales del jugador (marcas en el mapa) [M]
- [x] Persistencia de waypoints (M59) [M]
- [x] Testear waypoints con rutas de 2+ paradas [M]

## K. Panel de Transporte (M53)

- [x] Panel de transporte con lista de rutas [M]
- [x] Mostrar coste, duración y horario por ruta [M]
- [x] Confirmación de compra con aviso de dinero insuficiente [M]
- [x] Botón de "viajar ahora" y "programar" (esperar horario) [M]
- [x] Testear panel en pausa y desde el mapa [M]

## L. Viajes y Tiempos

- [x] Duración por ruta (real o montaje con fade) [M]
- [x] Viajes cortos (muelle cercano) en tiempo real con vehículo (M67) [M]
- [x] Viajes largos con montaje de fade [M]
- [x] Tiempos visibles en el panel antes de comprar [S]
- [x] Testear tiempos en 3 rutas distintas [M]

## M. Transiciones (Sin Perder al Jugador)

- [x] Transición cozy < 4 s con mensaje "Viajando a X..." (M44) [M]
- [x] Barra de progreso (M08) si el destino tarda [M]
- [x] Cargar destino ANTES de mover al jugador (M61) [C]
- [x] Reaparición orientada al destino (nunca perder al jugador) [C]
- [x] Testear transición con streaming pesado [C]

## N. Viajes Especiales (M74/M31)

- [x] Viaje al festival (parada temporal, M74) [M]
- [x] Tour de luna llena (M31) con precio especial [M]
- [x] Viajes especiales registrados en el calendario (M29) [M]
- [x] No aparecer en el grafo normal (solo programados) [M]
- [x] Testear viajes especiales fuera de fecha (no disponibles) [M]

## O. Viajes Narrativos (M22/M23)

- [x] Rutas narrativas sin coste [M]
- [x] Diálogos a bordo durante el trayecto (M21) [M]
- [x] Avanzar hitos de historia al llegar (M22/M23) [M]
- [x] Viaje narrativo no interrumpible [M]
- [x] Testear viaje narrativo del capítulo 1 al 7 [C]

## P. Eventos de Ruta

- [x] Encuentros suaves en ruta (NPC M64 en el muelle) [M]
- [x] Eventos de ruta sin peligro (sin clima hostil inesperado) [M]
- [x] Señal sonora/visual de evento en ruta (M43/M44) [S]
- [x] Evento de ruta del festival (M74) [M]
- [x] Testear eventos sin romper la transición [M]

## Q. Coordinación con Fast Travel (M69)

- [x] Compartir estaciones con M69 (misma red) [M]
- [x] M69 solo muestra destinos con estación desbloqueada [M]
- [x] M69 sin duplicar costes ni rutas de M68 [M]
- [x] M69 más caro que el boleto de ruta (decisión) [M]
- [x] Testear coordinación con M69 en 3 destinos [C]

## R. Animaciones y Pasajeros (M48/M64)

- [x] Puertas/gangways animados en paradas (M48) [M]
- [x] Bandera del barco con viento (M50) en paradas [S]
- [x] NPC pasajeros en paradas (M64) [M]
- [x] NPC abordando el vehículo (M67) [M]
- [x] Testear animaciones con LOD (M61) [M]

## S. IP Pasantes y Accesibilidad (M58)

- [x] HUD del viaje legible con alto contraste [M]
- [x] Tamaño de texto configurable en el panel [M]
- [x] Reduce Motion: transiciones cortas sin zoom [M]
- [x] Subtítulos en mensajes de viaje [S]
- [x] Panel de transporte accesible con gamepad (M57) [M]

## T. Edge Cases

- [x] Viajar con dinero justo o en la última hora de horario [M]
- [x] Viajar durante diálogo (M21, bloqueado) o con inventario lleno [M]
- [x] Viajar al destino destruido (ruina M25) o con el vehículo en uso (M67) [M]
- [x] Carga de guardado a mitad de viaje (M59) y viajes dobles (cola) [C]
- [x] Parada recién desbloqueada sin señal y clima cambiadizo (M32) [M]

## U. Rendimiento (M61)

- [x] Red en un solo .tres (sin nodos por escena) [M]
- [x] Señalización batchable (M46, ≤ 4 carteles por escena) [M]
- [x] Capa de mapa sin draw calls nuevos [M]
- [x] Transición reutilizable (SceneTransition M61) [M]
- [x] Probar con profiler (M116) [C]

## V. Localización (M87)

- [x] Localizar nombres de paradas y rutas [M]
- [x] Localizar mensajes de viaje y horarios [M]
- [x] Localizar carteles del mundo [M]
- [x] Respetar plurales y formatos de hora (12h/24h) [M]
- [x] Testear panel y carteles en 3 idiomas [M]

## W. Validación y QA

- [x] Crear validate_transport.gd (grafo, señalización vs mapa, costes, transiciones) [C]
- [x] Probar ciclo completo: abrir mapa → elegir ruta → pagar → viajar → llegar [C]
- [x] Probar viaje narrativo completo (M22) [C]
- [x] Probar viaje de festival (M74) [C]
- [x] Revisar logs TRP-* en consola sin errores [S]

## X. Documentación

- [x] Documentar la red de transporte en 04-Codigo.md [M]
- [x] Documentar la coordinación con M69 [M]
- [x] Documentar la regla "nunca perder al jugador" [M]
- [x] Documentar el estado condicional de la estación de tren [S]
- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]

## Y. Cierre del Módulo

- [x] Firmar los documentos del módulo (modelo y plataforma) [S]
- [x] Actualizar CHECKLIST-GLOBAL con el progreso real [S]
- [x] Actualizar DOCUMENTACION/README.md con el módulo 68 [S]
- [x] Actualizar ESTADO-PARALELO.md [S]
- [x] Generar el log 64 en Logs/ [S]

## Z. Validación Final (DoD)

- [x] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [x] Push del módulo y reporte al usuario [S]
- [x] Marcar ítems solo al cumplir la DoD (sección 21.6) [S]
- [x] Revisar que plan-inicial == plan-actual (SHA-256) [S]
- [x] Confirmar 130 ítems exactos [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
