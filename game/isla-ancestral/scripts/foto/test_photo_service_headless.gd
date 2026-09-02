# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M56: Test headless del núcleo fotográfico (PhotoService + FotoSchema).
# Aislado del runner gdUnit (la suite está colgada por la regresión ajena M163,
# documentada en ESTADO-PARALELO).

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

func _on_senal(activo: bool, contenedor: Array) -> void:
	contenedor[0] = activo

func _run() -> void:
	print("=== [M56] Test del núcleo fotográfico ===")
	# Schema
	var sc := load("res://scripts/foto/foto_schema.gd")
	var ok_preset := {"nombre": "Cálido", "saturacion": 1.08, "contraste": 1.05,
		"temperatura": 0.12, "vineta": 0.08, "dof": 0.0}
	_check("Schema: preset válido", sc.validar_preset("calido", ok_preset).is_empty())
	var mal := {"nombre": "", "saturacion": 0.0}
	var errs = sc.validar_preset("mal", mal)
	_check("Schema: rechaza nombre ausente", errs.has("nombre ausente"))
	_check("Schema: rechaza campo ausente", errs.has("campo ausente: contraste"))
	_check("Schema: rechaza saturación 0", errs.has("saturacion debe ser > 0"))
	# Service
	var service = load("res://scripts/foto/photo_service.gd").new()
	root.add_child(service)
	await process_frame
	_check("Service: 6 presets cargados", service.presets().size() == 6)
	_check("Service: contiene crepusculo_rojo", service.presets().has("crepusculo_rojo"))
	var senal := [false]
	service.modo_foto_cambiado.connect(_on_senal.bind(senal))
	service.set_modo_foto(true)
	_check("Service: modo foto activo", service.modo_foto())
	_check("Service: señal emitida", senal[0])
	var preset = service.aplicar_preset("calido_playa")
	_check("Service: preset calido_playa aplicado", float(preset["temperatura"]) == 0.12)
	var fallback = service.aplicar_preset("no_existe")
	_check("Service: preset inexistente → natural", fallback.has("nombre"))
	service.free()
	print("=== Resumen M56: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
