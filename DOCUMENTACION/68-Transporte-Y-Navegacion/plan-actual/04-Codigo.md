**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15 (último modificador)
**Historial:** diseño completo por Deepseek V4 Flash (OpenCode, 2026-08-17) · núcleo data-driven implementado por DeepSeek-V4.1-Flash (WorkBuddy, 2026-09-11) · lógica headless de viaje, viajes especiales/narrativos, eventos de ruta, puente M69, localización y validador unificado por DeepSeek-V4.1-Flash (WorkBuddy, 2026-09-15, iter. 2 — Log 910)

# 04-Codigo.md — Módulo 68: Transporte y Navegación

> ⚠️ **ESTADO 2026-09-15: iter. 2 completada** por DeepSeek-V4.1-Flash (WorkBuddy).
> La documentación previa describía rutas estilo Unity (`Assets/_Project/Transport/...`). La convención real del proyecto es **`game/isla-ancestral/scripts/<dominio>/`** y **`data/`** para los datasets; las firmas públicas del diseño se respetan con nombres reales.

## 1. Ubicación de archivos (REAL, implementado)

```
game/isla-ancestral/
├── scripts/transporte/
│   ├── transport_stop.gd              ← class_name TransportStop (Resource): parada
│   ├── transport_route.gd             ← class_name TransportRoute (Resource): arista
│   ├── transport_network.gd           ← class_name TransportNetwork (Resource): el grafo
│   ├── transport_manager.gd           ← autoload "TransportManager" (sin class_name, §9.17)
│   ├── transport_trip_planner.gd      ← iter.2: PLAN del viaje (fases, cozy, orientación)
│   ├── transport_special_trips.gd     ← iter.2: viajes especiales (festivales M74, luna M31, tour)
│   ├── transport_narrative_trips.gd   ← iter.2: viajes narrativos (M22/M23, hitos y sellos)
│   ├── transport_route_events.gd      ← iter.2: eventos de ruta sin peligro (M64, señal M43/M44)
│   ├── transport_m69_bridge.gd        ← iter.2: puente con Fast Travel (M69)
│   ├── transport_localizer.gd         ← iter.2: localización M68 (12h/24h, plurales, carteles)
│   ├── validate_transport.gd          ← iter.2: VALIDADOR UNIFICADO (9 bloques + ciclo completo)
│   ├── generar_red_transporte.gd      ← generador del dataset (SceneTree)
│   ├── dump_locales_m68.gd            ← iter.2: vuelca el catálogo de M68 a JSON para los .po
│   ├── test_transporte_m68.gd         ← Test headless iter.1 (177 checks, 0 fallos)
│   └── test_transporte_m68_iter2.gd   ← Test headless iter.2 (199 checks, 0 fallos)
├── data/transporte/
│   ├── transport_network.tres         ← ÚNICA FUENTE DE VERDAD (10 paradas, 20 rutas)
│   └── m68_catalogo.json              ← catálogo generado (es/en) para aplicar a los .po
└── locales/
    ├── es.po                          ← +89 claves de M68 (86 simples + 3 plurales)
    └── en.po                          ← +89 claves de M68
```

**Diferencia vs el diseño:** el diseño preveía además `trip_service.gd`, `navigation_signs.gd`, `transport_map_layer.gd`, `transport_panel.gd` y `trip_transition.gd`. **Siguen sin implementar** porque dependen de escena/jugador (TripService, M61), de M46/M54 (carteles y capa de mapa) o de M53 (panel). La iter. 2 implementa en su lugar **toda la lógica de esas piezas que no necesita escena**: el plan del viaje, los registros de viajes especiales/narrativos/eventos, el puente con M69, la localización y el validador unificado. `validate_transport.gd` **sí existe** ahora (era el objetivo declarado de la sección W).

## 2. Registro en project.godot (REAL)

```
[autoload]
TransportManager="*res://scripts/transporte/transport_manager.gd"
```

## 3. API pública implementada

### 3.1 `transport_stop.gd` — TransportStop (Resource)

Una parada del grafo. Es la unidad de desbloqueo (M71) y de señalización (M46).

```gdscript
@export var id: StringName            # estable, snake_case ("puerto_aurora")
@export var nombre_clave: String      # "M68.STOP.<id>" para M87
@export var nombre_fallback: String   # texto en español (fallback y tests)
@export var tipo: String              # "barco" | "dirigible" | "tren" | "muelle"
@export var isla_id: String
@export var pos: Vector3              # voxel 1 m, Z arriba
@export_range(0,23) var horario_apertura: int
@export_range(0,23) var horario_cierre: int
@export var tiene_cartel: bool
@export var desbloqueada_inicial: bool
@export var desbloquea_flag: StringName   # flag de WorldState (M71/M22)
@export var poi_id: String                # POI del mapa (M54)

func abierta_a(hora: int) -> bool     # soporta horario nocturno y 24 h
func horario_texto() -> String        # "06:00-22:00"
func a_diccionario() -> Dictionary
```

### 3.2 `transport_route.gd` — TransportRoute (Resource)

Una **arista dirigida**. La inversa es explícita en el grafo (no se genera sola).

```gdscript
@export var id: StringName
@export var from_id: StringName
@export var to_id: StringName
@export var duracion_seg: float
@export var base_cost: int            # AO (M38)
@export var medio: String             # "barco" | "dirigible" | "tren" | "muelle"
@export var requiere_flag: StringName # gate de la RUTA (M22)
@export var es_secreta: bool
@export var temporada: String         # "" | "todas" | estación (M29)
@export var bidireccional: bool       # informativo

func afectada_por_clima() -> bool                  # barco/dirigible sí, tren no
func duracion_con_clima(factor: float) -> float    # +25% (M32)
func coste_con_descuento(nivel_amistad: int) -> int # −20% con nivel 5+ (M20)
func a_diccionario() -> Dictionary
```

### 3.3 `transport_network.gd` — TransportNetwork (Resource)

**El grafo.** Es lo que leen la señalización (M46), la capa del mapa (M54) y el panel (M53): nadie duplica la red.

```gdscript
@export var stops: Array[TransportStop]
@export var routes: Array[TransportRoute]
@export var schema_version: int = 1

func stop(id) -> TransportStop
func ruta(id) -> TransportRoute
func tiene_stop(id) -> bool
func contar_stops() -> int
func contar_rutas() -> int
func rutas_desde(origen, permitir := Callable()) -> Array[TransportRoute]
func vecinos(origen) -> Array[StringName]
func ruta_mas_barata(origen, destino, permitir := Callable()) -> Dictionary
func ruta_mas_corta(...) -> Dictionary     # alias con el nombre del diseño
func alcanzables_desde(origen) -> Array[StringName]
func validar() -> Array[String]            # vacío = red válida
func es_valida() -> bool
func huella() -> String                    # determinista, ordenada
```

**Dijkstra por COSTE (no por saltos).** Es lo que hace que combinar rutas gane al viaje directo, que es la regla de diseño §3.2. Devuelve `{ok, coste, duracion, saltos, paradas, rutas}`; sin camino → `{ok:false, motivo}`.

**`validar()`** detecta 11 clases de error: parada nula/sin id/id duplicado/tipo desconocido, ruta nula/sin id/id duplicado, origen o destino inexistente, bucle (origen == destino), par dirigido duplicado, coste negativo y duración no positiva. Es la puerta de calidad del dataset (la usa el test y puede usarla el CI de M108/M118).

### 3.4 `transport_manager.gd` — autoload "TransportManager"

```gdscript
signal rutas_listadas(stop_id, rutas)
signal viaje_iniciado(route_id, coste)
signal viaje_llegado(route_id, stop_id)
signal parada_desbloqueada(stop_id)
signal waypoint_agregado(stop_id)
signal waypoint_quitado(stop_id)

func red() -> TransportNetwork
func tiene_red() -> bool
func contar_paradas() -> int
func contar_rutas() -> int
func parada(id) -> TransportStop
func list_routes(stop_id) -> Array[Dictionary]     # contrato para M53
func buy_ticket(route_id, stop_id) -> Dictionary   # {ok, motivo, precio, route_id}
func notificar_llegada() -> Dictionary             # lo llama el TripService
func viaje_en_curso() -> StringName
func planificar(origen, destino) -> Dictionary     # camino más barato + precio
func esta_parada_desbloqueada(stop_id) -> bool
func desbloquear_parada(stop_id) -> bool
func agregar_waypoint(stop_id) -> bool
func quitar_waypoint(stop_id) -> bool
func waypoints() -> Array[String]
func tiene_waypoint(stop_id) -> bool
# ISaveProvider (M59)
func get_section_name() -> String                  # "transporte"
func get_save_data() -> Dictionary
func restore_save_data(datos) -> void
```

**`list_routes()`** devuelve, por ruta: `route_id, from, to, to_nombre, medio, precio, precio_base, duracion, horario, disponible, motivo_bloqueo`. La UI (M53) no calcula nada: sólo pinta.

**Orden de bloqueo** (determinista y testeado): desbloqueo de parada → flag de ruta → horario del destino → temporada → clima.

### 3.5 Hooks de test

`forzar_contexto(hora, clima, estacion, amistad)` y `forzar_cartera(saldo)` fijan el contexto para que el test headless sea **determinista** sin depender de M20/M29/M32/M38 reales. En producción quedan en `-1`/`""` y se consultan los autoloads. `forzar_cartera(-1)` desactiva la cartera simulada y vuelve a M38.

### 3.6 `generar_red_transporte.gd`

Construye el dataset y lo guarda con `ResourceSaver.save()` en `res://data/transporte/transport_network.tres`. **Se genera por script, no a mano**: garantiza un `.tres` válido y hace revisable cualquier cambio de costes/paradas. Valida antes de guardar: si el dataset es inválido, no escribe y sale con código 1.

## 4. El dataset (10 paradas, 20 rutas)

| Parada | Tipo | Isla | Horario | Gate |
|---|---|---|---|---|
| `puerto_aurora` | barco | isla_raiz | 06-22 | inicial |
| `muelle_raiz_sur` | muelle | isla_raiz | 06-22 | inicial |
| `plataforma_norte` | dirigible | isla_raiz | 08-19 | inicial |
| `estacion_central` | tren | isla_raiz | 06-21 | inicial |
| `puerto_sur` | barco | isla_sur | 07-21 | inicial |
| `puerto_este` | barco | isla_este | 07-21 | inicial |
| `puerto_norte` | barco | isla_norte | 07-20 | inicial |
| `puerto_brisa` | barco | isla_brisa | 08-20 | flag `templo_brisa_abierto` + temporada verano |
| `puerto_espejo` | barco | isla_espejo | 09-19 | flag de RUTA `pistas_secreto_completas` |
| `puerto_festival` | barco | isla_raiz | 10-23 | flag `festival_activo` (M74) |

**La regla de costes del diseño está en los datos, no en el código:**

| Trayecto | Directo | Combinado | Resultado |
|---|---|---|---|
| aurora → sur | 80 | aurora→muelle (8) + muelle→sur (60) = **68** | combinado gana |
| aurora → este | 90 | aurora→muelle (8) + muelle→este (70) = **78** | combinado gana |
| aurora → norte | *(sin directa)* | aurora→plataforma (20) + plataforma→norte (100) = **120** | 2 saltos obligatorios |

`TransportNetwork.validar()` sólo comprueba que el grafo sea **simple**; la propiedad "directo > combinado" la verifica el test contra el dataset concreto (así, cambiar los costes rompe el test y obliga a revisar la regla).

## 5. Contratos de integración (todos por DUCK-TYPING tolerante)

Si el módulo dueño no está presente, M68 sigue operativo (sin descuento, a las 12:00, sin clima, sin cobro, todo desbloqueado). **Nunca se cae por una dependencia ausente.**

| Módulo | Cómo se integra | Estado |
|---|---|---|
| M38 Economía | `EconomyManager.retirar_monedas()` al comprar | ✅ cableado |
| M29 Tiempo | `GameTime.get_hora()` / `get_estacion()` (o `TimeCalendar`) | ✅ cableado |
| M32 Clima | `Weather.get_clima()`; códigos adversos 3 (tormenta) y 7 (tropical) | ✅ cableado (viento del dirigible pendiente) |
| M71 Desbloqueo | `desbloquear_parada()` + señal + log `STOP-UNLOCKED` | ✅ API lista, falta el emisor de M71 |
| M22 Historia | `WorldState.has_flag()` para `desbloquea_flag`/`requiere_flag` | ✅ cableado |
| M20 Amistad | `Friendship` con nivel global si existe | ⚠️ M20 expone nivel por vecino → `[?]` |
| M07 EventBus | `TRIP_FINISHED` | ⚠️ el evento no está declarado en EventBus → `[?]` |
| M59 Guardado | `SaveManager.register_provider(self)` (sección `transporte`) | ✅ cableado |
| M53 UI | `list_routes()` + señales | ✅ contrato listo, falta la UI |
| M69 Fast travel | comparte las mismas estaciones | 📄 documentado (ver §7) |

## 6. Regla "nunca perder al jugador" (documentada, aún sin implementar)

El diseño la define así: al viajar, la transición debe (1) mostrar el mensaje "Viajando a X...", (2) **cargar el destino ANTES de mover al jugador** (M61), (3) reaparecer orientado al destino. Esa lógica vive en el **TripService**, que no está implementado en iter. 1 porque necesita escena y jugador (fuera del alcance headless). Lo que sí garantiza el núcleo actual es que **el estado nunca queda inconsistente**: si se restaura un save cuya ruta ya no existe en el dataset, el viaje se descarta y se registra `TRIP-ORPHAN` (jamás soft-lock).

## 7. Coordinación con M69 (Fast Travel)

Decisión del diseño, respetada: **M68 vende "boletos de ruta"** (viaje con transición y coste por trayecto) y **M69 vende "teletransporte"** (más caro, sin animación, sólo entre anclas desbloqueadas). Comparten las **mismas estaciones**: `TransportStop.id` es la clave común, y M69 sólo debe mostrar destinos con la parada desbloqueada (`TransportManager.esta_parada_desbloqueada`). **M69 no duplica rutas ni costes.** M69 ya existe (`scripts/fasttravel/fast_travel_service.gd`, `data/fasttravel/anclas.json`); el puente concreto (usar `TransportManager` como fuente de estaciones) queda para la iter. 2.

## 8. Estado condicional de la estación de tren

La `estacion_central` (tren) **existe en el dataset** y es funcional como parada, pero la **locomotora** depende de M67 (vehículos). El diseño lo preveía como parada opcional: si M67 no define la locomotora, la estación sigue siendo válida como nodo del grafo (conecta aurora y la plataforma) y se puede retirar del dataset regenerándolo, sin tocar código.

## 9. Convenciones respetadas

- GDScript puro (Godot 4.7); errores como valores de retorno, nunca excepciones.
- IDs estables y snake_case; texto visible por clave de localización `M68.STOP.<id>` (M87).
- `TransportNetwork` es un Resource: **un solo `.tres`, sin nodos por escena** (rendimiento M61).
- `TransportManager` es autoload sin `class_name` (§9.17/§9.41 de la guía).
- Nada de referencias vivas en `get_save_data()` (BUG-014): copias explícitas y ordenadas.

## Notas del Agente — iter. 1 (2026-09-11)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-11
**Estado:** núcleo data-driven implementado, 🟡 **36/131 `[x]` · 10 `[?]` · 85 `[ ]`**
**Log:** 828

### Lo que hice
- **El grafo, como Resource y fuente única de verdad.** `TransportStop`, `TransportRoute` y `TransportNetwork` (`class_name`, `extends Resource`). La red vive en **un** `transport_network.tres` (10 paradas, 20 rutas), no en nodos por escena.
- **Dijkstra por coste**, no por saltos: es lo que hace que "combinar rutas" gane al viaje directo (§3.2 del diseño). Con filtro opcional por `Callable`, que es como el manager aplica desbloqueo/horario/clima al planificar.
- **`validar()`** como puerta de calidad del dataset: 11 clases de error (ids duplicados, endpoints inexistentes, bucles, pares duplicados, costes negativos…). El test comprueba que **detecta las 11**.
- **`TransportManager` (autoload)**: `list_routes()` (contrato completo para M53), `buy_ticket()` con cobro real (M38) y descuento (M20), `notificar_llegada()`, `planificar()`, desbloqueo (M71), waypoints y persistencia (M59). Orden de bloqueo determinista y testeado.
- **Dataset generado por script** (`generar_red_transporte.gd`): valida antes de guardar, así que un dataset roto nunca llega al `.tres`. Los costes se diseñaron para que la regla "directo > combinado" se cumpla y **el test la verifique**.
- **Test headless: 177 checks / 0 fallos**, estable en 3 corridas. Cubre dataset, las 11 clases de error de `validar()`, dijkstra (costes, saltos, orden de paradas, sin camino, origen == destino), vecinos/alcanzables, unidades de Stop/Route, `list_routes` (horario, clima, temporada, gate de parada vs gate de ruta, descuento), `buy_ticket` (éxito, doble boleto, ruta inexistente, ruta desde otra parada, destino bloqueado, saldo insuficiente), `planificar`, desbloqueo, waypoints, persistencia (round-trip, anti-aliasing, ruta huérfana) y las 6 señales.

### Lo que NO pude hacer (honestidad obligatoria)
- [?] **`TRIP_FINISHED` (M07).** El emisor está implementado y guardado con `has_signal()`, pero **`EventBus` no declara ese evento** (sí `travel_started`, de M28). Declararlo es contrato de M07 → **dueño M07**.
- [?] **Descuento M20 por nivel real.** El mecanismo está implementado y testeado forzando el nivel, pero M20 expone el nivel **por vecino** (`Friendship.get_nivel(vecino_id)`) y el diseño habla del nivel del pasajero con el destino: falta el contexto de NPC → **dueño M20**.
- [?] **Dirigible con viento fuerte (M32).** Sólo conozco los códigos adversos 3/7 (confirmados con M28). El código de "viento fuerte" no está confirmado → **dueño M32**.
- [?] **Desbloqueo por construcción (M71).** La API + señal + log `STOP-UNLOCKED` están listos; falta que M71 emita `STOP_BUILT` → **dueño M71**.
- [?] **Capa de mapa y carteles (M54/M46)**, **panel (M53)** y **`validate_transport.gd` completo** (señalización vs mapa): son de UI/mundo, fuera del alcance headless → **dueños M46/M53/M54**.
- [?] **TripService / transición / "nunca perder al jugador".** Requiere escena y jugador (M61). El núcleo garantiza que **el estado nunca queda inconsistente**, pero la transición visual no existe todavía.
- **[ ] 85 ítems** siguen sin marcar: son infraestructura en el mundo (puertos, muelles, plataformas), UI, señalización, animaciones, localización y los ciclos completos de viaje. Nada de eso es verificable headless.

### Intentos fallidos / decisiones
- **Decisión D-grafo dirigido con inversas explícitas.** El diseño decía "sin bucles duplicados (grafo simple)": se interpretó como **sin pares dirigidos repetidos**, no como "sin aristas inversas". Las inversas son explícitas porque los costes de ida y vuelta pueden diferir y porque `validar()` puede así detectar el duplicado real.
- **Decisión D-gate de parada vs gate de ruta.** Una parada puede estar desbloqueada y su ruta seguir bloqueada (espejo: la parada existe, la ruta exige la flag de historia) y al revés (brisa: la parada exige la flag, la ruta además es estacional). Separar los dos gates permite expresar ambos casos sin duplicar lógica. **Se detectó en el propio test**: al principio brisa tenía los dos gates con la misma flag, lo que hacía imposible probar la temporada tras un desbloqueo en runtime.
- **Decisión D-hooks de test.** Sin ellos, `list_routes` dependería del reloj, el clima y el saldo reales → test no determinista. Con `forzar_contexto`/`forzar_cartera` el test fija el contexto y **no toca el estado de M20/M29/M32/M38**. Es la misma idea que usan los dobles de M60.
- **Error resuelto (E-nuevo): señal y método con el mismo nombre.** `signal parada_desbloqueada(stop_id)` + `func parada_desbloqueada(stop_id) -> bool` → *"Function has the same name as a previously declared signal"*. Renombrado el método a `esta_parada_desbloqueada()`. Documentado.
- **Error resuelto (E-nuevo): autoload no es identificador global en modo `--script`.** `TransportManager` como identificador → *"Identifier not found"*, porque el script se compila **antes** de que existan los autoloads. Solución: `root.get_node_or_null("TransportManager")`. (M60 ya usaba este patrón; queda documentado como regla.)
- **Error resuelto:** `_nivel_amistad()` llamaba `Friendship.get_nivel()` sin argumentos porque `has_method()` no comprueba la aridad → error en runtime. Ahora sólo se usan métodos de nivel **global**.
- **Corrección de encabezado:** el `05-Checklist.md` decía "130/130 completados" con **0 código implementado**. Corregido a 36/131 con el estado real; el recuento real de ítems es **131**, no 130.

### Recomendaciones para el próximo agente
- **Iter. 2 (la de más valor):** implementar el `TripService` (transición con carga previa M61 y orientación al destino) y el `navigation_signs.gd`/`transport_map_layer.gd` leyendo **siempre** `TransportManager.red()` — nunca una copia.
- **M07:** declarar `TRIP_FINISHED` en `EventBus` para que el evento empiece a emitirse.
- **M71:** llamar `TransportManager.desbloquear_parada(id)` desde `STOP_BUILT`.
- **M32:** confirmar el código de "viento fuerte" y ampliar `CLIMAS_ADVERSOS`/la regla del dirigible.
- **M69:** usar `TransportManager.red()` como fuente de estaciones y `esta_parada_desbloqueada()` para filtrar destinos.
- **Si se cambian costes o paradas:** editar `generar_red_transporte.gd` y **regenerar** el `.tres` (nunca editar el `.tres` a mano). El test verifica la regla "directo > combinado": si se rompe, el test falla a propósito.
- Test: `Godot --headless --path game/isla-ancestral --script res://scripts/transporte/test_transporte_m68.gd` (177 checks).

---

## Notas del Agente — iter. 2 (2026-09-15)

**Modelo:** DeepSeek-V4.1-Flash · **Plataforma:** WorkBuddy · **Log:** 910

Alcance: la **mitad verificable headless** de las secciones L, M, N, O, P, Q, V y W del `05-Checklist.md`. Lo que necesita escena/UI/3D sigue fuera (ver "Lo que NO pude hacer").

### 10. API de la iter. 2

#### 10.1 `transport_trip_planner.gd` — TransportTripPlanner (RefCounted)

Planifica el viaje **sin escena ni jugador**: produce el PLAN que el TripService ejecutará cuando exista el runtime 3D.

| Miembro | Qué hace |
|---|---|
| `ORDEN_FASES` | Orden obligatorio: `preparar → cargar_destino → fundido_salida → mover_jugador → fundido_entrada → orientar → notificar` |
| `planificar(ruta, destino, opciones)` | Devuelve `{ok, motivo, modo, duracion_total, necesita_barra, usa_vehiculo, fases, orientacion, sale_de, llega_a, puede_perder_jugador, reintentos_carga}` |
| `verificar_plan(plan)` | Convierte la regla de diseño en algo verificable: total > 0 y < 4 s, orden exacto de fases, `cargar_destino` **antes** de `mover_jugador`, fase de carga bloqueante, orientación unitaria, `puede_perder_jugador == false`, mensaje no vacío |
| `es_viaje_corto(seg)` | `≤ 90 s` → tiempo real con el vehículo (M67); por encima → montaje con fade |
| `orientacion_hacia` / `orientacion_entre` | Vector unitario en XZ hacia el destino (RF20) |

**Invariante clave (RF20):** si la carga del destino falla (`opciones.motivo_aborto`), el plan queda `ok = false`, **sin fases**, con `reintentos_carga` y `puede_perder_jugador = false`. El jugador **no se mueve**.

#### 10.2 `transport_special_trips.gd` — TransportSpecialTrips (RefCounted)

Registro data-driven de 7 viajes especiales: **los 5 festivales reales de M74** (`festival_primavera`, `_verano`, `_otono`, `_invierno`, `_luces`, con sus fechas reales de `scripts/eventos/data/festivales/*.tres`), el **tour de luna llena** (M31) y el **tour panorámico** en dirigible.

- `disponible_en(viaje, fecha, contexto)` → `{ok, motivo}`. Si M74 está presente (`contexto.eventos_activos`), **manda el evento**; si no, se usa el calendario (M29) como respaldo. Motivos legibles: `"sólo el 15/9"`, `"sólo en luna llena"`, `"sólo los fines de semana"`, `"sólo de 08:00 a 20:00"`.
- `rutas_ocultas()` / `ruta_oculta(id)` → las rutas del Puerto del Festival (`r_muelle_festival`, `r_festival_muelle`) **no aparecen en el grafo normal** salvo ventana activa (regla dura de la sección N).
- `validar(red)` → id único, tipo válido, ruta/paradas reales, `precio_base == ruta.base_cost`, precio especial > boleto en luna/tour, y **un viaje oculto debe tener ventana** (si no, sería una parada muerta).

#### 10.3 `transport_narrative_trips.gd` — TransportNarrativeTrips (RefCounted)

Anclado al grafo de historia **real** (`data/historia/historia_principal.json`): `c4` ("El Valle de los Vientos", Templo de la Brisa → `puerto_brisa`), `c7` ("La Cámara del Sello") y `final_secreto` (flag `pistas_secreto_completas` → `puerto_espejo`).

- Reglas duras verificadas: `sin_coste == true`, `precio == 0`, `interrumpible == false`, diálogos a bordo declarados (M21), hito existente en M22.
- `plan_narrativo(viaje, red)` → plan del planner común con `modo = "narrativo"`, precio 0 y no interrumpible.
- `avanzar_hitos(viaje, historia)` → llama por duck-typing a `Historia.completar_nodo()` y `marcar_sello()`. Nunca lanza: sin M22 devuelve el motivo.
- `registrar(viaje)` → M22/M23 pueden añadir sus propios viajes narrativos sin tocar el módulo.

#### 10.4 `transport_route_events.gd` — TransportRouteEvents (RefCounted)

5 encuentros suaves anclados a los NPC **reales** de `data/villagers/*.tres` (mateo_mapache, bruno_sapo, luna_zorra, finneas_zorro, catalina_oso).

- **Invariante dura (RF18):** ningún evento es peligroso, ninguno declara clima adverso, y **con clima adverso (3/7) no se dispara ningún evento**.
- **No rompen la transición:** sólo se disparan en `FASES_SEGURAS = ["preparar", "notificar"]`; `rompe_transicion()` lo comprueba.
- Señal siempre presente (M43 audio / M44 visual).
- `elegir(ruta_id, contexto, semilla, red)` → **determinista** (RandomNumberGenerator con semilla explícita + peso), para que el test no dependa del azar.

#### 10.5 `transport_m69_bridge.gd` — TransportM69Bridge (RefCounted)

- `estaciones_compartidas(red, anclas)` → empareja ancla de M69 con parada de M68 por `stop_id` explícito, por `poi_id` o por **proximidad** (radio 12 m en el plano XZ).
- `destinos_disponibles(...)` → M69 **sólo** ofrece destinos cuya parada esté desbloqueada (consulta el manager real, o la lista, o `desbloqueada_inicial`).
- `detectar_duplicacion(...)` → ancla que reusa el id de una parada, ancla con `rutas`/`precio` propios, dos anclas sobre la misma parada.
- **Decisión 4:** `precio_m69(boleto) = max(ceil(boleto × 1.6), boleto + 10)` → **siempre estrictamente más caro** que el boleto de ruta.

> ⚠️ **HALLAZGO MEDIDO (Log 910):** con los datos actuales (`data/fasttravel/anclas.json`: 4 anclas en x/z 256..320) y las paradas de M68 (pos ±200, Z arriba) hay **0 coincidencias**: M69 y M68 **todavía no comparten ninguna estación** y las 4 anclas son huérfanas. El puente lo detecta y lo reporta; el mecanismo está verificado con 3 destinos anclados a paradas reales.

#### 10.6 `transport_localizer.gd` — TransportLocalizer (RefCounted)

- **Resolución PURA por locale:** lee los `.po` a memoria, así que puede verificar `es` y `en` **sin** llamar a `Localization.set_locale()` (que tendría efectos laterales: señal + persistencia M60).
- **Formatos delegados a `LocaleUtils` (M87)** — no se reimplementa el reloj: `es` 24 h (`08:00-20:00`), `en` 12 h (`8:00 AM-8:00 PM`).
- **Plurales** vía `msgid_plural`/`msgstr[n]` con `{n}`: `45 segundos` · `1 minuto` · `5 minutos` · `1 h 30 min`.
- `generar_catalogo(locale)` es la **única fuente de verdad** del texto de M68: 86 claves simples + 3 plurales por idioma. `dump_locales_m68.gd` lo vuelca a JSON y `scripts/aplicar_locales_m68.py` lo inserta en los `.po` (idempotente, sin BOM, LF, **sin tocar las claves de M87**).
- Convención de claves: `M68.STOP.<id>` · `M68.SIGN.<id>` (plantilla `"→ {destino} · {metros} m"`) · `M68.ROUTE.<id>` (`"<origen> → <destino>"`) · `M68.TRIP.*` · `M68.SPECIAL.*` · `M68.NARR.*` · `M68.EVENT.*`.

#### 10.7 `validate_transport.gd` — ValidateTransport (RefCounted)

Validador **unificado**: 9 bloques (`grafo`, `planes`, `costes`, `especiales`, `narrativos`, `eventos`, `m69`, `localizacion`, `ciclo`) + `simular_ciclo()` (mapa → elegir → pagar → viajar → llegar contra el manager real) + `informe()`.

- `PENDIENTES_EXTERNOS` declara lo que **no** es verificable headless (M46, M54, M53, M48/M64) en vez de fingir cobertura.
- `validar_todo()` devuelve `{ok, errores, checks, bloques, pendientes, mediciones}`.

### 11. Corrección de un `[x]` optimista de la iter. 1

La iter. 1 marcó `[x]` **"Coste directo mayor que combinar rutas (incentivo de exploración)"** afirmando que *"el test la verifica"*. **Es falso como invariante universal:** el test sólo comprobaba 2 rutas (aurora→sur 80 > 68 y aurora→este 90 > 78). Medido sobre las 20 rutas:

| Categoría | Rutas | Detalle |
|---|---|---|
| Cumplen (directo > combinar) | **4** | las **expresas**: `r_aurora_sur`, `r_sur_aurora`, `r_aurora_este`, `r_este_aurora` |
| Violan | **6** | las **locales del muelle**: `r_aurora_muelle`, `r_muelle_aurora` (8 vs 140), `r_muelle_sur`, `r_sur_muelle` (60 vs 88), `r_muelle_este`, `r_este_muelle` (70 vs 98) |
| Sin alternativa | **10** | no aplica |

Las 6 "violaciones" son **correctas por diseño**: en una ruta local el directo *debe* ser la opción barata. Por eso la iter. 2 la convierte de invariante en **medición** (`medir_directo_vs_combinar`), que el validador reporta y el test comprueba (4/6/10). Exigirla como error habría fallado en 6 rutas correctas.

### 12. Integración en `TransportManager`

`_ready()` crea los 5 registros (`especiales()`, `narrativos()`, `eventos_de_ruta()`, `puente_m69()`, `localizador()`). Además:

- `list_routes()` **omite** las rutas de un viaje programado cuando su ventana no está activa (sección N) y las lista cuando sí lo está.
- `_motivo_bloqueo()` añade el gate `"viaje especial: sólo programado"`, que protege también `buy_ticket()` y `planificar()`.
- Nuevos hooks/API: `forzar_fecha(...)`, `fecha_forzada()`, `ruta_oculta()`, `viaje_especial_activo()`, `viajes_especiales_disponibles()`, `viajes_narrativos_disponibles()`, `evento_de_ruta(ruta_id, semilla)`.

### 13. Lo que NO pude hacer (honestidad obligatoria)

- [?] **Diálogos a bordo (M21).** El contrato está implementado y validado (claves `M68.NARR.*` declaradas, `DialogueManager` invocado por duck-typing), pero **no existe ningún grafo de diálogo** para esos ids: `data/dialogues/` sólo tiene 4 archivos (`catalina_hola`, `reaccion_nivel`, `reaccion_regalo`, `contextual`). Sin contenido de M21 no se puede oír nada a bordo → **dueño M21**.
- [?] **Hitos de historia (M22/M23).** `avanzar_hitos()` llama a `Historia.completar_nodo()`/`marcar_sello()` y está verificado con un doble; los **nodos y sellos referenciados existen** en `historia_principal.json` (`c4`, `c7`, `final_secreto`, `sello_brisa_camara`), pero el avance real de la partida es de M22 → verificado el contrato, no la partida.
- [?] **Festival realmente alcanzable (M74/M71).** La ventana del festival funciona por calendario y por `contexto.eventos_activos`, pero la flag `festival_activo` (que desbloquea `puerto_festival`) **no la emite nadie**: no aparece en ningún script, sólo en el dataset → **dueño M74/M71**.
- [?] **M69 comparte 0 estaciones** (ver hallazgo arriba) → **dueño M69**.
- [?] **Tercer idioma.** Sólo existen `es.po` y `en.po` (`LOCALES_SOPORTADOS := ["es","en"]` en M87). Las 89 claves de M68 están en ambos; probar en 3 idiomas requiere que M87 añada el tercero → **dueño M87**.
- [ ] **Carteles (M46), capa de mapa (M54), panel (M53), docking y animaciones (M48/M64)** y los ciclos visuales completos: fuera del alcance headless.

### 14. Trampas encontradas y resueltas en la iter. 2

- **Falso verde por aborto silencioso (M124) confirmado en vivo.** Al dejar un `Identifier not declared` en `validate_transport.gd`, el **bloque G entero se saltó** y la suite igual imprimió `169 checks, 0 fallos`. Solución adoptada: cada bloque registra su letra en `_fin()` y `_summary()` **falla** si falta alguna (`"los 8 bloques se completaron"`). **Se verificó la guarda con una sonda**: inyectando un aborto en el bloque C la suite pasa a `FALLÓ — bloques que no terminaron: ["C"]`.
- **`Array` genérico no entra en un parámetro `Array[String]`.** `contexto.get("locales", ["es","en"])` devuelve un `Array` sin tipar; pasarlo a `validar_localizacion(locales: Array[String])` da *"does not have the same element type as the expected typed array argument"*. `validar_localizacion` ahora recibe `Array` y convierte.
- **Traducción incompleta silenciosa.** `nombre_ruta()` en inglés seguía devolviendo los nombres en español porque `nombre_parada()` sólo miraba los `.po` (que aún no tenían las claves) y caía al `nombre_fallback` español. Ahora consulta también `NOMBRES_EN` antes del fallback. Se detectó comparando `es` vs `en` en el catálogo generado (13 claves idénticas: sólo plantillas, moneda y formato).
- **Claves plurales contadas como "texto vacío".** El lector `.po` metía las claves plurales en `mensajes` con `msgstr ""` → `claves_vacias()` daba falsos positivos. Ahora las plurales viven **sólo** en `plurales`.
- **Escapes `\n`/`\t` destrozados por Git Bash.** Un `python -c "..."` con `\n`/`\t` produjo `/n/t` dentro del archivo escrito (la sonda quedó con `if true:/n/t/treturn`). Solución: construir los caracteres con `chr(10)`/`chr(9)` en vez de escapes.

### 15. Comandos

```bash
# iter. 1 (regresión): 177 checks
Godot --headless --path game/isla-ancestral --script res://scripts/transporte/test_transporte_m68.gd
# iter. 2: 199 checks
Godot --headless --path game/isla-ancestral --script res://scripts/transporte/test_transporte_m68_iter2.gd
# regenerar el catálogo de localización y aplicarlo a los .po
Godot --headless --path game/isla-ancestral --script res://scripts/transporte/dump_locales_m68.gd
python scripts/aplicar_locales_m68.py
```

### 16. Recomendaciones para el próximo agente

- **M07:** declarar `TRIP_FINISHED` en `EventBus` (sigue pendiente desde la iter. 1).
- **M21:** crear los grafos de diálogo de `M68.NARR.*` — el contrato ya los pide.
- **M74/M71:** emitir la flag `festival_activo` al abrir el festival para que `puerto_festival` sea alcanzable de verdad.
- **M69:** re-anclar sus 4 anclas sobre paradas de M68 (o declararlas fuera de la red) — hoy son huérfanas.
- **M46/M53/M54:** consumir `TransportManager.red()`, `list_routes()` y `TransportLocalizer` (nunca duplicar la red).
- **Si se cambian costes o paradas:** editar `generar_red_transporte.gd` y **regenerar** el `.tres`. Ojo: la regla "directo > combinado" **no** es universal (ver §11) — no la conviertas en invariante.
- **Si se añaden claves de localización:** añadirlas a las tablas de `TransportLocalizer`, volver a volcar y aplicar. El test comprueba que no falte ninguna en `es` ni en `en`.
