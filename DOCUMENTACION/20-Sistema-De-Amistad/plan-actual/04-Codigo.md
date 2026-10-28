**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

# 04-Codigo.md — Módulo 20: Sistema de Amistad

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/amistad/friendship_service.gd` | Autoload | Autoridad unica: puntos, niveles, limites diarios, senales, log DOM-AMISTAD |
| `res://src/amistad/gift_evaluator.gd` | Clase estatica | Evaluacion pura de regalos (gustos M19 + metadatos M14) |
| `res://src/amistad/friendship_level.gd` | Resource | Definicion de nivel: umbral, nombre, recompensas |
| `res://src/amistad/friendship_event.gd` | Resource | Definicion de evento: requisitos, franja, lugar, participantes |
| `res://src/amistad/vecino_data.gd` | Resource | Datos de gustos/personalidad del vecino (consumido de M19, de solo lectura) |
| `res://src/amistad/cartas.gd` | Componente | Correspondencia: bandeja, respuestas, adjuntos de retorno |
| `res://src/amistad/persistencia_amistad.gd` | Util | Serializacion/deserializacion del estado (schema M26) |
| `res://data/amistad/niveles.tres` | Data | Tabla de niveles 0-10 con recompensas |
| `res://data/amistad/eventos/*.tres` | Data | Eventos convocables (picnic, reunion, cumpleanos, visita) |
| `res://data/amistad/cartas/*.tres` | Data | Textos de cartas y respuestas por vecino |

## 2. Firmas clave (GDScript, Godot 4.x)

```
# friendship_service.gd
class_name FriendshipService extends Node
@onready var _estado: Dictionary = {}              # vecino_id -> estado_amistad
@export var _data_niveles: Array[FriendshipLevel]
@export var _data_eventos: Array[FriendshipEvent]

func _registrar_vecino(vecino_id: String, data: VecinoData) -> void
func get_nivel(vecino_id: String) -> int
func get_puntos(vecino_id: String) -> int
func get_puntos_para_siguiente(vecino_id: String) -> int
func get_progreso(vecino_id: String) -> float
func _usado_hoy(vecino_id: String, tipo: String) -> bool          # segun M29
func regalar(vecino_id: String, item_id: String) -> Dictionary
func charlar(vecino_id: String) -> Dictionary
func enviar_carta(vecino_id: String, texto_id: String, adjunto_id: String = "") -> bool
func _aplicar_puntos(vecino_id: String, puntos: int, fuente: String) -> void
func _comprobar_subida(vecino_id: String) -> void
func _entregar_recompensas(vecino_id: String, nivel: int) -> Array[String]
func celebrar_evento(evento_id: String) -> Dictionary
func get_memoria(vecino_id: String) -> Array[Dictionary]
func get_recompensas_pendientes() -> Array[Dictionary]
func reclamar_recompensa(uid: String) -> Dictionary
func _loguear(evento: String, datos: Dictionary) -> void

# gift_evaluator.gd
class_name GiftEvaluator
static func evaluar(vecino: VecinoData, item: ItemData) -> Dictionary

# friendship_level.gd
class_name FriendshipLevel extends Resource
@export var nivel: int
@export var puntos_necesarios: int
@export var nombre: String
@export var recompensas: Array[RewardData]

# friendship_event.gd
class_name FriendshipEvent extends Resource
@export var id: String
@export var tipo: String
@export var nivel_minimo: int
@export var dia_semana: int
@export var hora: Vector2
@export var lugar_id: String
@export var puntos_otorgados: int
@export var participantes: Array[String]

# persistencia_amistad.gd
static func serializar(estado: Dictionary) -> Dictionary
static func deserializar(data: Dictionary) -> Dictionary
static func actualizar_schema(datos_guardados: Dictionary) -> Dictionary   # migracion
```

## 3. Logs relacionados

- **DOM-AMISTAD** (`Logs/aplicacion.log`, rotacion section 18): se registra cada `regalar`, `charla_realizada`, `carta_enviada`/`carta_recibida`, `nivel_subido`, `evento_celebrado`, fallos de persistencia y migraciones de schema.
- Formato de linea: `[DOM-AMISTAD] <fecha M29> <vecino_id> <accion> <puntos> <nivel_resultante>`.
- En release los `Debug.log` se desactivan (conditional symbols, seccion 22 de AGENTS.md).

## 4. Suscripciones e integracion

- M29 (Reloj): `nuevo_dia` -> resetear `usado_hoy`, madurar cartas pendientes, verificar eventos de fecha.
- M21 (Dialogos): `dialogo_abierto(vecino_id)` / senales de M20 para frases por nivel y reacciones del evaluador.
- M14 (Inventario): `item_removido(item_id)` al regalar; `item_agregado` al entregar recompensas.
- M26 (Guardado): `pre_save` -> `serializar`; `post_load` -> `deserializar` + `actualizar_schema`.
- M73 (Festivales): `festival_iniciado` -> ofrecer eventos convocables y cumpleanos sin limite diario.

## 5. Pendientes de implementacion (dueno: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| FriendshipService + evaluador + niveles | Requiere M19 (VecinoData) y M14 (ItemData) |
| Tabla de niveles y eventos en `.tres` | Data; prototipo con 3 niveles y 4 eventos |
| Cartas y bandeja de recompensas | Con buzon/correo de UI (otra capa) |
| Persistencia con schema versionado | Con M26 |
| Tests y QA M114 | Regalos, limites, excedente, sin FOMO |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 12:00:00
**Estado:** Documentacion de diseno completa (modulo delegable; bloqueado por M19 y M14)

### Lo que hice
- 26/26 puntos de la seccion 19 del plan maestro resueltos (amistad).
- Sistema acumulativo sin decaimiento, limites diarios por vecino (M29), recompensas por nivel, cartas y eventos con amigos.
- Contratos GDScript completos y reglas de balanceo de puntos.

### Lo que NO hice (honestidad obligatoria)
- Implementar: requiere M19 (VecinoData con gustos) y M14 (ItemData con metadatos). Dueno: AGENTE DELEGADO.
- Data de cartas y textos pendiente de escritura narrativa (M21).

### Recomendaciones para el proximo agente
- El evaluador debe ser puro y determinista (solo datos); el azar se reserva a variantes decorativas de respuesta.
- Probar primero el flujo regalo->puntos->nivel con 3 vecinos de ejemplo.
- Validar que el excedente de puntos al subir de nivel no se pierde.

---

## 6. Implementacion actual (M20 + M29) — 2026-08-30, WorkBuddy

> Nota: las rutas y firmas de las secciones 1-2 son el diseno original (algunas
> divergen de la implementacion real). Lo siguiente documenta el estado real.

### 6.1 Archivos reales

| Archivo | Rol |
|---|---|
| `res://scripts/friendship/friendship_service.gd` | Autoload `Friendship` (sin `class_name` a proposito). Unica autoridad de amistad; consume M29. |
| `res://scripts/friendship/vecino_amistad.gd` | `class_name VecinoAmistad` (RefCounted): puntos, nivel, limites diarios, recuerdos, serializacion. |
| `res://scripts/friendship/gift_evaluator.gd` | `class_name GiftEvaluator`: evaluacion pura de regalos. |
| `res://scripts/core/event_bus.gd` | `EventBus.npc`: `cumpleanos(npc_id, edad)` y `carta_recibida(npc_id, respuesta_id)` (nuevas). |
| `res://data/amistad/cumpleanos.json` | 10 NPCs: `vecino_id, nombre, mes(1-12), dia(1-28), edad_base`. Data-driven (sync desde M19 despues). |
| `res://data/amistad/cartas.json` | Plantillas `CARTA_GENERICA`, `CARTA_GRACIAS` (adjunto `FLOR_SILVESTRE`), `CUMPLEANOS` (adjunto `PASTEL`). |
| `res://scripts/friendship/test_amistad_eventos.gd` | Test headless de cumpleanos + cartas (28/28 OK). |

### 6.2 Cumpleanos (logica M29)

- `es_cumpleanos_hoy(vid)`: mes/dia vs espejo de calendario (`_mes`, `_dia_mes`).
- `proximo_cumpleanos(vid)`: dias hasta el proximo (wrap +336 al ano siguiente, cozy: nunca expira). Edad = `edad_base + maxi(0, anio-1)`.
- `regalar_en_cumpleanos(vid, item)`: usa limite propio `"cumpleanos"` (NO consume `"regalo"`), +`BONUS_CUMPLEANOS_REGALO` (5).
- `celebrar_cumpleanos(vid)`: +`PUNTOS_CUMPLEANOS` (15), una vez por ano (`_anio_cumpleanos`), sin penalizacion si se omite.
- `_verificar_cumpleanos_hoy()` (en `_procesar_nuevo_dia`): emite `cumpleanos_hoy` signal + `EventBus.npc.cumpleanos` (idempotente por dia via `_cumpleanos_anunciados`) y el NPC envia carta `CUMPLEANOS` a la bandeja.

### 6.2b Sincronizacion de cumpleanos desde M19 (2026-08-30, WorkBuddy)

- M20 **CONSUME** M19: los cumpleanos son la fuente de verdad en `VillagerProfile`
  (`scripts/npc/villager_profile.gd`, campos `@export cumpleanos_mes`, `cumpleanos_dia`,
  `edad_base`; 0 = sin fecha). No se acopla M19 -> M20.
- `VillagerProfile` gano los 3 campos; `data/villagers/catalina_oso.tres` poblado
  (Catalina: 6/14, edad_base 29).
- `FriendshipService` extrae vía `_cumpleanos_desde_perfil(perfil)` (duck-typing por
  `has_method("evaluar_objeto")`, omite perfiles sin fecha) y `set_cumpleanos_desde_perfil`
  fusiona sobre el seed `data/amistad/cumpleanos.json` (override por `id`).
- `sincronizar_cumpleanos_desde_m19()`: itera `VillagerManager.obtener_activos()` y tira de
  `obtener_perfil()`. Se invoca en `_ready()`, en `_procesar_nuevo_dia()` (frescura diaria)
  y al conectar `VillagerManager.poblacion_cambio` (villager que se muda hoy).
- Test: `test_amistad_eventos.gd` `_test_sincronizar_cumpleanos_m19()` (35/35 OK).

### 6.3 Cartas (respuesta diferida M29)

- `enviar_carta(vid, texto_id, adjunto_id="")`: 1/dia (limite `"carta"`); guarda pendiente con `dia_envio`.
- `_madurar_cartas()` (en `_procesar_nuevo_dia`): las enviadas en dias anteriores se responden hoy → +`PUNTOS_CARTA` (8), entrega `adjunto_retorno`, emite `carta_recibida` + `EventBus.npc.carta_recibida`.
- `_recibir_carta_npc(vid, plantilla_id)`: carta que el NPC envia al jugador (p.ej. cumpleanos), entra directo a recibidas.
- `get_bandeja(vid)`, `get_cartas_pendientes(vid)`, `get_cartas_pendientes_total()` para UI.

### 6.4 Integracion M29

- `_calendario()` devuelve `TimeCalendar` (M29) o `GameClock` (M30) por `dia_absoluto()` (monotono; robusto al paso de mes/ano).
- Punto unico de avance de dia: `_procesar_nuevo_dia()` (cumpleanos + maduracion de cartas), invocado desde `dia_cambio`.
- `pivote_fecha(dia_absoluto, mes, dia, anio)` para tests/fallback sin arbol.

### 6.5 Persistencia (ISaveProvider M59)

- `get_save_data()` / `restore_save_data()` incluyen vecinos, cartas (pendientes/recibidas), `anio_cumpleanos`, `cumpleanos_anunciados`, espejo de calendario.
- `_registrar_como_proveedor_guardado()` conecta con `SaveManager.register_provider(self)` (guarda fuera del arbol).

### 6.6 Verificacion

- `godot --headless --path game/isla-ancestral --script res://scripts/friendship/test_amistad.gd` → 14/14 OK (logica base).
- `godot --headless --path game/isla-ancestral --script res://scripts/friendship/test_amistad_eventos.gd` → 44/44 OK (cumpleanos + cartas M29 + sync M19 + gustos reales + niveles .tres).

### 6.7 Gustos reales desde M19 (2026-08-30, WorkBuddy)

- **Bug de diseno cerrado:** `_get_vecino_data()` devolvia `null` => todos los regalos
  salian NEUTRAL y el sistema IGNORABA gustos/disgustos de M19. Ahora M20 los consume.
- `VillagerProfile` se cachea por `vecino_id` en `_perfiles` (dentro de
  `set_cumpleanos_desde_perfil`, SIEMPRE, aunque no tenga cumpleanos definido).
- `_get_vecino_data(vid)` devuelve `{gustos, disgustos}` del perfil cacheado (o `{}` si no
  hay perfil => NEUTRAL). Alimenta `GiftEvaluator.evaluar(vecino_data, item_meta, ya_regalado)`.
- `GiftEvaluator` resuelve AMADO (`regalos_amados`) / GUSTA (`gustos`) / NEUTRAL (`disgustos`
  o ajeno; cozy: un disgusto baja a NEUTRAL, NUNCA castiga) / DUPLICADO. M20 ahora respeta
  preferencias reales de M19.
- **Pendiente como campo en M19:** `regalos_amados` (para clase AMADO) y `personalidad` aun no
  existen en `VillagerProfile`; cuando se agreguen, `GiftEvaluator` los usara sin tocar M20.
- Test: `test_amistad_eventos.gd` `_test_gustos_reales_m19()` (5 checks).

### 6.8 Niveles en .tres (2026-08-30, WorkBuddy)

- `scripts/friendship/amistad_config.gd` (`class_name AmistadConfig`, `extends Resource`) +
  `data/amistad/amistad_config.tres`: `umbrales: Array[int]` (11 niveles: 0..500) y
  `recompensas_nivel: Dictionary` (reward_ids por nivel). Editable en el inspector sin codigo.
- `FriendshipService._cargar_config()` carga el .tres en `_ready` y lo inyecta en cada
  `VecinoAmistad` (`v.umbrales = _umbrales`); fallback a const `UMBRALES` / `RECOMPENSAS_NIVEL`
  si el .tres falta o falla (el juego sigue funcionando). `_recompensas` reemplaza el const en
  los 5 `aplicar_puntos(...)`.
- `VecinoAmistad.umbrales` (var, default = const `UMBRALES`) reemplaza el const hardcodeado en
  `aplicar_puntos` / `get_progreso` / `deserializar`.
- Test: `test_amistad_eventos.gd` `_test_niveles_config()` (4 checks).

### 6.9 Reaccion M21 — clase exacta de regalo (2026-08-30, WorkBuddy)

- **Contrato:** `EventBus.npc.gift_given(npc_id: String, item_id: String, clase: int)`.
  La `clase` es `GiftEvaluator.Clase` (AMADO/GUSTA/NEUTRAL/DUPLICADO). Antes solo llevaba
  `liked: bool`; M21 no podia reaccionar por clase.
- `FriendshipService._emitir_npc_events(vecino_id, item_id, clase)` emite `gift_given` con la
  clase calculada por `GiftEvaluator` (no la colapsa a bool). No habia suscriptores previos de
  `gift_given` → cambio de firma seguro.
- **Puente M21 → M20 (ya existia, verificado en vivo):** `WorldStateService` (M21) resuelve
  `amistad_<npc_id>` delegando en `Friendship.get_nivel(npc_id)` (`_get_amistad`). Las variantes
  de dialogo por nivel de amistad (05-Checklist L58) funcionan por delegacion en tiempo real.
- Verificacion: `test_amistad_eventos.gd` `_test_reaccion_m21()` — firma de 3 args, emision de
  clase GUSTA y NEUTRAL exactas, y `WorldStateService.amistad_R_M21_WS == nivel vivo M20`.

### 6.10 DOM-AMISTAD — log centralizado con rotacion (2026-08-30, WorkBuddy)

- `FriendshipService` mantiene `const LOG_CAP := 100` y `var _eventos: Array` (sin UI).
- `registrar_evento(tipo, npc_id, detalle, clase=-1)`: append + `pop_front` mientras
  `size() > LOG_CAP` (rotacion: se descartan los mas antiguos). `clase` = `GiftEvaluator.Clase`
  cuando aplica, `-1` si no.
- `get_eventos()` (copia) y `get_eventos_npc(npc_id)` (filtrado por vecino) para UI/notificaciones.
- Sitios de llamada: `regalar` (regalo + nivel), `regalar_en_cumpleanos` (regalo_cumpleanos +
  nivel), `celebrar_cumpleanos` (cumpleanos), `charlar` (nivel), `_madurar_cartas`
  (carta_recibida + nivel), `_recibir_carta_npc` (carta_npc).
- Persistencia: `get_save_data()` incluye `"eventos"`; `restore_save_data()` repuebla `_eventos`
  con guarda de cap (compatible con ISaveProvider M59).
- Verificacion: `test_amistad_eventos.gd` `_test_dom_amistad()` — registro, filtrado por NPC,
  tipos (regalo/nivel/cumpleanos/carta_npc), rotacion cap 100, y persistencia tras restore.

> **Pendiente honesto (fuera de este cierre):** 05-Checklist L82 — escenas breves de evento
> con dialogos de los vecinos (M21). El hook de datos (clase + nivel en vivo) esta listo; falta
> el contenido de escenas/dialogos, que es alcance de M21.

---

## 7. Cierre de cobertura M20 — 2026-10-27, minimax-m3-1-flash (Kilo Code)

### 7.1 Suite nueva de cobertura (15 checks, verde)

| Archivo | Rol |
|---|---|
| `res://tests/test_m20_amistad_cobertura.gd` | Suite de cobertura de los items `[ ]` de M20 verificables en headless. Vive en `res://tests/` → la descubre el runner central (M112) automaticamente. |

```
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://tests/test_m20_amistad_cobertura.gd
→ === Resumen: 15 checks, 0 fallos ===   (M20 COBERTURA OK)
```

Checks (nombre = texto del item que cierra, criterio estricto del Log 2124):

1. `el indice de vecinos por id es un Dictionary (consultas O(1))` → item 173.
2. `indice de vecinos por id: 20 vecinos registrados se consultan por id (O(1))` → item 173.
3. `bandeja de recompensas bajo demanda: no hay recompensa pendiente antes de subir de nivel` → item 175.
4. `bandeja de recompensas bajo demanda: al subir de nivel la recompensa queda pendiente` → item 175.
5. `bandeja de recompensas bajo demanda: la consulta devuelve copia (no refresco continuo)` → item 175.
6. `reclamar recompensa: se retira de la bandeja y no se puede reclamar dos veces` → item 175.
7. `dia 100: la charla del dia se permite` / `dia 100: la segunda charla del mismo dia se rechaza por limite diario` → item 167.
8. `medianoche (dia 101): el limite diario se recalcula y la charla vuelve a estar disponible` → item 167.
9. `guardado corrupto del modulo: fallback a estado vacio sin crash` → item 168.
10. `guardado corrupto del modulo: valores por defecto sin crash (puntos 0, nivel clamp 10)` → item 168.
11. `vecinos nuevos agregados al schema sin romper guardados previos (estado previo intacto)` → item 156.
12. `extraccion del item al regalar integrada: el item sale del inventario al regalar` → item 134 (M14 real).
13. `inventario vacio: regalar se rechaza con aviso sin_item (no se extrae nada)` → item 163 (parte de servicio).
14. `adjuntos de carta usados correctamente: el adjunto se consume del inventario al enviar` → item 137.
15. `adjuntos de carta recibidos correctamente: el adjunto de retorno llega al inventario al responder` → item 137.
16. `progress visible: barra de progreso dentro del nivel actual (en_nivel, ancho, progreso)` → item 37.
17. `coste de evaluacion menor a 1 ms por regalo (medido 0.0025 ms en 2000 evaluaciones)` → item 53.
18. `recorrido M114: 10 vecinos a nivel 5+ en sesiones simuladas sin fallos` → item 205.

La suite usa el `InventarioService` real (autoload `Inventario` o una instancia propia si el
autoload no existe) y **restaura el inventario al terminar** (`_restaurar_inventario`), para no
dejar basura en el save del jugador.

### 7.2 Items cerrados (19)

Documentacion (verificados contra disco): problema (L8), dependencias (L9), catalogo de los 26
puntos de §19 (L10, nuevo `01-Requerimientos.md` §6), decision Alternativa B (L95) y los 5
archivos de `plan-actual/` creados y firmados (L209-L213).

Codigo (con check nombrado): L37, L53, L134, L137, L156, L167, L168, L173, L175, L205.

### 7.3 Deuda detectada (NO se inflaron los items)

| Item | Hallazgo | Referencia |
|---|---|---|
| L30 | No existe tabla de nombres de nivel ("Conocido"/"Amigo"/"Confidente"/"Mejor amigo"): 0 hits en `scripts/` y `data/`. | `data/amistad/amistad_config.tres` solo tiene `umbrales` + `recompensas_nivel` |
| L77 / L78 | `FriendshipEvent` sigue sin existir (0 hits) y los 5 tipos convocables tampoco. Solo hay el evento de cumpleaños. | re-verificado 2026-10-27 |
| L124 | `_vecino()` CREA el vecino bajo demanda → un vecino "no registrado" sí existe en el servicio tras cualquier consulta. El item, tal como está escrito, no se cumple. | `friendship_service.gd` L269-274 |
| L154 | El save de M20 no lleva `schema_version` (`data/balance/friendship.json` sí lo tiene, pero es data de balance). | `friendship_service.gd` L630-650 |
| L163 | El servicio ya devuelve `sin_item`, pero la UI (opción deshabilitada + tooltip) no existe. **BUG:** el límite diario "regalo" se consume ANTES de validar el inventario → un regalo fallido por inventario vacío quema el límite del día. | `friendship_service.gd` L513 vs L515-519 |
| L164 | `enviar_carta()` no valida `texto_id` (admite `""` e ids inexistentes en `cartas.json`). | `friendship_service.gd` L423-435 |
| L191 / L60 | Los recuerdos se crean (`primer_regalo:<item>`, `cumpleanos_anio_N`) y los consumen `event_manager.gd` (M74) y `tutorial_manager.gd`, pero **ninguna línea de diálogo del vecino (M21) los menciona** (0 hits de `get_recuerdos` en `scripts/dialogos/`). | Deuda cruzada M20 ↔ M21 |
| L142 / L143 | M20 expone el dato (`get_nivel`, `get_memoria`, `get_recuerdos`) pero ninguna misión lo consulta todavía. | Deuda cruzada M20 ↔ M23 |

### 7.4 Hallazgos cross-module (para el director / dueños M162-M21)

1. **Escala de `amistad_<npc_id>` incompatible entre M20 y M162.**
   `WorldStateService._get_amistad()` (`scripts/dialogos/world_state_service.gd` L102-106)
   devuelve `Friendship.get_nivel(npc_id)` → un **nivel** (1..11; `UMBRALES` llega a 500 puntos
   y 11 niveles). Pero `data/dialogues/contextual/registry.json` usa condiciones
   `amistad_<npc> >= 60` y `>= 90` (variantes `amistad60` / `amistad90`), y
   `scripts/dialogos/contextual_dialogue_manager.gd` L16 documenta "amistad_<slug> (int 0-100)".
   Con el nivel real (máx. 11) esas variantes **nunca se disparan**; el test de M162
   (`test_contextual_dialogue_m162.gd` L125-136) pasa porque inyecta `amistad_riz_001: 60` a mano.
   Decidir escala (nivel vs 0-100) es una decisión de contrato entre M20 y M162/M21.
2. **Deriva de umbrales de balance.** `data/balance/friendship.json` declara
   `umbrales.nivel_2=30, nivel_3=70, nivel_4=120, nivel_5=150, nivel_8=260`, mientras la
   configuración realmente inyectada (`data/amistad/amistad_config.tres`, cargada por
   `_cargar_config()`) usa `20/40/70/100/140/190/250/320/400/500`. El JSON de balance no es la
   fuente de verdad en runtime → dos números de balance que no coinciden en el mismo módulo.

### 7.5 CI (M112): timeout flake del pool y reintento en serie

**Evidencia (dos corridas del runner central el 2026-10-27, misma máquina, Godot 4.7.2):**

| Corrida | Suites | Resultado | Suite que colgó (TIMEOUT 300 s) |
|---|---|---|---|
| A (con la suite M20 nueva) | 51 (47 SceneTree + 4 GdUnit4) | 50 OK / 1 FAIL | `res://tests/test_m166_h12_variantes.gd` |
| B (SIN la suite M20 nueva) | 50 (46 SceneTree + 4 GdUnit4) | 49 OK / 1 FAIL | `res://tests/unit/data/test_item_data.gd` |

En ambas, la suite que colgó **pasa en < 10 s en serie** (verificado enIsolation), y el timeout
cambia de suite entre corridas → es **contención del pool** (6 workers) sobre la salida final del
motor (deinit de Voxel Tools), que todas las suites pagan al arrancar los autoloads
(`Bootstrap` carga `main_island.tscn`), no un fallo de ninguna suite.

**Fix aplicado** (`res://tests/run_tests.gd`, `_correr_scenetree`): si una suite da TIMEOUT
**dentro del pool**, se **re-mide en serie** antes de declararla fallida. El reintento NO tolera
fallos reales (si la suite vuelve a fallar, el fallo se reporta igual); solo re-mide el TIMEOUT,
que es un artefacto de contención. Documentado en la cabecera del runner (punto 5).

**Pendiente de M112 (no tocado):** el tiempo total del CI quedó en ~872-878 s, por encima del
presupuesto de 600 s (la lane voxel son 6 suites × ~72 s). No es de M20.

### 7.6 BUG M20: el límite diario se consumía antes de validar el inventario (corregido)

**Routeo:** la directora `agnes-3-flash` (canal MiniMax #059) detectó el bug y lo asignó a M20
(dueño: MiniMax). Regresión de gameplay: con el inventario vacío, el jugador hacía un regalo,
recibía `sin_item` y **ya no podía volver a regalar ese día** (el límite "regalo" = 1/día se
había quemado en el intento fallido).

**Causa raíz** (`res://scripts/friendship/friendship_service.gd`, `func regalar`):
el orden era *consumir límite → validar inventario*. Con `remover_items()` en modo todo-o-nada,
el fallo `sin_item` devolvía el control **sin devolver el límite**.

**Fix (3 call sites + 1 primitiva nueva):**

| Archivo | Cambio |
|---|---|
| `res://scripts/friendship/vecino_amistad.gd` | Nueva primitiva `devolver_limite(tipo)` (descuenta 1 uso del límite diario del día). |
| `res://scripts/friendship/friendship_service.gd` `regalar()` | Si `remover_items()` falla → `v.devolver_limite("regalo")` antes de devolver `sin_item`. |
| `res://scripts/friendship/friendship_service.gd` `regalar_en_cumpleanos()` | Ídem con el límite propio `"cumpleanos"` (que va aparte del `"regalo"`). |
| `res://scripts/friendship/friendship_service.gd` `enviar_carta()` | Adjunto inexistente → `devolver_limite("carta")`; además **valida `texto_id` antes de consumir el límite**: `texto_id == ""` → `texto_vacio`; `texto_id` inexistente en `data/amistad/cartas.json` → `texto_invalido`. Nuevo helper privado `_hay_item_para_regalo(inv, item_id)` (consulta `count_item(item_id, true)` = bolsa+mochila+casa, igual que `remover_items`). |

**Suite de regresión nueva:** `res://tests/test_m20_limite_regalo.gd` → **19 checks, 0 fallos,
EXIT 0** (Godot 4.7.2 headless). Checks nombrados (texto literal en el log):

1. "regalo rechazado por falta de item: se avisa sin_item y no se entrega nada"
2. "regalo rechazado por falta de item NO consume el limite diario de regalo"
3. "regalo valido del mismo dia tras el fallo: se acepta (limite conservado)"
4. "carta con adjunto inexistente: se rechaza con sin_adjunto"
5. "carta con adjunto inexistente NO consume el limite diario de carta"
6. "carta valida del mismo dia tras el fallo: se envia (limite de carta conservado)"
7. "carta sin texto seleccionado (texto_id vacio): se rechaza con texto_vacio"
8. "carta sin texto no consume el limite diario de carta"
9. "carta con texto_id inexistente en data: se rechaza con texto_invalido"
10. "carta con texto_id inexistente no consume el limite diario de carta"
11. "carta con texto_id valido tras los rechazos: se envia (limite de carta conservado)"
12. "cumpleanos: la fecha de prueba coincide con el cumpleanos del vecino"
13. "regalo de cumpleanos rechazado por falta de item: se avisa sin_item"
14. "regalo de cumpleanos fallido NO consume el limite diario de cumpleanos"
15. "regalo de cumpleanos valido tras el fallo: se acepta (limite conservado)"
16. "regalo de cumpleanos NO consume el limite diario de regalo"
17. "regalo valido: el limite diario de regalo queda consumido (usado=1)"
18. "segundo regalo del mismo dia: se rechaza con limite_diario"
19. "dia siguiente: el limite diario de regalo se reinicia y el regalo se acepta"

**Prueba rojo-verde (guardianía):**

| Escenario | Resultado |
|---|---|
| Suite sin el fix (`devolver_limite` ausente) | **14 checks / 6 fallos / EXIT 1** — el guardián detecta el bug |
| Suite sin la validación de `texto_id` | **19 checks / 5 fallos / EXIT 1** |
| Suite con el fix completo | **19 checks / 0 fallos / EXIT 0** |

**Regresión (todas verdes, EXIT 0):** `scripts/friendship/test_amistad.gd` 14/0 ·
`scripts/friendship/test_amistad_eventos.gd` 53/0 · `scripts/friendship/test_amistad_rf48_m20.gd`
12/0 · `scripts/friendship/test_ciclo_amistad_m20_hy3.gd` 30/0 · `tests/test_m20_amistad_cobertura.gd`
15/0 · `tests/test_m20_limite_regalo.gd` 19/0.

**Nota de compatibilidad:** `scripts/friendship/test_ciclo_amistad_m20_hy3.gd` (suite de Hy3)
codificaba por accidente el comportamiento con bug (el primer regalo fallaba por falta de `PIEDRA`
en el inventario y el segundo se rechazaba con `limite_diario`). Se ajustó **solo** para que el
primer regalo sea determinista (se asegura `PIEDRA` en el inventario antes de regalar); el caso
negativo que la suite quiere probar (2º regalo del mismo día → `limite_diario`) se mantiene
intacto. No se cambió ninguna aserción de fondo de la suite de Hy3.

**CI:** la suite nueva queda cableada en `.github/workflows/quality.yml` (job `test-suite`, lane
M20) junto a las otras 4 de M20; el runner central M112 (`tests/run_tests.gd`) también la
descubre por estar en `res://tests/`.
