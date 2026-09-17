# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M68 iter. 2: Transporte y Navegación — TransportTripPlanner.
#
# Planifica el viaje SIN escena ni jugador: produce el PLAN (fases ordenadas,
# duración cozy, mensaje, orientación de llegada) que el TripService (M68/M61)
# ejecuta cuando exista el runtime 3D.
#
# RF14 (tiempos) + RF15 (transiciones cozy) + RF20 ("nunca perder al jugador").
#
# Regla dura del diseño (01-Requerimientos §4 / 03-Diseno §2.1):
#   * la transición SIEMPRE dura < 4 s (cozy);
#   * el destino se CARGA ANTES de mover al jugador (M61);
#   * la cámara reaparece ORIENTADA AL DESTINO;
#   * si no se puede cargar el destino, el jugador NO se mueve (nunca se pierde).
#
# `verificar_plan()` comprueba esas invariantes sobre el propio plan: es lo que
# convierte la regla de diseño en algo verificable en headless.

class_name TransportTripPlanner
extends RefCounted

## Duración máxima de la transición (RF15: cozy < 4 s).
const DURACION_MAX_COZY := 4.0
## Piso: por debajo de esto la transición se siente un salto.
const DURACION_MIN_COZY := 2.4
## Una ruta de ≤ este tiempo se hace en tiempo real con el vehículo (M67);
## por encima, se monta con fade (03-Diseno §3.2).
const UMBRAL_VIAJE_CORTO_SEG := 90.0
## Si la carga del destino supera esto, se muestra barra de progreso (M08).
const UMBRAL_BARRA_SEG := 2.5
## Distancia mínima entre paradas para poder calcular una orientación.
const DISTANCIA_MIN_ORIENTACION := 0.5

## Claves de localización (M87) de los mensajes del viaje.
const CLAVE_VIAJANDO := "M68.TRIP.TRAVELING_TO"
const CLAVE_LLEGADA := "M68.TRIP.ARRIVED_AT"
const CLAVE_BARRA := "M68.TRIP.LOADING"

## Orden OBLIGATORIO de las fases. `cargar_destino` va antes de `mover_jugador`.
const ORDEN_FASES: Array[String] = [
	"preparar",
	"cargar_destino",
	"fundido_salida",
	"mover_jugador",
	"fundido_entrada",
	"orientar",
	"notificar",
]

## Duraciones base por fase (segundos). Se escalan de forma acotada.
const DURACION_FASES: Dictionary = {
	"preparar": 0.15,
	"cargar_destino": 0.9,
	"fundido_salida": 0.6,
	"mover_jugador": 0.1,
	"fundido_entrada": 0.8,
	"orientar": 0.2,
	"notificar": 0.25,
}


## ¿El viaje se hace en tiempo real con el vehículo (M67) o montado con fade?
static func es_viaje_corto(duracion_seg: float) -> bool:
	return duracion_seg <= UMBRAL_VIAJE_CORTO_SEG


## Plan del viaje. `ruta` es un TransportRoute; `destino` un TransportStop.
## `opciones` admite:
##   carga_destino_seg (float) — coste simulado de cargar el destino (M61)
##   usar_vehiculo (bool)      — forzar viaje en tiempo real (M67)
##   motivo_aborto (String)    — simular fallo de carga del destino (test)
##   destino_nombre (String)   — nombre visible para el mensaje (M87)
static func planificar(ruta: TransportRoute, destino: TransportStop, opciones: Dictionary = {}) -> Dictionary:
	var base: Dictionary = {
		"ok": false,
		"motivo": "",
		"modo": "fade",
		"duracion_total": 0.0,
		"duracion_ruta_seg": 0.0,
		"necesita_barra": false,
		"usa_vehiculo": false,
		"mensaje_clave": CLAVE_VIAJANDO,
		"mensaje": "",
		"fases": [],
		"orientacion": Vector3.ZERO,
		"destino_pos": Vector3.ZERO,
		"sale_de": "",
		"llega_a": "",
		"puede_perder_jugador": false,
		"reintentos_carga": 0,
	}

	if ruta == null:
		base["motivo"] = "ruta nula"
		return base
	if destino == null:
		# Sin destino no hay plan válido: se aborta SIN mover al jugador.
		base["motivo"] = "destino nulo (no se mueve al jugador)"
		return base
	var fallo: String = String(opciones.get("motivo_aborto", ""))
	if not fallo.is_empty():
		# Fallo de carga del destino (M61): se aborta ANTES de mover.
		base["motivo"] = fallo
		base["sale_de"] = String(ruta.from_id)
		base["llega_a"] = String(ruta.to_id)
		base["reintentos_carga"] = int(opciones.get("reintentos_carga", 1))
		return base

	var dur_ruta: float = maxf(0.0, ruta.duracion_seg)
	var carga: float = maxf(0.0, float(opciones.get("carga_destino_seg", DURACION_FASES["cargar_destino"])))
	var corto: bool = es_viaje_corto(dur_ruta)
	var usa_vehiculo: bool = bool(opciones.get("usar_vehiculo", corto))
	var modo: String = "tiempo_real" if usa_vehiculo else "fade"

	# Duración total: escala suave por duración de ruta, acotada a [MIN, MAX].
	var total: float = clampf(DURACION_MIN_COZY + dur_ruta * 0.002, DURACION_MIN_COZY, DURACION_MAX_COZY)
	var necesita_barra: bool = carga > UMBRAL_BARRA_SEG

	var nombre: String = String(opciones.get("destino_nombre", destino.nombre_fallback))
	if nombre.is_empty():
		nombre = String(destino.id)

	var fases: Array[Dictionary] = _construir_fases(carga, usa_vehiculo)

	base["ok"] = true
	base["modo"] = modo
	base["duracion_total"] = snappedf(total, 0.01)
	base["duracion_ruta_seg"] = snappedf(dur_ruta, 0.01)
	base["necesita_barra"] = necesita_barra
	base["usa_vehiculo"] = usa_vehiculo
	base["mensaje"] = _formatear_mensaje(CLAVE_VIAJANDO, nombre)
	base["fases"] = fases
	base["destino_pos"] = destino.pos
	base["sale_de"] = String(ruta.from_id)
	base["llega_a"] = String(ruta.to_id)
	base["orientacion"] = orientacion_hacia(destino.pos)
	base["puede_perder_jugador"] = false
	return base


## Vector unitario (XZ) desde el que mirar el destino. Si la parada está en el
## origen del mundo no hay dirección fiable → se devuelve el eje +Z.
static func orientacion_hacia(destino_pos: Vector3) -> Vector3:
	var plano := Vector3(destino_pos.x, 0.0, destino_pos.z)
	if plano.length() < DISTANCIA_MIN_ORIENTACION:
		return Vector3(0.0, 0.0, 1.0)
	return plano.normalized()


## Orientación para MIRAR desde `origen` hacia `destino` (la cámara del jugador
## al reaparecer). A diferencia de `orientacion_hacia`, usa la diferencia real.
static func orientacion_entre(origen_pos: Vector3, destino_pos: Vector3) -> Vector3:
	var d := Vector3(destino_pos.x - origen_pos.x, 0.0, destino_pos.z - origen_pos.z)
	if d.length() < DISTANCIA_MIN_ORIENTACION:
		return orientacion_hacia(destino_pos)
	return d.normalized()


static func _construir_fases(carga: float, usa_vehiculo: bool) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var orden: int = 0
	for id in ORDEN_FASES:
		var dur: float = float(DURACION_FASES.get(id, 0.0))
		if id == "cargar_destino":
			dur = carga
		elif id == "fundido_salida" or id == "fundido_entrada":
			# En viaje corto con vehículo no hay fundido: el jugador ve el trayecto.
			dur = 0.0 if usa_vehiculo else dur
		elif id == "mover_jugador":
			dur = 0.1
		orden += 1
		out.append({
			"id": id,
			"orden": orden,
			"duracion": snappedf(dur, 0.01),
			"bloqueante": id == "cargar_destino",
			"descripcion": _descripcion_fase(id),
		})
	return out


static func _descripcion_fase(id: String) -> String:
	match id:
		"preparar":
			return "bloquear entrada y fijar el destino"
		"cargar_destino":
			return "cargar el destino ANTES de mover al jugador (M61)"
		"fundido_salida":
			return "fundido cozy de salida (M44)"
		"mover_jugador":
			return "mover al jugador a la parada destino"
		"fundido_entrada":
			return "fundido de entrada en el destino"
		"orientar":
			return "orientar la cámara al destino (RF20)"
		"notificar":
			return "avisar llegada y cerrar el viaje (TRIP-END)"
	return id


static func _formatear_mensaje(clave: String, nombre: String) -> String:
	return "Viajando a %s..." % nombre if clave == CLAVE_VIAJANDO else "Has llegado a %s." % nombre


## ── Verificación de las invariantes del plan (RF15/RF20) ───────────────────
## Devuelve Array[String] de violaciones; vacío = plan correcto.
static func verificar_plan(plan: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	if not bool(plan.get("ok", false)):
		# Un plan abortado es legítimo: lo que NO puede pasar es que mueva al jugador.
		if bool(plan.get("puede_perder_jugador", false)):
			errores.append("plan abortado con puede_perder_jugador=true")
		return errores

	var total: float = float(plan.get("duracion_total", 0.0))
	if total <= 0.0:
		errores.append("duración total no positiva")
	if total >= DURACION_MAX_COZY:
		errores.append("transición no cozy: %.2f s (máx < %.1f)" % [total, DURACION_MAX_COZY])

	var fases: Array = plan.get("fases", [])
	if fases.is_empty():
		errores.append("plan sin fases")
		return errores

	# Orden exacto y cargar_destino ANTES de mover_jugador.
	var ids: Array[String] = []
	for f in fases:
		var d: Dictionary = f as Dictionary
		ids.append(String(d.get("id", "")))
	if ids != ORDEN_FASES:
		errores.append("orden de fases inesperado: %s" % str(ids))
	var i_carga: int = ids.find("cargar_destino")
	var i_mover: int = ids.find("mover_jugador")
	if i_carga < 0 or i_mover < 0 or i_carga > i_mover:
		errores.append("el destino se carga DESPUÉS de mover al jugador (M61/RF20)")

	# La fase de carga debe ser bloqueante.
	for f in fases:
		var d: Dictionary = f as Dictionary
		if String(d.get("id", "")) == "cargar_destino" and not bool(d.get("bloqueante", false)):
			errores.append("la carga del destino no es bloqueante")

	# Orientación válida.
	var o: Vector3 = plan.get("orientacion", Vector3.ZERO) as Vector3
	if o.length() < 0.9 or o.length() > 1.1:
		errores.append("orientación no unitaria: %s" % str(o))

	if bool(plan.get("puede_perder_jugador", false)):
		errores.append("puede_perder_jugador=true en un plan válido")
	if String(plan.get("mensaje", "")).is_empty():
		errores.append("plan sin mensaje para el jugador")
	return errores


static func es_plan_valido(plan: Dictionary) -> bool:
	return verificar_plan(plan).is_empty()


## Resumen legible (para logs y para el validador unificado).
static func resumen(plan: Dictionary) -> String:
	if not bool(plan.get("ok", false)):
		return "PLAN-ABORT motivo=%s" % String(plan.get("motivo", "?"))
	return "PLAN modo=%s dur=%.2fs barra=%s fases=%d ruta=%s>%s" % [
		String(plan.get("modo", "?")),
		float(plan.get("duracion_total", 0.0)),
		str(bool(plan.get("necesita_barra", false))),
		(plan.get("fases", []) as Array).size(),
		String(plan.get("sale_de", "?")),
		String(plan.get("llega_a", "?")),
	]
