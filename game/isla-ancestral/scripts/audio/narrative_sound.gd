# Modelo: deepseek-v4-flash (iter. 1) / mimo-v2.5 (iter. 2)
# Plataforma: Kilo Code / OpenCode
# Fecha: 2026-09-01 (iter. 1), 2026-09-20 (iter. 2)
#
# M150: Diseno Sonoro Narrativo — NarrativeSound (autoload)
# Catalogo de sonidos narrativos por momento: sellos, templos, resonancia,
# Elysia, leitmotifs, reglas narrativas. Data-driven desde JSON.
# Adaptacion Godot 4.7/GDScript del diseno (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

signal leitmotif_started(leitmotif_id: String)
signal leitmotif_ended(leitmotif_id: String)
signal momento_played(momento_id: String)
signal silencio_started(duracion: float)

const RUTA_NARRATIVA := "res://data/audio/narrative_sound.json"

var config: Dictionary = {}
var current_leitmotif: String = ""
var audio_context: String = "calm"  # calm, tension, danger
var _silencio_timer: SceneTreeTimer = null

func _ready() -> void:
	_cargar_narrativa()
	_registrar_servicio()
	print("[M150] NarrativeSound listo (%d momentos, %d leitmotifs)" % [
		config.get("momentos", {}).size(),
		config.get("leitmotifs", {}).size()
	])

func _cargar_narrativa() -> void:
	if not FileAccess.file_exists(RUTA_NARRATIVA):
		push_warning("[M150] narrative_sound.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_NARRATIVA))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("narrative_sound"):
		sr.register("narrative_sound", self)

## Obtiene la configuracion de sonido para un momento narrativo.
func momento(id: String) -> Dictionary:
	return config.get("momentos", {}).get(id, {})

func leitmotif(id: String) -> Dictionary:
	return config.get("leitmotifs", {}).get(id, {})

func regla(nombre: String) -> bool:
	return bool(config.get("reglas", {}).get(nombre, false))

func momentos_ids() -> Array:
	return config.get("momentos", {}).keys()

## Reproduce un leitmotif con variacion segun contexto.
func play_leitmotif(leitmotif_id: String, context: String = "calm") -> void:
	if leitmotif_id.is_empty():
		push_warning("[M150] leitmotif_id vacio")
		return
	var lm := leitmotif(leitmotif_id)
	if lm.is_empty():
		push_warning("[M150] Leitmotif no encontrado: %s" % leitmotif_id)
		return
	current_leitmotif = leitmotif_id
	audio_context = context
	leitmotif_started.emit(leitmotif_id)
	# La reproduccion real depende de M41 (Musica) — aqui solo emitimos senales
	# y registramos el estado. El MusicDirector escucha leitmotif_started.

## Detiene el leitmotif actual.
func stop_leitmotif() -> void:
	if current_leitmotif.is_empty():
		return
	var ended_id := current_leitmotif
	current_leitmotif = ""
	leitmotif_ended.emit(ended_id)

## Configura el contexto de audio (calm, tension, danger).
func set_audio_context(context: String) -> void:
	audio_context = context
	if not current_leitmotif.is_empty():
		play_leitmotif(current_leitmotif, context)

## Configuracion inicial de contexto de audio.
func setup_audio_context() -> void:
	audio_context = "calm"

## Reproduce un momento narrativo por ID. Devuelve true si se ejecuto.
func play_momento(momento_id: String) -> bool:
	var m := momento(momento_id)
	if m.is_empty():
		push_warning("[M150] Momento no encontrado: %s" % momento_id)
		return false
	var lm_id: String = m.get("leitmotif", "")
	if not lm_id.is_empty():
		play_leitmotif(lm_id, audio_context)
	momento_played.emit(momento_id)
	return true

## Reproduce sonido de descubrimiento.
func play_discovery_sound() -> void:
	play_momento("descubre_isla")

## Reproduce sonido de misterio.
func play_mystery_sound() -> void:
	play_momento("misterio_detectado")

## Reproduce sonido de puerta antigua.
func play_ancient_door_sound() -> void:
	play_momento("puerta_ancestral")

## Reproduce sonido de maquina ancestral.
func play_machine_sound() -> void:
	play_momento("maquina_ancestral")

## Reproduce sonido de telemetria ancestral.
func play_telemetry_sound() -> void:
	play_momento("telemetria_ancestral")

## Reproduce silencio narrativo (pausa de impacto).
func play_narrative_silence(duration: float) -> void:
	if duration <= 0.0:
		return
	stop_leitmotif()
	silencio_started.emit(duration)
	# La pausa es logica — el MusicDirector debe silenciar su salida
	await get_tree().create_timer(duration).timeout
