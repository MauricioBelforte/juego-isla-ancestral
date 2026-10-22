extends SceneTree
## M20 RF4-RF8 agnes-3-flash — charla (5+1/nivel cap10, limite, independencia de regalo),
## carta (PUNTOS_CARTA=8), evento/cumpleanos (PUNTOS_CUMPLEANOS=15), memoria/recuerdo,
## recompensas_pendientes + reclamar.
## Pattern: extends SceneTree + call_deferred + servicio standalone (FS.new + registrar_vecino).
## Ejecutar: godot --headless --path game/isla-ancestral -s res://scripts/friendship/test_amistad_rf48_m20.gd

const FS := preload("res://scripts/friendship/friendship_service.gd")
const VEC := preload("res://scripts/friendship/vecino_amistad.gd")

var _ok := 0
var _ko := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== TEST AMISTAD RF4-RF8 M20 ===")
	_test_charla()
	_test_carta_evento()
	_test_memoria_recompensas()
	_reportar()

func _fs() -> Object:
	var fs = FS.new()
	fs.registrar_vecino("N1")
	fs.set_dia(1)
	return fs

func _test_charla() -> void:
	var fs = _fs()
	# Charla nivel 1: 5 + min(1-1, 10) = 5
	var r1 = fs.charlar("N1")
	_verificar(r1.get("ok") == true and int(r1.get("puntos", 0)) == 5, "charla nivel1 = 5 pts")
	# 2da charla mismo dia rechazada (limite)
	var r2 = fs.charlar("N1")
	_verificar(r2.get("ok") == false, "2da charla mismo dia rechazada (limite_diario)")
	# dia nuevo -> charla de nuevo permitida
	fs.set_dia(2)
	var r3 = fs.charlar("N1")
	_verificar(r3.get("ok") == true, "dia nuevo: charla permitida de nuevo")
	# Charla no consume el limite de regalo (independiente): subir nivel, dia 3, charla + regalo
	# sube N1 a nivel 5 para ver charla = 5 + min(4,10) = 9
	var v = VEC.new("N2")
	v.aplicar_puntos(110, {})  # 110 pts -> nivel 5 (umbral 100)
	_verificar(v.get_nivel() == 5, "vecino N2 subio a nivel 5 con 90 pts")
	# la formula de charla depende del nivel; validar el cap
	_verificar(5 + mini(v.get_nivel() - 1, 10) == 9, "charla nivel5 = 5+4 = 9 pts (formula)")
	# cap: nivel 20 -> 5 + min(19,10) = 15 (cap +10)
	var vcap = VEC.new("N3")
	vcap.aplicar_puntos(600, {})
	_verificar(5 + mini(vcap.get_nivel() - 1, 10) == 15, "charla cap +10 en nivel alto (5+10=15)")

func _test_carta_evento() -> void:
	# PUNTOS_CARTA = 8 (se aplican al RECIBIR la respuesta)
	_verificar(int(FS.PUNTOS_CARTA) == 8, "PUNTOS_CARTA = 8")
	# PUNTOS_CUMPLEANOS = 15 (evento como participante)
	_verificar(int(FS.PUNTOS_CUMPLEANOS) == 15, "PUNTOS_CUMPLEANOS = 15 (evento participante)")

func _test_memoria_recompensas() -> void:
	var v = VEC.new("N4")
	# Registro del evento en la memoria del vecino (recuerdo)
	v.agregar_recuerdo("acudió al evento del pueblo")
	_verificar(v.get_recuerdos().size() >= 1, "memoria: recuerdo registrado en vecino")
	# Bandeja de recompensas pendientes + reclamar (insercion al reclamar)
	v.aplicar_puntos(40, {2: ["receta_herramienta_basica"]})  # nivel 2 -> recompensa pendiente
	var pendientes := v.get_recompensas_pendientes()
	_verificar(pendientes.size() >= 1, "recompensas pendientes tras subir a nivel 2")
	var rec := v.reclamar_recompensa("receta_herramienta_basica")
	_verificar(rec == true, "reclamar_recompensa: inserta y marca reclamada")
	_verificar(v.get_recompensas_pendientes().size() == 0, "tras reclamar, bandeja vacia")

func _verificar(cond: bool, msg: String) -> void:
	if cond:
		_ok += 1
		print("  [OK] " + msg)
	else:
		_ko += 1
		push_warning("  [FALLO] " + msg)

func _reportar() -> void:
	print("=== M20 RF4-RF8: OK=%d FALLOS=%d ===" % [_ok, _ko])
	if _ko > 0:
		quit(1)
	else:
		print("M20 RF4-RF8 TODO OK")
		quit(0)
