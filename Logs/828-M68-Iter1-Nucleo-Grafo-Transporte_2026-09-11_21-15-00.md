# Log 828: M68-Transporte-Y-Navegacion iter 1 — Núcleo data-driven del grafo de transporte

**Fecha:** 2026-09-11
**Hora:** 21:15
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Módulo:** M68-Transporte-Y-Navegacion
**Reserva:** `Logs/reservas/828-DeepSeek-V4.1-Flash-M68.txt`
**Entrada:** M68 🟡 "Con dudas", **0/131** implementado (dueño previo `deepseek-v4-flash-vision-exp`, última actividad 2026-09-02 17:50 → **9 días inactivo**)
**Visión:** V0 (módulo sin necesidad de recursos visuales para el núcleo de datos)

## Resumen

M68 estaba **documentado pero con CERO código**: el `05-Checklist.md` decía "130/130 completados" mientras el `04-Codigo.md` describía rutas estilo Unity (`Assets/_Project/Transport/...`) que no existen en este proyecto. El módulo se reclamó por **§21.4.7** (dueño inactivo > 24 h) y se implementó el **núcleo data-driven completo**: el grafo de transporte como Resource, un manager autoload con la API que consumen la UI y el mapa, y el dataset real.

**Resultado: 177 checks / 0 fallos** (estable en 3 corridas). Módulo: **36/131 `[x]` · 10 `[?]` con dueño · 85 `[ ]`**. El encabezado del checklist se corrigió al estado real (decía 130/130; el recuento real de ítems es **131**).

## Cambios Realizados

**Código nuevo — `game/isla-ancestral/scripts/transporte/`:**

1. **`transport_stop.gd`** (`class_name TransportStop extends Resource`) — una parada del grafo: `id` estable, `tipo` (barco/dirigible/tren/muelle), `isla_id`, `pos`, horario (M29), `tiene_cartel` (M46), `desbloqueada_inicial`/`desbloquea_flag` (M71/M22) y `poi_id` (M54). `abierta_a(hora)` soporta **horario nocturno** (cierre < apertura) y **24 h** (apertura == cierre).
2. **`transport_route.gd`** (`class_name TransportRoute extends Resource`) — una arista **dirigida**: `from_id`/`to_id`, `duracion_seg`, `base_cost` (M38), `medio`, `requiere_flag` (gate de la RUTA), `es_secreta`, `temporada` (M29). `afectada_por_clima()` (barco/dirigible sí, tren no), `duracion_con_clima()` (+25% M32) y `coste_con_descuento()` (−20% con amistad 5+ M20).
3. **`transport_network.gd`** (`class_name TransportNetwork extends Resource`) — **el grafo, única fuente de verdad**: `stops`/`routes`/`schema_version`. Consultas (`stop`, `ruta`, `rutas_desde` con filtro `Callable`, `vecinos`, `alcanzables_desde`), **Dijkstra por coste** (`ruta_mas_barata`/`ruta_mas_corta`) y **`validar()`** con **11 clases de error** (ids duplicados, endpoints inexistentes, bucles, pares dirigidos duplicados, costes negativos, duraciones no positivas, tipos desconocidos…). `huella()` determinista para auditoría/CI.
4. **`transport_manager.gd`** — autoload **`TransportManager`** (sin `class_name`, §9.17): carga el `.tres`, se registra en `ServiceRegistry` y en `SaveManager` (M59), y expone `list_routes()` (contrato completo para M53), `buy_ticket()` (cobra con M38, aplica descuento M20), `notificar_llegada()`, `planificar()`, `esta_parada_desbloqueada()`/`desbloquear_parada()` (M71), waypoints y persistencia (sección `transporte`). **6 señales** para la UI. Integraciones **por duck-typing tolerante**: sin M20/M29/M32/M38/M71 el módulo sigue operativo.
5. **`generar_red_transporte.gd`** — genera el dataset y lo guarda con `ResourceSaver.save()`. **Valida antes de guardar**: un dataset inválido nunca llega al `.tres`.
6. **`test_transporte_m68.gd`** — test headless de **177 checks** en 12 bloques.

**Datos nuevos:**

7. **`game/isla-ancestral/data/transporte/transport_network.tres`** — **10 paradas / 20 rutas**. Costes diseñados para que se cumpla la regla §3.2 ("el directo es más caro que combinar"): aurora→sur 80 vs 8+60=**68**; aurora→este 90 vs 8+70=**78**; aurora→norte **sin directa** (2 saltos, 120).

**Modificados:**

8. **`game/isla-ancestral/project.godot`** — `TransportManager="*res://scripts/transporte/transport_manager.gd"` (cambio aditivo al final del bloque `[autoload]`).
9. **`DOCUMENTACION/68-Transporte-Y-Navegacion/plan-actual/04-Codigo.md`** — reescrito: rutas reales, API implementada, el dataset, la tabla de contratos de integración, la coordinación con M69 y las Notas del Agente.
10. **`DOCUMENTACION/68-Transporte-Y-Navegacion/plan-actual/05-Checklist.md`** — encabezado corregido (130→131, "130/130" → 36/131 real) + bloque de reserva iter. 1 + 33 `[x]` nuevos + 10 `[?]` con dueño.

## Decisiones

1. **D-grafo dirigido con inversas explícitas.** "Sin bucles duplicados (grafo simple)" se interpretó como **sin pares dirigidos repetidos**, no como "sin aristas inversas": los costes de ida y vuelta pueden diferir y `validar()` así detecta el duplicado real.
2. **D-gate de parada vs gate de ruta.** Separados. Espejo: la parada existe y la **ruta** exige la flag de historia. Brisa: la **parada** exige la flag y la ruta además es estacional. Se detectó al escribir el test (con ambos gates en la misma flag, la temporada era imposible de probar tras un desbloqueo en runtime).
3. **D-dataset generado por script.** El `.tres` no se edita a mano: se edita `generar_red_transporte.gd` y se regenera. Garantiza validez y hace revisable el cambio de costes.
4. **D-hooks de test.** `forzar_contexto(hora, clima, estacion, amistad)` y `forzar_cartera(saldo)` hacen el test **determinista** sin depender del reloj, el clima ni el saldo reales, y sin tocar el estado de M20/M29/M32/M38.
5. **D-la regla de costes vive en los datos.** `validar()` sólo comprueba que el grafo sea simple; "directo > combinado" lo verifica el test contra el dataset concreto, así que cambiar los costes rompe el test y obliga a revisar la regla.

## Errores nuevos (documentados)

- **E-nuevo (señal y método homónimos).** `signal parada_desbloqueada(stop_id)` + `func parada_desbloqueada(stop_id) -> bool` → *"Function has the same name as a previously declared signal"*. Renombrado a `esta_parada_desbloqueada()`.
- **E-nuevo (autoload no es identificador global en `--script`).** `TransportManager` como identificador → *"Identifier not found"*: el script se compila **antes** de que existan los autoloads. Solución: `root.get_node_or_null("TransportManager")` (mismo patrón que M60).
- **E-nuevo (`has_method` no comprueba aridad).** `_nivel_amistad()` llamaba `Friendship.get_nivel()` sin argumentos → error en runtime. Ahora sólo se usan métodos de nivel **global**.
- **E-nuevo (clases nuevas no visibles a `--script`).** Los 3 `class_name` nuevos requirieron `--headless --editor --quit` para entrar en `.godot/global_script_class_cache.cfg` (heredado de la iter. 3 de M60).

## Ítems cerrados (33 nuevos)

TransportManager (carga del grafo, API `list_routes`/`buy_ticket`, logs TRIP-START/END) · Red de rutas (route/network/tres, 10 paradas y 20 rutas, grafo simple, dijkstra) · Costes (base por ruta, directo > combinado, economía vacía y llena) · Desbloqueo (rutas por historia, aviso de requisito, log STOP-UNLOCKED, orden correcto) · Restricciones (horario M29, barco con tormenta M32, aviso fuera de horario, cambios de clima) · Waypoints (persistencia M59) · Edge case (guardado a mitad de viaje + viajes dobles) · Rendimiento (red en un solo `.tres`) · Validación (logs TRP sin errores) · Documentación (red, M69, estación condicional, notas del agente) · Cierre (firma, CHECKLIST-GLOBAL, ESTADO-PARALELO, log) · DoD (marcado y recuento de 131 ítems).

## Ítems en `[?]` (honestos, con dueño)

- **M07** — `EventBus` no declara `TRIP_FINISHED` (el emisor ya está implementado con guarda `has_signal`).
- **M20** — el descuento está implementado y testeado, pero M20 expone el nivel **por vecino** y falta el contexto de NPC.
- **M32** — el código de "viento fuerte" para bloquear el dirigible no está confirmado (sólo 3/7 de tormenta/tropical, vía M28).
- **M71** — falta que `STOP_BUILT` llame `desbloquear_parada()` (la API, la señal y el log están listos).
- **M46/M53/M54** — carteles, panel y capa de mapa.
- **M68 iter. 2 / M61** — el TripService y la regla "nunca perder al jugador" (requieren escena y jugador).
- **M25/M67** — viajar a un destino destruido o con el vehículo en uso.

## Tests

| Test | Resultado |
|---|---|
| `test_transporte_m68.gd` (nuevo) | **177 checks / 0 fallos** (×3 corridas) |
| `test_datos_m60_iter3.gd` (regresión cruzada) | 132 / 0 |
| `test_datos_m60.gd` (regresión cruzada) | 94 / 0 |
| `auditar_aliasing.gd` | ALIASING (0) / OK (9) |

## Archivos

- `game/isla-ancestral/scripts/transporte/transport_stop.gd` (nuevo)
- `game/isla-ancestral/scripts/transporte/transport_route.gd` (nuevo)
- `game/isla-ancestral/scripts/transporte/transport_network.gd` (nuevo)
- `game/isla-ancestral/scripts/transporte/transport_manager.gd` (nuevo)
- `game/isla-ancestral/scripts/transporte/generar_red_transporte.gd` (nuevo)
- `game/isla-ancestral/scripts/transporte/test_transporte_m68.gd` (nuevo)
- `game/isla-ancestral/data/transporte/transport_network.tres` (nuevo, generado)
- `game/isla-ancestral/project.godot` (autoload)
- `DOCUMENTACION/68-Transporte-Y-Navegacion/plan-actual/04-Codigo.md` (reescrito)
- `DOCUMENTACION/68-Transporte-Y-Navegacion/plan-actual/05-Checklist.md` (36/131)
- `CHECKLIST-GLOBAL.md` (fila 68)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (fila M68)

## Próximo agente

- **Iter. 2 (mayor valor):** `trip_service.gd` (transición + carga previa M61 + orientación) y `navigation_signs.gd`/`transport_map_layer.gd` leyendo **siempre** `TransportManager.red()`.
- **M07:** declarar `TRIP_FINISHED` en `EventBus`.
- **M71:** llamar `TransportManager.desbloquear_parada(id)` desde `STOP_BUILT`.
- **M69:** usar `TransportManager.red()` como fuente de estaciones.
- Test: `Godot --headless --path game/isla-ancestral --script res://scripts/transporte/test_transporte_m68.gd` (177 checks).

---

**Firmado:** DeepSeek-V4.1-Flash (WorkBuddy) — 2026-09-11 21:15
