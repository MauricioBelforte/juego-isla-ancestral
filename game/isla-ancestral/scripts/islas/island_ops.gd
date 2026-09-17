# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M27: Islas del Mundo — IslandOps (iter. 2).
#
# Cola de operaciones de isla (carga / descarga / precarga) con estados,
# prioridad estable, progreso por pesos y cancelación limpia.
#
# Lógica PURA: no toca escena, no toca disco, no depende de ningún autoload.
# El bloque E del checklist (`IslandLoading` real, sobre el streaming de M63)
# sigue siendo de M63; esto es la ORQUESTACIÓN verificable que M28 (viaje) y
# M63 (streaming) pueden consumir sin acoplarse.
#
# Uso:
#   var ops := IslandOps.new()
#   var op: int = ops.encolar(IslandOps.TIPO_CARGA, &"coral")
#   ops.iniciar()
#   while ops.esta_ocupada():
#       ops.avanzar_etapa()

class_name IslandOps
extends RefCounted

# ── Tipos de operación ────────────────────────────────────────────────────
const TIPO_CARGA: StringName = &"carga"
const TIPO_DESCARGA: StringName = &"descarga"
const TIPO_PRECARGA: StringName = &"precarga"
const TIPOS: Array[StringName] = [TIPO_CARGA, TIPO_DESCARGA, TIPO_PRECARGA]

# ── Estados ───────────────────────────────────────────────────────────────
const EST_PENDIENTE: StringName = &"pendiente"
const EST_EN_CURSO: StringName = &"en_curso"
const EST_HECHA: StringName = &"hecha"
const EST_CANCELADA: StringName = &"cancelada"
const EST_FALLIDA: StringName = &"fallida"
const ESTADOS_CERRADOS: Array[StringName] = [EST_HECHA, EST_CANCELADA, EST_FALLIDA]

# ── Progreso por pesos (03-Diseno §2, flujo F2) ───────────────────────────
## Etapas de una carga, en orden. Los pesos suman 1.0 (lo verifica validar()).
const ETAPAS: Array[String] = ["losa", "props", "audio", "navmesh"]
const PESOS: Array[float] = [0.60, 0.25, 0.10, 0.05]

# ── Prioridad: número MENOR = antes ───────────────────────────────────────
## Una carga pedida por el jugador (viaje) gana siempre a una precarga de fondo.
const PRIORIDAD_VIAJE: int = 0
const PRIORIDAD_CARGA: int = 1
const PRIORIDAD_DESCARGA: int = 2
const PRIORIDAD_PRECARGA: int = 3

## Presupuesto de "no congelar el frame": cuántas operaciones puede arrancar el
## llamador por frame. Con 1, la cola nunca monopoliza el frame (K1 del
## checklist: "carga de isla vecina mientras el jugador navega el borde").
const MAX_OPS_POR_FRAME: int = 1

var _ops: Array[Dictionary] = []
var _historial: Array[Dictionary] = []
var _siguiente_id: int = 1
var _en_curso: int = 0


# ── API estática ──────────────────────────────────────────────────────────

static func suma_pesos() -> float:
	var total: float = 0.0
	for p in PESOS:
		total += p
	return total


## Progreso acumulado [0,1] al terminar la etapa `indice` (0 = losa).
## `indice` -1 (antes de empezar) devuelve 0.0.
static func progreso_hasta(indice: int) -> float:
	if indice < 0:
		return 0.0
	var total: float = 0.0
	var tope: int = mini(indice, PESOS.size() - 1)
	for i in range(tope + 1):
		total += PESOS[i]
	return clampf(total, 0.0, 1.0)


static func etapa_nombre(indice: int) -> String:
	if indice < 0 or indice >= ETAPAS.size():
		return ""
	return ETAPAS[indice]


static func es_tipo_valido(tipo: StringName) -> bool:
	return TIPOS.has(tipo)


static func es_estado_cerrado(estado: StringName) -> bool:
	return ESTADOS_CERRADOS.has(estado)


static func prioridad_por_defecto(tipo: StringName) -> int:
	match tipo:
		TIPO_CARGA:
			return PRIORIDAD_CARGA
		TIPO_DESCARGA:
			return PRIORIDAD_DESCARGA
		TIPO_PRECARGA:
			return PRIORIDAD_PRECARGA
		_:
			return PRIORIDAD_PRECARGA


# ── Encolar ───────────────────────────────────────────────────────────────

## Encola una operación y devuelve su id (>0). Devuelve 0 si el tipo o la isla
## son inválidos. Es IDEMPOTENTE: si ya hay una operación viva del mismo tipo
## sobre la misma isla, devuelve el id de esa operación en vez de duplicarla.
func encolar(tipo: StringName, isla_id: StringName, prioridad: int = -1) -> int:
	if not es_tipo_valido(tipo):
		return 0
	if str(isla_id).is_empty():
		return 0
	for op in _ops:
		if op["tipo"] == tipo and op["isla"] == isla_id:
			return int(op["id"])
	var prio: int = prioridad if prioridad >= 0 else prioridad_por_defecto(tipo)
	var op: Dictionary = {
		"id": _siguiente_id,
		"tipo": tipo,
		"isla": isla_id,
		"prioridad": prio,
		"estado": EST_PENDIENTE,
		"etapa": -1,
		"etapa_nombre": "",
		"progreso": 0.0,
		"motivo": "",
	}
	_siguiente_id += 1
	_ops.append(op)
	_ordenar()
	return int(op["id"])


func _ordenar() -> void:
	_ops.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["prioridad"]) != int(b["prioridad"]):
			return int(a["prioridad"]) < int(b["prioridad"])
		return int(a["id"]) < int(b["id"]))


# ── Avance ────────────────────────────────────────────────────────────────

## Arranca la siguiente operación pendiente (respeta prioridad y orden de
## llegada). SÓLO una operación puede estar en curso a la vez: es lo que evita
## que un viaje se pise con una descarga. Devuelve el id en curso (0 si no hay
## nada que arrancar).
func iniciar() -> int:
	if _en_curso != 0:
		return _en_curso
	for op in _ops:
		if op["estado"] == EST_PENDIENTE:
			op["estado"] = EST_EN_CURSO
			op["etapa"] = -1
			op["etapa_nombre"] = ""
			op["progreso"] = 0.0
			_en_curso = int(op["id"])
			return _en_curso
	return 0


## Avanza una etapa la operación en curso. Cuando pasa la última etapa la
## marca como `hecha` y libera la cola. Devuelve una COPIA de la operación
## (vacía si no había nada en curso).
func avanzar_etapa() -> Dictionary:
	if _en_curso == 0:
		return {}
	var op: Dictionary = _buscar(_en_curso)
	if op.is_empty():
		return {}
	var siguiente: int = int(op["etapa"]) + 1
	if siguiente >= ETAPAS.size():
		op["estado"] = EST_HECHA
		op["progreso"] = 1.0
		op["etapa_nombre"] = ETAPAS[ETAPAS.size() - 1]
		var copia: Dictionary = _copiar(op)
		_cerrar(op)
		return copia
	op["etapa"] = siguiente
	op["etapa_nombre"] = ETAPAS[siguiente]
	op["progreso"] = progreso_hasta(siguiente)
	return _copiar(op)


## Corre la operación en curso hasta el final (atajo para tests y para el
## camino síncrono de M63 cuando la isla ya está en disco).
func completar_actual() -> Dictionary:
	if _en_curso == 0:
		return {}
	var ultima: Dictionary = {}
	while _en_curso != 0:
		ultima = avanzar_etapa()
	return ultima


## Marca la operación en curso como fallida (p. ej. sin disco, sin memoria).
func fallar(motivo: String = "") -> bool:
	if _en_curso == 0:
		return false
	var op: Dictionary = _buscar(_en_curso)
	if op.is_empty():
		return false
	op["estado"] = EST_FALLIDA
	op["motivo"] = motivo
	op["progreso"] = 0.0
	_cerrar(op)
	return true


# ── Cancelación ───────────────────────────────────────────────────────────

## Cancela una operación viva. Devuelve false si no existe o ya estaba cerrada.
func cancelar(op_id: int) -> bool:
	for k in range(_ops.size() - 1, -1, -1):
		var op: Dictionary = _ops[k]
		if int(op["id"]) != op_id:
			continue
		if es_estado_cerrado(op["estado"]):
			return false
		op["estado"] = EST_CANCELADA
		op["progreso"] = 0.0
		if _en_curso == op_id:
			_en_curso = 0
		_historial.append(op.duplicate(true))
		_ops.remove_at(k)
		return true
	return false


## Cancela TODAS las operaciones vivas de una isla. Devuelve cuántas canceló.
func cancelar_por_isla(isla_id: StringName) -> int:
	var ids: Array[int] = []
	for op in _ops:
		if op["isla"] == isla_id:
			ids.append(int(op["id"]))
	for oid in ids:
		cancelar(oid)
	return ids.size()


# ── Consultas ─────────────────────────────────────────────────────────────

func en_curso_id() -> int:
	return _en_curso


func esta_ocupada() -> bool:
	return _en_curso != 0


func hay_ops_vivas() -> bool:
	return not _ops.is_empty()


func contar_vivas() -> int:
	return _ops.size()


## Copias de las operaciones pendientes (nunca referencias internas).
func pendientes() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for op in _ops:
		if op["estado"] == EST_PENDIENTE:
			out.append(_copiar(op))
	return out


## Copias de todas las operaciones vivas (pendientes + en curso).
func vivas() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for op in _ops:
		out.append(_copiar(op))
	return out


func historial() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for h in _historial:
		out.append(_copiar(h))
	return out


func estado(op_id: int) -> StringName:
	var op: Dictionary = _buscar(op_id)
	if op.is_empty():
		return &""
	return op["estado"]


func info(op_id: int) -> Dictionary:
	var op: Dictionary = _buscar(op_id)
	if op.is_empty():
		return {}
	return _copiar(op)


func progreso(op_id: int) -> float:
	var op: Dictionary = _buscar(op_id)
	if op.is_empty():
		return 0.0
	return float(op["progreso"])


func op_en_curso() -> Dictionary:
	if _en_curso == 0:
		return {}
	return info(_en_curso)


## Islas con alguna operación viva (para detectar colisiones de viaje).
func islas_con_ops_vivas() -> Array[StringName]:
	var out: Array[StringName] = []
	for op in _ops:
		var isla: StringName = op["isla"]
		if not out.has(isla):
			out.append(isla)
	return out


## Islas con una operación viva de un tipo concreto.
func islas_con_tipo(tipo: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	for op in _ops:
		if op["tipo"] != tipo:
			continue
		var isla: StringName = op["isla"]
		if not out.has(isla):
			out.append(isla)
	return out


## Primera operación viva de un tipo (id, 0 si no hay).
func primera_de_tipo(tipo: StringName) -> int:
	for op in _ops:
		if op["tipo"] == tipo:
			return int(op["id"])
	return 0


func contar_por_estado() -> Dictionary:
	var out: Dictionary = {}
	for op in _ops:
		var e: StringName = op["estado"]
		out[e] = int(out.get(e, 0)) + 1
	return out


func limpiar() -> void:
	_ops.clear()
	_historial.clear()
	_en_curso = 0
	_siguiente_id = 1


# ── Validación / informe ──────────────────────────────────────────────────

func validar() -> Array[String]:
	var err: Array[String] = []
	var en_curso: int = 0
	var ids: Dictionary = {}
	var claves: Dictionary = {}
	for op in _ops:
		var oid: int = int(op["id"])
		if ids.has(oid):
			err.append("id de operación duplicado: %d" % oid)
		ids[oid] = true
		if op["estado"] == EST_EN_CURSO:
			en_curso += 1
		if not es_tipo_valido(op["tipo"]):
			err.append("tipo inválido en la operación %d: %s" % [oid, str(op["tipo"])])
		if str(op["isla"]).is_empty():
			err.append("operación %d sin isla" % oid)
		var clave: String = "%s|%s" % [str(op["tipo"]), str(op["isla"])]
		if claves.has(clave):
			err.append("dos operaciones vivas idénticas (tipo|isla): %s" % clave)
		claves[clave] = true
		var pr: float = float(op["progreso"])
		if pr < 0.0 or pr > 1.0:
			err.append("progreso fuera de [0,1] en la operación %d: %f" % [oid, pr])
	if en_curso > 1:
		err.append("más de una operación en curso: %d" % en_curso)
	if absf(suma_pesos() - 1.0) > 0.001:
		err.append("los pesos de carga no suman 1.0: %f" % suma_pesos())
	if _en_curso != 0 and estado(_en_curso) != EST_EN_CURSO:
		err.append("_en_curso apunta a una operación que no está en curso: %d" % _en_curso)
	return err


func es_valida() -> bool:
	return validar().is_empty()


func informe() -> Dictionary:
	return {
		"vivas": _ops.size(),
		"en_curso": _en_curso,
		"pendientes": pendientes().size(),
		"historial": _historial.size(),
		"por_estado": contar_por_estado(),
		"pesos": suma_pesos(),
		"etapas": ETAPAS.duplicate(),
		"max_ops_por_frame": MAX_OPS_POR_FRAME,
		"islas_vivas": islas_con_ops_vivas(),
	}


func resumen() -> String:
	return "IslandOps(vivas=%d, en_curso=%d, historial=%d)" % [
		_ops.size(), _en_curso, _historial.size()
	]


# ── Interno ───────────────────────────────────────────────────────────────

func _buscar(op_id: int) -> Dictionary:
	for op in _ops:
		if int(op["id"]) == op_id:
			return op
	for h in _historial:
		if int(h["id"]) == op_id:
			return h
	return {}


func _copiar(op: Dictionary) -> Dictionary:
	return op.duplicate(true)


func _cerrar(op: Dictionary) -> void:
	var oid: int = int(op["id"])
	if _en_curso == oid:
		_en_curso = 0
	_historial.append(op.duplicate(true))
	for k in range(_ops.size() - 1, -1, -1):
		if int(_ops[k]["id"]) == oid:
			_ops.remove_at(k)
			return
