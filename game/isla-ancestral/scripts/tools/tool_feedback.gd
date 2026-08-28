# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-28
#
# M13: Herramientas — ToolFeedback (sonido + partículas, desacoplado del controlador)
# Escucha señales del ToolController y reproduce feedback perceptivo (RF7).
# Sonidos sintetizados en runtime (AudioStreamWAV); M65 reemplazará por assets finales.
# Partículas: pool de GPUParticles3D one-shot con color por material.

## Feedback perceptivo de herramientas: golpes, extracciones, colocación y fallos.
class_name ToolFeedback
extends Node

## Pool de reproductores de audio (round-robin)
var _audio_pool: Array[AudioStreamPlayer] = []
var _audio_idx: int = 0

## Pool de emisores de partículas (round-robin)
var _particle_pool: Array[GPUParticles3D] = []
var _particle_idx: int = 0

## Streams sintetizados por material
var _sonidos: Dictionary = {}

const SAMPLE_RATE: int = 22050
const POOL_AUDIO: int = 5
const POOL_PARTICULAS: int = 8

func _ready() -> void:
	_sonidos["piedra"] = _sintetizar([[1400.0, 0.35], [2600.0, 0.18]], 0.10, 26.0, 0.65)
	_sonidos["tierra"] = _sintetizar([[95.0, 0.85], [55.0, 0.5]], 0.13, 22.0, 0.25)
	_sonidos["madera"] = _sintetizar([[240.0, 0.8], [480.0, 0.3]], 0.11, 30.0, 0.15)
	_sonidos["generico"] = _sintetizar([[520.0, 0.5]], 0.09, 28.0, 0.3)
	_sonidos["colocar"] = _sintetizar([[320.0, 0.5], [640.0, 0.22]], 0.09, 34.0, 0.12)
	_sonidos["fallo"] = _sintetizar([[180.0, 0.45]], 0.09, 30.0, 0.1)
	_sonidos["romper"] = _sintetizar([[900.0, 0.4], [1800.0, 0.2]], 0.16, 16.0, 0.8)
	for i in POOL_AUDIO:
		var p := AudioStreamPlayer.new()
		p.name = "Audio_%d" % i
		p.volume_db = -6.0
		add_child(p)
		_audio_pool.append(p)
	for i in POOL_PARTICULAS:
		var e := _crear_emisor()
		e.name = "Particulas_%d" % i
		add_child(e)
		_particle_pool.append(e)

## Callbacks conectados por el ToolController ──────────────────

func _on_golpe_conectado(pos: Vector3i, _block_id: int, material: String, _progreso: float) -> void:
	_reproducir(_sonidos.get(material, _sonidos["generico"]))
	_reventar(pos, _color_de_material(material), 10)

func _on_bloque_extraido(pos: Vector3i, _block_id: int, drops: Array) -> void:
	var material: String = "generico"
	if not drops.is_empty():
		var item_id: String = str(drops[0].get("item_id", ""))
		material = _material_de_item(item_id)
	_reproducir(_sonidos["romper"])
	_reproducir(_sonidos.get(material, _sonidos["generico"]))
	_reventar(pos, _color_de_material(material), 20)

func _on_bloque_colocado(pos: Vector3i, _block_id: int) -> void:
	_reproducir(_sonidos["colocar"])
	_reventar(pos, Color(0.9, 0.9, 0.9), 6)

func _on_golpe_fallido(_pos: Vector3i, razon: String) -> void:
	if razon == "permanente" or razon == "inutilizada" or razon == "herramienta_equivocada":
		_reproducir(_sonidos["fallo"])

## Síntesis de audio ────────────────────────────────────────────

## Genera un AudioStreamWAV: suma de parciales + ruido, con envolvente exponencial.
## freqs: [[frecuencia_hz, amplitud], ...], dur: segundos, decay: tasa exponencial, ruido: mezcla 0-1
func _sintetizar(freqs: Array, dur: float, decay: float, ruido: float) -> AudioStreamWAV:
	var n: int = int(SAMPLE_RATE * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t: float = float(i) / float(SAMPLE_RATE)
		var env: float = exp(-t * decay)
		if t < 0.004:
			env *= t / 0.004
		var muestra: float = 0.0
		for par in freqs:
			var f: float = float(par[0])
			var a: float = float(par[1])
			muestra += a * sin(TAU * f * t)
		if ruido > 0.0:
			muestra = muestra * (1.0 - ruido) + (randf() * 2.0 - 1.0) * ruido
		muestra *= env
		var v: int = int(clampf(muestra, -1.0, 1.0) * 32000.0)
		data.encode_s16(i * 2, v)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	return wav

func _reproducir(stream: AudioStreamWAV) -> void:
	if stream == null:
		return
	var p := _audio_pool[_audio_idx]
	_audio_idx = (_audio_idx + 1) % POOL_AUDIO
	p.stream = stream
	p.play()

## Partículas ───────────────────────────────────────────────────

func _crear_emisor() -> GPUParticles3D:
	var e := GPUParticles3D.new()
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 55.0
	pm.initial_velocity_min = 1.5
	pm.initial_velocity_max = 3.5
	pm.gravity = Vector3(0, -9.8, 0)
	pm.scale_min = 0.6
	pm.scale_max = 1.2
	pm.color = Color(0.7, 0.7, 0.7)
	e.process_material = pm
	var quad := QuadMesh.new()
	quad.size = Vector2(0.14, 0.14)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	quad.material = mat
	e.draw_pass_1 = quad
	e.amount = 14
	e.lifetime = 0.55
	e.one_shot = true
	e.explosiveness = 1.0
	e.emitting = false
	e.top_level = true
	return e

func _reventar(pos: Vector3i, color: Color, cantidad: int) -> void:
	var e := _particle_pool[_particle_idx]
	_particle_idx = (_particle_idx + 1) % POOL_PARTICULAS
	var pm: ParticleProcessMaterial = e.process_material
	pm.color = color
	e.amount = cantidad
	e.global_position = Vector3(pos) + Vector3(0.5, 0.5, 0.5)
	e.restart()

## Colores de partícula por material/categoría de bloque (M08).
func _color_de_material(material: String) -> Color:
	match material:
		"tierra":
			return Color(0.55, 0.35, 0.2)
		"piedra":
			return Color(0.65, 0.65, 0.68)
		"madera":
			return Color(0.45, 0.3, 0.15)
		"nieve":
			return Color(0.95, 0.95, 0.98)
		"agua":
			return Color(0.2, 0.4, 0.8)
		_:
			return Color(0.7, 0.7, 0.7)

func _material_de_item(item_id: String) -> String:
	if item_id in ["dirt", "grass", "sand", "clay", "mud", "gravel", "snow", "moss"]:
		return "tierra"
	if item_id in ["stone", "copper_ore", "iron_ore", "crystal", "gemstone"]:
		return "piedra"
	if item_id in ["wood", "planks"]:
		return "madera"
	if item_id == "ice":
		return "nieve"
	return "generico"
