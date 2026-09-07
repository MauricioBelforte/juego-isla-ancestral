# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-07
#
# TEMPORAL (M09): teleporta al player al lado oeste de la isla (r 1300 del
# centro) para que las montañas del centro queden en el cuadro. Captura 3
# frames y sale. Eliminar al finalizar.

extends Node

const PUNTO := Vector3(3860.0, 0.0, 3860.0)  # spawn real del jugador
const DELAY_BOOT := 10.0

var _delay := DELAY_BOOT

func _process(delta: float) -> void:
	if _delay > 0.0:
		_delay -= delta
		if _delay <= 0.0:
			_teleport()

func _teleport() -> void:
	var main := get_tree().root.get_node_or_null("Main")
	var player := main.get_node_or_null("Player") if main != null else null
	if player == null:
		get_tree().quit()
		return
	player.global_position = Vector3(PUNTO.x, 25.0, PUNTO.z)
	# Orientar al player hacia la montaña más alta (2460, h36, 2400) desde el
	# spawn — dist ~1460m: la vista REAL del usuario al mirar las montañas.
	var hacia_centro := Vector3(2460.0, 0.0, 2400.0) - Vector3(PUNTO.x, 0.0, PUNTO.z)
	player.rotation.y = atan2(-hacia_centro.x, -hacia_centro.z)
	print("[M51-CAP] player en el oeste r=1300, rotado hacia el centro")
	var tree := get_tree()
	for i in range(3):
		var t := tree.create_timer(2.0 + 2.0 * float(i))
		t.timeout.connect(_capturar.bind(i))

func _capturar(i: int) -> void:
	var img := get_viewport().get_texture().get_image()
	if img == null:
		return
	var dir := "user://capturas_m51"
	DirAccess.make_dir_recursive_absolute(dir)
	var ruta := "%s/montanas_%d.png" % [dir, i]
	var err := img.save_png(ruta)
	print("[M51-CAP] captura %d -> %s (err=%d)" % [i, ruta, err])
	if i == 2:
		get_tree().quit()
