# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-04
#
# M21: Dialogos — TypewriterEffect
# Implementa efecto de escritura progresiva letra a letra para diálogos.
# Se integra con DialogueUI/M53 para mostrar texto carácter por carácter.

extends Node

## Velocidad de escritura (caracteres por segundo)
@export var chars_per_second: float = 30.0
## Temporizador acumulado
var _timer: float = 0.0
## Texto completo a mostrar
var _full_text: String = ""
## Índice actual del carácter
var _current_index: int = 0
## Señal cuando se completa la escritura
signal typing_complete()
## Señal para cada carácter mostrado (para animaciones)
signal character_shown(character: String, index: int)


## Inicia el efecto typewriter con un texto
func start(text: String) -> void:
	_full_text = text
	_current_index = 0
	_timer = 0.0
	typing_complete.emit()


## Actualiza el progreso (llamar desde _process o tween)
func update(delta: float) -> String:
	if _full_text.is_empty():
		return ""
	
	_timer += delta
	var chars_to_show: int = int(_timer * chars_per_second)
	
	if chars_to_show > _current_index:
		_current_index = chars_to_show
		if _current_index >= _full_text.length():
			_typing_complete()
	
	return _full_text.substr(0, _current_index)


## Devuelve el texto parcial hasta ahora
func get_partial_text() -> String:
	return _full_text.substr(0, _current_index)


## Devuelve verdadero si terminó de escribir
func is_finished() -> bool:
	return _current_index >= _full_text.length()


## Salta al texto completo (click para terminar)
func skip() -> String:
	_current_index = _full_text.length()
	_timer = 0.0
	_typing_complete()
	return _full_text


## Limpia el estado
func clear() -> void:
	_full_text = ""
	_current_index = 0
	_timer = 0.0


## Emite la señal de completado
func _typing_complete() -> void:
	typing_complete.emit()


## Método estático para obtener texto parcial rápido
static func get_partial(source: String, target_len: int) -> String:
	return source.substr(0, min(target_len, source.length()))


## Validación básica del efecto
static func validate_config(config: Dictionary) -> Array[String]:
	"""Retorna errores de configuración."""
	var errors: Array[String] = []
	var cps: float = float(config.get("chars_per_second", 30.0))
	if cps <= 0.0:
		errors.append("chars_per_second debe ser positivo")
	if cps > 100.0:
		errors.append("chars_per_second muy alto (>100)")
	return errors
