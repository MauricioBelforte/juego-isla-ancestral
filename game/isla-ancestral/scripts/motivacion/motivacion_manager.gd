# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M94: Retención sin FOMO — MotivacionManager (autoload)
# Servicio central de retención amable (RF1/RF4/RF9):
#   - Tablero de objetivos (diario/semanal/mensual) con reseteo rotatorio.
#   - Recompensas acumuladas sin expiración (cola, límite 50).
#   - Motor de variantes de eventos (3+ por festividad).
#   - AntiFomoAuditor para verificar que ninguna mecánica viole las 5 normas.
# Persistencia vía DataStore M60 (sección "motivacion") cuando existe.
#
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

signal objetivos_cambiados
signal recompensa_acumulada(recompensa_id: String, cantidad: int)

const CATALOGO_RUTA := "res://data/motivacion/objetivos.json"
const PLAZO := {
	"diario": 0, "semanal": 1, "mensual": 2,
}

var catalogo: Array = []                # Array[Dictionary] de objetivos
var activos: Dictionary = {}            # objetivo_id -> ObjetivoActivo
var recompensas := RecompensaAcumulada.new()
var motor_variantes := MotorEventosVariantes.new()

func _ready() -> void:
	_cargar_catalogo()
	_registrar_festividades()
	_registrar_servicio()
	print("[M94] MotivacionManager listo (%d objetivos en catálogo)" % catalogo.size())

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("motivacion"):
		sr.register("motivacion", self)

## ── Catálogo ────────────────────────────────────────────

func _cargar_catalogo() -> void:
	if not FileAccess.file_exists(CATALOGO_RUTA):
		push_warning("[M94] Catálogo no encontrado: %s (tablero vacío)" % CATALOGO_RUTA)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOGO_RUTA))
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("objetivos"):
		push_warning("[M94] Catálogo inválido (sin clave 'objetivos')")
		return
	catalogo = parsed["objetivos"]
	_crear_activos()

## ── Tablero ─────────────────────────────────────────────

func _crear_activos() -> void:
	for objetivo in catalogo:
		var oid: String = objetivo.get("id", "")
		if oid.is_empty():
			continue
		activos[oid] = ObjetivoActivo.new(oid)

## Objetivos activos por plazo (diario/semanal/mensual). Devuelve Array.
func objetivos_por_plazo(plazo: String) -> Array:
	var resultado: Array = []
	for objetivo in catalogo:
		if String(objetivo.get("plazo", "")) != plazo:
			continue
		var oid: String = objetivo.get("id", "")
		resultado.append({"data": objetivo, "activo": activos.get(oid, null)})
	return resultado

## Avanza el progreso de un objetivo (llamado por el sistema de gameplay).
## Devuelve true si recién se completó (y acumula recompensa pendiente).
func registrar_progreso(objetivo_id: String, delta: int = 1) -> bool:
	var activo: ObjetivoActivo = activos.get(objetivo_id, null)
	if activo == null:
		return false
	var data := _buscar_data(objetivo_id)
	var requerido: int = int(data.get("cantidad_requerida", 1)) if not data.is_empty() else 1
	var recien_completado := activo.avanzar(requerido, delta)
	if recien_completado:
		_otorgar_recompensa(objetivo_id)
	emit_signal("objetivos_cambiados")
	return recien_completado

## Cobra un objetivo completado (diario M55): vacía la recompensa pendiente.
## Devuelve la lista de recompensas cobradas (vacía si no hay).
func cobrar_recompensa(objetivo_id: String) -> Array:
	var activo: ObjetivoActivo = activos.get(objetivo_id, null)
	if activo == null or not activo.cobrado:
		return []
	activo.cobrado = true
	emit_signal("objetivos_cambiados")
	return _pendientes_cobrados()

func _pendientes_cobrados() -> Array:
	return recompensas.cobrar_pendientes()

## Reseteo rotatorio al empezar ciclo nuevo (día/semana/mes de juego, M29):
## los objetivos NO cobrados se conservan (sin pérdida), los completados
## vuelven a estar disponibles con nuevo ciclo. RF1: sin pérdida de premios.
func rotar_objetivos() -> void:
	for oid in activos:
		var activo: ObjetivoActivo = activos[oid]
		var data := _buscar_data(oid)
		if not activo.cobrado and activo.completado:
			# premio pendiente queda acumulado; el objetivo se reinicia
			_otorgar_recompensa(oid)
		activo.ciclo += 1
		activo.progreso = 0
		activo.cobrado = false
		activo.completado = false
	emit_signal("objetivos_cambiados")

## ── Recompensas y variantes ──────────────────────────────

func _otorgar_recompensa(objetivo_id: String) -> void:
	var data := _buscar_data(objetivo_id)
	if data.is_empty():
		return
	var rid: String = data.get("recompensa_id", "")
	var cantidad: int = int(data.get("recompensa_cantidad", 1))
	recompensas.agregar(rid, cantidad)
	emit_signal("recompensa_acumulada", rid, cantidad)
	var activo: ObjetivoActivo = activos.get(objetivo_id, null)
	if activo:
		activo.cobrado = true

func _buscar_data(objetivo_id: String) -> Dictionary:
	for objetivo in catalogo:
		if String(objetivo.get("id", "")) == objetivo_id:
			return objetivo
	return {}

func _registrar_festividades() -> void:
	motor_variantes.registrar("festival_estaciones", ["flores", "cosecha", "luces", "nieve"])
	motor_variantes.registrar("dia_del_pescador", ["marea_alta", "rio_dorado", "tormenta_calmada"])

## ── Auditoría ───────────────────────────────────────────

## Scan anti-FOMO: devuelve Array de violaciones (vacía = OK).
func auditar() -> Array:
	var config := {
		"permite_streak": false,
		"permite_expiracion": false,
		"penaliza_ausencia": false,
		"exclusivo_temporal": false,
		"usa_tiempo_real": false,
	}
	return AntiFomoAuditor.escanear(catalogo, config)

## ── Persistencia (M60 DataStore, sección "motivacion") ──

func snapshot() -> Dictionary:
	return {
		"activos": _serializar_activos(),
		"recompensas": recompensas.a_diccionario(),
		"motor_variantes": motor_variantes.a_diccionario(),
	}

func restaurar(datos: Dictionary) -> void:
	if datos.is_empty():
		return
	_restaurar_activos(datos.get("activos", {}))
	recompensas = RecompensaAcumulada.desde_diccionario(datos.get("recompensas", {}))
	motor_variantes = MotorEventosVariantes.desde_diccionario(datos.get("motor_variantes", {}))

func _serializar_activos() -> Dictionary:
	var out: Dictionary = {}
	for oid in activos:
		out[oid] = activos[oid].a_diccionario()
	return out

func _restaurar_activos(datos: Dictionary) -> void:
	for oid in datos:
		if activos.has(oid):
			activos[oid] = ObjetivoActivo.desde_diccionario(datos[oid])