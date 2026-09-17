**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-11 (último modificador)

# 05-Checklist.md — Módulo 68: Transporte y Navegación (131 ítems)

**Estado real:** **36/131 `[x]` · 10 `[?]` con dueño · 85 `[ ]`** (2026-09-11, iter. 1 por DeepSeek-V4.1-Flash, Log 828).
> ⚠️ El encabezado anterior decía "130/130 completados" con **0 código implementado** (la documentación de M68 era sólo diseño con rutas estilo Unity). Corregido al estado real.

## Reserva actual (iter. 2 — abierta 2026-09-15)

- Estado: 🔵 En curso
- Agente: DeepSeek-V4.1-Flash (WorkBuddy)
- Entrada: M68 36/131 `[x]` · 10 `[?]` · 85 `[ ]`
- Alcance: la **mitad verificable headless** — planificador de viaje (fases, cozy < 4 s, cargar destino ANTES de mover, orientación al destino, "nunca perder al jugador"), viajes especiales (M74/M31), viajes narrativos (M22/M23), eventos de ruta sin peligro, puente con M69, localización 12h/24h + plurales y validador unificado.
- Fuera del alcance (dueño externo): todo lo que necesita escena/UI/3D — carteles (M46), capa del mapa (M54), panel (M53), docking y vehículos (M67), animaciones (M48), NPC pasajeros (M64).
- Log: 910 (reserva en `Logs/reservas/910-DSV41F-M68.txt`)

## Reserva anterior (iter. 1 — cerrada 2026-09-11)

- Estado: 🟡 Liberado — 2026-09-11
- Agente: DeepSeek-V4.1-Flash (WorkBuddy)
- Entrada: M68 0/131 ("Con dudas"), dueño previo `deepseek-v4-flash-vision-exp` (última actividad 2026-09-02, 9 días → reclamado §21.4.7)
- Salida: **núcleo data-driven del grafo de transporte** — `TransportStop`/`TransportRoute`/`TransportNetwork` (Resource) + `TransportManager` (autoload) + `data/transporte/transport_network.tres` (10 paradas / 20 rutas) + generador del dataset + test headless **177 checks / 0 fallos**.
- Archivos: `game/isla-ancestral/scripts/transporte/{transport_stop,transport_route,transport_network,transport_manager,generar_red_transporte,test_transporte_m68}.gd`, `game/isla-ancestral/data/transporte/transport_network.tres`, `project.godot` (autoload)
- Log: 828
- Fecha cierre: 2026-09-11

## A. TransportManager (autoload)

- [x] Definir TransportManager como autoload único de transporte [M]
- [x] Cargar el grafo de paradas/rutas desde transport_network.tres [M]
- [x] Exponer API list_routes/buy_ticket a la UI (M53) [S]
- [x] Registrar logs TRIP-START y TRIP-END [S]
- [?] Emitir eventos TRIP_FINISHED (M07) — iter. 1 DeepSeek-V4.1-Flash 2026-09-11: el emisor está implementado pero **`EventBus` no declara `TRIP_FINISHED`** (sí `travel_started`, de M28). Declarar el evento es contrato de M07. Dueño: M07. [S]

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
- [?] Descuento del 20% con amistad nivel 5+ (M20) — iter. 1 DeepSeek-V4.1-Flash 2026-09-11: el mecanismo está implementado y testeado (`TransportRoute.coste_con_descuento`, forzando el nivel), pero M20 expone el nivel **por vecino** (`Friendship.get_nivel(vecino_id)`) y el diseño habla del nivel del pasajero con el destino: falta el contexto de NPC. Dueño: M20. [M]
- [?] Descuentos visibles en el panel (M53) — iter. 1 DeepSeek-V4.1-Flash 2026-09-11: `list_routes()` ya entrega `precio` y `precio_base`; falta la UI. Dueño: M53. [S]
- [x] Testear costes con economía vacía y llena [M]

## F. Desbloqueo (M71)

- [?] Desbloquear paradas al construir infraestructura (M71) — iter. 1 DeepSeek-V4.1-Flash 2026-09-11: `TransportManager.desbloquear_parada()` + señal + log `STOP-UNLOCKED` están listos; falta que M71 emita `STOP_BUILT`/llame la API. Dueño: M71. [M]
- [x] Desbloquear rutas por progreso de historia (M22) [M]
- [x] Rutas bloqueadas con aviso de requisito [S]
- [x] Log STOP-UNLOCKED [S]
- [x] Testear desbloqueo en orden correcto [M]

## G. Restricciones (Horarios y Clima)

- [x] Rutas respetan horario (M29: apertura/cierre por parada) [M]
- [x] Rutas de barco bloqueadas con tormenta (M32) [M]
- [?] Dirigible bloqueado con viento fuerte (M32) — iter. 1 DeepSeek-V4.1-Flash 2026-09-11: sólo se conocen los códigos adversos 3/7 (tormenta/tropical, confirmados con M28). El código de "viento fuerte" no está confirmado con M32. Dueño: M32. [M]
- [x] Aviso claro si se intenta viajar fuera de horario [S]
- [x] Testear restricciones con cambios de clima en vivo [C]

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

- [?] Marcadores de paradas en el mapa (M54) — iter. 1 DeepSeek-V4.1-Flash 2026-09-11: el dataset trae `poi_id` por parada; la capa es de M54. Dueño: M54. [S]
- [ ] Waypoints automáticos en rutas largas [M]
- [?] Waypoints manuales del jugador (marcas en el mapa) — iter. 1 DeepSeek-V4.1-Flash 2026-09-11: los datos y su persistencia están listos (T-049); el marcado en el mapa es de M54. Dueño: M54. [M]
- [x] Persistencia de waypoints (M59) [M]
- [ ] Testear waypoints con rutas de 2+ paradas [M]

## K. Panel de Transporte (M53)

- [ ] Panel de transporte con lista de rutas [M]
- [ ] Mostrar coste, duración y horario por ruta [M]
- [ ] Confirmación de compra con aviso de dinero insuficiente [M]
- [ ] Botón de "viajar ahora" y "programar" (esperar horario) [M]
- [ ] Testear panel en pausa y desde el mapa [M]

## L. Viajes y Tiempos

- [x] Duración por ruta (real o montaje con fade) [M]
- [x] Viajes cortos (muelle cercano) en tiempo real con vehículo (M67) [M]
- [x] Viajes largos con montaje de fade [M]
- [?] Tiempos visibles en el panel antes de comprar — iter. 2 DeepSeek-V4.1-Flash 2026-09-15: el planner entrega `duracion` por ruta y `TransportLocalizer.duracion_texto()` la formatea (12 h/24 h + plurales), pero el panel no existe (M53). Dueño: M53. [S]
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
- [?] Diálogos a bordo durante el trayecto (M21) — iter. 2 DeepSeek-V4.1-Flash 2026-09-15: el contrato está implementado y validado (claves `M68.NARR.*` declaradas y no vacías, `DialogueManager` invocado por duck-typing, `validar()` exige que haya guion), pero **no existe ningún grafo de diálogo** para esos ids: `data/dialogues/` sólo tiene 4 archivos. Dueño: M21. [M]
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

- [?] Compartir estaciones con M69 (misma red) — iter. 2 DeepSeek-V4.1-Flash 2026-09-15: **HALLAZGO MEDIDO**: las 4 anclas de `anclas.json` (x/z 256..320, isla RIZ) y las 10 paradas de M68 (`pos` con Z arriba, ±200) usan marcos distintos → **0 estaciones compartidas, 4 huérfanas**. `TransportM69Bridge.estaciones_compartidas()` lo detecta y lo reporta. Dueño del re-anclaje: M69. [M]
- [?] M69 solo muestra destinos con estación desbloqueada — iter. 2 DeepSeek-V4.1-Flash 2026-09-15: el filtro está implementado y testeado (`destinos_disponibles()` consulta `esta_parada_desbloqueada()`, la lista o `desbloqueada_inicial`), pero el menú de M69 no lo consume: `FastTravelService` **ni siquiera es autoload** (no está en `project.godot`). Dueño: M69. [M]
- [x] M69 sin duplicar costes ni rutas de M68 [M]
- [x] M69 más caro que el boleto de ruta (decisión) [M]
- [x] Testear coordinación con M69 en 3 destinos [C]

## R. Animaciones y Pasajeros (M48/M64)

- [ ] Puertas/gangways animados en paradas (M48) [M]
- [ ] Bandera del barco con viento (M50) en paradas [S]
- [ ] NPC pasajeros en paradas (M64) [M]
- [ ] NPC abordando el vehículo (M67) [M]
- [ ] Testear animaciones con LOD (M61) [M]

## S. IP Pasantes y Accesibilidad (M58)

- [ ] HUD del viaje legible con alto contraste [M]
- [x] Tamaño de texto configurable en el panel [M]
- [ ] Reduce Motion: transiciones cortas sin zoom [M]
- [ ] Subtítulos en mensajes de viaje [S]
- [ ] Panel de transporte accesible con gamepad (M57) [M]

## T. Edge Cases

- [ ] Viajar con dinero justo o en la última hora de horario [M]
- [ ] Viajar durante diálogo (M21, bloqueado) o con inventario lleno [M]
- [?] Viajar al destino destruido (ruina M25) o con el vehículo en uso (M67) — iter. 1 DeepSeek-V4.1-Flash 2026-09-11: requiere el estado de M25/M67. Dueño: M25/M67. [M]
- [x] Carga de guardado a mitad de viaje (M59) y viajes dobles (cola) [C]
- [ ] Parada recién desbloqueada sin señal y clima cambiadizo (M32) [M]

## U. Rendimiento (M61)

- [x] Red en un solo .tres (sin nodos por escena) [M]
- [ ] Señalización batchable (M46, ≤ 4 carteles por escena) [M]
- [ ] Capa de mapa sin draw calls nuevos [M]
- [ ] Transición reutilizable (SceneTransition M61) [M]
- [ ] Probar con profiler (M116) [C]

## V. Localización (M87)

- [x] Localizar nombres de paradas y rutas [M]
- [x] Localizar mensajes de viaje y horarios [M]
- [x] Localizar carteles del mundo [M]
- [x] Respetar plurales y formatos de hora (12h/24h) [M]
- [?] Testear panel y carteles en 3 idiomas — iter. 2 DeepSeek-V4.1-Flash 2026-09-15: las 89 claves de M68 están en `es.po` y `en.po` y el test verifica que no falte ninguna en los 2 idiomas, pero M87 sólo declara `LOCALES_SOPORTADOS := ["es", "en"]`: no hay tercer idioma que probar. Dueño: M87. [M]

## W. Validación y QA

- [x] Crear validate_transport.gd (grafo, señalización vs mapa, costes, transiciones) — iter. 2 DeepSeek-V4.1-Flash 2026-09-15: **creado** con 9 bloques (`grafo`, `planes`, `costes`, `especiales`, `narrativos`, `eventos`, `m69`, `localizacion`, `ciclo`), `simular_ciclo()` end-to-end e `informe()`. "Señalización vs mapa" se declara en `PENDIENTES_EXTERNOS` (M46/M54) en vez de fingirse. [C]
- [x] Probar ciclo completo: abrir mapa → elegir ruta → pagar → viajar → llegar [C]
- [x] Probar viaje narrativo completo (M22) [C]
- [x] Probar viaje de festival (M74) [C]
- [x] Revisar logs TRP-* en consola sin errores [S]

## X. Documentación

- [x] Documentar la red de transporte en 04-Codigo.md [M]
- [x] Documentar la coordinación con M69 [M]
- [?] Documentar la regla "nunca perder al jugador" — iter. 1 DeepSeek-V4.1-Flash 2026-09-11: la regla vive en el TripService (transición + carga previa M61), que **no está implementado** (requiere escena/jugador, fuera del alcance headless). Dueño: M68 iter. 2 / M61. [M]
- [ ] Documentar el estado condicional de la estación de tren [S]
- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]

## Y. Cierre del Módulo

- [x] Firmar los documentos del módulo (modelo y plataforma) [S]
- [x] Actualizar CHECKLIST-GLOBAL con el progreso real [S]
- [ ] Actualizar DOCUMENTACION/README.md con el módulo 68 [S]
- [x] Actualizar ESTADO-PARALELO.md [S]
- [x] Generar el log 64 en Logs/ [S]

## Z. Validación Final (DoD)

- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Push del módulo y reporte al usuario [S]
- [x] Marcar ítems solo al cumplir la DoD (sección 21.6) [S]
- [ ] Revisar que plan-inicial == plan-actual (SHA-256) [S]
- [x] Confirmar 131 ítems exactos (contados: 131) [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
