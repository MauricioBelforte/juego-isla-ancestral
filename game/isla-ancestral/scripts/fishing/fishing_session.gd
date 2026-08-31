# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M34: FishingSession — máquina de estados del minijuego (§2.5).
# IDLE -> LANZANDO -> ESPERA_PICADA -> PICADA -> MINIJUEGO -> CAPTURA | ESCAPE -> IDLE
# Fases indulgentes: A (reacción al hundirse) y B (3 pulsaciones con ventana amplia).
# Timers propias del nodo (pausable con get_tree().paused — GameClock M29 congela).

class_name FishingSession
extends Node

enum Estado { IDLE, LANZANDO, ESPERA_PICADA, PICADA, MINIJUEGO, CAPTURA, ESCAPE }

signal estado_cambiado(estado: int)
signal ventana_activa(inicio_ventana: float, duracion: float)
signal pulsaciones_minijuego(restantes: int)

var estado: int = Estado.IDLE
var cana: FishingRod = null
var cebo: CeboDefinition = null

var _pulsaciones_restantes: int = 0
var _ventana_timer: SceneTreeTimer = null
var _espera_timer: SceneTreeTimer = null

## Tiempo de espera de picada: base [2,8] s x cana x cebo (regla §6.1).
func calcular_espera(prng: RandomNumberGenerator) -> float:
	var base := prng.randf_range(2.0, 8.0)
	var mult_cana := cana.multiplicador_espera if cana else 1.0
	var mult_cebo := cebo.multiplicador_espera if cebo else 1.0
	return clampf(base * mult_cana * mult_cebo, 2.0, 8.0)

## ── Máquina de estados ───────────────────────────────────

func _set_estado(nuevo: int) -> void:
	estado = nuevo
	estado_cambiado.emit(nuevo)

## Lanzar: entra LANZANDO y programa la picada.
func lanzar(prng: RandomNumberGenerator) -> void:
	if cana == null:
		return
	_set_estado(Estado.LANZANDO)
	var espera := calcular_espera(prng)
	_espera_timer = get_tree().create_timer(espera)
	_espera_timer.timeout.connect(_on_picada)
	_set_estado(Estado.ESPERA_PICADA)

## Picada: abre la ventana de reacción (fase A).
func _on_picada() -> void:
	if estado != Estado.ESPERA_PICADA:
		return
	_set_estado(Estado.PICADA)
	_abrir_ventana(_on_ventana_fase_a_expirada)

func _abrir_ventana(on_expirada: Callable) -> void:
	var duracion := cana.ventana_clamp() if cana else 0.5
	ventana_activa.emit(Time.get_ticks_msec() / 1000.0, duracion)
	_ventana_timer = get_tree().create_timer(duracion)
	_ventana_timer.timeout.connect(on_expirada)

## Pulsación del jugador (llamada por la UI indirectamente).
func notificar_pulsacion_boton() -> void:
	match estado:
		Estado.PICADA:
			# Fase A OK -> minijuego (fase B: 3 pulsaciones)
			_pulsaciones_restantes = 3
			_set_estado(Estado.MINIJUEGO)
			pulsaciones_minijuego.emit(_pulsaciones_restantes)
			_rearmar_ventana_fase_b()
		Estado.MINIJUEGO:
			_pulsaciones_restantes -= 1
			pulsaciones_minijuego.emit(_pulsaciones_restantes)
			if _pulsaciones_restantes <= 0:
				_set_estado(Estado.CAPTURA)
			else:
				_rearmar_ventana_fase_b()
		_:
			pass

func _rearmar_ventana_fase_b() -> void:
	_abrir_ventana(_on_ventana_fase_b_expirada)

## Fase A expirada -> escape
func _on_ventana_fase_a_expirada() -> void:
	if estado == Estado.PICADA:
		_escapar()

## Fase B expirada -> escape
func _on_ventana_fase_b_expirada() -> void:
	if estado == Estado.MINIJUEGO:
		_escapar()

func _escapar() -> void:
	_set_estado(Estado.ESCAPE)
	_set_estado(Estado.IDLE)

## Cancelar (chunk descargado, pausa prolongada): sin castigo (§6).
func cancelar(_motivo: String) -> void:
	_set_estado(Estado.IDLE)

func get_estado() -> int:
	return estado
