**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

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