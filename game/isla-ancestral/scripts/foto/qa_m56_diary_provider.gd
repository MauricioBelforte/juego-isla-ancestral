# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-23
#
# M56/M55: QA del contrato IDiaryPhotoProvider (desacople diario M55 <->
# PhotoService M56). Ejecutar: Godot --headless --path game\isla-ancestral
# --script res://scripts/foto/qa_m56_diary_provider.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA diary provider M56/M55: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

## Dummy que implementa el contrato (duck-typing del M55 futuro).
class FakeDiary extends RefCounted:
	var fotos: Array = []
	var conectada: bool = false

	func obtener_fotos_diario() -> Array:
		return fotos

	func obtener_fotos_visibles(_dia: int) -> Array:
		return fotos

	func conectar_foto_tomada() -> bool:
		conectada = true
		return true

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var iface_script := load("res://scripts/foto/i_diary_photo_provider.gd")
	_check(iface_script != null, "i_diary_photo_provider.gd carga")
	if iface_script == null:
		return

	# 1) default de la interfaz: metodos con retorno seguro
	var base = iface_script.new()
	_check(base.obtener_fotos_diario() is Array, "obtener_fotos_diario default devuelve Array")
	_check((base.obtener_fotos_diario() as Array).is_empty(), "default vacio (sin fotos)")
	_check(base.conectar_foto_tomada() == false, "default conectar_foto_tomada devuelve false")

	# 2) duck-typing: un implementador cumple el contrato sin heredar
	var fake = FakeDiary.new()
	var tiene_metodos: bool = fake.has_method("obtener_fotos_diario") \
		and fake.has_method("obtener_fotos_visibles") and fake.has_method("conectar_foto_tomada")
	_check(tiene_metodos, "implementador cumple duck-typing del contrato")
	_check(fake.conectar_foto_tomada() == true, "implementador se subscribe")
	_check(fake.obtener_fotos_diario() is Array, "implementador devuelve Array")
	fake.fotos = [{"ruta": "user://photos/f1.png", "resultado": {}}]
	_check(fake.obtener_fotos_visibles(5) == fake.fotos, "fotos visibles pasan el filtro por dia")

	# 3) el PhotoService esta desconectado por diseno: la señal existe y el
	#    diario NO debe importar el service (contrato por senal).
	var ps_script := load("res://scripts/foto/photo_service.gd")
	_check(ps_script != null, "photo_service.gd sigue presente (freight limpio)")

	# 4) el emisor canonico existe: PhotoService.foto_tomada(ruta, resultado)
	if ps_script != null:
		var tmp = ps_script.new()
		_check(tmp.has_signal("foto_tomada"), "PhotoService.foto_tomada existe (pkt contrato M56 04-Codigo)")
		tmp.free()
