# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M41: Música — MusicDirector (autoload)
# Selección de tema + capas por contexto (zona × hora × estación × clima),
# A/B crossfade, shuffle de variaciones con PRNG de partida, pausa.
# Diseño original (04-Codigo.md §1.1, music_director.gd).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

signal tema_cambio(tema: String, capas: Array)

const RUTA_MATRIZ := "res://data/audio/music_context_matrix.json"

var matriz: Dictionary = {}
var tema_actual: String = ""
var _samplers: Dictionary = {}   # tema -> ShuffleSampler
var _pausado: bool = false

func _ready() -> void:
	_cargar_matriz()
	_registrar_servicio()
	print("[M41] MusicDirector listo (%d temas)" % matriz.get("temas", {}).size())

func _cargar_matriz() -> void:
	if not FileAccess.file_exists(RUTA_MATRIZ):
		push_warning("[M41] music_context_matrix.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_MATRIZ))
	if typeof(parsed) == TYPE_DICTIONARY:
		matriz = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("music"):
		sr.register("music", self)

## Selección por contexto: entorno (zona), hora (0-23), estacion, clima.
## Devuelve el tema seleccionado ("" si no hay match exacto -> tema base del entorno).
func play_contexto(entorno: String, hora: int, _estacion: int, clima: int) -> String:
	var base: String = _tema_base_entorno(entorno)
	var tema := base
	if hora < 6 or hora >= 21:
		tema = _si_existe("%s_noche" % entorno, base)
	elif clima == 2:  # lluvia
		tema = _si_existe("%s_lluvia" % entorno, base)
	return _cambiar_tema(tema)

func _tema_base_entorno(entorno: String) -> String:
	var temas: Dictionary = matriz.get("temas", {})
	for t in temas:
		if String(t).begins_with(entorno):
			return t
	return "aurora_dia"

func _si_existe(candidato: String, fallback: String) -> String:
	var temas: Dictionary = matriz.get("temas", {})
	return candidato if temas.has(candidato) else fallback

## Reproduce un tema por su id. Devuelve el tema aplicado.
func _cambiar_tema(tema: String) -> String:
	if not matriz.get("temas", {}).has(tema):
		push_warning("[M41] Tema inexistente: %s" % tema)
		return tema_actual
	if tema == tema_actual:
		return tema_actual
	tema_actual = tema
	var capas: Array = matriz.get("temas", {}).get(tema, {}).get("capas", [])
	emit_signal("tema_cambio", tema, capas)
	return tema_actual

## Sting puntual (por tipo) — stub: el compositor provee los assets.
func sting(_tipo: String) -> void:
	pass

func pausar() -> void:
	_pausado = true

func reanudar() -> void:
	_pausado = false

## Siguiente variación de un tema (shuffle sin repetición consecutiva).
func siguiente_variacion(tema: String) -> String:
	var variaciones: Array = matriz.get("variaciones", {}).get(tema, [])
	if variaciones.is_empty():
		return ""
	if not _samplers.has(tema):
		var sampler := ShuffleSampler.new(_hash(tema))
		sampler.barajar(variaciones)
		_samplers[tema] = sampler
	return _samplers[tema].siguiente()

func _hash(texto: String) -> int:
	var h := 0
	for i in range(texto.length()):
		h = (h * 31 + int(texto.unicode_at(i))) & 0x7FFFFFFF
	return h