# Modelo: deepseek-v4-flash (iter. 1) / mimo-v2.5 (iter. 2)
# Plataforma: Kilo Code / OpenCode
# Fecha: 2026-09-01 (iter. 1), 2026-09-20 (iter. 2)
#
# M150: Diseno Sonoro Narrativo — NarrativeSound (autoload)
# Catalogo de sonidos narrativos por momento: sellos, templos, resonancia,
# Elysia, leitmotifs, reglas narrativas. Data-driven desde JSON.
# Adaptacion Godot 4.7/GDScript del diseno (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).
#
# --- iter. 3 (2026-10-15, step-5-kilocode / Kilo Code) ---
# Integracion de los 4 triggers de M150 (autorizada por el director, msg 379):
#   1. quest.prereq_met(seal_id) de M22/Historia -> momento de sello.
#   2. leitmotifs_por_isla + travel.island_loaded(isla) -> leitmotif de isla
#      con fade_out del anterior (regla fade_out_leitmotif_al_cambiar_zona).
#   3. trigger_lore_oculto() -> momento lore_oculto (API lista; M148 todavia no
#      emite evento por EventBus, ver NOTA al final del archivo).
#   4. sello_recordado -> repeticion del leitmotif al recordar un sello.

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
var isla_actual: String = ""  # isla cargada actual (para leitmotif por isla)

func _ready() -> void:
	_cargar_narrativa()
	_registrar_servicio()
	_conectar_eventos()
	print("[M150] NarrativeSound listo (%d momentos, %d leitmotifs)" % [
		config.get("momentos", {}).size(),
		config.get("leitmotifs", {}).size()
	])

## Suscribe los triggers cross-modulo via EventBus (patron Signal Up, Call Down,
## contrato M07). Si EventBus no esta disponible degrada sin error: el servicio
## sigue siendo invocable a mano.
func _conectar_eventos() -> void:
	var eb := get_node_or_null("/root/EventBus")
	if eb == null:
		push_warning("[M150] EventBus no disponible: triggers desactivados")
		return
	if not eb.quest.prereq_met.is_connected(_on_sello_prereq):
		eb.quest.prereq_met.connect(_on_sello_prereq)
	if not eb.travel.island_loaded.is_connected(_on_isla_cargada):
		eb.travel.island_loaded.connect(_on_isla_cargada)
	# TravelService (autoload) emite travel_arrived(island_id) en produccion; el
	# EventBus.travel.island_loaded existe en el bus pero ningun dominio lo emite
	# todavia (verificado 2026-10-15), por eso conectamos tambien la senal real.
	var ts := get_node_or_null("/root/TravelService")
	if ts != null and ts.has_signal("travel_arrived"):
		if not ts.travel_arrived.is_connected(_on_isla_cargada):
			ts.travel_arrived.connect(_on_isla_cargada)

## M22/Historia emite prereq_met(seal_id) por cada sello obtenido.
func _on_sello_prereq(seal_id: String) -> void:
	trigger_sello(seal_id)

## Entrada a isla: llega por EventBus.travel.island_loaded o por la senal real
## TravelService.travel_arrived (ambas llevan el id de isla).
func _on_isla_cargada(isla: String) -> void:
	on_cambio_isla(isla)

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

# ---------------------------------------------------------------- iter. 3
# Integracion M150 (step-5-kilocode, 2026-10-15)

## Devuelve el leitmotif asignado a una isla (RIZ/COR/CEN/AUR) o "" si no tiene.
##
## El proyecto usa TRES nomenclaturas de isla distintas (deuda de datos real):
##   - data/islas/islas.json .............. RIZ, COR, CEN, AUR
##   - data/herramientas/tiers_config.json  isla_raiz, isla_coral, isla_ceniza, isla_aurora
##   - data/viajes/rutas.json ............. isla_raiz, isla_sur, isla_norte, isla_brisa, isla_espejo
## Esta funcion normaliza las dos primeras. Las islas de viajes que no existen en
## el catalogo (isla_sur, isla_norte, isla_brisa, isla_espejo) devuelven "" y el
## llamador solo corta el leitmotif anterior.
func leitmotif_de_isla(isla: String) -> String:
	if isla.is_empty():
		return ""
	var clave := isla.to_lower()
	# alias explicitos por nomenclatura
	var alias := {
		"riz": "RIZ", "isla_raiz": "RIZ", "raiz": "RIZ",
		"cor": "COR", "isla_coral": "COR", "coral": "COR",
		"cen": "CEN", "isla_ceniza": "CEN", "ceniza": "CEN",
		"aur": "AUR", "isla_aurora": "AUR", "aurora": "AUR",
	}
	var codigo: String = alias.get(clave, isla.to_upper())
	return String(config.get("leitmotifs_por_isla", {}).get(codigo, ""))

## Trigger 1: sello obtenido o recordado (M22 emite prereq_met por sello).
## Aplica la regla silencio_narrativo_tras_sello cuando corresponde.
func trigger_sello(sello_id: String) -> bool:
	if sello_id.is_empty():
		push_warning("[M150] trigger_sello con id vacio")
		return false
	var ok := play_momento("sello_obtenido")
	if ok and regla("silencio_narrativo_tras_sello"):
		play_narrative_silence(1.0)
	return ok

## Trigger 1b: repeticion del leitmotif al recordar un sello ya obtenido.
## No tiene evento propio en M22 todavia: se invoca desde memoria/historia
## cuando el jugador vuelve a ver un sello.
func trigger_sello_recordado(sello_id: String) -> bool:
	if sello_id.is_empty():
		return false
	return play_momento("sello_recordado")

## Trigger 2: lore oculto encontrado.
## NOTA: M148-Lore-Ambiental todavia no emite ningun evento por EventBus
## (verificado 2026-10-15: scripts/lore/* no referencian EventBus). La API queda
## lista para que el dia que M148 emita, se conecte aqui sin tocar este archivo.
func trigger_lore_oculto(pieza_id: String = "") -> bool:
	return play_momento("lore_oculto")

## Trigger 3 y 4: cambio de isla/zona.
## Aplica fade_out del leitmotif anterior (regla fade_out_leitmotif_al_cambiar_zona)
## y arranca el leitmotif propio de la nueva isla si existe.
func on_cambio_isla(isla: String) -> void:
	if isla.is_empty() or isla == isla_actual:
		return
	var anterior := isla_actual
	isla_actual = isla.to_upper()
	var lm_id := leitmotif_de_isla(isla)
	if lm_id.is_empty():
		# Isla sin leitmotif propio: solo cortamos el anterior si la regla aplica
		if not anterior.is_empty() and regla("fade_out_leitmotif_al_cambiar_zona"):
			stop_leitmotif()
		return
	if regla("fade_out_leitmotif_al_cambiar_zona"):
		stop_leitmotif()
	play_leitmotif(lm_id, audio_context)
