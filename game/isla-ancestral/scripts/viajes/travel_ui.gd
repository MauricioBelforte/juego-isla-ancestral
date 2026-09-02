# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M28: Viajes — TravelUI (CanvasLayer). Capa de presentación para la UI de viajes.
# Muestra pantalla de reserva, barra de progreso durante travesía, avisos de clima
# y confirmaciones de devolución. Lógica de gameplay NO aquí: solo refleja estado
# de TravelService (autoguardado M59, datos de rutas desde TravelService).
#
# Sin class_name: CanvasLayer de escena (pitfall §9.17).
# Integra con M53 (ThemeUx) para estilos; duck-typing si M53 no existe.

extends CanvasLayer

## Señales de interacción del jugador.
signal confirmar_reserva(route_id: StringName)
signal confirmar_cancelacion
signal confirmar_viaje_rapido(destination_id: String)

## Estado interno de la UI.
enum UIScreen { HIDDEN, RESERVATION, PROGRESS, WEATHER_DELAY, REFUND }
var _pantalla_actual: int = UIScreen.HIDDEN

## Puerto asociado a la pantalla abierta (harbor_id).
var _harbor_id_act: String = ""


func _ready() -> void:
	print("[M28/TravelUI] Cargado")
	_cerrar()


# ── Pantalla de reserva ────────────────────────────────────

func show_reservation_screen(harbor_id: String) -> void:
	_harbor_id_act = harbor_id
	var ts := get_node_or_null("/root/TravelService")
	if ts == null:
		push_error("[M28/TravelUI] TravelService no encontrado")
		return
	# Obtener destinos disponibles.
	var rutas = ts.get_available_destinations()
	# Para cada ruta, construir un diccionario legible por la UI.
	var opciones: Array = []
	for ruta in rutas:
		opciones.append({
			"route_id": str(ruta.route_id),
			"destino": ruta.destination_island_id,
			"coste": ruta.cost_coins,
			"duracion": ruta.base_duration_seconds,
			"nocturna": ruta.is_night_line,
			"temporada": ruta.temporada,
		})
	# Mostrar pantalla (duck-typing: si M53 ThemeUx existe, usar sus colores).
	_abrir_pantalla(opciones)
	_pantalla_actual = UIScreen.RESERVATION
	_set_interactivo(true)
	print("[M28/TravelUI] Mostrando reserva para harbor '%s' (%d opciones)" % [harbor_id, opciones.size()])


func _abrir_pantalla(opciones: Array) -> void:
	# Nota: en V0 no hay escenas UI; los calls se hacen vía EventBus o callbacks.
	# Este método es un stub que emite la señal confirmar_reserva con los datos.
	# M53 (UI/UX) consumirá estas señales cuando se implemente.
	_emitar_cambio_pantalla("RESERVATION", {"opciones": opciones})


# ── Barra de progreso ──────────────────────────────────────

func show_travel_progress(progress: float, label: String) -> void:
	_pantalla_actual = UIScreen.PROGRESS
	_emitar_cambio_pantalla("PROGRESS", {"progress": progress, "label": label})
	_set_interactivo(false)  # Sección 8 AGENTS.md: deshabilitar interacción en transición


func show_weather_delay_notice(seconds: float, reason: String) -> void:
	_pantalla_actual = UIScreen.WEATHER_DELAY
	_emitar_cambio_pantalla("WEATHER_DELAY", {"seconds": seconds, "reason": reason})
	# El usuario puede cancelar o esperar (viajaservice maneja el flujo real).


func show_refund_notice(coins: int) -> void:
	_pantalla_actual = UIScreen.REFUND
	_emitar_cambio_pantalla("REFUND", {"coins": coins})
	# Auto-cerrar después de 2 s.
	get_tree().create_timer(2.0).timeout.connect(_cerrar)


# ── Utilidades ─────────────────────────────────────────────

func set_interactive(enabled: bool) -> void:
	"""Sección 8 AGENTS.md: deshabilitar UI interactiva durante transiciones."""
	_set_interactivo(enabled)


func _set_interactivo(enabled: bool) -> void:
	# En V0: solo controla el flag interno. M53 aplicará enabled/disabled a botones.
	pass


func _cerrar() -> void:
	_pantalla_actual = UIScreen.HIDDEN
	_harbor_id_act = ""
	_emitar_cambio_pantalla("HIDDEN", {})
	_set_interactivo(true)


# ── Emisión de cambios (bridge a M53) ─────────────────────

func _emitar_cambio_pantalla(tipo: String, datos: Dictionary) -> void:
	"""Emite via EventBus.ui.travel_ui para que M53 refresque la capa correspondiente."""
	var bus := get_node_or_null("/root/EventBus")
	if bus != null and bus.ui != null and bus.ui.has_signal("travel_ui_cambio"):
		bus.ui.travel_ui_cambio.emit(tipo, datos)
	else:
		# Fallback: print para debug en headless.
		print("[M28/TravelUI] Cambio pantalla: %s %s" % [tipo, str(datos)])


## Consulta el estado actual de la UI (para tests).
func get_current_screen() -> int:
	return _pantalla_actual


func get_harbor_id() -> String:
	return _harbor_id_act
