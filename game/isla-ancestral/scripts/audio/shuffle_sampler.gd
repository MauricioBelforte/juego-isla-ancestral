# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M41: Música — ShuffleSampler
# Baraja variaciones de un tema con PRNG de partida (sin repetición
# consecutiva). Diseño original (04-Codigo.md §1.1, shuffle_sampler.gd).

class_name ShuffleSampler
extends RefCounted

var _indice: int = 0
var _barajada: Array = []
var _semilla: int = 0

func _init(seed_valor: int = 0) -> void:
	_semilla = seed_valor

## Baraja las variaciones con PRNG de la partida.
func barajar(variaciones: Array) -> void:
	_barajada = variaciones.duplicate()
	var rng := RandomNumberGenerator.new()
	rng.seed = _semilla
	for i in range(_barajada.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = _barajada[i]
		_barajada[i] = _barajada[j]
		_barajada[j] = tmp
	_indice = 0

## Siguiente variación sin repetir la última consecutivamente.
func siguiente() -> String:
	if _barajada.is_empty():
		return ""
	if _barajada.size() == 1:
		return String(_barajada[0])
	if _indice >= _barajada.size():
		# re-barajar evitando repetir la última al inicio
		var ultima: Variant = _barajada[_barajada.size() - 1]
		var rng := RandomNumberGenerator.new()
		rng.seed = _semilla + _indice
		var nueva := _barajada.duplicate()
		for i in range(nueva.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var tmp = nueva[i]
			nueva[i] = nueva[j]
			nueva[j] = tmp
		# si la primera == última, moverla
		if nueva[0] == ultima:
			var tmp = nueva[0]
			nueva[0] = nueva[1]
			nueva[1] = tmp
		_barajada = nueva
		_indice = 0
	var resultado := String(_barajada[_indice])
	_indice += 1
	return resultado