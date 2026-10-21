extends SceneTree

var _t := 0.0
var _escena: Node
var _storm := false
var _audio: AudioStreamWAV


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main_island.tscn")
	_escena = packed.instantiate()
	root.add_child(_escena)
	current_scene = _escena
	print("PROBE tormenta escena instanciada")


func _process(delta: float) -> bool:
	_t += delta
	if not _storm:
		if _t < 12.0:
			return false
		var gt: Node = root.get_node_or_null("/root/GameTime")
		var w: Node = root.get_node_or_null("/root/Weather")
		if gt == null or w == null:
			print("PROBE sin GameTime/Weather")
			quit()
			return true
		var clima := int(w.call("get_clima"))
		var dias := 0
		for i in 90:
			if clima == 3:
				break
			gt.call("avanzar_hasta", 23, 59)
			gt.call("avanzar_hasta", 0, 0)
			clima = int(w.call("get_clima"))
			dias += 1
		print("PROBE tormenta clima=%d dias=%d" % [clima, dias])
		_audio = AudioStreamWAV.new()
		_audio.format = AudioStreamWAV.FORMAT_16_BITS
		_audio.mix_rate = 44100
		_audio.stereo = false
		var datos := PackedByteArray()
		datos.resize(3 * 1024 * 1024)
		_audio.data = datos
		_storm = true
		_t = 0.0
		return false
	if _t < 3.0:
		return false
	var est := float(Performance.get_monitor(Performance.MEMORY_STATIC)) / 1048576.0
	var vram := float(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) / 1048576.0
	var tex := float(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)) / 1048576.0
	var buf := float(Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED)) / 1048576.0
	var obj := int(Performance.get_monitor(Performance.OBJECT_COUNT))
	print("PROBE static=%.1f vram=%.1f tex=%.1f buf=%.1f total_est=%.1f objects=%d audio=3.0"
		% [est, vram, tex, buf, est + vram, obj])
	quit()
	return true
