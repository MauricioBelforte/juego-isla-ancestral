# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M18 iter 9: Test de interior (cámara + colisiones + transición).
extends SceneTree

var _fallos := 0
var _checks := 0
const CHECKS_MINIMOS := 15

func _initialize() -> void:
	print("=== TEST M18 INTERIOR: Cámara + Colisiones + Transición ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	# ── Cámara interior ──
	var cam_script: Script = load("res://scripts/houses/interior_camera.gd")
	_check("InteriorCamera.gd carga", cam_script != null)
	if cam_script != null:
		var cam: Node3D = cam_script.new()
		_check("cámara no interior por defecto", not cam.es_interior())
		cam.entrar_habitacion("casa_1", "living")
		_check("cámara interior tras entrar", cam.es_interior())
		_check("habitacion=living", cam.obtener_habitacion() == "living")
		_check("casa_id=casa_1", cam.obtener_casa_id() == "casa_1")
		_check("FOV interior=60", float(cam.obtener_fov()) == 60.0)
		cam.salir_habitacion()
		_check("cámara exterior tras salir", not cam.es_interior())
		_check("FOV exterior=75", float(cam.obtener_fov()) == 75.0)
		_check("limite habitación", cam.obtener_limite().x > 0.0)

	# ── Colisiones interior ──
	var col_script: Script = load("res://scripts/houses/interior_collision.gd")
	_check("InteriorCollision.gd carga", col_script != null)
	if col_script != null:
		var col: Node3D = col_script.new()
		var n: int = col.generar_colisiones("living")
		_check("colisiones living: 5 formas (1 suelo + 4 paredes)", n == 5)
		_check("habitacion=living", col.obtener_habitacion() == "living")
		_check("es_interior(0,0,0)=true", col.es_interior(Vector3.ZERO))
		_check("es_interior(10,0,0)=false", not col.es_interior(Vector3(10, 0, 0)))
		col.limpiar()
		_check("limpiar: 0 formas", col.cantidad_formas() == 0)
		# Cocina
		col.generar_colisiones("cocina")
		_check("colisiones cocina: 5 formas", col.cantidad_formas() == 5)

	# ── Transición (fundido) ──
	var trans_script: Script = load("res://scripts/houses/interior_transition.gd")
	_check("InteriorTransition.gd carga", trans_script != null)
	if trans_script != null:
		var trans: Control = trans_script.new()
		_check("transición no activa por defecto", not trans.esta_activa())
		trans.set_progreso(0.0)
		_check("progreso=0", float(trans.obtener_progreso()) == 0.0)
		trans.set_progreso(1.0)
		_check("progreso=1", float(trans.obtener_progreso()) == 1.0)
		_check("completado (progreso=1)", trans.esta_completado())

	# ── Red de seguridad ──
	create_timer(0.3).timeout.connect(func(): _fin())

func _fin() -> void:
	_resumen()
	quit(1 if _fallos > 0 else 0)

func _resumen() -> void:
	print("=== Resumen M18-INT: %d checks, %d fallos ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("WARNING: solo %d checks (mínimo %d)" % [_checks, CHECKS_MINIMOS])

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
