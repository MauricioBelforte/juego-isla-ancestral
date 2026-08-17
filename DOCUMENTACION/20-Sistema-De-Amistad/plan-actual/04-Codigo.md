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