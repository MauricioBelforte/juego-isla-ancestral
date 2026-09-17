# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-13
#
# M52: VfxPool — pool de emisores GPUParticles3D reutilizables (parte NO visual).
#
# Cubre el encaje A8 del backlog:
#   T-027  Pool de emisores one-shot prestados/liberados
#   T-029  Precalentamiento del pool (8 emisores)
#   T-093  Determinismo: semilla estable por (evento, indice) + validador
#
# Motivo: `FACTORY.crear()` asignaba `GPUParticles3D.mesh`, propiedad ELIMINADA
# en Godot 4.3 (hoy es `draw_pass_1`). El error abortaba la función en silencio y
# `crear()` devolvía null: cada disparo asignaba un emisor nuevo y NO aparecía
# nada. El pool resuelve además el coste de allocar por disparo.
#
# Diseño:
#   - Emisores agrupados por `id` de VFX: reusar uno del mismo id evita
#     reconfigurar material/amount (barato y determinista).
#   - Límite de emisores vivos (`max_emisores`) y de partículas activas
#     (`max_particulas`). Al desbordar se RECICLA el activo más antiguo
#     (política determinista, orden de préstamo) y se cuenta como descarte.
#   - Si ni siquiera cabe un emisor solo, `prestar()` devuelve null (descarte).
#   - Todo es lógica pura + nodos: verificable en headless.

class_name VfxPool
extends RefCounted

## Emitida cuando `prestar()` rechaza un disparo por límites (o id vacío).
## El director la usa para el log `VFX-SKIP` (RF3/M52). Testeable en headless.
signal emision_descartada(id: String, motivo: String)

## Preload y no el nombre global: un `class_name` recién añadido no es visible
## para `--script` hasta regenerar la cache (§9.52 y trampa conocida).
const FACTORY := preload("res://scripts/particles/vfx_factory.gd")

const MAX_EMISORES_DEF := 32
const MAX_PARTICULAS_DEF := 1200

## Motivos de descarte (claves estables para telemetría/tests).
const MOTIVO_SIN_ID := "id vacío"
const MOTIVO_PARTICULAS := "presupuesto de partículas"
const MOTIVO_EMISORES := "sin cupo de emisores"

var max_emisores: int = MAX_EMISORES_DEF
var max_particulas: int = MAX_PARTICULAS_DEF

var ultimo_descarte: String = ""   # último motivo de descarte ("" si nunca)

var _libres: Dictionary = {}    # id -> Array[GPUParticles3D]
var _activos: Dictionary = {}   # GPUParticles3D -> {"id", "particulas", "orden"}
var _creados: int = 0           # total de emisores instanciados (nunca baja)
var _descartes: int = 0         # disparos rechazados por límites
var _reciclados: int = 0        # emisores activos reciclados por límite
var _orden: int = 0             # contador de préstamos (para "más antiguo")
var _emisiones: int = 0         # disparos efectivos
var _motivos: Dictionary = {}   # motivo -> conteo

func _init(p_max_emisores: int = MAX_EMISORES_DEF, p_max_particulas: int = MAX_PARTICULAS_DEF) -> void:
	max_emisores = maxi(1, p_max_emisores)
	max_particulas = maxi(1, p_max_particulas)

# ── Semilla determinista (T-093) ───────────────────────────────────────

## Semilla estable para (id, indice): FNV-1a de 32 bits. Determinista entre
## corridas y plataformas (no depende de hash() del motor ni del azar).
static func semilla_de(id: String, indice: int) -> int:
	var texto := "%s:%d" % [id, indice]
	var h: int = 2166136261          # offset basis FNV-1a 32
	for i in texto.length():
		h = (h ^ texto.unicode_at(i)) & 0xFFFFFFFF
		h = (h * 16777619) & 0xFFFFFFFF
	return h

## Valida una secuencia de semillas: no vacía y sin repetidos consecutivos.
## Devuelve "" si es válida, o el motivo del fallo (validador de determinismo).
static func validar_semillas(semillas: Array) -> String:
	if semillas.is_empty():
		return "secuencia de semillas vacía"
	for i in semillas.size():
		if typeof(semillas[i]) != TYPE_INT:
			return "semilla %d no es int" % i
		if i > 0 and semillas[i] == semillas[i - 1]:
			return "semilla repetida en %d (%d)" % [i, semillas[i]]
	return ""

# ── Precalentamiento (T-029) ───────────────────────────────────────────

## Crea `n` emisores del VFX dado y los deja LIBRES (sin emitir). Devuelve
## cuántos se crearon realmente (limitado por `max_emisores`).
func precalentar(vfx: Dictionary, n: int = 8) -> int:
	var id := str(vfx.get("id", ""))
	if id.is_empty() or n <= 0:
		return 0
	var hechos := 0
	for _i in n:
		if _creados >= max_emisores:
			break
		var gp := FACTORY.nuevo_emisor(vfx)
		gp.emitting = false
		_creados += 1
		_apilar(id, gp)
		hechos += 1
	return hechos

## Precalienta el pool con los 8 emisores por defecto para un catálogo
## completo (una entrada por evento). Devuelve el total creado.
func precalentar_catalogo(catalogo: Array, n_por_vfx: int = 1) -> int:
	var total := 0
	for vfx in catalogo:
		total += precalentar(vfx, n_por_vfx)
	return total

# ── Préstamo / liberación (T-027) ──────────────────────────────────────

## Pide un emisor para el VFX dado, en la posición indicada, y lo dispara.
## Devuelve el nodo (ya emitiendo) o null si se descartó por límites.
func prestar(vfx: Dictionary, pos: Vector3 = Vector3.ZERO, container: Node = null) -> Node:
	var id := str(vfx.get("id", ""))
	if id.is_empty():
		return _descartar(id, MOTIVO_SIN_ID)
	var cantidad := int(FACTORY.parametros(vfx)["cantidad"])

	# 1) Asegurar hueco de emisores y de partículas reciclando los más antiguos.
	if not _hacer_hueco(cantidad):
		return _descartar(id, MOTIVO_PARTICULAS)

	# 2) Reusar un emisor libre del mismo id, o crear uno nuevo.
	var gp: GPUParticles3D = null
	var pila: Array = _libres.get(id, [])
	if not pila.is_empty():
		gp = pila.pop_back()
	elif _creados < max_emisores:
		gp = FACTORY.nuevo_emisor(vfx)
		_creados += 1
	else:
		# Sin libres y sin cupo: reciclar el activo más antiguo.
		gp = _reciclar_mas_antiguo()
		if gp == null:
			return _descartar(id, MOTIVO_EMISORES)
		id = str(_activos[gp]["id"]) if _activos.has(gp) else id

	# 3) Disparar de forma determinista.
	_orden += 1
	_emisiones += 1
	FACTORY.redisparar(gp, vfx, pos, semilla_de(id, _emisiones))
	if container != null and gp.get_parent() != container:
		if gp.get_parent() != null:
			gp.get_parent().remove_child(gp)
		container.add_child(gp)
	_activos[gp] = {"id": id, "particulas": cantidad, "orden": _orden}
	return gp

## Devuelve un emisor al pool (deja de contar como activo).
func liberar(nodo: Node) -> bool:
	if nodo == null or not _activos.has(nodo):
		return false
	var info: Dictionary = _activos[nodo]
	nodo.emitting = false
	_activos.erase(nodo)
	_apilar(str(info["id"]), nodo)
	return true

## Libera todos los activos (p. ej. al cambiar de escena).
func liberar_todos() -> int:
	var n := 0
	for gp in _activos.keys():
		if liberar(gp):
			n += 1
	return n

# ── Métricas ───────────────────────────────────────────────────────────

func activos() -> int:
	return _activos.size()

func libres() -> int:
	var n := 0
	for id in _libres:
		n += (_libres[id] as Array).size()
	return n

func creados() -> int:
	return _creados

func descartes() -> int:
	return _descartes

func reciclados() -> int:
	return _reciclados

func emisiones() -> int:
	return _emisiones

## Conteo de descartes por motivo (copia defensiva).
func motivos() -> Dictionary:
	return _motivos.duplicate()

func particulas_activas() -> int:
	var n := 0
	for gp in _activos:
		n += int(_activos[gp]["particulas"])
	return n

func stats() -> Dictionary:
	return {
		"activos": activos(), "libres": libres(), "creados": _creados,
		"descartes": _descartes, "reciclados": _reciclados,
		"emisiones": _emisiones, "particulas_activas": particulas_activas(),
		"max_emisores": max_emisores, "max_particulas": max_particulas,
		"motivos": _motivos.duplicate(), "ultimo_descarte": ultimo_descarte,
	}

## Vacía el pool por completo (suelta los nodos del padre si lo tienen).
func vaciar() -> void:
	_activos.clear()
	_libres.clear()
	_creados = 0
	_emisiones = 0
	_motivos.clear()
	ultimo_descarte = ""

## Todos los emisores vivos (activos + libres). Para liberarlos al cerrar.
func nodos() -> Array:
	var out: Array = []
	out.append_array(_activos.keys())
	for id in _libres:
		out.append_array(_libres[id])
	return out

# ── Interno ────────────────────────────────────────────────────────────

## Registra un descarte: cuenta, guarda el motivo, emite `emision_descartada`
## (lo consume el director para el log VFX-SKIP) y devuelve null.
func _descartar(id: String, motivo: String) -> Node:
	_descartes += 1
	ultimo_descarte = motivo
	_motivos[motivo] = int(_motivos.get(motivo, 0)) + 1
	emision_descartada.emit(id, motivo)
	return null

func _apilar(id: String, gp: GPUParticles3D) -> void:
	if not _libres.has(id):
		_libres[id] = []
	(_libres[id] as Array).append(gp)

## Garantiza que quepan `cantidad` partículas y al menos 1 emisor libre/creable.
## Devuelve false si es imposible (el VFX solo ya supera max_particulas).
func _hacer_hueco(cantidad: int) -> bool:
	if cantidad > max_particulas:
		return false
	# Partículas: reciclar activos (más antiguos primero) hasta que quepa.
	while particulas_activas() + cantidad > max_particulas and not _activos.is_empty():
		var gp := _reciclar_mas_antiguo()
		if gp == null:
			break
	# Emisores: si no hay libres y no hay cupo, reciclar uno activo.
	if _sin_libres() and _creados >= max_emisores and not _activos.is_empty():
		_reciclar_mas_antiguo()
	return true

func _sin_libres() -> bool:
	return libres() == 0

## Recicla (libera) el emisor activo de menor `orden`. Devuelve el nodo.
func _reciclar_mas_antiguo() -> GPUParticles3D:
	var elegido: GPUParticles3D = null
	var menor := 1 << 62
	for gp in _activos:
		var o := int(_activos[gp]["orden"])
		if o < menor:
			menor = o
			elegido = gp
	if elegido == null:
		return null
	_reciclados += 1
	liberar(elegido)
	return elegido
