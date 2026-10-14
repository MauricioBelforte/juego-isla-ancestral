# asset_preview.gd — M108 Pipeline de Assets (RF9)
# Escena de preview: caja de referencia de 1 m + cámara orbitante.
# Uso en editor: abrir scenes/asset_preview.tscn.
# Uso headless: godot --headless --path game/isla-ancestral scenes/asset_preview.tscn --auto-quit
# Carga opcional de un asset junto a la caja: --asset res://assets/3d/media/18-Casas_pared_madera.glb
#
# **Modelo:** Ling 3.1 Flash
# **Plataforma:** Kilo Code
# **Fecha:** 2026-10-14

extends Node3D

const RADIO_ORBITA := 3.0
const ALTURA_CAMARA := 1.6
const VELOCIDAD_ORBITA := 0.6
const CUADRO_REFERENCIA := Vector3(0.5, 0.5, 0.5)

var _camara: Camera3D
var _angulo := 0.0
var _frames := 0
var _auto_quit := false

func _ready() -> void:
	_camara = $CamaraOrbitante as Camera3D
	var args := OS.get_cmdline_args()
	if args.has("--auto-quit"):
		_auto_quit = true
	_cargar_asset_cmdline(args)
	print("[M108] asset_preview: escena lista — caja de referencia de 1 m + cámara orbitante")

func _cargar_asset_cmdline(args: PackedStringArray) -> void:
	var idx := args.find("--asset")
	if idx < 0 or idx + 1 >= args.size():
		return
	var ruta := args[idx + 1]
	var empaquetada: PackedScene = load(ruta)
	if empaquetada == null:
		push_warning("[M108] asset_preview: no se pudo cargar el asset %s" % ruta)
		return
	var asset: Node = empaquetada.instantiate()
	add_child(asset)
	print("[M108] asset_preview: asset cargado para revision: %s" % ruta)

func _process(delta: float) -> void:
	_angulo += delta * VELOCIDAD_ORBITA
	if _camara != null:
		_camara.global_position = Vector3(
			cos(_angulo) * RADIO_ORBITA,
			ALTURA_CAMARA,
			sin(_angulo) * RADIO_ORBITA
		)
		_camara.look_at(CUADRO_REFERENCIA, Vector3.UP)
	if _auto_quit:
		_frames += 1
		if _frames > 90:
			get_tree().quit(0)
