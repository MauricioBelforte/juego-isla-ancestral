# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M42: Sonido Ambiental — AmbientDirector (autoload)
# Selección de banco + capas por bioma, hora/clima y fase.
# Diseño original (04-Codigo.md §1.1, ambient_director.gd).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

signal ambiente_cambiado(bioma: String, capas: Array)

const RUTA_BANCO := "res://data/audio/ambient_biome_bank.json"

var banco: Dictionary = {}
var bioma_actual: String = ""
var clima_actual: int = 0
var fase_actual: int = 0

func _ready() -> void:
	_cargar_banco()
	_registrar_servicio()
	print("[M42] AmbientDirector listo (%d biomas)" % banco.size())

func _cargar_banco() -> void:
	if not FileAccess.file_exists(RUTA_BANCO):
		push_warning("[M42] ambient_biome_bank.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_BANCO))
	if typeof(parsed) == TYPE_DICTIONARY:
		banco = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("ambient"):
		sr.register("ambient", self)

func set_bioma(bioma: String) -> void:
	if not banco.has(bioma):
		push_warning("[M42] Bioma desconocido: %s" % bioma)
		return
	bioma_actual = bioma
	_emitir_ambiente()

func set_estado_clima(clima: int, _intensidad: float) -> void:
	clima_actual = clima
	_emitir_ambiente()

func set_fase(fase: int) -> void:
	fase_actual = fase
	_emitir_ambiente()

func _emitir_ambiente() -> void:
	if bioma_actual.is_empty():
		return
	var entrada: Dictionary = banco.get(bioma_actual, {})
	var capas: Array = entrada.get("capas", []).duplicate()
	# Agregar capa de clima si existe
	var clima_key: String = "clima_%d" % clima_actual
	if entrada.has(clima_key):
		capas.append(entrada[clima_key])
	emit_signal("ambiente_cambiado", bioma_actual, capas)
	print("[M42] Ambiente: %s, capas=%s" % [bioma_actual, str(capas)])

func pausar() -> void:
	pass

func reanudar() -> void:
	pass