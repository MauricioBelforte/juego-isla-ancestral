extends SceneTree

## QA visual M154 (encargo msg 78) — Sonda de capturas de viewport.
## Correr SIN --headless (necesita rendering real):
##   Godot_v4.7.2-stable_win64_console.exe --path game/isla-ancestral \
##       --script res://tests/_qa_m154_sondas.gd
##
## Fases:
##   0) Espera a que bootstrap monte main_island + terreno (~10 s).
##   1) Cámara en la playa mirando al mar → captura M51 (mod 51).
##   2) Cámara junto al chamán (2320, 2300) → captura M163 (mod 163) + print
##      de su Y real (esperada ≈17, no 35).
##   3) Abre inventario del player → captura M53 (mod 53).
##   4) Quit.
##
## M154 protocolo: máx 5 iteraciones por ítem. Las capturas se guardan en
## tools/mcp/godot-mcp/capturas/{ID}/ con timestamp (nunca sobrescriben).

const ESPERA_BOOTSTRAP_S := 10.0
const CAPTURAS_ROOT := "res://../tools/mcp/godot-mcp/capturas"

var _fase := 0
var _t0 := 0.0
var _cam: Camera3D = null
var _capturas_ok: Array[String] = []


func _initialize() -> void:
	print("[QA-M154] Sonda iniciada (espera bootstrap %.0f s)..." % ESPERA_BOOTSTRAP_S)
	_t0 = float(Time.get_ticks_msec()) / 1000.0


func _process(delta: float) -> bool:
	var ahora := float(Time.get_ticks_msec()) / 1000.0
	var transcurrido := ahora - _t0

	match _fase:
		0:
			if transcurrido >= ESPERA_BOOTSTRAP_S:
				_fase = 1
				_preparar_camara_playa()
		1:
			# 2 s con la cámara en la playa para que el viewport repinte
			if transcurrido >= ESPERA_BOOTSTRAP_S + 2.0:
				_capturar(51, "post_bug105_mar_desde_playa")
				_fase = 2
				_preparar_camara_chaman()
		2:
			if transcurrido >= ESPERA_BOOTSTRAP_S + 4.0:
				_reportar_chaman()
				_capturar(163, "post_bug119_chaman_terreno")
				_fase = 3
				_abrir_inventario()
		3:
			if transcurrido >= ESPERA_BOOTSTRAP_S + 6.0:
				_capturar(53, "inventario_unificado_overlay")
				_fase = 4
		4:
			print("[QA-M154] Capturas OK: %d -> %s" % [_capturas_ok.size(), str(_capturas_ok)])
			quit(0)
			return true
	return false


## Cámara en la playa del SE mirando al centro (mar + costa a la vista).
func _preparar_camara_playa() -> void:
	_cam = Camera3D.new()
	_cam.name = "QACamPlaya"
	root.add_child(_cam)
	# Orilla SE: centro (2560,2560) + radio_orilla ~1700 en diagonal
	_cam.position = Vector3(3600.0, 28.0, 3600.0)
	_cam.look_at(Vector3(2560.0, 8.0, 2560.0), Vector3.UP)
	_cam.fov = 70.0
	_cam.current = true
	print("[QA-M154] Fase 1: cámara playa en ", _cam.position)


## Cámara a ~25 m del chamán, ligeramente elevada, mirándolo.
func _preparar_camara_chaman() -> void:
	var shaman := root.get_node_or_null("MainIsland/ShamanMonte")
	if shaman == null:
		# tolerar otro nombre de raíz de escena
		for h in root.get_children():
			shaman = h.get_node_or_null("ShamanMonte")
			if shaman:
				break
	if shaman == null or _cam == null:
		push_warning("[QA-M154] ShamanMonte no encontrado; la cámara se queda en la playa")
		return
	var pos := shaman.global_position
	_cam.position = pos + Vector3(18.0, 10.0, 18.0)
	_cam.look_at(pos + Vector3(0.0, 1.5, 0.0), Vector3.UP)
	_cam.current = true
	print("[QA-M154] Fase 2: cámara chamán cerca de ", pos)


func _reportar_chaman() -> void:
	var shaman := root.get_node_or_null("MainIsland/ShamanMonte")
	if shaman == null:
		for h in root.get_children():
			shaman = h.get_node_or_null("ShamanMonte")
			if shaman:
				break
	if shaman:
		print("[QA-M154][EVIDENCIA] ShamanMonte global_position = %s (Y esperada ~17, fallback 35)" % str(shaman.global_position))
	else:
		print("[QA-M154][EVIDENCIA] ShamanMonte NO encontrado en el árbol")


## Abre el inventario del player (patrón player.gd:_toggle_inventory).
func _abrir_inventario() -> void:
	var player := root.get_node_or_null("MainIsland/Player")
	if player == null:
		for h in root.get_children():
			player = h.get_node_or_null("Player")
			if player:
				break
	if player and player.has_method("_toggle_inventory"):
		player._toggle_inventory()
		print("[QA-M154] Fase 3: inventario alternado vía player._toggle_inventory()")
	elif player:
		push_warning("[QA-M154] Player sin _toggle_inventory; se captura sin overlay")
	else:
		push_warning("[QA-M154] Player no encontrado; se captura sin inventario")


## Captura el viewport actual y la guarda en capturas/{ID}/ (timestamped).
func _capturar(modulo_id: int, nota: String) -> void:
	var img := root.get_texture().get_image()
	if img == null:
		push_warning("[QA-M154] viewport texture null; captura módulo %d saltada" % modulo_id)
		return
	var carpeta := "%s/%d" % [CAPTURAS_ROOT, modulo_id]
	var da := DirAccess.open("res://..")
	if da and not da.dir_exists(carpeta.trim_prefix("res://../")):
		da.make_dir_recursive(carpeta.trim_prefix("res://../"))
	var stamp := Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system().replace(":", "-")
	var ruta := "%s/cap_%d_%s_%s.png" % [carpeta, modulo_id, stamp, nota]
	var err := img.save_png(ruta)
	if err == OK:
		_capturas_ok.append(ruta)
		print("[QA-M154][CAP] %s (%dx%d)" % [ruta, img.get_width(), img.get_height()])
	else:
		push_warning("[QA-M154] save_png err=%d para %s" % [err, ruta])
