extends Node

# Modelo: GLM (Kilo)
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M16: Crafting — Feedback procedural (SFX + VFX + notificación).
# RF12: feedback de éxito y descubrimiento sin assets externos.
# Genera un beep procedural (AudioStreamWAV en memoria) y un burst de partículas
# doradas (CPUParticles2D) en una CanvasLayer propia. Tolerante a headless.

const DURACION_BEEP_S: float = 0.18
const FRECUENCIA_BEEP_HZ: float = 660.0
const DURACION_DESCUBRIMIENTO_S: float = 0.28
const FRECUENCIA_DESCUBRIMIENTO_HZ: float = 880.0
const DURACION_ANCESTRAL_S: float = 0.35
const FRECUENCIA_ANCESTRAL_HZ: float = 1046.0
const DURACION_SECRETA_S: float = 0.32
const FRECUENCIA_SECRETA_HZ: float = 988.0

var _audio_ok: AudioStreamPlayer
var _audio_desc: AudioStreamPlayer
var _audio_anc: AudioStreamPlayer
var _audio_sec: AudioStreamPlayer
var _canvas: CanvasLayer
var _beep_data: AudioStreamWAV
var _desc_data: AudioStreamWAV
var _anc_data: AudioStreamWAV
var _sec_data: AudioStreamWAV


func _ready() -> void:
	_beep_data = _generar_seno(FRECUENCIA_BEEP_HZ, DURACION_BEEP_S, 0.35)
	_desc_data = _generar_seno(FRECUENCIA_DESCUBRIMIENTO_HZ, DURACION_DESCUBRIMIENTO_S, 0.45)
	_anc_data = _generar_seno(FRECUENCIA_ANCESTRAL_HZ, DURACION_ANCESTRAL_S, 0.5)
	_sec_data = _generar_seno(FRECUENCIA_SECRETA_HZ, DURACION_SECRETA_S, 0.48)
	_audio_ok = AudioStreamPlayer.new()
	_audio_ok.stream = _beep_data
	_audio_ok.bus = "Master"
	_audio_ok.volume_db = -6.0
	add_child(_audio_ok)
	_audio_desc = AudioStreamPlayer.new()
	_audio_desc.stream = _desc_data
	_audio_desc.bus = "Master"
	_audio_desc.volume_db = -4.0
	add_child(_audio_desc)
	_audio_anc = AudioStreamPlayer.new()
	_audio_anc.stream = _anc_data
	_audio_anc.bus = "Master"
	_audio_anc.volume_db = -3.5
	add_child(_audio_anc)
	_audio_sec = AudioStreamPlayer.new()
	_audio_sec.stream = _sec_data
	_audio_sec.bus = "Master"
	_audio_sec.volume_db = -3.5
	add_child(_audio_sec)
	_canvas = CanvasLayer.new()
	_canvas.layer = 90
	add_child(_canvas)

	var svc: Node = get_parent()
	if svc != null:
		if svc.has_signal("crafting_completed"):
			svc.crafting_completed.connect(_on_crafting_completed)
		if svc.has_signal("receta_descubierta"):
			svc.receta_descubierta.connect(_on_receta_descubierta)
		if svc.has_signal("crafting_failed"):
			svc.crafting_failed.connect(_on_crafting_failed)


func _on_crafting_completed(receta: CraftingRecipe, cantidad: int) -> void:
	_tocar(_audio_ok)
	_notificar("¡Listo! x%d %s" % [cantidad, receta.nombre], "ok")


func _on_receta_descubierta(receta: CraftingRecipe) -> void:
	var tags: Array = receta.tags if receta.has_method("get") and receta.get("tags") != null else []
	var es_ancestral: bool = tags.has("ancestral")
	var es_secreta: bool = tags.has("secreta")
	if es_ancestral:
		_tocar(_audio_anc)
		_notificar("¡Receta ancestral!: %s" % receta.nombre, "descubrimiento")
		_emitir_particulas_doradas(Color(1.0, 0.95, 0.7, 1.0), 32, 1.1)
	elif es_secreta:
		_tocar(_audio_sec)
		_notificar("¡Receta secreta!: %s" % receta.nombre, "descubrimiento")
		_emitir_particulas_doradas(Color(1.0, 0.9, 0.5, 1.0), 28, 1.0)
	else:
		_tocar(_audio_desc)
		_notificar("¡Nueva receta!: %s" % receta.nombre, "descubrimiento")
		_emitir_particulas_doradas(Color(1.0, 0.85, 0.35, 1.0), 24, 0.9)


func _on_crafting_failed(receta: CraftingRecipe, motivo: String) -> void:
	# Mensaje cozy, no punitivo (RF12)
	var texto: String = "Ups, no se pudo fabricar."
	if motivo == "materiales_insuficientes":
		texto = "Faltan materiales."
	elif motivo == "inventario_lleno":
		texto = "Inventario lleno; se devolvieron los materiales."
	elif motivo == "temporada_cerrada":
		texto = "Fuera de temporada."
	elif motivo == "ao_insuficiente":
		texto = "Monedas insuficientes."
	_notificar(texto, "fallo")


func _tocar(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return
	player.play()


func _notificar(texto: String, tipo: String) -> void:
	var notif: Node = get_node_or_null("/root/NotificationService")
	if notif == null:
		print("[M16] %s" % texto)
		return
	if notif.has_method("show_notification"):
		notif.show_notification(texto, tipo)
	else:
		print("[M16] %s" % texto)


func _emitir_particulas_doradas(color: Color = Color(1.0, 0.85, 0.35, 1.0), cantidad: int = 24, lifetime: float = 0.9) -> void:
	if _canvas == null:
		return
	var particulas := CPUParticles2D.new()
	particulas.emitting = true
	particulas.one_shot = true
	particulas.amount = cantidad
	particulas.lifetime = lifetime
	particulas.explosiveness = 0.85
	particulas.spread = 60.0
	particulas.initial_velocity_min = 80.0
	particulas.initial_velocity_max = 160.0
	particulas.gravity = Vector2(0, 180.0)
	particulas.scale_amount_min = 3.0
	particulas.scale_amount_max = 6.0
	particulas.color = color
	var centro := Node2D.new()
	centro.position = Vector2(640, 280)  # zona central superior
	_canvas.add_child(centro)
	centro.add_child(particulas)
	# Limpieza diferida
	var timer := get_tree().create_timer(1.2)
	if timer != null:
		timer.timeout.connect(func() -> void:
			if is_instance_valid(centro):
				centro.queue_free()
		)


# Genera un AudioStreamWAV en memoria con una onda sinusoidal corta.
# Robusto a headless (no requiere dispositivos de audio).
func _generar_seno(frecuencia: float, duracion: float, amplitud: float) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	var mix_rate: int = 22050
	var muestras: int = int(mix_rate * duracion)
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	var datos := PackedByteArray()
	datos.resize(muestras * 2)
	for i in range(muestras):
		var t: float = float(i) / float(mix_rate)
		# Envolvente (attack/release) para evitar clicks
		var env: float = 1.0
		var ataque: float = 0.01
		var release: float = 0.05
		if t < ataque:
			env = t / ataque
		elif t > duracion - release:
			env = maxi(0.0, (duracion - t) / release)
		var muestra: float = sin(TAU * frecuencia * t) * amplitud * env
		var muestra_i: int = clampi(int(muestra * 32767.0), -32768, 32767)
		# Little-endian 16-bit
		datos[i * 2] = muestra_i & 0xFF
		datos[i * 2 + 1] = (muestra_i >> 8) & 0xFF
	stream.data = datos
	return stream
