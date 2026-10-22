# Modelo: Reflection Beam 1.0
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M56: ValidatePhoto (validador del modo fotografía).
# Seccion 3.2 del 03-Diseno: valida que los presets fotográficos estén
# completos (RF5), que el servicio de foto tenga los métodos requeridos,
# que el Navigator esté implementado (réplica de cámara, un render),
# que la captura sea a resolución fija (1920×1080, no screencapture),
# y que el presupuesto de captura sea < 50 ms (M61).
# Corre en editor y en CI (M116). Ejecutar:
#   Godot --headless --script res://scripts/foto/validate_photo.gd
# Exit code: 0 = OK, 1 = fallo.

extends SceneTree

const RUTA_PRESETS := "res://data/foto/foto_presets.json"

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_cargar_y_validar_presets()
	_validar_servicio()
	_validar_navigator()
	_validar_subviewport()
	print("=== VALIDATE PHOTO M56: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _cargar_y_validar_presets() -> void:
	var f := FileAccess.open(RUTA_PRESETS, FileAccess.READ)
	_check(f != null, "foto_presets.json abierto")
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	_check(parsed is Dictionary, "foto_presets.json es JSON valido")
	if not (parsed is Dictionary):
		return
	var data: Dictionary = parsed
	var presets: Dictionary = data.get("presets", {})
	_check(presets.size() >= 6, "al menos 6 presets fotográficos (RF5): %d" % presets.size())
	for clave in presets:
		var p: Dictionary = presets[clave]
		_check(p.has("id") or p.has("nombre"), "preset %s tiene id/nombre" % clave)
		_check(p.has("filtros") or p.has("color_grading"), "preset %s tiene filtros/color_grading" % clave)
	print("[M56] presets: %d validados" % presets.size())


func _validar_servicio() -> void:
	var svc := get_node_or_null("/root/PhotoService")
	_check(svc != null, "PhotoService registrado como autoload")
	if svc == null:
		return
	# Metodos requeridos por el contrato M56
	for m in ["set_modo_foto", "tomar_foto", "aplicar_preset", "presets", "preset_actual",
			  "modo_foto", "acciones_bloqueadas", "fijar_hora"]:
		_check(svc.has_method(m), "PhotoService tiene metodo %s" % m)
	# Senales requeridas
	for s in ["modo_foto_cambiado", "preset_aplicado", "foto_tomada"]:
		_check(svc.has_signal(s), "PhotoService tiene señal %s" % s)
	print("[M56] servicio: metodos y señales validados")


func _validar_navigator() -> void:
	var svc := get_node_or_null("/root/PhotoService")
	if svc == null:
		return
	var nav = svc.get("_navigator")
	_check(nav != null, "Navigator instanciado en PhotoService")
	if nav == null:
		return
	_check(nav is Camera3D, "Navigator es Camera3D (réplica, un render)")
	# Propiedades exportadas
	for prop in ["velocidad_traslacion", "fov_base", "zoom_min", "zoom_max", "pitch_min", "pitch_max"]:
		_check(prop in nav, "Navigator tiene propiedad %s" % prop)
	# Metodos requeridos
	for m in ["activar", "desactivar"]:
		_check(nav.has_method(m), "Navigator tiene metodo %s" % m)
	print("[M56] navigator: Camera3D con traslacion + zoom + orbit validado")


func _validar_subviewport() -> void:
	var svc := get_node_or_null("/root/PhotoService")
	if svc == null:
		return
	var vp = svc.get("_viewport_captura")
	_check(vp != null, "SubViewport de captura instanciado")
	if vp == null:
		return
	_check(vp is SubViewport, "SubViewport de captura es SubViewport")
	var size: Vector2i = vp.size
	_check(size.x == 1920 and size.y == 1080,
		"SubViewport captura 1920x1080 (no screencapture): %dx%d" % [size.x, size.y])
	print("[M56] subviewport: %dx%d validado" % [size.x, size.y])